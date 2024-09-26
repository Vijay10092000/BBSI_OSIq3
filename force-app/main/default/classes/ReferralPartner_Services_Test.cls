@IsTest
public without sharing class ReferralPartner_Services_Test {

    @IsTest
    static void test_ReferralPartnerToActive() {
        Account rp = TestFactoryAccount.makeReferralPartner('Test RP Noe', '% of Margin', 10.10, null);
        rp.Status__c = 'Pending';
        rp.Referral_Partner_Status__c = 'Pending';
        insert rp;

        rp = [SELECT Id, Commission_Type__c, Commission_Rate__c, Referral_Partner_Status__c FROM Account WHERE Id = :rp.Id];

        List<Referral_Partner__c> rss;

        rss = [
            SELECT Commission_Rate__c, Referral_Partner_Commission_Type__c
            FROM Referral_Partner__c
            WHERE Referral_Partner__c = :rp.Id
        ];

        Assert.areEqual(0, rss.size(), 'No Referral Source should exist, yet');
        Assert.areEqual('Pending', rp.Referral_Partner_Status__c, 'Referral Partner should have commission type of "% of Margin"');
        Assert.areEqual('% of Margin', rp.Commission_Type__c, 'Referral Partner should have commission type of "% of Margin"');
        Assert.areEqual(10.10, rp.Commission_Rate__c, 'Referral Partner should have commission rate of 10.10');

        Test.startTest();

        rp.Referral_Partner_Status__c = 'Active';
        update rp;

        Test.stopTest();

        rss = [
            SELECT Commission_Rate__c, Referral_Partner_Commission_Type__c
            FROM Referral_Partner__c
            WHERE Referral_Partner__c = :rp.Id
        ];

        Assert.areEqual(1, rss.size(), 'A Referral Source should have been created');

        Referral_Partner__c rs = rss.get(0);
        Assert.areEqual(rp.Commission_Type__c, rs.Referral_Partner_Commission_Type__c, 'Referral Source should have same rate as Referral Partner');
        Assert.areEqual(rp.Commission_Rate__c, rs.Commission_Rate__c, 'Referral Source should have same rate as Referral Partner');
    }

    @IsTest
    static void test_ReferralPartnerToActiveWithClients() {
        Account rp = TestFactoryAccount.makeReferralPartner('Test RP One', '% of Margin', 10.10, null);
        rp.Status__c = 'Pending';
        rp.Referral_Partner_Status__c = 'Pending';
        insert rp;

        Account client1 = TestFactoryAccount.makeClient('Test Client One', rp.Id, null, null, null);
        Account client2 = TestFactoryAccount.makeClient('Test Client Two', rp.Id, null, null, null);
        client2.Status__c = 'Active';
        insert new List<Account>{ client1, client2 };

        List<Referral_Partner__c> rss;

        rss = [
            SELECT Commission_Rate__c, Referral_Partner_Commission_Type__c
            FROM Referral_Partner__c
            WHERE Referral_Partner__c = :rp.Id OR Account__c IN ( :client1.Id, :client2.Id )
        ];

        Assert.areEqual(0, rss.size(), 'No Referral Source should exist, yet');

        Test.startTest();

        rp.Referral_Partner_Status__c = 'Active';
        update rp;

        Test.stopTest();

        rss = [
            SELECT Commission_Rate__c, Referral_Partner_Commission_Type__c
            FROM Referral_Partner__c
            WHERE Referral_Partner__c = :rp.Id OR Account__c IN ( :client1.Id, :client2.Id )
        ];

        Assert.areEqual(3, rss.size(), 'Referral Sources should have been created');

        for (Referral_Partner__c rs : rss) {
            Assert.areEqual(rp.Commission_Type__c, rs.Referral_Partner_Commission_Type__c, 'Referral Source should have same rate as Referral Partner');
            Assert.areEqual(rp.Commission_Rate__c, rs.Commission_Rate__c, 'Referral Source should have same rate as Referral Partner');
        }
    }

    @IsTest
    static void test_LeadConvertToReferralPartner() {
        Account branch = TestFactoryAccount.createBranch('TESTBRANCH', '911', 'area.manager@bbsi.zzz', 'area.manager@bbsi.zzz');

        Lead newLead = new Lead();
        newLead.RecordTypeId = RecordTypeService.getId('Lead', 'Referral_Partner_Lead');
        newLead.Branch__c = branch.Id;
        newLead.Company = 'Test Lead - Referral Partner';
        newLead.LastName = 'TestReferralPartner';
        newLead.Referral_Comments__c = 'Referral Comments';
        newLead.Estimated_Annual_Billing__c = 250000;
		newLead.Phone = TestFactory.nextPhoneNumber();
        insert newLead;

        List<Referral_Partner__c> rss = [SELECT Referral_Partner__c,Comments__c FROM Referral_Partner__c WHERE Lead__c = :newLead.Id];

        Test.startTest();

        Database.LeadConvertResult lcr = LeadConvert.convert(newLead.Id, false);
        System.assert(lcr.isSuccess(), 'Lead conversion failed');

        Test.stopTest();

        Id idAccount = lcr.getAccountId();

        Account newAccount = [SELECT Id, Name, RecordType.Name, Referral_Partner_Status__c, Commission_Rate__c, Commission_Type__c FROM Account WHERE Id = :idAccount];
        Assert.areEqual('Referral Partner', newAccount.RecordType.Name, 'Converted RP lead account should be of record type "Referral Partner"');
        Assert.areEqual('Pending', newAccount.Referral_Partner_Status__c, 'Converted RP lead account should be "Pending"');

        rss = [
            SELECT Commission_Rate__c, Referral_Partner_Commission_Type__c
            FROM Referral_Partner__c
            WHERE Referral_Partner__c = :idAccount
        ];

        Assert.areEqual(0, rss.size(), 'A Referral Source should not have been created');
    }

    /**
     * test_LeadConvertToReferralPartnerAndActivate creates and converts a Referral Partner Lead,
     * then activated the Referral Partner
     */
    @IsTest
    static void test_LeadConvertToReferralPartnerAndActivate() {
        Account newAccount;
        Account branch = TestFactoryAccount.createBranch('TESTBRANCH', '911', 'area.manager@bbsi.zzz', 'area.manager@bbsi.zzz');

        Lead newLead = new Lead();
        newLead.RecordTypeId = RecordTypeService.getId('Lead', 'Referral_Partner_Lead');
        newLead.Branch__c = branch.Id;
        newLead.Company = 'Test Lead - Referral Partner';
        newLead.LastName = 'TestReferralPartner';
        newLead.Referral_Comments__c = 'Referral Comments';
        newLead.Estimated_Annual_Billing__c = 320000;
		newLead.Phone = TestFactory.nextPhoneNumber();
        insert newLead;

        List<Referral_Partner__c> rss = [SELECT Referral_Partner__c,Comments__c FROM Referral_Partner__c WHERE Lead__c = :newLead.Id];

        Test.startTest();

        Database.LeadConvertResult lcr = LeadConvert.convert(newLead.Id, false);
        System.assert(lcr.isSuccess(), 'Lead conversion failed');

        Id idAccount = lcr.getAccountId();

        newAccount = [SELECT Id, Name, RecordType.Name, Referral_Partner_Status__c, Commission_Rate__c, Commission_Type__c FROM Account WHERE Id = :idAccount];

        rss = [
            SELECT Commission_Rate__c, Referral_Partner_Commission_Type__c
            FROM Referral_Partner__c
            WHERE Referral_Partner__c = :idAccount
        ];

        Assert.areEqual(0, rss.size(), 'A Referral Source should not have been created');

        newAccount.Referral_Partner_Status__c = 'Active';
        newAccount.Commission_Rate__c = 9.87;
        newAccount.Commission_Type__c = '% of Margin';
        update newAccount;

        Test.stopTest();

        newAccount = [SELECT Id, Name, RecordType.Name, Referral_Partner_Status__c, Commission_Rate__c, Commission_Type__c FROM Account WHERE Id = :idAccount];
        Assert.areEqual('Referral Partner', newAccount.RecordType.Name, 'Converted RP lead account should be of record type "Referral Partner"');
        Assert.areEqual('Active', newAccount.Referral_Partner_Status__c, 'Converted RP lead account should be "Acitve"');

        rss = [
            SELECT Commission_Rate__c, Referral_Partner_Commission_Type__c
            FROM Referral_Partner__c
            WHERE Referral_Partner__c = :idAccount
        ];

        Assert.areEqual(1, rss.size(), 'A Referral Source should have been created');
        Referral_Partner__c rs = rss.get(0);
        Assert.areEqual(newAccount.Commission_Type__c, rs.Referral_Partner_Commission_Type__c, 'Referral Source should have same rate as Referral Partner');
        Assert.areEqual(newAccount.Commission_Rate__c, rs.Commission_Rate__c, 'Referral Source should have same rate as Referral Partner');
    }

}