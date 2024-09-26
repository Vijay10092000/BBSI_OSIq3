/**
 * @description SobjectUpdate_Batch_Test contains tests for the SobjectUpdate_Batch class.
 */
@IsTest
@SuppressWarnings('PMD.ApexAssertionsShouldIncludeMessage')
public with sharing class SobjectUpdate_Batch_Test {
	private static final String BATCH_NAME_START = 'BATCH-TEST-ACCOUNT ';

	@IsTest
    static void test_batch() {
		List<Account> clients = new List<Sobject>();

		for (Integer index = 1; index < 5; ++index) {
			clients.add(
				TestFactory.createAccountClient(BATCH_NAME_START + index, false)
			);
		}

		insert clients;

		Test.startTest();

		for (Account client : clients) {
			client.BillingPostalCode = '00000';
		}

		Database.executeBatch(new SobjectUpdate_Batch(clients), 100);

		Test.stopTest();

		String batchName = BATCH_NAME_START + '%';

		clients = [
			SELECT Id, Name, BillingPostalCode
			FROM Account
			WHERE Name LIKE :batchName
			ORDER BY NAME ASC
		];

		for (Account client : clients) {
			System.assertEquals('00000', client.BillingPostalCode);
		}
    }
}