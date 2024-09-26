/**
 * Task is the trigger for the Task SObject.
 */
trigger Task on Task(
	before insert,
	after insert,
	before update,
	after update,
	before delete,
	after delete,
	after undelete
) {
	TriggerHandlerInvoker.execute(new Task_TriggerHandler()); // Updated For US-69176
}