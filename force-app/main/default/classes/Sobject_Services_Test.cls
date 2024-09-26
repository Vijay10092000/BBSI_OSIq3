/**
 * @description Sobject_Services_Test contains tests for the Sobject_Servies class.
 */
@IsTest
@SuppressWarnings('PMD.ApexAssertionsShouldIncludeMessage, PMD.AvoidHardcodingId')
public with sharing class Sobject_Services_Test {
	static final String FAKE_ACCOUNT_ID = '0012J00002brWoZMAU';
	static final String FAKE_CONTACT_ID = '0032J00003lytWnQAI';

	@IsTest
	public static void test_getType() {
		Assert.areEqual('Account', Sobject_Services.getType(FAKE_ACCOUNT_ID));
		Assert.areEqual('Contact', Sobject_Services.getType(FAKE_CONTACT_ID));

		Assert.areEqual(null, Sobject_Services.getType(null));
	}
	@IsTest
	public static void test_getIdPrefix() {
		Assert.areEqual('001', Sobject_Services.getIdPrefix('Account'));
		Assert.areEqual('003', Sobject_Services.getIdPrefix('Contact'));
	}

	@IsTest
	public static void test_getFieldNames() {
		List<String> fields = Sobject_Services.getFieldNames('Account');

		Assert.isTrue(fields.contains('id'));
		Assert.isTrue(fields.contains('phone'));

		Assert.isTrue(fields.contains('external_id__c'));
		Assert.isTrue(fields.contains('naics__c'));
	}

	@IsTest
	public static void test_getCustomFieldNames() {
		List<String> fields = Sobject_Services.getCustomFieldNames('Account');

		Assert.isFalse(fields.contains('id'));
		Assert.isFalse(fields.contains('phone'));

		Assert.isTrue(fields.contains('external_id__c'));
		Assert.isTrue(fields.contains('naics__c'));
	}

	@IsTest
	public static void test_getFieldsMap() {
		Map<String, Schema.sObjectField> mapFields = Sobject_Services.getFieldsMap('Account');

		Assert.isFalse(mapFields.isEmpty());

		Assert.isTrue(mapFields.containsKey('id'));
		Assert.isTrue(mapFields.containsKey('phone'));

		Assert.isTrue(mapFields.containsKey('external_id__c'));
		Assert.isTrue(mapFields.containsKey('naics__c'));
	}

	@IsTest
	public static void test_getValue() {
		Assert.areEqual((Decimal) 1, Sobject_Services.getValue((Decimal) null, (Decimal) 1));
		Assert.areEqual((Decimal) 2, Sobject_Services.getValue((Decimal) 2, (Decimal) 1));
	}

	@IsTest
	public static void test_toString() {
		Account account = new Account(Name = 'TEST');

		Assert.areEqual('Account\n  Name: TEST', Sobject_Services.toString(account));
	}

	@IsTest
	public static void test_getFieldsSet() {
		Account account = new Account(Id = FAKE_ACCOUNT_ID, Name = 'TEST');

		List<String> names;

		names= Sobject_Services.getFieldsSet(account);
		Assert.areEqual('Id', names.get(0));
		Assert.areEqual('Name', names.get(1));

		names = Sobject_Services.getFieldsSet(null);
		Assert.isTrue(names.isEmpty());
	}

	@IsTest
	public static void test_describeObjects() {
		Map<String, Schema.DescribeSObjectResult> results = Sobject_Services.describeObjects();

		Assert.isTrue(0 < results.size());
		Assert.isTrue(results.containsKey('account'));
		Assert.isTrue(results.containsKey('contact'));
		Assert.isTrue(results.containsKey('opportunity'));
		Assert.isTrue(results.containsKey('lead'));
	}

	@IsTest
	public static void test_describeObject() {
		Schema.DescribeSObjectResult result = Sobject_Services.describeObject('Account');

		Assert.isNotNull(result);
	}

	@IsTest
	public static void test_describeFields() {
		Map<String, Schema.DescribeFieldResult> results = Sobject_Services.describeFields('Account');

		Assert.isTrue(0 < results.size());
		Assert.isTrue(results.containsKey('name'));
		Assert.isTrue(results.containsKey('ownerid'));
	}

	@IsTest
	public static void test_describeField() {
		Schema.DescribeFieldResult result = Sobject_Services.describeField('Account', 'Name');

		Assert.isNotNull(result);
	}

	@IsTest
	public static void test_getSearchResult() {
		Account branch1 = TestFactoryAccount.makeBranch('BRANCH ONE');
		Account branch2 = TestFactoryAccount.makeBranch('BRANCH TWO');
		Account branch3 = TestFactoryAccount.makeBranch('BRANCH THREE');
		Account branch4 = TestFactoryAccount.makeBranch('BRANCH FOUR');
		Account branch5 = TestFactoryAccount.makeBranch('BRANCH FIVE');
		insert new List<Account>{ branch1, branch2, branch3, branch4, branch5 };

		Test.startTest();

		List<Sobject_Services.SObjectResult> result1 = Sobject_Services.getSearchResult('Account', 'Name', 'Name LIKE \'%BRANCH%\'', 'Name ASC', null);
		List<Sobject_Services.SObjectResult> result2 = Sobject_Services.getSearchResult('Account', 'Name', 'Name LIKE \'%ONE%\'', 'Name ASC', 10);
		List<Sobject_Services.SObjectResult> result3 = Sobject_Services.getSearchResult('Account', 'External_Id__c', 'External_Id__c != NULL', 'External_ID__c ASC', 10);

		Test.stopTest();

		Assert.areEqual(5, result1.size());
		Assert.areEqual(1, result2.size());
		Assert.areEqual(5, result3.size());
	}
}