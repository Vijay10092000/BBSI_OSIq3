/**
 * @description BenefitsAffiliates_TriggerHandler handles Trigger events for the Benefits_Affiliates__c object.
 */
@SuppressWarnings('PMD.UnusedLocalVariable')
public without sharing class BenefitsAffiliates_TriggerHandler extends TriggerHandlerInvoker.TriggerHandler_Abstract {
	/**
	 * @description beforeInsert performs actions on the mapNew sObjects before the insert happens.
	 * NOTE: Before Insert records have no Id, so are not be able to use Map<>.
	 * @param listNew is the list of new sObjects
	 */
	override public void beforeInsert(List<SObject> listNew) {
		List<Benefits_Affiliates__c> newAffiliates = (List<Benefits_Affiliates__c>) listNew;

		BenefitsAffiliates.confirmInitialData(newAffiliates);
		BenefitsAffiliates.updateFromBenefits(null, newAffiliates);
	}

	/**
	 * @description afterInsert performs actions on related objects to the mapNew sObjects after
	 * the insert.
	 * @param mapNew is the map of sObjects after being saved
	 */
	override public void afterInsert(Map<Id, SObject> mapNew) {
		Map<Id, Benefits_Affiliates__c> newAffiliates = (Map<Id, Benefits_Affiliates__c>) mapNew;

		BenefitsAffiliates.updatePrimaryRecords(newAffiliates);
	}

	/**
	 * @description beforeUpdate performs actions on the mapNew sObjects before the update happens.
	 * @param mapOld is the map of sObjects before the new changes
	 * @param mapNew is the map of sObjects with the changes
	 */
	override public void beforeUpdate(Map<Id, SObject> mapOld, Map<Id, SObject> mapNew) {
		Map<Id, Benefits_Affiliates__c> oldAffiliates = (Map<Id, Benefits_Affiliates__c>) mapOld;
		Map<Id, Benefits_Affiliates__c> newAffiliates = (Map<Id, Benefits_Affiliates__c>) mapNew;

		BenefitsAffiliates.updateFromBenefits(oldAffiliates, newAffiliates.values());
		BenefitsAffiliates.confirmPrimaryAccount(oldAffiliates, newAffiliates);
		System.debug('BenefitsAffiliates_TriggerHandler :: beforeUpdate :: newAffiliates ::' + newAffiliates);
		BenefitsAffiliates.setCounts(newAffiliates);
	}

	/**
	 * @description afterUp
	 *
	 date performs actions on the mapNew sObjects after the update happens.
	 * @param mapOld is the map of sObjects before the new changes
	 * @param mapNew is the map of sObjects with the changes
	 */
	override public void afterUpdate(Map<Id, SObject> mapOld, Map<Id, SObject> mapNew) {
		Map<Id, Benefits_Affiliates__c> oldAffiliates = (Map<Id, Benefits_Affiliates__c>) mapOld;
		Map<Id, Benefits_Affiliates__c> newAffiliates = (Map<Id, Benefits_Affiliates__c>) mapNew;

		BenefitsAffiliates.updateRelatedRecords(newAffiliates);
	}

	/**
	 * @description beforeDelete performs actions on the mapOld sObjects before the delete happens.
	 * @param mapOld is the map of sObjects before deletion
	 */
	override public void beforeDelete(Map<Id, SObject> mapOld) {
		Map<Id, Benefits_Affiliates__c> oldAffiliates = (Map<Id, Benefits_Affiliates__c>) mapOld;

		BenefitsAffiliates.checkDeletionAllowed(oldAffiliates);
		BenefitsAffiliates.clearRelatedRecords(oldAffiliates);
	}
}