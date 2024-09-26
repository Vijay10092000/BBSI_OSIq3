/**
 * @description FeedComment_TriggerHandler controls trigger events for FeedComment objects.
 */
public without sharing class FeedComment_TriggerHandler extends TriggerHandlerInvoker.TriggerHandler_Abstract {
	override public void beforeInsert(List<SObject> listNew) {
        List<FeedComment> newFeedComments = (List<FeedComment>) listNew;

    	FeedComment_Service.blockClosedCaseComments(newFeedComments);
	}

	override public void afterInsert(Map<Id, SObject> mapNew) {
		Map<Id, FeedComment> newFeedComments = (Map<Id, FeedComment>) mapNew;

    	FeedComment_Service.workMentions(newFeedComments.values());
    	FeedComment_Service.emailCaseTeam(newFeedComments.values());
	}

	override public void beforeUpdate(Map<Id, SObject> mapOld, Map<Id, SObject> mapNew) {
		Map<Id, FeedComment> oldFeedComments = (Map<Id, FeedComment>) mapOld;
		Map<Id, FeedComment> newFeedComments = (Map<Id, FeedComment>) mapNew;

    	FeedComment_Service.blockCaseCommentEdit(newFeedComments, oldFeedComments);
	}

	override public void beforeDelete(Map<Id, SObject> mapOld) {
		Map<Id, FeedComment> oldFeedComments = (Map<Id, FeedComment>) mapOld;

        FeedComment_Service.blockCaseCommentDeletion(null, oldFeedComments);
	}
}