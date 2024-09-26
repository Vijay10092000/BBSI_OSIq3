/**
 * @description Group_Service_Test contains tests for the Group_Service class.
 *
 *
 * Setup will create a heirarchical grouping of queue like:
 *    Queue_1
 *        User A
 *        Group_1_1
 *            User B
 *        Group_1_2
 *            User C
 *            User D
 *            Group_1_2_1
 *                User E
 *    Queue_2
 *        User B
 *        Group_2_1
 *            User A
 *            User E
 *    Queue_3
 *        User F
 */
@IsTest
public without sharing class Group_Service_Test {
	private static User makeUser(String firstName, String lastName, String alias, Profile profile) {
		return new User(FirstName =firstName,
						LastName = lastName,
						Alias = alias,
						Email = firstName + '.' + lastName + '@fakeemail.zzz',
						Username = firstName + '.' + lastName + '@fakeemail.zzz',
						ProfileId = profile.Id,
						Branch_ID__c = '910',
						TimeZoneSidKey = 'GMT',
						LanguageLocaleKey = 'en_US',
						EmailEncodingKey = 'UTF-8',
						LocaleSidKey = 'en_US' );
	}

	private static Group makeGroup(String nameGroup, String nameType, String email, Boolean emailMembers) {
		return new Group( Name = nameGroup,
						DeveloperName = nameGroup,
						Type = nameType, 
						Email = email, 
						DoesSendEmailToMembers = emailMembers );
	}

	private static QueueSobject makeQueueSobject(Id queueId, String objectType) {
		return new QueueSobject( QueueId = queueId, 
								SobjectType = objectType );
	}

	private static GroupMember makeGroupMember(Id groupId, String memberId) {
		return new GroupMember( GroupId = groupId, 
								UserOrGroupId = memberId );
	}

	private static Map<String, Group> retrieveTestGroups() {
		List<Group> queues = [SELECT Id, Name FROM Group WHERE Name LIKE 'Queue_%' OR Name LIKE 'Group_%'];

		Map<String, Group> mapQueues = new Map<String, Group>();
		for (Group q : queues ) {
			mapQueues.put(q.Name, q);
		}

		return mapQueues;
	}

	@TestSetup
	static void setUp() {        
		Group queue_1     = makeGroup( 'Queue_1',     'Queue', 'queue_1@fakeemail.zzz', true);
		insert queue_1;
		insert makeQueueSobject(queue_1.Id, 'Case');
		Group queue_2     = makeGroup( 'Queue_2',     'Queue', null, true);
		insert queue_2;
		insert makeQueueSobject(queue_2.Id, 'Case');
		Group queue_3     = makeGroup( 'Queue_3',     'Queue', 'queue_3@fakeemail.zzz', true);
		insert queue_3;
		insert makeQueueSobject(queue_3.Id, 'Case');
		
		Group group_1_1   = makeGroup( 'Group_1_1',   'Regular', null, false);
		Group group_1_2   = makeGroup( 'Group_1_2',   'Regular', null, false);
		Group group_1_2_1 = makeGroup( 'Group_1_2_1', 'Regular', null, true);
		Group group_2_1   = makeGroup( 'Group_2_1',   'Regular', null, true);
		insert new List<Group>{ group_1_1, group_1_2, group_1_2_1, group_2_1 };

		Profile profile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];

		User userA = makeUser('User', 'A', 'usera', profile);
		User userB = makeUser('User', 'B', 'userb', profile);
		User userC = makeUser('User', 'C', 'userc', profile);
		User userD = makeUser('User', 'D', 'userd', profile);
		User userE = makeUser('User', 'E', 'usere', profile);
		User userF = makeUser('User', 'F', 'userf', profile);
		insert new List<User> { userA, userB, userC, userD, userE, userF };

		List<GroupMember> listGroupMembers = new List<GroupMember>();
		listGroupMembers.add( makeGroupMember( queue_1.Id, userA.Id ) );
		listGroupMembers.add( makeGroupMember( queue_1.Id, group_1_1.Id ) );
		listGroupMembers.add( makeGroupMember( group_1_1.Id, userB.Id ) );
		listGroupMembers.add( makeGroupMember( queue_1.Id, group_1_2.Id ) );
		listGroupMembers.add( makeGroupMember( group_1_2.Id, userC.Id ) );
		listGroupMembers.add( makeGroupMember( group_1_2.Id, userD.Id ) );
		listGroupMembers.add( makeGroupMember( group_1_2.Id, group_1_2_1.Id ) );
		listGroupMembers.add( makeGroupMember( group_1_2_1.Id, userE.Id ) );
		listGroupMembers.add( makeGroupMember( queue_2.Id, userB.Id ) );
		listGroupMembers.add( makeGroupMember( queue_2.Id, group_2_1.Id ) );
		listGroupMembers.add( makeGroupMember( group_2_1.Id, userA.Id ) );
		listGroupMembers.add( makeGroupMember( group_2_1.Id, userE.Id ) );
		listGroupMembers.add( makeGroupMember( queue_3.Id, userF.Id ) );

		insert listGroupMembers;
	}

	@IsTest 
	static void getGroupEmails() {
		Map<String, Group> mapGroups = retrieveTestGroups();
		Set<Id> groupIds = new Set<Id> {
			mapGroups.get('Queue_1').Id,
			mapGroups.get('Group_1_1').Id,
			mapGroups.get('Group_1_2').Id,
			mapGroups.get('Group_1_2_1').Id,
			mapGroups.get('Queue_2').Id,
			mapGroups.get('Group_2_1').Id,
			mapGroups.get('Queue_3').Id
		};
		
		Test.startTest();
		
		Map<Id, String> groupEmails = Group_Service.getGroupEmails(groupIds);
		
		Test.stopTest();
		
		System.assertEquals('queue_1@fakeemail.zzz', groupEmails.get(mapGroups.get('Queue_1').Id));
		System.assertEquals(null, groupEmails.get(mapGroups.get('Group_1_1').Id));
		System.assertEquals(null, groupEmails.get(mapGroups.get('Group_1_1').Id));
		System.assertEquals(null, groupEmails.get(mapGroups.get('Group_1_2_1').Id));
		System.assertEquals(null, groupEmails.get(mapGroups.get('Queue_2').Id));
		System.assertEquals(null, groupEmails.get(mapGroups.get('Group_2_1').Id));
		System.assertEquals('queue_3@fakeemail.zzz', groupEmails.get(mapGroups.get('Queue_3').Id));
		
	}
	
	@IsTest 
	static void getUsersInGroups() {
		Map<String, Group> mapGroups = retrieveTestGroups();
		Set<Id> members;
	
		Test.startTest();
		
		members = Group_Service.getUserIdsInGroups(new Set<Id>{ mapGroups.get('Queue_1').Id }, false);
		System.assertEquals(1, members.size());
		members = Group_Service.getUserIdsInGroups(new Set<Id>{ mapGroups.get('Group_1_2').Id }, false);
		System.assertEquals(2, members.size());
		members = Group_Service.getUserIdsInGroups(new Set<Id>{ mapGroups.get('Queue_2').Id }, false);
		System.assertEquals(1, members.size());
		
		members = Group_Service.getUserIdsInGroups(new Set<Id>{ mapGroups.get('Queue_1').Id }, true);
		System.assertEquals(5, members.size());
		members = Group_Service.getUserIdsInGroups(new Set<Id>{ mapGroups.get('Group_1_1').Id }, true);
		System.assertEquals(1, members.size());
		members = Group_Service.getUserIdsInGroups(new Set<Id>{ mapGroups.get('Group_1_2').Id }, true);
		System.assertEquals(3, members.size());
		members = Group_Service.getUserIdsInGroups(new Set<Id>{ mapGroups.get('Group_1_2_1').Id }, true);
		System.assertEquals(1, members.size());
		members = Group_Service.getUserIdsInGroups(new Set<Id>{ mapGroups.get('Queue_2').Id }, true);
		System.assertEquals(3, members.size());
		members = Group_Service.getUserIdsInGroups(new Set<Id>{ mapGroups.get('Group_2_1').Id }, true);
		System.assertEquals(2, members.size());
		members = Group_Service.getUserIdsInGroups(new Set<Id>{ mapGroups.get('Queue_3').Id }, false);
		System.assertEquals(1, members.size());
		
		members = Group_Service.getUserIdsInGroups(new Set<Id>{ mapGroups.get('Queue_1').Id, mapGroups.get('Queue_2').Id, mapGroups.get('Queue_3').Id }, false);
		System.assertEquals(3, members.size());
		
		members = Group_Service.getUserIdsInGroups(new Set<Id>{ mapGroups.get('Queue_1').Id, mapGroups.get('Queue_2').Id, mapGroups.get('Queue_3').Id }, true);
		System.assertEquals(6, members.size());
		
		members = Group_Service.getUserIdsInGroups(new Set<Id>{ mapGroups.get('Group_1_2_1').Id, mapGroups.get('Group_2_1').Id }, true);
		System.assertEquals(2, members.size());
		
		Test.stopTest();
	}

