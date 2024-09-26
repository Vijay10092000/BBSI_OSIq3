@IsTest
@SuppressWarnings('PMD.ApexAssertionsShouldIncludeMessage')
public class BenefitsAffiliatesAccountControllerTest {
	private static final String BRANCH_NUMBER = 'TEST';
	private static final String BRANCH_NAME = 'TEST_BRANCH';
	private static final String PROSPECT_NAME_1 = 'TEST_PROSPECT 1';
	private static final String PROSPECT_NAME_2 = 'TEST_PROSPECT 2';
	private static final String CLIENT_NAME_1 = 'TEST_CLIENT 1';
	private static final String CLIENT_NAME_2 = 'TEST_CLIENT 2';
	private static final String OPPSINGLE_NAME = 'Benefits: ' + PROSPECT_NAME_1;

	private static Account branch;
	private static Account prospect1;
	public static Account prospect2;
	private static Account client1;
	private static Account client2;
	private static Opportunity opp1;
	public static User admin;
	public static User owner;
	public static User representative;
	public static User coordinator;
	public static User specialist;
	private static Benefits_Affiliates__c affiliate;

	/**
	 * @description makeData creates the test data.
	 */
	@TestSetup
	public static void makeData() {
		branch = TestFactoryAccount.createBranch(BRANCH_NAME, BRANCH_NUMBER, 'Area Manager', 'area.manager@bbsi.zzz');

		admin = TestFactoryUser.makeUser('TESTING', 'ADMIN', 'System Administrator', BRANCH_NUMBER);
		owner = TestFactoryUser.makeUser('TESTING', 'OWNER', 'BBSI Standard', BRANCH_NUMBER);
		coordinator = TestFactoryUser.makeUser('TESTING', 'COORDINATOR', 'BBSI Standard', BRANCH_NUMBER);
		representative = TestFactoryUser.makeUser('TESTING', 'REPRESENTATIVE', 'BBSI Standard', BRANCH_NUMBER);
		specialist = TestFactoryUser.makeUser('TESTING', 'SPECIALIST', 'BBSI Standard', BRANCH_NUMBER);
		insert new List<User>{ admin, coordinator, owner, representative, specialist };

		client1 = TestFactoryAccount.makeClient(CLIENT_NAME_1, null, null);
		client1.Benefits_Representative__c = representative.Id;
		client1.NumberOfEmployees = 100;
		client1.Active_Employees_Full_Time__c = 10;
		client1.Active_Employees_Part_Time__c = 1;
		client2 = TestFactoryAccount.makeClient(CLIENT_NAME_2, null, null);
		client2.Benefits_Representative__c = representative.Id;
		client2.NumberOfEmployees = 200;
		client2.Active_Employees_Full_Time__c = 20;
		client2.Active_Employees_Part_Time__c = 2;
		prospect1 = TestFactoryAccount.makeClient(PROSPECT_NAME_1, null, null);
		prospect1.Benefits_Representative__c = representative.Id;
		prospect1.NumberOfEmployees = 100;
		prospect1.Active_Employees_Full_Time__c = 10;
		prospect1.Active_Employees_Part_Time__c = 1;
		prospect2 = TestFactoryAccount.makeClient(PROSPECT_NAME_2, null, null);
		prospect2.Benefits_Representative__c = representative.Id;
		prospect2.NumberOfEmployees = 200;
		prospect2.Active_Employees_Full_Time__c = 20;
		prospect2.Active_Employees_Part_Time__c = 2;
		insert new List<Account>{ prospect1, prospect2, client1, client2 };

		opp1 = TestFactoryOpportunity.makeBenefits(
			OPPSINGLE_NAME,
			prospect1.Id,
			representative.Id,
			Date.today().addDays(20),
			Opportunity_Service.STAGE_PENDED_UNDERWRITING
		);
		opp1.Have_Common_Ownership__c = 'Yes';
		insert opp1;

		Map<Id, Benefits_Affiliates__c> affiliates = BenefitsAffiliates.selectAffiliates(new Set<String>{ prospect1.Name });
		Assert.areEqual(1, affiliates.size());

		prospect2.Benefits_Affiliates__c = affiliates.values().get(0).Id;
		update prospect2;
	}

