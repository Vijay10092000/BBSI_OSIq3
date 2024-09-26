/**
 * Account is the trigger for the Account SObject.
 */
trigger Account on Account(
	before insert,
	after insert,
	before update,
	after update,
	before delete,
	after delete,
	after undelete
) {
	TriggerHandlerInvoker.execute(new Account_TriggerHandler());
	TriggerHandlerInvoker.execute(new Account_Benefits_TriggerHandler());
	TriggerHandlerInvoker.execute(new Account_Dlrs_TriggerHandler());
}