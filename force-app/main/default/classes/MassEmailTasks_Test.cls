/**
 * @description MassEmailTasks_Test contains tests for the MassEmailTasks class.
 */
@IsTest
@SuppressWarnings('PMD.ApexAssertionsShouldIncludeMessage')
public with sharing class MassEmailTasks_Test {
	private static User sysAdmin;
	private static User owner;
	private static User userBenefitsRep;

	private static Account branch;
	private static Account client1;

	private static Contact contact1;

	private static MassEmailPerson person1;

	@TestSetup
	static void makeData() {
		branch = TestFactoryAccount.makeBranch('TEST BRANCH');
		branch.BillingPostalCode = '99999';
		branch.ShippingPostalCode = '99999';
		branch.External_Id__c = 'a1000';
		insert branch;

		owner = TestFactoryUser.makeUser('TEST_OWNER', 'TEST_OWNER', 'BBSI Standard', 'a1000');
		insert new List<User>{ owner };

		userBenefitsRep = TestFactoryUser.makeUser('TEST_REP', 'TEST_REP', 'BBSI Standard', 'a1000');
		userBenefitsRep.Is_Benefits_Representative__c = true;
		insert userBenefitsRep;

		branch.Benefits_Representative__c = userBenefitsRep.Id;
		update branch;

		client1 = TestFactoryAccount.makeClient('CLIENT_1', null, null);
		client1.Primary_Contact_Name__c = 'CONTACT_1';
		client1.Primary_Contact_Email__c = 'CONTACT_1@client1.zzz';
		client1.Benefits_Representative__c = userBenefitsRep.Id;

		System.runAs(owner) {
			insert new List<Account>{ client1 };
		}

		contact1 = TestFactoryContact.makeContact('CONTACT_1', 'CONTACT_1', 'Client Contact', client1.Id);
		contact1.Email = 'CONTACT_1@client1.zzz';
		contact1.Primary__c = true;
		insert new List<Contact>{ contact1 };
	}

	static void readData() {
		List<User> users = [
			SELECT Id, Name, Email
			FROM User
			WHERE LastName IN ('TEST_OWNER', 'TEST_REP')
			ORDER BY LastName ASC
		];

		Assert.areEqual(2, users.size());
		owner = users.get(0);
		userBenefitsRep = users.get(1);

		List<Account> accounts = [
			SELECT
				Id,
				Name,
				OwnerId,
				Owner.Name,
				Owner.Email,
				Benefits_Representative__r.Name,
				Benefits_Representative__r.Email
			FROM Account
			WHERE NAME IN ('CLIENT_1', 'TEST BRANCH')
			ORDER BY Name ASC
		];

		Assert.areEqual(2, accounts.size());
		client1 = accounts.get(0);
		branch = accounts.get(1);

		List<Contact> contacts = [SELECT Id, Name, Email FROM Contact WHERE LastName IN ('CONTACT_1') ORDER BY LastName ASC];
		contact1 = contacts.get(0);

		person1 = new MassEmailPerson(
			'Id1',
			client1.Id,
			client1.Name,
			contact1.Id,
			'CONTACT',
			contact1.Name,
			contact1.Email,
			owner.Id,
			owner.Name,
			owner.Email,
			userBenefitsRep.Id,
			userBenefitsRep.Name,
			userBenefitsRep.Email
		);
	}

	@IsTest
	public static void test_create() {
		readData();

		MassEmailTasks.create(new List<MassEmailPerson>{ person1 }, 'CompletedEmailTask');

		List<Task> tasks = [
			SELECT Id, WhoId, WhatId, Subject
			FROM Task
			WHERE WhoId = :person1.idPerson AND WhatId = :person1.idAccount
		];

		Assert.areEqual(1, tasks.size(), 'Should have created a Task');
	}
}