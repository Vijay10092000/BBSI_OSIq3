/**
 * @description UserAreaManager_Test contains methods to test the UserAreaManager class.
 */
@IsTest
public without sharing class UserAreaManager_Test {
	private static Account client;
	private static Account branch1;
	private static Account branch2;
	private static User bdm;
	private static User areaManager1;
	private static User areaManager2;

	@TestSetup
	static void makeData() {
		client = TestFactoryAccount.makeClient('ClientTest', null, null);
		branch1 = TestFactoryAccount.makeBranch('BranchTest1', '1001', 'AreaManager1', 'areamanager1@bbsi.zzz');
		branch2 = TestFactoryAccount.makeBranch('BranchTest2', '1002', 'AreaManager2', 'areamanager2@bbsi.zzz');
		insert new List<Account>{ client, branch1, branch2 };

		bdm = TestFactoryUser.makeBDM('BDM1', 'BDM', 'BBSI Support', '1001');
		areaManager1 = TestFactoryUser.makeAreaManager(null, 'AreaManager1', '1001');
		areaManager2 = TestFactoryUser.makeAreaManager(null, 'AreaManager2', '1002');
		insert new List<User>{ bdm, areaManager1, areaManager2 };
	}

	static void loadData() {
		List<Account> branches = [SELECT Id, Name, Branch_Manager__c, External_Id__c FROM Account WHERE Name LIKE 'BranchTest%' ORDER BY Name];
		branch1 = branches.get(0);
		branch2 = branches.get(1);

		client = [SELECT Id, Name, Branch_Manager__c, External_Id__c FROM Account WHERE Name = 'ClientTest' LIMIT 1];

		List<User> areaManagers = [SELECT Id, Name, Branch_Id__c FROM User WHERE LastName LIKE 'AreaManager%' ORDER BY Name];
		areaManager1 = areaManagers.get(0);
		areaManager2 = areaManagers.get(1);

		bdm = [SELECT Id, Name FROM User WHERE Name = 'BDM1 BDM' LIMIT 1];
	}

	@IsTest
	static void test_setup() {
		loadData();

		Test.startTest();

		UserAreaManager.setup();

		Test.stopTest();

		Assert.isTrue(UserAreaManager.mapAreaManagers.containsKey(areaManager1.Id));
		Assert.isTrue(UserAreaManager.mapAreaManagers.containsKey(areaManager2.Id));
		Assert.isTrue(UserAreaManager.mapBranchIdToAreaManager.containsKey(branch1.Id));
		Assert.isTrue(UserAreaManager.mapBranchIdToAreaManager.containsKey(branch2.Id));
		Assert.areEqual(areaManager2.Id, UserAreaManager.mapBranchIdToAreaManager.get(branch2.Id).Id);
		Assert.areEqual(areaManager1.Id, UserAreaManager.mapBranchIdToAreaManager.get(branch1.Id).Id);
	}

	@IsTest
	static void test_getAreaManagers() {
		loadData();

		List<User> users = UserAreaManager.getAreaManagers();

		Boolean found = false;
		for (User user : users) {
			if (user.Id == areaManager1.Id) {
				found = true;
				break;
			}
		}

		Assert.isTrue(found, 'AreaManager1 should be in the list.');
	}

	@IsTest
	static void test_isAreaManager() {
		loadData();

		Assert.isTrue(!UserAreaManager.isAreaManagers(bdm.Id));
		Assert.isTrue(UserAreaManager.isAreaManagers(areamanager1.Id));
		Assert.isTrue(UserAreaManager.isAreaManagers(areamanager2.Id));
	}

	@IsTest
	static void test_getBranchAreaManager() {
		loadData();

		Assert.areEqual(areamanager1.Id, UserAreaManager.getBranchAreaManager(branch1.Id).Id);
		Assert.areEqual(areamanager2.Id, UserAreaManager.getBranchAreaManager(branch2.Id).Id);

		Assert.areEqual(null, UserAreaManager.getBranchAreaManager(client.Id));
	}
}