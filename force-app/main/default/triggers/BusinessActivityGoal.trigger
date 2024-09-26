/**
 * BusinessActivityGoal is the trigger for the Business Activity Goal SObject.
 */
trigger BusinessActivityGoal on Business_Activity_Goal__c(
	before insert,
	after insert,
	before update,
	after update,
	before delete,
	after delete,
	after undelete
) {
	TriggerHandlerInvoker.execute(New BusinessActivityGoal_TriggerHandler()); // Updated For US-69176
}