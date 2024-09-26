/**
 * @description ContactClient_Test contains tests for the ContactClient class.
 */
@IsTest
public without sharing class ContactClient_Test {
	private static Account client1;
	private static Account client2;
	private static Account rp1;
	private static Account rp2;
	private static Contact producer1;
	private static Contact producer2;
	private static Contact contact1;
	private static Contact contact2;

    @TestSetup
	static void makeData() {
		rp1 = TestFactoryAccount.makeReferralPartner('TEST_REFERRAL_PARTNER_ONE', '% of Margin', 1.0, null);
		rp2 = TestFactoryAccount.makeReferralPartner('TEST_REFERRAL_PARTNER_TWO', '% of Margin', 2.0, null);
		insert new List<Account>{ rp1, rp2 };

		producer1 = TestFactoryContact.makeProducer('TEST_PRODUCER', 'ONE', rp1.Id);
		producer2 = TestFactoryContact.makeProducer('TEST_PRODUCER', 'TWO', rp2.Id);
		insert new List<Contact>{ producer1, producer2 };

		client1 = TestFactoryAccount.makeClient('TEST_CLIENT_ONE', null, null);
		client1.Assigned_Referral_Partner__c = rp1.Id;
		client1.Producer__c = producer1.Id;
		client2 = TestFactoryAccount.makeClient('TEST_CLIENT_TWO', null, null);
		client2.Assigned_Referral_Partner__c = rp2.Id;
		client2.Producer__c = producer2.Id;
		insert new List<Account>{ client1, client2 };

		contact1 = TestFactoryContact.makeClient('TEST_CLIENT', 'AONE', client1.Id);
		contact2 = TestFactoryContact.makeClient('TEST_CLIENT', 'BTWO', client2.Id);
		insert new List<Contact>{ contact1, contact2 };
	}

	static void loadData() {
		List<Account> accounts = [
			SELECT Id, Name, Producer__c, Assigned_Referral_Partner__c
			FROM Account
			WHERE Name LIKE 'TEST_%'
			ORDER BY Name
		];

		client1 = accounts.get(0);
		client2 = accounts.get(1);
		rp1 = accounts.get(2);
		rp2 = accounts.get(3);

		List<Contact> contacts = [
			SELECT Id, Name, AccountId, Producer__c, Referral_Partner__c
			FROM Contact
			WHERE Name LIKE 'TEST_%'
			ORDER BY FirstName ASC, LastName ASC
		];

		contact1 = contacts.get(0);
		contact2 = contacts.get(1);
		producer1 = contacts.get(2);
		producer2 = contacts.get(3);

		Assert.areEqual(producer1.Id, client1.Producer__c, 'Initial Setup client1 should have producer1');
		Assert.areEqual(producer2.Id, client2.Producer__c, 'Initial Setup client2 should have producer2');
		Assert.areEqual(rp1.Id, client1.Assigned_Referral_Partner__c, 'Initial Setup client1 should have rp1');
		Assert.areEqual(rp2.Id, client2.Assigned_Referral_Partner__c, 'Initial Setup client2 should have rp2');

		Assert.areEqual(rp1.Id, contact1.Referral_Partner__c, 'Initial Setup');
		Assert.areEqual(rp2.Id, contact2.Referral_Partner__c, 'Initial Setup');
		Assert.areEqual(producer1.Id, client1.Producer__c, 'Initial Setup');
		Assert.areEqual(producer2.Id, client2.Producer__c, 'Initial Setup');

		Assert.areEqual(client1.Id, contact1.AccountId, 'Initial Setup');
		Assert.areEqual(producer1.Id, contact1.Producer__c, 'Initial Setup');
		Assert.areEqual(rp1.Id, contact1.Referral_Partner__c, 'Initial Setup');

		Assert.areEqual(client2.Id, contact2.AccountId, 'Initial Setup');
		Assert.areEqual(producer2.Id, contact2.Producer__c, 'Initial Setup');
		Assert.areEqual(rp2.Id, contact2.Referral_Partner__c, 'Initial Setup');
	}

	@IsTest
	public static void test_AddContact() {
		loadData();

		Test.startTest();

		Contact contact = TestFactoryContact.createClient('TEST_CLIENT', 'CTHREE', client1.Id);

		Test.stopTest();

		contact = [
			SELECT Id, Name, AccountId, Producer__c, Referral_Partner__c
			FROM Contact
			WHERE Id = :contact.Id
		];

		Assert.areEqual(client1.Id, contact.AccountId, 'Should belong to client 1');
		Assert.areEqual(client1.Producer__c, contact.Producer__c, 'Producer should be same as account');
		Assert.areEqual(client1.Assigned_Referral_Partner__c, contact.Referral_Partner__c, 'Referral Partner should be same as account');
	}

	@IsTest
	public static void test_ChangeProducer() {
		loadData();

		Contact producer = TestFactoryContact.createProducer('TEST_PRODUCER', 'CTHREE', rp1.Id);


		Test.startTest();

		client1.Producer__c = producer.Id;

		update client1;

		Test.stopTest();

		contact1 = [
			SELECT Id, Name, AccountId, Producer__c, Referral_Partner__c
			FROM Contact
			WHERE Id = :contact1.Id
		];

        System.debug(
            '\n-----------------------------------------------------' +
            '\n-  Producer:  ' + producer.Id + '   ' + producer +
            '\n-  Producer1: ' + producer1.Id + '   ' + producer1 +
            '\n-  Producer2: ' + producer2.Id + '   ' + producer2 +
            '\n-  Contact 1: ' + contact1.Id + '   ' + contact1 +
            '\n-----------------------------------------------------'
        );
		Assert.areEqual(producer.Id, contact1.Producer__c, 'Should the new producer');

		Assert.areEqual(client1.Id, contact1.AccountId, 'Should belong to client 1');
		Assert.areEqual(client1.Producer__c, contact1.Producer__c, 'Producer should be same as account');
		Assert.areEqual(client1.Assigned_Referral_Partner__c, contact1.Referral_Partner__c, 'Referral Partner should be same as account');
	}

	@IsTest
	public static void test_ChangeReferralPartner() {
		loadData();

		Test.startTest();

		client1.Assigned_Referral_Partner__c = rp2.Id;
		client1.Producer__c = producer2.Id;

		update client1;

		Test.stopTest();

		contact1 = [
			SELECT Id, Name, AccountId, Producer__c, Referral_Partner__c
			FROM Contact
			WHERE Id = :contact1.Id
		];

		Assert.areEqual(producer2.Id, contact1.Producer__c, 'Should now be producer 2');
		Assert.areEqual(rp2.Id, contact1.Referral_Partner__c, 'Should now be referral partner 2');

		Assert.areEqual(client1.Id, contact1.AccountId, 'Should belong to client 1');
		Assert.areEqual(client1.Producer__c, contact1.Producer__c, 'Producer should be same as account');
		Assert.areEqual(client1.Assigned_Referral_Partner__c, contact1.Referral_Partner__c, 'Referral Partner should be same as account');
	}
}