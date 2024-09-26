/**
 * Event is the trigger for the Event SObject.
 */
trigger Event on Event(
	before insert,
	after insert,
	before update,
	after update,
	before delete,
	after delete,
	after undelete
) {
	TriggerHandlerInvoker.execute(new Event_TriggerHandler());
}