/**
 * @description AccountClientShell_ExtensionTest tests for the AccountClientShell_Extension class.
 */
@IsTest
@SuppressWarnings('PMD.ApexAssertionsShouldIncludeMessage')
private class AccountClientShell_ExtensionTest {
	private static final Id OPPORTUNITY_FAKE_ID = '0062J00000p7G5oQAM';

	private static Account branch; 
	private static Account client;
	private static Contact employee;
	private static Opportunity opp;
	private static User userSysAdmin;
	private static User userEmployee;
	private static Business_Unit__c bu;

	@TestSetup
	static void makeData() {
		insert new NAICS_Code__c(Name = '111435', NAICS_Title__c = 'Crop Production');

		branch = TestFactoryAccount.createBranch('!!TEST BRANCH', '1000', null, null);

		userSysAdmin = TestFactoryUser.makeUser('!!TEST', 'SYSTEMADMIN', 'System Administrator', branch.External_Id__c);
		userEmployee = TestFactoryUser.makeUser('!!TEST', 'USER', 'BBSI Standard', branch.External_Id__c);
		userEmployee.AD_Username__c = 'tuser';
		insert new List<User>{userSysAdmin, userEmployee};

		employee = TestFactoryContact.createEmployee(userEmployee.Id, '!!TEST', 'USER', branch.Id);

		bu = testFactory.createBusinessUnit('!!TEST BU', branch, true);

		System.runAs(userSysAdmin) {
			client = TestFactoryAccount.makeClient('!!TEST ACCOUNT', null, null);
			client.OwnerId = userEmployee.Id;
			client.Verified__c = true;
			client.BU_Assignment_Date__c = System.today();
			client.Safety_Incentive__c = 'Safety Incentive';
			client.Customer_Class__c = '1';
			client.NAICS__c = '111435';
			client.Business_Unit__c = bu.Id;
			client.EEO_Reporting__c = 'No';
			client.FEIN__c = '12-1234567';
			client.External_Id__c = null;
			client.BillingStreet = '123 Fake Street\r\nApt 0\r\nRoom 0';
			client.Prospect_Branch__c = branch.Id;
			client.Payroll_Specialist__c = userEmployee.Id;
			insert client;

			opp = TestFactoryOpportunity.makeClient('!!TEST OPPORTUNITY', client.Id, Date.today().addMonths(6), 'Identifing');
			opp.OwnerId = userEmployee.Id;
			opp.Amount = 500000;
			opp.OK_For_Risk_Approval_Status__c = 'Approved';
			opp.Credit_Approval_Status__c = 'Approved';
			opp.AM_Approval_Status__c = 'Approved';
			insert opp;
		}
	}

	static void loadData() {
		branch = [
			SELECT Id, Name, External_Id__c 
			FROM Account 
			WHERE Name = '!!TEST BRANCH' 
			LIMIT 1
		];

		client = [
			SELECT Id, Name, External_Id__c, Verified__c, BU_Assignment_Date__c, Prospect_Branch__c
			FROM Account 
			WHERE Name = '!!TEST ACCOUNT' 
			LIMIT 1
		];

		Assert.areEqual(branch.Id, client.Prospect_Branch__c);

		employee = [SELECT Id, Name, User_Id__c FROM Contact WHERE Name = '!!TEST USER' LIMIT 1];

		opp = [
			SELECT 
				Id, 
				Name,
				AccountId, 
				OwnerId,
				Amount,
				OK_For_Risk_Approval_Status__c,
				Credit_Approval_Status__c,
				AM_Approval_Status__c,
				Client_Annual_Payroll__c,
				States_of_Operation__c
			FROM Opportunity 
			WHERE Name = '!!TEST OPPORTUNITY' 
			LIMIT 1
		];

		userSysAdmin = [SELECT Id, Name FROM User WHERE Name = '!!TEST SYSTEMADMIN' LIMIT 1];
		userEmployee = [SELECT Id, Name FROM User WHERE Name = '!!TEST USER' LIMIT 1];

		bu = [SELECT Id, Name FROM Business_Unit__c WHERE Name = '!!TEST BU'];

		Assert.isNotNull(employee.User_Id__c);
	}

	@IsTest
	static void testPostiveOutComeOfHRPCreate() {
		loadData();

		client.Verified__c = true;
		client.BU_Assignment_Date__c = System.today();
		update client;

		opp.AM_Approval_Status__c = 'Approved';
		update opp;

		Map<String, String> headers = new Map<String, String>();
		headers.put('Content-Type', 'application/xml; charset=UTF-8');

		Test.setMock(
			HttpCalloutMock.class,
			new GenericMockCallout(200, 'OK', '<response><clientid>123456</clientid></response>', headers)
		);

		PageReference pageRef;

		Test.startTest();

		ApexPages.currentPage().getParameters().put('ID', opp.Id);
		ApexPages.StandardController stdOpp = new ApexPages.StandardController(opp);
		AccountClientShell_Extension extension  = new AccountClientShell_Extension(stdOpp);
		pageRef = extension.createClientShell();

		Test.stopTest();

		loadData();

		Assert.isNotNull(pageRef);
		Assert.areEqual('/' + opp.AccountId, pageRef.getUrl());
		Assert.areEqual('123456', client.External_Id__c);
	}

