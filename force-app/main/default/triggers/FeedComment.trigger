/**
 * FeedComment is the trigger for the FeedComment SObject.
 */
trigger FeedComment on FeedComment(
	before insert,
	after insert,
	before update,
	after update,
	before delete,
	after delete,
	after undelete
) {
	TriggerHandlerInvoker.execute(new FeedComment_TriggerHandler()); // Updated For US-69176
}