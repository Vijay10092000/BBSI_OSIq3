/**
 * @description Contact_Service_Test contains test method form the Contact_Service class.
 */
@IsTest
@SuppressWarnings('PMD.ApexAssertionsShouldIncludeMessage, PMD.LocalVariableNamingConventions')
public without sharing class Contact_Service_Test {
	static private Account branch;
	static private User bdmUser1;
	static private User bdmUser2;
	static private User bdmUser3;
	static private Contact bdmContact1;
	static private Contact bdmContact2;
	static private Contact bdmContact3;

	@TestSetup
	static void makeData() {
		User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
		Account branch = new Account();
		System.runAs(currentUser) {
           branch = TestFactoryAccount.createBranch('BRANCH', 'TEST', null, 'area.managerone@bbsi.zzz');
		}
       	bdmUser1 =TestFactoryUser.makeBDM(null, 'BDMONE', 'BBSI Standard', 'TEST');
        bdmUser2 =TestFactoryUser.makeBDM(null, 'BDMTWO', 'BBSI Standard', 'TEST');
		bdmUser3 =TestFactoryUser.makeBDM(null, 'BDMTHREE', 'BBSI Standard', 'TEST');
        bdmUser3.AD_Username__c = 'User3';
		List<User> users = new List<User>{ bdmUser1, bdmUser2, bdmUser3 };
		insert users;
		System.runAs(currentUser) {
            bdmContact1 = TestFactoryContact.makeEmployee(bdmUser1.Id, null, 'BDMONE', branch.Id);
			bdmContact2 = TestFactoryContact.makeEmployee(bdmUser2.Id, null, 'BDMTWO', branch.Id);
            bdmContact2.Bdm_Acronym__c = 'ACRONYM2';
			insert new List<Contact>{ bdmContact1, bdmContact2 };              
		}
	}

	static void loadData() {
		branch = [SELECT Id, Name FROM Account WHERE RecordType.Name = 'BBSI Branch' AND Name = 'BRANCH'];
		bdmUser1 = [SELECT Id, Name, Acronym__c FROM User WHERE LastName = 'BDMONE'];
		bdmUser2 = [SELECT Id, Name, Acronym__c FROM User WHERE LastName = 'BDMTWO'];
		bdmUser3 = [SELECT Id, Name, Acronym__c FROM User WHERE LastName = 'BDMTHREE'];
		bdmContact1 = [SELECT Id, Name, Bdm_Acronym__c FROM Contact WHERE LastName = 'BDMONE'];
		bdmContact2 = [SELECT Id, Name, Bdm_Acronym__c FROM Contact WHERE LastName = 'BDMTWO'];
		bdmContact3 = [SELECT Id, Name, Bdm_Acronym__c FROM Contact WHERE LastName = 'BDMTHREE'];
	}

	/**
	 * @description testSetPrimaryOnInsert_Set checks the first contact on an account becomes primary.
	 */
	@IsTest
	static void testSetPrimaryOnInsert_Set() {
		Account a = TestFactoryAccount.createBranch('TEST ACCOUNT 1', '99999', null, null);
		
		Test.startTest();
		Contact c = new Contact(
			AccountId = a.Id,
			FirstName = 'Test',
			LastName = 'Testerman',
			RecordTypeId = RecordTypeService.getId('Contact', 'BBSI Employee')
		);
		Contact_Services.setPrimaryOnInsert(new List<Contact>{ c });
		Test.stopTest();

		Assert.areEqual(true, c.Primary__c);
	}

	/**
	 * @description testSetPrimaryOnInsert_NoSet checks the second (or later) contact on an account becomes primary.
	 */
	@IsTest
	static void testSetPrimaryOnInsert_NoSet() {
		Account a = TestFactoryAccount.createBranch('TEST ACCOUNT 1', '99999', null, null);
		TestFactoryContact.createEmployee(null, null, 'Lastname', a.Id);
		
		Contact c = new Contact(
			AccountId = a.Id,
			FirstName = 'Test',
			LastName = 'Testerman',
			RecordTypeId = RecordTypeService.getId('Contact', 'BBSI Employee')
		);

		Contact_Services.setPrimaryOnInsert(new List<Contact>{ c });

		Assert.areEqual(false, c.Primary__c);
	}

	/**
	 * @description testSetPrimaryOnInsert checks when multiple contacts are added to a new account,
	 * no primary is added.
	 */
	@IsTest
	static void testSetPrimaryOnInsert() {
		Account a1 = TestFactoryAccount.makeBranch('TEST ACCOUNT 1', null, null, null);
		Account a2 = TestFactoryAccount.makeBranch('TEST ACCOUNT 2', null, null, null);
		Account a3 = TestFactoryAccount.makeBranch('TEST ACCOUNT 3', null, null, null);		
		insert new List<Account>{ a1, a2, a3 };

		Contact c1_a1 = TestFactoryContact.makeEmployee(null, null, 'Lastname1', a1.Id);
		Contact c2_a1 = TestFactoryContact.makeEmployee(null, null, 'Lastname2', a1.Id);
		Contact c3_a2 = TestFactoryContact.makeEmployee(null, null, 'Lastname3', a2.Id);
		Contact c4_a2 = TestFactoryContact.makeEmployee(null, null, 'Lastname4', a2.Id);
		Contact c5_a3 = TestFactoryContact.makeEmployee(null, null, 'Lastname5', a3.Id);
		insert new List<Contact>{ c1_a1, c2_a1, c3_a2, c4_a2, c5_a3 };

		Map<Id, Contact> mapContacts = new Map<Id, Contact>([SELECT Id, Primary__c FROM Contact]);

		Assert.areEqual(false, mapContacts.get(c1_a1.Id).Primary__c);
		Assert.areEqual(false, mapContacts.get(c2_a1.Id).Primary__c);
		Assert.areEqual(false, mapContacts.get(c3_a2.Id).Primary__c);
		Assert.areEqual(false, mapContacts.get(c4_a2.Id).Primary__c);
		Assert.areEqual(true, mapContacts.get(c5_a3.Id).Primary__c);
	}

	/**
	 * @description testTooManyContact shows for too many contacts on account does not throw exception.
	 * This was an issue in the code which has been fixed.
	 */
	@IsTest
	static void testTooManyContact() {
		Account a = TestFactoryAccount.createBranch('TEST ACCOUNT 1', '99999', null, null);

		List<Contact> contacts = new List<Contact>();

		for (Integer i = 0; i < 204; i++) {
			contacts.add(TestFactoryContact.makeEmployee(null, null, 'Lastname1', a.Id));
		}
		insert contacts;

		Test.startTest();

		try {
			TestFactoryContact.createEmployee(null, null, 'Lastname2', a.Id);
		} catch (Exception e) {
			Assert.isTrue(false, 'Failed: Exception thrown: ' + e.getMessage());
		}

		Test.stopTest();
	}

	@IsTest
	static void test_checkForDuplicatePrimaryContacts_HavePrimary() {
		Account acc1 = TestFactoryAccount.createClient('Test Account 1', null, null);
		TestFactoryContact.createClient(null, 'Contact1', acc1.Id);

		Test.startTest();
		Contact contact = TestFactoryContact.makeClient(null, 'Contact1', acc1.Id);
		contact.Primary__c = true;
		Test.stopTest();

		try {
			insert contact;
			Assert.isTrue(false, 'Should throw exception');
		} catch (Exception e) {
			Assert.isTrue(true, 'Should throw exception.  Already a primary contact');
		}
	}

	@IsTest
	static void test_checkForDuplicatePrimaryContacts_NoPrimary() {
		Account acc1 = TestFactoryAccount.createClient('Test Account 1', null, null);

		Contact contact = TestFactoryContact.createClient(null, 'Contact1', acc1.Id);
		contact.Primary__c = false;
		update contact;

		Test.startTest();
		contact.Primary__c = true;
		Test.stopTest();

		try {
			update contact;
			Assert.isTrue(true, 'Should not throw exception');
		} catch (Exception e) {
			Assert.isTrue(false, 'Should not throw exception.  ' + e.getMessage());
		}
	}

	@IsTest
	static void test_getContactAttachments() {
		Account account = TestFactoryAccount.createClient('Account', null, null);
		Contact contact1 = TestFactoryContact.makeClient(null, 'Contact1', account.Id);
		Contact contact2 = TestFactoryContact.makeClient(null, 'Contact2', account.Id);
		Contact contact3 = TestFactoryContact.makeClient(null, 'Contact3', account.Id);
		List<Contact> contacts = new List<Contact>{contact1, contact2, contact3};
		insert contacts;
		Attachment attachment1 = TestFactoryAttachment.makeAttachment('Name1', 'Body1', contact1.Id,null);
		Attachment attachment2 = TestFactoryAttachment.makeAttachment('Name2', 'Body2', contact1.Id,null);
		Attachment attachment3 = TestFactoryAttachment.makeAttachment('Name3', 'Body3', contact1.Id,null);
		Attachment attachment4 = TestFactoryAttachment.makeAttachment('Name4', 'Body4', contact2.Id,null);		
		insert new List<Attachment>{ attachment1, attachment2, attachment3, attachment4 };

		Assert.areEqual(
			3,
			Contact_services.getContactAttachments(new Set<Id>{ contact1.Id }).size(),
			'Contact1 should have 3 Attachments'
		);
		Assert.areEqual(
			1,
			Contact_services.getContactAttachments(new Set<Id>{ contact2.Id }).size(),
			'Contact1 should have 1 Attachment'
		);
		Assert.areEqual(
			0,
			Contact_services.getContactAttachments(new Set<Id>{ contact3.Id }).size(),
			'Contact1 should have no Attachments'
		);
		Assert.areEqual(
			4,
			Contact_services.getContactAttachments(new Set<Id>{ contact1.Id, contact2.Id, contact3.Id }).size(),
			'All Contacts have 4 Attachments'
		);
	}

	@IsTest
	static void test_getContactNotes() {
		Account account = TestFactoryAccount.createClient('Account', null, null);
		Contact contact1 = TestFactoryContact.makeClient(null, 'Contact1', account.Id);
		Contact contact2 = TestFactoryContact.makeClient(null, 'Contact2', account.Id);
		Contact contact3 = TestFactoryContact.makeClient(null, 'Contact3', account.Id);
		List<Contact> contacts = new List<Contact>{contact1, contact2, contact3};
		insert contacts;
		Note note1 = TestFactoryNote.makeNote(contact1.Id, 'Title1', 'Body1', null);
		Note note2 = TestFactoryNote.makeNote(contact1.Id, 'Title2', 'Body2', null);
		Note note3 = TestFactoryNote.makeNote(contact1.Id, 'Title3', 'Body3', null);
		Note note4 = TestFactoryNote.makeNote(contact2.Id, 'Title4', 'Body4', null);
		insert new List<Note>{ note1, note2, note3, note4 };

		Assert.areEqual(
			3,
			Contact_services.getContactNotes(new Set<Id>{ contact1.Id }).size(),
			'Contact1 should have 3 Notes'
		);
		Assert.areEqual(
			1,
			Contact_services.getContactNotes(new Set<Id>{ contact2.Id }).size(),
			'Contact1 should have 1 Note'
		);
		Assert.areEqual(
			0,
			Contact_services.getContactNotes(new Set<Id>{ contact3.Id }).size(),
			'Contact1 should have no Notes'
		);
		Assert.areEqual(
			4,
			Contact_services.getContactNotes(new Set<Id>{ contact1.Id, contact2.Id, contact3.Id }).size(),
			'All Contacts have 4 Notes'
		);
	}

	@IsTest
	static void test_updateUserAcronym() {
		loadData();

		Test.startTest();

		Assert.isTrue(String.isBlank(bdmUser1.Acronym__c), 'BDM Acronym should not be set on User 1');
		Assert.areEqual('ACRONYM2', bdmUser2.Acronym__c, 'BDM Acronym should be set on User 2');
		Assert.isTrue(String.isBlank(bdmUser3.Acronym__c), 'BDM Acronym should not be set on User 3');

		Contact bdmContact3 = [SELECT Id, Bdm_Acronym__c FROM Contact WHERE User_Id__c = :bdmUser3.Id];
		Assert.areEqual(null, bdmContact3.Bdm_Acronym__c, 'BDM Acronym should not be set on Contact 3');

		bdmContact1.BDM_Acronym__c = 'ACRONYM1';
		bdmContact2.BDM_Acronym__c = '';

		update new List<Contact>{ bdmContact1, bdmContact2 };

		Test.stopTest();

		bdmUser1 = [SELECT Id, Acronym__c FROM User WHERE Id = :bdmUser1.Id];
		bdmUser2 = [SELECT Id, Acronym__c FROM User WHERE Id = :bdmUser2.Id];
		bdmUser3 = [SELECT Id, Acronym__c FROM User WHERE Id = :bdmUser3.Id];

		Assert.areEqual('ACRONYM1', bdmUser1.Acronym__c, 'BDM Acronym should be set on User 1');
		Assert.isTrue(String.isBlank(bdmUser2.Acronym__c), 'BDM Acronym should not be set on User 2');
		Assert.isTrue(String.isBlank(bdmUser3.Acronym__c), 'BDM Acronym should not be set on User 3');
	}

	@IsTest
	public static void test_method() {
		Account a1 = TestFactoryAccount.makeClient('ACCOUNT 1', null, null);
		Account a2 = TestFactoryAccount.makeClient('ACCOUNT 2', null, null);
		Account a3 = TestFactoryAccount.makeClient('ACCOUNT 3', null, null);
		insert new List<Account>{ a1, a2, a3 };

		Contact c1 = TestFactoryContact.makeEmployee(null, null, 'Contact1', a1.Id);
		Contact c2 = TestFactoryContact.makeEmployee(null, null, 'Contact2', a2.Id);
		Contact c3 = TestFactoryContact.makeEmployee(null, null, 'Contact3', a3.Id);
		insert new List<Contact>{ c1, c2, c3 };

		Map<Id, Id> mapContactToAccount = Contact_Services.getRelatedAccountId(new Set<Id>{ c1.Id, c2.Id, c3.Id });

		Assert.areEqual(3, mapContactToAccount.keySet().size());
		Assert.areEqual(a1.Id, mapContactToAccount.get(c1.Id));
		Assert.areEqual(a2.Id, mapContactToAccount.get(c2.Id));
		Assert.areEqual(a3.Id, mapContactToAccount.get(c3.Id));
	}

	@IsTest
	static void test_getContactEvents() {
		Account a1 = TestFactoryAccount.makeClient('ACCOUNT 1', null, null);
		Account a2 = TestFactoryAccount.makeClient('ACCOUNT 2', null, null);
		Account a3 = TestFactoryAccount.makeClient('ACCOUNT 3', null, null);
		insert new List<Account>{ a1, a2, a3 };

		Contact c1 = TestFactoryContact.makeEmployee(null, null, 'Contact1', a1.Id);
		Contact c2 = TestFactoryContact.makeEmployee(null, null, 'Contact2', a2.Id);
		Contact c3 = TestFactoryContact.makeEmployee(null, null, 'Contact3', a3.Id);
		insert new List<Contact>{ c1, c2, c3 };

		DateTime dtEvent = DateTime.now().addDays(7);

		Event event1 = new Event(
			WhoId = c1.Id,
			Type = 'Meeting',
			Description = 'EVENT 1',
			ActivityDateTime = dtEvent,
			DurationInMinutes = 60,
			OwnerId = UserInfo.getUserId()
		);
		Event event2 = new Event(
			WhoId = c2.Id,
			Type = 'Meeting',
			Description = 'EVENT 2',
			ActivityDateTime = dtEvent,
			DurationInMinutes = 60,
			OwnerId = UserInfo.getUserId()
		);
		Event event3 = new Event(
			WhoId = c3.Id,
			Type = 'Meeting',
			Description = 'EVENT 3',
			ActivityDateTime = dtEvent,
			DurationInMinutes = 60,
			OwnerId = UserInfo.getUserId()
		);
		insert new List<Event>{ event1, event2, event3 };

		Test.startTest();

		List<Event> eventsC1 = contact_services.getContactEvents(new Set<Id>{ c1.Id });
		List<Event> eventsC2 = contact_services.getContactEvents(new Set<Id>{ c2.Id });
		List<Event> eventsC3 = contact_services.getContactEvents(new Set<Id>{ c3.Id });
		List<Event> eventsC1C2C3 = contact_services.getContactEvents(new Set<Id>{ c1.Id, c2.Id, c3.Id });

		Test.stopTest();

		Assert.areEqual(1, eventsC1.size());
		Assert.areEqual(1, eventsC2.size());
		Assert.areEqual(1, eventsC3.size());
		Assert.areEqual(3, eventsC1C2C3.size());
	}

	@IsTest
	static void test_getContactTasks() {
		Account a1 = TestFactoryAccount.makeClient('ACCOUNT 1', null, null);
		Account a2 = TestFactoryAccount.makeClient('ACCOUNT 2', null, null);
		Account a3 = TestFactoryAccount.makeClient('ACCOUNT 3', null, null);
		insert new List<Account>{ a1, a2, a3 };

		Contact c1 = TestFactoryContact.makeEmployee(null, null, 'Contact1', a1.Id);
		Contact c2 = TestFactoryContact.makeEmployee(null, null, 'Contact2', a2.Id);
		Contact c3 = TestFactoryContact.makeEmployee(null, null, 'Contact3', a3.Id);
		insert new List<Contact>{ c1, c2, c3 };

		Date today = Date.today();

		Task taskC1_1 = Task_Service.createTask(
			'Task',
			c1.Id,
			null,
			UserInfo.getUserId(),
			'Contact1 First',
			null,
			today.addDays(7)
		);
		Task taskC1_2 = Task_Service.createTask(
			'Task',
			c1.Id,
			null,
			UserInfo.getUserId(),
			'Contact1 Second',
			null,
			today.addDays(14)
		);
		Task taskC2_1 = Task_Service.createTask(
			'Task',
			c2.Id,
			null,
			UserInfo.getUserId(),
			'Contact2 First',
			null,
			today.addDays(2)
		);
		insert new List<Task>{ taskC1_1, taskC1_2, taskC2_1 };

		Test.startTest();

		List<Task> tasksC1C3 = contact_services.getContactTasks(new Set<Id>{ c1.Id, c3.Id });
		List<Task> tasksC2 = contact_services.getContactTasks(new Set<Id>{ c2.Id });

		Test.stopTest();

		Assert.areEqual(2, tasksC1C3.size());
		Assert.areEqual(1, tasksC2.size());
	}
}