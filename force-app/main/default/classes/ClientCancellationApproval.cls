/**
 * @description ClientCancellationApproval
 */
@SuppressWarnings('PMD.ApexCRUDViolation')
public without sharing class ClientCancellationApproval {
	Map<Id, Client_Cancellation__c> newCollection;
	Map<Id, Client_Cancellation__c> oldCollection;
	list<Client_Cancellation__c> newList;

	Set<Id> areaMangerRequests = new Set<Id>();
	List<Client_Cancellation__c> areaMangerApprovals = new List<Client_Cancellation__c>();
	List<Client_Cancellation__c> areaMangerComments = new List<Client_Cancellation__c>();

	Map<Id, Id> clientBranch = new Map<Id, Id>();
	Map<String, Admin_Branch__c> branchAdminApproval = new Map<String, Admin_Branch__c>();
	Map<Id, Admin_Branch__c> cancellationCheck = new Map<Id, Admin_Branch__c>();
	Set<String> branchNames = new Set<String>();

	Boolean isAfter = false;
	Boolean isInsert = false;

	User loggedUser = [Select ID, ProfileID, Name, Title from User where ID = :UserInfo.getUserID() limit 1];

	/**
	 * @description handle controls the flow of before/after and update/insert
	 * @param  mapOld    How the objects looked before the changes
	 * @param  mapNew    How the objects looked with the changes
	 * @param  operation Operation being performed
	 */
	public void handle(
		Map<Id, Client_Cancellation__c> mapOld,
		Map<Id, Client_Cancellation__c> mapNew,
		System.TriggerOperation operation
	) {
		newCollection = mapNew;
		oldCollection = mapOld;
		newList = mapNew.values();

		isAfter = (operation == System.TriggerOperation.AFTER_INSERT ||
			operation == System.TriggerOperation.AFTER_UPDATE);

		isInsert = (operation == System.TriggerOperation.BEFORE_INSERT ||
			operation == System.TriggerOperation.AFTER_INSERT);

		if (isAfter) {
			updateCancellationReason(mapOld, mapNew);
		}

		if (!isAfter || isInsert) {
			checkUpdate();

			getAdminBranch();

			if (areaMangerApprovals.size() > 0 || areaMangerComments.size() > 0) {
				checkValidation();
			}

			if (areaMangerRequests.size() > 0) {
				sendAreaManagerEmail();
			}
		}
	}

	/**
	 * @description checkUpdate determines what must be changed.
	 */
	private void checkUpdate() {
		if (!isAfter) {
			for (Client_Cancellation__c c : newCollection.values()) {
				clientBranch.put(c.Client__c, c.ID);
				if (c.AM_Approval_Status__c != oldCollection.get(c.Id).AM_Approval_Status__c) {
					areaMangerApprovals.add(c);
				}
				if (oldCollection.get(c.Id).AM_Comments__c != c.AM_Comments__c) {
					areaMangerComments.add(c);
				}
			}
		} else if (isInsert) {
			for (Client_Cancellation__c c : newList) {
				clientBranch.put(c.Client__c, c.Id);
				areaMangerRequests.add(c.Client__c);
				
				if (c.AM_Approval_Status__c != null) {
					areaMangerApprovals.add(c);
				}
				if (c.AM_Comments__c != null) {
					areaMangerComments.add(c);
				}
			}
		}
	}

	/**
	 * @description getAdminBranch
	 */
	private void getAdminBranch() {
		for (Admin_Branch__c a : [SELECT Name, Admin_User__c FROM Admin_Branch__c]) {
			branchAdminApproval.put(a.name, a);
		}

		for (Account a : [SELECT Prospect_Branch__r.Name FROM Account WHERE Id IN :clientBranch.keySet()]) {
			branchNames.add(a.Prospect_Branch__r.Name);
			if (branchAdminApproval.containsKey(a.Prospect_Branch__r.Name)) {
				cancellationCheck.put(clientBranch.get(a.Id), branchAdminApproval.get(a.Prospect_Branch__r.Name));
			}
		}
	}

	/**
	 * @description sendAreaManagerEmail sends an email to the Area Manger about the cancellation request.
	 */
	private void sendAreaManagerEmail() {
		System.debug(LoggingLevel.FINER, 'ClientCancellationApproval.sendAreaManagerEmail: areaMangerRequests: ' + areaMangerRequests);

		AreaManagerEmail.areaManagerApprovalEmail(
			areaMangerRequests,
			UserInfo.getName(),
			branchNames,
			'Cancellation'
		);
	}

	/**
	 * @description checkValidation
	 */
	private void checkValidation() {
		//Area Manager Approval Check
		if (Profile_Service.mayConfigure(UserInfo.getProfileId())) {
			// Running user is not a System Adminstrator or Configuration Admin
			return;
		}

		Boolean isAreaManager = User_Services.actsAsAreaManager(UserInfo.getUserId());

		for (Client_Cancellation__c c : areaMangerApprovals) {
			if (!isAreaManager) {
				if (cancellationCheck.containsKey(c.Id)) {
					if (cancellationCheck.get(c.Id).Admin_User__c != loggedUser.Name) {
						newCollection.get(c.Id)
							.addError('You Must be a Area Manager or Delegated Admin to approve records.');
						areaMangerRequests.remove(c.Client__c);
					}
				} else {
					if (!isInsert) {
						newCollection.get(c.Id)
							.addError('You Must be a Area Manager or Delegated Admin to approve records.');
						areaMangerRequests.remove(c.Client__c);
					} else {
						newList[0].addError('You Must be a Area Manager or Delegated Admin to approve records.');
						areaMangerRequests.remove(newList[0].Client__c);
					}
				}
			}
		}
		//Area Manager Comment Check
		for (Client_Cancellation__c c : areaMangerComments) {
			if (!isAreaManager) {
				if (cancellationCheck.containsKey(c.Id)) {
					if (cancellationCheck.get(c.Id).Admin_User__c != loggedUser.Name) {
						newCollection.get(c.Id)
							.addError('You Must be the Approver or Delegated Aprover to edit Area Manager Comments.');
					}
				} else {
					if (!isInsert) {
						newCollection.get(c.Id)
							.addError('You Must be the Approver or Delegated Aprover to edit Area Manager Comments.');
					} else {
						newList[0]
							.addError('You Must be the Approver or Delegated Aprover to edit Area Manager Comments.');
					}
				}
			}
		}
	}

	@TestVisible
	private static void updateCancellationReason(Map<Id, Client_Cancellation__c> oldValues, Map<Id, Client_Cancellation__c> newValues) {
		Map<Id, Client_Cancellation__c> accountToCc = new Map<Id, Client_Cancellation__c>();

		for (Client_Cancellation__c cc : newValues.values()) {
			if (!cc.Revoke__c) {
				Client_Cancellation__c ccOld = oldValues?.get(cc.Id);

				if (ccOld == null || ccOld.Reason_for_Cancellation__c != cc.Reason_for_Cancellation__c) {
					accountToCc.put(cc.Client__c, cc);
				}
			}
		}

		if (!accountToCc.isEmpty()) {
			List<Account> updatedAccounts = new List<Account>();

			for (Account a : [
				SELECT Id, Name, Cancellation_Reason__c
				FROM Account
				WHERE Id IN :accountToCc.keySet()
				AND RecordType.Name = 'Terminated'
				AND Status__c = 'Terminated'
			]) {
				a.Cancellation_Reason__c = accountToCc.get(a.Id).Reason_for_Cancellation__c;
				updatedAccounts.add(a);
			}

			if (!updatedAccounts.isEmpty()) {
				update updatedAccounts;
			}
		}
	}
}