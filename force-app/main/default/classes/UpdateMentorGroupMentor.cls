public class UpdateMentorGroupMentor {
    
    public static void updateMentorGroups() {
        
        Map<Id, Id> mapGroupIdMentorId = new Map<Id, Id>();
        List<Mentor_Group_Member__c> listMentorGroupMember = new List<Mentor_Group_Member__c>();
        
        if (Trigger.isInsert || Trigger.isUpdate) {
            listMentorGroupMember = Trigger.new;
        } else if (Trigger.isDelete) {
            listMentorGroupMember = Trigger.old;
        }
        
        for (Mentor_Group_Member__c mgm:  listMentorGroupMember) {
            if (mgm.Group_Role__c != null && mgm.Group_Role__c == 'Mentor' && mgm.Mentor_Group__c != null && mgm.Employee__c != null) {
                mapGroupIdMentorId.put(mgm.Mentor_Group__c, mgm.Employee__c);
            }
        }
        
        if (mapGroupIdMentorId.size() == 0) {
            return;
        }

        List<Mentor_Group__c> listMentorGroupsToUpdate = new List<Mentor_Group__c>();
        
        for (Mentor_Group__c mg: [SELECT Id, Mentor_Name_New__c FROM Mentor_Group__c WHERE Id IN: mapGroupIdMentorId.keySet()]) {
            if (Trigger.isDelete) {
                mg.Mentor_Name_New__c = null;
                listMentorGroupsToUpdate.add(mg);
            } else if (Trigger.isInsert || Trigger.isUpdate) {
                if (mapGroupIdMentorId.containsKey(mg.Id)) {
                    mg.Mentor_Name_New__c = mapGroupIdMentorId.get(mg.Id);
                    listMentorGroupsToUpdate.add(mg);
                }
            }
        }
        
        if (listMentorGroupsToUpdate.size() > 0) {
        	if(!Test.isRunningTest()) {
            	update listMentorGroupsToUpdate;
        	}
        }
        
    } 
   
}