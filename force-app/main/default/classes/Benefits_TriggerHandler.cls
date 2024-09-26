/**
 * @description Benefits_TriggerHandler handles Trigger events for the Benefits__c object.
 */
@SuppressWarnings('PMD.UnusedLocalVariable')
public without sharing class Benefits_TriggerHandler extends TriggerHandlerInvoker.TriggerHandler_Abstract {
	override public void beforeInsert(List<SObject> mapNew) {
		List<Benefits__c> newBenefits = (List<Benefits__c>) mapNew;

		Benefits_Service.onCreate(newBenefits);
		Benefits_Service.setBranch(null, newBenefits);
	}

	override public void afterInsert(Map<Id, SObject> mapNew) {
		Map<Id, Benefits__c> newBenefits = (Map<Id, Benefits__c>) mapNew;

		Benefits_Service.createInitialTasks(newBenefits.values());
		BenefitsAffiliatesBenefits.checkCommonOwnership(null,  newBenefits.values());
		BenefitsAffiliatesBenefits.updateRelatedRecords(newBenefits.values());
	}

	override public void beforeUpdate(Map<Id, SObject> mapOld, Map<Id, SObject> mapNew) {
		Map<Id, Benefits__c> oldBenefits = (Map<Id, Benefits__c>) mapOld;
		Map<Id, Benefits__c> newBenefits = (Map<Id, Benefits__c>) mapNew;

		Benefits_Service.setBranch(oldBenefits,  newBenefits.values());
	}

	override public void afterUpdate(Map<Id, SObject> mapOld, Map<Id, SObject> mapNew) {
		Map<Id, Benefits__c> oldBenefits = (Map<Id, Benefits__c>) mapOld;
		Map<Id, Benefits__c> newBenefits = (Map<Id, Benefits__c>) mapNew;

		BenefitsAffiliatesBenefits.checkCommonOwnership(oldBenefits,  newBenefits.values());
		BenefitsAffiliatesBenefits.updateRelatedRecords(newBenefits.values());
	}
}