	@IsTest
	static void testNegativeOutComeOfHRPCreate() {
		loadData();

		System.runAs(userSysAdmin) {
			client.Verified__c = true;
			client.BU_Assignment_Date__c = System.today();
			update client;

			opp.AM_Approval_Status__c = 'Approved';
			update opp;
		}

		Map<String, String> headers = new Map<String, String>();
		headers.put('Content-Type', 'application/xml; charset=UTF-8');

		Test.setMock(
			HttpCalloutMock.class, 
			new GenericMockCallout(500, 'OK', 'Test Stuff', headers)
		);

		Test.startTest();

		System.runAs(userEmployee) {
			ApexPages.currentPage().getParameters().put('ID', opp.Id);
			ApexPages.StandardController stdOpp = new ApexPages.StandardController(opp);
			AccountClientShell_Extension extension  = new AccountClientShell_Extension(stdOpp);

			PageReference pageRef = extension.createClientShell();

			Assert.isNull(pageRef);
		}

		Test.stopTest();

		boolean bFound = false;

		for (Apexpages.Message msg : ApexPages.getMessages()) {
			if (msg.getDetail().contains(AccountClientShell_Extension.SHELL_CREATION_FAILURE.left(20))) {
				bFound = true;
				break;
			}
		}

		Assert.isTrue(bFound);

		List<Case> cases = [SELECT Id, Subject, Description FROM Case WHERE AccountId = :client.Id];
		Assert.areEqual(1, cases.size());
		Case c = cases.get(0);
		Assert.isTrue(c.Subject.startsWith('Failed to create Client Shell for Account'));
		Assert.isTrue(c.Description.startsWith('Callout to Boomi/Prism failed.'));
	}

	@IsTest
	static void testErrorsGeneratedWhenMissingData() {
		loadData();

		client.Verified__c = false;
		client.BU_Assignment_Date__c = null;
		client.Customer_Class__c = '';
		client.EEO_Reporting__c = '';
		client.FEIN__c = '';
		client.NAICS__c = '';
		client.Safety_Incentive__c = '';
		update client;
		
		opp.Amount = 0;
		opp.AM_Approval_Status__c = '';
		opp.OK_For_Risk_Approval_Status__c = '';
		opp.Credit_Approval_Status__c = '';
		opp.Amount = 1000000;   // Set field: Estimated Annual Billing
		update opp;

		Map<String, String> headers = new Map<String, String>();
		headers.put('Content-Type', 'application/xml; charset=UTF-8');

		Test.setMock(
			HttpCalloutMock.class, 
			new GenericMockCallout(200, 'OK', 'Test Stuff', headers)
		);

		Test.startTest();

		ApexPages.currentPage().getParameters().put('ID', opp.Id);
		ApexPages.StandardController stdOpp = new ApexPages.StandardController(opp);
		AccountClientShell_Extension extension = new AccountClientShell_Extension(stdOpp);
		PageReference pageRef = extension.createClientShell();

		Test.stopTest();

		Assert.isNull(pageRef);

		List<ApexPages.Message> msgs = ApexPages.getMessages();

		Boolean bFound = false;

		for (Apexpages.Message msg : msgs) {
			if (msg.getDetail().startsWith(AccountClientShell_Extension.OPPORTUNITY_IS_INCOMPLETE.left(20))) {
				bFound = true;
			}
		}

		Assert.isTrue(bFound);
	}

	@IsTest
	public static void testAcronymIsSet() {
		loadData();

		User userBDM = TestFactoryUser.createBDM('!!Test', 'USERBDM', 'BBSI Standard', branch.External_Id__c);

		client.Verified__c = false;
		client.Business_Development_manager__c = userBDM.Id;
		client.BU_Assignment_Date__c = null;
		client.Customer_Class__c = '';
		client.EEO_Reporting__c = '';
		client.FEIN__c = '';
		client.NAICS__c = '';
		client.Safety_Incentive__c = '';
		update client;

		opp.Amount = 0;
		opp.AM_Approval_Status__c = '';
		opp.OK_For_Risk_Approval_Status__c = '';
		opp.Credit_Approval_Status__c = '';
		opp.Amount = 1000000;
		update opp;

		Id idAccount = client.Id;
		Account account = Database.Query(AccountClientShell_Extension.QUERY_SHELL_DATA);

		Assert.isNotNull(account);
		Assert.areEqual(userBDM.Id, account.Business_Development_manager__c);
	}

