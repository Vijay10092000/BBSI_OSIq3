/**
 * @description AccountBranch_Test contains tests for the AccountBranch class.
 */
@IsTest
@SuppressWarnings('PMD.ApexAssertionsShouldIncludeMessage')
public without sharing class AccountBranch_Test {
    private static Account branchHome;
    private static Account branch1;
    private static Account branch2;
    private static Account branch3;

    private static User am1;
    private static User am2;
    private static User am3;
    public static User bdm1;
    public static User bdm2;
    public static User bdm3;
    public static User bdmInactive;

    @TestSetup
    static void makeData() {
        branchHome = TestFactoryAccount.makeBranch('HOME', '9000', 'Test AreaManager1', 'am.one@bbsi.zzz');
        branchHome.Region__c = 'Upper';
        branch1 = TestFactoryAccount.makeBranch('ONE', '9001', 'Test AreaManager1', 'am.one@bbsi.zzz');
        branch1.Region__c = 'Middle';
        branch2 = TestFactoryAccount.makeBranch('TWO', '9002', 'Test AreaManager2', 'am.two@bbsi.zzz');
        branch2.Region__c = 'Middle';
        branch3 = TestFactoryAccount.makeBranch('THREE', '9003', 'Test AreaManager3', 'am.three@bbsi.zzz');
        branch3.Region__c = 'Lower';
        insert new List<Account>{ branchHome, branch1, branch2, branch3 };

        am1 = TestFactoryUser.makeAreaManager('Test', 'AreaManager1', '9001');
        am2 = TestFactoryUser.makeAreaManager('Test', 'AreaManager2', '9002');
        am3 = TestFactoryUser.makeAreaManager('Test', 'AreaManager3', '9003');

        bdm1 = TestFactoryUser.makeBDM('Test', 'Bdm1', 'BBSI Standard', '9001');
        bdm2 = TestFactoryUser.makeBDM('Test', 'Bdm2', 'BBSI Standard', '9002');
        bdm3 = TestFactoryUser.makeBDM('Test', 'Bdm3', 'BBSI Standard', '9003');

        bdmInactive = TestFactoryUser.makeBDM('Test', 'BdmInactive', 'BBSI Standard', '9001');
        bdmInactive.IsActive = false;

        insert new List<User>{ am1, am2, am3, bdm1, bdm2, bdm3, bdmInactive };
    }

    static void loadData() {
        List<Account> branches = [
            SELECT Id, Name, Branch_Manager__c
            FROM Account
            WHERE External_ID__c IN ('9000', '9001', '9002', '9003')
            ORDER BY External_ID__c
        ];
        Assert.areEqual(4, branches.size(), 'Should start with 4 branches.');
        branchHome = branches.get(0);
        branch1 = branches.get(1);
        branch2 = branches.get(2);
        branch3 = branches.get(3);

        List<User> users = [
            SELECT Id, Name, Email
            FROM User
            WHERE Branch_Id__c IN ('9001', '9002', '9003')
            ORDER BY Name
        ];
        Assert.areEqual(7, users.size(), 'Should start with 7 Users.');
        am1 = users.get(0);
        am2 = users.get(1);
        am3 = users.get(2);
        bdm1 = users.get(3);
        bdm2 = users.get(4);
        bdm3 = users.get(5);
        bdmInactive = users.get(6);
    }

    @IsTest
    public static void test_getAreaManagersBranchesNoArgs() {
        loadData();

        branch3.Branch_Manager__c = 'Test AreaManager1';
        branch3.Branch_Manager_Email__c = 'am.three@bbsi.zzz';
        update branch3;

        Test.startTest();

        Map<Id, List<Account>> mapAMtoBranch = AccountBranch.getAreaManagersBranches();

        Test.stopTest();

        Assert.areEqual(2, mapAMtoBranch.size(), 'Should have 2 Area Managers');
        Assert.areEqual(true, mapAMtoBranch.containsKey(am1.Id), 'Must have AreaManager1');
        Assert.areEqual(true, mapAMtoBranch.containsKey(am2.Id), 'Must have AreaManager2');
        Assert.areEqual(false, mapAMtoBranch.containsKey(am3.Id), 'Does not have AreaManager3');

        List<Account> branches;
        branches = mapAMtoBranch.get(am1.Id);
        Assert.areEqual(3, branches.size(), 'AreaManager1 has 3 branches - HOME, 1, 3');
        branches = mapAMtoBranch.get(am2.Id);
        Assert.areEqual(1, branches.size(), 'AreaManager1 has 1 branch - 2');
    }

    @IsTest
    public static void test_getAreaManagerBranches() {
        loadData();

        branch3.Branch_Manager__c = 'Test AreaManager1';
        branch3.Branch_Manager_Email__c = 'am.one@bbsi.zzz';
        update branch3;

        Test.startTest();

        Map<Id, List<Account>> mapAMtoBranch = AccountBranch.getAreaManagerBranches(new Set<Id>{ am2.Id, am3.Id });

        Test.stopTest();

        Assert.areEqual(2, mapAMtoBranch.size(), 'Should have 2 Area Manager1');
        Assert.areEqual(true, mapAMtoBranch.containsKey(am2.Id), 'Must have AreaManager2');
        Assert.areEqual(true, mapAMtoBranch.containsKey(am3.Id), 'Must have AreaManager3');

        List<Account> branches;
        branches = mapAMtoBranch.get(am2.Id);
        Assert.areEqual(1, branches.size(), 'AreaManager2 has 1 branches');
        branches = mapAMtoBranch.get(am3.Id);
        Assert.areEqual(0, branches.size(), 'AreaManager3 has no branches');
    }
    
    @IsTest
    public static void test_getRelatedBdms_Leads() {
        loadData();

        insert new List<Lead>{
            TestFactoryLead.makeClientLead('TEST', 'LeadOne', 'LeadOne', branch1.Id, bdm1.Id),
            TestFactoryLead.makeClientLead('TEST', 'LeadTwo', 'LeadTwo', branch1.Id, bdm1.Id),
            TestFactoryLead.makeClientLead('TEST', 'LeadThree', 'LeadThree', branch2.Id, bdm1.Id),
            TestFactoryLead.makeClientLead('TEST', 'LeadFour', 'LeadFour', branch2.Id, bdm2.Id),
            TestFactoryLead.makeClientLead('TEST', 'LeadFive', 'LeadFive', branch3.Id, bdm2.Id),
            TestFactoryLead.makeClientLead('TEST', 'LeadSix', 'LeadSix', branch3.Id, bdm3.Id)
        };

        Set<Id> idBranchesHome = new Set<Id>{ branchHome.Id };
        Set<Id> idBranchesAll = new Set<Id>{ branch1.Id, branch2.Id, branch3.Id };
        Set<Id> idBranches1and2 = new Set<Id>{ branch1.Id, branch2.Id };
        Set<Id> idBranches2and3 = new Set<Id>{ branch2.Id, branch3.Id };

        Test.startTest();

        Map<Id, User> bdmsHome = AccountBranch.getRelatedBdms(idBranchesHome);
        Map<Id, User> bdmsAll = AccountBranch.getRelatedBdms(idBranchesAll);
        Map<Id, User> bdms1and2 = AccountBranch.getRelatedBdms(idBranches1and2);
        Map<Id, User> bdms2and3 = AccountBranch.getRelatedBdms(idBranches2and3);

        Test.stopTest();

        Assert.areEqual(0, bdmsHome.size());
        Assert.areEqual(false, bdmsHome.containsKey(bdm1.Id));
        Assert.areEqual(false, bdmsHome.containsKey(bdm2.Id));
        Assert.areEqual(false, bdmsHome.containsKey(bdm3.Id));

        Assert.areEqual(3, bdmsAll.size());
        Assert.areEqual(true, bdmsAll.containsKey(bdm1.Id));
        Assert.areEqual(true, bdmsAll.containsKey(bdm2.Id));
        Assert.areEqual(true, bdmsAll.containsKey(bdm3.Id));

        Assert.areEqual(2, bdms1and2.size());
        Assert.areEqual(true, bdms1and2.containsKey(bdm1.Id));
        Assert.areEqual(true, bdms1and2.containsKey(bdm2.Id));
        Assert.areEqual(false, bdms1and2.containsKey(bdm3.Id));

        Assert.areEqual(3, bdms2and3.size());
        Assert.areEqual(true, bdms2and3.containsKey(bdm1.Id));
        Assert.areEqual(true, bdms2and3.containsKey(bdm2.Id));
        Assert.areEqual(true, bdms2and3.containsKey(bdm3.Id));
    }

    @IsTest
    public static void test_getRelatedBdms_Clients() {
        loadData();

        Account client1 = TestFactoryAccount.makeClient('Client 1', null, null);
        Account client2 = TestFactoryAccount.makeClient('Client 2', null, null);
        Account client3 = TestFactoryAccount.makeClient('Client 3', null, null);
        Account prospect1 = TestFactoryAccount.makeProspect('Prospect 1', null, null);
        Account prospect2 = TestFactoryAccount.makeProspect('Prospect 2', null, null);
        Account prospect3 = TestFactoryAccount.makeProspect('Prospect 3', null, null);

        client1.Business_Development_Manager__c = bdm1.Id;
        client1.Prospect_Branch__c = branch1.Id;
        prospect1.Business_Development_Manager__c = bdm1.Id;
        prospect1.Prospect_Branch__c = branch1.Id;
        client2.Business_Development_Manager__c = bdm1.Id;
        client2.Prospect_Branch__c = branch2.Id;
        prospect2.Business_Development_Manager__c = bdm2.Id;
        prospect2.Prospect_Branch__c = branch2.Id;
        client3.Business_Development_Manager__c = bdm2.Id;
        client3.Prospect_Branch__c = branch3.Id;
        prospect3.Business_Development_Manager__c = bdm3.Id;
        prospect3.Prospect_Branch__c = branch3.Id;

        insert new List<Account>{ client1, client2, client3, prospect1, prospect2, prospect3 };

        Set<Id> idBranchesAll = new Set<Id>{ branch1.Id, branch2.Id, branch3.Id };
        Set<Id> idBranches1and2 = new Set<Id>{ branch1.Id, branch2.Id };
        Set<Id> idBranches2and3 = new Set<Id>{ branch2.Id, branch3.Id };

        Test.startTest();

        Map<Id, User> bdmsAll = AccountBranch.getRelatedBdms(idBranchesAll);
        Map<Id, User> bdms1and2 = AccountBranch.getRelatedBdms(idBranches1and2);
        Map<Id, User> bdms2and3 = AccountBranch.getRelatedBdms(idBranches2and3);

        Test.stopTest();

        Assert.areEqual(3, bdmsAll.size());
        Assert.areEqual(true, bdmsAll.containsKey(bdm1.Id));
        Assert.areEqual(true, bdmsAll.containsKey(bdm2.Id));
        Assert.areEqual(true, bdmsAll.containsKey(bdm3.Id));

        Assert.areEqual(2, bdms1and2.size());
        Assert.areEqual(true, bdms1and2.containsKey(bdm1.Id));
        Assert.areEqual(true, bdms1and2.containsKey(bdm2.Id));
        Assert.areEqual(false, bdms1and2.containsKey(bdm3.Id));

        Assert.areEqual(3, bdms2and3.size());
        Assert.areEqual(true, bdms2and3.containsKey(bdm1.Id));
        Assert.areEqual(true, bdms2and3.containsKey(bdm2.Id));
        Assert.areEqual(true, bdms2and3.containsKey(bdm3.Id));
    }

    @IsTest
    public static void test_getBranches() {
        loadData();

        Test.startTest();

        List<Account> allBranches = AccountBranch.getBranches(null);

        Set<Id> idBranches = new Set<Id>{ branch1.Id, branch2.Id, branch3.Id };
        List<Account> partialBranches = AccountBranch.getBranches(idBranches);

        Test.stopTest();

        Assert.areEqual(4, allBranches.size(), 'Should have received all branches');
        Assert.areEqual(3, partialBranches.size(), 'Should have received branches 1, 2, and 3');
    }

    @IsTest
    public static void test_getRegions() {
        loadData();

        Test.startTest();

        List<String> regions = AccountBranch.getRegions();

        Test.stopTest();

        Assert.areEqual(3, regions.size(), 'Should have received 3 regions');
        Assert.areEqual('Lower', regions.get(0), 'Lower should be first');
        Assert.areEqual('Middle', regions.get(1), 'Middle should be second');
        Assert.areEqual('Upper', regions.get(2), 'Upper should be third');
    }

    @IsTest
    public static void test_getRegionToBranches() {
        loadData();

        Test.startTest();

        Map<String, List<Account>> mapRegionToBranches = AccountBranch.getRegionToBranches();

        Test.stopTest();

        Assert.areEqual(3, mapRegionToBranches.size(), 'Should have received 3 regions');
        Assert.isTrue(mapRegionToBranches.containsKey('Lower'), 'Lower should be in key set');
        Assert.isTrue(mapRegionToBranches.containsKey('Middle'), 'Middle should be in key set');
        Assert.isTrue(mapRegionToBranches.containsKey('Upper'), 'Upper should be in key set');

        Assert.areEqual(1, mapRegionToBranches.get('Lower').size(), 'Lower should have 1 branch');
        Assert.areEqual(2, mapRegionToBranches.get('Middle').size(), 'Lower should have 2 branches');
        Assert.areEqual(1, mapRegionToBranches.get('Upper').size(), 'Lower should have 1 branch');
    }

    @IsTest
    static void test_getBranchesByNumber() {
        loadData();

        Test.startTest();

        Map<String, Account> mapBranches = AccountBranch.getBranchesByNumber();

        Test.stopTest();

        Assert.areEqual(4, mapBranches.size());
        Assert.isTrue(mapBranches.containsKey('9000'));
        Assert.isTrue(mapBranches.containsKey('9001'));
        Assert.isTrue(mapBranches.containsKey('9002'));
        Assert.isTrue(mapBranches.containsKey('9003'));
    }

    @IsTest
    public static void test_getBranchToClients() {
        loadData();

        Account client1 = TestFactoryAccount.makeClient('Client 1', null, null);
        Account client2 = TestFactoryAccount.makeClient('Client 2', null, null);
        Account client3 = TestFactoryAccount.makeClient('Client 3', null, null);
        Account prospect1 = TestFactoryAccount.makeProspect('Prospect 1', null, null);
        Account prospect2 = TestFactoryAccount.makeProspect('Prospect 2', null, null);
        Account prospect3 = TestFactoryAccount.makeProspect('Prospect 3', null, null);
        client1.Prospect_Branch__c = branch1.Id;
        client2.Prospect_Branch__c = branch2.Id;
        client3.Prospect_Branch__c = branch2.Id;
        prospect1.Prospect_Branch__c = branch3.Id;
        prospect2.Prospect_Branch__c = branch3.Id;
        prospect3.Prospect_Branch__c = branch3.Id;

        insert new List<Account>{ client1, client2, client3, prospect1, prospect2, prospect3 };

        // Setup Data
        Set<Id> idBranches = new Set<Id>{ branchHome.Id, branch1.Id, branch2.Id, branch3.Id };
        Set<String> fields = new Set<String>{ 'Id', 'Name', 'Prospect_Branch__c' };

        Test.startTest();

        Map<Id, List<Account>> branchClients = AccountBranch.getBranchToClients(idBranches, fields);

        Test.stopTest();

        Assert.areEqual(4, branchClients.keySet().size(), 'An entry for each branch should be created');
        Assert.areEqual(0, branchClients.get(branchHome.Id).size(), 'No clients or prospects for branchHome');
        Assert.areEqual(1, branchClients.get(branch1.Id).size(), 'One client/prospect for branch1');
        Assert.areEqual(2, branchClients.get(branch2.Id).size(), 'Two client/prospect for branch2');
        Assert.areEqual(3, branchClients.get(branch3.Id).size(), 'Three client/prospect for branch3');
    }

    /**
     * @description testGetBranchNumbersToAreaManagers check the relating
     * Area Managers with Branches.
     */
    @IsTest
    static void testGetBranchNumbersToAreaManagers() {
        User am1 = TestFactory.createUserBDM('AM_1', 'AM001', 'Area Manager', '910', false);
        am1.FirstName = 'Z';
        User am2 = TestFactory.createUserBDM('AM_2', 'AM002', 'Area Manager', '910', false);
        am2.FirstName = 'Z';
        insert new List<User>{ am1, am2 };
        Account branch1 = TestFactory.createBranchAccount(
            'ONE',
            '00001',
            am1.FirstName +
            ' ' +
            am1.LastName,
            am1.Email,
            false
        );
        Account branch2 = TestFactory.createBranchAccount(
            'TWO',
            '00002',
            am2.FirstName +
            ' ' +
            am2.LastName,
            am2.Email,
            false
        );
        Account branch3 = TestFactory.createBranchAccount(
            'THREE',
            '00003',
            am2.FirstName +
            ' ' +
            am2.LastName,
            am2.Email,
            false
        );
        insert new List<Account>{ branch1, branch2, branch3 };

        Test.startTest();

        Map<String, User> mapBtoAM = AccountBranch.getBranchNumbersToAreaManagers();

        Test.stopTest();

        System.assertEquals(true, mapBtoAM.containsKey('00001'));
        System.assertEquals(true, mapBtoAM.containsKey('00002'));
        System.assertEquals(true, mapBtoAM.containsKey('00003'));

        System.assertEquals(am1.Id, mapBtoAM.get('00001').Id);
        System.assertEquals(am2.Id, mapBtoAM.get('00002').Id);
        System.assertEquals(am2.Id, mapBtoAM.get('00003').Id);
    }

    /**
     * @description testUpdateAreaManagerEmails_1 check the Area Manager Email is updated
     * when the owning branch's Branch Manager Email changes.
     */
    @IsTest
    static void testUpdateAreaManagerEmails_1() {
        String amEmail = 'area.manager@bbsi.zzz';

        Account testBranch = testFactory.createAccount('Test Branch', '98662', 'BBSI Branch', false);
        testBranch.External_Id__c = '999';
        insert testBranch;

        Account testClient = testFactory.createAccount('Test Client', '98662', 'Client', false);
        testClient.Prospect_Branch__c = testBranch.Id;
        insert testClient;

        testClient = [SELECT Id, Area_Manager_Email__c FROM Account WHERE Id = :testClient.Id];
        System.assertEquals(null, testClient.Area_Manager_Email__c);

        Test.startTest();

        testBranch.Branch_Manager_Email__c = amEmail;
        update testBranch;

        Test.stopTest();

        testClient = [SELECT Id, Area_Manager_Email__c FROM Account WHERE Id = :testClient.Id];
        System.assertEquals(amEmail, testClient.Area_Manager_Email__c);
    }

    /**
     * @description testUpdateAreaManagerEmails_2 check the Area Manager Email is initialized
     * to the owning branch's Branch Manager Email and updated on a change of the owning branch's
     * Branch Manager Email changes.
     */
    @IsTest
    static void testUpdateAreaManagerEmails_2() {
        String amEmailONE = 'area.managerone@bbsi.zzz';
        String amEmailTWO = 'area.managertwo@bbsi.zzz';

        Account testBranch = testFactory.createAccount('Test Branch', '98662', 'BBSI Branch', false);
        testBranch.External_Id__c = '999';
        testBranch.Branch_Manager_Email__c = amEmailONE;
        insert testBranch;

        testBranch = [SELECT Id, Branch_Manager_Email__c FROM Account WHERE Id = :testBranch.Id];
        System.assertEquals(amEmailONE, testBranch.Branch_Manager_Email__c);

        Account testClient = testFactory.createAccount('Test Client', '98662', 'Client', false);
        testClient.Prospect_Branch__c = testBranch.Id;
        insert testClient;

        testClient = [SELECT Id, Area_Manager_Email__c, Prospect_Branch__c FROM Account WHERE Id = :testClient.Id];
        System.assertEquals(amEmailONE, testClient.Area_Manager_Email__c);

        Test.startTest();

        testBranch.Branch_Manager_Email__c = amEmailTWO;
        update testBranch;

        Test.stopTest();

        testClient = [SELECT Id, Area_Manager_Email__c FROM Account WHERE Id = :testClient.Id];
        System.assertEquals(amEmailTWO, testClient.Area_Manager_Email__c);
    }

    /**
     * @description testUpdateAreaManagerEmails_invalid cannot change AM to non-User.
     */
    @IsTest
    static void testUpdateBranchManagerEmails_invalid() {
        Account testBranch = testFactory.createAccount('Test Branch', '98662', 'BBSI Branch', false);
        testBranch.External_Id__c = '999';
        insert testBranch;

        Boolean exceptionThrown = false;

        Test.startTest();

        try {
            testBranch.Branch_Manager__c = 'Failed Test';
            update testBranch;
        } catch (Exception e) {
            exceptionThrown = true;
        }

        Test.stopTest();

        System.assertEquals(true, exceptionThrown, 'Should have thrown an exception');
    }

    /**
     * @description testUpdateAreaManagerEmails_valid change the AM.
     */
    @IsTest
    static void testUpdateBranchManagerEmails_valid() {
        Account testBranch = testFactory.createAccount('Test Branch', '98662', 'BBSI Branch', false);
        testBranch.External_Id__c = '999';
        insert testBranch;

        User userOther = TestFactory.createUser(
            'Test',
            'ztest@bbsihq.zzz',
            'ztest@bbsihq.zzz',
            'BBSI Standard',
            '999',
            false
        );
        User userAM = TestFactory.createUserAM('AM_TEST', '999', false);
        userAM.FirstName = 'Z';
        userAM.Email = 'ztest@bbsihq.zzz';

        insert new List<User>{ userOther, userAM };

        Test.startTest();

        testBranch.Branch_Manager__c = 'Z AM_TEST';
        update testBranch;

        Test.stopTest();

        testBranch = [SELECT Id, Branch_Manager__c, Branch_Manager_Email__c FROM Account WHERE Id = :testBranch.Id];
        System.assertEquals('ztest@bbsihq.zzz', testBranch.Branch_Manager_Email__c);
    }

    /**
     * @description testFutureUpdateUserManagersForBranch
     */
    @IsTest
    static void testFutureUpdateUserManagersForBranch() {
        Account branch1 = TestFactory.createBranchAccount('ONE', '00001', null, null, false);
        Account branch2 = TestFactory.createBranchAccount('TWO', '00002', null, null, false);
        Account branch3 = TestFactory.createBranchAccount('THREE', '00003', null, null, false);
        insert new List<Account>{ branch1, branch2, branch3 };
        User am1 = TestFactory.createUserBDM('AM_1', 'AM001', 'Area Manager', '00001', false);
        am1.FirstName = 'Z';
        User am2 = TestFactory.createUserBDM('AM_2', 'AM002', 'Area Manager', '00002', false);
        am2.FirstName = 'Z';
        User am3 = TestFactory.createUserBDM('AM_3', 'AM003', 'Area Manager', '00003', false);
        am3.FirstName = 'Z';
        insert new List<User>{ am1, am2, am3 };

        branch1.Branch_Manager__c = am1.FirstName + ' ' + am1.LastName;
        branch2.Branch_Manager__c = am2.FirstName + ' ' + am2.LastName;
        branch3.Branch_Manager__c = am2.FirstName + ' ' + am2.LastName;
        update new List<Account>{ branch1, branch2, branch3 };

        User e1 = TestFactory.createUser('AAAA', 'aaaa@bbsihq.zzz', 'aaaa@bbsihq.zzz', 'BBSI Standard', '00001', false);
        e1.ManagerId = am1.Id;
        User e2 = TestFactory.createUser('BBBB', 'bbbb@bbsihq.zzz', 'bbbb@bbsihq.zzz', 'BBSI Standard', '00002', false);
        e2.ManagerId = am2.Id;
        User e3 = TestFactory.createUser('CCCC', 'cccc@bbsihq.zzz', 'cccc@bbsihq.zzz', 'BBSI Standard', '00003', false);
        e3.ManagerId = am2.Id;
        insert new List<User>{ e1, e2, e3 };

        Test.startTest();

        branch3.Branch_Manager__c = am3.Firstname + ' ' + am3.LastName;
        update branch3;

        Test.stopTest();

        Map<Id, User> users = new Map<Id, User>([SELECT Id, Name, ManagerId, Branch_ID__c FROM User]);
        System.assertEquals(null, users.get(am3.Id).ManagerId);
        System.assertEquals(am3.Id, users.get(e3.Id).ManagerId);
    }
}