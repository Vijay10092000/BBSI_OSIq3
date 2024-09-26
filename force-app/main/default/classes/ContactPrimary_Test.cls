/**
 * @description ContactPrimary_Test contains test methods for the ContactPrimary class.
 */
@IsTest
public without sharing class ContactPrimary_Test {
	/**
	 * @description assertPrimary read the contact and account and asser the contact
	 * is the Primary Contact on the account.
	 * @param  idContact  Contact identifier
	 * @param  idAccount  Account identifier
	 */
	private static void assertPrimary(Id idContact, Id idAccount) {
		Contact contact = [
			SELECT Id, Name, Primary__c, Email, Direct__c, Direct_Extension__c, Phone, MobilePhone
			FROM Contact
			WHERE Id = :idContact
			LIMIT 1
		];

		Account account = [
			SELECT
				Id,
				Primary_Contact_Name__c,
				Primary_Contact_Email__c,
				Primary_Contact_Direct__c,
				Primary_Contact_Direct_Extension__c,
				Primary_Contact_Phone__c,
				Primary_Contact_Mobile__c
			FROM Account
			WHERE Id = :idAccount
			LIMIT 1
		];

		Assert.isTrue(contact.Primary__c, 'Contact should be Primary Contact on Account');

		Assert.areEqual(contact.Name, account.Primary_Contact_Name__c, 'Name should match');
		Assert.areEqual(contact.Email, account.Primary_Contact_Email__c, 'Email should match');
		Assert.areEqual(contact.Direct__c, account.Primary_Contact_Direct__c, 'Direct should match');
		Assert.areEqual(contact.Direct_Extension__c, account.Primary_Contact_Direct_Extension__c, 'Direct Extension should match');
		Assert.areEqual(contact.Phone, account.Primary_Contact_Phone__c, 'Phone should match');
		Assert.areEqual(contact.MobilePhone, account.Primary_Contact_Mobile__c, 'Mobile Phone should match');
	}

	/**
	 * @description test_PrimaryContact_Simple first Contact onto an Account becomes Primary.
	 */
	@IsTest
	@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
	static void test_PrimaryContact() {
		Account account = TestFactoryAccount.createClient('TestAccount', null, null);

		Contact contact = TestFactoryContact.makeClient('Test', 'Contact', account.Id);
		contact.Direct__c = '555-555-5555';
		contact.Direct_Extension__c = 123;
		contact.Phone = '555-555-0001';
		contact.MobilePhone = '555-555-0002';
		insert contact;

		assertPrimary(contact.Id, account.Id);
	}

	/**
	 * @description test_PrimaryContact_Update first Contact onto an Account becomes Primary
	 * and when data is updated on the Contact, the account is updated.
	 */
	@IsTest
	static void test_PrimaryContact_Update() {
		Account account = TestFactoryAccount.createClient('TestAccount', null, null);

		Contact contact = TestFactoryContact.makeClient('Test', 'Contact', account.Id);
		contact.Direct__c = '555-555-5555';
		contact.Direct_Extension__c = 123;
		contact.Phone = '555-555-0001';
		contact.MobilePhone = '555-555-0002';
		insert contact;

		assertPrimary(contact.Id, account.Id);

		try {
			// Update Primary data
			contact.FirstName = 'Milo';
			contact.Email = 'new.email@bbsi.zzz';
			contact.Direct__c = '444-444-4444';
			contact.Direct_Extension__c = null;
			contact.Phone = '444-444-0001';
			contact.MobilePhone = '444-444-0002';
			update contact;

			assertPrimary(contact.Id, account.Id);
		} catch (DmlException e) {
			Assert.fail('Exception should not be thrown exception');
		}
	}

	/**
	 * @description test_SecondContact second Contact does not become Primary.
	 */
	@IsTest
	static void test_SecondContact() {
		Account account = TestFactoryAccount.createClient('TestAccount', null, null);

		Contact contact1 = TestFactoryContact.createClient('Test', 'ContactONE', account.Id);
		assertPrimary(contact1.id, account.id);

		Contact contact2 = TestFactoryContact.createClient('Test', 'ContactTWO', account.Id);

		contact2 = [SELECT Id, Name, Primary__c FROM Contact WHERE Id = :contact2.Id LIMIT 1];
		Assert.isFalse(contact2.Primary__c, 'contact2 should NOT be the Primary Contact');
	}

	/**
	 * @description test_SecondPrimary tries to set a second Primary Contact.
	 */
	@IsTest
	static void test_SecondPrimary() {
		Account account = TestFactoryAccount.createClient('TestAccount', null, null);
		Contact contact1 = TestFactoryContact.createClient('Test', 'ContactONE', account.Id);
		assertPrimary(contact1.id, account.id);

		try {
			Contact contact2 = TestFactoryContact.makeClient('Test', 'ContactTWO', account.Id);
			contact2.Primary__c = true;
			insert contact2;

			Assert.fail('Exception should have been thrown');
		} catch (DmlException e) {
			Assert.isTrue(true, 'Exception was thrown');
		}
	}

	/**
	 * @description multipleContacts multiple Contacts added to an Account
	 * do not create a Primary.
	 */
	@IsTest
	static void multipleContacts() {
		Account account = TestFactoryAccount.createClient('TestAccount', null, null);

		List<Contact> listContact = new List<Contact>();
		for (integer index = 0; index < 5; index++) {
			listContact.add( TestFactoryContact.makeClient('Test', 'Contact' + index, account.Id) );
		}

		insert listContact;

		account = [SELECT Id, Primary_Contact_Name__c, Primary_Contact_Email__c FROM Account WHERE Id = :account.Id];
		Assert.isNull(account.Primary_Contact_Name__c, 'Should have no Primary');
		Assert.isNull(account.Primary_Contact_Email__c, 'Should have no Primary');

		Contact workContact = listContact[2];
		workContact.Primary__c = true;
		workContact.Email = 'test2@test.com';
		update workContact;

		assertPrimary(workContact.Id, account.Id);
	}

	@IsTest
	@SuppressWarnings('PMD.ApexAssertionsShouldIncludeMessage')
	static void test_changesMade() {
		Contact contactInitial = new Contact(
			FirstName = 'Test',
			LastName = 'Contact',
			Email = 'test.contact@bbsi.zzz',
			Phone = '555-555-0001',
			MobilePhone = '555-555-0002',
			Direct__c = '555-555-0003',
			Direct_Extension__c = null
		);

		Contact contactChanged = new Contact(
			FirstName = contactInitial.FirstName,
			LastName = contactInitial.LastName,
			Email = contactInitial.Email,
			Phone = contactInitial.Phone,
			MobilePhone = contactInitial.MobilePhone,
			Direct__c = contactInitial.Direct__c,
			Direct_Extension__c = contactInitial.Direct_Extension__c
		);

		Assert.isFalse(ContactPrimary.changesMade(contactInitial, contactChanged));

		contactChanged.FirstName = 'CHANGED';
		Assert.isTrue(ContactPrimary.changesMade(contactInitial, contactChanged));

		contactChanged.FirstName = contactInitial.FirstName;
		contactChanged.LastName = 'CHANGED';
		Assert.isTrue(ContactPrimary.changesMade(contactInitial, contactChanged));

		contactChanged.LastName = contactInitial.LastName;
		contactChanged.Email = 'changed@bbsi.zzz';
		Assert.isTrue(ContactPrimary.changesMade(contactInitial, contactChanged));

		contactChanged.Email = contactInitial.Email;
		contactChanged.Phone = '444-444-0001';
		Assert.isTrue(ContactPrimary.changesMade(contactInitial, contactChanged));

		contactChanged.Phone = contactInitial.Phone;
		contactChanged.MobilePhone = '444-444-0003';
		Assert.isTrue(ContactPrimary.changesMade(contactInitial, contactChanged));

		contactChanged.MobilePhone = contactInitial.MobilePhone;
		contactChanged.Direct__c = '444-444-0003';
		Assert.isTrue(ContactPrimary.changesMade(contactInitial, contactChanged));

		contactChanged.Direct__c = contactInitial.Direct__c;
		contactChanged.Direct_Extension__c = 123;
		Assert.isTrue(ContactPrimary.changesMade(contactInitial, contactChanged));
	}
}