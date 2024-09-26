/**
 * Interview is the trigger for the Interview__c SObject.
 */
trigger Interview on Interview__c(
	before insert,
	after insert,
	before update,
	after update,
	before delete,
	after delete,
	after undelete
) {
	TriggerHandlerInvoker.execute(new Interview_TriggerHandler()); // Updated For US-69176
}