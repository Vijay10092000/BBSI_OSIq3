/**
 * @description FeedComment_Service
 *
 * @See Email Notifications for Comments (replies) in Chatter Groups https://success.salesforce.com/ideaView?id=08730000000ielDAAQ
 */
public without sharing class FeedComment_Service {

    /**
     * @description blockClosedCaseComments stops new posts on closed cases.
     * @param  newValues List of new FeedComments
     */
    public static void blockClosedCaseComments(List<FeedComment> newValues) {
        Map<Id, List<FeedComment>> mapCaseIdToFeedComments = new Map<Id, List<FeedComment>>();

        for (FeedComment fc : newValues) {
            if (Id_Service.isType(fc.ParentId, 'Case')) {
                if (!mapCaseIdToFeedComments.containsKey(fc.ParentId)) {
                    mapCaseIdToFeedComments.put(fc.ParentId, new List<FeedComment>());
                }
                mapCaseIdToFeedComments.get(fc.ParentId).add(fc);
            }
        }

        if (!mapCaseIdToFeedComments.isEmpty()) {
            List<Case> cases = [SELECT Id, Status FROM Case WHERE Id IN :mapCaseIdToFeedComments.keySet() AND Status = 'Closed'];

            for (Case c : cases) {
                for (FeedComment fc : mapCaseIdToFeedComments.get(c.Id)) {
                    fc.addError(Label.FeedComment_Block_Closed_Case_Comment);
                }
            }
        }
    }
    
    /**
     * @description blockCaseCommentEdit stops posts on cases from being edited.
     * @param  newValues Map of changed FeedComments
     * @param  oldValues Map of FeedComments before changes
     */
    public static void blockCaseCommentEdit(Map<Id, FeedComment> newValues, Map<id, FeedComment> oldValues) {
        for (FeedComment fc : newValues.Values()) {
            if (Id_Service.isType(fc.ParentId, 'Case')) {
                fc.addError(Label.FeedComment_Block_Case_Comment_Edit);
            }
        }
    }

    /**
     * @description blockCaseCommentDeletion stops posts on cases from being deleted.
     * @param  newValues Map of FeedComments deleting
     * @param  oldValues Map of FeedComments before delete
     */
    public static void blockCaseCommentDeletion(Map<Id, FeedComment> newValues, Map<id, FeedComment> oldValues) {
        for (FeedComment fc : oldValues.Values()) {
            if (Id_Service.isType(fc.ParentId, 'Case')) {
                fc.addError(Label.FeedComment_Block_Case_Comment_Deletion);
            }
        }
    }

    /**
     * @description workMentions works through the given FeedComments and adds
     * the @ mentions to the Case Team as required.
     *
     * @param feedComments - A list of FeedComments to add to Case Team
     */
    public static void workMentions(List<FeedComment> feedComments) {
        List<FeedComment> workComments = onlyCaseFeedComments(feedComments);

        if (!workComments.isEmpty()) {
            Map<Id, FeedComment> mapFeedComments = toIdMap(workComments);
            FeedMention_Service.workMentions(mapFeedComments);
        }
    }

    /**
     * @description onlyCaseFeedComments removes any comments which are not related to a Case.
     * @param  feedComments The List of FeedComments to review
     * @return A list with only the FeedComments for Cases
     */
    private static List<FeedComment> onlyCaseFeedComments(List<FeedComment> feedComments) {
        List<FeedComment> results = new List<FeedComment>();
        
        for (FeedComment fc : feedComments) {
            if (Id_Service.isType(fc.ParentId, 'Case')) {
                results.add(fc);
            }
        }
        
        return results;
    }

    /**
     * @description toIdMap converts the List of FeedComments into a Map with Id as key.
     * @param  feedComments The List to convert
     * @return The Map
     */
    public static Map<Id, FeedComment> toIdMap(List<FeedComment> feedComments) {
        Map<Id, FeedComment> results = new Map<Id, FeedComment>();

        for (FeedComment fc : feedComments) {
            results.put(fc.Id, fc);
        }

        return results;
    }
    
    /**
     * @description emailCaseTeam emails chatter posts comments on cases to the Case Team Members.
     * If the owner is a group or queue, then all members are emailed.
     * @param  feedComments The chatter post comments
     */    
	public static void emailCaseTeam(List<FeedComment> feedComments) {
        List<FeedComment> openCaseFeedComments = onlyOpenCasesFeedComments(feedComments);

        if (openCaseFeedComments.isEmpty()) {
            return;
        }
        
        if (updateRelatedCases(openCaseFeedComments)) {
            Set<Id> feedItemIds = new Set<Id>();
    	    Set<Id> caseIds = new Set<Id>();
            for (FeedComment fc : openCaseFeedComments) {
                if (fc.ParentId.getSObjectType() == Case.SObjectType) {
                    caseIds.add(fc.parentId);
                }
                feedItemIds.add(fc.feedItemId);
            }

            Map<Id, FeedItem> mapFeedItems = new Map<Id, FeedItem>([SELECT Id, InsertedById, InsertedBy.Email FROM FeedItem WHERE Id IN :feedItemIds]);

            List<Messaging.SingleEmailMessage> emails = makeCaseCommentEmails(feedComments, caseIds, mapFeedItems);

            if (emails != null) {
                if (!Test.isRunningTest()) {
                    Messaging.sendEmail(emails);
                }
            }
        }
    } 
    
    /**
     * @description onlyOpenCasesFeedComments retrieves the FeedComments for open cases only.
     * @param  feedComments feedComments description
     * @return              return description
     */
    @TestVisible
    private static List<FeedComment> onlyOpenCasesFeedComments(List<FeedComment> feedComments) {
       List<FeedComment> comments = new List<FeedComment>();

       Set<Id> caseIds = new Set<Id>();
       
       for (FeedComment fc : feedComments){
           if (fc.ParentId.getSObjectType() == Case.SObjectType) {
               caseIds.add(fc.parentId);
           }
       }

       if (!caseIds.isEmpty()) {
           Map<Id, Case> maRelatedOpenCases = new Map<Id, Case>([SELECT Id FROM Case WHERE Id IN :caseIds AND IsClosed = false]);

           for (FeedComment fc : feedComments) {
               if (maRelatedOpenCases.containsKey(fc.parentId)) {
                   comments.add(fc);
               }
           }
       }

       return comments;
   }


    /**
     * @description updateRelatedCases updates the Most Recent Comment field with the new
     * Feed Comment text and who commented.
     * @param  feedComments The chatter post comments
     * @return true is Cases were updated
     */
	@TestVisible
    private static Boolean updateRelatedCases(List<FeedComment> feedComments) {
        Set<Id> insertBys = new Set<Id>();

    	for (FeedComment fc : feedComments) {
        	if (fc.ParentId.getSObjectType() == Case.SObjectType) {
                insertBys.add(fc.InsertedById);
            }
        }

        List<Case> updateCases = new List<Case>();
	    Map<Id, User> userMap = new Map<Id, User>([SELECT Id, Name FROM User WHERE Id IN :insertBys]);

    	for (FeedComment fc : feedComments) {
        	if (fc.ParentId.getSObjectType() == Case.SObjectType) {
                Case updateCase = new Case();
                updateCase.Id = fc.ParentId;

                if (userMap.containsKey(fc.InsertedById) && fc.commentBody != null) {
                    String text = '\r\nComment Made By: ' + userMap.get(fc.InsertedById).Name + '\r\n' + fc.commentBody.stripHtmlTags();

					updateCase.Most_Recent_Comment__c = text.left(3900);
                }
                updateCase.Sub_Status__c = 'New Comment';
	    		
                updateCases.add(updateCase);
            }
        }

        if (updateCases.isEmpty()) {
            return false;
        }

        update updateCases;
        return true;
    }

    /**
     * @description makeCaseCommentEmails creates emails for the given Feed Comments.
     * @param  feedComments Feed Comments creating emails for
     * @param  idCases      Ids of cases related to the Feed Comments
     * @param  mapFeedItems FeedItems related to FeedComments
     * @return A list of emails to send
     */
    private static List<Messaging.SingleEmailMessage> makeCaseCommentEmails(List<FeedComment> feedComments, Set<Id> idCases, Map<Id, FeedItem> mapFeedItems) {
	    List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        if (idCases.size() > 0) {
            Id idEmailTemplate = [SELECT Id FROM EmailTemplate WHERE Name = 'Case: Feed Comment' LIMIT 1].Id;
	    	Map<Id, Case> caseMap = new Map<Id, Case>([
                SELECT Id, OwnerId, ContactId, Contact.User_Id__c 
                FROM Case 
                WHERE Id IN :idCases
            ]);

            Map<Id, Set<String>> caseEmails = getCaseTeamMemberEmails(idCases);

	    	for (FeedComment fc : feedComments) {
                if (!String.isBlank(fc.commentBody) && caseMap.containsKey(fc.ParentId)) {
                    Case c = caseMap.get(fc.ParentId);

                    Set<String> addresses = caseEmails.get(c.Id);
                    addresses.remove(UserInfo.getUserEmail());

                    if (mapFeedItems.containsKey(fc.FeedItemId)) {
                        addresses.remove(mapFeedItems.get(fc.FeedItemId).InsertedBy.Email);
                    }

                    if (!addresses.isEmpty()) {
                        Messaging.SingleEmailMessage message = Messaging.renderStoredEmailTemplate(idEmailTemplate, null, fc.ParentId);
                        message.setSaveAsActivity(false);
                        message.setToAddresses(new List<String>(addresses));
                        emails.add(message);
                    }
                }
	    	}
    	}

        return emails;
    }

    /**
     * @description getCaseTeamMemberEmails for each of the given emails, get a list of the
     * team member emails.
     * @param  idCases Cases looking at
     * @return Map from case to list of email addresses
     */
    @TestVisible
    private static Map<Id, Set<String>> getCaseTeamMemberEmails(Set<Id> idCases) {
        Map<Id, Set<String>> caseEmails = new Map<Id, Set<String>>();

        for (CaseTeamMember member : [SELECT MemberId, Member.Email, ParentId FROM CaseTeamMember WHERE ParentId = :idCases]) {
            if (!caseEmails.containsKey(member.ParentId)) {
                caseEmails.put(member.ParentId, new Set<String>());
            }
            
            if (member.MemberId.getSobjectType() == User.SObjectType) {
                caseEmails.get(member.ParentId).add(member.Member.Email);
            }
        }
        return caseEmails;
    }

}