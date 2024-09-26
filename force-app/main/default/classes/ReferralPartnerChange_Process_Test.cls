/**
 * ReferralPartnerChange_Process_Test contains test for the
 * ReferralPartnerChange_Process class.
 */
@SuppressWarnings('PMD.MethodNamingConventions')
@IsTest
public without sharing class ReferralPartnerChange_Process_Test {
    
    private static Set<Id> idAccounts = null;
    private static ReferralPartner_TestEnv testEnv = new ReferralPartner_TestEnv();

    @TestSetup
    static void makeData() {
        testEnv.build();
    }

    static void getData() {
        testEnv.read();

        testEnv.dumpAccounts();

        idAccounts = new Set<Id>{
            testEnv.branch.Id,
            testEnv.partner0.Id,
            testEnv.partner1.Id,
            testEnv.partner2.Id,
            testEnv.partner3.Id,
            testEnv.client10.Id,
            testEnv.client11.Id,
            testEnv.client12.Id,
            testEnv.client13.Id,
            testEnv.client21.Id,
            testEnv.client22.Id,
            testEnv.clientSplit.Id
        };
    }

    /**
     * testRetrieveRelatedData runs a test against the
     * retrieveRelatedData method
     */
    @IsTest 
    static void testRetrieveRelatedData() {
        getData();

        Referral_Partner_Change_Request__c rpcr1 = new Referral_Partner_Change_Request__c(
            RecordTypeId = ReferralPartnerChange_Const.idrtHoldClient,
            Client__c = testEnv.client11.Id,
            Referral_Partner__c = testEnv.partner1.Id,
            Override__c = false,
            Effective_Date__c = Date.today(),
            Comments__c = 'TESTING',
            Status__c = 'Approved',
            Product_Line__c = ReferralPartnerChange_Const.PLTYPE_WORKERSCOMP
        );

        Referral_Partner_Change_Request__c rpcr2 = new Referral_Partner_Change_Request__c(
            RecordTypeId = ReferralPartnerChange_Const.idrtHoldRP,
            Client__c = null,
            Referral_Partner__c = testEnv.partner2.Id,
            Override__c = false,
            Effective_Date__c = Date.today(),
            Comments__c = 'TESTING',
            Status__c = 'Approved',
            Product_Line__c = ReferralPartnerChange_Const.PLTYPE_WORKERSCOMP
        );

        List<Referral_Partner_Change_Request__c> rpcrs = new List<Referral_Partner_Change_Request__c>{ rpcr1, rpcr2 };

        Test.startTest();

        ReferralPartnerChange_Process process = new ReferralPartnerChange_Process();
        process.retrieveRelatedData(rpcrs);

        Test.stopTest();

        // Should have all Referral Partners partner1 and partner2
        Assert.areEqual(true, process.mapRpToClients.keySet().contains(testEnv.partner1.Id), 'Should have Partner 1');
        Assert.areEqual(true, process.mapRpToClients.keySet().contains(testEnv.partner2.Id), 'Should have Partner 2');
        Assert.areEqual(2, process.mapRPs.size(), 'Only have Partner 1 and Partner 2');

        // Should have all clients of partner1 and partner2
        Assert.areEqual(true, process.mapRpToClients.keySet().contains(testEnv.partner1.Id), 'Should have Partner 1');
        Assert.areEqual(true, process.mapRpToClients.keySet().contains(testEnv.partner2.Id), 'Should have Partner 2');
        Assert.areEqual(5, process.mapRpToClients.get(testEnv.partner1.Id).size(), 'Should have Partner 1 clients');
        Assert.areEqual(3, process.mapRpToClients.get(testEnv.partner2.Id).size(), 'Should have Partner 1 clients');
        Assert.areEqual(2, process.mapRpToClients.size(), 'Only have clients for Partner 1 and Partner 2');

        // 8 - partner1, partner2, and their clients
        Assert.areEqual(10, process.mapAccountToReferralSources.size(), 'Should have entries for each of the Accounts.');
        Assert.areEqual(true, process.mapAccountToReferralSources.keySet().contains(testEnv.partner1.Id), 'mapAccountToReferralSources needs an entry for partner1.');
        Assert.areEqual(true, process.mapAccountToReferralSources.keySet().contains(testEnv.partner2.Id), 'mapAccountToReferralSources needs an entry for partner2.');
        Assert.areEqual(true, process.mapAccountToReferralSources.keySet().contains(testEnv.client11.Id), 'mapAccountToReferralSources needs an entry for client11.');
        Assert.areEqual(true, process.mapAccountToReferralSources.keySet().contains(testEnv.clientSplit.Id), 'mapAccountToReferralSources needs an entry for clientSplit.');

        // 2 - partner1, partner2
        Assert.areEqual(2, process.mapRps.size(), 'Should have entries for each Referral Partner.');
        Assert.areEqual(true, process.mapRps.keySet().contains(testEnv.partner1.Id), 'mapRps needs an entry for partner1.');
        Assert.areEqual(true, process.mapRps.keySet().contains(testEnv.partner2.Id), 'mapRps needs an entry for partner2.');

        // 9 - partner1, partner2, and their clients
        Assert.areEqual(10, process.mapAccounts.size(), 'Should have entries for each Account.');
        Assert.areEqual(true, process.mapAccounts.keySet().contains(testEnv.partner1.Id), 'mapAccounts needs an entry for partner1.');
        Assert.areEqual(true, process.mapAccounts.keySet().contains(testEnv.partner2.Id), 'mapAccounts needs an entry for partner2.');
        Assert.areEqual(true, process.mapAccounts.keySet().contains(testEnv.client10.Id), 'mapAccounts needs an entry for client10.');
        Assert.areEqual(true, process.mapAccounts.keySet().contains(testEnv.client11.Id), 'mapAccounts needs an entry for client11.');
        Assert.areEqual(true, process.mapAccounts.keySet().contains(testEnv.client12.Id), 'mapAccounts needs an entry for client12.');
        Assert.areEqual(true, process.mapAccounts.keySet().contains(testEnv.client13.Id), 'mapAccounts needs an entry for client13.');
        Assert.areEqual(true, process.mapAccounts.keySet().contains(testEnv.client21.Id), 'mapAccounts needs an entry for client21.');
        Assert.areEqual(true, process.mapAccounts.keySet().contains(testEnv.client22.Id), 'mapAccounts needs an entry for client22.');
        Assert.areEqual(true, process.mapAccounts.keySet().contains(testEnv.clientSplit.Id), 'mapAccounts needs an entry for clientSplit.');
        Assert.areEqual(true, process.mapAccounts.keySet().contains(testEnv.clientPrimary.Id), 'mapAccounts needs an entry for clientPrimary.');
    }

    /**
     * testHold_ReferralPartner
     */
    @IsTest
    static void testHold_ReferralPartner() {
        getData();

        Test.startTest();

        Referral_Partner_Change_Request__c rpcr = new Referral_Partner_Change_Request__c(
            RecordTypeId = ReferralPartnerChange_Const.idrtHoldRP,
            Client__c = null,
            Referral_Partner__c = testEnv.partner2.Id,
            Override__c = false,
            Effective_Date__c = Date.today(),
            Comments__c = 'Test RP Set Hold',
            Status__c = 'Approved',
            Product_Line__c = ReferralPartnerChange_Const.PLTYPE_WORKERSCOMP
        );

        List<Referral_Partner_Change_Request__c> rpcrs = new List<Referral_Partner_Change_Request__c>{ rpcr };

        ReferralPartnerChange_Process process = new ReferralPartnerChange_Process();
        process.execute(rpcrs);

        Test.stopTest();

        Assert.areEqual(1, process.mapRPs.size(), 'Should have partner 2');
        Assert.areEqual(true, process.mapRpToClients.keySet().contains(testEnv.partner2.Id), 'partner2 is missing');

        Assert.areEqual(1, process.mapRpToClients.size(), 'Should have partner 2');
        Assert.areEqual(3, process.mapRpToClients.get(testEnv.partner2.Id).size(), 'Should have all Clients of partner2');

        Assert.areEqual(4, process.mapAccountToReferralSources.size(), 'Should have created Referral Sources for partner2, client21, client22 and clientSplit');

        Map<Id, List<Referral_Partner__c>> mapRss = ReferralSource_Service.getActiveAccountReferralSources(idAccounts);
        Assert.areEqual(0, mapRss.get(testEnv.partner2.Id).size(), 'partner2 should have 1 Referral Sources');
        List<Account> clients = process.mapRpToClients.get(testEnv.partner2.Id);
        Assert.isTrue(!clients.isEmpty(), 'Shold have clients');
        Assert.areEqual(0, mapRss.get(testEnv.client21.Id).size(), 'client21 should have 0 Referral Sources');
        Assert.areEqual(0, mapRss.get(testEnv.client22.Id).size(), 'client22 should have 0 Referral Sources');
        Assert.areEqual(2, mapRss.get(testEnv.clientSplit.Id).size(), 'clientSplit should have 2 Referral Sources');

        /*Date today = Date.today();
        List<Referral_Partner__c> rss;

        rss = mapRss.get(testEnv.client21.Id);
        ReferralPartner_TestEnv.assertReferralSource('client21 - Hold', rss.get(rss.size() - 1), testEnv.client21.Id, testEnv.partner2.Id, false, true, 'Test RP Set Hold', false, ReferralPartnerChange_Const.DEFAULTWORKCOMPTYPE, 0.00, today, (Date) null);
        Assert.areEqual(false, rss.get(rss.size() - 1).Ignore_Record__c, 'Hold should be ignored');

        rss = mapRss.get(testEnv.client22.Id);
        ReferralPartner_TestEnv.assertReferralSource('client22 - Hold', rss.get(rss.size() - 1), testEnv.client22.Id, testEnv.partner2.Id, false, true, 'Test RP Set Hold', false, ReferralPartnerChange_Const.DEFAULTWORKCOMPTYPE, 0.00, today, (Date) null);
        Assert.areEqual(false, rss.get(rss.size() - 1).Ignore_Record__c, 'Hold should be ignored');*/
    }
    /**
     * testHold_ReferralPartner_Benefits
     */
    @IsTest
    static void testHold_ReferralPartner_Benefits() {
        getData();

        Test.startTest();

        Referral_Partner_Change_Request__c rpcr = new Referral_Partner_Change_Request__c(
            RecordTypeId = ReferralPartnerChange_Const.idrtHoldRP,
            Client__c = null,
            Referral_Partner__c = testEnv.partner2.Id,
            Override__c = false,
            Effective_Date__c = Date.today(),
            Comments__c = 'Test RP Set Hold',
            Status__c = 'Approved',
            Product_Line__c = ReferralPartnerChange_Const.PLTYPE_BENEFITS
        );

        List<Referral_Partner_Change_Request__c> rpcrs = new List<Referral_Partner_Change_Request__c>{ rpcr };

        ReferralPartnerChange_Process process = new ReferralPartnerChange_Process();
        process.execute(rpcrs);

        Test.stopTest();

        Assert.areEqual(1, process.mapRPs.size(), 'Should have partner 2');
        Assert.areEqual(true, process.mapRpToClients.keySet().contains(testEnv.partner2.Id), 'partner2 is missing');

        Assert.areEqual(1, process.mapRpToClients.size(), 'Should have partner 2');
        Assert.areEqual(3, process.mapRpToClients.get(testEnv.partner2.Id).size(), 'Should have all Clients of partner2');

        Assert.areEqual(4, process.mapAccountToReferralSources.size(), 'Should have created Referral Sources for partner2, client21, client22 and clientSplit');

        Map<Id, List<Referral_Partner__c>> mapRss = ReferralSource_Service.getActiveAccountReferralSources(idAccounts);
        Assert.areEqual(0, mapRss.get(testEnv.partner2.Id).size(), 'partner2 should have 1 Referral Sources');
        Assert.areEqual(0, mapRss.get(testEnv.client21.Id).size(), 'client21 should have 0 Referral Sources');
        Assert.areEqual(0, mapRss.get(testEnv.client22.Id).size(), 'client22 should have 0 Referral Sources');
        Assert.areEqual(2, mapRss.get(testEnv.clientSplit.Id).size(), 'clientSplit should have 2 Referral Sources');

        /*Date today = Date.today();
        List<Referral_Partner__c> rss;

        rss = mapRss.get(testEnv.client21.Id);
        ReferralPartner_TestEnv.assertReferralSource('client21 - Hold', rss.get(rss.size() - 1), testEnv.client21.Id, testEnv.partner2.Id, false, true, 'Test RP Set Hold', false, ReferralPartnerChange_Const.DEFAULTWORKCOMPTYPE, 0.00, today, (Date) null);
        Assert.areEqual(false, rss.get(rss.size() - 1).Ignore_Record__c, 'Hold should be ignored');

        rss = mapRss.get(testEnv.client22.Id);
        ReferralPartner_TestEnv.assertReferralSource('client22 - Hold', rss.get(rss.size() - 1), testEnv.client22.Id, testEnv.partner2.Id, false, true, 'Test RP Set Hold', false, ReferralPartnerChange_Const.DEFAULTWORKCOMPTYPE, 0.00, today, (Date) null);
        Assert.areEqual(false, rss.get(rss.size() - 1).Ignore_Record__c, 'Hold should be ignored');*/
    }

    /**
     * testReleaseHold_ReferralPartner
     */
    @IsTest
    static void testReleaseHold_ReferralPartner() {
        getData();

        Date dateHold = Date.today().addDays(-7);
        Date dateRelease = Date.today();
        Referral_Partner_Change_Request__c rpcr;

        // Put Referral Partner on Hold
        rpcr = new Referral_Partner_Change_Request__c(
            RecordTypeId = ReferralPartnerChange_Const.idrtHoldRP,
            Client__c = null,
            Referral_Partner__c = testEnv.partner1.Id,
            Override__c = false,
            Effective_Date__c = dateHold,
            Comments__c = 'Test RP Set Hold',
            Status__c = 'Approved',
            Product_Line__c = ReferralPartnerChange_Const.PLTYPE_WORKERSCOMP
        );

        List<Referral_Partner_Change_Request__c> rpcrs = new List<Referral_Partner_Change_Request__c>{ rpcr };
        insert rpcrs;

        Test.startTest();

        // Release Hold
        rpcr = new Referral_Partner_Change_Request__c(
            RecordTypeId = ReferralPartnerChange_Const.idrtReleaseHoldRP,
            Client__c = null,
            Referral_Partner__c = testEnv.partner1.Id,
            Effective_Date__c = dateRelease,
            Comments__c = 'Test RP Release Hold',
            Status__c = 'Approved',
            Product_Line__c = ReferralPartnerChange_Const.PLTYPE_WORKERSCOMP
        );

        rpcrs = new List<Referral_Partner_Change_Request__c>{ rpcr };

        ReferralPartnerChange_Process process = new ReferralPartnerChange_Process();
        process.execute(rpcrs);

        Test.stopTest();

        Assert.areEqual(1, process.mapRPs.size(), 'Should have partner 1');
        Assert.areEqual(true, process.mapRpToClients.keySet().contains(testEnv.partner1.Id), 'partner1 is missing');

        Assert.areEqual(1, process.mapRpToClients.size(), 'Should have partner 1');
        Assert.areEqual(5, process.mapRpToClients.get(testEnv.partner1.Id).size(), 'Should have all Clients of partner1');

        Map<Id, List<Referral_Partner__c>> mapRss = ReferralSource_Service.getActiveAccountReferralSources(idAccounts);
        Assert.areEqual(0, mapRss.get(testEnv.partner1.Id).size(), 'partner1 should have 1 Active Referral Sources');
        Assert.areEqual(0, mapRss.get(testEnv.client10.Id).size(), 'client10 should have no Active Referral Sources');
        Assert.areEqual(0, mapRss.get(testEnv.client11.Id).size(), 'client11 should have 0 Active Referral Sources');
        Assert.areEqual(0, mapRss.get(testEnv.client12.Id).size(), 'client12 should have 0 Active Referral Sources');
        Assert.areEqual(0, mapRss.get(testEnv.client13.Id).size(), 'client13 should have 0 Active Referral Sources');
        Assert.areEqual(2, mapRss.get(testEnv.clientSplit.Id).size(), 'clientSplit should have 2 Active Referral Sources');

        Assert.areEqual(7, process.mapAccountToReferralSources.size(), 'Should have created Referral Sources for partner1, client 10, client11, client12, client13 and clientSplit');
        List<Referral_Partner__c> rss;

        /*rss = process.mapAccountToReferralSources.get(testEnv.client11.Id);
        ReferralPartner_TestEnv.assertReferralSource('client11 - Release', rss.get(rss.size() - 1), testEnv.client11.Id, testEnv.partner1.Id, false, false, null, false, '% of WC Eligible Payroll', 1.11, dateRelease, (Date) null);
        Assert.areEqual(false, rss.get(rss.size() - 1).Ignore_Record__c, 'Release Hold should not be ignored');

        rss = process.mapAccountToReferralSources.get(testEnv.client12.Id);
        ReferralPartner_TestEnv.assertReferralSource('client12 - Release', rss.get(rss.size() - 1), testEnv.client12.Id, testEnv.partner1.Id, false, false, null, false, '% of WC Eligible Payroll', 1.11, dateRelease, (Date) null);
        Assert.areEqual(false, rss.get(rss.size() - 1).Ignore_Record__c, 'Hold should be ignored');

        rss = process.mapAccountToReferralSources.get(testEnv.client13.Id);
        ReferralPartner_TestEnv.assertReferralSource('client13 - Release', rss.get(rss.size() - 1), testEnv.client13.Id, testEnv.partner1.Id, false, false, null, false, '% of WC Eligible Payroll', 1.11, dateRelease, (Date) null);
        Assert.areEqual(false, rss.get(rss.size() - 1).Ignore_Record__c, 'Hold should be ignored');

        rss = process.mapAccountToReferralSources.get(testEnv.clientPrimary.Id);
        ReferralPartner_TestEnv.assertReferralSource('clientPrimary - Release', rss.get(rss.size() - 1), testEnv.clientPrimary.Id, testEnv.partner1.Id, false, false, null, false, 'Price per medical participant', 0.00, dateRelease, (Date) null);
        Assert.areEqual(false, rss.get(rss.size() - 1).Ignore_Record__c, 'Hold should be ignored');*/
    }

    /**
     * testHold_Client
     */
    @IsTest 
    static void testHold_Client() {
        getData();

        Test.startTest();
        Referral_Partner_Change_Request__c rpcr = new Referral_Partner_Change_Request__c(
            RecordTypeId = ReferralPartnerChange_Const.idrtHoldClient,
            Client__c = testEnv.client11.Id,
            Referral_Partner__c = testEnv.partner1.Id,
            Override__c = false,
            Effective_Date__c = Date.today(),
            Comments__c = 'Test Client Set Hold',
            Status__c = 'Approved',
            Product_Line__c = ReferralPartnerChange_Const.PLTYPE_WORKERSCOMP
        );

        List<Referral_Partner_Change_Request__c> rpcrs = new List<Referral_Partner_Change_Request__c>{ rpcr };

        ReferralPartnerChange_Process process = new ReferralPartnerChange_Process();
        process.execute(rpcrs);

        Test.stopTest();

        Assert.areEqual(1, process.mapRPs.size(), 'Should have only partner1');
        Assert.areEqual(true, process.mapRpToClients.keySet().contains(testEnv.partner1.Id), 'partner1 is missing');

        Assert.areEqual(1, process.mapRpToClients.size(), 'Should have partner1');
        Assert.areEqual(5, process.mapRpToClients.get(testEnv.partner1.Id).size(), 'Should have all Clients of partner1');

        Assert.areEqual(true, process.mapAccountToReferralSources.containsKey(testEnv.client11.Id), 'client11 missing');
        Assert.areEqual(0, process.mapAccountToReferralSources.get(testEnv.client11.Id).size(), 'Should have not created Referral Sources for client11');

        Map<Id, List<Referral_Partner__c>> mapRss = ReferralSource_Service.getActiveAccountReferralSources(new Set<Id>{ testEnv.client11.Id });
        Assert.areEqual(0, mapRss.get(testEnv.client11.Id).size(), 'client11 should have 0 Referral Source');
        Date today = Date.today();
        List<Referral_Partner__c> rss;
        
        rss = mapRss.get(testEnv.client11.Id);
        //Referral_Partner__c rs = rss.get(rss.size() - 1);
        //ReferralPartner_TestEnv.assertReferralSource('client11 - Hold', rs, testEnv.client11.Id, testEnv.partner1.Id, true, false, 'Test Client Set Hold', false, '% of WC Eligible Payroll', 1.11, today, (Date) null);
        //Assert.areEqual(false, rs.Ignore_Record__c, 'Hold should be ignored');
    }
    /**
     * testHold_Client_Benifits
     */
    @IsTest 
    static void testHold_Client_Benifits() {    
        getData();
        
        Test.startTest();
        Referral_Partner_Change_Request__c rpcr = new Referral_Partner_Change_Request__c(
            RecordTypeId = ReferralPartnerChange_Const.idrtHoldClient,
            Client__c = testEnv.clientPrimary.Id,
            Referral_Partner__c = testEnv.partner1.Id,
            Override__c = false,
            Effective_Date__c = Date.today(),
            Comments__c = 'Test Client Set Hold',
            Status__c = 'Approved',
            Product_Line__c = ReferralPartnerChange_Const.PLTYPE_BENEFITS
        );

        List<Referral_Partner_Change_Request__c> rpcrs = new List<Referral_Partner_Change_Request__c>{ rpcr };

        ReferralPartnerChange_Process process = new ReferralPartnerChange_Process();
        process.execute(rpcrs);

        Test.stopTest();

        Assert.areEqual(1, process.mapRPs.size(), 'Should have only partner1');
        Assert.areEqual(true, process.mapRpToClients.keySet().contains(testEnv.partner1.Id), 'partner1 is missing');

        Assert.areEqual(1, process.mapRpToClients.size(), 'Should have partner1');
        Assert.areEqual(5, process.mapRpToClients.get(testEnv.partner1.Id).size(), 'Should have all Clients of partner1');

        Assert.areEqual(true, process.mapAccountToReferralSources.containsKey(testEnv.clientPrimary.Id), 'clientPrimary missing');
        Assert.areEqual(0, process.mapAccountToReferralSources.get(testEnv.clientPrimary.Id).size(), 'Should have not created Referral Sources for clientPrimary');

        /*Map<Id, List<Referral_Partner__c>> mapRss = ReferralSource_Service.getActiveAccountReferralSources(new Set<Id>{ testEnv.clientPrimary.Id });
        Assert.areEqual(1, mapRss.get(testEnv.clientPrimary.Id).size(), 'clientPrimary should have 1 Referral Source');
        Date today = Date.today();
        List<Referral_Partner__c> rss;
        
        rss = mapRss.get(testEnv.clientPrimary.Id);
        Referral_Partner__c rs = rss.get(rss.size() - 1);
        ReferralPartner_TestEnv.assertReferralSource('clientPrimary - Hold', rs, testEnv.clientPrimary.Id, testEnv.partner1.Id, true, false, 'Test Client Set Hold', false, '% of medical charges', 0.00, today, (Date) null);
        Assert.areEqual(false, rs.Ignore_Record__c, 'Hold should be ignored');*/
    }
    /**
     * testHold_Client_Benifits
     */
    @IsTest 
    static void testHold_Client_Benifits_Negative() {
        getData();

        Test.startTest();
        Referral_Partner_Change_Request__c rpcr = new Referral_Partner_Change_Request__c(
            RecordTypeId = ReferralPartnerChange_Const.idrtHoldClient,
            Client__c = testEnv.client11.Id,
            Referral_Partner__c = testEnv.partner1.Id,
            Override__c = false,
            Effective_Date__c = Date.today(),
            Comments__c = 'Test Client Set Hold',
            Status__c = 'Approved',
            Product_Line__c = ReferralPartnerChange_Const.PLTYPE_BENEFITS
        );

        List<Referral_Partner_Change_Request__c> rpcrs = new List<Referral_Partner_Change_Request__c>{ rpcr };

        ReferralPartnerChange_Process process = new ReferralPartnerChange_Process();
        string exMsg = '';
        try {
            process.execute(rpcrs);
            
        } catch (Exception ex) {
            exMsg = ex.getMessage();
        }
        Assert.isTrue(!String.isEmpty(exMsg), 'Expected message should not be empty');
        Test.stopTest();
        
    }

    /**
     * testReleaseHold_Client runs a test against the puts a Client on Hold
     * then releases the Hold.  No holds should be lefton the Client, but new
     * Referral Sources should be created.
     */
    @IsTest 
    static void testReleaseHold_Client() {
        getData();

        Date dateHold = Date.today().addDays(-7);
        Date dateRelease = Date.today();
        Referral_Partner_Change_Request__c rpcr;

        // Put Client on Hold
        rpcr = new Referral_Partner_Change_Request__c(
            RecordTypeId = ReferralPartnerChange_Const.idrtHoldClient,
            Client__c = testEnv.client11.Id,
            Referral_Partner__c = testEnv.partner1.Id,
            Override__c = false,
            Effective_Date__c = dateHold,
            Comments__c = 'Test Client Set Hold',
            Status__c = 'Approved',
            Product_Line__c = ReferralPartnerChange_Const.PLTYPE_WORKERSCOMP
        );

        List<Referral_Partner_Change_Request__c> rpcrs = new List<Referral_Partner_Change_Request__c>{ rpcr };
        insert rpcrs;

        Test.startTest();

        // Release Hold
        rpcr = new Referral_Partner_Change_Request__c(
            RecordTypeId = ReferralPartnerChange_Const.idrtReleaseHoldClient,
            Client__c = testEnv.client11.Id,
            Referral_Partner__c = testEnv.partner1.Id,
            Effective_Date__c = dateRelease,
            Comments__c = 'Test Client Release Hold',
            Status__c = 'Approved',
            Product_Line__c = ReferralPartnerChange_Const.PLTYPE_WORKERSCOMP
        );

        rpcrs = new List<Referral_Partner_Change_Request__c>{ rpcr };

        ReferralPartnerChange_Process process = new ReferralPartnerChange_Process();
        process.execute(rpcrs);

        Test.stopTest();

        getData();

        Assert.areEqual(1, process.mapRpToClients.size(), 'Should have partner1');
        Assert.areEqual(5, process.mapRpToClients.get(testEnv.partner1.Id).size(), 'Should have all Clients of partner1');

        Assert.areEqual(0, process.mapAccountToReferralSources.get(testEnv.client11.Id).size(), 'Should have created 1 Referral Sources for client11');

        Map<Id, List<Referral_Partner__c>> mapRss = ReferralSource_Service.getActiveAccountReferralSources(idAccounts);
        Assert.areEqual(0, mapRss.get(testEnv.branch.Id).size(), 'branch should have no Referral Sources');
        Assert.areEqual(0, mapRss.get(testEnv.partner0.Id).size(), 'partner0 should have no Referral Sources');
        Assert.areEqual(0, mapRss.get(testEnv.partner1.Id).size(), 'partner1 should have no Referral Sources');
        Assert.areEqual(0, mapRss.get(testEnv.partner2.Id).size(), 'partner2 should have no Referral Sources');
        Assert.areEqual(0, mapRss.get(testEnv.partner3.Id).size(), 'partner3 should have no Referral Sources');
        Assert.areEqual(0, mapRss.get(testEnv.client10.Id).size(), 'client10 should have no Referral Sources');
        Assert.areEqual(0, mapRss.get(testEnv.client11.Id).size(), 'client11 should have 0 Active Referral Sources');
        Assert.areEqual(0, mapRss.get(testEnv.client12.Id).size(), 'client12 should have no Referral Sources');
        Assert.areEqual(0, mapRss.get(testEnv.client13.Id).size(), 'client13 should have no Referral Sources');
        Assert.areEqual(0, mapRss.get(testEnv.client21.Id).size(), 'client21 should have no Referral Sources');
        Assert.areEqual(0, mapRss.get(testEnv.client22.Id).size(), 'client22 should have no Referral Sources');

        /*List<Referral_Partner__c> rss = process.mapAccountToReferralSources.get(testEnv.client11.Id);
        
        ReferralPartner_TestEnv.assertReferralSource('client11 - Hold', rss.get(0), testEnv.client11.Id, testEnv.partner1.Id, true, false, 'Test Client Set Hold', false, '% of WC Eligible Payroll', 1.11, dateHold, dateRelease.addDays(-1));
        Assert.areEqual(true, rss.get(0).Ignore_Record__c, 'Hold should be ignored');

        ReferralPartner_TestEnv.assertReferralSource('client11 - Release', rss.get(1), testEnv.client11.Id, testEnv.partner1.Id, false, false, null, false, '% of WC Eligible Payroll', 1.11, dateRelease, (Date) null);
        Assert.areEqual(true, rss.get(0).Ignore_Record__c, 'Hold should be ignored');*/
    }

    /**
     * testOverride_Client runs a test against the Client adds an Override
     * Commission on a Client.
     */
    @IsTest 
    static void testOverride_Client() {
        getData();

        Date dateOverride = Date.today().addDays(-7);
        Referral_Partner_Change_Request__c rpcr = new Referral_Partner_Change_Request__c(
            RecordTypeId = ReferralPartnerChange_Const.idrtOverrideClient,
            Client__c = testEnv.client11.Id,
            Referral_Partner__c = testEnv.partner1.Id,
            Override__c = true,
            Commission_Type__c = '% of Margin',
            Commission_Rate__c = 12.12,
            Effective_Date__c = dateOverride,
            Comments__c = 'Test Client Set Override',
            Status__c = 'Approved',
            Product_Line__c = ReferralPartnerChange_Const.PLTYPE_WORKERSCOMP
        );

        Test.startTest();
        ReferralPartnerChange_Process process = new ReferralPartnerChange_Process();
        process.execute( new List<Referral_Partner_Change_Request__c>{ rpcr } );
        Test.stopTest();

        getData();

        Assert.areEqual(1, process.mapRpToClients.size(), 'Should have partner1');
        Assert.areEqual(5, process.mapRpToClients.get(testEnv.partner1.Id).size(), 'Should have all Clients of partner1');

        Assert.areEqual(1, process.mapAccountToReferralSources.get(testEnv.client11.Id).size(), 'Should have created 1 Referral Sources for client11');

        Map<Id, List<Referral_Partner__c>> mapRss = ReferralSource_Service.getActiveAccountReferralSources(idAccounts);
        Assert.areEqual(0, mapRss.get(testEnv.branch.Id).size(), 'branch should have no Referral Sources');
        Assert.areEqual(0, mapRss.get(testEnv.partner0.Id).size(), 'partner0 should have no Referral Sources');
        Assert.areEqual(0, mapRss.get(testEnv.partner1.Id).size(), 'partner1 should have no Referral Sources');
        Assert.areEqual(0, mapRss.get(testEnv.partner2.Id).size(), 'partner2 should have no Referral Sources');
        Assert.areEqual(0, mapRss.get(testEnv.partner3.Id).size(), 'partner3 should have no Referral Sources');
        Assert.areEqual(0, mapRss.get(testEnv.client10.Id).size(), 'client10 should have no Referral Sources');
        Assert.areEqual(1, mapRss.get(testEnv.client11.Id).size(), 'client11 should have 1 Active Referral Sources');
        Assert.areEqual(0, mapRss.get(testEnv.client12.Id).size(), 'client12 should have no Referral Sources');
        Assert.areEqual(0, mapRss.get(testEnv.client13.Id).size(), 'client13 should have no Referral Sources');
        Assert.areEqual(0, mapRss.get(testEnv.client21.Id).size(), 'client21 should have no Referral Sources');
        Assert.areEqual(0, mapRss.get(testEnv.client22.Id).size(), 'client22 should have no Referral Sources');

        List<Referral_Partner__c> rss = process.mapAccountToReferralSources.get(testEnv.client11.Id);
        Assert.areEqual(1, rss.size(), 'client11 should have 1 Active Referral Sources');

        ReferralPartner_TestEnv.assertReferralSource('client11 - Set Override', rss.get(0), testEnv.client11.Id, testEnv.partner1.Id, false, false, null, true, '% of Margin', 12.12, dateOverride, null);
    }

    /**
     * testReleaseOverride_Client runs a test against the Client adds an Override
     * Commission on a Client, then releases it.
     */
    @IsTest 
    static void testReleaseOverride_Client() {
        getData();

        Date dateOverride = Date.today().addDays(-7);
        Date dateRelease = Date.today();
        Referral_Partner_Change_Request__c rpcr = new Referral_Partner_Change_Request__c(
            RecordTypeId = ReferralPartnerChange_Const.idrtOverrideClient,
            Client__c = testEnv.client11.Id,
            Referral_Partner__c = testEnv.partner1.Id,
            Override__c = true,
            Commission_Type__c = '% of Margin',
            Commission_Rate__c = 12.12,
            Effective_Date__c = dateOverride,
            Comments__c = 'Test Client Set Override',
            Status__c = 'Approved',
            Product_Line__c = ReferralPartnerChange_Const.PLTYPE_WORKERSCOMP
        );

        List<Referral_Partner_Change_Request__c> rpcrs = new List<Referral_Partner_Change_Request__c>{ rpcr };
        insert rpcrs;

        Test.startTest();
        rpcr = new Referral_Partner_Change_Request__c(
            RecordTypeId = ReferralPartnerChange_Const.idrtOverrideClient,
            Client__c = testEnv.client11.Id,
            Referral_Partner__c = testEnv.partner1.Id,
            Override__c = false,
            Commission_Type__c = '% of CES Payroll',
            Commission_Rate__c = 77.77,
            Effective_Date__c = dateRelease,
            Comments__c = 'Test Client Release Override',
            Status__c = 'Approved',
            Product_Line__c = ReferralPartnerChange_Const.PLTYPE_WORKERSCOMP
        );
        rpcrs = new List<Referral_Partner_Change_Request__c>{ rpcr };

        ReferralPartnerChange_Process process = new ReferralPartnerChange_Process();
        process.execute(rpcrs);
        Test.stopTest();

        getData();

        Assert.areEqual(1, process.mapRpToClients.size(), 'Should have partner1');
        Assert.areEqual(5, process.mapRpToClients.get(testEnv.partner1.Id).size(), 'Should have all Clients of partner1');

        Assert.areEqual(2, process.mapAccountToReferralSources.get(testEnv.client11.Id).size(), 'Should have created 2 Referral Sources for client11');

        Map<Id, List<Referral_Partner__c>> mapRss = ReferralSource_Service.getActiveAccountReferralSources(idAccounts);
        Assert.areEqual(0, mapRss.get(testEnv.branch.Id).size(), 'branch should have no Referral Sources');
        Assert.areEqual(0, mapRss.get(testEnv.partner0.Id).size(), 'partner0 should have no Referral Sources');
        Assert.areEqual(0, mapRss.get(testEnv.partner1.Id).size(), 'partner1 should have no Referral Sources');
        Assert.areEqual(0, mapRss.get(testEnv.partner2.Id).size(), 'partner2 should have no Referral Sources');
        Assert.areEqual(0, mapRss.get(testEnv.partner3.Id).size(), 'partner3 should have no Referral Sources');
        Assert.areEqual(0, mapRss.get(testEnv.client10.Id).size(), 'client10 should have no Referral Sources');
        Assert.areEqual(1, mapRss.get(testEnv.client11.Id).size(), 'client11 should have 1 Active Referral Sources');
        Assert.areEqual(0, mapRss.get(testEnv.client12.Id).size(), 'client12 should have no Referral Sources');
        Assert.areEqual(0, mapRss.get(testEnv.client13.Id).size(), 'client13 should have no Referral Sources');
        Assert.areEqual(0, mapRss.get(testEnv.client21.Id).size(), 'client21 should have no Referral Sources');
        Assert.areEqual(0, mapRss.get(testEnv.client22.Id).size(), 'client22 should have no Referral Sources');

        List<Referral_Partner__c> rss = process.mapAccountToReferralSources.get(testEnv.client11.Id);
        
        ReferralPartner_TestEnv.assertReferralSource('client11 - Override', rss.get(0), testEnv.client11.Id, testEnv.partner1.Id, false, false, null, true, '% of Margin', 12.12, dateOverride, dateRelease.addDays(-1));

        ReferralPartner_TestEnv.assertReferralSource('client11 - Release Override', rss.get(1), testEnv.client11.Id, testEnv.partner1.Id, false, false, null, false, '% of WC Eligible Payroll', 1.11, dateRelease, (Date) null);
    }

    /**
     * testReleaseOverride_Client2 runs a test against the Client adds an Override
     * Commission on a Client, then releases by re-overriding to default values.
     */
    @IsTest 
    static void testReleaseOverride_Client2() {
        getData();

        //RPC: Get default values
        String defaultType = testEnv.client11.Commission_Type__c;
        Decimal defaultRate = testEnv.client11.Commission_Rate__c;

        Date dateOverride = Date.today().addDays(-7);
        Date dateRelease = Date.today();
        Referral_Partner_Change_Request__c rpcr = new Referral_Partner_Change_Request__c(
            RecordTypeId = ReferralPartnerChange_Const.idrtOverrideClient,
            Client__c = testEnv.client11.Id,
            Referral_Partner__c = testEnv.partner1.Id,
            Override__c = true,
            Commission_Type__c = '% of Margin',
            Commission_Rate__c = 12.12,
            Effective_Date__c = dateOverride,
            Comments__c = 'Test Client Set Override',
            Status__c = 'Approved',
            Product_Line__c = ReferralPartnerChange_Const.PLTYPE_WORKERSCOMP
        );

        List<Referral_Partner_Change_Request__c> rpcrs = new List<Referral_Partner_Change_Request__c>{ rpcr };
        insert rpcrs;

        Test.startTest();
        rpcr = new Referral_Partner_Change_Request__c(
            RecordTypeId = ReferralPartnerChange_Const.idrtOverrideClient,
            Client__c = testEnv.client11.Id,
            Referral_Partner__c = testEnv.partner1.Id,
            Override__c = true,
            Commission_Type__c = defaultType,
            Commission_Rate__c = defaultRate,
            Effective_Date__c = dateRelease,
            Comments__c = 'Test Client Release Override',
            Status__c = 'Approved',
            Product_Line__c = ReferralPartnerChange_Const.PLTYPE_WORKERSCOMP
        );
        rpcrs = new List<Referral_Partner_Change_Request__c>{ rpcr };

        ReferralPartnerChange_Process process = new ReferralPartnerChange_Process();
        process.execute(rpcrs);
        Test.stopTest();

        getData();

        Assert.areEqual(1, process.mapRpToClients.size(), 'Should have partner1');
        Assert.areEqual(5, process.mapRpToClients.get(testEnv.partner1.Id).size(), 'Should have all Clients of partner1');

        Assert.areEqual(2, process.mapAccountToReferralSources.get(testEnv.client11.Id).size(), 'Should have created 2 Referral Sources for client11');

        Map<Id, List<Referral_Partner__c>> mapRss = ReferralSource_Service.getActiveAccountReferralSources(idAccounts);
        Assert.areEqual(0, mapRss.get(testEnv.branch.Id).size(), 'branch should have no Referral Sources');
        Assert.areEqual(0, mapRss.get(testEnv.partner0.Id).size(), 'partner0 should have no Referral Sources');
        Assert.areEqual(0, mapRss.get(testEnv.partner1.Id).size(), 'partner1 should have no Referral Sources');
        Assert.areEqual(0, mapRss.get(testEnv.partner2.Id).size(), 'partner2 should have no Referral Sources');
        Assert.areEqual(0, mapRss.get(testEnv.partner3.Id).size(), 'partner3 should have no Referral Sources');
        Assert.areEqual(0, mapRss.get(testEnv.client10.Id).size(), 'client10 should have no Referral Sources');
        Assert.areEqual(1, mapRss.get(testEnv.client11.Id).size(), 'client11 should have 1 Active Referral Sources');
        Assert.areEqual(0, mapRss.get(testEnv.client12.Id).size(), 'client12 should have no Referral Sources');
        Assert.areEqual(0, mapRss.get(testEnv.client13.Id).size(), 'client13 should have no Referral Sources');
        Assert.areEqual(0, mapRss.get(testEnv.client21.Id).size(), 'client21 should have no Referral Sources');
        Assert.areEqual(0, mapRss.get(testEnv.client22.Id).size(), 'client22 should have no Referral Sources');

        List<Referral_Partner__c> rss = process.mapAccountToReferralSources.get(testEnv.client11.Id);
        
        ReferralPartner_TestEnv.assertReferralSource('client11 - Override', rss.get(0), testEnv.client11.Id, testEnv.partner1.Id, false, false, null, true, '% of Margin', 12.12, dateOverride, dateRelease.addDays(-1));

        ReferralPartner_TestEnv.assertReferralSource('client11 - Release Override', rss.get(1), testEnv.client11.Id, testEnv.partner1.Id, false, false, null, false, '% of WC Eligible Payroll', 1.11, dateRelease, (Date) null);
    }

    /**
     * testGroupCommissionChange
     */
    @IsTest 
    static void testGroupCommissionChange() {
        getData();

        Date dateChange = Date.today();
        Referral_Partner_Change_Request__c rpcr = new Referral_Partner_Change_Request__c(
            RecordTypeId = ReferralPartnerChange_Const.idrtGroupComm,
            Client__c = null,
            Referral_Partner__c = null,
            Override__c = false,
            Referral_Partner_Group__c = testEnv.group1.Id,
            Commission_Type__c = 'Amount Per Check',
            Commission_Rate__c = 999.99,
            Effective_Date__c = dateChange,
            Comments__c = 'Test Group Commission Override',
            Status__c = 'Approved',
            Product_Line__c = ReferralPartnerChange_Const.PLTYPE_WORKERSCOMP
        );

        Test.startTest();
        insert rpcr;
        Test.stopTest();

        getData();

        List<Referral_Partner_Change_Request__c> requests;
        
        requests = [SELECT Id, RecordType.Name, Effective_Date__c, Commission_Type__c, Commission_Rate__c
            FROM Referral_Partner_Change_Request__c
            WHERE Referral_Partner_Group__c = :testEnv.group1.Id];
        
        Assert.areEqual(1, requests.size(), 'Group 1 should have only the created request.');

        rpcr = requests.get(0);
        Assert.areEqual(dateChange, rpcr.Effective_Date__c, 'Effective date is incorrect.');
        Assert.areEqual('Amount Per Check', rpcr.Commission_Type__c, 'Commission Type is incorrect.');
        Assert.areEqual(999.99, rpcr.Commission_Rate__c, 'Commission Rate is incorrect.');
    }

    /**
     * testRPOR_Client change the Referral Partner
     */
    @IsTest 
    static void testRPOR_Client() {
        getData();

        Date dateChange = Date.today();
        Referral_Partner_Change_Request__c rpcr;

        Test.startTest();

        System.RunAs(testEnv.sysAdmin) {
            rpcr = new Referral_Partner_Change_Request__c(
                RecordTypeId = ReferralPartnerChange_Const.idrtRPOR,
                Client__c = testEnv.client11.Id,
                Referral_Partner__c = testEnv.partner2.Id,
                Producer__c = testEnv.producer2.Id,
                Effective_Date__c = dateChange,
                Comments__c = 'Test RPOR',
                Status__c = 'Approved',
                Product_Line__c = ReferralPartnerChange_Const.PLTYPE_WORKERSCOMP
            );

            Database.SaveResult sr = Database.insert(rpcr, false);
            Boolean success = Debug_Service.debug(LoggingLevel.DEBUG, new List<Database.SaveResult>{ sr }, false);
            Assert.areEqual(true, success, 'testRPOR_Client: Unable to insert request');
        }

        Test.stopTest();

        getData();

        List<Referral_Partner_Change_Request__c> requests = [SELECT Id, Effective_Date__c, Comments__c, Referral_Partner__c, Status__c
            FROM Referral_Partner_Change_Request__c
            WHERE Client__c = :testEnv.client11.Id];
        
        Assert.areEqual(1, requests.size(), 'Client 11 should have only the inserted request');

        rpcr = requests.get(0);
        Assert.areEqual(dateChange, rpcr.Effective_Date__c, 'Effective date is incorrect.');
        Assert.areEqual(testEnv.partner2.Id, rpcr.Referral_Partner__c, 'Lost Referral Partner.');
        Assert.areEqual('Performed', rpcr.Status__c, 'Action should have been performed.');

        Assert.areEqual(testEnv.partner2.Id, testEnv.client11.Assigned_Referral_Partner__c, 'Referral Partner should have changed to partner2.');
    }

    /**
     * testRPOR_Client change the Referral Partner
     */
    @IsTest 
    static void testRPOR_ClientToRP_RPOnHold() {
        getData();

		System.debug(LoggingLevel.DEBUG, 'CLIENT 11: [' + testEnv.client11.Id + '] ' + testEnv.client11.Name);
		System.debug(LoggingLevel.DEBUG, 'RP 1: [' + testEnv.partner1.Id + '] ' + testEnv.partner1.Name);
		System.debug(LoggingLevel.DEBUG, 'RP 2: [' + testEnv.partner2.Id + '] ' + testEnv.partner2.Name);

		Referral_Partner__c rs = ReferralSource_Service.createReferralSourceForClient(testEnv.client11, testEnv.partner1);

        Date dateChange = Date.today();
		Referral_Partner_Change_Request__c rpcr;
		
        Referral_Partner_Change_Request__c rpcr2 = new Referral_Partner_Change_Request__c(
            RecordTypeId = ReferralPartnerChange_Const.idrtHoldRP,
            Client__c = null,
            Referral_Partner__c = testEnv.partner2.Id,
            Override__c = false,
            Effective_Date__c = Date.today(),
            Comments__c = 'Test RP Set Hold',
            Status__c = 'Approved'
        );

		insert new List<Referral_Partner_Change_Request__c>{ rpcr2 };

		Account p2 = [SELECT Id, Hold__c FROM Account WHERE Id = :testEnv.partner2.Id];
		Assert.areEqual(true, p2.Hold__c);
		List<Referral_Partner__c> rss = [
            SELECT Id, Effective_Date__c, Termination_Date__c, Account__c, Referral_Partner__c, Referral_Partner_ID__c, RP_On_Hold__c
            FROM Referral_Partner__c
            WHERE Referral_Partner__c = :testEnv.partner2.Id AND Termination_Date__c = null
        ];
        Assert.areEqual(true, rss.get(0).RP_On_Hold__c);
        Test.startTest();

        System.RunAs(testEnv.sysAdmin) {
            rpcr = new Referral_Partner_Change_Request__c(
                RecordTypeId = ReferralPartnerChange_Const.idrtRPOR,
                Client__c = testEnv.client11.Id,
                Referral_Partner__c = testEnv.partner2.Id,
                Producer__c = testEnv.producer2.Id,
                Effective_Date__c = dateChange,
                Comments__c = 'Test RPOR',
                Status__c = 'Approved',
                Product_Line__c=ReferralPartnerChange_Const.PLTYPE_WORKERSCOMP
            );

            Database.SaveResult sr = Database.insert(rpcr, false);
            Boolean success = Debug_Service.debug(LoggingLevel.DEBUG, new List<Database.SaveResult>{ sr }, false);
            Assert.areEqual(true, success, 'testRPOR_Client: Unable to insert request');
        }

        Test.stopTest();

        getData();

        List<Referral_Partner_Change_Request__c> requests = [SELECT Id, Effective_Date__c, Comments__c, Referral_Partner__c, Status__c
            FROM Referral_Partner_Change_Request__c
            WHERE Client__c = :testEnv.client11.Id];
        
        Assert.areEqual(1, requests.size(), 'Client 11 should have only the inserted request');

        rpcr = requests.get(0);
        Assert.areEqual(dateChange, rpcr.Effective_Date__c, 'Effective date is incorrect.');
        Assert.areEqual(testEnv.partner2.Id, rpcr.Referral_Partner__c, 'Lost Referral Partner.');
        Assert.areEqual('Performed', rpcr.Status__c, 'Action should have been performed.');

        Assert.areEqual(testEnv.partner2.Id, testEnv.client11.Assigned_Referral_Partner__c, 'Referral Partner should have changed to partner2.');

        List<Referral_Partner__c> rssC1 = [
            SELECT Id, Effective_Date__c, Termination_Date__c, Account__c, Referral_Partner__c, Referral_Partner_ID__c, RP_On_Hold__c
            FROM Referral_Partner__c
            WHERE Account__c = :testEnv.client11.Id AND Termination_Date__c = null
        ];

		Assert.areEqual(1, rssC1.size());
		Assert.areEqual(testEnv.partner2.Id, rssC1.get(0).Referral_Partner__c);
		Assert.areEqual(false, rssC1.get(0).RP_On_Hold__c);
    }

    /**
     * testRPOR_Branch change the Referral Partner to a Branch.
     */
    @IsTest 
    static void testRPOR_Branch() {
        getData();

        Date dateChange = Date.today();
        Referral_Partner_Change_Request__c rpcr;

        Test.startTest();

        System.RunAs(testEnv.sysAdmin) {
            rpcr = new Referral_Partner_Change_Request__c(
                RecordTypeId = ReferralPartnerChange_Const.idrtRPOR,
                Client__c = testEnv.client11.Id,
                Referral_Partner__c = testEnv.branch.Id,
                Producer__c = testEnv.branchDude.Id,
                Effective_Date__c = dateChange,
                Comments__c = 'Test RPOR',
                Status__c = 'Approved',
                Product_Line__c = ReferralPartnerChange_Const.PLTYPE_WORKERSCOMP
            );

            Database.SaveResult sr = Database.insert(rpcr, false);
            Boolean success = Debug_Service.debug(LoggingLevel.DEBUG, new List<Database.SaveResult>{ sr }, false);
            Assert.areEqual(true, success, 'testRPOR_Branch: Unable to insert request');
        }

        Test.stopTest();

        getData();

        List<Referral_Partner_Change_Request__c> requests = [SELECT Id, Effective_Date__c, Comments__c, Referral_Partner__c, Status__c
            FROM Referral_Partner_Change_Request__c
            WHERE Client__c = :testEnv.client11.Id];
        
        Assert.areEqual(1, requests.size(), 'Client 11 should have only the inserted request');

        rpcr = requests.get(0);
        Assert.areEqual(dateChange, rpcr.Effective_Date__c, 'Effective date is incorrect.');
        Assert.areEqual(testEnv.branch.Id, rpcr.Referral_Partner__c, 'Lost Referral Partner.');
        Assert.areEqual('Performed', rpcr.Status__c, 'Action should have been performed.');

        Assert.areEqual(testEnv.branch.Id, testEnv.client11.Assigned_Referral_Partner__c, 'Referral Partner should have changed to branch.');
    }

    /**
     * testRPOR_SplitClient
     */
    @IsTest 
    static void testRPOR_SplitClient() {
        getData();

        Account newRP = TestFactory.createAccountReferralPartner('New Referral Partner', 'Active', '% of Margin', 13.18, null, true);
        Contact newProducer;
        Date dateChange = System.today();
        Referral_Partner_Change_Request__c rpcr;

        Test.startTest();

        System.RunAs(testEnv.sysAdmin) {
            newProducer = TestFactory.createContact(newRP, 'TestProducer', 'Producer', false);
            newProducer.Primary__c = true;
            insert newProducer;

            rpcr = new Referral_Partner_Change_Request__c(
                RecordTypeId = ReferralPartnerChange_Const.idrtRPOR,
                Client__c = testEnv.clientSplit.Id,
                Referral_Partner__c = newRP.Id,
                Producer__c = newProducer.Id,
                Effective_Date__c = dateChange,
                Comments__c = 'Test RPOR on Split Client',
                Status__c = 'Approved',
                Product_Line__c = ReferralPartnerChange_Const.PLTYPE_WORKERSCOMP
            );

            Database.SaveResult sr = Database.insert(rpcr, false);
            Boolean success = Debug_Service.debug(LoggingLevel.DEBUG, new List<Database.SaveResult>{ sr }, false);
            Assert.areEqual(true, success, 'testRPOR_SplitClient: Unable to insert request');
        }

        Test.stopTest();

        getData();

        List<Referral_Partner_Change_Request__c> requests = [SELECT Id, Effective_Date__c, Comments__c, Referral_Partner__c, Status__c
            FROM Referral_Partner_Change_Request__c
            WHERE Client__c = :testEnv.clientSplit.Id];
        
        Assert.areEqual(1, requests.size(), 'Client clientSplit should now have only the inserted request');

        rpcr = requests.get(0);
        Assert.areEqual(dateChange, rpcr.Effective_Date__c, 'Effective date is incorrect.');
        Assert.areEqual(newRP.Id, rpcr.Referral_Partner__c, 'Lost Referral Partner.');
        Assert.areEqual('Performed', rpcr.Status__c, 'Action should have been performed.');

        List<Referral_Partner__c> rss = [
            SELECT Id, Commission_Rate__c, Referral_Partner_Commission_Type__c, Referral_Partner__c, Producer__c
            FROM Referral_Partner__c 
            WHERE Termination_Date__c = null 
            AND Account__c = :testEnv.clientSplit.Id
        ];

        Assert.areEqual(1, rss.size(), 'Only 0 active Referral Source should remain on clientSplit.');
        Referral_Partner__c rs = rss.get(0);
        Assert.areEqual(newRP.Id, rs.Referral_Partner__c, 'Should have moved to the new Referral Partner');
        Assert.areEqual(newRP.Commission_Rate__c, rs.Commission_Rate__c, 'Rate should be the same as the new Referral Partner');
        Assert.areEqual(newRP.Commission_Type__c, rs.Referral_Partner_Commission_Type__c, 'Type should be the same as the new Referral Partner');

        Account client = [SELECT Id, Commission_Rate__c, Commission_Type__c, Assigned_Referral_Partner__c, Producer__c FROM Account WHERE Id = :testEnv.clientSplit.Id];
// RPC TODO: FIX THIS TEST !!!       Assert.areEqual(newRP.Commission_Rate__c, client.Commission_Rate__c, 'Rate should be the same as the new Referral Partner');
//         Assert.areEqual(newRP.Commission_Type__c, client.Commission_Type__c, 'Type should be the same as the new Referral Partner');
//        Assert.areEqual(newRP.Id, client.Assigned_Referral_Partner__c, 'Should have new Referral Partner');
//        Assert.areEqual(newProducer.Id, client.Producer__c, 'Producer should be the same as the for Referral Partner');
    }

    /**
     * testIsSplitCommission
     */
    @IsTest 
    static void testIsSplitCommission() {
        getData();

        Test.startTest();

        List<Referral_Partner__c> rss1 = [
            SELECT Id, Effective_Date__c, Termination_Date__c, Account__c, Referral_Partner__c
            FROM Referral_Partner__c
            WHERE Account__c = :testEnv.clientSplit.Id
        ];
        List<Referral_Partner__c> rss2 = [
            SELECT Id, Effective_Date__c, Termination_Date__c, Account__c, Referral_Partner__c
            FROM Referral_Partner__c
            WHERE Account__c = :testEnv.client11.ID
        ];

        Boolean split1 = ReferralPartnerChange_Process.isSplitCommission(rss1);
        Boolean split2 = ReferralPartnerChange_Process.isSplitCommission(rss2);

        Test.stopTest();

        Assert.areEqual(true, split1, 'Client Split is a split commission client');
        Assert.areEqual(false, split2, 'Client 11 is not a split commission client');
    }

    /**
     * testCommissionChange_ReferralPartner runs adds an Override Commission on a Referral Partner.
     */
    @IsTest 
    static void testCommissionChange_ReferralPartner() {
        getData();
    
        Date dateOverride = Date.today().addDays(-14);
        Referral_Partner_Change_Request__c rpcrClient11 = new Referral_Partner_Change_Request__c(
            RecordTypeId = ReferralPartnerChange_Const.idrtOverrideClient,
            Client__c = testEnv.client11.Id,
            Referral_Partner__c = testEnv.partner1.Id,
            Override__c = true,
            Commission_Type__c = '% of Margin',
            Commission_Rate__c = 12.78,
            Effective_Date__c = dateOverride,
            Comments__c = 'Test Client Set Override',
            Status__c = 'Approved',
            Product_Line__c = ReferralPartnerChange_Const.PLTYPE_WORKERSCOMP
        );
        insert rpcrClient11;

        Date dateEffective = Date.today().addDays(-7);
        Referral_Partner_Change_Request__c rpcr = new Referral_Partner_Change_Request__c(
            RecordTypeId = ReferralPartnerChange_Const.idrtCommissionChangeRP,
            Client__c = null,
            Referral_Partner__c = testEnv.partner1.Id,
            Override__c = false,
            Commission_Type__c = '% of Margin',
            Commission_Rate__c = 34.45,
            Effective_Date__c = dateEffective,
            Comments__c = 'Test Referral Partner Commission Change',
            Status__c = 'Approved',
            Product_Line__c = ReferralPartnerChange_Const.PLTYPE_WORKERSCOMP
        );

        Test.startTest();
        ReferralPartnerChange_Process process = new ReferralPartnerChange_Process();
        process.execute( new List<Referral_Partner_Change_Request__c>{ rpcr } );
        Test.stopTest();

        getData();

        Assert.areEqual(1, process.mapRpToClients.size(), 'Should have partner1');
        Assert.areEqual(5, process.mapRpToClients.get(testEnv.partner1.Id).size(), 'Should have all Clients of partner1');
        Assert.areEqual(0, process.mapAccountToReferralSources.get(testEnv.partner1.Id).size(), 'Should have not created a Referral Source for each active client.');

        Map<Id, List<Referral_Partner__c>> mapRss = ReferralSource_Service.getActiveAccountReferralSources(idAccounts);
        Assert.areEqual(0, mapRss.get(testEnv.branch.Id).size(), 'branch should have no Referral Sources');
        Assert.areEqual(0, mapRss.get(testEnv.partner0.Id).size(), 'partner0 should have no Referral Sources');
        Assert.areEqual(0, mapRss.get(testEnv.partner1.Id).size(), 'partner1 should have 0 Referral Source');
        Assert.areEqual(0, mapRss.get(testEnv.partner2.Id).size(), 'partner2 should have no Referral Sources');
        Assert.areEqual(0, mapRss.get(testEnv.partner3.Id).size(), 'partner3 should have no Referral Sources');
        Assert.areEqual(0, mapRss.get(testEnv.client10.Id).size(), 'client10 should have no Referral Sources');
        Assert.areEqual(1, mapRss.get(testEnv.client11.Id).size(), 'client11 should have 1 Referral Source');
        Assert.areEqual(1, mapRss.get(testEnv.client12.Id).size(), 'client12 should have 1 Referral Source');
        Assert.areEqual(1, mapRss.get(testEnv.client13.Id).size(), 'client13 should have 1 Referral Source');
        Assert.areEqual(0, mapRss.get(testEnv.client21.Id).size(), 'client21 should have no Referral Sources');
        Assert.areEqual(0, mapRss.get(testEnv.client22.Id).size(), 'client22 should have no Referral Sources');

        List<Referral_Partner__c> rss;
        rss = process.mapAccountToReferralSources.get(testEnv.partner1.Id);
        Assert.areEqual(0, rss.size(), 'partner1 should have 0 Active Referral Sources');
        //ReferralPartner_TestEnv.assertReferralSource('partner1 - Commission Change', rss.get(0), null, testEnv.partner1.Id, false, false, null, false, '% of Margin', 34.45, dateEffective, null);

        rss = process.mapAccountToReferralSources.get(testEnv.client10.Id);
        Assert.areEqual(0, rss.size(), 'client10 should have no Active Referral Sources');

        rss = process.mapAccountToReferralSources.get(testEnv.client11.Id);
        Assert.areEqual(1, rss.size(), 'client11 should have 1 Active Referral Sources');
        ReferralPartner_TestEnv.assertReferralSource('client11 - Set RP Commission Change Client OVERRIDE', rss.get(0), testEnv.client11.Id, testEnv.partner1.Id, false, false, null, true, '% of Margin', 12.78, dateOverride, null);

        rss = process.mapAccountToReferralSources.get(testEnv.client12.Id);
        Assert.areEqual(1, rss.size(), 'client12 should have 1 Active Referral Sources');
        ReferralPartner_TestEnv.assertReferralSource('client12 - Set RP Commission Change', rss.get(0), testEnv.client12.Id, testEnv.partner1.Id, false, false, null, false, '% of Margin', 34.45, dateEffective, null);

        rss = process.mapAccountToReferralSources.get(testEnv.client13.Id);
        Assert.areEqual(2, rss.size(), 'client13 should have 1 Active Referral Sources');
        ReferralPartner_TestEnv.assertReferralSource('client13 - Set RP Commission Change', rss.get(rss.size() - 1), testEnv.client13.Id, testEnv.partner1.Id, false, false, null, false, '% of Margin', 34.45, dateEffective, null);
    }

    /**
     * testGroupChange_ReferralPartner.
     */
    @IsTest 
    static void testGroupChange_ReferralPartner() {
        getData();

        Referral_Partner__c client11RS = new Referral_Partner__c(
            RecordTypeId = ReferralSource_Service.idrtClientRP,
            Account__c = testEnv.client11.Id,
            Effective_Date__c = System.today(),
            Referral_Partner_Commission_Type__c = testEnv.partner1.Commission_Type__c,
            Commission_Rate__c = testEnv.partner1.Commission_Rate__c,
            Producer__c = testEnv.client11.Producer__c,
            Referral_Partner__c = testEnv.partner1.Id
        );

        Referral_Partner__c client12RS = new Referral_Partner__c(
            RecordTypeId = ReferralSource_Service.idrtClientRP,
            Account__c = testEnv.client12.Id,
            Effective_Date__c = System.today(),
            Referral_Partner_Commission_Type__c = testEnv.partner1.Commission_Type__c,
            Commission_Rate__c = testEnv.partner1.Commission_Rate__c,
            Producer__c = testEnv.client12.Producer__c,
            Referral_Partner__c = testEnv.partner1.Id
        );

        insert new List<Referral_Partner__c>{ client11RS, client12RS };

        Assert.areEqual(testEnv.group1.Id, testEnv.partner1.Referral_Partner_Group__c, 'Start with group 1.');
        Assert.areEqual(true, PermissionSet_Service.userHasCustomPermission(testEnv.rpAdmin.Id, 'Referral_Partner_Group_Edit'), 'rpAdmin should have Custom Permission Referral_Partner_Group_Edit');
        Date dateSet = Date.today().addDays(-14);
        Referral_Partner_Change_Request__c rpcr = new Referral_Partner_Change_Request__c(
            RecordTypeId = ReferralPartnerChange_Const.idrtRPGroupChange,
            Client__c = null,
            Referral_Partner__c = testEnv.partner1.Id,
            Referral_Partner_Group__c = testEnv.group3.Id,
            Effective_Date__c = dateSet,
            Comments__c = 'Test RP Group change',
            Status__c = 'Pre-Approval',
            Product_Line__c = ReferralPartnerChange_Const.PLTYPE_WORKERSCOMP
        );

        Test.startTest();

        try {
            System.runAs(testEnv.rpAdmin) {
                insert rpcr;
            }
        }
        catch(Exception e) {
            Assert.isTrue(false, 'Should not thrown an exception: ' + e.getMessage());
        }

        Test.stopTest();

        getData();

        List<Referral_partner__c> rps = [SELECT Id, Name FROM Referral_Partner__c WHERE Account__c = :testEnv.client12.Id];
        Assert.isTrue(rps != null, 'Query failed');
        Assert.isTrue(rps.size() > 0, 'Missing the Referral Source');

        Assert.areEqual(testEnv.group3.Id, testEnv.partner1.Referral_Partner_Group__c, 'Did not change RP Group.');

        Map<Id, List<Referral_Partner__c>> mapRss = ReferralSource_Service.getActiveAccountReferralSources(new Set<Id>{ testEnv.partner1.Id, testEnv.client11.Id, testEnv.client12.Id });
        Assert.areEqual(1, mapRss.get(testEnv.partner1.Id).size(), 'partner1 should have 1 active Referral Source');

        List<Referral_Partner__c> rss = mapRss.get(testEnv.partner1.Id);
        ReferralPartner_TestEnv.assertReferralSource('partner1 - Group Change', rss.get(0), null, testEnv.partner1.Id, false, false, null, false, '% of WC Eligible Payroll', 1.11, dateSet, null);
        Assert.areEqual(testEnv.group3.Id, rss.get(0).Referral_Partner_Group__c, 'Group should be set');

        // Test Clients
        rss = mapRss.get(testEnv.client11.Id);
        ReferralPartner_TestEnv.assertReferralSource('client11 - Group Change', rss.get(0), testEnv.client11.Id, testEnv.partner1.Id, false, false, null, false, '% of WC Eligible Payroll', 1.11, Date.today(), null);
            Assert.areEqual(testEnv.group3.Id, rss.get(0).Referral_Partner_Group__c, 'Group should be set');
            Assert.areEqual('GROUP 3', rss.get(0).Group_Description__c, 'Group description should be set');

        rss = mapRss.get(testEnv.client12.Id);
        ReferralPartner_TestEnv.assertReferralSource('client12 - Group Change', rss.get(0), testEnv.client12.Id, testEnv.partner1.Id, false, false, null, false, '% of WC Eligible Payroll', 1.11, Date.today(), null);
        Assert.areEqual(testEnv.group3.Id, rss.get(0).Referral_Partner_Group__c, 'Group should be set');
        Assert.areEqual('GROUP 3', rss.get(0).Group_Description__c, 'Group description should be set');
    }

    /**
     * testRPOR_TerminatedClient change the Referral Partner 
     * on Client with Status of Terminated
     */
    @IsTest 
    static void testRPOR_TerminatedClient() {
        getData();
        
        List<Referral_Partner_Change_Request__c> requests;
        requests = [SELECT Id, Effective_Date__c, Comments__c, Referral_Partner__c, Producer__c, Status__c
            FROM Referral_Partner_Change_Request__c
            WHERE Client__c = :testEnv.client10.Id];

        Assert.areEqual(0, requests.size(), 'Client 10 should have no Referral Sources');

        Date dateChange = Date.today();
        Referral_Partner_Change_Request__c rpcr;

        Test.startTest();

        System.RunAs(testEnv.sysAdmin) {
            rpcr = new Referral_Partner_Change_Request__c(
                RecordTypeId = ReferralPartnerChange_Const.idrtRPOR,
                Client__c = testEnv.client10.Id,
                Referral_Partner__c = testEnv.partner2.Id,
                Producer__c = testEnv.producer2.Id,
                Effective_Date__c = dateChange,
                Comments__c = 'Test RPOR',
                Status__c = 'Approved',
                 Product_Line__c = ReferralPartnerChange_Const.PLTYPE_WORKERSCOMP
            );

            Database.SaveResult sr = Database.insert(rpcr, false);
            Boolean success = Debug_Service.debug(LoggingLevel.DEBUG, new List<Database.SaveResult>{ sr }, false);
            Assert.areEqual(true, success, 'testRPOR_TerminatedClient: Unable to insert request');
        }

        Test.stopTest();

        getData();

        requests = [SELECT Id, Effective_Date__c, Comments__c, Referral_Partner__c, Producer__c, Status__c
            FROM Referral_Partner_Change_Request__c
            WHERE Client__c = :testEnv.client10.Id];
        
        Assert.areEqual(1, requests.size(), 'Client 10 should have only the inserted request');

        rpcr = requests.get(0);
        Assert.areEqual(dateChange, rpcr.Effective_Date__c, 'Effective date is incorrect.');
        Assert.areEqual(testEnv.partner2.Id, rpcr.Referral_Partner__c, 'Lost Referral Partner.');
        Assert.areEqual(testEnv.producer2.Id, rpcr.Producer__c, 'Lost Referral Partner.');
        Assert.areEqual('Performed', rpcr.Status__c, 'Action should have been performed.');

        Assert.areEqual(testEnv.partner2.Id, testEnv.client10.Assigned_Referral_Partner__c, 'Referral Partner should have changed to partner2.');
    }

    /**
     * test_addExceptionMessage
     */
    @IsTest 
    static void test_addExceptionMessage() {
        Referral_Partner_Change_Request__c rpcr = new Referral_Partner_Change_Request__c();

        ReferralPartnerChange_Process process = new ReferralPartnerChange_Process();
        process.addExceptionMessage(new InvalidValueException('Text Exception'), rpcr);

        Assert.isTrue(process.exceptionText.contains('Exception while processing change request:'), 'Base message missing');
    }

    /**
     * test_makeUpsertError
     */
    @IsTest 
    static void test_makeUpsertError() {
        Referral_Partner_Group__c rpGroup = new Referral_Partner_Group__c(
            Name = 'Test Group Name',
            Group_Commission_Rate__c = 10.3,
            Group_Commission_Type__c = '% of Margin'
        );

        insert rpGroup;

        rpGroup.Name = 'Better Name';

        Database.UpsertResult err = Database.upsert( rpGroup );

        ReferralPartnerChange_Process process = new ReferralPartnerChange_Process();
        String error = process.makeUpsertError('Title', new List<Database.UpsertResult>{ err });

        Assert.areEqual('', error, 'No error should have been added');
    }
    
    
     @isTest
    static void testBenefitsFieldMapping() {
        getData();
        List<Benefits__c> benefitsList = new List<Benefits__c>();
       			
            Benefits__c benefit = new Benefits__c();
            benefit.Name='test benefits';
			benefit.AccountId__c= testEnv.clientPrimary.Id;
			benefit.L_H_Referral_Partner__c= testEnv.partner1.Id;
            benefitsList.add(benefit);
        
        insert benefitsList;
        
        Test.startTest();
        Referral_Partner_Change_Request__c rpcr = new Referral_Partner_Change_Request__c(
            RecordTypeId = ReferralPartnerChange_Const.idrtRPOR,
            Client__c = testEnv.clientPrimary.Id,
            Referral_Partner__c = testEnv.partner1.Id,
            Override__c = false,
            Effective_Date__c = Date.today(),
            Comments__c = 'Test Client Set Hold',
            Status__c = 'Approved',
            Product_Line__c = ReferralPartnerChange_Const.PLTYPE_BENEFITS
        );

        List<Referral_Partner_Change_Request__c> rpcrs = new List<Referral_Partner_Change_Request__c>{ rpcr };

        ReferralPartnerChange_Process process = new ReferralPartnerChange_Process();
        process.execute(rpcrs);

        Test.stopTest();
    }
    
    @isTest
    static void testrpRequestActivation() {
        getData();
       
        Test.startTest();
        Referral_Partner_Change_Request__c rpcr = new Referral_Partner_Change_Request__c(
            RecordTypeId = ReferralPartnerChange_Const.idrtRPReqActiv,
            Client__c = testEnv.client13.Id,
            Referral_Partner__c = testEnv.partner3.Id,
            Override__c = false,
            Effective_Date__c = Date.today(),
            Comments__c = 'Test Client Set Hold',
            Status__c = 'Pending Approval',
            Product_Line__c = ReferralPartnerChange_Const.PLTYPE_BENEFITS
        );

        List<Referral_Partner_Change_Request__c> rpcrs = new List<Referral_Partner_Change_Request__c>{ rpcr };

        ReferralPartnerChange_Process process = new ReferralPartnerChange_Process();
        process.execute(rpcrs);

        Test.stopTest();
    } 
}