	@IsTest
	public static void test_getError() {
		loadData();

		ApexPages.StandardController sc = new ApexPages.StandardController(opp);

		AccountClientShell_Extension extension = new AccountClientShell_Extension(sc);

		Assert.areEqual('', extension.getError(null));
		Assert.areEqual('', extension.getError(''));
		Assert.areEqual('', extension.getError('<response>Text</response>'));
		Assert.areEqual('', extension.getError('<html><title></title></html>'));
		Assert.areEqual('Main Error', extension.getError('<html><title>abc\nUnable to create new client in Prism: Error 4\r\n \nMain Error\n\n</title></html>'));

		Assert.areEqual(
			'Unable to determine geocode with city, state, zip received',
			extension.getError('<html>\n<head>\n<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1"/>\n<title>Error 500 Process terminating -- some documents reached an exception which is set to halt all documents: Unable to create new client in Prism. Error 1\n\nSalesforce Account ID: 0015000001T3GpvAAF\n\nUnable to create new client in Prism: Error 4\nUnable to determine geocode with city, state, zip received\n\n\n</title>\n</head>')
		);
	}

	@IsTest
	static void test_fixBranchNumber() {
		Assert.isNull(AccountClientShell_Extension.fixBranchNumber(null));
		Assert.areEqual('', AccountClientShell_Extension.fixBranchNumber(''));

		Assert.areEqual('001', AccountClientShell_Extension.fixBranchNumber('1'));
		Assert.areEqual('023', AccountClientShell_Extension.fixBranchNumber('23'));
		Assert.areEqual('777', AccountClientShell_Extension.fixBranchNumber('777'));
		Assert.areEqual('1000', AccountClientShell_Extension.fixBranchNumber('1000'));
		Assert.areEqual('TEST', AccountClientShell_Extension.fixBranchNumber('TEST'));
	}

	@IsTest
	public static void test_ShellWrapper() {
		loadData();

		Test.startTest();

		AccountClientShell_Extension.ShellWrapper wrapper;

		wrapper = new AccountClientShell_Extension.ShellWrapper(client.Id);

		Test.stopTest();
		
		Assert.IsNotNull(wrapper.sfdcAccount);
		Assert.areEqual(client.Id, wrapper.sfdcAccount.Id);

		// Assert.isNotNull(wrapper.riskManager);
		// Assert.isNotNull(wrapper.referralPartner);
		// Assert.isNotNull(wrapper.payrollRep);
		// Assert.isNotNull(wrapper.hrManager);
		// Assert.isNotNull(wrapper.riskManagerUser);
		// Assert.isNotNull(wrapper.payrollRepUser);
		// Assert.isNotNull(wrapper.hrManagerUser);

		Assert.areEqual('1000', wrapper.branchNo);
		Assert.isNotNull(wrapper.billingStreet1);
		Assert.areEqual('123 Fake Street', wrapper.billingStreet1);
		Assert.isNotNull(wrapper.billingStreet2);
		Assert.areEqual('Apt 0 Room 0', wrapper.billingStreet2);

		String text = 'WRAPPER';
		text += '\n  Risk Manager: ' + wrapper.riskManager;
		text += '\n  Referral Partner: ' +  wrapper.referralPartner;
		text += '\n  Payroll Rep: ' +  wrapper.payrollRep;
		text += '\n  HR Manager: ' +  wrapper.hrManager;
		text += '\n  Risk Manager User: ' +  wrapper.riskManagerUser;
		text += '\n  Payroll Rep User: ' +  wrapper.payrollRepUser;
		text += '\n  HR ManagerUser: ' +  wrapper.hrManagerUser;
		text += '\n  Branch No: ' +  wrapper.branchNo;
		System.debug(LoggingLevel.INFO, text);
	}
	
	@IsTest
	public static void test_queryShellData() {
		loadData();

		Test.startTest();

		AccountClientShell_Extension.ShellWrapper wrapper = new AccountClientShell_Extension.ShellWrapper(client.Id);

		Account c = wrapper.queryShellData(client.Id);

		Test.stopTest();

		Assert.areEqual(branch.Name, c.Prospect_Branch__r.Name);
		Assert.areEqual(branch.External_Id__c, c.Prospect_Branch__r.Branch_No__c);
	}

	@IsTest
	static void test_HaveClientId() {
		loadData();

		System.runAs(userSysAdmin) {
			client.Verified__c = true;
			client.BU_Assignment_Date__c = System.today();
			client.External_Id__c = '111111';
			update client;

			opp.AM_Approval_Status__c = 'Approved';
			update opp;
		}

		PageReference pageRef;

		Test.startTest();

		System.runAs(userEmployee) {
			ApexPages.currentPage().getParameters().put('ID', opp.Id);
			ApexPages.StandardController stdOpp = new ApexPages.StandardController(opp);
			AccountClientShell_Extension extension  = new AccountClientShell_Extension(stdOpp);

			pageRef = extension.createClientShell();
		}

		Test.stopTest();

		Assert.isNotNull(pageRef);
		Assert.areEqual('/' + client.Id, pageRef.getUrl());
	}
}