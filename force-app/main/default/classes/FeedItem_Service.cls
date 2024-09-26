/**
 * FeedItem_Service
 */
public without sharing class FeedItem_Service {
    
    /**
     * blockClosedCaseFeedItems stops new posts on closed cases.
     * @param  newValues List of new FeedItems
     */
    public static void blockClosedCaseFeedItems(List<FeedItem> newValues) {
        Map<Id, List<FeedItem>> mapCaseIdToFeedItems = new Map<Id, List<FeedItem>>();

        for (FeedItem fi : newValues) {
            if (Id_Service.isType(fi.ParentId, 'Case')) {
                if (!mapCaseIdToFeedItems.containsKey(fi.ParentId)) {
                    mapCaseIdToFeedItems.put(fi.ParentId, new List<FeedItem>());
                }
                mapCaseIdToFeedItems.get(fi.ParentId).add(fi);
            }
        }

        if (!mapCaseIdToFeedItems.isEmpty()) {
            List<Case> cases = [SELECT Id, Status FROM Case WHERE Id IN :mapCaseIdToFeedItems.keySet() AND Status = 'Closed'];

            for (Case c : cases) {
                for (FeedItem fi : mapCaseIdToFeedItems.get(c.Id)) {
                    fi.addError(Label.FeedItem_Block_Closed_Case_Post);
                }
            }
        }
    }
    
    /**
     * blockCaseFeedItemEdit stops posts on cases from being edited.
     * @param  newValues Map of changed FeedItems
     * @param  oldValues Map of FeedItems before changes
     */
    public static void blockCaseFeedItemEdit(Map<Id, FeedItem> newValues, Map<id, FeedItem> oldValues) {
        for (FeedItem fi : newValues.Values()) {
            if (Id_Service.isType(fi.ParentId, 'Case')) {
                fi.addError(Label.FeedItem_Block_Case_Post_Edit);
            }
        }
    }

    /**
     * blockCaseFeedItemDeletion stops posts on cases from being deleted.
     * @param  newValues Map of FeedItems deleting
     * @param  oldValues Map of FeedItems before delete
     */
    public static void blockCaseFeedItemDeletion(Map<Id, FeedItem> newValues, Map<id, FeedItem> oldValues) {
        for (FeedItem fi : oldValues.Values()) {
            if (Id_Service.isType(fi.ParentId, 'Case')) {
                fi.addError(Label.FeedItem_Block_Case_Post_Deletion);
            }
        }
    }

    /**
     * workMentions works through the given FeedItems and adds
     * the @ mentions to the Case Team as required.
     *
     * @param feedItems - A list of FeedItems to add to Case Team
     */
    public static void workMentions(List<FeedItem> feedItems) {
        List<FeedItem> workItems = onlyCaseFeedItems(feedItems);

        if (!workItems.isEmpty()) {
            Map<Id, FeedItem> mapFeedItems = toIdMap(workItems);
            FeedMention_Service.workMentions(mapFeedItems);
        }
    }

    /**
     * toIdMap converts the List of FeedItems into a Map with Id as key.
     * @param  feedItems The List to convert
     * @return The Map
     */
    public static Map<Id, FeedItem> toIdMap(List<FeedItem> feedItems) {
        Map<Id, FeedItem> results = new Map<Id, FeedItem>();

        for (FeedItem fi : feedItems) {
            results.put(fi.Id, fi);
        }

        return results;
    }

    /**
     * onlyCaseFeedItems removes any comments which are not related to a Case.
     * @param  feedItems The List of FeedItems to review
     * @return A list with only the FeedComments for Cases
     */
    private static List<FeedItem> onlyCaseFeedItems(List<FeedItem> feedItems) {
        List<FeedItem> results = new List<FeedItem>();
        
        for (FeedItem fi : feedItems) {
            if (Id_Service.isType(fi.ParentId, 'Case')) {
                results.add(fi);
            }
        }
        
        return results;
    }

}