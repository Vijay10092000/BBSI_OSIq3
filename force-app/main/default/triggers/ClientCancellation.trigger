/**
 * ClientCancellation is the trigger for the ClientCancellation__c object.
 */
trigger ClientCancellation on Client_Cancellation__c(
	before insert,
	after insert,
	before update,
	after update,
	before delete,
	after delete,
	after undelete
) {
	TriggerHandlerInvoker.execute(new ClientCancellation_TriggerHandler()); // Updated For US-69176
}