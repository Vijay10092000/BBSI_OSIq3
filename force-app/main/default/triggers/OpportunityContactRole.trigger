/**
 * OpportunityContactRole is the trigger for the OpportunityContactRole SObject.
 */
trigger OpportunityContactRole on OpportunityContactRole (
	before insert, after insert,
	before update, after update,
	before delete, after delete,
	after undelete
) {
	TriggerHandlerInvoker.execute(new OpportunityContactRole_TriggerHandler()); // Updated For US-69176
}