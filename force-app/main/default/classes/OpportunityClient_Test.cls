/**
 * @description OpportunityClient_Test contains tests for the OpportunityClient class.
 */
@IsTest
public without sharing class OpportunityClient_Test {
	private static Account prospect1;
	private static Account prospect2;
	private static Account prospect3;
	private static Account prospect4;
	private static Opportunity oppP1Benefits;
	private static Opportunity oppP1Client;
	private static Opportunity oppP2Client;
	private static Opportunity oppP2ClientLost;
	private static Opportunity oppP3Shell;
	private static Opportunity oppP4ShellLost;

	/**
	 * @description makeData creates the base data for each test.
	 */
	@TestSetup
	private static void makeData() {
		Date today = Date.today();

		prospect1 = TestFactoryAccount.makeProspect('TEST PROSPECT 1', null, null);
		prospect1.External_Id__c = null;
		prospect2 = TestFactoryAccount.makeProspect('TEST PROSPECT 2', null, null);
		prospect2.External_Id__c = null;
		prospect3 = TestFactoryAccount.makeProspect('TEST PROSPECT 3', null, null);
		prospect3.External_Id__c = null;
		prospect4 = TestFactoryAccount.makeProspect('TEST PROSPECT 4', null, null);
		prospect4.External_Id__c = null;
		insert new List<Account>{ prospect1, prospect2, prospect3, prospect4 };

		oppP1Benefits = TestFactoryOpportunity.makeBenefits('BENEFITS: PROSPECT 1', prospect1.Id, today, Opportunity_Service.STAGE_PENDING_SUBMISSION);
		oppP1Client = TestFactoryOpportunity.makeClient('PROSPECT 1', prospect1.Id, today, Opportunity_Service.STAGE_DISCOVERY_MEETING);

		oppP2Client = TestFactoryOpportunity.makeClient('PROSPECT 2', prospect2.Id, today, Opportunity_Service.STAGE_PROPOSAL);
		oppP2ClientLost = TestFactoryOpportunity.makeShell('PROSPECT 2 LOST', prospect2.Id, today, Opportunity_Service.STAGE_CLOSED_LOST);
		oppP2ClientLost.Closed_Reason__c = 'Test';

		oppP3Shell = TestFactoryOpportunity.makeShell('PROSPECT 3', prospect3.Id, today, Opportunity_Service.STAGE_PENDING_SUBMISSION);

		oppP4ShellLost = TestFactoryOpportunity.makeShell('PROSPECT 4 LOST', prospect4.Id, today, Opportunity_Service.STAGE_CLOSED_LOST);
		oppP4ShellLost.Closed_Reason__c = 'Test';

		insert new List<Opportunity>{ oppP1Benefits, oppP1Client, oppP2Client, oppP2ClientLost, oppP3Shell, oppP4ShellLost };
	}

	/**
	 * @description loadData load the static data.
	 */
	private static void loadData() {
		List<Account> accounts = [SELECT Id, Name FROM Account ORDER BY Name ASC];
		prospect1 = accounts.get(0);
		prospect2 = accounts.get(1);
		prospect3 = accounts.get(2);
		prospect4 = accounts.get(3);

		List<Opportunity> opps = [
			SELECT
				Id,
				Name,
				RecordTypeId,
				AccountId,
				Credit_Approval_Status__c,
				AM_Approval_Status__c,
				Contract_Approval_Status__c,
				OK_For_Risk_Approval_Status__c
			FROM Opportunity
			ORDER BY Name ASC
		];
		oppP1Benefits = opps.get(0);
		oppP1Client = opps.get(1);
		oppP2Client = opps.get(2);
		oppP2ClientLost = opps.get(3);
		oppP3Shell = opps.get(4);
		oppP4ShellLost = opps.get(5);
	}

	/**
	 * @description test_mayCreate tests the mayCreate() method.
	 */
	@IsTest
	static void test_blockCreation() {
		loadData();

		Date today = Date.today();

		Opportunity oppTest = TestFactoryOpportunity.makeShell('SHELL', prospect1.Id, today, Opportunity_Service.STAGE_PENDING_SUBMISSION);
		Opportunity oppP3 = TestFactoryOpportunity.makeClient('PROSPECT 3', prospect3.Id, today, Opportunity_Service.STAGE_DISCOVERY_MEETING);

		Test.startTest();

		OpportunityClient.blockCreation(new List<Opportunity>{ oppTest, oppP3 });

		Test.stopTest();

		Assert.isTrue(oppTest.hasErrors(), 'Not allowed to create a "Creation of Shell" opportunity directly');
		Assert.isTrue(oppTest.hasErrors(), 'Not allowed to create a "Client" opportunity when one is already active');
	}

	/**
	 * @description test_mayCreate tests the mayCreate() method.
	 */
	@IsTest
	static void test_mayCreate() {
		loadData();

		Test.startTest();

		Set<Id> idAccounts = new Set<Id>{ prospect1.Id, prospect2.Id, prospect3.Id, prospect4.Id };
		Map<Id, Boolean> createable = OpportunityClient.mayCreate(idAccounts);

		Test.stopTest();

		Assert.areEqual(4, createable.size(), 'All the prospects should have a mapping');

		Assert.isFalse(createable.get(prospect1.Id), 'Prospect 1 should be NOT allowed to create');
		Assert.isFalse(createable.get(prospect2.Id), 'Prospect 2 should be NOT allowed to create');
		Assert.isFalse(createable.get(prospect3.Id), 'Prospect 3 should be NOT allowed to create');
		Assert.isTrue(createable.get(prospect4.Id), 'Prospect 4 should be allowed to create');
	}

	/**
	 * @description test_setToCreationShell tests the setShells() method.
	 */
	@IsTest
	static void test_setToCreationShell() {
		loadData();

		Id idrtShell = RecordTypeService.getId(Opportunity_Service.OPPORTUNITY, Opportunity_Service.RECORDTYPE_SHELL);

		prospect1.Verified__c = true;
		prospect1.External_Id__c = null;

		oppP1Client.Credit_Approval_Status__c = 'Approved';
		oppP1Client.AM_Approval_Status__c = 'Approved';
		oppP1Client.Contract_Approval_Status__c = 'Approved';
		oppP1Client.OK_For_Risk_Approval_Status__c = 'Approved';

		Test.startTest();

		opportunityClient.setToCreationShell(new List<Opportunity> { oppP1Benefits, oppP1Client });

		Test.stopTest();

		Assert.areEqual(idrtShell, oppP1Client.RecordTypeId);
	}

	@IsTest
	static void test_allApproved() {
		loadData();

		Assert.isFalse(OpportunityClient.allApproved(oppP1Client));

		oppP1Client.Credit_Approval_Status__c = 'Approved';
		oppP1Client.AM_Approval_Status__c = 'Approved';
		oppP1Client.Contract_Approval_Status__c = 'Approved';
		oppP1Client.OK_For_Risk_Approval_Status__c = 'Approved';

		Assert.isTrue(OpportunityClient.allApproved(oppP1Client));
	}

	/**
	 * @description test_CreateClientOpportunityCallCenter.
	 */
	@IsTest
	public static void test_CreateClientOpportunityCallCenter() {
		Account branch = TestFactoryAccount.createBranch('TEST');
		User userCallCenter = TestFactoryUser.createUser('Call', 'Center', 'BBSI Call Center', branch.External_Id__c);
		Account prospect = TestFactoryAccount.createProspect('TEST PROSPECT', null, null);

		Opportunity opp = TestFactoryOpportunity.makeClient('TEST PROSPECT - CLIENT OPP - LOST', prospect.Id, Date.today().addDays(5), Opportunity_Service.STAGE_CLOSED_LOST);
		opp.Closed_Reason__c = 'TESTING OPPORTUNITY';
		
		Test.startTest();
		
		try {
			System.runAs(userCallCenter) {
				opp = TestFactoryOpportunity.makeClient('TEST PROSPECT - CLIENT OPP', prospect.Id, Date.today().addDays(30), Opportunity_Service.STAGE_DISCOVERY_MEETING);
				insert opp;
			}
		} catch (Exception e) {
			Assert.isTrue(false, 'Should not throw an exception');
		}
		
		Test.stopTest();
	}
}