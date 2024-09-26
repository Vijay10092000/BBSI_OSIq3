/**
 * Position is the trigger for the Position__c SObject.
 */
trigger Position on Position__c (
	before insert, after insert,
	before update, after update,
	before delete, after delete,
	after undelete
) {
	TriggerHandlerInvoker.execute(new Position_TriggerHandler()); // Updated For US-69176
}