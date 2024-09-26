public class CompleteMilestoneFirstResponse {
	@InvocableMethod
    public static void CompleteAssignmentMilestone(List<Id> caseIds){
        String milestoneName = 'First Response';
        DateTime currentDateTime = System.Now();
        Milestone_Services.completeMilestone(caseIds, milestoneName, currentDateTime);
    }
}