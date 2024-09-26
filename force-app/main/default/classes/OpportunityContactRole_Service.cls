/**
 * @description OpportunityContactRole_Service contains routines to handle OpportunityContactRoles.
 *
 * TEST QUERY:
 *
SELECT Id, OpportunityId, ContactId, Contact.Email, IsPrimary, Role, Opportunity.Name
FROM OpportunityContactRole
WHERE Role IN ('Benefits Contact')
ORDER BY IsPrimary DESC, Role ASC, LastModifiedDate DESC
 */
public without sharing class OpportunityContactRole_Service {
	public static final String BENEFITS_CONTACT = 'Benefits Contact';
	public static final String DECISION_MAKER = 'Decision Maker';
	public static final String EXECUTIVE_SPONSOR = 'Executive Sponsor';

	/**
	 * @description updateQuestionnaires update the Benefits Discovery Questionnaires
	 * if changed.
	 * @param  mapOld  Objects before change
	 * @param  mapNew  Objects with change
	 */
	public static void updateQuestionnaires(
		Map<Id, OpportunityContactRole> mapOld,
		Map<Id, OpportunityContactRole> mapNew
	) {
		Map<Id, OpportunityContactRole> roleBenefits = getRoles(mapNew.values(), BENEFITS_CONTACT);

		if (!roleBenefits.isEmpty()) {
			Set<Id> idOpps = new Set<Id>();

			for (OpportunityContactRole ocr : roleBenefits.values()) {
				if (mapOld == null || mapOld.get(ocr.Id).Role != ocr.Role) {
					idOpps.add(ocr.OpportunityId);
				}
			}

			if (!idOpps.isEmpty()) {
				Map<Id, Benefits_Discovery_Questionnaire__c> mapOpToBdqs = new Map<Id, Benefits_Discovery_Questionnaire__c>();

				for (Benefits_Discovery_Questionnaire__c bdq : [
					SELECT Id, Name, Benefits_Contact__c, OpportunityId__c
					FROM Benefits_Discovery_Questionnaire__c
					WHERE OpportunityId__c IN :idOpps
				]) {
					mapOpToBdqs.put(bdq.OpportunityId__c, bdq);
				}

				List<Benefits_Discovery_Questionnaire__c> changedBdqs = new List<Benefits_Discovery_Questionnaire__c>();
				for (OpportunityContactRole ocr : roleBenefits.values()) {
					if (mapOpToBdqs.containsKey(ocr.OpportunityId)) {
						Benefits_Discovery_Questionnaire__c bdq = mapOpToBdqs.get(ocr.OpportunityId);

						bdq.Benefits_Contact__c = ocr.ContactId;

						if (!changedBdqs.contains(bdq)) {
							changedBdqs.add(bdq);
						}
					}
				}

				update changedBdqs;
			}
		}
	}

	/**
	 * @description updateQuestionnaires update the Benefits Discovery Questionnaires
	 * if changed.
	 * @param  mapOld   Objects before change
	 * @param  listNew  Objects with change
	 */
	public static void updateContacts(
		Map<Id, OpportunityContactRole> mapOld,
		List<OpportunityContactRole> listNew
	) {
		Set<Id> idBenefitsContacts = new Set<Id>();

		for (OpportunityContactRole ocr : listNew) {
			if (ocr.Role == BENEFITS_CONTACT) {
				idBenefitsContacts.add(ocr.ContactId);
			}
		}

		if (idBenefitsContacts != null) {
			List<Contact> contacts = [SELECT Id, Name, Benefits_Contact__c FROM Contact WHERE Id IN :idBenefitsContacts];

			for (Contact c : contacts) {
				c.Benefits_Contact__c = true;
			}

			update contacts;
		}
	}

	/**
	 * @description getOpportunityPrimaryContacts retrieves all the Contacts with roles
	 * for the given Opportunities.
	 * @param idOpportunities  List of Opportunities
	 * @param roles            List of roles looking at
	 * @return Map relating the Opportunity's with Roles
	 */
	public static Map<Id, List<OpportunityContactRole>> getOpportunityContactsByRole(
		List<Id> idOpportunities,
		List<String> roles
	) {
		Map<Id, List<OpportunityContactRole>> result = new Map<Id, List<OpportunityContactRole>>();

		for (OpportunityContactRole ocr : [
			SELECT Id, ContactId, OpportunityId, IsPrimary, Role
			FROM OpportunityContactRole
			WHERE OpportunityId IN :idOpportunities AND Role IN :roles
			AND IsDeleted = FALSE
			ORDER BY IsPrimary DESC, Role ASC, LastModifiedDate DESC
		]) {
			if (!result.keySet().contains(ocr.OpportunityId)) {
				result.put(ocr.OpportunityId, new List<OpportunityContactRole>());
			}

			result.get(ocr.OpportunityId).add(ocr);
		}

		return result;
	}

	/**
	 * @description getRoles retrieve a Map containing all the OpportunityContactRoles with
	 * the given role name.
	 * @param  roles     Map of OpportunityContactRole to search
	 * @param  nameRole  Role name to find
	 * @return Map<Id, OpportunityContactRole>
	 */
	public static Map<Id, OpportunityContactRole> getRoles(List<OpportunityContactRole> roles, String nameRole) {
		Map<Id, OpportunityContactRole> result = new Map<Id, OpportunityContactRole>();

		for (OpportunityContactRole ocr : roles) {
			if (ocr.Role == nameRole) {
				result.put(ocr.Id, ocr);
			}
		}

		return result;
	}

	/**
	 * @description readContactRoles gets the Opportunities Contact Roles related
	 * to the Opporunties.
	 * @param idOpps  Opportunity identifiers
	 * @return Map<Id, List<OpportunityContactRole>>
	 */
	public static Map<Id, List<OpportunityContactRole>> readContactRoles(Set<Id> idOpps) {
		Map<Id, List<OpportunityContactRole>> result = new Map<Id, List<OpportunityContactRole>>();

		for (Id idOpp : idOpps) {
			result.put(idOpp, new List<OpportunityContactRole>());
		}

		List<OpportunityContactRole> roles = [
			SELECT Id, ContactId, OpportunityId, IsPrimary, Role
			FROM OpportunityContactRole
			WHERE OpportunityId IN :idOpps
			AND IsDeleted = FALSE
			ORDER BY OpportunityId ASC
		];

		for (OpportunityContactRole role : roles) {
			result.get(role.OpportunityId).add(role);
		}

		return result;
	}
}