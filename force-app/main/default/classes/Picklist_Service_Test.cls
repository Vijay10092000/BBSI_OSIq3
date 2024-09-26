/**
 * @description Picklist_Service_Test tests commands in Picklist_Service.
 */
@IsTest
public without sharing class Picklist_Service_Test {
	private static final String JSON_PICKLIST_DEPENDENT =
		'{' +
		' "eTag":"22785e69f361a5d1c6af42e845942634",' +
		' "picklistFieldValues":{' +
		'  "Dependent__c":{' +
		'   "controllerValues":{"Login":0,"Access":1,"Reports":2},' +
		'   "defaultValue":null,' +
		'   "eTag":"ecdabbf9c8b489fd28f301972ac20d1c",' +
		'   "url":"/services/data/v48.0/ui-api/object-info/Case/picklist-values/0122J000000FAKE000/Dependent__c",' +
		'   "values":[' +
		'    {"attributes":null,"label":"AngelHair","validFor":[0,1,2],"value":"AngelHair"},' +
		'    {"attributes":null,"label":"Baseware","validFor":[0,1],"value":"Baseware"},' +
		'    {"attributes":null,"label":"Other","validFor":[0,2],"value":"Other"}' +
		'   ]' +
		'  }' +
		' }' +
		'}';

	private static final String JSON_PICKLIST_INDEPENDENT =
		'{' +
		' "eTag":"22785e69f361a5d1c6af42e845942634",' +
		' "picklistFieldValues":{' +
		'  "Independent__c":{' +
		'   "controllerValues":{},' +
		'   "defaultValue":null,' +
		'   "eTag":"7fb41632be4d7b89115219a90e97f8b9",' +
		'   "url":"/services/data/v48.0/ui-api/object-info/Case/picklist-values/0122J000000FAKE001/Independent__c",' +
		'   "values":[' +
		'     {"attributes":null,"label":"Yes","validFor":[],"value":"Yes"},' +
		'     {"attributes":null,"label":"No","validFor":[],"value":"No"}' +
		'    ]' +
		'  }' +
		' }' +
		'}';

	private static final String JSON_PICKLIST_THREE =
		'{' +
		' "eTag":"22785e69f361a5d1c6af42e845942634",' +
		' "picklistFieldValues":{' +
		'  "Independent__c":{' +
		'   "controllerValues":{},' +
		'   "defaultValue":null,' +
		'   "eTag":"7fb41632be4d7b89115219a90e97f8b9",' +
		'   "url":"/services/data/v48.0/ui-api/object-info/Case/picklist-values/0122J000000FAKE002/Independent__c",' +
		'   "values":[' +
		'     {"attributes":null,"label":"Yes","validFor":[],"value":"Yes"},' +
		'     {"attributes":null,"label":"No","validFor":[],"value":"No"}' +
		'    ]' +
		'  },' +
		'  "Dependent1__c":{' +
		'   "controllerValues":{"Login":0,"Access":1,"Reports":2},' +
		'   "defaultValue":null,' +
		'   "eTag":"ecdabbf9c8b489fd28f301972ac20d1c",' +
		'   "url":"/services/data/v48.0/ui-api/object-info/Case/picklist-values/0122J000000FAKE003/Dependent1__c",' +
		'   "values":[' +
		'    {"attributes":null,"label":"AngelHair","validFor":[0,1,2],"value":"AngelHair"},' +
		'    {"attributes":null,"label":"Baseware","validFor":[0,1],"value":"Baseware"},' +
		'    {"attributes":null,"label":"Other","validFor":[0,2],"value":"Other"}' +
		'   ]' +
		'  },' +
		'  "Dependent2__c":{' +
		'   "controllerValues":{"Off":0,"On":1},' +
		'   "defaultValue":null,' +
		'   "eTag":"ecdabbf9c8b489fd28f301972ac20d1c",' +
		'   "url":"/services/data/v48.0/ui-api/object-info/Case/picklist-values/0122J000000FAKE0004/Dependent2__c",' +
		'   "values":[' +
		'    {"attributes":null,"label":"Junk","validFor":[0,1],"value":"Junk"},' +
		'    {"attributes":null,"label":"Other","validFor":[0],"value":"Other"}' +
		'   ]' +
		'  }' +
		' }' +
		'}';

	private static final String JSON_PICKLIST_MISSING_PICKLIST_FIELD_VALUES =
		'{' +
		' "eTag":"22785e69f361a5d1c6af42e845942634"' +
		'}';

	@IsTest
	static void test_parseJsonPicklistValues_Dependent() {
		List<String> subvalues;
		Map<String, Map<String, List<String>>> picklistValues = Picklist_Service.parseJsonPicklistValues(
			JSON_PICKLIST_DEPENDENT
		);

		Assert.areEqual(1, picklistValues.keySet().size(), 'Should have found 1 picklist');

		Assert.isTrue(picklistValues.containsKey('Dependent__c'), 'Dependent__c should be the picklist');
		Map<String, List<String>> dependents = picklistValues.get('Dependent__c');
		Assert.areNotEqual(null, dependents, 'Should have found data');
		Assert.areEqual(3, dependents.keySet().size(), 'Dependent__c should have 3 entries');

		Assert.isTrue(dependents.containsKey('Login'), '"Login" should be one of the values');
		Assert.areEqual(3, dependents.get('Login').size(), 'There should be 3 values below "AngelHair"');
		subvalues = dependents.get('Login');
		Assert.isTrue(subvalues.contains('AngelHair'), '"AngelHair" should be one of the values under "Login"');
		Assert.isTrue(subvalues.contains('Baseware'), '"Baseware" should be one of the values under "Login"');
		Assert.isTrue(subvalues.contains('Other'), '"Other" should be one of the values under "Login"');

		Assert.isTrue(dependents.containsKey('Access'), '"Access" should be one of the values');
		Assert.areEqual(2, dependents.get('Access').size(), 'There should be 2 values below "Access"');
		subvalues = dependents.get('Access');
		Assert.isTrue(subvalues.contains('AngelHair'), '"AngelHair" should be one of the values under "Access"');
		Assert.isTrue(subvalues.contains('Baseware'), '"Baseware" should be one of the values under "Access"');

		Assert.isTrue(dependents.containsKey('Reports'), '"Reports" should be one of the values');
		Assert.areEqual(2, dependents.get('Reports').size(), 'There should be 2 values below "Reports"');
		subvalues = dependents.get('Reports');
		Assert.isTrue(subvalues.contains('AngelHair'), '"AngelHair" should be one of the values under "Reports"');
		Assert.isTrue(subvalues.contains('Other'), '"Other" should be one of the values under "Reports"');
	}

	@IsTest
	static void test_parseJsonPicklistValues_Independent() {
		Map<String, Map<String, List<String>>> picklistValues = Picklist_Service.parseJsonPicklistValues(
			JSON_PICKLIST_INDEPENDENT
		);

		Assert.areEqual(1, picklistValues.keySet().size(), 'Should have found 1 picklist');

		Assert.isTrue(picklistValues.containsKey('Independent__c'), 'Independent__c should be the picklist');
		Map<String, List<String>> independents = picklistValues.get('Independent__c');
		Assert.areNotEqual(null, independents, 'Should have found data');
		Assert.areEqual(2, independents.keySet().size(), 'Independent__c should have 2 entries');

		Assert.isTrue(independents.containsKey('Yes'), '"Yes" should be one of the values');
		Assert.areEqual(0, independents.get('Yes').size(), 'There should be no values below "Yes"');

		Assert.isTrue(independents.containsKey('No'), '"No" should be one of the values');
		Assert.areEqual(0, independents.get('No').size(), 'There should be no values below "No"');
	}

	@IsTest
	static void test_readRecordType() {
		Assert.areEqual(null, Picklist_Service.sPicklistValues, '"sPicklistValues" should not be set');
		Assert.areEqual(null, Picklist_Service.sIdRecordType, '"sIdRecordType" should not be set');
		Assert.areEqual(0, Picklist_Service.countCallouts, '"countCallouts" should start at zero');

		Test.setMock(HttpCalloutMock.class, new GenericMockCallout(200, 'SUCCESS', JSON_PICKLIST_INDEPENDENT, null));

		Picklist_Service.readRecordType('Case', '0012f00000XFAKEID1');

		Assert.areNotEqual(null, Picklist_Service.sPicklistValues, '"sPicklistValues" should be set');
		Assert.areEqual(
			'0012f00000XFAKEID1',
			String.valueOf(Picklist_Service.sIdRecordType),
			'"sIdRecordType" should be set'
		);
		Assert.areEqual(1, Picklist_Service.countCallouts, '"countCallouts" should be set');

		Test.setMock(HttpCalloutMock.class, new GenericMockCallout(500, 'FAILURE', JSON_PICKLIST_DEPENDENT, null));
		Picklist_Service.readRecordType('Case', '0012f00000XFAKEID2');

		Assert.areEqual(null, Picklist_Service.sPicklistValues, '"sPicklistValues" should have cleared');
		Assert.areEqual(null, Picklist_Service.sIdRecordType, '"sIdRecordType" should have cleared');
		Assert.areEqual(2, Picklist_Service.countCallouts, '"countCallouts" should be set');
	}

	@IsTest
	static void test_getPicklistValuesByRecordType_Fail() {
		Test.setMock(
			HttpCalloutMock.class,
			new GenericMockCallout(200, 'SUCCESS', JSON_PICKLIST_MISSING_PICKLIST_FIELD_VALUES, null)
		);

		Map<String, List<String>> mapValues = Picklist_Service.getPicklistValuesByRecordType(
			'Case',
			'0012f00000XFAKEID1',
			'Independent__c'
		);

		Assert.isTrue(
			mapValues.isEmpty(),
			'Should not return a value since no picklistFieldValues was in the return Http body.'
		);
	}
}