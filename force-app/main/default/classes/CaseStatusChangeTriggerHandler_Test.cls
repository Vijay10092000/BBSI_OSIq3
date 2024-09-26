/**
 * CaseStatusChangeTriggerHandler_Test is the test class for the Case Status change work.
 */
 @IsTest
public class CaseStatusChangeTriggerHandler_Test {
    @testSetup 
    static void setup() {
        Account a1 = TestFactoryAccount.createBranch('TEST ACCOUNT 1', '99999',null,null);
        Contact con = TestFactoryContact.createContact('firstname', 'Lastname1', 'BBSI Employee', a1.id);		
        Map<String, Object> fldMap = new Map<String, Object>();
        fldMap.put('Subject', 'Unittest');
        fldMap.put('Status', 'New');
        fldMap.put('ContactId', con.Id);
        fldMap.put('Skip_Automation__c', true);
		Case newCase = TestFactoryCase.createCase('', fldMap);
        Case testCase = [SELECT Subject, Status FROM Case WHERE Subject = 'Unittest']; 
        Assert.areEqual(testCase.Subject, 'Unittest');
    }

    @IsTest 
    static void testOnAfterInsert() {
        Case[] testCase = [SELECT Subject, CaseNumber, Status, Owner.Name FROM Case WHERE Subject = 'Unittest'];
        CaseStatusChangeTriggerHandler.OnAfterInsert(testCase);
        Case_Status_Change__c[] caseStatusChange = [SELECT Name FROM Case_Status_Change__c WHERE Case__r.Id =:testCase[0].Id];
        Assert.areEqual(caseStatusChange[0].Name, testCase[0].CaseNumber + ' status: New');
    }

    @IsTest 
    static void testOnAfterUpdate(){
        Map<Id, Case> oldObjectMap = new Map<Id, Case>();
        Case[] testCase = [SELECT Subject, CaseNumber, Status, Owner.Name FROM Case WHERE Subject = 'Unittest'];
        Case_Status_Change__c statusChange = TestFactoryCaseStatusChange.createCaseStatusChange(testCase[0].Id,testCase[0].CaseNumber + ' status: New',testCase[0].Status);
        testCase[0].Status = 'Escalated';

        Case oldCase = new Case(
            Id = testCase[0].Id,
            Subject ='Unittest',
            Status = 'New'
        );
        oldObjectMap.put(testCase[0].Id, oldCase);
        CaseStatusChangeTriggerHandler.OnAfterUpdate(testCase, oldObjectMap);
        Case_Status_Change__c[] caseStatusChange = [SELECT Name FROM Case_Status_Change__c WHERE Case__r.Id = :testCase[0].Id AND Change_Time__c = null];
        Assert.areEqual(caseStatusChange[0].Name, testCase[0].CaseNumber + ' from New to Escalated');
    }
}