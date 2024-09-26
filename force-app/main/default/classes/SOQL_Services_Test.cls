/**
 * @description SOQL_Services_Test contains tests for the SOQL_Services class.
 */
@IsTest
@SuppressWarnings('PMD.ApexAssertionsShouldIncludeMessage')
public without sharing class SOQL_Services_Test {
	private static final String EXPECTED_QUERY = 'SELECT Id,Name FROM Account WHERE Name = \'CLIENT 1\' LIMIT 1';
	private static final String EXPECTED_FIELD_LIST = 'Id,Name,StageName';

	@IsTest
	static void test_getFullObjectQuery() {
		String accountSELECT = SOQL_Services.getFullObjectQuery('Account');

		System.debug(LoggingLevel.INFO, 'QUERY:\n' + accountSELECT);

		System.assertEquals(true, accountSELECT.startsWith('SELECT '));
		System.assertEquals(true, accountSELECT.endsWith(' FROM Account '));

		Schema.SObjectType convertType = Schema.getGlobalDescribe().get('Account');
		Map<String, Schema.sObjectField> fieldMap = convertType.getDescribe().Fields.getMap();

		accountSELECT = accountSELECT.toLowerCase();
		for (String field : fieldMap.keySet()) {
			Schema.DescribeFieldResult dfr = fieldMap.get(field).getDescribe();

			if (dfr.isAccessible()) {
				System.assertEquals(true, accountSELECT.contains(field), 'Missing field: ' + field);
			}
		}
	}

	@IsTest
	static void test_joinIds() {
		Id idTest1 = Id.valueOf('0018A0000000000001');
		Id idTest2 = Id.valueOf('0018A0000000000002');
		Id idTest3 = Id.valueOf('0018A0000000000003');

		Set<Id> setNone = new Set<Id>{};
		Set<Id> setOne = new Set<Id>{ idTest1 };
		Set<Id> setOneTwo = new Set<Id>{ idTest1, idTest2 };
		Set<Id> setOneTwoThree = new Set<Id>{ idTest1, idTest2, idTest3 };

		Assert.areEqual('', SOQL_Services.joinIds(setNone));
		Assert.areEqual('\'0018A0000000000001\'', SOQL_Services.joinIds(setOne));
		Assert.areEqual('\'0018A0000000000001\',\'0018A0000000000002\'', SOQL_Services.joinIds(setOneTwo));
		Assert.areEqual(
			'\'0018A0000000000001\',\'0018A0000000000002\',\'0018A0000000000003\'',
			SOQL_Services.joinIds(setOneTwoThree)
		);
	}
	@IsTest
	static void test_makeQuery() {
		Set<String> fields = new Set<String>{ 'Id', 'Name' };

		String query = SOQL_Services.makeQuery('Account', fields, 'WHERE Name = \'CLIENT 1\' LIMIT 1');

		Assert.areEqual(EXPECTED_QUERY, query);
	}

	@IsTest
	static void test_callQuery() {
		TestFactoryAccount.createClient('CLIENT 1', null, null);

		Set<String> fields = new Set<String>{ 'Id', 'Name' };

		Map<Id, SObject> accounts = SOQL_Services.callQuery('Account', fields, 'WHERE Name = \'CLIENT 1\' LIMIT 1');

		Assert.areEqual(1, accounts.size());
	}

	@IsTest
	static void test_fieldList() {
		Set<String> fields = new Set<String>{ 'Id', 'Name', 'StageName' };

		String result = SOQL_Services.fieldList(fields);

		Assert.areEqual(EXPECTED_FIELD_LIST, result);

		Assert.areEqual('Id', SOQL_Services.fieldList(null));
	}
}