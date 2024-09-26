/**
 * @description AccountHub_Test contains tests for the AccountHub class.
 */
@IsTest
public without sharing class AccountHub_Test {
	private static Account hub1;
	private static Account branch1;
	private static Account branch2;
	private static Account client1;
	private static Account client2;

    @TestSetup
	static void makeData() {
		hub1 = TestFactoryAccount.makeAccount('TEST_HUB_ONE', 'BBSI Hub');
		hub1.Region__c = 'HUB REGION';
		insert new List<Account>{ hub1 };

		branch1 = TestFactoryAccount.makeBranch('TEST_BRANCH_ONE', 'TEST_ONE', 'Area One', 'one@bbsi.zzz');
		branch1.BBSI_Hub__c = hub1.Id;
		branch2 = TestFactoryAccount.makeBranch('TEST_BRANCH_TWO', 'TEST_TWO', 'Area Two', 'two@bbsi.zzz');
		insert new List<Account>{ branch1, branch2 };

		client1 = TestFactoryAccount.makeClient('TEST_CLIENT_ONE', null, null);
		client1.Prospect_Branch__c = branch1.Id;
		client2 = TestFactoryAccount.makeClient('TEST_CLIENT_TWO', null, null);
		insert new List<Account>{ client1, client2 };
	}

	static void loadData() {
		List<Account> accounts = [
			SELECT Id, Name, BBSI_Hub__c, Region__c, Region_Client__c, Prospect_Branch__c
			FROM Account
			WHERE Name LIKE 'TEST_%'
			ORDER BY Name ASC
		];

		Assert.areEqual(5, accounts.size(), 'Should start with 5 accounts');

		branch1 = accounts.get(0);
		branch2 = accounts.get(1);
		client1 = accounts.get(2);
		client2 = accounts.get(3);
		hub1 = accounts.get(4);

		Assert.areEqual(hub1.Id, branch1.BBSI_Hub__c, 'Should set initially');
		Assert.areEqual(hub1.Region__c, branch1.Region__c, 'Should set initially');
		Assert.areEqual(branch1.Id, client1.Prospect_Branch__c, 'Should set initially');
		Assert.areEqual(hub1.Region__c, client1.Region_Client__c, 'Should set initially');
		Assert.isNull(client2.Region_Client__c, 'Should set initially');
	}

	@IsTest
	public static void test_AddBranchToHub() {
		loadData();

		Test.startTest();

		branch2.BBSI_Hub__c = hub1.Id;
		update branch2;

		Test.stopTest();

		branch2 = [SELECT Id, Name, BBSI_Hub__c, Region__c FROM Account WHERE Id = :branch2.Id LIMIT 1];

		Assert.areEqual(hub1.Id, branch2.BBSI_Hub__c, 'Hub should be set');
		Assert.areEqual(hub1.Region__c, branch2.Region__c, 'Branch 2 Region should same as its hub');
	}

	@IsTest
	public static void test_ChangeHubRegion() {
		loadData();

		Test.startTest();

		hub1.Region__c = 'NEW REGION';
		update hub1;

		Test.stopTest();

		loadData();

		branch2 = [SELECT Id, Name, BBSI_Hub__c, Region__c FROM Account WHERE Id = :branch2.Id LIMIT 1];

		Assert.areEqual('NEW REGION', hub1.Region__c, 'Hub region should have changed');
		Assert.areEqual(hub1.Id, branch1.BBSI_Hub__c, 'Hub should be set');
		Assert.areEqual(hub1.Region__c, branch1.Region__c, 'Branch 1 Region should same as its hub');
	}

	@IsTest
	public static void test_getHubBranches() {
		loadData();

		Test.startTest();

		Map<Id, List<Account>> hubBranches = AccountHub.getHubBranches(new Set<Id>{ hub1.Id });

		Test.stopTest();

		Assert.areEqual(1, hubBranches.size(), 'There is one Hub branch looked for');

		List<Account> branches = hubBranches.get(hub1.Id);

		Assert.areEqual(1, branches.size(), 'Single branch attached to hub1');
		Assert.areEqual(branch1.Id, branches.get(0).Id, 'Single branch attached to hub1');

		Assert.areEqual(hub1.Region__c, branch1.Region__c, 'Branch 1 Region should same as its hub');
	}
}