/**
 * @description AccountSearcherController_Test
 * #40777: Replaced Payroll Specialist(Contact Lookup) field to Payroll Specialist(User Lookup) field
 */
@IsTest
public without sharing class AccountSearcherController_Test {
	private static final String QUERY_TEST_RESULT_1 =
		'SELECT Id, Name, External_Id__c, Prospect_Branch__c, Prospect_Branch__r.Name, OwnerId, Owner.Name, ' +
		'       DBA_Name__c, Payroll_Specialist__c, Payroll_Specialist__r.Name, RecordType.Name FROM Account' +
		' WHERE  (Name LIKE \'%ABC%\' OR External_Id__c LIKE \'%ABC%\' OR DBA_Name__c LIKE \'%ABC%\') ' +
		' ORDER BY Name ' +
		' LIMIT 20';


	private static final String QUERY_TEST_RESULT_2 =
		'SELECT Id, Name, External_Id__c, Prospect_Branch__c, Prospect_Branch__r.Name, OwnerId, Owner.Name, ' +
		'       DBA_Name__c, Payroll_Specialist__c, Payroll_Specialist__r.Name, RecordType.Name' +
		' FROM Account' +
		' WHERE RecordType.Name IN (\'Prospect\', \'Client\', \'Terminated\')' +
		' AND  (Name LIKE \'%ABC%\' OR External_Id__c LIKE \'%ABC%\' OR DBA_Name__c LIKE \'%ABC%\') ' +
		' ORDER BY Name ' +
		' LIMIT 40';

	@TestSetup
	static void setData() {
		Account branch = TestFactoryAccount.createBranch('UNITTEST BRANCH');

		User user = TestFactoryUser.createUser('UNITTEST', 'USER', 'BBSI Standard', branch.External_Id__c);
		Assert.isNotNull(user.Id);
		Assert.areEqual('UNITTEST', user.FirstName);
		Assert.areEqual('USER', user.LastName);
		Assert.isTrue(user.IsActive);

		Contact contact = TestFactoryContact.createEmployee(user.Id, 'UNITTEST', 'USER', branch.id);
		Assert.isNotNull(contact.Id);

		Account referralPartner = TestFactoryAccount.makeReferralPartner('ONE RP','% of Margin', 12.0, null);
		referralPartner.External_Id__c = '000000';
		
		Account client1 = TestFactoryAccount.makeClient('Client One',null,null);
		client1.External_Id__c = '111111';
		client1.DBA_Name__c = 'John Furport';
		client1.Prospect_Branch__c = branch.Id;
		client1.Payroll_Specialist__c = user.Id;
		Account client2 = TestFactoryAccount.makeClient('Client TWO',null,null);
		client2.External_Id__c = '222222';
		client2.DBA_Name__c = 'Joe Oneoff';
		Account client3 = TestFactoryAccount.makeClient('Client THREE',null,null);
		client3.External_Id__c = 'one333';
		client3.DBA_Name__c = 'DBA Man';
		Account client4 = TestFactoryAccount.makeClient('Client FOUR',null,null);
		client4.External_Id__c = '444444';

		insert new List<Account> { referralPartner, client1, client2, client3, client4 };
		Assert.isNotNull(referralPartner.Id);
		Assert.isNotNull(client1.Id);
		Assert.isNotNull(client2.Id);
		Assert.isNotNull(client3.Id);
		Assert.isNotNull(client4.Id);
	}

	@IsTest
	public static void test_makeQuery() {
		Assert.areEqual(QUERY_TEST_RESULT_1, AccountSearcherController.makeQuery('ABC', 20, 'AllTypes'));
		Assert.areEqual(QUERY_TEST_RESULT_2, AccountSearcherController.makeQuery('ABC', 40, 'ProspectsClientsTerminated'));
	}

	@IsTest
	public static void test_makeAndClause() {
		Assert.areEqual(AccountSearcherController.AND_ALL, AccountSearcherController.makeAndClause('AllTypes'));
		Assert.areEqual(AccountSearcherController.AND_PROSPECT_CLIENT_TERMINATED, AccountSearcherController.makeAndClause('ProspectsClientsTerminated'));
		Assert.areEqual(AccountSearcherController.AND_PROSPECT_CLIENT, AccountSearcherController.makeAndClause('ProspectsClients'));
		Assert.areEqual(AccountSearcherController.AND_PROSPECT_ONLY, AccountSearcherController.makeAndClause('Prospects'));
		Assert.areEqual(AccountSearcherController.AND_CLIENT_ONLY, AccountSearcherController.makeAndClause('Clients'));
		Assert.areEqual(AccountSearcherController.AND_PROSPECT_CLIENT_TERMINATED, AccountSearcherController.makeAndClause('Unknown'));
	}

	@IsTest
	public static void test_queryAccounts_InvalidSearchText() {
		AccountSearcherController.AccountSearchResponse response;

		response = AccountSearcherController.queryAccounts(null, 20, 'ProspectsClientsTerminated');

	Assert.isNotNull( response);
		Assert.areEqual(0, response.accounts.size());
	}

	@IsTest
	public static void test_queryAccounts_ValidSearchTextONE() {
		AccountSearcherController.AccountSearchResponse response;

		response = AccountSearcherController.queryAccounts('ONE', 20, 'AllTypes');
		Assert.isNotNull(response);
		Assert.isNotNull(response.footer);
		Assert.areEqual(3, response.accounts.size());

		response = AccountSearcherController.queryAccounts('One', 20, 'ProspectsClientsTerminated');
		Assert.isNotNull(response);
		Assert.isNotNull(response.footer);
		Assert.areEqual(2, response.accounts.size());

		response = AccountSearcherController.queryAccounts('RP', 20, 'AllTypes');
		Assert.isNotNull(response);
		Assert.isNotNull(response.footer);
		Assert.areEqual(2, response.accounts.size());

		response = AccountSearcherController.queryAccounts('RP', 20, 'ProspectsClientsTerminated');
		Assert.isNotNull( response);
		Assert.isNotNull( response.footer);
		Assert.areEqual(1, response.accounts.size());

		response = AccountSearcherController.queryAccounts('4', 20, 'AllTypes');
		Assert.isNotNull(response);
		Assert.isNotNull(response.footer);
		Assert.areEqual(1, response.accounts.size());
	}

	@IsTest
	public static void test_queryAccounts_ValidSearchTextBbsiStandardUser() {
		User user = [SELECT Id, Name FROM User WHERE FirstName = 'UNITTEST'];

		System.runAs(user) {
			AccountSearcherController.AccountSearchResponse response;

			response = AccountSearcherController.queryAccounts('ONE', 20, 'AllTypes');
			Assert.isNotNull(response);
			Assert.isNotNull(response.footer);
			Assert.areEqual(3, response.accounts.size());

			response = AccountSearcherController.queryAccounts('One', 20, 'ProspectsClientsTerminated');
			Assert.isNotNull(response);
			Assert.isNotNull(response.footer);
			Assert.areEqual(2, response.accounts.size());

			response = AccountSearcherController.queryAccounts('RP', 20, 'AllTypes');
			Assert.isNotNull(response);
			Assert.isNotNull(response.footer);
			Assert.areEqual(2, response.accounts.size());

			response = AccountSearcherController.queryAccounts('RP', 20, 'ProspectsClientsTerminated');
			Assert.isNotNull(response);

			Assert.isNotNull(response.footer);
			Assert.areEqual(1, response.accounts.size());

			response = AccountSearcherController.queryAccounts('444', 20, 'AllTypes');
			Assert.isNotNull(response);
			Assert.isNotNull(response.footer);
			Assert.areEqual(1, response.accounts.size());
		}
	}
}