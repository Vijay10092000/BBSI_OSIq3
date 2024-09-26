/**
 * @description Account_ChangeOwnerTriggerTest contains tests to confirm change owner when ???.
 */
@IsTest
public class Account_ChangeOwnerTriggerTest {
	/**
	 * @description test_AccountUpdate tests changing owner changes branch.
	 */
	@IsTest
	static void test_AccountUpdate() {
		User am = TestFactoryUser.makeAreaManager('Test', 'AreaManager', '9001');
		User user = testFactoryUser.makeUser('Test', 'User', 'BBSI Standard', '9002');

		Account branch1 = TestFactoryAccount.createBranch('TEST BRANCH', '9001', 'Test AreaManager', am.Email);
		Account branch2 = TestFactoryAccount.createBranch('TEST BRANCH', '9002', 'Test AreaManager', am.Email);

		insert new List<User>{ am, user };

		Account client = testFactoryAccount.createClient('!!!TEST CLIENT', null, null);
		Assert.areNotEqual(am.Id, client.OwnerId);
		Assert.areNotEqual(branch1.Id, client.Prospect_Branch__c);

		Test.startTest();

		client.OwnerId = am.Id;
		update client;

		client = [SELECT Id, OwnerId, Prospect_Branch__c FROM Account WHERE Id = :client.Id];
		Assert.areEqual(am.Id, client.OwnerId);
		Assert.areEqual(branch1.Id, client.Prospect_Branch__c);

		Test.stopTest();

		client.OwnerId = user.Id;
		update client;

		client = [SELECT Id, OwnerId, Prospect_Branch__c FROM Account WHERE Id = :client.Id];
		Assert.areEqual(user.Id, client.OwnerId);
		Assert.areEqual(branch2.Id, client.Prospect_Branch__c);
    }
}