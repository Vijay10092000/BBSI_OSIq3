/**
 * @description Notification_Service_Test contains tests for the Notification_Service class.
 *
 * Tests use the Custom Notification Type: Referral_Partner_Change_Request.  If this
 * is removed from Salesforce, the test will fail.
 */
@IsTest
@SuppressWarnings('PMD.ApexAssertionsShouldIncludeMessage')
public with sharing class Notification_Service_Test {
	private static final Id FAKE_TYPE_ID = Id.valueOf('0ML500000148cYGEAY');
	private static final Id FAKE_TARGET_ID = Id.valueOf('001500000148cYGEAY');
	private static final String FAKE_PAGE_REF = 'PAGE REF';

	private static final String TEST_TYPE = 'Referral_Partner_Change_Request';

	private static User user1Active;
	private static User user2Active;
	private static User user3Inactive;

	@TestSetup
	static void makeData() {
		Account branch = testFactory.createAccount('Test Branch', '98662', 'BBSI Branch', false);
		branch.External_Id__c = '1000';
		insert branch;

		user1Active = TestFactory.createUser('USER_1_ACTIVE', 'BBSI Standard', '1000', false);
		user2Active = TestFactory.createUser('USER_2_ACTIVE', 'BBSI Standard', '1000', false);
		user3Inactive = TestFactory.createUser('USER_3_INACTIVE', 'BBSI Standard', '1000', false);
		user3Inactive.IsActive = false;

		insert new List<User>{ user1Active, user2Active, user3Inactive };
	}

	static void readData() {
		for (User user : [
			SELECT Id, IsActive, LastName, Name
			FROM User
			WHERE LastName LIKE 'USER_%'
			ORDER BY LastName
		]) {
			if (user.LastName == 'USER_1_ACTIVE') { user1Active = user; }
			else if (user.LastName == 'USER_2_ACTIVE') { user2Active = user; }
			else if (user.LastName == 'USER_3_INACTIVE') { user3Inactive = user; }
		}

		System.assertNotEquals(null, user1Active);
		System.assertEquals(true, user1Active.IsActive);
		System.assertNotEquals(null, user2Active);
		System.assertEquals(true, user2Active.IsActive);
		System.assertNotEquals(null, user3Inactive);
		System.assertEquals(false, user3Inactive.IsActive);
	}

	@IsTest
	public static void test_getCustomNotificationId() {
		System.assertEquals(null, Notification_Service.getCustomNotificationId('UNKNOWN_TYPE'), 'Request unknown type should return null');
		System.assertEquals(null, Notification_Service.getCustomNotificationId(null), 'Request null should return null');

		System.assertNotEquals(null, Notification_Service.types, 'types should have been read');
		System.assertNotEquals(null, Notification_Service.getCustomNotificationId('Referral_Partner_Change_Request'));
	}

	@IsTest
	public static void test_getCustomNotificationItem_Constructor() {
		readData();

		Notification_Service.CustomNotificationItem item = new Notification_Service.CustomNotificationItem(
			FAKE_TYPE_ID,
			new List<Id>{ user1Active.Id, user2Active.Id, user3Inactive.Id },
			'TITLE',
			'BODY',
			FAKE_TARGET_ID,
			FAKE_PAGE_REF
		);

		System.assertEquals(FAKE_TYPE_ID, item.typeId);
		System.assertEquals(3, item.recipientIds.size());
		System.assert(item.recipientIds.contains(user1Active.Id));
		System.assert(item.recipientIds.contains(user2Active.Id));
		System.assert(item.recipientIds.contains(user3Inactive.Id));
		System.assertEquals('TITLE', item.title);
		System.assertEquals('BODY', item.body);
		System.assertEquals(FAKE_TARGET_ID, item.targetId);
		System.assertEquals(FAKE_PAGE_REF, item.pageReference);
	}

	@IsTest
	public static void test_getCustomNotificationItem_removeInactive() {
		readData();

		Notification_Service.CustomNotificationItem item = new Notification_Service.CustomNotificationItem(
			FAKE_TYPE_ID,
			new List<Id>{ user1Active.Id, user2Active.Id, user3Inactive.Id },
			'TITLE',
			'BODY',
			FAKE_TARGET_ID,
			FAKE_PAGE_REF
		);

		Map<Id, User> users = new Map<Id, User>{
			user1Active.Id => user1Active,
			user2Active.Id => user2Active,
			user3Inactive.Id => user3Inactive
		};

		DateTime startTime = DateTime.now();

		item.removeInactive(users);

		System.assert(item.recipientIds.contains(user1Active.Id));
		System.assert(item.recipientIds.contains(user2Active.Id));
		System.assert(!item.recipientIds.contains(user3Inactive.Id));

		List<Log__c> logs = Log_Test.recentLogs(startTime);
		System.assertEquals(1, logs.size());
		Log__c log = logs.get(0);
		System.assertEquals('Notification Service', log.Scope__c);
		System.assert(log.Description__c.contains(user3Inactive.Id));
	}

	@IsTest
	public static void test_getCustomNotificationItem_send() {
		readData();

		Notification_Service.CustomNotificationItem item = new Notification_Service.CustomNotificationItem(
			FAKE_TYPE_ID,
			new List<Id>{ user1Active.Id, user2Active.Id },
			'TITLE',
			'BODY',
			FAKE_TARGET_ID,
			FAKE_PAGE_REF
		);

		DateTime startTime;
		List<Log__c> logs;

		// TEST: GOOD
		startTime = DateTime.now();
		item.send();
		logs = Log_Test.recentLogs(startTime);
		System.assertEquals(0, logs.size());

		// TEST: BAD
		startTime = DateTime.now();
		Notification_Service.testException = true;
		item.send();

		logs = Log_Test.recentLogs(startTime);
		System.assertEquals(1, logs.size());
		Log__c log = logs.get(0);
		System.assertEquals('Failed to send Notification', log.Subject__c);
		System.assertEquals('Notification Service', log.Scope__c);
	}

	@IsTest
	public static void test_addItem() {
		readData();

		Notification_Service service = new Notification_Service();

		List<Id> idUsers = new List<Id>{ user1Active.Id, user2Active.Id };

		try {
			service.addItem(FAKE_TYPE_ID, idUsers, 'TITLE', 'BODY', FAKE_TARGET_ID, null);
			service.addItem(FAKE_TYPE_ID, idUsers, 'TITLE', 'BODY', null, FAKE_PAGE_REF);

			System.assert(true, 'Should not throw an Exception.');
			System.assertEquals(2, service.items.size());
		} catch (Exception e) {
			System.assert(false, 'Should not throw an Exception.');
		}

		try {
			service.addItem(null, null, null, null, null, null);
			System.assert(false, 'Should throw an Exception.');
		} catch (Exception e) {
			System.assert(true, 'Should throw an Exception.');
		}
	}

	@IsTest
	public static void test_getUsers() {
		readData();

		Notification_Service service = new Notification_Service();

		List<Id> idUsers = new List<Id>{ user1Active.Id, user2Active.Id, user3Inactive.Id };

		service.addItem(FAKE_TYPE_ID, idUsers, 'TITLE', 'BODY', FAKE_TARGET_ID, null);

		Map<Id, User> mapUsers = service.getUsers();

		System.assertEquals(3, mapUsers.keySet().size());
		System.assertEquals(true, mapUsers.get(user1Active.Id).IsActive);
		System.assertEquals(true, mapUsers.get(user2Active.Id).IsActive);
		System.assertEquals(false, mapUsers.get(user3Inactive.Id).IsActive);
	}

	@IsTest
	public static void test_getUsers_Group() {
		readData();

		Notification_Service service = new Notification_Service();

		Group group1 = new Group( 
			Name = 'UNITTEST_GROUP',
			DeveloperName = 'UNITTEST_GROUP',
			Type = 'Regular', 
			Email = null,  DoesSendEmailToMembers = false
		);
		insert group1;

		GroupMember member1 = new GroupMember( GroupId = group1.Id, UserOrGroupId = user1Active.Id );
		GroupMember member2 = new GroupMember( GroupId = group1.Id, UserOrGroupId = user2Active.Id );
		insert new List<GroupMember>{ member1, member2 };

		service.addItem(FAKE_TYPE_ID, new List<Id>{ group1.Id }, 'TITLE', 'BODY', FAKE_TARGET_ID, null);

		Test.startTest();
		
		Map<Id, User> mapUsers = service.getUsers();

		Test.stopTest();

		System.assertEquals(2, mapUsers.keySet().size());
		System.assertEquals(true, mapUsers.get(user1Active.Id).IsActive);
		System.assertEquals(true, mapUsers.get(user2Active.Id).IsActive);
	}

	@IsTest
	public static void test_addNotify() {
		readData();

		Notification_Service service = new Notification_Service();

		List<Id> idUsers = new List<Id>{ user1Active.Id, user2Active.Id, user3Inactive.Id };

		service.addNotify(TEST_TYPE, idUsers, 'TITLE', 'BODY', FAKE_TARGET_ID);
		service.addNotify(TEST_TYPE, idUsers, 'TITLE', 'BODY', FAKE_PAGE_REF);

		System.assertEquals(2, service.items.size());
	}

	@IsTest
	public static void test_notify() {
		readData();

		List<Id> idUsers1 = new List<Id>{ user1Active.Id, user2Active.Id, user3Inactive.Id };
		List<Id> idUsers2 = new List<Id>{ user1Active.Id, user3Inactive.Id };

		DateTime startTime = DateTime.now();

		Id idType = Notification_Service.getCustomNotificationId(TEST_TYPE);
		Notification_Service.notify(idType, idUsers1, 'TITLE', 'BODY', FAKE_TARGET_ID);
		Notification_Service.notify(idType, idUsers2, 'TITLE', 'BODY', FAKE_PAGE_REF);

		List<Log__c> logs = Log_Test.recentLogs(startTime);

		for (Log__c log : logs) {
			System.debug(LoggingLevel.INFO, 'LOG: ' + log);
		}

		System.assertEquals(2, logs.size());
	}

	@IsTest
	@SuppressWarnings('PMD.LocalVariableNamingConventions')
	public static void test_fixUserIds() {
		readData();

		User user4 = TestFactoryUser.makeUser('UNITTEST', 'ACTIVE_4', 'BBSI Standard', '1000');
		User user5 = TestFactoryUser.makeUser('UNITTEST', 'ACTIVE_5', 'BBSI Standard', '1000');
		User user6 = TestFactoryUser.makeUser('UNITTEST', 'ACTIVE_6', 'BBSI Standard', '1000');
		User user7 = TestFactoryUser.makeUser('UNITTEST', 'ACTIVE_7', 'BBSI Standard', '1000');
		insert new List<User>{ user4, user5, user6, user7 };

		Group group1 = new Group( 
			Name = 'UNITTEST_GROUP_ONE',
			DeveloperName = 'UNITTEST_GROUP_ONE',
			Type = 'Regular', 
			Email = null,  DoesSendEmailToMembers = false
		);
		Group group2 = new Group( 
			Name = 'UNITTEST_GROUP_TWO',
			DeveloperName = 'UNITTEST_GROUP_TWO',
			Type = 'Regular', 
			Email = null,  DoesSendEmailToMembers = false
		);
		Group group3 = new Group( 
			Name = 'UNITTEST_GROUP_THREE',
			DeveloperName = 'UNITTEST_GROUP_THREE',
			Type = 'Regular', 
			Email = null,  DoesSendEmailToMembers = false
		);
		insert new List<Group>{ group1, group2, group3 };

		GroupMember member1_1 = new GroupMember( GroupId = group1.Id, UserOrGroupId = user1Active.Id );
		GroupMember member1_2 = new GroupMember( GroupId = group1.Id, UserOrGroupId = user2Active.Id );
		GroupMember member2_1 = new GroupMember( GroupId = group1.Id, UserOrGroupId = user4.Id );
		GroupMember member2_2 = new GroupMember( GroupId = group1.Id, UserOrGroupId = user5.Id );
		insert new List<GroupMember>{ member1_1, member1_2, member2_1, member2_2 };

		Test.startTest();
		
		List<Id> userIds = new List<Id>{ user6.Id, group1.Id, group2.Id, user7.Id, group3.Id };
		List<Id> newUserIds = (new Notification_Service()).fixUserIds(userIds);
		
		Test.stopTest();

		Assert.areEqual(3, Notification_Service.groupUsers.size());
		Assert.isTrue(Notification_Service.groupUsers.containsKey(group1.Id));
		Assert.isTrue(Notification_Service.groupUsers.containsKey(group2.Id));
		Assert.isTrue(Notification_Service.groupUsers.containsKey(group3.Id));
		
		Assert.isNotNull(newUserIds);
		Assert.areEqual(6, newUserIds.size());
		Assert.isTrue(newUserIds.contains(user1Active.Id));
		Assert.isTrue(newUserIds.contains(user2Active.Id));
		Assert.isTrue(newUserIds.contains(user4.Id));
		Assert.isTrue(newUserIds.contains(user5.Id));
		Assert.isTrue(newUserIds.contains(user6.Id));
		Assert.isTrue(newUserIds.contains(user7.Id));
	}
}