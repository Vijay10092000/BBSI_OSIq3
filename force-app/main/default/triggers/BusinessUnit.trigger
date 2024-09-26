/**
 * BusinessUnit is the trigger for the Business_Unit__c SObject.
 */
trigger BusinessUnit on Business_Unit__c(
	before insert,
	after insert,
	before update,
	after update,
	before delete,
	after delete,
	after undelete
) {
	TriggerHandlerInvoker.execute(new BusinessUnit_TriggerHandler()); // Updated For US-69176
}