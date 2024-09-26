/**
 * @description CaseCreationUtility_Test tests commands in CaseCreationUtility.
 */
@IsTest
public with sharing class CaseCreationUtility_Test {
	@IsTest
	static void test_getFieldToAPIName() {
		Map<String, String> caseFields = CaseCreationUtility.getFieldToAPIName('Case');
		Assert.areEqual('assetid', caseFields.get('Asset ID'), 'Did not find Field Name for Case field "Escalated".');
		Assert.areEqual('type', caseFields.get('Category'), 'Did not find Field Name for Case field "Category".');
		Assert.areEqual('recordtypeid', caseFields.get('Record Type ID'), 'Did not find Field Name for Case field "Category".');
	}

	@IsTest
	static void getFieldType() {
		Assert.areEqual(Schema.DisplayType.ID, CaseCreationUtility.getFieldType('Case', 'Case ID'), 'Should have found an ID');
		Assert.areEqual(Schema.DisplayType.BOOLEAN, CaseCreationUtility.getFieldType('Case', 'Resolved'), 'Should have found a BOOLEAN');
		Assert.areEqual(null, CaseCreationUtility.getFieldType('Case', '--INVALID--'), 'Should not find Field Name for Case field named "--INVALID--".');
	}

	@IsTest
	static void test_getFieldAPIName() {
		Assert.areEqual('assetid', CaseCreationUtility.getFieldAPIName('Case', 'Asset ID'), 'Did not find Field Name for Case field "Asset".');
		Assert.areEqual('type', CaseCreationUtility.getFieldAPIName('Case', 'Category'), 'Did not find Field Name for Case field "Category".');
		Assert.areEqual('recordtypeid', CaseCreationUtility.getFieldAPIName('Case', 'Record Type ID'), 'Did not find Field Name for Case field "Category".');
		Assert.areEqual(null, CaseCreationUtility.getFieldAPIName('Case', '--INVALID--'), 'Should not find Field Name for Case field named "--INVALID--".');
	}
}