/**
 * Lead is the trigger for the Lead SObject.
 */
trigger Lead on Lead(
	before insert,
	after insert,
	before update,
	after update,
	before delete,
	after delete,
	after undelete
) {
	TriggerHandlerInvoker.execute(new Lead_TriggerHandler());
	TriggerHandlerInvoker.execute(new Lead_Dlrs_TriggerHandler());
}