/**
 * Opportunity_Trigger is the trigger for the changes to Opportunity.
 */
trigger Opportunity on Opportunity(
	before insert, after insert,
	before update, after update,
	before delete, after delete,
	after undelete ) {
	TriggerHandlerInvoker.execute(new Opportunity_Benefits_TriggerHandler());
	TriggerHandlerInvoker.execute(new Opportunity_TriggerHandler());
}