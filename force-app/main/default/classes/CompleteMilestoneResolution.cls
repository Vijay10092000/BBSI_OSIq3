public class CompleteMilestoneResolution {
	@InvocableMethod
    public static void CompleteAssignmentMilestone(List<Id> caseIds){
        String milestoneName = 'Resolution';
        DateTime currentDateTime = System.Now();
        Milestone_Services.completeMilestone(caseIds, milestoneName, currentDateTime);
    }
}