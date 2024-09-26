/**
 * @description OpportunityValidation
 */
public without sharing class OpportunityValidation {
	private List<Opportunity> newCollection;
	private Map<Id, Opportunity> oldCollection;

	private Map<Id, string> branchLookup = new Map<Id, string>();
	private Set<String> nameBranches = new Set<String>();

	/**
	 * @description afterUpdate
	 * @param  mapOld   Opportunities before changes
	 * @param  listNew  Opportunities with changes
	 */
	public OpportunityValidation(Map<Id, Opportunity> mapOld, List<Opportunity> listNew) {
		oldCollection = mapOld;
		newCollection = listNew;
	}

	/**
	 * @description afterUpdate handles Trigger event AFTER UPDATE.
	 */
	public void beforeUpdate() {
		Map<String, List<Opportunity>> oppValidate = checkUpdates();

		if (
			oppValidate.get('Credit').size() > 0 ||
			oppValidate.get('OkRisk').size() > 0 ||
			oppValidate.get('AMApproval').size() > 0 ||
			oppValidate.get('CreditComments').size() > 0 ||
			oppValidate.get('OkRiskComments').size() > 0 ||
			oppValidate.get('AMApprovalComments').size() > 0
		) {
			checkValidation(getOkRiskApproval(), getCreditApproval(), getBranchAdmin(), oppValidate);
		}
	}

	/** @desciption checkUpdates
		Method that cycles through all possible validations and makes sure the right person modifies the
		right field.  Validates Approvals and Comments for Approvals.  It sends an email for notifing
		users of certain approvals.  Also requires a user to enter nerin a Referral Partner if they choose
		"Closed Lost" for the status and the reason "Unable to Schedule a Meeting".
		1. Validations
			a. Credit
			b. Ok for Risk
			c. Area Manager
		2. Nofications
			a. Risk
			b. Area Manager
	*/
	private Map<String, List<Opportunity>> checkUpdates() {
		List<Opportunity> oppCredit = new List<Opportunity>();
		List<Opportunity> oppCreditComments = new List<Opportunity>();

		List<Opportunity> oppRisk = new List<Opportunity>();
		List<Opportunity> oppRiskComments = new List<Opportunity>();

		List<Opportunity> oppAMApproval = new List<Opportunity>();
		List<Opportunity> oppAMApprovalComments = new List<Opportunity>();

		Set<Id> oppRiskEmail = new Set<Id>();
		Set<Id> areaManagerEmailSet = new Set<Id>();
		Set<Id> acctId = new Set<Id>();

		Map<String, List<Opportunity>> oppValidate = new Map<String, List<Opportunity>>();

		for (Opportunity o : newCollection) {
			if (o.Credit_Approval_Status__c != oldCollection.get(o.Id).Credit_Approval_Status__c) {
				oppCredit.add(o);
			}
			if (o.Credit_Comments__c != oldCollection.get(o.Id).Credit_Comments__c) {
				oppCreditComments.add(o);
			}

			if (o.OK_For_Risk_Approval_Status__c != oldCollection.get(o.Id).OK_For_Risk_Approval_Status__c) {
				oppRisk.add(o);
			}
			if (
				o.Request_OK_For_Risk_Approval_Comment__c !=
				oldCollection.get(o.Id).Request_OK_For_Risk_Approval_Comment__c
			) {
				oppRiskComments.add(o);
			}

			if (o.AM_Approval_Status__c != oldCollection.get(o.Id).AM_Approval_Status__c) {
				oppAMApproval.add(o);
				acctId.add(o.AccountId);
			}
			if (o.AM_Approval_Comments__c != oldCollection.get(o.Id).AM_Approval_Comments__c) {
				oppAMApprovalComments.add(o);
				acctId.add(o.AccountId);
			}

			if (
				o.Request_OK_For_Risk_Approval__c != oldCollection.get(o.Id).Request_OK_For_Risk_Approval__c &&
				o.Request_OK_For_Risk_Approval__c == true
			) {
				oppRiskEmail.add(o.Id);
			}
			if (
				o.Request_Area_Manager_Approval__c != oldCollection.get(o.Id).Request_Area_Manager_Approval__c &&
				o.Request_Area_Manager_Approval__c == true
			) {
				areaManagerEmailSet.add(o.accountID);
				acctId.add(o.AccountId);
			}

			if (o.Closed_Reason__c == 'Unable to Schedule a Meeting' && o.StageName == 'Closed Lost') {
				if (checkReferralParterner(o)) {
					o.addError(
						'Must have a Referral Source when choosing to unqualify by unable to schedule a meeting'
					);
				}
			}
		}

		if (acctId.size() > 0) {
			getBranch(acctId);
		}

		if (areaManagerEmailSet != null && areaManagerEmailSet.size() > 0) {
			AreaManagerEmail.areaManagerApprovalEmail(acctId, UserInfo.getName(), nameBranches, 'Prospect');
		}

		if (oppRiskEmail != null && oppRiskEmail.size() > 0) {
			OkForRiskEmail.riskEmail(oppRiskEmail); // Updated For US-33150
		}

		oppValidate.put('Credit', oppCredit);
		oppValidate.put('CreditComments', oppCreditComments);

		oppValidate.put('OkRisk', oppRisk);
		oppValidate.put('OkRiskComments', oppRiskComments);

		oppValidate.put('AMApproval', oppAMApproval);
		oppValidate.put('AMApprovalComments', oppAMApprovalComments);

		return oppValidate;
	}

	/**
	 * @desciption Method that get the related branch for the opportunities that got modified.  Parameters are
	 *	the accountIDs of the Opportunities.
	 * @param acctId  Set of Account Identifiers
	 */
	private void getBranch(Set<Id> acctId) {
		Map<Id, String> acctLookup = new Map<Id, String>();

		for (Account a : [SELECT Id, Prospect_Branch__c FROM Account WHERE Id IN :acctId]) {
			BranchLookup.put(a.Prospect_Branch__c, a.Id);
		}

		for (Account a : [SELECT Name FROM Account WHERE Id = :BranchLookup.keySet()]) {
			acctLookup.put(BranchLookup.get(a.Id), a.Name.toLowerCase());
			nameBranches.add(a.Name);
		}

		for (Opportunity o : [SELECT Id, accountID FROM Opportunity WHERE accountID IN :acctLookup.keySet()]) {
			BranchLookup.put(o.Id, acctLookup.get(o.accountID));
		}
	}

	/**
	 * @desciption Method that gets all the Ok for Risk Approvers that are stored in the Custom Settings.
	 * @return Set of Strings with risk access names
	 */
	private Set<String> getOkRiskApproval() {
		list<Ok_For_Risk_Access__c> okRisk = Ok_For_Risk_Access__c.getall().values();

		set<String> okRiskApproval = new Set<String>();

		for (Ok_For_Risk_Access__c r : okRisk) {
			okRiskApproval.add(r.name);
		}

		return okRiskApproval;
	}

	/**
	 * @desciption Method that gets all the Credit Approvers that are stored in the Custom Settings.
	 * @return Set of Strings with credit approval names
	 */
	private Set<String> getCreditApproval() {
		List<Credit_Approval__c> credit = Credit_Approval__c.getall().values();

		set<String> creditApproval = new Set<String>();

		for (Credit_Approval__c c : credit) {
			creditApproval.add(c.name);
		}

		return creditApproval;
	}

	/**
	 * @desciption Method that gets all the Admin Approvers that are stored in the Custom Settings.
	 * @return A Map
	 */
	private Map<String, String> getBranchAdmin() {
		Map<String, String> branchAdmin = new Map<String, String>();

		list<Admin_Branch__c> adminBranch = Admin_Branch__c.getall().values();

		for (Admin_Branch__c a : adminBranch) {
			branchAdmin.put(a.name.toLowerCase(), a.Admin_User__c);
		}

		return branchAdmin;
	}

	/**
	 * @desciption Method that checks if the Opportuntiy has a Referral Patner associated with the Opportuntity
	 * @return true if has Referral Partner
	 */
	private boolean checkReferralParterner(Opportunity o) {
		if ([SELECT Id FROM Referral_Partner__c WHERE Account__c = :o.AccountID].size() > 0) {
			return false;
		} else {
			return true;
		}
	}

	/**
	 * @desciption Method to cycle through all the changes that were made and verify that the changes were valid
	 *	ones.  If changes were not valid, block the change and throw a custom error message that relates
	 *	to the update violation.  It ignores a system admin change who can modify any field at any time.
	 *	Parameters:
	 *		1. OkRisk - set of valid names of users who can approve Ok for Risk
	 *		2. Credit - set of valid names of users who can approve Credit
	 *		3. BranchAdmin -  Map of Branch Names as the key and the User as the value for
	 *			users who can approve Area Manager Approval
	 *		4. oppValidate - Master collection of Opportunities that need to be validated against.  Each
	 *			key is a list of Opportunities that need to be validated against.
	 */
	private void checkValidation(
		Set<String> okRisk,
		Set<String> credit,
		Map<String, String> branchAdmin,
		Map<String, List<Opportunity>> oppValidate
	) {
		String nameUser = UserInfo.getName();

		if (!Profile_Service.mayConfigure(UserInfo.getProfileId())) {
			// Running user is not a System Adminstrator or Configuration Admin

			//Add key of +Comments ie. CreditComments and then check if the logged user is in the Approved list
			for (Opportunity o : oppValidate.get('Credit')) {
				if (!credit.contains(nameUser)) {
					o.addError('You must be the Approver or Delegated Approver for Credit Approval');
				} else {
					o.Request_Credit_Approval__c = false;
				}
			}
			for (Opportunity o : oppValidate.get('CreditComments')) {
				if (!credit.contains(nameUser)) {
					o.addError('You must be the Approver or Delegated Approver to edit Credit Comments');
				}
			}

			for (Opportunity o : oppValidate.get('OkRisk')) {
				if (!okRisk.contains(nameUser)) {
					o.addError('You must be the Approver or Delegated Approver for Underwriting Approval');
				} else {
					o.Request_OK_For_Risk_Approval__c = false;
				}
			}
			for (Opportunity o : oppValidate.get('OkRiskComments')) {
				if (!okRisk.contains(nameUser)) {
					o.addError('You must be the Approver or Delegated Approver to edit Underwriting Comments');
				}
			}

			Boolean isAreaManager = User_Services.actsAsAreaManager(UserInfo.getUserId());

			for (Opportunity o : oppValidate.get('AMApproval')) {
				if (!isAreaManager && branchAdmin.get(BranchLookup.get(o.Id)) != nameUser) {
					o.addError('You must be an Area Manager or Delegated Admin to approve records.');
				} else {
					o.Request_Area_Manager_Approval__c = false;
				}
			}

			for (Opportunity o : oppValidate.get('AMApprovalComments')) {
				if (!isAreaManager && branchAdmin.get(BranchLookup.get(o.Id)) != nameUser) {
					o.addError('You must be the Approver or Delegated Approver to edit Area Manager Comments');
				}
			}
		}
	}
}