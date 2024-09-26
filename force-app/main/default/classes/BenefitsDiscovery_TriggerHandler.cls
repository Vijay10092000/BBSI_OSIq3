/**
 * @description BenefitsDiscovery_TriggerHandler handles Trigger events for the Benefits_Discovery_Questionnaire__c object.
 */
@SuppressWarnings('PMD.UnusedLocalVariable')
public without sharing class BenefitsDiscovery_TriggerHandler extends TriggerHandlerInvoker.TriggerHandler_Abstract {
	/**
	 * @description beforeInsert performs actions on the mapNew sObjects before the insert happens.
	 * NOTE: Before Insert records have no Id, so are not be able to use Map<>.
	 * @param listNew is the list of new sObjects
	 */
	override public void beforeInsert(List<SObject> listNew) {
		List<Benefits_Discovery_Questionnaire__c> newBdqs = (List<Benefits_Discovery_Questionnaire__c>) listNew;

		BenefitsDiscovery_Service.confirmOnlyOne(newBdqs);
		BenefitsDiscovery_Service.setBenefitsContact(newBdqs);
	}

	/**
	 * @description afterInsert performs actions on related objects to the mapNew sObjects after
	 * the insert.
	 * @param mapNew is the map of sObjects after being saved
	 */
	override public void afterInsert(Map<Id, SObject> mapNew) {
		List<Benefits_Discovery_Questionnaire__c> newBdqs = (List<Benefits_Discovery_Questionnaire__c>) mapNew.values();

		BenefitsDiscovery_Service.setContactBenefits(newBdqs);
	}

	/**
	 * @description afterUpdate performs actions on related objects to the mapNew sObjects after
	 * the update.
	 * @param mapOld is the map of sObjects before the new changes
	 * @param mapNew is the map of sObjects with the saved changes
	 */
	override public void afterUpdate(Map<Id, SObject> mapOld, Map<Id, SObject> mapNew) {
		Map<Id, Benefits_Discovery_Questionnaire__c> oldBdqs = (Map<Id, Benefits_Discovery_Questionnaire__c>) mapOld;
		List<Benefits_Discovery_Questionnaire__c> newBdqs = (List<Benefits_Discovery_Questionnaire__c>) mapNew.values();

		BenefitsDiscovery_Service.updateOpportunity(oldBdqs, newBdqs);
		BenefitsDiscovery_Service.setContactBenefits(newBdqs);
	}
}