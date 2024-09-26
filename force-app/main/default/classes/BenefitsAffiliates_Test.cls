/**
 * @description BenefitsAffiliates_Test contains tests for the BenefitsAffiliates class.
 */
@IsTest
@SuppressWarnings('PMD.ApexAssertionsShouldIncludeMessage')
public without sharing class BenefitsAffiliates_Test {
	private static final String FAKE_ACCOUNT_ID = '0012f00000XFAKEID1';
	private static final String FAKE_OPPORTUNITY_ID = '006D500000XFAKEID1';

	private static final String BRANCH_NAME = 'TEST_BRANCH';
	private static final String BRANCH_NUMBER = 'TEST';

	private static final String PROSPECT1_NAME = '!!!PROSPECT_TEST 1';
	private static final String PROSPECT2_NAME = '!!!PROSPECT_TEST 2';
	private static final String PROSPECT3_NAME = '!!!PROSPECT_TEST 3';

	private static final String OPP1_NAME = 'Benefits: ' + PROSPECT1_NAME;

	public static Account branch;
	public static Account prospect1;
	public static Account prospect2;
	public static Account prospect3;
	public static User admin;
	public static User owner;
	public static User representative;
	public static User coordinator;
	public static User specialist;
	public static Opportunity opp1;

	@TestSetup
	static void makeData() {
		branch = TestFactoryAccount.createBranch(BRANCH_NAME, BRANCH_NUMBER, 'Area Manager', 'area.manager@bbsi.zzz');

		admin = TestFactoryUser.makeUser('TESTING', 'ADMIN', 'System Administrator', BRANCH_NUMBER);
		coordinator = TestFactoryUser.makeUser('TESTING', 'COORDINATOR', 'BBSI Standard', BRANCH_NUMBER);
		owner = TestFactoryUser.makeUser('TESTING', 'OWNER', 'BBSI Standard', BRANCH_NUMBER);
		representative = TestFactoryUser.makeUser('TESTING', 'REPRESENTATIVE', 'BBSI Standard', BRANCH_NUMBER);
		specialist = TestFactoryUser.makeUser('TESTING', 'SPECIALIST', 'BBSI Standard', BRANCH_NUMBER);
		insert new List<User>{ admin, coordinator, owner, representative, specialist };

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
		prospect3 = TestFactoryAccount.makeProspect(PROSPECT3_NAME, null, null);
		prospect3.Benefits_Representative__c = representative.Id;
		prospect3.NumberOfEmployees = 300;
		prospect3.Active_Employees_Full_Time__c = 30;
		prospect3.Active_Employees_Part_Time__c = 3;

		insert new List<Account>{ prospect1, prospect2, prospect3 };

		opp1 = TestFactoryOpportunity.makeBenefits(
			OPP1_NAME,
			prospect1.Id,
			Date.today().addDays(20),
			Opportunity_Service.STAGE_PENDED_UNDERWRITING
		);

		opp1.Benefits_Specialist__c = specialist.Id;

		insert new List<Opportunity>{ opp1 };
	}

	static void loadData() {
		loadUsers();
		loadAccounts();
		loadOpportunities();
	}

	static void loadUsers() {
		List<User> users = [
			SELECT Id, Name, ProfileId
			FROM User
			WHERE FirstName = 'TESTING' AND Branch_ID__c = :BRANCH_NUMBER
			ORDER BY LastName ASC
		];
		admin = users.get(0);
		owner = users.get(1);
		coordinator = users.get(2);
		representative = users.get(3);
		specialist = users.get(4);
	}

	private static void loadAccounts() {
		branch = [SELECT Id, Name FROM Account WHERE Name = :BRANCH_NAME LIMIT 1];

		List<Account> prospects = [
			SELECT
				Id,
				Name,
				OwnerId,
				External_Id__c,
				NumberOfEmployees,
				Active_Employees_Full_Time__c,
				Active_Employees_Part_Time__c,
				Benefits_Representative__c,
				Benefits_Affiliates__c,
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
		prospect3 = prospects.get(2);
	}

	static void loadOpportunities() {
		List<Opportunity> opps = [
			SELECT
				Id,
				Name,
				OwnerId,
				AccountId,
				StageName,
				Benefits_Affiliates__c,
				Benefits_Specialist__c,
				Benefits_Consultant__c,
				Benefits_Coordinator__c,
				Benefits_Type__c,
				Have_Common_Ownership__c,
				Benefits_Affiliated_Companies__c,
				Active_Employees_All_Affiliates__c,
				Full_Time_Employees_All_Affiliates__c,
				Part_Time_Employees_All_Affiliates__c
			FROM Opportunity
			WHERE Name LIKE 'Benefits: %'
			ORDER BY Name ASC
		];
		opp1 = opps.get(0);
	}

	static Benefits_Affiliates__c getBenefitsAffiliates(Id idBA) {
		return [
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
			WHERE Id = :idBA
		];
	}

	@IsTest
	public static void test_make() {
		loadData();

		Assert.isNull(prospect1.Benefits_Affiliates__c);
		Assert.isNull(opp1.Benefits_Affiliates__c);
		Assert.areEqual(prospect1.Id, opp1.AccountId);

		Test.startTest();

		opp1.Have_Common_Ownership__c = 'Yes';
		update opp1;

		Test.stopTest();

		loadData();

		Id idBA = prospect1.Benefits_Affiliates__c;
		Assert.isNotNull(idBA);

		Benefits_Affiliates__c ba = getBenefitsAffiliates(idBA);
		Assert.isNotNull(ba);
		Assert.areEqual(100, ba.Active_Employees_All_Affiliates__c);
		Assert.areEqual(10, ba.Full_Time_Employees_All_Affiliates__c);
		Assert.areEqual(1, ba.Part_Time_Employees_All_Affiliates__c);

		Assert.areEqual(prospect1.Name, ba.Name);
		Assert.areEqual(prospect1.Id, ba.Primary_Account__c);

		Assert.areEqual(prospect1.NumberOfEmployees, ba.Active_Employees_All_Affiliates__c);
		Assert.areEqual(prospect1.Active_Employees_Full_Time__c, ba.Full_Time_Employees_All_Affiliates__c);
		Assert.areEqual(prospect1.Active_Employees_Part_Time__c, ba.Part_Time_Employees_All_Affiliates__c);

		Assert.areEqual(opp1.Id, ba.Benefits_Opportunity__c);
		Assert.areEqual(opp1.Active_Employees_All_Affiliates__c, ba.Active_Employees_All_Affiliates__c);
		Assert.areEqual(opp1.Full_Time_Employees_All_Affiliates__c, ba.Full_Time_Employees_All_Affiliates__c);
		Assert.areEqual(opp1.Part_Time_Employees_All_Affiliates__c, ba.Part_Time_Employees_All_Affiliates__c);

		Assert.isNull(ba.Benefits__c);
	}

	@IsTest
	public static void test_updateEmployees() {
		loadData();

		Assert.isNull(prospect1.Benefits_Affiliates__c);
		Assert.isNull(opp1.Benefits_Affiliates__c);
		Assert.areEqual(prospect1.Id, opp1.AccountId);

		System.runAs(admin) {
			opp1.Have_Common_Ownership__c = 'Yes';
			update opp1;
		}

		loadAccounts();

		Test.startTest();

		Id idBA = prospect1.Benefits_Affiliates__c;
		Assert.isNotNull(idBA);

		prospect1.NumberOfEmployees = 500;
		prospect1.Active_Employees_Full_Time__c = 450;
		prospect1.Active_Employees_Part_Time__c = 50;
		update prospect1;  // DID NOT UPDATE !!!

		Test.stopTest();

		loadData();

		idBA = prospect1.Benefits_Affiliates__c;
		Assert.isNotNull(idBA);

		Benefits_Affiliates__c ba = getBenefitsAffiliates(idBA);
		Assert.isNotNull(ba);
		Assert.areEqual(500, ba.Active_Employees_All_Affiliates__c);
		Assert.areEqual(450, ba.Full_Time_Employees_All_Affiliates__c);
		Assert.areEqual(50, ba.Part_Time_Employees_All_Affiliates__c);

		Assert.areEqual(prospect1.Name, ba.Name);
		Assert.areEqual(prospect1.Id, ba.Primary_Account__c);

		Assert.areEqual(prospect1.NumberOfEmployees, ba.Active_Employees_All_Affiliates__c);
		Assert.areEqual(prospect1.Active_Employees_Full_Time__c, ba.Full_Time_Employees_All_Affiliates__c);
		Assert.areEqual(prospect1.Active_Employees_Part_Time__c, ba.Part_Time_Employees_All_Affiliates__c);

		Assert.areEqual(opp1.Id, ba.Benefits_Opportunity__c);
		Assert.areEqual(opp1.Active_Employees_All_Affiliates__c, ba.Active_Employees_All_Affiliates__c);
		Assert.areEqual(opp1.Full_Time_Employees_All_Affiliates__c, ba.Full_Time_Employees_All_Affiliates__c);
		Assert.areEqual(opp1.Part_Time_Employees_All_Affiliates__c, ba.Part_Time_Employees_All_Affiliates__c);

		Assert.isNull(ba.Benefits__c);
	}

	@IsTest
	public static void test_addProspect() {
		loadData();

		Assert.isNull(prospect1.Benefits_Affiliates__c);
		Assert.isNull(opp1.Benefits_Affiliates__c);
		Assert.areEqual(prospect1.Id, opp1.AccountId);

		System.runAs(admin) {
			opp1.Have_Common_Ownership__c = 'Yes';
			update opp1;
		}

		loadAccounts();

		Test.startTest();

		prospect2.Benefits_Affiliates__c = prospect1.Benefits_Affiliates__c;
		update prospect2;

		Test.stopTest();

		loadData();

		Id idBA = prospect2.Benefits_Affiliates__c;
		Assert.isNotNull(idBA);

		Benefits_Affiliates__c ba = getBenefitsAffiliates(idBA);
		Assert.isNotNull(ba);

		Assert.areEqual(300, ba.Active_Employees_All_Affiliates__c);
		Assert.areEqual(30, ba.Full_Time_Employees_All_Affiliates__c);
		Assert.areEqual(3, ba.Part_Time_Employees_All_Affiliates__c);

		Assert.areEqual(prospect1.Name, ba.Name);
		Assert.areEqual(prospect1.Id, ba.Primary_Account__c);

		Assert.areEqual(prospect1.Active_Employees_All_Affiliates__c, ba.Active_Employees_All_Affiliates__c);
		Assert.areEqual(prospect1.Full_Time_Employees_All_Affiliates__c, ba.Full_Time_Employees_All_Affiliates__c);
		Assert.areEqual(prospect1.Part_Time_Employees_All_Affiliates__c, ba.Part_Time_Employees_All_Affiliates__c);

		Assert.areEqual(prospect2.Active_Employees_All_Affiliates__c, ba.Active_Employees_All_Affiliates__c);
		Assert.areEqual(prospect2.Full_Time_Employees_All_Affiliates__c, ba.Full_Time_Employees_All_Affiliates__c);
		Assert.areEqual(prospect2.Part_Time_Employees_All_Affiliates__c, ba.Part_Time_Employees_All_Affiliates__c);

		Assert.areEqual(opp1.Id, ba.Benefits_Opportunity__c);
		Assert.areEqual(opp1.Active_Employees_All_Affiliates__c, ba.Active_Employees_All_Affiliates__c);
		Assert.areEqual(opp1.Full_Time_Employees_All_Affiliates__c, ba.Full_Time_Employees_All_Affiliates__c);
		Assert.areEqual(opp1.Part_Time_Employees_All_Affiliates__c, ba.Part_Time_Employees_All_Affiliates__c);

		Assert.isNull(ba.Benefits__c);
	}

	@IsTest
	public static void test_removeProspect() {
		loadData();

		Test.startTest();
		
		Assert.isNull(prospect1.Benefits_Affiliates__c);
		Assert.isNull(opp1.Benefits_Affiliates__c);
		Assert.areEqual(prospect1.Id, opp1.AccountId);

		System.runAs(admin) {
			opp1.Have_Common_Ownership__c = 'Yes';
			update opp1;
		}

		System.runAs(admin) {
			prospect2.Benefits_Affiliates__c = prospect1.Benefits_Affiliates__c;
			update prospect2;
		}


		prospect2.Benefits_Affiliates__c = null;
		update prospect2;

		Test.stopTest();

		loadData();

		Assert.isNull(prospect2.Benefits_Affiliates__c);
		Assert.areEqual(0, prospect2.Active_Employees_All_Affiliates__c);
		Assert.areEqual(0, prospect2.Full_Time_Employees_All_Affiliates__c);
		Assert.areEqual(0, prospect2.Part_Time_Employees_All_Affiliates__c);

		Id idBA = prospect1.Benefits_Affiliates__c;
		Assert.isNotNull(idBA);

		Benefits_Affiliates__c ba = getBenefitsAffiliates(idBA);
		Assert.isNotNull(ba);

		Assert.areEqual(prospect1.Name, ba.Name);
		Assert.areEqual(prospect1.Id, ba.Primary_Account__c);
		Assert.areEqual(prospect1.NumberOfEmployees, ba.Active_Employees_All_Affiliates__c);
		Assert.areEqual(prospect1.Active_Employees_Full_Time__c, ba.Full_Time_Employees_All_Affiliates__c);
		Assert.areEqual(prospect1.Active_Employees_Part_Time__c, ba.Part_Time_Employees_All_Affiliates__c);

		Assert.areEqual(opp1.Id, ba.Benefits_Opportunity__c);
		Assert.areEqual(opp1.Active_Employees_All_Affiliates__c, ba.Active_Employees_All_Affiliates__c);
		Assert.areEqual(opp1.Full_Time_Employees_All_Affiliates__c, ba.Full_Time_Employees_All_Affiliates__c);
		Assert.areEqual(opp1.Part_Time_Employees_All_Affiliates__c, ba.Part_Time_Employees_All_Affiliates__c);

		Assert.isNull(ba.Benefits__c);
	}

	@IsTest
	public static void test_changePrimary() {
		loadData();

		Assert.isNull(prospect1.Benefits_Affiliates__c);
		Assert.isNull(opp1.Benefits_Affiliates__c);
		Assert.areEqual(prospect1.Id, opp1.AccountId);

		System.runAs(admin) {
			opp1.Have_Common_Ownership__c = 'Yes';
			update opp1;
		}

		loadAccounts();

		Test.startTest();

		prospect2.Benefits_Affiliates__c = prospect1.Benefits_Affiliates__c;
		update prospect2;

		Benefits_Affiliates__c ba = getBenefitsAffiliates(prospect1.Benefits_Affiliates__c);
		ba.Primary_Account__c = prospect2.Id;
		update ba;

		Test.stopTest();

		loadData();

		Id idBA = prospect2.Benefits_Affiliates__c;
		Assert.isNotNull(idBA);

		ba = getBenefitsAffiliates(idBA);
		Assert.isNotNull(ba);

		Assert.areEqual(prospect2.Id, ba.Primary_Account__c);
		Assert.areEqual(300, ba.Active_Employees_All_Affiliates__c);
		Assert.areEqual(30, ba.Full_Time_Employees_All_Affiliates__c);
		Assert.areEqual(3, ba.Part_Time_Employees_All_Affiliates__c);

		Assert.areEqual(prospect1.Name, ba.Name);
		Assert.areEqual(prospect2.Id, ba.Primary_Account__c);

		Assert.areEqual(prospect1.Active_Employees_All_Affiliates__c, ba.Active_Employees_All_Affiliates__c);
		Assert.areEqual(prospect1.Full_Time_Employees_All_Affiliates__c, ba.Full_Time_Employees_All_Affiliates__c);
		Assert.areEqual(prospect1.Part_Time_Employees_All_Affiliates__c, ba.Part_Time_Employees_All_Affiliates__c);

		Assert.areEqual(prospect2.Active_Employees_All_Affiliates__c, ba.Active_Employees_All_Affiliates__c);
		Assert.areEqual(prospect2.Full_Time_Employees_All_Affiliates__c, ba.Full_Time_Employees_All_Affiliates__c);
		Assert.areEqual(prospect2.Part_Time_Employees_All_Affiliates__c, ba.Part_Time_Employees_All_Affiliates__c);

		Assert.areEqual(opp1.Id, ba.Benefits_Opportunity__c);
		Assert.areEqual(opp1.Active_Employees_All_Affiliates__c, ba.Active_Employees_All_Affiliates__c);
		Assert.areEqual(opp1.Full_Time_Employees_All_Affiliates__c, ba.Full_Time_Employees_All_Affiliates__c);
		Assert.areEqual(opp1.Part_Time_Employees_All_Affiliates__c, ba.Part_Time_Employees_All_Affiliates__c);

		Assert.isNull(ba.Benefits__c);
	}

	@IsTest
	public static void test_removePrimary() {
		loadData();

		Assert.isNull(prospect1.Benefits_Affiliates__c);
		Assert.isNull(opp1.Benefits_Affiliates__c);
		Assert.areEqual(prospect1.Id, opp1.AccountId);

		System.runAs(admin) {
			opp1.Have_Common_Ownership__c = 'Yes';
			update opp1;
		}

		loadAccounts();

		Benefits_Affiliates__c ba = getBenefitsAffiliates(prospect1.Benefits_Affiliates__c);
		Assert.areEqual(prospect1.Id, ba.Primary_Account__c);

		Test.startTest();

		try {
			prospect1.Benefits_Affiliates__c = null;
			update prospect1;

			Assert.isTrue(false, 'Exception should be thrown, cannot remove primary account');
		} catch (Exception e) {
			Assert.isTrue(true, 'Exception should be thrown, cannot remove primary account');
		}

		Test.stopTest();
	}

	@IsTest
	public static void test_removeAffiliates() {
		loadData();

		Assert.isNull(prospect1.Benefits_Affiliates__c);
		Assert.isNull(opp1.Benefits_Affiliates__c);
		Assert.areEqual(prospect1.Id, opp1.AccountId);

		System.runAs(admin) {
			opp1.Have_Common_Ownership__c = 'Yes';
			update opp1;
		}

		loadAccounts();
		Assert.isNotNull(prospect1.Benefits_Affiliates__c);

		loadOpportunities();
		Assert.isNotNull(opp1.Benefits_Affiliates__c);
		Assert.isNotNull(opp1.Benefits_Affiliated_Companies__c);

		Test.startTest();

		Benefits_Affiliates__c ba = getBenefitsAffiliates(prospect1.Benefits_Affiliates__c);

		delete ba;

		Test.stopTest();

		loadAccounts();
		Assert.isNull(prospect1.Benefits_Affiliates__c);
		Assert.areEqual(100, prospect1.NumberOfEmployees);
		Assert.areEqual(10, prospect1.Active_Employees_Full_Time__c);
		Assert.areEqual(1, prospect1.Active_Employees_Part_Time__c);
		Assert.areEqual(0, prospect1.Active_Employees_All_Affiliates__c);
		Assert.areEqual(0, prospect1.Full_Time_Employees_All_Affiliates__c);
		Assert.areEqual(0, prospect1.Part_Time_Employees_All_Affiliates__c);
		Assert.isNull(prospect1.Benefits_Affiliates__c);
		Assert.isNull(prospect1.Benefits_Affiliated_Companies__c);

		loadOpportunities();
		Assert.areEqual(100, opp1.Active_Employees_All_Affiliates__c);
		Assert.areEqual(10, opp1.Full_Time_Employees_All_Affiliates__c);
		Assert.areEqual(1, opp1.Part_Time_Employees_All_Affiliates__c);
		Assert.isNull(opp1.Benefits_Affiliates__c);
		Assert.isNull(opp1.Benefits_Affiliated_Companies__c);
	}

	@IsTest
	public static void test_removeAffiliates_FAIL() {
		loadData();

		Assert.isNull(prospect1.Benefits_Affiliates__c);
		Assert.isNull(opp1.Benefits_Affiliates__c);
		Assert.areEqual(prospect1.Id, opp1.AccountId);

		System.runAs(admin) {
			opp1.Have_Common_Ownership__c = 'Yes';
			update opp1;
		}

		Test.startTest();

		loadAccounts();

		Benefits_Affiliates__c ba = getBenefitsAffiliates(prospect1.Benefits_Affiliates__c);

		prospect2.Benefits_Affiliates__c = prospect1.Benefits_Affiliates__c;
		update prospect2;

		try {
			delete ba;
			Assert.isTrue(false, 'Exception should be thrown, cannot remove affiliate with mulitple accounts.');
		} catch (Exception e) {
			Assert.isTrue(true, 'Exception should be thrown, cannot remove affiliate with mulitple accounts.');
		}

		Test.stopTest();
	}
    
    //This  Method Added For Benefits Phase 2- Commissions 
    @IsTest
	public static void test_selectAffiliatesByName() {
		loadData();

		Assert.isNull(prospect1.Benefits_Affiliates__c);
		Assert.isNull(opp1.Benefits_Affiliates__c);
		Assert.areEqual(prospect1.Id, opp1.AccountId);

		System.runAs(admin) {
			opp1.Have_Common_Ownership__c = 'Yes';
			update opp1;
		}

		loadAccounts();
		Assert.isNotNull(prospect1.Benefits_Affiliates__c);

		loadOpportunities();
		Assert.isNotNull(opp1.Benefits_Affiliates__c);
		Assert.isNotNull(opp1.Benefits_Affiliated_Companies__c);

		Test.startTest();
		Benefits_Affiliates__c ba = getBenefitsAffiliates(prospect1.Benefits_Affiliates__c);
		Map<Id, Benefits_Affiliates__c> baMap = BenefitsAffiliates.selectAffiliates(new Set<String> { ba.Name} );        
		Test.stopTest();
        Benefits__c ben = new Benefits__c();
        ben.Full_Time_Employees_All_Affiliates__c = 10;
        ben.Part_Time_Employees_All_Affiliates__c = 20;
        ben.Active_Employees_All_Affiliates__c = 30;
        ben.AccountId__c=prospect1.id;
        ben.Opportunity__c = opp1.Id;
        ba.Benefits__c = ben.Id;
        BenefitsAffiliates.make(new Map<Id, Benefits__c> {prospect1.Id => new Benefits__c(Benefits_Specialist__c = specialist.Id)});
        BenefitsAffiliates.updateFromBenefits(null, new List<Benefits_Affiliates__c>{ba});
        BenefitsAffiliates.clearAffiliatesData(ben, null, null);
        BenefitsAffiliates.deleteAffiliates(new Set<Id>{ba.Id});
		Assert.isNotNull(baMap);
		Assert.areEqual(1, baMap.size());
		Assert.areEqual(ba.Name, baMap.values()[0].Name);
	}
}