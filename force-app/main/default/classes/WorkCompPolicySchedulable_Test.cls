@IsTest
public with sharing class WorkCompPolicySchedulable_Test {

    @IsTest
    public static void  testSchedule() {
    	Account a = TestFactoryAccount.createProspect('TestAccount', null, null);
        Test.startTest();

        WorkCompPolicySchedulable wcpSchedule = new WorkCompPolicySchedulable();      
        wcpSchedule.execute(null);

        Test.stopTest();
    }

}