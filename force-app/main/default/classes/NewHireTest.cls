@isTest
private class NewHireTest {

    @isTest static void approvalSubmission(){
        Position__c p = new Position__c();
        User BDM = TestFactory.createUser('Test', 'BDM@bbsihq.com', 'BDM@bbsihq.com', 'BBSI Standard', '910', true);

        Account Branch = new Account();
        Branch.Name = 'Test Branch';
        Branch.Branch_Manager__c = 'Test';
        Branch.Area_Manager_Email__c = 'Test@Test.com';
        Branch.RecordTypeId = RecordTypeService.getId('Account','BBSI_Branch');
        Branch.Branch_Manager_Email__c = 'Test@Test.com';
        insert Branch;
        
        Account a = new Account();
        a.Name = 'Cancelled Client';
        a.Business_Development_Manager__c = BDM.ID;
        a.Prospect_Branch__c = Branch.ID;
        insert a;
        
        p.Branch__c = Branch.Id;
        p.Job_Title__c = 'Area Manager';
        p.Type__c = 'New';
        p.Position__c = 'Exempt';
        p.Hours_Per_Week__c = 40;
        p.Est_Annual_Salary__c = 3.50;
        p.Reason_for_New_Hire__c = 'Test Class';
        p.Status__c = 'Open';
        insert p;
		
        Candidate__c c = new Candidate__c();
        c.Name= 'Test';
        c.Position__c = p.ID;
        insert c;
        
		PageReference pageRef = Page.CandidateSubmitApprovalPage;
        pageRef.getParameters().put('id', c.ID);
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController Extension = new ApexPages.StandardController(c);
        CandidateSubmitApprovalExtension controller = new CandidateSubmitApprovalExtension(Extension);
		
		controller.submitRecordForApproval();		
	}
}