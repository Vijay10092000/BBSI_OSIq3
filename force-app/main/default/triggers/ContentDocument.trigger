/**
 * ContentDocument is the trigger for the ContentDocument SObject.
 */
trigger ContentDocument on ContentDocument(
	before insert,
	after insert,
	before update,
	after update,
	before delete,
	after delete,
	after undelete
) {
	TriggerHandlerInvoker.execute(new ContentDocument_TriggerHandler());
}