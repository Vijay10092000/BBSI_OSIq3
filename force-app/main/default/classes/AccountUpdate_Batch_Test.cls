/**
 * @description AccountUpdate_Batch_Test contains tests for the AccountUpdate_Batch class.
 */
@IsTest
@SuppressWarnings('PMD.ApexAssertionsShouldIncludeMessage')
public with sharing class AccountUpdate_Batch_Test {
	@IsTest
    static void test_batch() {
		List<Account> clients = new List<Account>();

		for (Integer index = 1; index < 5; ++index) {
			clients.add(
                TestFactoryAccount.makeClient('BATCH-TEST-ACCOUNT',null,null)
			);
		}

		insert clients;

		Test.startTest();

		for (Account client : clients) {
			client.BillingPostalCode = '00000';
		}

		Database.executeBatch(new AccountUpdate_Batch(clients), 100);

		Test.stopTest();

		clients = [
			SELECT Id, Name, BillingPostalCode
			FROM Account
			WHERE Name LIKE 'BATCH-TEST-ACCOUNT%'
			ORDER BY NAME ASC
		];

		for (Account client : clients) {
			Assert.areEqual('00000', client.BillingPostalCode);
		}
    }
}