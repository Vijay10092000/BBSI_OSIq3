/**
 * @description OpportunityProductCases_Test contains tests for the OpportunityProductCases class.
 */
@IsTest
@SuppressWarnings('PMD.ApexAssertionsShouldIncludeMessage')
public without sharing class OpportunityProductCases_Test {
	private static OpportunityProducts_TestEnv env = new OpportunityProducts_TestEnv();

	@TestSetup
	static void makeData() {
		env.create();
	}

	@IsTest
	public static void test_createBbsiuContract() {
		env.load();

		Test.startTest();

		OpportunityProductCases maker = new OpportunityProductCases(
			env.relatedAccounts,
			env.relatedContacts,
			env.relatedLineItems,
			env.relatedFileIds
		);

		maker.createBbsiuContract(env.opp);

		Test.stopTest();

		Assert.areEqual(1, maker.cases.size());

		Case workCase = maker.cases.get(0);

		Assert.isTrue(workCase.Subject.startsWith('New BBSIU Setup'));
	}

	@IsTest
	public static void test_createBbsiuSetup() {
		env.load();

		Test.startTest();

		OpportunityProductCases maker = new OpportunityProductCases(
			env.relatedAccounts,
			env.relatedContacts,
			env.relatedLineItems,
			env.relatedFileIds
		);

		maker.createBbsiuSetup(env.opp);

		Test.stopTest();

		Assert.areEqual(1, maker.cases.size());

		Case workCase = maker.cases.get(0);

		Assert.isTrue(workCase.Subject.startsWith('BBSIU Billing Setup'));
	}

	@IsTest
	public static void test_createLmsDemo() {
		env.load();

		List<Id> idContacts = new List<Id>{ env.contactUser.Id, env.contactClient.Id };

		Map<Id, Contact> contacts = new Map<Id, Contact>([
			SELECT Id, Name, AccountId
			FROM Contact
			WHERE Id IN :idContacts
		]);

		Test.startTest();

		OpportunityProductCases maker = new OpportunityProductCases(
			env.relatedAccounts,
			env.relatedContacts,
			env.relatedLineItems,
			env.relatedFileIds
		);

		OpportunityContactRole role = env.relatedContactRoles.get(0);
		Contact contact = contacts.get(role.ContactId);

		Boolean created = maker.createLmsDemo(env.opp, role, contact);

		Test.stopTest();

		Assert.isTrue(created);
		Assert.areEqual(1, maker.cases.size());

		Case workCase = maker.cases.get(0);

		System.debug(LoggingLevel.INFO, workCase.Subject);

		Assert.isTrue(workCase.Subject.startsWith('Demo Access Requested'));
	}
}