/**
 * @description FeedItem_TriggerHandler controls trigger events for FeedItem objects.
 */
public without sharing class FeedItem_TriggerHandler extends TriggerHandlerInvoker.TriggerHandler_Abstract {
	override public void beforeInsert(List<SObject> listNew) {
        List<FeedItem> newFeedItems = (List<FeedItem>) listNew;

		FeedItem_Service.blockClosedCaseFeedItems(newFeedItems);
	}

	override public void afterInsert(Map<Id, SObject> mapNew) {
		Map<Id, FeedItem> newFeedItems = (Map<Id, FeedItem>) mapNew;

    	FeedItem_Service.workMentions(newFeedItems.values());
	}

	override public void beforeUpdate(Map<Id, SObject> mapOld, Map<Id, SObject> mapNew) {
		Map<Id, FeedItem> oldFeedItems = (Map<Id, FeedItem>) mapOld;
		Map<Id, FeedItem> newFeedItems = (Map<Id, FeedItem>) mapNew;

        FeedItem_Service.blockCaseFeedItemEdit(newFeedItems, oldFeedItems);
	}

	override public void beforeDelete(Map<Id, SObject> mapOld) {
		Map<Id, FeedItem> oldFeedItems = (Map<Id, FeedItem>) mapOld;

    	FeedItem_Service.blockCaseFeedItemDeletion(null, oldFeedItems);
	}
}