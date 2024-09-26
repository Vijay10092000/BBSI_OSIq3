public class Milestone_Services {
    public static void completeMilestone(List<Id> caseIds, String milestoneName, DateTime CompletedDate){
        List<CaseMilestone> caseMilestones = new List<CaseMilestone>();
        List<Id> milestoneIds = new List<Id>();
        
        if(caseIds.size()>0){
        	caseMilestones = [SELECT Id, CaseId, IsCompleted FROM CaseMilestone WHERE IsCompleted = FALSE AND CaseMilestone.MilestoneType.Name = :milestoneName AND CaseId IN:caseIds];
        
            for(CaseMilestone cm : caseMilestones){
                cm.CompletionDate = completedDate;
            }
            
            if(caseMilestones.size()>0){
                update caseMilestones;
            }
        }
    }
}