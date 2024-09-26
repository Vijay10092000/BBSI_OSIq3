/**
 * LeadValidation contains Lead trigger handling methods.
 */
public without sharing class LeadValidation {
	Map<Id, Lead> newCollection;
	Map<Id, Lead> oldCollection;
	List<Lead> newList;
    Boolean isUpdate;

	Map<Id, Id> accountId = new Map<Id, Id>();
	Set<Id> leadAMEmail = new Set<Id>();
	Map<Id, Admin_Branch__c> leadCheck = new Map<Id, Admin_Branch__c>();
	Map<Id, Id> checkBranch = new Map<Id, Id>();

	Map<String, Admin_Branch__c> branchAdminApproval = new Map<String, Admin_Branch__c>();

	public void handle() {
        if (Trigger.isInsert && Trigger.isBefore) {
            beforeInsert(Trigger.new);
        }
        else if (Trigger.isInsert && Trigger.isAfter) {
            afterInsert(Trigger.newMap);
        }
        else if (Trigger.isUpdate && Trigger.isBefore) {
            beforeUpdate(Trigger.oldMap, Trigger.newMap);
        }
	}

	public void beforeInsert(List<Sobject> listNew) {
		List<Lead> newLeads = (List<Lead>) listNew;

		setCreationDate(newLeads);
	}

    public void afterInsert(Map<Id, Sobject> mapNew) {
        isUpdate = false;
	    newCollection = (Map<Id, Lead>) mapNew;
	    oldCollection = null;
        newList = newCollection.values();

		Map<String, List<Lead>> leadValidate = checkUpdates();

		if (!leadValidate.get('AMApproval').isEmpty() ||
			!leadValidate.get('AMComments').isEmpty() ||
			!leadCheck.isEmpty()
		) {
			checkValidation(branchAdminApproval, leadValidate);
		}
    }

    public void beforeUpdate(Map<Id, Sobject> mapOld, Map<Id, Sobject> mapNew) {
        isUpdate = true;
	    newCollection = (Map<Id, Lead>) mapNew;
	    oldCollection = (Map<Id, Lead>) mapOld;
        newList = newCollection.values();

		Map<String, List<Lead>> leadValidate = checkUpdates();

		if (!leadValidate.get('AMApproval').isEmpty() ||
			!leadValidate.get('AMComments').isEmpty() ||
			!leadCheck.isEmpty()
		) {
			checkValidation(branchAdminApproval, leadValidate);
		}
    }

	/**
	 *  checkUpdates through all possible validations and makes sure the right person modifies the
	 *  right field.  On Update and Insert it validates Approvals and Comments for Approvals on Area Managers.  When
	 *  a user updates the record the Business Development Manager field will get updated with the logged in user if
	 *  the field is blank. Also sends out an email to the Area Manager.
	 */
	private Map<String, List<Lead>> checkUpdates() {
		List<Lead> leadAMApproval = new List<Lead>();
		List<Lead> leadAMComments = new List<Lead>();
		Map<String, List<Lead>> leadValidate = new Map<String, List<Lead>>();
		Id idrtClientLead = recordTypeService.getId('Lead', 'Client_Lead');

		if (isUpdate) {
			String userAcronym = null;
			try {
				User loggedUser = [SELECT Id, Name, Acronym__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
				userAcronym = loggeduser.Acronym__c;
			} catch (Exception e) {
				System.debug(LoggingLevel.INFO, 'LeadValidation.checkUpdates(): Running as a Salesforce Process user userAcronym NOT Retrieved');
			}

			for (Lead newLead : newCollection.values()) {
                Lead oldLead = oldCollection.get(newLead.Id);

				if (newLead.RecordTypeId == idrtClientLead) {
					if (oldLead.AM_Approval_Status__c != newLead.AM_Approval_Status__c &&
                        newLead.AM_Approval_Status__c == 'Approved'
					) {
						leadAMApproval.add(newLead);
						checkBranch.put(newLead.Branch__c, newLead.Id);
					}

					if (oldLead.Request_Area_Manager_Approval__c != newLead.Request_Area_Manager_Approval__c &&
						newLead.Request_Area_Manager_Approval__c == true
					) {
						leadAMEmail.add(newLead.Id);
						accountId.put(newLead.Branch__c, newLead.Id);
					}

					if (oldLead.Area_Manager_Comments__c != newLead.Area_Manager_Comments__c) {
						leadAMComments.add(newLead);
						checkBranch.put(newLead.Branch__c, newLead.Id);
					}

					// Assume if BDM is current user, then add them as Business_Development_Manager__c.
                    if (newLead.Business_Development_Manager__c == null && !String.isBlank(userAcronym)) {
						newLead.Business_Development_Manager__c = UserInfo.getUserId();
					}

					if (newLead.isConverted) {
						checkBranch.put(newLead.Branch__c, newLead.Id);
					}
				}
			}
		} else {
			for (Lead l : newList) {
				if (l.RecordTypeId == idrtClientLead) {
					if (l.AM_Approval_Status__c == 'Approved') {
						leadAMApproval.add(l);
						checkBranch.put(l.Branch__c, l.Id);
					}

					if (l.Request_Area_Manager_Approval__c == true) {
						leadAMEmail.add(l.Id);
						accountId.put(l.Branch__c, l.Id);
					}
				}
			}
		}

		if (!checkBranch.isEmpty()) {
			getAdminBranch(checkBranch);
		}

		if (!leadAMEmail.isEmpty() && !accountId.isEmpty()) {
			AreaManagerEmail.areaManagerApprovalEmail(leadAMEmail, UserInfo.getName(), getBranchNames(), 'Lead');
		}

		leadValidate.put('AMApproval', leadAMApproval);
		leadValidate.put('AMComments', leadAMComments);

		return leadValidate;
	}

	/**
	 * getBranchNames retrieves all the Branch Names assocated with the leads
	 */
	private Set<String> getBranchNames() {
		Set<String> branchNames = new Set<String>();

		for (Account a : [SELECT Name FROM Account WHERE Id IN :accountId.keySet()]) {
			branchNames.add(a.Name);
		}

		return branchNames;
	}

	/**
	 * getAdminBranch retrieves the Lookup Map of the Admin for that Branch and the coresponding lead Id.
	 * It also builds the Branch Names to send to the AM Manager Email Notification.
	 *
	 *  Lead Check => <Lead.Id, Admin_Branch__c>
	 *  BranchNames => <Admin_Branch__c.Name>
	 */
	private void getAdminBranch(Map<Id, Id> checkBranch) {
		for (Admin_Branch__c a : [SELECT Id, Name, Admin_User__c, Lead_AM_Approval__c FROM Admin_Branch__c]) {
			branchAdminApproval.put(a.name, a);
		}

		for (Account branch : [SELECT Id, Name, Lead_AM_Approval__c FROM Account WHERE Id IN :checkBranch.keySet()]) {
			Boolean approvalNeeded = (branch.Lead_AM_Approval__c == null) ? false : branch.Lead_AM_Approval__c;

			if (branchAdminApproval.containsKey(branch.Name)) {
				branchAdminApproval.get(branch.Name).Lead_AM_Approval__c = approvalNeeded;
			} else {
				branchAdminApproval.put(
					branch.Name,
					new Admin_Branch__c(
						Name = branch.Name,
						Admin_User__c = null,
						Lead_AM_Approval__c = approvalNeeded
					)
				);
			}

			if (branchAdminApproval.containsKey(branch.Name)) {
				leadCheck.put(checkBranch.get(branch.Id), branchAdminApproval.get(branch.Name));
			}
		}
	}

	/**
	 *  checkValidation runs through all of the lead records and checks them against Admin Approvals and User
	 *  Titles. Nothing is returned, endpoint is an .addError Message to stop the DML action from taking place.  There
	 *  is a check in place for updated the Request AM Approval checkbox.  Cannot update the checkbox on insert, you
	 *  get a read-only error
	 */
	private void checkValidation(
		Map<String, Admin_Branch__c> branchAdminApproval,
		Map<String, List<Lead>> leadValidate
	) {
		if (Profile_Service.isSystemAdministrator(UserInfo.getProfileId())) {
			// Running user is a System Adminstrator
			return;
		}

		Boolean isAreaManager = User_Services.actsAsAreaManager(UserInfo.getUserId());

		for (Lead lead : leadValidate.get('AMApproval')) {
			if (!isAreaManager) {
				if (leadCheck.containsKey(lead.Id)) {
					if (leadCheck.get(lead.Id).Admin_User__c != UserInfo.getName()) {
						newCollection.get(lead.Id)
							.addError('You Must be a Area Manager or Delegated Admin to approve records.');
					} else if (isUpdate) {
						lead.Request_Area_Manager_Approval__c = false;
					}
				} else {
					newCollection.get(lead.Id)
						.addError('You Must be a Area Manager or Delegated Admin to approve records.');
				}
			} else if (isUpdate) {
				lead.Request_Area_Manager_Approval__c = false;
			}
		}

		for (Lead l : leadValidate.get('AMComments')) {
			if (!isAreaManager) {
				if (leadCheck.containskey(l.Id)) {
					if (leadCheck.get(l.Id).Admin_User__c != UserInfo.getName()) {
						newCollection.get(l.Id)
							.addError('You Must be the Approver or Delegated Aprover to edit Area Manager Comments.');
					}
				} else {
					newCollection.get(l.ID)
						.addError('You Must be the Approver or Delegated Aprover to edit Area Manager Comments.');
				}
			}
		}

		for (Id i : leadCheck.keySet()) {
			if (leadCheck.containsKey(i) && isUpdate && newCollection.get(i).isconverted) {
				if (leadCheck.get(i).Lead_AM_Approval__c && newCollection.get(i).AM_Approval_Status__c != 'Approved') {
					newCollection.get(i).addError('You must validate AM Approval before converting this lead.');
				}
			}
		}
	}

	private static void setCreationDate(List<Lead> leads) {
		for (Lead lead : leads) {
			if (Lead.Lead_Creation_Date__c == null) {
				Lead.Lead_Creation_Date__c = lead.CreatedDate;
			}
		}
	}
}