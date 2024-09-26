/**
 * @description PopulateContacts_test contains tests for the PopulateContacts class
 */
@IsTest
public with sharing class PopulateContacts_test {
	@IsTest
	static void testInsert() {
		Account branch = TestFactoryAccount.createBranch('TEST BRANCH');
		User user = TestFactoryUser.makeUser('FirstName', 'LastName', 'BBSI Standard', branch.External_Id__c);
		user.AD_Username__c = 'testUsername';

		Test.startTest();

		insert user;

		Test.stopTest();

		Id idrtContactEmployee = RecordTypeService.getId('Contact', 'BBSI Employee');

		Contact c = [
			SELECT Id, RecordTypeId, FirstName, LastName, Email, Phone, MobilePhone
			FROM Contact
			WHERE User_Id__c = :user.Id
		];

		Assert.areEqual(idrtContactEmployee, c.RecordTypeId);
		Assert.areEqual('FirstName', c.FirstName);
		Assert.areEqual('LastName', c.LastName);
		Assert.areEqual(user.Email, c.Email);
		Assert.areEqual(user.Phone, c.Phone);
		Assert.areEqual(user.MobilePhone, c.MobilePhone);
	}

	@IsTest
	static void testUpdate() {
		Account branch = TestFactoryAccount.createBranch('TEST BRANCH');
		User user = TestFactoryUser.makeUser('FirstName', 'LastName', 'BBSI Standard', branch.External_Id__c);
		user.AD_Username__c = 'testUsername';
		insert user;

		user.FirstName = 'CHANGED';

		Test.startTest();

		update user;

		Test.stopTest();

		Contact c = [
			SELECT Id, RecordTypeId, FirstName, LastName, Email, Phone, MobilePhone
			FROM Contact
			WHERE User_Id__c = :user.Id
		];

		Assert.areEqual(c.FirstName, 'CHANGED');
	}

	@IsTest
	static void bulkTest() {
		Account branch = TestFactoryAccount.createBranch('TEST BRANCH');

		User user;
		User[] users = new List<User>();

		for (Integer x = 0; x < 200; x++) {
			
			user = TestFactoryUser.makeUser('!!TEST', x.format(), 'BBSI Standard', branch.External_Id__c);
			user.AD_Username__c = 'test' + x.format();
			users.add(user);
		}

		Test.startTest();

		try {
			insert users;
		} catch (DmlException e) {
			Assert.fail('Exception should not have be thrown. \n' + e.getMessage() + '\n' + e.getStackTraceString());
		}

		Test.stopTest();

		List<Contact> contacts = [SELECT Id, Name FROM Contact WHERE FirstName = '!!TEST' ORDER BY Name ASC];

		Assert.areEqual(200, contacts.size());
	}
}