/**
 * CollaborationGroupMember_Service_Test contains tests for the CollaborationGroupMember_Service class.
 */
@IsTest
public with sharing class CollaborationGroupMember_Service_Test {
	private static Id FAKEID_GROUP = (Id) '0F9220000000T7iCAE';
	private static Id FAKEID_MEMBER_1 = (Id) '005K0000005VLk8IAG';
	private static Id FAKEID_MEMBER_2 = (Id) '005K0000005VLk9IAG';
	private static Id FAKEID_MEMBER_3 = (Id) '005K0000005VLj0IAG';

	private static User u1;
	private static User u2;
	private static User u3;

	/**
	 * makeData creates asdf for testing.
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
	static void makeData() {
		u1 = TestFactoryUser.makeUser('One', 'Test', 'BBSI Standard', '910');
		u2 = TestFactoryUser.makeUser('Two', 'Test', 'BBSI Standard', '910');
		u3 = TestFactoryUser.makeUser('Three', 'Test', 'BBSI Standard', '910');
		u3.IsActive = false;
		insert new List<User>{ u1, u2, u3 };

		CollaborationGroup group1;
		CollaborationGroup group2;

		System.runAs(u1) {
			group1 = new CollaborationGroup(Name = 'Test-Group-1', CollaborationType = 'Private');
			group2 = new CollaborationGroup(Name = 'Test-Group-2', CollaborationType = 'Private');
			insert new List<CollaborationGroup>{ group1, group2 };
		}
	}

	static void readData() {
		User u1 = [SELECT Id, Email FROM User WHERE Name = 'One Test' LIMIT 1];
		User u2 = [SELECT Id, Email FROM User WHERE Name = 'Two Test' LIMIT 1];
		User u3 = [SELECT Id, Email FROM User WHERE Name = 'Three Test' LIMIT 1];
	}

	@IsTest
	public static void test_makeCollaborationGroupMember() {
		Test.startTest();

		CollaborationGroupMember member = CollaborationGroupMember_Service.makeCollaborationGroupMember(
			FAKEID_GROUP,
			FAKEID_MEMBER_1
		);

		Test.stopTest();

		Assert.areEqual(FAKEID_GROUP, member.CollaborationGroupId);
		Assert.areEqual(FAKEID_MEMBER_1, member.MemberId);
		Assert.areEqual(
			'Standard',
			member.CollaborationRole,
			'Expected "Standard", received: ' + member.CollaborationRole
		);
	}
	@IsTest
	public static void test_inList() {
		CollaborationGroupMember member1 = CollaborationGroupMember_Service.makeCollaborationGroupMember(
			FAKEID_GROUP,
			FAKEID_MEMBER_1
		);
		CollaborationGroupMember member2 = CollaborationGroupMember_Service.makeCollaborationGroupMember(
			FAKEID_GROUP,
			FAKEID_MEMBER_2
		);
		CollaborationGroupMember member3 = CollaborationGroupMember_Service.makeCollaborationGroupMember(
			FAKEID_GROUP,
			FAKEID_MEMBER_3
		);

		Test.startTest();

		List<CollaborationGroupMember> groupMembers = new List<CollaborationGroupMember>{ member1, member2 };

		Test.stopTest();

		Assert.isTrue(CollaborationGroupMember_Service.inList(groupMembers, FAKEID_MEMBER_1));
		Assert.isTrue(CollaborationGroupMember_Service.inList(groupMembers, FAKEID_MEMBER_2));
		Assert.isFalse(CollaborationGroupMember_Service.inList(groupMembers, FAKEID_MEMBER_3));
	}
}