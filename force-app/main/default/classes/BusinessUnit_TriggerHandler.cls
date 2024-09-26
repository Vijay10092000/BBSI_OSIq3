/**
 * @description BusinessUnit_TriggerHandler controls trigger events for Business_Unit__c objects.
 */
public without sharing class BusinessUnit_TriggerHandler extends TriggerHandlerInvoker.TriggerHandler_Abstract {
	override public void beforeInsert(List<SObject> listNew) {
		List<Business_Unit__c> newBusinessUnits = (List<Business_Unit__c>) listNew;

        BusinessUnit_Service.insertChatterGroups(newBusinessUnits);
	}

	override public void afterInsert(Map<Id, SObject> mapNew) {
		Map<Id, Business_Unit__c> newBusinessUnits = (Map<Id, Business_Unit__c>) mapNew;

        BusinessUnit_Service.insertChatterGroupMembers(newBusinessUnits);
	}

    @SuppressWarnings('PMD.UnusedLocalVariable')
	override public void beforeUpdate(Map<Id, SObject> mapOld, Map<Id, SObject> mapNew) {
		Map<Id, Business_Unit__c> oldBusinessUnits = (Map<Id, Business_Unit__c>) mapOld;
		Map<Id, Business_Unit__c> newBusinessUnits = (Map<Id, Business_Unit__c>) mapNew;

        BusinessUnit_Service.insertChatterGroups(newBusinessUnits.values());
	}

	override public void afterUpdate(Map<Id, SObject> mapOld, Map<Id, SObject> mapNew) {
		Map<Id, Business_Unit__c> oldBusinessUnits = (Map<Id, Business_Unit__c>) mapOld;
		Map<Id, Business_Unit__c> newBusinessUnits = (Map<Id, Business_Unit__c>) mapNew;

        BusinessUnit_Service.insertChatterGroupMembers(newBusinessUnits);
        BusinessUnit_Service.updateChatterGroups(newBusinessUnits, oldBusinessUnits);
	}
}