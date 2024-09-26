/**
 * @description BusinessUnitMember_TriggerHandler controls trigger events
 * for Business_Unit_Contact__c objects.
 */
public without sharing class BusinessUnitMember_TriggerHandler extends TriggerHandlerInvoker.TriggerHandler_Abstract {

    override public void beforeInsert(List<SObject> listNew) { 
        List<Business_Unit_Contact__c> newValues = (List<Business_Unit_Contact__c>) listNew;

        BusinessUnitMember_Service.reviewChatterGroupMembers(newValues);
    }
    
    override public void afterInsert(Map<Id, SObject> mapNew) {
        Map<Id, Business_Unit_Contact__c> newValues = (Map<Id, Business_Unit_Contact__c>) mapNew;

        BusinessUnitMember_Service.updateBUMContacts(newValues, null);
    }
    
    @SuppressWarnings('PMD.UnusedLocalVariable')
    override public void beforeUpdate(Map<Id, SObject> mapOld, Map<Id, SObject> mapNew) { 
        Map<Id, Business_Unit_Contact__c> oldValues = (Map<Id, Business_Unit_Contact__c>) mapOld;
        Map<Id, Business_Unit_Contact__c> newValues = (Map<Id, Business_Unit_Contact__c>) mapNew;

        BusinessUnitMember_Service.reviewChatterGroupMembers(newValues.values());
    }
    
    override public void afterUpdate(Map<Id, SObject> mapOld, Map<Id, SObject> mapNew) {
        Map<Id, Business_Unit_Contact__c> oldValues = (Map<Id, Business_Unit_Contact__c>) mapOld;
        Map<Id, Business_Unit_Contact__c> newValues = (Map<Id, Business_Unit_Contact__c>) mapNew;

        BusinessUnitMember_Service.updateBUMContacts(newValues, oldValues);
    }
    
    override public void beforeDelete(Map<Id, SObject> mapOld) { 
        Map<Id, Business_Unit_Contact__c> oldValues = (Map<Id, Business_Unit_Contact__c>) mapOld;

        BusinessUnitMember_Service.removeChatterGroupMembers(oldValues.values());
    }
}