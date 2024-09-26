/**
 * User_TriggerHandler performs the trigger events for a User SObject.
 */
public with sharing class User_TriggerHandler extends TriggerHandlerInvoker.TriggerHandler_Abstract {
    private static final String FORMAT_LOG_CHANGE = ' {0} {1}  Ad User: {2} {3} Fed id: {4} {5} Email: {6} {7}';

	override public void beforeInsert(List<SObject> newList) {
		List<User> listNew = (List<User>) newList;

		confirmBranchId(listNew, null);
	}

	override public void afterInsert(Map<Id, SObject> newMap) {
		Map<Id, User> mapNew = (Map<Id, User>) newMap;

		populateContacts(null, mapNew);
	}

	override public void beforeUpdate(Map<Id, SObject> oldMap, Map<Id, SObject> newMap) {
		Map<Id, User> mapNew = (Map<Id, User>) newMap;
		Map<Id, User> mapOld = (Map<Id, User>) oldMap;

		if (confirmBranchId(mapNew.values(), mapOld)) {
			User_Services.limitEditOfUsers(mapNew, mapOld);
			User_Services.handleDeactivatedUsers(mapNew, mapOld);
			updateLogField(mapOld, mapNew);
		}
	}

	override public void afterUpdate(Map<Id, SObject> oldMap, Map<Id, SObject> newMap) {
		Map<Id, User> mapNew = (Map<Id, User>) newMap;
		Map<Id, User> mapOld = (Map<Id, User>) oldMap;

		populateContacts(mapOld, mapNew);
		User_Services.checkBusinessUnitMembers(mapNew, mapOld);
	}

	/**
	 * @description updateLogField update the User_Log_Changes__c field on the user.
	 * @param  oldMap User objects before changes
	 * @param  newMap Changes made to User objects
	 */
	public void updateLogField(Map<Id, User> oldMap, Map<Id, User> newMap) {
		User oldUser;

		for (User newUser : newMap.Values()) {
			oldUser = oldMap.get(newUser.id);

			if (oldUser.AD_Username__c != newuser.AD_Username__c ||
				oldUser.FederationIdentifier != newUser.FederationIdentifier ||
				oldUser.Email != newUser.Email ||
				oldUser.Username != newUser.UserName
			) {
				String newEntry = String.format(
                    FORMAT_LOG_CHANGE, 
                    new List<String>{
					    String.valueOf(System.Today()),  UserInfo.getUserName(), 
                        oldUser.AD_Username__c, newUser.AD_Username__c, 
                        oldUser.FederationIdentifier, newUser.FederationIdentifier, 
                        oldUser.Email, newUser.Email
                    }
                );

				newuser.User_Log_Changes__c += newEntry;
			}
		}
	}

	/**
	 * @description populateContacts for new Users with AD_Usernames, create a contact
	 * and for current users update the contact or deactivate it if the User is deactiveated.
	 * @param  newMap newMap description
	 * @param  oldMap oldMap description
	 */
	private void populateContacts(Map<Id, User> oldMap, Map<Id, User> newMap) {
		List<Id> userIds = new List<Id>();

		for (User u : newMap.Values()) {
			if (oldMap == null) {
				if (u.AD_Username__c != null) {
					userIds.add(u.Id);
				}
			} else if (changesMade(oldMap.get(u.Id), u)) {
				userIds.add(u.Id);
			}
		}

		if (!userIds.isEmpty()) {
			PopulateContacts.updateInsertContacts(userIds);
		}
	}

	/**
	 * @description confirmBranchId confirms the User has a Branch Id.
	 * @param  newUsers Changes made to User objects
	 * @param  oldMap User objects before changes
	 */
	private boolean confirmBranchId(List<User> newUsers, Map<Id, User> mapOld) {
		Boolean result = true;
		Set<String> branches = new Set<String>();

		for (User u : newUsers) {
			if (String.isBlank(u.Branch_Id__c)) {
				u.addError('Branch ID can not be blank');
				result = false;
			} else if (mapOld == null || u.Branch_Id__c != mapOld.get(u.Id).Branch_Id__c) {
				branches.add(u.Branch_Id__c);
			}
		}

		if (!branches.isEmpty()) {
			Set<String> foundBranches = getBranchesExist(branches);

			for (User u : newUsers) {
				if (u.Branch_Id__c != '910' && !foundBranches.Contains(u.Branch_Id__c)) {
					u.addError(u.Branch_Id__c + ' is not a valid branch number.');
					result = false;
				}
			}
		}

		return result;
	}

	/**
	 * @description getBranchesExist retrieves a list of Branch External Ids given
	 * the branch number.
	 * @param  branchesToLookFor Branch numbers looking for
	 * @ return The Set of found External Ids
	 */
	private Set<String> getBranchesExist(Set<String> branchesToLookFor) {
		Set<String> result = new Set<String>();

		for (Account a : [SELECT ID, External_ID__c FROM Account WHERE External_ID__c IN :branchesToLookFor]) {
			result.add(a.External_ID__c);
		}

		return result;
	}

	/**
	 * @description changesMade determines if a User's related Contact needs updating.
	 * @param  newUser Changes being made to a User object
	 * @param  oldUser User object before changes
	 * @return true if Contact related changes have been made
	 */
	private Boolean changesMade(User oldUser, User newUser) {
		if (newUser.Firstname != oldUser.FirstName ||
			newUser.LastName != oldUser.LastName ||
			newuser.Email != oldUser.Email ||
			newUser.Phone != oldUser.Phone ||
			newUser.MobilePhone != oldUser.MobilePhone ||
			newUser.Branch_Id__c != oldUser.Branch_Id__c ||
			newUser.AccountId != oldUser.AccountId ||
			newUser.isActive != oldUser.isActive ||
			newUser.AD_UserName__c != oldUser.AD_Username__c
		) {
			return true;
		}
		return false;
	}
}