/**
 * EventC is the trigger for the Event__c SObject.
 */
trigger EventC on Event__c(
	before insert,
	after insert,
	before update,
	after update,
	before delete,
	after delete,
	after undelete
) {
	TriggerHandlerInvoker.execute(new EventC_TriggerHandler()); // Updated For US-69176
}