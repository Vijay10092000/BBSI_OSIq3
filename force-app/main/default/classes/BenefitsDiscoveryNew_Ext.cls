/**
 * @description BenefitsDiscoveryNew_Ext
 */
public without sharing class BenefitsDiscoveryNew_Ext {
	Opportunity opportunity;

	/**
	 * @description BenefitsDiscoveryNew_Ext constructor.
	 * @param  controller  Standard Controller
	 */
	public BenefitsDiscoveryNew_Ext(ApexPages.StandardController controller) {
		Id idOpportunity = (Id) controller.getRecord().Id;

		opportunity = [SELECT Id, Name, AccountId FROM Opportunity WHERE Id = :idOpportunity];
	}

	/**
	 * @description redirect determines where it needs to go.
	 * @return Pagereference
	 */
	public PageReference redirect() {
		Benefits_Discovery_Questionnaire__c bdq;

		bdq = getQuestionnaire();

		if (bdq == null) {
			try {
				bdq = createQuestionnaire();

				insert bdq;
			} catch (Exception e) {
				Log.error('Opportunity', 'Failed to create Benefits_Discovery_Questionnaire__c', null, e);
				return backToOpportunity();
			}
		}

		return new PageReference('/' + bdq.Id);
	}

	/**
	 * @description backToOpportunity return to the Opportunity
	 * @return   return description
	 */
	public PageReference backToOpportunity() {
		return new Pagereference('/' + opportunity.Id);
	}

	/**
	 * @description getQuestionnaire get the Opportunity's questionnaire if it has one
	 * @return Questionnaire Id or null if not found
	 */
	private Benefits_Discovery_Questionnaire__c getQuestionnaire() {
		List<Benefits_Discovery_Questionnaire__c> bdqs = [
			SELECT Id, Name
			FROM Benefits_Discovery_Questionnaire__c
			WHERE OpportunityId__c = :opportunity.Id
		];

		if (!bdqs.isEmpty()) {
			return bdqs.get(0);
		}

		return null;
	}

	/**
	 * @description createQuestionnaire create a new Benefits_Discovery_Questionnaire__c with
	 * default values.
	 * @return Benefits_Discovery_Questionnaire__c
	 */
	private Benefits_Discovery_Questionnaire__c createQuestionnaire() {
		Id idContact = null;

		// Get some of the Opportunity's Client Account data
		Account client = [
			SELECT Id, Name, Active_Employees_Full_Time__c, Active_Employees_Part_Time__c
			FROM Account
			WHERE Id = :opportunity.AccountId
		];

		// Find the Opportunity's BENEFITS CONTACT
		Map<Id, List<OpportunityContactRole>> mapRoles = OpportunityContactRole_Service.getOpportunityContactsByRole(
			new List<Id>{ opportunity.Id },
			new List<String>{ OpportunityContactRole_Service.BENEFITS_CONTACT }
		);

		if (mapRoles.containsKey(opportunity.Id)) {
			List<OpportunityContactRole> roles = mapRoles.get(opportunity.Id);

			if (!roles.isEmpty()) {
				idContact = roles.get(0).ContactId;
			}
		}

		return new Benefits_Discovery_Questionnaire__c(
			Name = opportunity.Name,
			OpportunityId__c = opportunity.Id,
			Benefits_Contact__c = idContact,
			Active_Employees_Full_Time__c = client.Active_Employees_Full_Time__c,
			Active_Employees_Part_Time__c = client.Active_Employees_Part_Time__c,
			BBSI_Team_Member_Completing_This_Form__c = UserInfo.getUserId(),
			Employees_Enrolled_in_Medical__c = 0
		);
	}
}