	/**
	 * @description loadData read the test data.
	 */
	public static void loadData() {
		branch = [SELECT Id, Name FROM Account WHERE Name = :BRANCH_NAME LIMIT 1];

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

		List<Account> accounts = [
			SELECT Id, Name, OwnerId, External_Id__c, Benefits_Affiliated_Companies__c
			FROM Account
			WHERE Name LIKE 'TEST_%'
			ORDER BY Name ASC
		];

		branch = accounts.get(0);
		client1 = accounts.get(1);
		client2 = accounts.get(2);
		prospect1 = accounts.get(3);
		prospect2 = accounts.get(4);

		opp1 = [
			SELECT
				Id,
				Name,
				OwnerId,
				AccountId,
				StageName,
				Benefits_Affiliates__c,
				Benefits_Affiliated_Companies__c,
				Active_Employees_All_Affiliates__c,
				Full_Time_Employees_All_Affiliates__c,
				Part_Time_Employees_All_Affiliates__c
			FROM Opportunity
			WHERE Name LIKE 'Benefits: %'
			LIMIT 1
		];

		affiliate = [
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
				Primary_Account__c,
				Toggle_Update__c
			FROM Benefits_Affiliates__c
			LIMIT 1
		];
	}

	@IsTest
	static void test_getAffiliatedAccounts() {
		loadData();

		Test.startTest();

		List<Account> accounts = BenefitsAffiliatesAccount_Controller.getAffiliatedAccounts(affiliate.Id);

		Test.stopTest();

		Assert.areEqual(2, accounts.size());
		Assert.areEqual(prospect1.Id, accounts[0].Id);
		Assert.areEqual(prospect2.Id, accounts[1].Id);
	}

	@IsTest
	static void test_getSelected() {
		loadData();

		Test.startTest();

		List<Option> options = BenefitsAffiliatesAccount_Controller.getSelected(affiliate.Id);

		Test.stopTest();

		Assert.areEqual(2, options.size());
		Assert.areEqual(prospect1.Id, options[0].value);
		Assert.areEqual(prospect1.Name, options[0].label);
		Assert.areEqual(prospect2.Id, options[1].value);
		Assert.areEqual(prospect2.Name, options[1].label);
	}

	@IsTest
	static void test_getAccounts() {
		loadData();

		Test.startTest();

		List<Option> options = BenefitsAffiliatesAccount_Controller.getAccounts(
			'TEST_',
			new List<Id>{ prospect1.Id, prospect2.Id }
		);

		Test.stopTest();

		Assert.areEqual(4, options.size());
		Assert.areEqual(client1.Id, options[0].value);
		Assert.areEqual(client1.Name, options[0].label);
		Assert.areEqual(client2.Id, options[1].value);
		Assert.areEqual(client2.Name, options[1].label);
		Assert.areEqual(prospect1.Id, options[2].value);
		Assert.areEqual(prospect1.Name, options[2].label);
		Assert.areEqual(prospect2.Id, options[3].value);
		Assert.areEqual(prospect2.Name, options[3].label);
	}

	@IsTest
	static void test_getAccountsClientId() {
		loadData();

		Test.startTest();

		List<Option> options = BenefitsAffiliatesAccount_Controller.getAccounts(
			client1.External_Id__c,
			null
		);

		Test.stopTest();

		Assert.areEqual(1, options.size());
		Assert.areEqual(client1.Id, options[0].value);
		Assert.areEqual(client1.Name, options[0].label);
	}

	@IsTest
	static void test_setSelected() {
		loadData();

		Test.startTest();

		BenefitsAffiliatesAccount_Controller.setSelected(affiliate.Id, new List<Id>{ prospect1.Id, client1.Id });

		Test.stopTest();

		List<Account> accounts = BenefitsAffiliatesAccount_Controller.getAffiliatedAccounts(affiliate.Id);

		Assert.areEqual(2, accounts.size());
		Assert.areEqual(client1.Id, accounts[0].Id);
		Assert.areEqual(prospect1.Id, accounts[1].Id);
	}
}