/**
 * @description BenefitsDiscovery_Service contains methods for the Benefits_Discovery_Questionnaire__c object.
 */
public without sharing class BenefitsDiscovery_Service {
	private static final String FORMAT_QUERY_OPP = 'SELECT Id, Name, Employees_Currently_Enrolled_in_Medical__c, {0} FROM Opportunity WHERE Id IN ({1})';

	// DBQ_FIELDS contains the fields which will be checked for change on the questionnaire and updated on the Opportunity.
	private static final List<String> DBQ_FIELDS = new List<String>{
		'Active_Employees_Full_Time__c',
		'Active_Employees_Part_Time__c',
		'Affiliated_Companies__c',
		'Budget_For_Renewal_Increase__c',
		'Company_Pay_Portion_Benefits__c',
		'Company_Plan_Contributions__c',
		'Do_you_have_any_COBRA_participants__c',
		'Have_Benefits__c',
		'Have_Common_Ownership__c',
		'Insurance_Medical_Renewal__c',
		'Medical_Carrier__c',
		'Plan_Types__c',
		'Plan_Types_Other__c'
	};

	/**
	 * @description confirmOnlyOne confirms only one questionnaire per Opportunity.
	 * @param listNew  List of Benefits_Discovery_Questionnaire__c with the new changes
	 */
	public static void confirmOnlyOne(List<Benefits_Discovery_Questionnaire__c> listNew) {
		Map<Id, Benefits_Discovery_Questionnaire__c> mapOpportunityToBdq = new Map<Id, Benefits_Discovery_Questionnaire__c>();

		for (Benefits_Discovery_Questionnaire__c bdq : listNew) {
			mapOpportunityToBdq.put(bdq.OpportunityId__c, bdq);
		}

		List<Benefits_Discovery_Questionnaire__c> currentBdqs = [
			SELECT Id, OpportunityId__c
			FROM Benefits_Discovery_Questionnaire__c
			WHERE OpportunityId__c IN :mapOpportunityToBdq.keySet()
		];

		for (Benefits_Discovery_Questionnaire__c currentBdq : currentBdqs) {
			Benefits_Discovery_Questionnaire__c bdq = mapOpportunityToBdq.get(currentBdq.OpportunityId__c);
			bdq.addError('Questionnaire already exists for the Opportunity');
		}
	}

	/**
	 * @description setBenefitsContact finds and sets the Benefits Contact from the Opportunity.
	 * @param listNew  List of Benefits_Discovery_Questionnaire__c with the new changes
	 */
	public static void setBenefitsContact(List<Benefits_Discovery_Questionnaire__c> listNew) {
		List<Id> idOpps = new List<Id>();

		for (Benefits_Discovery_Questionnaire__c bdq : listNew) {
			idOpps.add(bdq.OpportunityId__c);
		}

		Map<Id, List<OpportunityContactRole>> mapOcrs = OpportunityContactRole_service.getOpportunityContactsByRole(
			idOpps,
			new List<String>{ OpportunityContactRole_Service.BENEFITS_CONTACT }
		);

		for (Benefits_Discovery_Questionnaire__c bdq : listNew) {
			if (mapOcrs.containsKey(bdq.OpportunityId__c)) {
				List<OpportunityContactRole> ocrs = mapOcrs.get(bdq.OpportunityId__c);

				if (!ocrs.isEmpty()) {
					bdq.Benefits_Contact__c = ocrs.get(0).ContactId;
				}
			}
		}
	}

	/**
	 * @description setContactBenefits finds and sets the Benefits Contact from the Opportunity.
	 * @param listNew  List of Benefits_Discovery_Questionnaire__c with the new changes
	 */
	public static void setContactBenefits(List<Benefits_Discovery_Questionnaire__c> listNew) {
		List<Id> idContacts = new List<Id>();

		for (Benefits_Discovery_Questionnaire__c bdq : listNew) {
			if ( bdq.Benefits_Contact__c != null) {
				idContacts.add(bdq.Benefits_Contact__c);
			}
		}

		if (!idContacts.isEmpty()) {
			List<Contact> contacts = [
				SELECT Id, Name, Benefits_Contact__c
				FROM Contact
				WHERE Benefits_Contact__c = FALSE
				AND Id IN :idContacts
			];

			if (!contacts.isEmpty()) {
				for (Contact contact : contacts) {
					contact.Benefits_Contact__c = true;
				}

				update contacts;
			}
		}
	}

	/**
	 * @description updateOpportunity updates the related Opportunity if needed.
	 * @param mapOld   Map of Benefits_Discovery_Questionnaire__c before the changes
	 * @param listNew  List of Benefits_Discovery_Questionnaire__c with the saved changes
	 */
	public static void updateOpportunity(
		Map<Id, Benefits_Discovery_Questionnaire__c> mapOld,
		List<Benefits_Discovery_Questionnaire__c> listNew
	) {
		Set<Id> idOpps = new Set<Id>();

		for (Benefits_Discovery_Questionnaire__c bdq : listNew) {
			if (mapOld == null || changedBenefitsQuestionnaireFields(mapOld.get(bdq.Id), bdq)) {
				idOpps.add(bdq.OpportunityId__c);
			}
		}

		if (!idOpps.isEmpty()) {
			String ids = '';
			for (Id id : idOpps) {
				if (!String.isEmpty(ids)) {
					ids += ', ';
				}

				ids += '\''+ String.valueOf(id) + '\'';
			}

			String fields = String.join(DBQ_FIELDS, ', ');

			String query = String.format(FORMAT_QUERY_OPP, new List<String>{ fields, ids });

			List<Opportunity> opps = Database.query(query);

			Map<Id, Opportunity> mapOpps = new Map<Id, Opportunity>(opps);

			for (Benefits_Discovery_Questionnaire__c bdq : listNew) {
				if (mapOpps.containsKey(bdq.OpportunityId__c)) {
					Opportunity opp = mapOpps.get(bdq.OpportunityId__c);

					opp.QuestionnaireId__c = bdq.Id;
					opp.Employees_Currently_Enrolled_in_Medical__c = bdq.Employees_Enrolled_in_Medical__c;

					for (String field : DBQ_FIELDS) {
						opp.put(field, bdq.get(field));
					}
				}
			}

			update mapOpps.values();
		}
	}

	/**
	 * @description changedBenefitsQuestionnaireFields checks if a change has been
	 * made to the Benefits Questionnaire's files
	 * @param oldBdq  Previous Benefits_Discovery_Questionnaire__c
	 * @param newBdq  Updated Benefits_Discovery_Questionnaire__c
	 * @return true if change has been made
	 */
	private static Boolean changedBenefitsQuestionnaireFields(
		Benefits_Discovery_Questionnaire__c oldBdq,
		Benefits_Discovery_Questionnaire__c newBdq
	) {
		for (String field : DBQ_FIELDS) {
			if (oldBdq.get(field) != newBdq.get(field)) {
				return true;
			}
		}

		if (oldBdq.Employees_Enrolled_in_Medical__c != newBdq.Employees_Enrolled_in_Medical__c) {
			return true;
		}

		return false;
	}
}