/**
 * @description RenewalChangeOwner_Test contains tests for the RenewalChangeOwner class.
 */
@IsTest
public with sharing class RenewalChangeOwner_Test {
	@IsTest
	public static void test_method() {
		// Testfactory.createAccountBranch('!!! TEST BRANCH', '99999', '0000', true);
		TestFactoryAccount.createBranch('!!! TEST BRANCH', '0000', null, null);

		// User userOne = TestFactory.createUserAM('TEST_ONE', '0000', false);
		User userOne = TestFactoryUser.makeAreaManager(null, 'TEST_ONE', '0000');
		// User userTwo = TestFactory.createUserAM('TEST_TWO', '0000', false);
		User userTwo = TestFactoryUser.makeAreaManager(null, 'TEST_TWO', '0000');
		insert new List<User>{ userOne, userTwo };

		Account client;
		Renewal__c renewal;
		System.runAs(userOne) {
			// client = TestFactory.createAccountClient('!!! TEST CLIENT', true);
			client = TestFactoryAccount.createClient('!!! TEST CLIENT', null, null);

			renewal = new Renewal__c(
				Name = 'Tester DEF',
				FEIN__c = '99-1234567',
				Status__c = 'New'
			);

			insert(renewal);
		}

		renewal = [SELECT Id, OwnerId FROM Renewal__c WHERE Id = :renewal.Id];
		Assert.areEqual(userOne.Id, renewal.OwnerId, 'Owner should userOne to start');

		Test.startTest();

		Account newClient = new Account(
			Id = client.Id,
			OwnerId = userTwo.Id,
			Renewal__c = renewal.Id
		);

		RenewalChangeOwner.processRenewalChangeOwner(
			new Map<Id, Account>{ client.Id => client },
			new List<Account>{ newClient }
		);

		Test.stopTest();

		renewal = [SELECT Id, OwnerId FROM Renewal__c WHERE Id = :renewal.Id];
		Assert.areEqual(userTwo.Id, renewal.OwnerId, 'Owner should update');
	}
}