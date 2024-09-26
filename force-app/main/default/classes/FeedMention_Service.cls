/**
 * FeedMention_Service
 *
 * @see https://salesforce.stackexchange.com/questions/147300/feeditem-trigger-parse-mentions
 *
 * When testing for DEPLOY run FeedItem_Service_Test and FeedComment_Service_Test
 */
public without sharing class FeedMention_Service {

    private static Case_Team_Settings__mdt teamSettings = [SELECT Case_Team_User_Mention_Base_Role__c, Case_Team_Group_Mention_Size_Limit__c
                                                           FROM Case_Team_Settings__mdt
                                                           WHERE DeveloperName = 'Base_Case_Team_Settings'
                                                           LIMIT 1];

    /**
     * workMentions adds members to Case Team if @-mentioned.  Also, adds
     * the users as Case followers.
     * @param  mapFeedItems Items to look through for @-mentions
     */
    public static void workMentions(Map<Id, FeedItem> mapFeedItems) {
        FeedMention_Service service = new FeedMention_Service();
        Set<ConnectApi.FeedItem> apifeedItems = service.getConnectApiFeedItems(new List<Id>(mapFeedItems.keySet()));
        Map<Id, Set<Id>> mapCaseToUsers = service.getCaseUserMentions(mapFeedItems, apiFeedItems);
        service.addMentionsToCaseTeam(mapCaseToUsers);
        EntitySubscription_Service.addSubscribers(mapCaseToUsers);
    }

    /**
     * workMentions adds members to Case Team if @-mentioned.  Also, adds
     * the users as Case followers.
     * @param  mapFeedComments Comments to look through for @-mentions
     */
    public static void workMentions(Map<Id, FeedComment> mapFeedComments) {     
        FeedMention_Service service = new FeedMention_Service();
        Set<ConnectApi.Comment> apifeedComments = service.getConnectApiFeedComments(new List<Id>(mapFeedComments.keySet()));
        Map<Id, Set<Id>> mapCaseToUsers = service.getCaseUserMentions(mapFeedComments, apifeedComments);
        service.addMentionsToCaseTeam(mapCaseToUsers);
        EntitySubscription_Service.addSubscribers(mapCaseToUsers);
    }

    private FeedMention_Service() {
    }

    /**
     * addMentionsToCaseTeam
     * @param  mapCaseToMentions Maps of Case Ids to a list of user Ids mentioned.
     * @return true if new members were added because of mentions
     */
    private void addMentionsToCaseTeam(Map<Id, Set<Id>> mapCaseToUsers) {        
        if (!mapCaseToUsers.isEmpty()) {    
            mapCaseToUsers = replaceGroupsWithMembers(mapCaseToUsers);

            List<CaseTeamMember> insertMembers = new List<CaseTeamMember>();

            String roleName = teamSettings.Case_Team_User_Mention_Base_Role__c;
            Id roleId = CaseTeamRole_Services.getRole(roleName).Id;
            
            for (Id caseId : mapCaseToUsers.keySet()) {
                for (Id newMemberId : mapCaseToUsers.get(caseId)) {                       
                    CaseTeamMember newMember =  new CaseTeamMember(
                        ParentId = caseId,
                        MemberId = newMemberId,
                        TeamRoleId = roleId
                    );
                    insertMembers.add(newMember);
                }
            }

            if (!insertMembers.isEmpty()) {
                // Allow the failures to clean up the duplicates
                database.insert(insertMembers, false);
            }
        }
    }

    /**
     * getCaseUserMentions relates the User @ mentions to Cases.
     *
     * @param feedItems - The orignial FeedItems
     * @param apiFeedItems - The ConnectApi.FeedItems to get mentions for
     * @return a map of Case Ids to Mention Ids.
     */
    private Map<Id, Set<Id>> getCaseUserMentions(Map<Id, FeedItem> mapIdToFeedItems, Set<ConnectApi.FeedItem> apiFeedItems) {
        Map<Id, Set<Id>> results = new Map<Id, Set<Id>>();

        for (ConnectApi.FeedItem afi : apiFeedItems) {
            Set<Id> mentionIds = getMentions(afi);
            
            if (!mentionIds.isEmpty()) {
                results.put(mapIdToFeedItems.get(afi.Id).ParentId, mentionIds);
            }
        }

        return results;
    }

    /**
     * getCaseUserMentions relates the User @ mentions to Cases.
     *
     */
    private Map<Id, Set<Id>> getCaseUserMentions(Map<Id, FeedComment> mapIdToFeedComments, Set<ConnectApi.Comment> apiFeedComments) {
        Map<Id, Set<Id>> results = new Map<Id, Set<Id>>();

        for (ConnectApi.Comment afc : apiFeedComments) {
            Set<Id> mentionIds = getMentions(afc);
            
            if (!mentionIds.isEmpty()) {
                results.put(mapIdToFeedComments.get(afc.Id).ParentId, mentionIds);
            }
        }

        return results;
    }

    /**
     * getMentions finds the @ mentions in the given ConnectApi.FeedItem.
     *
     * @param feedItem - The ConnectApi.FeedItem to get mentions for
     * @return a List of Mention Ids.
     */
    private Set<Id> getMentions(ConnectApi.FeedItem feedItem) {
        Set<Id> mentions = new Set<Id>();

        for (ConnectApi.MessageSegment segment : feedItem.body.messageSegments) {
            if (segment instanceof ConnectApi.MentionSegment) {
                ConnectApi.MentionSegment theMention = (ConnectApi.MentionSegment) segment;
                mentions.add(theMention.record.id);
            }
        }

        return mentions;
    }

    /**
     * getMentions finds the @ mentions in the given ConnectApi.FeedItem.
     *
     * @param feedComment - The ConnectApi.Comment to get mentions for
     * @return a List of Mention Ids.
     */
    private Set<Id> getMentions(ConnectApi.Comment feedComment) {
        Set<Id> mentions = new Set<Id>();


        for (ConnectApi.MessageSegment segment : feedComment.body.messageSegments) {
            if (segment instanceof ConnectApi.MentionSegment) {
                ConnectApi.MentionSegment theMention = (ConnectApi.MentionSegment) segment;
                mentions.add(theMention.record.id);
            }
        }

        return mentions;
    }
        
    /**
     * replaceGroupsWithMembers runs through the mention ids and replaces group ids
     * with the members of the group ids.
     *
     * @param mapCaseToMentions
     * @return a map of Cases to Mention Ids with groups replaced.
     */
    private Map<Id, Set<Id>> replaceGroupsWithMembers(Map<Id, Set<Id>> mapCaseToMentions) {
        Set<Id> groupIds = new Set<Id>();
        
        for (Id caseId : mapCaseToMentions.keySet()) {
            groupIds.addAll(getCollaborationGroupIds(mapCaseToMentions.get(caseId)));
        }

        if (!groupIds.isEmpty()) {
            Map<Id, Set<CollaborationGroupMember>> groupMembers = CollaborationGroup_Service.getGroupMembers(groupIds);

            for (Id caseId : mapCaseToMentions.keySet()) {
                mapCaseToMentions.put(caseId, replaceGroups(mapCaseToMentions.get(caseId), groupMembers));
            }
        }
        
        return mapCaseToMentions;
    }

    private Set<Id> getCollaborationGroupIds(Set<Id> members) {
        Set<Id> groupIds = new Set<Id>();
        
        for (Id sId : members) {
            if (sId.getSObjectType() == CollaborationGroup.SObjectType) {
                groupIds.add(sId);
            }
        }
        
        return groupIds;
    }

    private Set<Id> replaceGroups(Set<Id> ids, Map<Id, Set<CollaborationGroupMember>> groupMembers) {
        Set<Id> groupIds = new Set<Id>();
        
        for (Id sId : ids) {
            if (sId.getSObjectType() == CollaborationGroup.SObjectType) {
                groupIds.add(sId);
            }
        }
        
        Set<Id> results = new Set<ID>(ids);
        
        for (Id sId : ids) {
            if (sId.getSObjectType() == CollaborationGroup.SObjectType) {                
                if (groupMembers.get(sId).size() <= teamSettings.Case_Team_Group_Mention_Size_Limit__c) {
                    for (CollaborationGroupMember gm : groupMembers.get(sId)) {
                        results.add(gm.MemberId);
                        results.remove(sId);
                    }
                }
            }
        }
        
        return results;
    }

    /**
     * getFeedItems connects the ConnectApi.FeedItem with the given FeedItems.
     *
     */
    private Set<ConnectApi.FeedItem> getConnectApiFeedItems(List<Id> feedItemIds) {
        Set<ConnectApi.FeedItem> results = new Set<ConnectApi.FeedItem>();

        ConnectApi.BatchResult[] batchResults = ConnectApi.ChatterFeeds.getFeedElementBatch(Network.getNetworkId(), feedItemIds);

        for (ConnectApi.BatchResult result : batchResults) {
            if (result.isSuccess()) {
                Object theResult = result.getResult();

                if (theResult instanceof ConnectApi.FeedItem) {
                    results.add((ConnectApi.FeedItem) theResult);
                }
            }
        }

        return results;
    } 

    /**
     * getConnectApiFeedComments connects the ConnectApi.Comment with the given FeedComments.
     *
     * @param feedCommentIds - A list of FeedComments to get mentions for
     * @return a Map connecting the FeedComment Id to a set of ConnectApi.Comments.
     */
    private Set<ConnectApi.Comment> getConnectApiFeedComments(List<Id> feedCommentIds) {
      Set<ConnectApi.Comment> results = new Set<ConnectApi.Comment>();

        ConnectApi.BatchResult[] batchResults = ConnectApi.ChatterFeeds.getCommentBatch(Network.getNetworkId(), feedCommentIds);

        for (ConnectApi.BatchResult result : batchResults) {
            if (result.isSuccess()) {
                Object theResult = result.getResult();

                if (theResult instanceof ConnectApi.Comment) {
                    results.add((ConnectApi.Comment) theResult);
                }
            }
        }

        return results;
    }

}