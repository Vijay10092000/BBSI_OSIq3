/**
 * @description BenefitsAffiliates_TestEnv creates a test environment for
 * testing Benefits affiliated companies.
 */
@IsTest
public without sharing class BenefitsAffiliates_TestEnv {
    private static final String BRANCH_NAME = 'TEST_BRANCH';
    private static final String BRANCH_NUMBER = 'TEST';
    private static final String PROSPECT1_NAME = '!!!PROSPECT_TEST 1';
    private static final String PROSPECT2_NAME = '!!!PROSPECT_TEST 2';
    private static final String PROSPECTA_NAME = '!!!PROSPECT_TEST A';
    private static final String PROSPECTB_NAME = '!!!PROSPECT_TEST B';
    private static final String OPPSINGLE_NAME = 'Benefits: ' + PROSPECT1_NAME;
    private static final String OPPDOUBLE_NAME = 'Benefits: ' + PROSPECTA_NAME;

    public Account branch;
    public Account prospect1;
    public Account prospect2;
    public Account prospectA;
    public Account prospectB;
    public User admin;
    public User owner;
    public User representative;
    public Opportunity oppSingle;
    public Opportunity oppDouble;
    public Benefits_Affiliates__c affiliateSingle;
    public Benefits_Affiliates__c affiliateDouble;

    /**
     * @description BenefitsAffiliates_TestEnv constructor.
     */
    @SuppressWarnings('PMD.EmptyStatementBlock')
    public BenefitsAffiliates_TestEnv() {
    }

    /**
     * @description makeData creates the test data.
     */
    public void makeData() {
        branch = TestFactoryAccount.createBranch(BRANCH_NAME, BRANCH_NUMBER, 'Area Manager', 'area.manager@bbsi.zzz');

        admin = TestFactoryUser.makeUser('TESTING', 'ADMIN', 'System Administrator', BRANCH_NUMBER);
        owner = TestFactoryUser.makeUser('TESTING', 'OWNER', 'BBSI Standard', BRANCH_NUMBER);
        representative = TestFactoryUser.makeUser('TESTING', 'REPRESENTATIVE', 'BBSI Standard', BRANCH_NUMBER);
        insert new List<User>{ admin, owner, representative};

        prospect1 = TestFactoryAccount.makeProspect(PROSPECT1_NAME, null, null);
        prospect1.Benefits_Representative__c = representative.Id;
        prospect1.NumberOfEmployees = 100;
        prospect1.Active_Employees_Full_Time__c = 10;
        prospect1.Active_Employees_Part_Time__c = 1;
        prospect2 = TestFactoryAccount.makeProspect(PROSPECT2_NAME, null, null);
        prospect2.Benefits_Representative__c = representative.Id;
        prospect2.NumberOfEmployees = 200;
        prospect2.Active_Employees_Full_Time__c = 20;
        prospect2.Active_Employees_Part_Time__c = 2;
        prospectA = TestFactoryAccount.makeProspect(PROSPECTA_NAME, null, null);
        prospectA.Benefits_Representative__c = representative.Id;
        prospectA.NumberOfEmployees = 3000;
        prospectA.Active_Employees_Full_Time__c = 300;
        prospectA.Active_Employees_Part_Time__c = 30;
        prospectB = TestFactoryAccount.makeProspect(PROSPECTB_NAME, null, null);
        prospectB.Benefits_Representative__c = representative.Id;
        prospectB.NumberOfEmployees = 4000;
        prospectB.Active_Employees_Full_Time__c = 400;
        prospectB.Active_Employees_Part_Time__c = 40;
        insert new List<Account>{ prospect1, prospect2, prospectA, prospectB };

        oppSingle = TestFactoryOpportunity.makeBenefits(
            OPPSINGLE_NAME,
            prospect1.Id,
            Date.today().addDays(20),
            Opportunity_Service.STAGE_PENDED_UNDERWRITING
        );
        oppSingle.Benefits_Specialist__c = representative.Id;
        oppSingle.Have_Common_Ownership__c = 'Yes';

        oppDouble = TestFactoryOpportunity.makeBenefits(
            OPPDOUBLE_NAME,
            prospectA.Id,
            Date.today().addDays(20),
            Opportunity_Service.STAGE_PENDED_UNDERWRITING
        );
        oppDouble.Benefits_Specialist__c = representative.Id;
        oppDouble.Have_Common_Ownership__c = 'Yes';
        insert new List<Opportunity>{ oppSingle, oppDouble };

        Opportunity tempOpp = [SELECT Id, Benefits_Affiliates__c FROM Opportunity WHERE Id = :oppDouble.Id];

        Assert.isNotNull(tempOpp.Benefits_Affiliates__c);

        prospectB.Benefits_Affiliates__c = tempOpp.Benefits_Affiliates__c;
        update prospectB;
    }

    /**
     * @description loadData read the test data.
     */
    public void loadData() {
        branch = [SELECT Id, Name FROM Account WHERE Name = :BRANCH_NAME LIMIT 1];

        List<User> users = [
            SELECT Id, Name, ProfileId
            FROM User
            WHERE FirstName = 'TESTING' AND Branch_ID__c = :BRANCH_NUMBER
            ORDER BY LastName ASC
        ];
        admin = users.get(0);
        owner = users.get(1);
        representative = users.get(2);

        List<Account> prospects = [
            SELECT
                Id,
                Name,
                OwnerId,
                External_Id__c,
                Benefits_Representative__c,
                Benefits_Affiliated_Companies__c,
                Active_Employees_All_Affiliates__c,
                Full_Time_Employees_All_Affiliates__c,
                Part_Time_Employees_All_Affiliates__c
            FROM Account
            WHERE Name LIKE '!!!PROSPECT_TEST %'
            ORDER BY Name ASC
        ];
        prospect1 = prospects.get(0);
        prospect2 = prospects.get(1);
        prospectA = prospects.get(2);
        prospectB = prospects.get(3);

        List<Opportunity>opps = [
            SELECT
                Id,
                Name,
                OwnerId,
                AccountId,
                StageName,
                Benefits_Consultant__c,
                Benefits_Affiliates__c,
                Benefits_Affiliated_Companies__c,
                Active_Employees_All_Affiliates__c,
                Full_Time_Employees_All_Affiliates__c,
                Part_Time_Employees_All_Affiliates__c
            FROM Opportunity
            WHERE Name LIKE 'Benefits: %'
            ORDER BY Name ASC
        ];
        oppSingle = opps.get(0);
        oppDouble = opps.get(1);

        List<Benefits_Affiliates__c> affiliates = [
            SELECT
                Active_Employees_All_Affiliates__c,
                Benefits__c,
                Benefits_Affiliated_Companies_Count__c,
                Benefits_Affiliated_Companies__c,
                Benefits_Coordinator__c,
                Benefits_Opportunity__c,
                Benefits_Opportunity_Stage__c,
                Benefits_Representative__c,
                Benefits_Type__c,
                Full_Time_Employees_All_Affiliates__c,
                Id,
                Name,
                OwnerId,
                Part_Time_Employees_All_Affiliates__c,
                Primary_Account__c
            FROM Benefits_Affiliates__c
            ORDER BY Name ASC
        ];
        affiliateSingle = affiliates.get(0);
        affiliateDouble = affiliates.get(1);
    }

    @IsTest
    public static void test_Envronment() {
        BenefitsAffiliates_TestEnv env = new BenefitsAffiliates_TestEnv();

        Test.startTest();

        env.makeData();

        Test.stopTest();

        env.loadData();

        String companies;

        Assert.areEqual(env.prospect1.Id, env.oppSingle.AccountId, 'Single Opportunity has Prospect1 as its account');
        Assert.areEqual(env.affiliateSingle.Id, env.oppSingle.Benefits_Affiliates__c, 'Single Opportunity related to affiliateSingle');
        Assert.areEqual(env.prospectA.Id, env.oppDouble.AccountId, 'Double Opportunity has ProspectA as its account');
        Assert.areEqual(env.affiliateDouble.Id, env.oppDouble.Benefits_Affiliates__c, 'Single Opportunity related to affiliateDouble');

        companies = env.prospect1.External_Id__c + '  ' + env.prospect1.Name;
        Assert.areEqual(env.prospect1.Name, env.affiliateSingle.Name, 'Name start same as the prospect');
        Assert.areEqual(env.prospect1.Id, env.affiliateSingle.Primary_Account__c, 'Belongs to the prospect account');
        Assert.areEqual(companies, env.affiliateSingle.Benefits_Affiliated_Companies__c, 'Should set affiliated companies');
        Assert.areEqual(1, env.affiliateSingle.Benefits_Affiliated_Companies_Count__c, 'Should set count');
        Assert.areEqual(100, env.affiliateSingle.Active_Employees_All_Affiliates__c, 'Should set count');
        Assert.areEqual(10, env.affiliateSingle.Full_Time_Employees_All_Affiliates__c, 'Should set count');
        Assert.areEqual(1, env.affiliateSingle.Part_Time_Employees_All_Affiliates__c, 'Should set count');
        Assert.areEqual(null, env.affiliateSingle.Benefits__c, 'No Benefits, yet');
        Assert.areEqual(null, env.affiliateSingle.Benefits_Coordinator__c, 'No Benefits_Coordinator__c, yet');
        Assert.areEqual(env.representative.Id, env.affiliateSingle.Benefits_Representative__c, 'Should set specialist');
        Assert.areEqual(env.oppSingle.Id, env.affiliateSingle.Benefits_Opportunity__c, 'Opportunity should have a value');
        Assert.areEqual(env.oppSingle.StageName, env.affiliateSingle.Benefits_Opportunity_Stage__c, 'Opportuntiy stage is wrong');

        Assert.areEqual(env.prospectA.Name, env.affiliateDouble.Name, 'Name start same as the prospect');
        Assert.areEqual(env.prospectA.Id, env.affiliateDouble.Primary_Account__c, 'Belongs to the prospect account');
        Assert.isNotNull(env.affiliateDouble.Benefits_Affiliated_Companies__c, 'Should set affiliated companies');
        Assert.areEqual(2, env.affiliateDouble.Benefits_Affiliated_Companies_Count__c, 'Should set count');
        Assert.areEqual(7000, env.affiliateDouble.Active_Employees_All_Affiliates__c, 'Should set count');
        Assert.areEqual(700, env.affiliateDouble.Full_Time_Employees_All_Affiliates__c, 'Should set count');
        Assert.areEqual(70, env.affiliateDouble.Part_Time_Employees_All_Affiliates__c, 'Should set count');
        Assert.areEqual(null, env.affiliateDouble.Benefits__c, 'No Benefits, yet');
        Assert.areEqual(null, env.affiliateDouble.Benefits_Coordinator__c, 'No Benefits_Coordinator__c, yet');
        Assert.areEqual(env.representative.Id, env.affiliateDouble.Benefits_Representative__c, 'Should set specialist');
        Assert.areEqual(env.oppDouble.Id, env.affiliateDouble.Benefits_Opportunity__c, 'Opportunity should have a value');
        Assert.areEqual(env.oppDouble.StageName, env.affiliateDouble.Benefits_Opportunity_Stage__c, 'Opportuntiy stage is wrong');

        Assert.areEqual(null, env.prospect2.Benefits_Affiliated_Companies__c, 'Companies should NOT be set');
        Assert.areEqual(0, env.prospect2.Active_Employees_All_Affiliates__c, 'No Employees');
        Assert.areEqual(0, env.prospect2.Full_Time_Employees_All_Affiliates__c, 'No Fulltime');
        Assert.areEqual(0, env.prospect2.Part_Time_Employees_All_Affiliates__c, 'No Parttime');
    }

    /**
     * @description assertCompanyData asserts the Benefits Affiliates company
     * data is the same between the two objects.
     * @param  expect  Object with the data expected
     * @param  actual  Object with data comparing
     */
    public static void assertCompanyData(SObject expect, SObject actual) {
        Assert.areEqual(expect.get('Benefits_Affiliated_Companies__c'), actual.get('Benefits_Affiliated_Companies__c'), 'Companies should be the same');
        Assert.areEqual(expect.get('Active_Employees_All_Affiliates__c'), actual.get('Active_Employees_All_Affiliates__c'), 'Active Employees should be the same');
        Assert.areEqual(expect.get('Full_Time_Employees_All_Affiliates__c'), actual.get('Full_Time_Employees_All_Affiliates__c'), 'Fulltime Employees should be the same');
        Assert.areEqual(expect.get('Part_Time_Employees_All_Affiliates__c'), actual.get('Part_Time_Employees_All_Affiliates__c'), 'ParttimeEmployees should be the same');
    }

    /**
     * @description assertCompanyData asserts the Benefits Affiliates company
     * data is the same between the two objects.
     * @param  actual     Object with data checking
     * @param  companies  Expected company list
     * @param  active     Number of active Employees
     * @param  fulltime   Number of fulltime Employees
     * @param  parttime   Number of parttime Employees
     */
    public static void assertCompanyData(SObject actual, String companies, Integer active, Integer fulltime, Integer parttime) {
        Assert.areEqual(companies, actual.get('Benefits_Affiliated_Companies__c'), 'Companies incorrect');
        Assert.areEqual(active, actual.get('Active_Employees_All_Affiliates__c'), 'Active Employees incorrect');
        Assert.areEqual(fulltime, actual.get('Full_Time_Employees_All_Affiliates__c'), 'Fulltime Employees incorrect');
        Assert.areEqual(parttime, actual.get('Part_Time_Employees_All_Affiliates__c'), 'Parttime Employees incorrect');
    }

    /**
     * @description readProspects reads the Benefits Affiliation data from
     * the environment's prospect accounts.
     * @return  Map<Id, Account>
     */
    public static Map<Id, Account> readProspects() {
        return new Map<Id, Account>([
            SELECT
                Id,
                Name,
                OwnerId,
                Benefits_Representative__c,
                Benefits_Affiliates__c,
                Benefits_Affiliated_Companies__c,
                Active_Employees_All_Affiliates__c,
                Full_Time_Employees_All_Affiliates__c,
                Part_Time_Employees_All_Affiliates__c
            FROM Account
            WHERE Name LIKE '!!!PROSPECT_TEST %'
        ]);
    }

    /**
     * @description readOpportunies reads the Benefits Affiliation data from
     * the environment's prospect accounts.
     * @return  Map<Id, Opportunity>
     */
    public static Map<Id, Opportunity> readOpportunies() {
        return new Map<Id, Opportunity>([
            SELECT
                Id,
                Name,
                OwnerId,
                StageName,
                Benefits_Affiliates__c,
                Benefits_Affiliated_Companies__c,
                Active_Employees_All_Affiliates__c,
                Full_Time_Employees_All_Affiliates__c,
                Part_Time_Employees_All_Affiliates__c
            FROM Opportunity
            WHERE Name LIKE 'Benefits: %'
        ]);
    }
}