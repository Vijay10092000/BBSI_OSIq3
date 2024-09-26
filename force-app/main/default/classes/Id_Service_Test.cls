/**
 * Id_Service_Test contains tests for Id_Service.
 */
@IsTest
public with sharing class Id_Service_Test {
	private static final String BRANCH_NAME = 'TEST BRANCH';
	private static final String BUSINESS_UNIT_NAME = 'TEST BUSINESS UNIT';

	private static Account branch;
	private static User user1;
	private static Contact contact1;
	private static Business_Unit__c bu1;
	private static Business_Unit_Contact__c buMember1;

	@TestSetup
	static void makeData() {
		Account branch = TestFactoryAccount.makeBranch(BRANCH_NAME);
		branch.Region__c = 'SoCal';
		branch.Zone__c = '1';
		insert branch;

		User user1 = testFactoryUser.createUser('TEST', 'USER', 'BBSI Standard', branch.External_Id__c);
		Contact contact1 = TestFactoryContact.createEmployee(user1.Id, 'TEST', 'USER', branch.Id);

		Business_Unit__c bu1 = TestFactoryBusinessUnit.createBusinessUnit(BUSINESS_UNIT_NAME, branch.Id);
		Business_Unit_Contact__c buMember1 = TestFactoryBusinessUnitContact.createBusinessUnitContact(
			bu1,
			true,
			'Payroll',
			contact1
		);
	}

	private static void readData() {
		branch = [SELECT Id FROM Account WHERE Name = :BRANCH_NAME LIMIT 1];
		user1 = [SELECT Id FROM User WHERE Name = 'TEST USER' LIMIT 1];
		contact1 = [SELECT Id FROM Contact WHERE Name = 'TEST USER' LIMIT 1];
		bu1 = [SELECT Id FROM Business_Unit__c WHERE Name = :BUSINESS_UNIT_NAME LIMIT 1];
		buMember1 = [SELECT Id FROM Business_Unit_Contact__c WHERE BU_Member__c = :contact1.Id LIMIT 1];
	}

	@IsTest
	public static void test_isType() {
		readData();

		Assert.isTrue(Id_Service.isType(user1.Id, 'User'));
		Assert.isTrue(Id_Service.isType(branch.Id, 'Account'));
		Assert.isTrue(Id_Service.isType(contact1.Id, 'Contact'));
		Assert.isTrue(Id_Service.isType(bu1.Id, 'Business_Unit__c'));
		Assert.isTrue(Id_Service.isType(buMember1.Id, 'Business_Unit_Contact__c'));

		Assert.isFalse(Id_Service.isType(user1.Id, 'Account'));
		Assert.isFalse(Id_Service.isType(branch.Id, 'Contract'));
		Assert.isFalse(Id_Service.isType(contact1.Id, 'FeedItem'));

		Assert.isFalse(Id_Service.isType(null, 'Account'));
	}

	@IsTest
	public static void test_getSObjectName() {
		readData();

		Assert.areEqual('User', Id_Service.getSObjectName(user1.Id));
		Assert.areEqual('Account', Id_Service.getSObjectName(branch.Id));
		Assert.areEqual('Contact', Id_Service.getSObjectName(contact1.Id));
		Assert.areEqual('Business_Unit__c', Id_Service.getSObjectName(bu1.Id));
		Assert.areEqual('Business_Unit_Contact__c', Id_Service.getSObjectName(buMember1.Id));
	}

	@IsTest
	public static void test_getSObjectLabel() {
		readData();

		Assert.areEqual('User', Id_Service.getSObjectLabel(user1.Id));
		Assert.areEqual('Account', Id_Service.getSObjectLabel(branch.Id));
		Assert.areEqual('Contact', Id_Service.getSObjectLabel(contact1.Id));
		Assert.areEqual('Business Unit', Id_Service.getSObjectLabel(bu1.Id));
		Assert.areEqual('Business Unit Member', Id_Service.getSObjectLabel(buMember1.Id));
	}

	@IsTest
	public static void test_makeIdString() {
		readData();

		Assert.areEqual('', Id_Service.makeIdString(null), 'NULL should become blank string');

		Assert.areEqual(String.valueOf(contact1.id), Id_Service.makeIdString(contact1.Id), 'Id should become a string');
	}
}