/**
 * ReferralPartnerGroup_Service_Test contains test for the
 * ReferralPartnerGroup_Service class.
 */
@IsTest
public without sharing class ReferralPartnerGroup_Service_Test {
    
    private static ReferralPartner_TestEnv testEnv = new ReferralPartner_TestEnv();

    @TestSetup
    public static void makeData() {
        testEnv.build();
    }

    public static void getData() {
        testEnv.read();
    }
    
    /**
     * testTriggerHandler performs a quick run through of all the 
     * Trigger events.
     */
    @IsTest
    public static void testTriggerHandler() {
        Referral_Partner_Group__c rpGroup = TestFactoryReferralPartnerGroup.makeReferralPartnerGroup('Test Group', 'Test Group', '% of WC Eligible Payroll', 1.11);

        insert rpGroup;
        rpGroup = [SELECT Id, Name, Description__c FROM Referral_Partner_Group__c WHERE Id = :rpGroup.Id];
        Assert.areNotEqual(null, rpGroup, 'Retrieved Referral Partner Group.');
        Assert.areEqual('Test Group', rpGroup.Description__c, 'Correct Referral Partner Group.');

        rpGroup.Description__c = 'Update Description';
        update rpGroup;
        rpGroup = [SELECT Id, Name, Description__c FROM Referral_Partner_Group__c WHERE Id = :rpGroup.Id];
        Assert.areNotEqual(null, rpGroup, 'Retrieved Referral Partner Group.');
        Assert.areEqual('Update Description', rpGroup.Description__c, 'Description Changed.');

        delete rpGroup;
        Map<Id, Referral_Partner_Group__c> groups = new Map<Id, Referral_Partner_Group__c>( [ SELECT Id, Name, Description__c FROM Referral_Partner_Group__c WHERE Id = :rpGroup.Id] );
        Assert.areEqual(0, groups.size(), 'Referral Partner Group is now deleted.');

        undelete rpGroup;
        rpGroup = [SELECT Id, Name, Description__c FROM Referral_Partner_Group__c WHERE Id = :rpGroup.Id];
        Assert.areNotEqual(null, rpGroup, 'Referral Partner Group is now restored.');
        Assert.areEqual('Update Description', rpGroup.Description__c, 'Check Description on Referral Partner Group');
    }

    @IsTest 
    public static void testGetRelatedReferralPartners() {
        getData();

        Set<Id> idGroups = new Set<Id>{ 
            testEnv.group1.Id, 
            testEnv.group2.Id, 
            testEnv.group3.Id
        };

        Test.startTest();        
        Map<Id, List<Account>> withInactive = ReferralPartnerGroup_Service.getRelatedReferralPartners(idGroups, true);
        Map<Id, List<Account>> onlyActive = ReferralPartnerGroup_Service.getRelatedReferralPartners(idGroups, false);
        Test.stopTest();

        Assert.areEqual(3, withInactive.size(), 'Data for 3 groups was requested.');
        Assert.areEqual(2, withInactive.get(testEnv.group1.Id).size(), 'Should be active/inactive Referral Partners for group1.');
        Assert.areEqual(1, withInactive.get(testEnv.group2.Id).size(), 'Should be active/inactive Referral Partners for  for group2.');
        Assert.areEqual(0, withInactive.get(testEnv.group3.Id).size(), 'Should be no Referral Partners for  for group3.');

        Assert.areEqual(3, onlyActive.size(), 'Data for 3 groups was requested.');
        Assert.areEqual(1, onlyActive.get(testEnv.group1.Id).size(), 'Should be 1 active Referral Partners for group1.');
        Assert.areEqual(1, onlyActive.get(testEnv.group2.Id).size(), 'Should be 1 active Referral Partners for group2.');
        Assert.areEqual(0, onlyActive.get(testEnv.group3.Id).size(), 'Should be no Referral Partners for group3.');
    }

    @IsTest
    public static void testGetReferralPartnerGroups() {
        getData();

        Set<Id> idGroups = new Set<Id>{ 
            testEnv.group1.Id, 
            testEnv.group2.Id, 
            testEnv.group3.Id
        };

        Test.startTest();

        Map<Id, Referral_Partner_Group__c> groups = ReferralPartnerGroup_Service.getReferralPartnerGroups(idGroups);

        Test.stopTest();

        Assert.areEqual(3, groups.size(), 'Incorrect number of groups found');
        Assert.areEqual(true, groups.containsKey(testEnv.group1.Id), 'Missing Referral Partner 1');
        Assert.areEqual(true, groups.containsKey(testEnv.group2.Id), 'Missing Referral Partner 2');
        Assert.areEqual(true, groups.containsKey(testEnv.group3.Id), 'Missing Referral Partner 3');
    }

    @IsTest
    public static void testDeleteReferralPartnerGroups_Success() {
        getData();

        Set<Id> idGroups = new Set<Id>{ 
            testEnv.group1.Id, 
            testEnv.group2.Id, 
            testEnv.group3.Id
        };

        List<Account> rps = [SELECT Id, Referral_Partner_Group__c FROM Account WHERE Referral_Partner_Group__c = :testEnv.group1.Id];
        for (Account rp : rps) {
            rp.Referral_Partner_Group__c = null;
        }
        update rps;

        Test.startTest();

        rps = [SELECT Id, Referral_Partner_Group__c FROM Account WHERE Referral_Partner_Group__c = :testEnv.group1.Id];
        Assert.areEqual(0, rps.size(), 'No members should exist in the Referral Partner Group.');

        try {
            delete testEnv.group1;
            Assert.isTrue(true, 'Group 1 is empty, so no Exception should have been thrown.');
        }
        catch (Exception e) {
            Assert.isTrue(false, 'Exception should NOT have been thrown.');
        }

        Test.stopTest();
    }

    @IsTest
    public static void testDeleteReferralPartnerGroups_Failure() {
        getData();

        Set<Id> idGroups = new Set<Id>{ 
            testEnv.group1.Id, 
            testEnv.group2.Id, 
            testEnv.group3.Id
        };

        Test.startTest();

        List<Account> rps = [SELECT Id, Referral_Partner_Group__c FROM Account WHERE Referral_Partner_Group__c = :testEnv.group1.Id];
        Assert.areNotEqual(0, rps.size(), 'Members should exist in the Referral Partner Group.');

        try {
            delete testEnv.group1;
            Assert.isTrue(false, 'Group 1 still has Referral Partners.  Exception should have been thrown.');
        }
        catch (Exception e) {
            Assert.isTrue(true, 'Exception thrown.');
        }

        Test.stopTest();
    }

}