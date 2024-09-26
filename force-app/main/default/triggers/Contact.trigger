/**
 * Contact is the trigger for the Contact SObject.
 */
trigger Contact on Contact(
	before insert,
	after insert,
	before update,
	after update,
	before delete,
	after delete,
	after undelete
) {
	TriggerHandlerInvoker.execute(new Contact_TriggerHandler()); // Updated For US-69176
}