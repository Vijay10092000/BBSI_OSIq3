/**
 * @description ClientPricingScenario_TriggerHandler performs the trigger events
 * for the ClientPricingScenario__c object.
 */
public with sharing class ClientPricingScenario_TriggerHandler extends TriggerHandlerInvoker.TriggerHandler_Abstract {
    override public void afterUpdate(Map<Id, SObject> mapOld, Map<Id, SObject> mapNew) {
        Map<Id, ClientPricingScenario__c> oldValues = (Map<Id, ClientPricingScenario__c>) mapOld;
        Map<Id, ClientPricingScenario__c> newValues = (Map<Id, ClientPricingScenario__c>) mapNew;

        ClientPricingScenario_Services.RollupModifiedDates(newValues, oldValues);
    }
}