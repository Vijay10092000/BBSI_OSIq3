/**
 * @description AccountTerminated_Test contains test for the AccountTerminated class.
 */
//@SuppressWarnings('PMD.MethodNamingConventions')
@IsTest
public without sharing class AccountTerminated_Test {
	private static final String NAME_BRANCH = 'TEST_BRANCH';
	private static final String NAME_REFERRAL_PARTNER_1 = 'Test Referral Partner - ONE';
	private static final String NAME_CLIENT_1 = 'Test Client - ONE';

	static private Account branch = null;
	static private Account partner1 = null;
	static private Account client1 = null;

	@TestSetup
	static void makeData() {
		branch = TestFactoryAccount.makeBranch(NAME_BRANCH);
		partner1 = TestFactoryAccount.makeReferralPartner(NAME_REFERRAL_PARTNER_1, '% of WC Eligible Payroll', 1.11, null);
		insert new List<Account>{ branch, partner1 };

		client1 = TestFactoryAccount.makeClient(NAME_CLIENT_1, null, null);
		client1.Prospect_Branch__c = branch.Id;
		insert client1;
	}

	static void getData() {
		partner1 = [SELECT Id, Name, Status__c FROM Account WHERE Name = :NAME_REFERRAL_PARTNER_1];
		client1 = [SELECT Id, Name, Status__c FROM Account WHERE Name = :NAME_CLIENT_1];
	}

	@IsTest
	static void test_getRecentCancellation() {
		getData();

		Date today = System.today();
		Date yesterday = today.addDays(-1);

		insert new Client_Cancellation__c (
			AM_Approval_Status__c = 'Approved',
			Cancellation_Attachment__c = true,
			Cancellation_decision_due_to_COVID_19__c = 'Yes',
			Client__c = client1.Id,
			Client_Cancellation_Date__c = today,
			AM_Comments__c = 'Test cancellation',
			Contracts_Comments__c = 'Test cancellation',
			Employees_Notified__c = yesterday,
			Last_Check_Date__c = yesterday,
			Reason_for_Cancellation__c = 'BUSINESS CLOSED',
			Where_did_the_business_go__c = 'Business Closed',
			Where_Framework_Failed__c = 'N/A',
			Who_Requested_Cancellation__c = 'Client'
		);

		insert new Client_Cancellation__c (
			AM_Approval_Status__c = 'Tentative',
			Cancellation_Attachment__c = true,
			Cancellation_decision_due_to_COVID_19__c = 'Yes',
			Client__c = client1.Id,
			Client_Cancellation_Date__c = yesterday,
			AM_Comments__c = 'Test cancellation',
			Contracts_Comments__c = 'Test cancellation',
			Employees_Notified__c = yesterday,
			Last_Check_Date__c = yesterday,
			Reason_for_Cancellation__c = 'BUSINESS SOLD',
			Where_did_the_business_go__c = 'Business Sold',
			Where_Framework_Failed__c = 'N/A',
			Who_Requested_Cancellation__c = 'Client'
		);

		Test.startTest();
		Map<Id, List<Client_Cancellation__c>> accountToCcs = AccountTerminated.getRecentCancellations( new Set<Id>{ client1.Id });

		Test.stopTest();

		Assert.areEqual(1, accountToCcs.size(), 'Should only be one Account read');

		List<Client_Cancellation__c> ccs = accountToCcs.get(client1.Id);
		Assert.areEqual(2, ccs.size());

		Assert.areEqual('Tentative', ccs.get(0).AM_Approval_Status__c, 'Order is wrong');
		Assert.areEqual('Approved', ccs.get(1).AM_Approval_Status__c, 'Order is wrong');
	}

	@IsTest
	static void test_updateTerminated1() {
		getData();
		Date today = System.today();
		Date yesterday = today.addDays(-1);

		insert new Client_Cancellation__c (
			AM_Approval_Status__c = 'Approved',
			Cancellation_Attachment__c = true,
			Cancellation_decision_due_to_COVID_19__c = 'Yes',
			Client__c = client1.Id,
			Client_Cancellation_Date__c = today,
			AM_Comments__c = 'Test cancellation',
			Contracts_Comments__c = 'Test cancellation',
			Employees_Notified__c = yesterday,
			Last_Check_Date__c = yesterday,
			Reason_for_Cancellation__c = 'BUSINESS CLOSED',
			Where_did_the_business_go__c = 'Business Closed',
			Where_Framework_Failed__c = 'N/A',
			Who_Requested_Cancellation__c = 'Client'
		);

		insert new Client_Cancellation__c (
			AM_Approval_Status__c = 'Tentative',
			Cancellation_Attachment__c = true,
			Cancellation_decision_due_to_COVID_19__c = 'Yes',
			Client__c = client1.Id,
			Client_Cancellation_Date__c = yesterday,
			AM_Comments__c = 'Test cancellation',
			Contracts_Comments__c = 'Test cancellation',
			Employees_Notified__c = yesterday,
			Last_Check_Date__c = yesterday,
			Reason_for_Cancellation__c = 'BUSINESS SOLD',
			Where_did_the_business_go__c = 'Business Sold',
			Where_Framework_Failed__c = 'N/A',
			Who_Requested_Cancellation__c = 'Client'
		);
		
		Account oldClient1 = client1.clone(true, true, false, false);
		Map<Id, Account> oldAccounts = new Map<Id, Account> { oldClient1.Id => oldClient1 };
		Map<Id, Account> newAccounts = new Map<Id, Account> { client1.Id => client1 };

		Test.startTest();

		client1.Status__c = 'Terminated';
		client1.RecordTypeId = RecordTypeService.getId('Account', 'Terminated');
		
		AccountTerminated.updateTerminated(oldAccounts, newAccounts);

		Test.stopTest();

		Assert.areEqual('BUSINESS CLOSED', client1.Cancellation_Reason__c);
	}

	@IsTest
	static void test_updateTerminated2() {
		getData();
		Date today = System.today();
		Date yesterday = today.addDays(-1);

		insert new Client_Cancellation__c (
			AM_Approval_Status__c = 'Approved',
			Cancellation_Attachment__c = true,
			Cancellation_decision_due_to_COVID_19__c = 'Yes',
			Client__c = client1.Id,
			Client_Cancellation_Date__c = today,
			AM_Comments__c = 'Test cancellation',
			Contracts_Comments__c = 'Test cancellation',
			Employees_Notified__c = yesterday,
			Last_Check_Date__c = yesterday,
			Reason_for_Cancellation__c = 'BUSINESS CLOSED',
			Revoke__c = true,
			Revoked_Reason__c = 'Testing',
			Where_did_the_business_go__c = 'Business Closed',
			Where_Framework_Failed__c = 'N/A',
			Who_Requested_Cancellation__c = 'Client'
		);

		insert new Client_Cancellation__c (
			AM_Approval_Status__c = 'Tentative',
			Cancellation_Attachment__c = true,
			Cancellation_decision_due_to_COVID_19__c = 'Yes',
			Client__c = client1.Id,
			Client_Cancellation_Date__c = yesterday,
			AM_Comments__c = 'Test cancellation',
			Contracts_Comments__c = 'Test cancellation',
			Employees_Notified__c = yesterday,
			Last_Check_Date__c = yesterday,
			Reason_for_Cancellation__c = 'BUSINESS SOLD',
			Revoke__c = false,
			Where_did_the_business_go__c = 'Business Sold',
			Where_Framework_Failed__c = 'N/A',
			Who_Requested_Cancellation__c = 'Client'
		);
		
		client1.Status__c = 'Terminated';
		client1.RecordTypeId = RecordTypeService.getId('Account', 'Client');
		client1.Cancellation_Reason__c = 'BUSINESS SOLD';

		Account oldClient1 = client1.clone(true, true, false, false);
		Map<Id, Account> oldAccounts = new Map<Id, Account> { oldClient1.Id => oldClient1 };
		Map<Id, Account> newAccounts = new Map<Id, Account> { client1.Id => client1 };

		Test.startTest();

		client1.Status__c = 'Active';
		client1.RecordTypeId = RecordTypeService.getId('Account', 'Terminated');
		
		AccountTerminated.updateTerminated(oldAccounts, newAccounts);

		Test.stopTest();

		Assert.areEqual(null, client1.Cancellation_Reason__c);
	}
}