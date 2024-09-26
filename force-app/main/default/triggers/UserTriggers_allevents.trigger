/**
 * User_Trigger is the trigger for the User SObject.
 */
trigger UserTriggers_allevents on User (
	before insert, after insert,
	before update, after update, 
	before delete, after delete,
	after undelete
) {
	TriggerHandlerInvoker.execute(new User_TriggerHandler()); // Updated For US-69176
}