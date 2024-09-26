/**
 * Modified from: https://dreamevent.secure.force.com/articleView?id=entitlements_milestones_trigger.htm&type=5
 */
@IsTest
public with sharing class MileStone_Services_Test {

    static testMethod void TestCompleteMilestoneCase(){
        Account client = TestFactory.createAccount('TestClient', '98662', 'Client', false);
        client.AD_Username__c = 'BBSI';
        client.External_ID__c = '999875';
        insert client;
        Account busAcc = TestFactory.createAccount('TestClient', '98662', 'BBSI Branch', false);
        busAcc.External_ID__c = '911';
        insert busAcc;

        Contact branchContact = TestFactory.createContact(busAcc, 'Lastname1', 'BBSI Employee',  false);
        insert new List<Contact> { branchContact };

		SlaProcess ep = [SELECT Id FROM SlaProcess WHERE Name = 'Standard Support' AND IsActive = true AND IsVersionDefault = true];
        Entitlement entl = new Entitlement(
            Name = 'TestEntitlement', 
            AccountId = busAcc.Id, 
            SlaProcessId = ep.Id,
            Entitlement_Code__c = '001');
        insert entl;

        String entlId;
        if (entl != null) {
            entlId = entl.Id; 
        }

        Test.startTest();

        List<Case> cases = new List<Case>{};
        if (entlId != null) {
            Case c = new Case(
                Subject = 'Test Case with Entitlement', 
                EntitlementId = entlId, 
                ContactId = branchContact.Id,
                Type = 'Contracts',
                Type__c = 'Renewal/Pricing',
                Origin = 'Salesforce',
                RecordTypeId = RecordTypeService.getId('Case', 'Client/Referral Partner'),
                Skip_Automation__c = true
            );
            cases.add(c);
        }
  
        List<Id> caseIds = new List<Id>();
        if (cases.isEmpty() == false) {
            insert cases;
            for (Case cL : cases) {
                caseIds.add(cL.Id);
            }
        }

        cases[0].OwnerId = UserInfo.getUserId();
        cases[0].Status = 'Assigned';
        cases[0].Severity__c = 'S1';
        update cases;

        Test.stopTest();
		Milestone_Services.completeMilestone(caseIds, 'Assignment', System.now());
        // This bypasses a correct test
        List<CaseMileStone> caseMilestones = [SELECT Id, CaseId, IsCompleted, MilestoneType.Name FROM CaseMilestone WHERE CaseId IN :caseIds];

        CompleteMilestoneAssignment.CompleteAssignmentMilestone(caseIds);
        CompleteMilestoneFirstResponse.CompleteAssignmentMilestone(caseIds);
        CompleteMilestoneResolution.CompleteAssignmentMilestone(caseIds);
    }

}