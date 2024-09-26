/**
 * EventRegistration_Trigger is the trigger for the Event_Registration__c SObject.
 */
trigger EventRegistration_Trigger on Event_Registration__c(
	before insert,
	after insert,
	before update,
	after update,
	before delete,
	after delete,
	after undelete
) {
	TriggerHandlerInvoker.execute(new EventRegistration_TriggerHandler()); // Updated For US-69176
}