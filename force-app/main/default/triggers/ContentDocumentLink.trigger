/**
 * ContentDocumentLink is the trigger for the ContentDocumentLink SObject.
 */
trigger ContentDocumentLink on ContentDocumentLink(
	before insert,
	after insert,
	before update,
	after update,
	before delete,
	after delete,
	after undelete
) {
	TriggerHandlerInvoker.execute(new ContentDocumentLink_TriggerHandler());
}