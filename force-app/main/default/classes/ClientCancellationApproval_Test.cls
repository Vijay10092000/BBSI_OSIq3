/**
 * @description ClientCancellationApproval_Test contains test for the
 * ClientCancellationApproval class.
 */
@SuppressWarnings('PMD.MethodNamingConventions')
@IsTest
public without sharing class ClientCancellationApproval_Test {
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
		partner1 = [SELECT Id, Name FROM Account WHERE Name = :NAME_REFERRAL_PARTNER_1];
		client1 = [SELECT Id, Name FROM Account WHERE Name = :NAME_CLIENT_1];
	}

	@IsTest
	static void terminateRelatedReferralSources() {
		getData();

		Date yesterday = System.today().addDays(-1);

		Referral_Partner__c rs1 = new Referral_Partner__c(
			RecordTypeId = ReferralSource_Service.idrtClientRP,
			Account__c = client1.Id,
			Referral_Partner__c = partner1.Id,
			Producer__c = null,
			Referral_Partner_Commission_Type__c = '% of WC Eligible Payroll',
			Commission_Rate__c = 1.11,
			Effective_Date__c = System.today().addDays(-30),
			Termination_Date__c = null,
			Hold__c = true,
			Override__c = false,
			Split_Commission__c = false,
			Comments__c = 'Test Referral Source'
		);
		insert rs1;

		Client_Cancellation__c cc = new Client_Cancellation__c (
			AM_Approval_Status__c = 'Tentative',
			Cancellation_Attachment__c = true,
			Cancellation_decision_due_to_COVID_19__c = 'Yes',
			Client__c = client1.Id,
			Client_Cancellation_Date__c = yesterday,
			AM_Comments__c = 'Test cancellation',
			Contracts_Comments__c = 'Test cancellation',
			Employees_Notified__c = yesterday,
			Last_Check_Date__c = yesterday,
			Where_did_the_business_go__c = 'Business Closed',
			Where_Framework_Failed__c = 'N/A',
			Who_Requested_Cancellation__c = 'Client'
		);
		insert cc;

		rs1 = [SELECT Id, Account__c, Referral_Partner__c, Termination_Date__c FROM Referral_Partner__c WHERE Id = :rs1.Id];

		Assert.areEqual(null, rs1.Termination_Date__c, 'Termination date should start with a null value');

		Test.startTest();

		cc.AM_Approval_Status__c = 'Approved';
		cc.AM_Comments__c = 'approval comments';
		cc.Communication_with_Client_Attached__c = true;
		update cc;

		Test.stopTest();

		rs1 = [SELECT Id, Account__c, Referral_Partner__c, Termination_Date__c FROM Referral_Partner__c WHERE Id = :rs1.Id];
		Assert.areEqual(null, rs1.Termination_Date__c, 'Termination Date should not be set on the Referral Source');

		Assert.areEqual(1, Email_Service.testEmails.size(), 'Should have sent an email.');
	}

	@IsTest
	static void test_setRelatedClient_1() {
		getData();

		Date today = System.today();
		Date yesterday = today.addDays(-1);

		client1.Status__c = 'Terminated';
		client1.RecordTypeId = RecordTypeService.getId('Account', 'Terminated');
		update client1;

		Client_Cancellation__c cc = new Client_Cancellation__c (
			AM_Approval_Status__c = 'Tentative',
			Cancellation_Attachment__c = true,
			Cancellation_decision_due_to_COVID_19__c = 'Yes',
			Client__c = client1.Id,
			Client_Cancellation_Date__c = yesterday,
			Communication_with_Client_Attached__c = true,
			AM_Comments__c = 'Test cancellation',
			Contracts_Comments__c = 'Test cancellation',
			Employees_Notified__c = yesterday,
			Last_Check_Date__c = yesterday,
			Reason_for_Cancellation__c = 'BUSINESS CLOSED',
			Where_did_the_business_go__c = 'Business Closed',
			Where_Framework_Failed__c = 'N/A',
			Who_Requested_Cancellation__c = 'Client'
		);
		insert cc;

		Test.startTest();

		cc.AM_Approval_Status__c = 'Approved';
		update cc;

		Test.stopTest();

		client1 = [SELECT Id, Cancellation_Reason__c FROM Account WHERE Id = :client1.Id];
		Assert.areEqual('BUSINESS CLOSED', client1.Cancellation_Reason__c, 'Client cancel reason should be set');
	}

	@IsTest
	static void test_setRelatedClient_2() {
		getData();

		Date today = System.today();
		Date yesterday = today.addDays(-1);

		insert new Client_Cancellation__c (
			AM_Approval_Status__c = 'Approved',
			Cancellation_Attachment__c = true,
			Cancellation_decision_due_to_COVID_19__c = 'Yes',
			Client__c = client1.Id,
			Client_Cancellation_Date__c = yesterday,
			Communication_with_Client_Attached__c = true,
			AM_Comments__c = 'Test cancellation 1',
			Contracts_Comments__c = 'Test cancellation 1',
			Employees_Notified__c = yesterday,
			Last_Check_Date__c = yesterday,
			Reason_for_Cancellation__c = 'BUSINESS CLOSED',
			Where_did_the_business_go__c = 'Business Closed',
			Where_Framework_Failed__c = 'N/A',
			Who_Requested_Cancellation__c = 'Client'
		);

		client1.Status__c = 'Terminated';
		client1.RecordTypeId = RecordTypeService.getId('Account', 'Terminated');
		update client1;

		Test.startTest();
		insert new Client_Cancellation__c (
			AM_Approval_Status__c = 'Approved',
			Cancellation_Attachment__c = true,
			Cancellation_decision_due_to_COVID_19__c = 'Yes',
			Client__c = client1.Id,
			Client_Cancellation_Date__c = today,
			Communication_with_Client_Attached__c = true,
			AM_Comments__c = 'Test cancellation 2',
			Contracts_Comments__c = 'Test cancellation 2',
			Employees_Notified__c = yesterday,
			Last_Check_Date__c = yesterday,
			Reason_for_Cancellation__c = 'BUSINESS SOLD',
			Where_did_the_business_go__c = 'Business Sold',
			Where_Framework_Failed__c = 'N/A',
			Who_Requested_Cancellation__c = 'Client'
		);
		Test.stopTest();
		
		client1 = [SELECT Id, Cancellation_Reason__c FROM Account WHERE Id = :client1.Id];
		Assert.areEqual('BUSINESS SOLD', client1.Cancellation_Reason__c, 'Client cancel reason should be set');
	}
}