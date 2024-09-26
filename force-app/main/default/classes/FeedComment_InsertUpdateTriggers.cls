public with sharing class FeedComment_InsertUpdateTriggers {

    public void handle(){
        if(Trigger.isBefore && Trigger.isInsert){
            beforeInsert((List<FeedComment>)Trigger.new);
        }
        if(Trigger.isAfter && Trigger.isInsert){
            afterInsert((Map<id, FeedComment>)Trigger.newMap);
        }
        if(Trigger.isBefore && Trigger.isUpdate){
            beforeUpdate((Map<id, FeedComment>)Trigger.newMap, (Map<id, FeedComment>)Trigger.oldMap);
        }
        if(Trigger.isBefore && Trigger.isDelete){
            beforeDelete((Map<id, FeedComment>)Trigger.newMap, (Map<id, FeedComment>)Trigger.oldMap);
        }
    }

    private void beforeInsert(List<FeedComment> newValues) {
    	FeedComment_Service.blockClosedCaseComments(newValues);
    }

    private void afterInsert(Map<Id, FeedComment> newValues) {
    	FeedComment_Service.workMentions(newValues.values());
    	FeedComment_Service.emailCaseTeam(newValues.values());
    }

    private void beforeUpdate(Map<Id, FeedComment> newValues, Map<id, FeedComment> oldValues) {
    	FeedComment_Service.blockCaseCommentEdit(newValues, oldValues);
    }

    private void beforeDelete(Map<Id, FeedComment> newValues, Map<id, FeedComment> oldValues) {
    	FeedComment_Service.blockCaseCommentDeletion(newValues, oldValues);
    }

}