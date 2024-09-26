/**
 * CollaborationGroup_Service_Test contains tests for the CollaborationGroup_Service class.
 */
@IsTest
public class CollaborationGroup_Service_Test {
	private static final String NAME_GROUP_ONE = 'TEST_Group_One';
	private static final String NAME_GROUP_TWO = 'TEST_Group_Two';

	private static User uAdmin;
	private static User user1;
	private static User user2;
	private static User user3;
	private static CollaborationGroup group1;
	private static CollaborationGroup group2;

	/**
	 * setupTests creates asdf for testing.
	 *     Group1 has two active members
	 *     Group2 has one active member
	 * NOTES:
	 *     Creator of a group is automatically added as member and is owner.
	 *     A group must have an owner member.
	 *     Cannot add inactive user as member of a CollaborationGroup.
	 *     Allows deactivation of members.
	 *     Memberless groups are created by deactivating all users in the group.
	 *     A group may be owned by an inactive user.
	 */
	@TestSetup
	static void makedata() {
		Account branch = TestFactoryAccount.createBranch('TEST BRANCH');
		uAdmin = TestFactoryUser.makeUser('SYSTEM', 'ADMIN', 'System Administrator', branch.External_Id__c);
		user1 = TestFactoryUser.makeUser('One', 'Test', 'BBSI Standard', branch.External_Id__c);
		user2 = TestFactoryUser.makeUser('Two', 'Test', 'BBSI Standard', branch.External_Id__c);
		user3 = TestFactoryUser.makeUser('Three', 'Test', 'BBSI Standard', branch.External_Id__c);
		user3.IsActive = false;
		insert new List<User>{ uAdmin, user1, user2, user3 };

		CollaborationGroup group1;
		CollaborationGroup group2;

		System.runAs(user1) {
			// NOTE: These groups will be owned by u1 and u1 becomes a member
			group1 = new CollaborationGroup(Name = NAME_GROUP_ONE, CollaborationType = 'Private');
			group2 = new CollaborationGroup(Name = NAME_GROUP_TWO, CollaborationType = 'Private');
			insert new List<CollaborationGroup>{ group1, group2 };
		}

		CollaborationGroupMember member2 = makeCollaborationGroupMember(group1.Id, user2.Id);
		insert new List<CollaborationGroupMember>{ member2 };
	}

	private static void readData() {
		uAdmin = [SELECT Id, Email FROM User WHERE Name = 'SYSTEM ADMIN' LIMIT 1];
		user1 = [SELECT Id, Email FROM User WHERE Name = 'One Test' LIMIT 1];
		user2 = [SELECT Id, Email FROM User WHERE Name = 'Two Test' LIMIT 1];
		user3 = [SELECT Id, Email FROM User WHERE Name = 'Three Test' LIMIT 1];
		
		group1 = [SELECT Id, Name, OwnerId FROM CollaborationGroup WHERE Name = :NAME_GROUP_ONE LIMIT 1];
		group2 = [SELECT Id, Name, OwnerId FROM CollaborationGroup WHERE Name = :NAME_GROUP_TWO LIMIT 1];
	}

	private static CollaborationGroupMember makeCollaborationGroupMember(Id groupId, Id userId) {
		return new CollaborationGroupMember(
			CollaborationGroupId = groupId,
			MemberId = userId,
			CollaborationRole = 'Standard',
			NotificationFrequency = 'N'
		);
	}

	@IsTest
	public static void test_getGroups() {
		readData();

		Map<Id, CollaborationGroup> mapGroups = CollaborationGroup_Service.getGroups(
			new Set<Id>{ group1.Id, group2.Id }
		);
		Assert.areEqual(2, mapGroups.size());

		Assert.areEqual(true, mapGroups.keySet().contains(group1.Id));
		Assert.areNotEqual(null, mapGroups.get(group1.Id));
		Assert.areEqual(NAME_GROUP_ONE, mapGroups.get(group1.Id).Name);

		Assert.areEqual(true, mapGroups.keySet().contains(group2.Id));
		Assert.areNotEqual(null, mapGroups.get(group2.Id));
		Assert.areEqual(NAME_GROUP_TWO, mapGroups.get(group2.Id).Name);
	}

	@IsTest
	public static void test_addInactiveMember() {
		readData();

		try {
			insert makeCollaborationGroupMember(group1.Id, user3.Id);
			Assert.fail('Should not allow adding inactive member');
		} catch (Exception e) {
			// Correct action
		}
	}

	/**
	 * test_memberlessGroup shows that an INACTIVE User is not retrieved as
	 * part of Collaboration Group.
	 */
	@IsTest
	public static void test_memberlessGroup() {
		readData();
		Assert.areEqual(user1.Id, group1.OwnerId);

		Map<Id, Set<CollaborationGroupMember>> groupMembers;

		groupMembers = CollaborationGroup_Service.getGroupMembers(new Set<Id>{ group1.Id });
		Assert.areEqual(2, groupMembers.get(group1.Id).size());

		Test.startTest();

		System.runAs(uAdmin) {
			user1.IsActive = false;
			update user1;

			// u1 is inactive, but still owner
			group1 = [SELECT Id, Name, OwnerId FROM CollaborationGroup WHERE Id = :group1.Id];
			Assert.areEqual(user1.Id, group1.OwnerId);

			groupMembers = CollaborationGroup_Service.getGroupMembers(new Set<Id>{ group1.Id });
			Assert.areEqual(1, groupMembers.get(group1.Id).size());

			/*
			for (CollaborationGroupMember member : groupMembers.get(group1.Id)) {
				Assert.areEqual(user2.Id, member.MemberId);
			}

			user2.IsActive = false;
			update user2;

			groupMembers = CollaborationGroup_Service.getGroupMembers(new Set<Id>{ group1.Id });
			Assert.areEqual(0, groupMembers.get(group1.Id).size());

			user1.IsActive = true;
			user2.IsActive = true;
			update new List<User>{ user1, user2 };

			groupMembers = CollaborationGroup_Service.getGroupMembers(new Set<Id>{ group1.Id });
			Assert.areEqual(2, groupMembers.get(group1.Id).size());
		*/
		}

		Test.stopTest();
	}

	@IsTest
	public static void test_makeCollaborationGroup() {
		CollaborationGroup g = CollaborationGroup_Service.makeCollaborationGroup('Name', 'Description');

		Assert.areEqual('Name', g.Name);
		Assert.areEqual(false, g.CanHaveGuests);
		Assert.areEqual('Private', g.CollaborationType);
		Assert.areEqual(true, g.IsBroadcast);
		Assert.areEqual('Description', g.Description);
	}

	@IsTest
	public static void test_getGroupMembers() {
		readData();

		Test.startTest();

		Map<Id, Set<CollaborationGroupMember>> groupMembers = CollaborationGroup_Service.getGroupMembers(
			new Set<Id>{ group1.Id, group2.Id }
		);

		Test.stopTest();

		Assert.areEqual(2, groupMembers.size());

		Assert.areEqual(2, groupMembers.get(group1.Id).size());
		Assert.areEqual(1, groupMembers.get(group2.Id).size());
	}
}