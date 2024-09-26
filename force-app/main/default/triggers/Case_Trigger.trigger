/**
 * Case_Trigger is the trigger for the Case SObject.
 */
trigger Case_Trigger on Case(
	before insert,
	after insert,
	before update,
	after update,
	before delete,
	after delete,
	after undelete
) {
	TriggerHandlerInvoker.execute(new Case_TriggerHandler()); // Updated For US-69176
}