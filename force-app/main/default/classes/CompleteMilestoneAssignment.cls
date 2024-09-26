public class CompleteMilestoneAssignment {
	@InvocableMethod
    public static void CompleteAssignmentMilestone(List<Id> caseIds){
        String milestoneName = 'Assignment';
        DateTime currentDateTime = System.Now();
        Milestone_Services.completeMilestone(caseIds, milestoneName, currentDateTime);
    }
}