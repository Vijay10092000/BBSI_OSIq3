@IsTest
private class RenewalTerminationTest {
    private static String TEST_ACCOUNT_NAME = 'Renewal Termination Test Account';
    private static String TEST_RENEWAL_NAME = 'Renewal Test';
    private static Account clientAccount;
    private static Renewal__c renewal;

    @TestSetup
    static void setupTest() {
        clientAccount = TestFactory.createAccount(TEST_ACCOUNT_NAME, '99999', 'Client', false);
        insert clientAccount;

        renewal = new Renewal__c(Name = TEST_RENEWAL_NAME, FEIN__c = '99-9999999', Status__c = 'Approved');
        insert renewal;        
    }

    static void setData() {
        clientAccount = [SELECT Id, Name, Status__c, Renewal__c FROM Account WHERE Name = :TEST_ACCOUNT_NAME];
        renewal = [SELECT Id, Name, FEIN__c, Status__c FROM Renewal__c WHERE Name = :TEST_RENEWAL_NAME];
    }

    @IsTest
    static void testProcessRenewalTermination_Terminate() {
        setData();

        clientAccount.Renewal__c = renewal.Id;
        clientAccount.Status__c = 'Active';
        update clientAccount;
        
        Test.startTest();
        
        clientAccount.Status__c = 'Terminated';
        update clientAccount;
        
        Test.stopTest();
        
        Account testAccount = [SELECT Id, Name, Status__c, Renewal__c FROM Account WHERE Id = :clientAccount.Id];
        System.assertEquals('Terminated', testAccount.Status__c);
        Renewal__c testRenewal = [SELECT Id, Name, FEIN__c, Status__c FROM Renewal__c WHERE Id = :renewal.Id];
        System.assertEquals('Terminated', testRenewal.Status__c);
    }

    @IsTest
    static void testProcessRenewalTermination_NotTerminate() {
        setData();

        clientAccount.Renewal__c = renewal.Id;
        clientAccount.Status__c = 'Active';
        update clientAccount;
        
        Test.startTest();
        
        // Should not change to 
        clientAccount.Phone = '555-555-5555';
        update clientAccount;
        
        Test.stopTest();
        
        Account testAccount = [SELECT Id, Name, Status__c, Renewal__c FROM Account WHERE Id = :clientAccount.Id];
        System.assertNotEquals('Terminated', testAccount.Status__c);
        Renewal__c testRenewal = [SELECT Id, Name, FEIN__c, Status__c FROM Renewal__c WHERE Id = :renewal.Id];
        System.assertNotEquals('Terminated', testRenewal.Status__c);
    }

}