/**** TODO: FUTURE WORK
	@IsTest 
	static void getGroupsUserIsAMember() {
		Id idUserA = [SELECT Id FROM User WHERE Alias = 'usera'].Id;
		Id idUserB = [SELECT Id FROM User WHERE Alias = 'userb'].Id;
		Id idUserC = [SELECT Id FROM User WHERE Alias = 'userc'].Id;
		Id idUserD = [SELECT Id FROM User WHERE Alias = 'userd'].Id;
		Id idUserE = [SELECT Id FROM User WHERE Alias = 'usere'].Id;
		Id idUserF = [SELECT Id FROM User WHERE Alias = 'userf'].Id;
		
		Set<Id> userIds = new Set<Id>{ idUserA, idUserB, idUserC, idUserD, idUserE, idUserF };
		
		Test.startTest();
		
		Map<Id, Set<Group>> mapUserGroups = Group_Service.getGroupsUserIsAMember(userIds);
		
		Test.stopTest();
		
		System.assertEquals(2, mapUserGroups.get(idUserA).size());
		System.assertEquals(2, mapUserGroups.get(idUserB).size());
		System.assertEquals(1, mapUserGroups.get(idUserC).size());
		System.assertEquals(1, mapUserGroups.get(idUserD).size());
		System.assertEquals(2, mapUserGroups.get(idUserE).size());
		System.assertEquals(1, mapUserGroups.get(idUserF).size());
	}

	@IsTest 
	static void getGroupMembers() {        
		Group queue_1 = [SELECT Id FROM Group WHERE Name = 'Queue_1' LIMIT 1];
		Group group_1_2 = [SELECT Id FROM Group WHERE Name = 'Group_1_2' LIMIT 1];
		Group group_1_2_1 = [SELECT Id FROM Group WHERE Name = 'Group_1_2_1' LIMIT 1];
		Group queue_2 = [SELECT Id FROM Group WHERE Name = 'Queue_2' LIMIT 1];
		Group group_2_1 = [SELECT Id FROM Group WHERE Name = 'Group_2_1' LIMIT 1];
		Group queue_3 = [SELECT Id FROM Group WHERE Name = 'Queue_3' LIMIT 1];

		Test.startTest();
		
		Set<Id> members;
	
		members = Group_Service.getUserIdsInGroups(new Set<Id>{ queue_1.Id }, false);
		System.assertEquals(1, members.size());
		members = Group_Service.getUserIdsInGroups(new Set<Id>{ queue_1.Id }, true);
		System.assertEquals(5, members.size());
		members = Group_Service.getUserIdsInGroups(new Set<Id>{ group_1_2.Id }, false);
		System.assertEquals(2, members.size());
		members = Group_Service.getUserIdsInGroups(new Set<Id>{ group_1_2.Id }, true);
		System.assertEquals(3, members.size());
		members = Group_Service.getUserIdsInGroups(new Set<Id>{ group_1_2_1.Id }, true);
		System.assertEquals(1, members.size());
		members = Group_Service.getUserIdsInGroups(new Set<Id>{ queue_2.Id }, false);
		System.assertEquals(1, members.size());
		members = Group_Service.getUserIdsInGroups(new Set<Id>{ queue_2.Id }, true);
		System.assertEquals(3, members.size());
		members = Group_Service.getUserIdsInGroups(new Set<Id>{ group_2_1.Id }, true);
		System.assertEquals(2, members.size());
		members = Group_Service.getUserIdsInGroups(new Set<Id>{ queue_3.Id }, false);
		System.assertEquals(1, members.size());
		
		Test.stopTest();
	}

	@IsTest 
	static void getFullGroupEmails() {   
		Group queue_1 = [SELECT Id FROM Group WHERE Name = 'Queue_1' LIMIT 1];
		Group group_1_2 = [SELECT Id FROM Group WHERE Name = 'Group_1_2' LIMIT 1];
		Group group_1_2_1 = [SELECT Id FROM Group WHERE Name = 'Group_1_2_1' LIMIT 1];
		Group queue_2 = [SELECT Id FROM Group WHERE Name = 'Queue_2' LIMIT 1];
		Group group_2_1 = [SELECT Id FROM Group WHERE Name = 'Group_2_1' LIMIT 1];
		Group queue_3 = [SELECT Id FROM Group WHERE Name = 'Queue_3' LIMIT 1];
		
		Test.startTest();

		Map<Id, Set<String>> mapEmails = Group_Service.getFullGroupEmails(new Set<Id>{ queue_1.Id, group_1_2.Id, group_1_2_1.Id, queue_2.Id, group_2_1.Id, queue_3.Id }, true);

		Test.stopTest();

		System.assertEquals(2, mapEmails.get(queue_1.Id).size());
		System.assertEquals(true, mapEmails.get(queue_1.Id).contains('queue_1@fakeemail.zzz'));
		System.assertEquals(true, mapEmails.get(queue_1.Id).contains('user.a@fakeemail.zzz'));
		System.assertEquals(0, mapEmails.get(group_1_2.Id).size());
		System.assertEquals(1, mapEmails.get(group_1_2_1.Id).size());
		System.assertEquals(true, mapEmails.get(group_1_2_1.Id).contains('user.e@fakeemail.zzz'));
		System.assertEquals(3, mapEmails.get(queue_2.Id).size());
		System.assertEquals(true, mapEmails.get(queue_2.Id).contains('user.a@fakeemail.zzz'));
		System.assertEquals(true, mapEmails.get(queue_2.Id).contains('user.b@fakeemail.zzz'));
		System.assertEquals(true, mapEmails.get(queue_2.Id).contains('user.e@fakeemail.zzz'));
		System.assertEquals(2, mapEmails.get(group_2_1.Id).size());
		System.assertEquals(true, mapEmails.get(group_2_1.Id).contains('user.a@fakeemail.zzz'));
		System.assertEquals(true, mapEmails.get(group_2_1.Id).contains('user.e@fakeemail.zzz'));
		System.assertEquals(2, mapEmails.get(queue_3.Id).size());
		System.assertEquals(true, mapEmails.get(queue_3.Id).contains('queue_3@fakeemail.zzz'));
		System.assertEquals(true, mapEmails.get(queue_3.Id).contains('user.f@fakeemail.zzz'));
	}
****/
}