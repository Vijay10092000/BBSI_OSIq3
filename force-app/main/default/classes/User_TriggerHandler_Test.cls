/**
 * @description User_TriggerHandler_Test contains tests for the User_TriggerHandler class.
 */
@IsTest
public with sharing class User_TriggerHandler_Test {
	private static final String BRANCH_NAME = 'TEST BRANCH';
	private static final String RP_NAME = 'TEST RP';

	private static Account branch;
	private static Account rp;
	private static Account client1;

	private static User admin;
	private static User user1;
	private static User user2;

	private static Contact producer;

	private static Lead lead1;

	@TestSetup
	public static void makeData() {
		branch = TestFactoryAccount.createBranch(BRANCH_NAME);

		User admin = user1 = TestFactoryUser.makeUser('TEST', 'ADMIN', Profile_Service.SYSTEM_ADMIN, branch.External_Id__c);
		User user1 = TestFactoryUser.makeUser('TEST', 'USER1', Profile_Service.BBSI_STANDARD, branch.External_Id__c);
		user1.AD_Username__c = 'Dude';
		User user2 = TestFactoryUser.makeUser('TEST', 'USER2', Profile_Service.BBSI_STANDARD, branch.External_Id__c);
		user1.AD_Username__c = 'Sweet';

		insert new List<User>{ admin, user1, user2 };

		System.runAs(user1) {
			rp = TestFactoryAccount.createReferralPartner(RP_NAME, '% of Margin', 12.0, null);
			producer = TestFactoryContact.createProducer('TEST', 'PRODUCER', rp.Id);
			lead1 = TestFactoryLead.createClientLead('TEST', 'LEAD1', 'TEST LEAD COMPANY', null, null);
			client1 = TestFactoryAccount.createClient('TEST CLIENT1', rp.Id, producer.Id);
		}
	}

	public static void loadData() {
		branch = [SELECT Id, Name, External_Id__c FROM Account WHERE Name = :BRANCH_NAME LIMIT 1];
		rp = [SELECT Id, Name, OwnerId FROM Account WHERE Name = :RP_NAME LIMIT 1];
		client1 = [SELECT Id, Name, OwnerId FROM Account WHERE Name = 'TEST CLIENT1' LIMIT 1];

		admin = [SELECT Id, Name, FirstName, LastName, IsActive FROM User WHERE Name = 'TEST ADMIN' LIMIT 1];
		user1 = [SELECT Id, Name, FirstName, LastName, IsActive FROM User WHERE Name = 'TEST USER1' LIMIT 1];
		user2 = [SELECT Id, Name, FirstName, LastName, IsActive FROM User WHERE Name = 'TEST USER2' LIMIT 1];

		producer = [SELECT Id, Name, FirstName, LastName, OwnerId FROM Contact WHERE Name = 'TEST PRODUCER' LIMIT 1];

		lead1 = [SELECT Id, Name, FirstName, LastName, OwnerId FROM Lead WHERE Name = 'TEST LEAD1' LIMIT 1];

		Assert.areEqual(user1.Id, client1.OwnerId);
		Assert.areEqual(user1.Id, lead1.OwnerId);
	}
	
	/**
	 * Test User cannot be deactivated when own Accounts and Leads.
	 */
	@IsTest
	public static void testErrorWhenDeactivatingUser() {
		loadData();

		user1.isActive = false;

		try {
			update user1;
			Assert.fail('Exception should have occurred user1 is owner of client and lead1.');
		} catch (Exception e) {
			boolean b = e.getMessage().ToUpperCase().contains('USER IS STILL THE OWNER');
			Assert.isTrue(b, 'Correct message generated');
		}
	}

	/**
	 * Test deactive user with no owned Accounts or Leads - Part 1
	 */
	@IsTest
	public static void testUserIsDeactivatedAfterMovingRecordsAccountFirst() {
		loadData();

		//System.debug(LoggingLevel.INFO, 'AFTER LOADDATA()' + Limits.getQueries() + ' / ' + Limits.getLimitQueries());

		List<Account> accounts = [SELECT Id, Name, OwnerId FROM Account WHERE OwnerId = :user1.Id];
		for (Account a : accounts) {
			a.OwnerId = user2.Id;
			Assert.areEqual(a.OwnerId, user2.Id);
		}

		List<Lead> leads = [SELECT Id, Name, OwnerId FROM Lead WHERE OwnerId = :user1.Id];
		for (Lead l : leads) {
			l.OwnerId = user2.Id;
			Assert.areEqual(l.OwnerId, user2.Id);
		}

		Test.startTest();
		//System.debug(LoggingLevel.INFO, 'START ' + Limits.getQueries() + ' / ' + Limits.getLimitQueries());

		System.runAs(admin) {
			update accounts;
			//System.debug(LoggingLevel.INFO, 'AFTER UPDATE ACCOUNTS ' + Limits.getQueries() + ' / ' + Limits.getLimitQueries());

			accounts = [SELECT Id, Name, OwnerId FROM Account WHERE OwnerId = :user1.Id];
			Assert.isTrue(accounts.isEmpty());

			user1.isActive = false;
			try {
				update user1;
			} catch (Exception e) {
				// Should receive exception because User still owns Leads
				boolean b = e.getMessage().ToUpperCase().contains('USER IS STILL THE OWNER');
				Assert.isTrue(b, 'Wrong message generated');
			}

			update leads;
			
			//System.debug(LoggingLevel.INFO, 'AFTER UPDATE LEADS ' + Limits.getQueries() + ' / ' + Limits.getLimitQueries());

			user1.isActive = false;
			try {
				update user1;
			} catch (Exception e) {
				Assert.fail('Should not have failed: ' + e.getMessage());
			}

			user1 = [SELECT Id, IsActive FROM User WHERE Id = :user1.Id];
			Assert.isFalse(user1.IsActive, 'User should be inactive');
		}

		Test.stopTest();
	}

	/**
	 * Test deactive user with no owned Leads or Account - Part 2
	 */
	@IsTest
	public static void testUserIsDeactivatedAfterMovingRecordsLeadFirst() {
		loadData();

		List<Account> accounts = [SELECT Id, OwnerId FROM Account WHERE OwnerId = :user1.Id];
		for (Account a : accounts) {
			a.OwnerId = user2.Id;
			Assert.areEqual(a.OwnerId, user2.Id);
		}
		List<Lead> leads = [SELECT Id, OwnerId FROM Lead WHERE OwnerId = :user1.Id];
		for (Lead l : leads) {
			l.OwnerId = user2.Id;
			Assert.areEqual(l.OwnerId, user2.Id);
		}

		Test.startTest();

		System.runAs(admin) {
			update leads;

			leads = [SELECT Id FROM Lead WHERE OwnerId = :user1.Id];
			Assert.isTrue(leads.isEmpty());

			user1.isActive = false;
			try {
				update user1;
			} catch (Exception e) {
				// Should recieve exception because still owns Accounts.
				boolean b = e.getMessage().ToUpperCase().contains('USER IS STILL THE OWNER');
				Assert.areEqual(true, b, 'Wrong message generated');
			}

			update accounts;

			user1.isActive = false;
			try {
				update user1;
			} catch (Exception e) {
				Assert.fail('Should not have failed: ' + e.getMessage());
			}

			user1 = [SELECT Id, IsActive FROM User WHERE Id = :user1.Id LIMIT 1];
			Assert.isFalse(user1.IsActive, 'User should be inactive.');
		}

		Test.stopTest();
	}

	@IsTest
	public static void testContactIsCorrectAfterInsertingUserwithADUserName() {
		loadData();

		Contact c = [
			SELECT User_Id__c, FirstName, LastName, Phone, Branch_Id__c, AccountId
			FROM Contact
			WHERE User_Id__c = :user1.Id
		];

		Assert.areEqual(user1.FirstName, c.FirstName);
		Assert.areEqual(user1.LastName, c.LastName);
	}

	@IsTest
	public static void testContactIsCorrectAfterUpdateingUserwithADUserName() {
		loadData();

		Test.startTest();

		user1.FirstName = 'HansOverman';
		update user1;

		Test.stopTest();

		Contact contact = [
			SELECT User_Id__c, FirstName, LastName, Phone, Branch_Id__c, AccountId
			FROM Contact
			WHERE User_Id__c = :user1.Id
		];

		Assert.areEqual(user1.FirstName, contact.FirstName);
		Assert.areEqual(user1.LastName, contact.LastName);
	}

	@IsTest
	public static void testNoContactExistsAfterInsertingUserWithNoAdUserName() {
		loadData();
		User userTest = TestFactoryUser.createUser('TEST', 'USERTEST', 'BBSI Standard', branch.External_Id__c);

		Integer count = [SELECT COUNT() FROM Contact WHERE User_Id__c = :userTest.Id];
		Assert.areEqual(0, count);
		
		Test.startTest();

		userTest.AD_Username__c = 'testpal';
		update userTest;

		Test.stopTest();

		Contact contact = [
			SELECT User_Id__c, FirstName, LastName, Phone, Branch_Id__c, AccountId
			FROM Contact
			WHERE User_Id__c = :userTest.Id
		];

		Assert.areEqual(userTest.FirstName, contact.FirstName);
		Assert.areEqual(userTest.LastName, contact.LastName);
	}
}