/**
 * BusinessUnitMember is the trigger for the Business_Unit_Contact__c SObject.
 */
trigger BusinessUnitMember on Business_Unit_Contact__c  (
    before insert, after insert, 
    before update, after update, 
    before delete, after delete,
    after undelete) {
    TriggerHandlerInvoker.execute(new BusinessUnitMember_TriggerHandler()); // Updated For US-69176
}