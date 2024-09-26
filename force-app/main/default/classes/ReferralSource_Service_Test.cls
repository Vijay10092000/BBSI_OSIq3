/**
 * @description ReferralSource_Service_Test contains test for the
 * ReferralSource_Service class.
 */
@IsTest
@SuppressWarnings('PMD.ApexAssertionsShouldIncludeMessage')
public without sharing class ReferralSource_Service_Test {

    private static final String RT_LEAD_CLIENT = 'Client Lead';

    private static final String NAME_LEAD_11 = 'ONE-ONE';
    private static final String NAME_LEAD_12 = 'ONE-TWO';
    private static final String NAME_LEAD_21 = 'TWO-ONE';

    private static final String ADMIN_BRANCH = 'BANKS';
    private static ReferralPartner_TestEnv testEnv = new ReferralPartner_TestEnv();

    private static Referral_Partner__c rsRPCurr;
    private static Referral_Partner__c rsRPOld;
    private static Referral_Partner__c rsRPOlder;
    private static Referral_Partner__c rsClientCurr;
    private static Referral_Partner__c rsClientOld;
    private static Referral_Partner__c rsClientOlder;
    private static Lead lead11 = null;
    private static Lead lead12 = null;
    private static Lead lead21 = null;

    @TestSetup
    static void setupTests() {
        testEnv.build();

        Referral_Partner__c rsRPCurr = TestFactory.createReferralSourceReferralPartner(Date.Today().addDays(-2), null, testEnv.partner1.Id, '% of Margin', 12.3, 'RP Curr', false);
        Referral_Partner__c rsRPOld = TestFactory.createReferralSourceReferralPartner(Date.Today().addDays(-100), Date.Today().addDays(-3), testEnv.partner1.Id, '% of Margin', 5.6, 'RP Old', false);
        Referral_Partner__c rsRPOlder = TestFactory.createReferralSourceReferralPartner(Date.Today().addDays(-200), Date.Today().addDays(-99), testEnv.partner1.Id, '% of Margin', 7.8, 'RP Older', false);

        Referral_Partner__c clientCurr = TestFactory.createReferralSourceClient(Date.Today().addDays(-2), null, testEnv.client11.Id, testEnv.partner1.Id, '% of Margin', 12.3, 'Client Curr', false);
        Referral_Partner__c clientOld = TestFactory.createReferralSourceClient(Date.Today().addDays(-99), Date.Today().addDays(-1), testEnv.client11.Id, testEnv.partner1.Id, '% of Margin', 5.6, 'Client Old', false);
        Referral_Partner__c clientOlder = TestFactory.createReferralSourceClient(Date.Today().addDays(-200), Date.Today().addDays(-99), testEnv.client11.Id, testEnv.partner1.Id, '% of Margin', 7.8, 'Client Older', false);

        insert new List<Referral_Partner__c>{ rsRPCurr, rsRPOld, rsRPOlder, clientCurr, clientOld, clientOlder };

        lead11 = TestFactoryLead.makeClientLead('Client', NAME_LEAD_11, 'TestCompany11', testEnv.branch.Id, testEnv.bdm.Id);
        lead11.Referral_Partner__c = testEnv.partner1.Id;
        lead11.Producer__c = testEnv.producer1A.Id;
        lead12 = TestFactoryLead.makeClientLead('Client', NAME_LEAD_12, 'TestCompany12', testEnv.branch.Id, testEnv.bdm.Id);
        lead12.Referral_Partner__c = testEnv.partner1.Id;
        lead12.Producer__c = testEnv.producer1B.Id;
        lead12.Status = 'Unqualified';
		lead12.Lead_Stage__c = 'Dead';
        lead12.Unqualified_Reason__c = 'Because I said so.';
        lead21 = TestFactoryLead.makeClientLead('Client', NAME_LEAD_21, 'TestCompany21', testEnv.branch.Id, testEnv.bdm.Id);
        lead21.Referral_Partner__c = testEnv.partner2.Id;
        lead21.Producer__c = testEnv.producer2.Id;
        insert new List<Lead>{ lead11, lead12, lead21 };
    }

    static void getData() {
        testEnv.read();

        for (Referral_Partner__c rp : [SELECT Id, Account__c, Branch__c, Comments__c, Commission_Rate__c,
                                            Referral_Partner_Commission_Type__c, DBA_Name__c, Effective_Date__c,
                                            Last_Referral_Date__c, Lead__c, Opportunity__c, OwnerId,
                                            Producer__c, RecordTypeId, Referral_Partner__c, Referral_Partner_ID__c,
                                            Termination_Date__c
                                        FROM Referral_Partner__c]) {
            switch on rp.Comments__c {
                when 'RP Curr' { rsRPCurr = rp; }
                when 'RP Old' { rsRPOld = rp; }
                when 'RP Older' { rsRPOlder = rp; }
                when 'Client Curr' { rsClientCurr = rp; }
                when 'Client Old' { rsClientOld = rp; }
                when 'Client Older' { rsClientOlder = rp; }
            }
        }

        for (Lead l : [SELECT Id, LastName FROM Lead]) {
            if (l.LastName == NAME_LEAD_11) { Lead11 = l; }
            else if (l.LastName == NAME_LEAD_12) { Lead12 = l; }
            else if (l.LastName == NAME_LEAD_21) { Lead21 = l; }
        }
    }

    @IsTest
    static void testCreateReferralSourceLead() {
        getData();

        Test.startTest();
		
        Lead lead = TestFactoryLead.createClientLead('TEST', 'Testman', 'TestCompany', testEnv.branch.Id, testEnv.bdm.Id);
        lead.Referral_Partner__c = testEnv.partner1.Id;

        Referral_Partner__c rs = ReferralSource_Service.createReferralSourceLead(lead.Id, null, testEnv.partner1.Id, 'Test Referral');

        Test.stopTest();

        System.assertEquals(lead.Id, rs.Lead__c, 'Referral Source for Lead should have the Lead Id');
        System.assertEquals(null, rs.Producer__c, 'Referral Source for Lead has no Producer');
        System.assertEquals(testEnv.partner1.Id, rs.Referral_Partner__c, 'Referral Source for Lead was created for Partner 1');
        System.assertNotEquals(null, rs.Effective_Date__c, 'Effective Date should have been set');
    }

    @SuppressWarnings('PMD.AvoidHardcodingId')
    @IsTest
    static void testcreateReferralSourceForProspect_1() {
        Id idFakeContact = '0035000002vHpz8AAC';
        Id idFakeProspect = '0015000000zvXMaAAM';

        Account prospect = TestFactoryAccount.makeProspect('TEST_PROSPECT');
        prospect.Id = idFakeProspect;
        prospect.Producer__c = idFakeContact;

        Test.startTest();

        Referral_Partner__c referralSource = ReferralSource_Service.createReferralSourceForProspect(prospect, null);

        Test.stopTest();

        System.assertEquals(idFakeProspect, referralSource.Account__c, 'Account should have been set to prospect');
        System.assertEquals(System.today(), referralSource.Effective_Date__c, 'Effective date should have been set to today');
        System.assertEquals(null, referralSource.Termination_Date__c, 'Termination date should not have a value');
        System.assertEquals(idFakeContact, referralSource.Producer__c, 'Producer should have been set');
        System.assertEquals(null, referralSource.Referral_Partner__c, 'No Referral Partner given');
        System.assertEquals(null, referralSource.Commission_Rate__c, 'No Referral Partner given');
        System.assertEquals(null, referralSource.Referral_Partner_Commission_Type__c, 'No Referral Partner given');
    }

    @SuppressWarnings('PMD.AvoidHardcodingId')
    @IsTest
    static void testcreateReferralSourceForProspect_2() {
        Id idFakeContact = '0035000002vHpz8AAC';
        Id idFakeProspect = '0015000000zvXMaAAM';
        Id idFakeRP = '00150000017bIABAA2';

        Account referralPartner = TestFactoryAccount.makeReferralPartner('TEST_RP', '% of Margin', 12.3, null);
        referralPartner.Id = idFakeRP;

        Account prospect = TestFactoryAccount.makeProspect('TEST_PROSPECT');
        prospect.Id = idFakeProspect;
        prospect.Producer__c = idFakeContact;

        Test.startTest();

        Referral_Partner__c referralSource = ReferralSource_Service.createReferralSourceForProspect(prospect, referralPartner);

        Test.stopTest();

        System.assertEquals(idFakeProspect, referralSource.Account__c, 'Account should have been set to prospect');
        System.assertEquals(System.today(), referralSource.Effective_Date__c, 'Effective date should have been set to today');
        System.assertEquals(null, referralSource.Termination_Date__c, 'Termination date should not have a value');
        System.assertEquals(idFakeContact, referralSource.Producer__c, 'Producer should have been set');
        System.assertEquals(idFakeRP, referralSource.Referral_Partner__c, 'Referral Partner should have been set');
        System.assertEquals(12.3, referralSource.Commission_Rate__c, 'Commission Rate should have been set');
        System.assertEquals('% of Margin', referralSource.Referral_Partner_Commission_Type__c, 'Commission Type should have been set');
    }

    @IsTest
    static void testCreateReferralSource() {
        getData();

        Test.startTest();

        Account client = TestFactoryAccount.makeClient('TEST_CLIENT');
        client.BillingPostalCode = '98683';
        client.Average_Monthly_Bill__c = 50;
        client.Branch__c = ADMIN_BRANCH;
        insert client;

        Referral_Partner__c rs = ReferralSource_Service.createReferralSource(client.Id, (Id) null, testEnv.partner1.Id, Date.today(), '% of Margin', 1.23, 'Test Referral');

        Test.stopTest();

        System.assertEquals(client.Id, rs.Account__c, 'Referral Source should relate to the Client.');
        System.assertEquals(testEnv.partner1.Id, rs.Referral_Partner__c, 'Referral Partner should be the partner1.');
        System.assertEquals('Test Referral', rs.Comments__c, 'Comment should match the created Referral Source.');
        System.assertNotEquals(null, rs.Effective_Date__c, 'The Effective date should have been set to today.');
    }

    @IsTest
    static void testGetReferralPartnerSources() {
        getData();

        Set<Id> ids = new Set<Id>{ rsRPCurr.Id, rsClientCurr.Id };

        Test.startTest();
        Map<Id, Referral_Partner__c> rss = ReferralSource_Service.getReferralPartnerSources(ids);
        Test.stopTest();

        System.assertEquals(2, rss.size(), 'Start with 2 Referral Sources');
        System.assertEquals(true, rss.containsKey(rsRPCurr.Id), 'Should be a Referral Source for the Referral Parnter.');
        System.assertEquals('RP Curr', rss.get(rsRPCurr.Id).Comments__c, 'Confirm the Referral Partner comment.');
        System.assertEquals(true, rss.containsKey(rsClientCurr.Id), 'Should be a Referral Source for the Client.');
        System.assertEquals('Client Curr', rss.get(rsClientCurr.Id).Comments__c, 'Confirm the Clinet comment.');
    }

    @IsTest
    static void testGetAccountReferralSources() {
        getData();

        Set<Id> idAccounts = new Set<Id>{
            testEnv.partner1.Id,
            testEnv.partner2.Id,
            testEnv.client10.Id,
            testEnv.client11.Id
        };

        Test.startTest();
        Map<Id, List<Referral_Partner__c>> sources = ReferralSource_Service.getAccountReferralSources(idAccounts);
        Test.stopTest();

        System.assertEquals(5, sources.size(), 'There should be 5 created.');
    }

    @IsTest
    static void testSortReferralSources() {
        Date today = Date.today();
        Date date4YearsAgo = today.addYears(-4);
        Date date3YearsAgo = today.addYears(-3);
        Date date2YearsAgo = today.addYears(-2);
        Date date1YearsAgo = today.addYears(-1);
        Date date1YearsAhead = today.addYears(1);

        Referral_Partner__c rs1 = TestFactory.createReferralSourceReferralPartner(null, date4YearsAgo, null, '% of Margin', 12.3, 'RP Curr', false);
        Referral_Partner__c rs2 = TestFactory.createReferralSourceReferralPartner(date4YearsAgo, date3YearsAgo, null, '% of Margin', 12.3, 'RP Curr', false);
        Referral_Partner__c rs3 = TestFactory.createReferralSourceReferralPartner(date3YearsAgo, date2YearsAgo, null, '% of Margin', 12.3, 'RP Curr', false);
        Referral_Partner__c rs4 = TestFactory.createReferralSourceReferralPartner(date2YearsAgo, date1YearsAgo, null, '% of Margin', 12.3, 'RP Curr', false);
        Referral_Partner__c rs5 = TestFactory.createReferralSourceReferralPartner(date1YearsAgo, date1YearsAhead, null, '% of Margin', 12.3, 'RP Curr', false);
        Referral_Partner__c rs6 = TestFactory.createReferralSourceReferralPartner(date1YearsAhead, null, null, '% of Margin', 12.3, 'RP Curr', false);

        List<Referral_Partner__c> sortedRPs;
        List<Referral_Partner__c> rps;

        // No gap
        rps = new List<Referral_Partner__c>{ rs3, rs1, rs6, rs4, rs5, rs2 };
        sortedRPs = ReferralSource_Service.sortReferralSources(rps);
        System.assertEquals(rs1, sortedRPs.get(0), 'RS1 should be first.');
        System.assertEquals(rs2, sortedRPs.get(1), 'RS1 should be second.');
        System.assertEquals(rs3, sortedRPs.get(2), 'RS1 should be third.');
        System.assertEquals(rs4, sortedRPs.get(3), 'RS1 should be fourth.');
        System.assertEquals(rs5, sortedRPs.get(4), 'RS1 should be fifth.');

        // Gaps
        rps = new List<Referral_Partner__c>{ rs5, rs6, rs1, rs3 };
        sortedRPs = ReferralSource_Service.sortReferralSources(rps);
        System.assertEquals(rs1, sortedRPs.get(0), 'RS1 should be first.');
        System.assertEquals(rs3, sortedRPs.get(1), 'RS3 should be second.');
        System.assertEquals(rs5, sortedRPs.get(2), 'RS5 should be third.');
        System.assertEquals(rs6, sortedRPs.get(3), 'RS6 should be fourth.');
    }

    @isTest
    public static void testGetActiveLeadReferralSources_Insert() {
        getData();

        Test.startTest();
        Set<Id> idLeads = new Set<Id>{ lead11.Id, lead12.Id, lead21.Id };
        Map<Id, List<Referral_Partner__c>> mapRSs = ReferralSource_Service.getActiveLeadReferralSources(idLeads);
        Test.stopTest();

        System.assertEquals(3, mapRSs.size(), 'There are 3 leads which should have entries in mapRSs.');
        List<Referral_Partner__c> rss;

        rss = mapRSs.get(lead11.Id);
        System.assertEquals(1, rss.size(), 'lead11 has one Referral Source.');
        System.assertEquals(testEnv.partner1.Id, rss.get(0).Referral_Partner__c, 'lead1 is related to Referral Partner partner1.');
        System.assertEquals(testEnv.producer1A.Id, rss.get(0).Producer__c, 'lead1 is related to Referral Partner producer1A.');

        rss = mapRSs.get(lead12.Id);
        System.assertEquals(0, rss.size(), 'lead12 has no Referral Source.');

        rss = mapRSs.get(lead21.Id);
        System.assertEquals(1, rss.size(), 'lead21 has one Referral Source.');
        System.assertEquals(testEnv.partner2.Id, rss.get(0).Referral_Partner__c, 'lead1 is related to Referral Partner partner2.');
        System.assertEquals(testEnv.producer2.Id, rss.get(0).Producer__c, 'lead1 is related to Referral Partner producer2.');
    }

    @isTest
    public static void testUpdateLeadReferralSources_Update() {
        getData();

        Test.startTest();
        lead11.Producer__c = testEnv.producer1B.Id;

        lead21.Referral_Partner__c = testEnv.partner1.Id;
        lead21.Producer__c = testEnv.producer1B.Id;

        update new List<Lead>{ lead11, lead21 };
        Test.stopTest();

        Set<Id> idLeads = new Set<Id>{ lead11.Id, lead12.Id, lead21.Id };
        Map<Id, List<Referral_Partner__c>> mapRSs = ReferralSource_Service.getActiveLeadReferralSources(idLeads);
        System.assertEquals(3, mapRSs.keySet().size(), 'Each Lead in getActiveLeadReferralSources request should have an entry in the mapRSs.');

        List<Referral_Partner__c> rss;

        rss = mapRSs.get(lead11.Id);
        System.assertEquals(1, rss.size(), 'Lead11 should have 1 Referral Source');
        System.assertEquals(testEnv.partner1.Id, rss.get(0).Referral_Partner__c, 'Lead11 should have partner1 as its Referral Partner');
        System.assertEquals(testEnv.producer1B.Id, rss.get(0).Producer__c, 'Lead11 should have producer1B as its Producer');

        rss = mapRSs.get(lead12.Id);
        System.assertEquals(0, rss.size(), 'Lead12 should have no Referral Sources');

        rss = mapRSs.get(lead21.Id);
        rss = mapRSs.get(lead21.Id);
        System.assertEquals(1, rss.size(), 'Lead21 should have 1 Referral Source');
        System.assertEquals(testEnv.partner1.Id, rss.get(0).Referral_Partner__c, 'Lead21 should have partner1 as its Referral Partner');
        System.assertEquals(testEnv.producer1B.Id, rss.get(0).Producer__c, 'Lead11 should have producer1B as its Producer');
    }

    @isTest
    public static void testTerminateRelatedReferralSources() {
        getData();

        // build Referral sources for client11 and partner 2

        List<Referral_Partner__c> rss;

        rss = [
            SELECT Id
            FROM Referral_Partner__c
            WHERE Termination_Date__c = null
            AND Account__c = null
            AND Referral_Partner__c = :testEnv.partner1.Id
        ];
        System.assertEquals(2, rss.size(), 'Confirm before state, partner1 has 2 active Referral Sources.');

        rss = [
            SELECT Id
            FROM Referral_Partner__c
            WHERE Termination_Date__c = null
            AND Account__c = null
            AND Referral_Partner__c = :testEnv.partner2.Id
        ];
        System.assertEquals(1, rss.size(), 'Confirm before state, partner2 has 1 active Referral Source.');

        rss = [
            SELECT Id
            FROM Referral_Partner__c
            WHERE Termination_Date__c = null
            AND Account__c = :testEnv.client11.Id
        ];
        System.assertEquals(1, rss.size(), 'Confirm before state, client11 has 1 active Referral Source.');

        Map<Id, Account> terminated = new Map<Id, Account>();

        terminated.put(testEnv.partner2.Id, testEnv.partner2);
        terminated.put(testEnv.client11.Id, testEnv.client11);

        Test.startTest();

        ReferralSource_Service.terminateRelatedReferralSources(terminated);

        Test.stopTest();

        rss = [
            SELECT Id
            FROM Referral_Partner__c
            WHERE Termination_Date__c = null
            AND Account__c = null
            AND Referral_Partner__c = :testEnv.partner1.Id
        ];
        System.assertEquals(2, rss.size(), 'partner1 is unchanged.');

        rss = [
            SELECT Id
            FROM Referral_Partner__c
            WHERE Termination_Date__c = null
            AND Account__c = null
            AND Referral_Partner__c = :testEnv.partner2.Id
        ];
        System.assertEquals(0, rss.size(), 'partner2 has not active Referral Sources.');

        rss = [
            SELECT Id
            FROM Referral_Partner__c
            WHERE Termination_Date__c = null
            AND Account__c = :testEnv.client11.Id
        ];
        System.assertEquals(0, rss.size(), 'client11 has not active Referral Sources.');
    }

    @IsTest
    static void test_ClientPendingToActive() {
        getData();

        Test.startTest();

        Date dateChange = Date.today().addDays(-7);
        Referral_Partner_Change_Request__c rpcr = new Referral_Partner_Change_Request__c(
            RecordTypeId = ReferralPartnerChange_Const.idrtCommissionChangeRP,
            Client__c = null,
            Referral_Partner__c = testEnv.partner1.Id,
            Commission_Type__c = '% of Margin',
            Commission_Rate__c = 4.32,
            Effective_Date__c = dateChange,
            Comments__c = 'Referral Source for partner1',
            Status__c = 'Approved', 
            Product_Line__c = ReferralPartnerChange_Const.PLTYPE_WORKERSCOMP
        );

        List<Referral_Partner_Change_Request__c> rpcrs = new List<Referral_Partner_Change_Request__c>{ rpcr };
        insert rpcrs;

        Map<Id, List<Referral_Partner__c>> mapRss;
        mapRSs = ReferralSource_Service.getActiveAccountReferralSources(new Set<Id>{ testEnv.partner1.Id, testEnv.client13.Id });
        delete mapRSs.get(testEnv.client13.Id).get(0);
        mapRSs.get(testEnv.client13.Id).remove(0);
        System.assertEquals(0, mapRSs.get(testEnv.partner1.Id).size(), 'partner1 should have one Referral Sources');
        System.assertEquals(0, mapRSs.get(testEnv.client13.Id).size(), 'client13 should have no Referral Sources');
        System.assertEquals(testEnv.partner1.Id, testEnv.client13.Assigned_Referral_Partner__c, 'client13 belongs to partner1');

        testEnv.client13.Status__c = 'Active';
        update testEnv.client13;

        Test.stopTest();

        mapRSs = ReferralSource_Service.getActiveAccountReferralSources(new Set<Id>{ testEnv.client13.Id });
        System.assertEquals(0, mapRSs.get(testEnv.client13.Id).size(), 'client13 should have one Referral Sources');

       /* ReferralPartner_TestEnv.assertReferralSource(
            'New Client', mapRSs.get(testEnv.client13.Id).get(0), testEnv.client13.Id, testEnv.partner1.Id, false, false, null,
            false, '% of Margin', 4.32, System.Today(), (Date) null);
*/
    }

    @IsTest
    public static void test_queryRelatedLeads() {
        getData();

        Test.startTest();

        Lead leadNotConverted = TestFactoryLead.makeClientLead('TEST', 'NotConverted', 'NotConvertedLead', testEnv.branch.Id, testEnv.bdm.Id);
		leadNotConverted.Status = 'Qualified';
		leadNotConverted.Lead_Stage__c = 'Nurture';

        Lead leadConverted = TestFactoryLead.makeClientLead('TEST', 'Converted', 'ConvertedLead', testEnv.branch.Id, testEnv.bdm.Id);
		leadConverted.Status = 'Qualified';
		leadConverted.Lead_Stage__c = 'Nurture';
        leadConverted.Estimated_Annual_Billing__c = 500000;

        insert new List<Lead>{ leadNotConverted, leadConverted };

        Database.LeadConvertResult lcr = LeadConvert.convert(leadConverted.Id, true);
        System.assert(lcr.isSuccess(), 'Lead conversion failed');

        leadNotConverted = [SELECT Id, Name, ConvertedAccountId FROM Lead WHERE Id = :leadNotConverted.Id];
        leadConverted = [SELECT Id, Name, ConvertedAccountId FROM Lead WHERE Id = :leadConverted.Id];

        Set<Id> idLeads = new Set<Id>();
        Set<Id> idAccounts = new Set<Id>();

        List<Lead> leadsBothNull = ReferralSource_Service.queryRelatedLeads(null, null);
        List<Lead> leadsBothEmpty = ReferralSource_Service.queryRelatedLeads(idLeads, idAccounts);

        idLeads.add(leadNotConverted.Id);
        List<Lead> leadsHasLead = ReferralSource_Service.queryRelatedLeads(idLeads, idAccounts);

        idLeads.clear();
        idAccounts.add(leadConverted.ConvertedAccountId);
        List<Lead> leadsHasAccount = ReferralSource_Service.queryRelatedLeads(idLeads, idAccounts);

        idLeads.add(leadNotConverted.Id);
        List<Lead> leadsHasBoth = ReferralSource_Service.queryRelatedLeads(idLeads, idAccounts);

        Test.stopTest();

        System.assertEquals(0, leadsBothNull.size(), 'No leads should have been found.');
        System.assertEquals(0, leadsBothEmpty.size(), 'No leads should have been found.');
        System.assertEquals(1, leadsHasLead.size(), 'A lead should have been found');
        System.assertEquals(leadNotConverted.Id, leadsHasLead[0].Id, 'Should be the not converted lead');
        System.assertEquals(1, leadsHasAccount.size(), 'A lead should have been found');
        System.assertEquals(leadNotConverted.Id, leadsHasLead[0].Id, 'Should be the not converted lead');
        System.assertEquals(2, leadsHasBoth.size(), 'Two leads should have been found');
    }

    @IsTest
    public static void test_getConvertedAccounts() {
        getData();

        Test.startTest();

        Lead leadNotConverted = TestFactoryLead.makeClientLead('TEST', 'NotConverted', 'NotConvertedLead', testEnv.branch.Id, testEnv.bdm.Id);
		leadNotConverted.Status = 'Qualified';
		leadNotConverted.Lead_Stage__c = 'Nurture';

        Lead leadConverted = TestFactoryLead.makeClientLead('TEST', 'Converted', 'ConvertedLead', testEnv.branch.Id, testEnv.bdm.Id);
		leadConverted.Status = 'Qualified';
		leadConverted.Lead_Stage__c = 'Nurture';
        leadConverted.Estimated_Annual_Billing__c = 500000;

        insert new List<Lead>{ leadNotConverted, leadConverted };

        Database.LeadConvertResult lcr = LeadConvert.convert(leadConverted.Id, true);
        System.assert(lcr.isSuccess(), 'Lead conversion failed');

        leadNotConverted = [SELECT Id, Name, ConvertedAccountId FROM Lead WHERE Id = :leadNotConverted.Id];
        leadConverted = [SELECT Id, Name, ConvertedAccountId FROM Lead WHERE Id = :leadConverted.Id];
        List<Lead> leads = new List<Lead>{ leadNotConverted, leadConverted };

        Map<Id, Account> mapAccounts = ReferralSource_Service.getConvertedAccounts(leads);

        Test.stopTest();

        System.assertEquals(1, mapAccounts.keySet().size(), 'Only Converted should be found.');
        System.assert(mapAccounts.keySet().contains(leadConverted.Id), 'Should contains lead converted.');
        System.assertEquals(leadConverted.ConvertedAccountId, mapAccounts.get(leadConverted.Id).Id, 'Confirm account Id.');
    }

    /**
     * @description test_getReferralPartners
     */
    @IsTest
    public static void test_getReferralPartners() {
        getData();

        List<Account> clients = new List<Account>{
            testEnv.client10,
            testEnv.client11,
            testEnv.client13,
            testEnv.client21
        };

        Test.startTest();
        Map<Id, Account> rps = ReferralSource_Service.getReferralPartners(clients);
        Test.stopTest();

        System.assertEquals(4, rps.size(), 'Should have a key for each client with a Referral Partner');
        System.assertEquals(testEnv.partner1.Id, rps.get(testEnv.client10.Id).Id, 'Client10 has partner1 as Referral Partner');
        System.assertEquals(testEnv.partner1.Id, rps.get(testEnv.client11.Id).Id, 'Client11 has partner1 as Referral Partner');
        System.assertEquals(testEnv.partner1.Id, rps.get(testEnv.client13.Id).Id, 'Client13 has partner1 as Referral Partner');
        System.assertEquals(testEnv.partner2.Id, rps.get(testEnv.client21.Id).Id, 'Client21 has partner2 as Referral Partner');
    }

    /**
     * @description test_createReferralSourceForClient
     */
    @IsTest
    public static void test_createReferralSourceForClient() {
        getData();

        Test.startTest();

        Account client = TestFactoryAccount.createClient('TEST_CLIENT', testEnv.partner1.Id, testEnv.producer1A.Id, '% of WC Eligible Payroll', 1.11);

        Referral_Partner__c rs = ReferralSource_Service.createReferralSourceForClient(client, testEnv.partner1);

        Test.stopTest();

        Id idRecordType = RecordTypeService.getId('Referral_Partner__c', 'Client_Referral_Partner');

        System.assertEquals(idRecordType, rs.RecordTypeId);
        System.assertEquals(client.Id, rs.Account__c);
        System.assertEquals(testEnv.partner1.Commission_Rate__c, rs.Commission_Rate__c);
        System.assertEquals(testEnv.partner1.Commission_Type__c, rs.Referral_Partner_Commission_Type__c);
        System.assertNotEquals(null, rs.Effective_Date__c);
        System.assertEquals(client.Producer__c, rs.Producer__c);
        System.assertEquals(testEnv.partner1.Id, rs.Referral_Partner__c);
        System.assertEquals(null, rs.Termination_Date__c);
    }
}