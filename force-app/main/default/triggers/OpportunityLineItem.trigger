/**
 * OpportunityLineItem is the trigger for the changes to OpportunityLineItems.
 */
trigger OpportunityLineItem on OpportunityLineItem(
	before insert, after insert,
	before update, after update,
	before delete, after delete,
	after undelete ) {
	TriggerHandlerInvoker.execute(new OpportunityLineItem_TriggerHandler()); // Updated For US-69176
}