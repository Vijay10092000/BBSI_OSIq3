/**
 * FeedItem is the trigger for the FeedItem SObject.
 */
trigger FeedItem on FeedItem(
	before insert,
	after insert,
	before update,
	after update,
	before delete,
	after delete,
	after undelete
) {
	TriggerHandlerInvoker.execute(new FeedItem_TriggerHandler()); // Updated For US-69176
}