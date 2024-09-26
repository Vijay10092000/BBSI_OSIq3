/**
 * @description RunoffForensicReportExtension_Test contains test methods for the RunoffForensicExctnsion class.
 */
@IsTest
@SuppressWarnings('PMD.ApexAssertionsShouldIncludeMessage')
public without sharing class RunoffForensicReportExtension_Test {
	private static Account client;
	private static Client_Cancellation__c cancellation;

	@TestSetup
	static void makeData() {
		User sysAdmin = TestFactory.createUser(
			'SysAdmin',
			'sys.admin@bbsi.zzz',
			'sys.admin@bbsi.zzz',
			'System Administrator',
			'910',
			true
		);
		User areaManager;
		User bdm;
		Account referralPartner;
		Account branch;
		Contact producer;

		System.runAs(sysAdmin) {
			areaManager = TestFactory.createUserAM('AreaManager', 'TEST', false);
			bdm = TestFactory.createUserBDM('BDM', '44444', Profile_Service.BBSI_STANDARD, 'TEST', false);

			referralPartner = TestFactory.createAccountReferralPartner(
				'RP',
				'Inactive',
				'% of WC Eligible Payroll',
				10.00,
				null,
				false
			);

			branch = TestFactory.createAccountBranch(
				'TEST BRANCH',
				'TEST',
				'Manager Name',
				'manager.name@bbsi.zzz',
				false
			);
			branch.Branch_Manager__c = areaManager.LastName;
			branch.Branch_Manager_Email__c = areaManager.Email;
			insert branch;

			producer = TestFactory.createContact(referralPartner, 'Producer', 'Producer', true);
		}

		client = TestFactory.createAccountClient(
			'!Test Client!',
			referralPartner.Id,
			producer.Id,
			'% of WC Eligible Payroll',
			1.23,
			'Active',
			false
		);
		client.Prospect_Branch__c = branch.Id;
		client.External_Id__c = 'CLIENT#';
		client.Annual_Billing__c = 100000.00;
		client.Start_Date__c = Date.newInstance(2020, 1, 1);
		insert client;

		Client_Cancellation__c cancellation = TestFactory.createClientCancellation(client.Id, Date.newInstance(2022, 1, 1), 'Approved', false);
		cancellation.Business_Development_Manager__c = bdm.Id;
		cancellation.Parent_Account__c = referralPartner.Id;
		cancellation.Who_Requested_Cancellation__c = 'Client';
		insert cancellation;
	}

	static void readData() {
		client = (Account) [SELECT Id, Name FROM Account WHERE Name = '!Test Client!' LIMIT 1];

		cancellation = (Client_Cancellation__c) [
			SELECT
				Id,
				AM_Approval_Status__c,
				AM_Comments__c,
				Business_Development_Manager__c,
				Cancellation_decision_due_to_COVID_19__c,
				Cancellation_Reason__c,
				Client__c,
				Client_Cancellation_Date__c,
				Consistent_CORE__c,
				Contracts_Comments__c,
				Contracts_Reviewed__c,
				Deep_Dive_Completed__c,
				Employees_Notified__c,
				Explanation__c,
				Had_Blueprint__c,
				Improvement__c,
				Last_Check_Date__c,
				Last_Core_Visit__c,
				Local_ORT_Attendance__c,
				Parent_Account__c,
				Red_Flags__c,
				Regular_Meetings__c,
				Revoke__c,
				Revoked_Reason__c,
				RP_Alignment__c,
				RP_Follow_up_Completed__c,
				RP_Follow_up_Date__c,
				Runoff_Forensic_Report_Attached__c,
				Safety_Incentive_Reason__c,
				Safety_Incentive_Refund_Request__c,
				Security_Deposit_Amount__c,
				Tax_Dept_Archived__c,
				Via__c,
				Where_did_the_business_go__c,
				Where_Framework_Failed__c,
				Who_Requested_Cancellation__c
			FROM Client_Cancellation__c
			ORDER BY CreatedDate DESC
			LIMIT 1
		];
	}

	@IsTest
	static void test_constructor() {
		readData();

		RunoffForensicReportExtension extension;

		Test.startTest();

        ApexPages.StandardController controller = new ApexPages.StandardController(cancellation);
		extension = new RunoffForensicReportExtension(controller);

		Test.stopTest();

		System.assertEquals(cancellation.Id, extension.record.Id);
		System.assertEquals(client.Id, extension.clientAccount.Id);
		System.assertEquals(true, extension.isValid);
	}

	@IsTest
	static void test_setup() {
		readData();

		RunoffForensicReportExtension extension;

		Test.startTest();

		extension = new RunoffForensicReportExtension(null);

		Test.stopTest();

		System.assertEquals(null, extension.record);
		System.assertEquals(null, extension.clientAccount);
		System.assertEquals(null, extension.isValid);

		extension.setup(null);
		System.assertEquals(null, extension.record);
		System.assertEquals(null, extension.clientAccount);
		System.assertEquals(false, extension.isValid);

		extension.setup(cancellation);
		System.assertEquals(cancellation.Id, extension.record.Id);
		System.assertEquals(client.Id, extension.clientAccount.Id);
		System.assertEquals(true, extension.isValid);
	}

	@IsTest
	static void test_createBodyPdf() {
		readData();

		Test.startTest();

		Blob body = RunoffForensicReportExtension.createBodyPdf(cancellation);

		Test.stopTest();

		System.assertNotEquals(RunoffForensicReportExtension.PDF_BODY_DEFAULT, String.valueOf(body));
	}

	@IsTest
	static void test_createReport() {
		readData();

		System.assert(true);
	}

	@IsTest
	static void test_createReport_Valid() {
		readData();

        List<Id> idRecords = new List<Id>{ cancellation.id };

		Test.startTest();

		List<String> results = RunoffForensicReportExtension.createReport(idRecords);

		Test.stopTest();

        System.assertEquals(1, results.size());
        System.assertEquals('CREATED', results.get(0));

		List<ContentDocumentLink> links = [
			SELECT Id, ContentDocumentId
			FROM ContentDocumentLink
			WHERE LinkedEntityId = :cancellation.Id
		];

		System.assertEquals(1, links.size(), 'Expect 1 file linked to object');
	}

	@IsTest
	static void test_createReport_Invalid() {
		readData();

        cancellation.Improvement__c = '';
		update cancellation;

		Test.startTest();

        List<Id> idRecords = new List<Id>{ cancellation.Id };
		List<String> results = RunoffForensicReportExtension.createReport(idRecords);

		Test.stopTest();

        System.assertEquals(1, results.size());
        System.assertNotEquals('CREATED', results.get(0));
	}
}