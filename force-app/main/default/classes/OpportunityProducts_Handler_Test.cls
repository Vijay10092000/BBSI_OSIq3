/**
 * @description OpportunityProducts_Handler_Test contains tests for the OpportunityProducts_Handler class.
 */
@IsTest
@SuppressWarnings('PMD.ApexAssertionsShouldIncludeMessage')
public without sharing class OpportunityProducts_Handler_Test {
	private static OpportunityProducts_TestEnv env = new OpportunityProducts_TestEnv();

	@TestSetup
	static void makeData() {
		env.create();
	}

	@IsTest
	public static void test_constructor() {
		env.load();

		Test.startTest();

		Opportunity oppBenefits = TestFactoryOpportunity.createBenefits(
			'Benefits',
			env.client.Id,
			Date.today(),
			'Pending Submission'
		);

		List<Opportunity> newOpps = new List<Opportunity>{ env.opp, oppBenefits };

		OpportunityProducts_Handler handler = new OpportunityProducts_Handler(null, newOpps);

		Test.stopTest();

		Assert.areEqual(null, handler.oldOpps);
		Assert.areEqual(1, handler.newOpps.size());
		Assert.areEqual(env.opp, handler.newOpps.get(0));
		Assert.areNotEqual(null, handler.assets);
		Assert.isTrue(handler.assets.isEmpty());
	}

	@IsTest
	public static void test_readAccounts() {
		env.load();

		List<Opportunity> newOpps = new List<Opportunity>{ env.opp };

		OpportunityProducts_Handler handler = new OpportunityProducts_Handler(null, newOpps);

		Test.startTest();

		handler.readAccounts();

		Test.stopTest();

		Assert.areNotEqual(null, handler.relatedAccounts);
		Assert.areEqual(1, handler.relatedAccounts.size());
		Assert.isTrue(handler.relatedAccounts.containsKey(env.client.Id));
	}

	@IsTest
	public static void test_readContacts() {
		env.load();

		List<Opportunity> newOpps = new List<Opportunity>{ env.opp };

		OpportunityProducts_Handler handler = new OpportunityProducts_Handler(null, newOpps);

		Test.startTest();

		handler.readContacts();

		Test.stopTest();

		Assert.areNotEqual(null, handler.relatedContacts);
		Assert.areEqual(1, handler.relatedContacts.size());
		Assert.isTrue(handler.relatedContacts.containsKey(env.client.Id));
		Assert.areEqual(env.contactUser.Id, handler.relatedContacts.get(env.client.Id).Id);
	}

	@IsTest
	public static void test_findClosedWon() {
		env.load();

		env.opp.StageName = 'Product Closed Won';

		List<Opportunity> newOpps = new List<Opportunity>{ env.opp };

		OpportunityProducts_Handler handler = new OpportunityProducts_Handler(null, newOpps);

		Test.startTest();

		handler.findClosedWon();

		Test.stopTest();

		Assert.areNotEqual(null, handler.closedWon);
		Assert.areEqual(1, handler.closedWon.size());
		Assert.areEqual(env.opp, handler.closedWon.get(0));
	}

	@IsTest
	public static void test_createClosedWonAssets() {
		env.load();

		env.opp.StageName = 'Product Closed Won';

		List<Opportunity> newOpps = new List<Opportunity>{ env.opp };

		OpportunityProducts_Handler handler = new OpportunityProducts_Handler(null, newOpps);

		Test.startTest();

		handler.findClosedWon();
		handler.readLineItems();
		handler.createClosedWonAssets();

		Test.stopTest();

		Assert.areNotEqual(null, handler.assets);
		Assert.areEqual(5, handler.assets.size());
	}

	@IsTest
	static void test_readContactRoles() {
		env.load();

		env.opp.BBSIU_for_Clients_Request_Demo_Access__c = true;

		List<Opportunity> newOpps = new List<Opportunity>{ env.opp };

		OpportunityProducts_Handler handler = new OpportunityProducts_Handler(null, newOpps);

		Test.startTest();

		handler.findDemoRequest();
		handler.readContactRoles();

		Test.stopTest();

		Assert.areNotEqual(null, handler.relatedContactRoles);
		Assert.areEqual(1, handler.relatedContactRoles.size());
	}

	@IsTest
	static void test_getContactsFromRoles() {
		env.load();

		env.opp.BBSIU_for_Clients_Request_Demo_Access__c = true;

		List<Opportunity> newOpps = new List<Opportunity>{ env.opp };

		OpportunityProducts_Handler handler = new OpportunityProducts_Handler(null, newOpps);

		Test.startTest();

		handler.findDemoRequest();
		handler.readContactRoles();
		Map<Id, Contact> contacts = handler.getContactsFromRoles();

		Test.stopTest();

		Assert.areNotEqual(null, contacts);
		Assert.areEqual(1, contacts.size());
	}
}