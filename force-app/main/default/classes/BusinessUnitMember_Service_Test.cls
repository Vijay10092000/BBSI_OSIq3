/**
 * BusinessUnitMember_Service_Test
 */
@isTest
public class BusinessUnitMember_Service_Test {

    private static Account a1;
    private static Account a2;
    private static Business_Unit__c bu1;
    private static Business_Unit__c bu2;
    private static User uAdmin;
    private static User u1;
    private static User u2;
    private static User u3;
    private static Contact c1;
    private static Contact c2;
    private static Contact c3;
    private static CollaborationGroup cg1;
    private static CollaborationGroup cg2;
    private static Business_Unit_Contact__c member1;
    private static Business_Unit_Contact__c member2;
    private static Business_Unit_Contact__c member3;
    private static Business_Unit_Contact__c member4;
    private static Business_Unit_Contact__c member5;
    private static List<CollaborationGroupMember> cg1Members;
    private static List<CollaborationGroupMember> cg2Members;

    /**
     * setupTests creates basic objects to test the BusinessUserMember_Service code.
     *
     * Objects Created:
     *    User: User Test_1 (System Administrator)
     *    User: User Test_2 (BBSI Standard)
     *    User: User Test_3 (BBSI Standard)
     *    Account: Test Account One
     *        Business Unit: Business Unit 1
     *        Contact: User Test_1
     *        Contact: User Test_2
     *    Account: Test Account Two
     *        Business Unit: Business Unit 2
     *        Contact: User Test_3
     */
     @testSetup
    private static void setupTests() {
        // User uAdmin = TestFactory.createUser('User Admin', 'User.Admin@bbsi.zzz', 'User.Admin@bbsi.zzz', 'System Administrator', '910', false);
        User uAdmin = TestFactoryUser.makeUser('User', 'Admin', 'System Administrator', '910', 'User.Admin@bbsi.zzz', 'User.Admin@bbsi.zzz');
        // uAdmin.isActive = true;
        // User u1 = TestFactory.createUser('User Test_1', 'User.Test_1@bbsi.zzz', 'User.Test_1@bbsi.zzz', 'BBSI Standard', '910', false);
        User u1 = TestFactoryUser.makeUser('User', 'Test_1', 'BBSI Standard', '910', 'User.Test_1@bbsi.zzz', 'User.Test_1@bbsi.zzz');
        // u1.isActive = true;
        // User u2 = TestFactory.createUser('User Test_2', 'User.Test_2@bbsi.zzz', 'User.Test_2@bbsi.zzz', 'BBSI Standard', '910', false);
        User u2 = TestFactoryUser.makeUser('User', 'Test_2', 'BBSI Standard', '910', 'User.Test_2@bbsi.zzz', 'User.Test_2@bbsi.zzz');
        // u2.isActive = true;
        // User u3 = TestFactory.createUser('User Test_3', 'User.Test_3@bbsi.zzz', 'User.Test_3@bbsi.zzz', 'BBSI Standard', '910', false);
        User u3 = TestFactoryUser.makeUser('User', 'Test_3', 'BBSI Standard', '910', 'User.Test_3@bbsi.zzz', 'User.Test_3@bbsi.zzz');
        // u3.isActive = true;
        insert new List<User>{ uAdmin, u1, u2, u3 };

        RecordType rtBBSIBranch = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Account' AND Name = 'BBSI Branch' LIMIT 1];
        RecordType rtBBSIEmployee = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'BBSI Employee' LIMIT 1];

        // Account a1 = TestFactory.createAccount('Test Account One', '99999', 'BBSI Branch', false);
        Account a1 = TestFactoryAccount.makeBranch('Test Account One');
        // a1.RecordTypeId = rtBBSIBranch.Id;
        // Account a2 = TestFactory.createAccount('Test Account Two', '99999', 'BBSI Branch', false);
        Account a2 = TestFactoryAccount.makeBranch('Test Account Two');
        // a2.RecordTypeId = rtBBSIBranch.Id;
        insert new List<Account>{ a1, a2 };

        System.runAs(uAdmin) {
            Business_Unit__c bu1 = TestFactoryBusinessUnit.makeBusinessUnit('Test Business Unit 1', a1.Id);
            Business_Unit__c bu2 = TestFactoryBusinessUnit.makeBusinessUnit('Test Business Unit 2', a2.Id);
            insert new List<Business_Unit__c>{ bu1, bu2 };
        }

        // Contact c1 = TestFactory.createContact(a1, 'User Test_1', 'Client Contact', false);
        Contact c1 = TestFactoryContact.makeEmployee(u1.Id, 'User', 'Test_1', a1.Id);
        // c1.Email = 'User.Test_1@bbsi.zzz';
        c1.User_Id__c = u1.Id;
        // c1.RecordTypeId = rtBBSIEmployee.Id;
        // Contact c2 = TestFactory.createContact(a1, 'User Test_2', 'Client Contact', false);
        Contact c2 = TestFactoryContact.makeEmployee(u2.Id, 'User', 'Test_2', a1.Id);
        // c2.Email = 'User.Test_2@bbsi.zzz';
        c2.User_Id__c = u2.Id;
        // c2.RecordTypeId = rtBBSIEmployee.Id;
        // Contact c3 = TestFactory.createContact(a2, 'User Test_3', 'Client Contact', false);
        Contact c3 = TestFactoryContact.makeEmployee(u3.Id, 'User', 'Test_3', a2.Id);
        // c3.Email = 'User.Test_3@bbsi.zzz';
        c3.User_Id__c = u3.Id;
        // c3.RecordTypeId = rtBBSIEmployee.Id;
        insert new List<Contact>{ c1, c2, c3 };
    }

    /**
     * getTestData retrieves the test objects from the data and places
     * them into the class variables.
     */
    private static void getTestData() {
        a1 = [SELECT Id, Name FROM Account WHERE Name = 'Test Account One' LIMIT 1];
        a2 = [SELECT Id, Name FROM Account WHERE Name = 'Test Account Two' LIMIT 1];
        bu1 = [SELECT Id, Name, Chatter_Group_Id__c FROM Business_Unit__c WHERE Name = 'Test Business Unit 1' LIMIT 1];
        bu2 = [SELECT Id, Name, Chatter_Group_Id__c FROM Business_Unit__c WHERE Name = 'Test Business Unit 2' LIMIT 1];
        uAdmin = [SELECT Id, Name FROM User WHERE Email = 'User.Admin@bbsi.zzz' LIMIT 1];
        u1 = [SELECT Id, Name FROM User WHERE Email = 'User.Test_1@bbsi.zzz' LIMIT 1];
        u2 = [SELECT Id, Name FROM User WHERE Email = 'User.Test_2@bbsi.zzz' LIMIT 1];
        u3 = [SELECT Id, Name FROM User WHERE Email = 'User.Test_3@bbsi.zzz' LIMIT 1];
        c1 = [SELECT Id, Name, User_Id__c FROM Contact WHERE Email = 'User.Test_1@bbsi.zzz' LIMIT 1];
        c2 = [SELECT Id, Name, User_Id__c FROM Contact WHERE Email = 'User.Test_2@bbsi.zzz' LIMIT 1];
        c3 = [SELECT Id, Name, User_Id__c FROM Contact WHERE Email = 'User.Test_3@bbsi.zzz' LIMIT 1];

        cg1 = [SELECT Id, Name, CollaborationType, OwnerId FROM CollaborationGroup WHERE Name = 'Test Business Unit 1' LIMIT 1];
        cg2 = [SELECT Id, Name, CollaborationType, OwnerId FROM CollaborationGroup WHERE Name = 'Test Business Unit 2' LIMIT 1];
    }

    private static void addTestMembers() {
        member1 = TestFactoryBusinessUnitContact.makeBusinessUnitContact(bu1, true, 'HR Consultant', c1);
        member2 = TestFactoryBusinessUnitContact.makeBusinessUnitContact(bu1, true, 'HR Consultant', c2);
        member3 = TestFactoryBusinessUnitContact.makeBusinessUnitContact(bu1, false, 'HR Consultant', c3);
        member4 = TestFactoryBusinessUnitContact.makeBusinessUnitContact(bu2, false, 'HR Consultant', c3);
        member5 = TestFactoryBusinessUnitContact.makeBusinessUnitContact(bu2, true, 'Risk Consultant', c3);
        insert new List<Business_Unit_Contact__c>{ member3, member4 };
        insert new List<Business_Unit_Contact__c>{ member1, member2, member5 };

        member1 = [SELECT Id, Name, Active__c, Role__c, Business_Unit__c, BU_Member__c, Chatter_Group_Member_Id__c, BU_User_Id__c
                   FROM Business_Unit_Contact__c
                   WHERE Role__c = 'HR Consultant' AND BU_Member__c = :c1.Id AND Business_Unit__c = :bu1.Id
                   LIMIT 1];
        member2 = [SELECT Id, Name, Active__c, Role__c, Business_Unit__c, BU_Member__c, Chatter_Group_Member_Id__c, BU_User_Id__c
                   FROM Business_Unit_Contact__c
                   WHERE Role__c = 'HR Consultant' AND BU_Member__c = :c2.Id AND Business_Unit__c = :bu1.Id
                   LIMIT 1];
        member3 = [SELECT Id, Name, Active__c, Role__c, Business_Unit__c, BU_Member__c, Chatter_Group_Member_Id__c, BU_User_Id__c
                   FROM Business_Unit_Contact__c
                   WHERE Role__c = 'HR Consultant' AND BU_Member__c = :c3.Id AND Business_Unit__c = :bu1.Id
                   LIMIT 1];
        member4 = [SELECT Id, Name, Active__c, Role__c, Business_Unit__c, BU_Member__c, Chatter_Group_Member_Id__c, BU_User_Id__c
                   FROM Business_Unit_Contact__c
                   WHERE Role__c = 'HR Consultant' AND BU_Member__c = :c3.Id AND Business_Unit__c = :bu2.Id
                   LIMIT 1];
        member5 = [SELECT Id, Name, Active__c, Role__c, Business_Unit__c, BU_Member__c, Chatter_Group_Member_Id__c, BU_User_Id__c
                   FROM Business_Unit_Contact__c
                   WHERE Role__c = 'Risk Consultant' AND BU_Member__c = :c3.Id AND Business_Unit__c = :bu2.Id
                   LIMIT 1];

        cg1Members = [SELECT Id, CollaborationGroupId, CollaborationRole, MemberId, NotificationFrequency
                     FROM CollaborationGroupMember
                     WHERE CollaborationGroupId = :cg1.Id];
        cg2Members = [SELECT Id, CollaborationGroupId, CollaborationRole, MemberId, NotificationFrequency
                      FROM CollaborationGroupMember
                      WHERE CollaborationGroupId = :cg2.Id];

        cg1 = [SELECT Id, Name, CollaborationType, OwnerId FROM CollaborationGroup WHERE Name = 'Test Business Unit 1' LIMIT 1];
        cg2 = [SELECT Id, Name, CollaborationType, OwnerId FROM CollaborationGroup WHERE Name = 'Test Business Unit 2' LIMIT 1];
    }

    /**
     * test_getContactChatterGroups confirms getContactChatterGroups worked.
     */
/**
@isTest
    public static void test_getContactChatterGroups() {
        getTestData();

        Assert.areNotEqual(null, bu1);
        Assert.areNotEqual(null, bu1.Chatter_Group_Id__c);
        Assert.areNotEqual(null, bu2);
        Assert.areNotEqual(null, bu2.Chatter_Group_Id__c);

        // Add members to the Chatter groups
        CollaborationGroupMember gmember1 = new CollaborationGroupMember( CollaborationGroupId = bu1.Chatter_Group_Id__c, MemberId = u1.Id, CollaborationRole = 'Standard' );
        CollaborationGroupMember gmember2 = new CollaborationGroupMember( CollaborationGroupId = bu1.Chatter_Group_Id__c, MemberId = u2.Id, CollaborationRole = 'Standard' );
        CollaborationGroupMember gmember3 = new CollaborationGroupMember( CollaborationGroupId = bu1.Chatter_Group_Id__c, MemberId = u3.Id, CollaborationRole = 'Standard' );
        CollaborationGroupMember gmember4 = new CollaborationGroupMember( CollaborationGroupId = bu2.Chatter_Group_Id__c, MemberId = u1.Id, CollaborationRole = 'Standard' );
        CollaborationGroupMember gmember5 = new CollaborationGroupMember( CollaborationGroupId = bu2.Chatter_Group_Id__c, MemberId = u2.Id, CollaborationRole = 'Standard' );

        insert new List<CollaborationGroupMember>{ gmember1, gmember2, gmember3, gmember4, gmember5 };

        Test.startTest();

        Set<Id> idUsers = new Set<Id>{ u1.Id, u2.Id, u3.Id };

        Map<Id, Map<Id, CollaborationGroupMember>> mapMembers = (new BusinessUnitMember_Service()).getUserChatterGroups(idUsers);

        Test.stopTest();

        Assert.areEqual(3, mapMembers.size(), 'Expected 3 User Ids in the map.');
        Assert.areEqual(2, mapMembers.get(u1.Id).size(), 'u1 should be in 2 groups');
        Assert.areEqual(2, mapMembers.get(u2.Id).size(), 'u2 should be in 2 groups');
        Assert.areEqual(1, mapMembers.get(u3.Id).size(), 'u3 should be in 1 groups');
    }
**/
    /**
     * test_checkTestData confirms setupTests worked.
     */
    @isTest
    public static void test_checkTestData() {
        getTestData();

        Assert.areEqual(cg1.OwnerId, uAdmin.Id);
        Assert.areEqual(cg2.OwnerId, uAdmin.Id);
    }

    /**
     * test_addTestMembers confirms addTestMembers worked.
     */
    @isTest
    public static void test_addTestMembers() {
        getTestData();

        addTestMembers();

        Assert.areNotEqual(null, a1);
        Assert.areNotEqual(null, a2);
        Assert.areNotEqual(null, bu1);
        Assert.areNotEqual(null, bu1.Chatter_Group_Id__c);
        Assert.areNotEqual(null, bu2);
        Assert.areNotEqual(null, bu2.Chatter_Group_Id__c);
        Assert.areNotEqual(null, c1);
        Assert.areNotEqual(null, c2);
        Assert.areNotEqual(null, c3);
        Assert.areNotEqual(null, cg1);
        Assert.areNotEqual(null, cg2);
        Assert.areEqual(cg1.Id, bu1.Chatter_Group_Id__c);
        Assert.areEqual(cg2.Id, bu2.Chatter_Group_Id__c);
        Assert.areEqual(true, (cg1.OwnerId == member1.BU_User_Id__c) || (cg1.OwnerId == member2.BU_User_Id__c));
        Assert.areEqual(true, (cg2.OwnerId == member5.BU_User_Id__c));

        Assert.areNotEqual(null, member1);
        Assert.areEqual(true, member1.Active__c);
        Assert.areEqual(true, isMemberInList(cg1Members, member1.Chatter_Group_Member_Id__c));
        Assert.areNotEqual(null, member2);
        Assert.areEqual(true, member2.Active__c);
        Assert.areEqual(true, isMemberInList(cg1Members, member2.Chatter_Group_Member_Id__c));
        Assert.areNotEqual(null, member3);
        Assert.areEqual(false, member3.Active__c);
        Assert.areEqual(null, member3.Chatter_Group_Member_Id__c);
        Assert.areNotEqual(null, member4);
        Assert.areEqual(false, member4.Active__c);
        Assert.areEqual(null, member4.Chatter_Group_Member_Id__c);  // TODO: THIS HAD A VALUE - WHY?
        Assert.areNotEqual(null, member5);
        Assert.areEqual(true, member5.Active__c);
        Assert.areEqual(true, isMemberInList(cg2Members, member5.Chatter_Group_Member_Id__c));
    }

    /**
     * test_insertActiveBusinessGroupMemberNoOwner
     *    GIVEN:  Business Unit '' exists with Chatter Group owned by non-member
     *    EVENT:  Add Business Unit Member
     *    RESULT: New Chatter Group Member and Owner changed
     */
    @isTest
    public static void test_insertActiveBusinessGroupMemberNoOwner() {
        getTestData();

        Test.startTest();

        Business_Unit_Contact__c member1 = TestFactoryBusinessUnitContact.makeBusinessUnitContact(bu1, true, 'HR Consultant', c1);
        insert new List<Business_Unit_Contact__c>{ member1 };

        Test.stopTest();

        List<Id> cMemberIds = new List<Id>{ member1.Id };

        member1 = [SELECT Id, Chatter_Group_Member_Id__c, BU_User_Id__c FROM Business_Unit_Contact__c WHERE Id = :member1.Id LIMIT 1];

        List<CollaborationGroupMember> cg1Members = [SELECT Id, CollaborationGroupId, CollaborationRole, MemberId, NotificationFrequency
                                                     FROM CollaborationGroupMember
                                                     WHERE CollaborationGroupId = :cg1.Id];
        Assert.areEqual(true, cg1Members.size() > 0);
        Assert.areEqual(true, isMemberInList(cg1Members, member1.Chatter_Group_Member_Id__c));

        CollaborationGroup cgroup = [SELECT Id, OwnerId FROM CollaborationGroup WHERE Id = :bu1.Chatter_Group_Id__c LIMIT 1];
        Assert.areEqual(member1.BU_User_Id__c, cgroup.OwnerId);
    }

    /**
     * test_insertActiveBusinessGroupMemberOwner
     *    GIVEN:  Business Unit 'Test Business Unit 1' exists with Chatter Group owned by member
     *    EVENT:  Add Business Unit Member
     *    RESULT: New Chatter Group Member and Owner NOT changed
     */
    @isTest
    public static void test_insertActiveBusinessGroupMemberOwner() {
        getTestData();

        Business_Unit_Contact__c member1 = TestFactoryBusinessUnitContact.makeBusinessUnitContact(bu1, true, 'HR Consultant', c1);
        insert new List<Business_Unit_Contact__c>{ member1 };

        member1 = [SELECT Id, BU_User_Id__c FROM Business_Unit_Contact__c WHERE Id = :member1.Id LIMIT 1];
        CollaborationGroup cgroup = [SELECT Id, OwnerId FROM CollaborationGroup WHERE Id = :bu1.Chatter_Group_Id__c LIMIT 1];
        Assert.areEqual(member1.BU_User_Id__c, cgroup.OwnerId);

        Test.startTest();

        Business_Unit_Contact__c member2 = TestFactoryBusinessUnitContact.makeBusinessUnitContact(bu1, true, 'HR Consultant', c2);
        insert new List<Business_Unit_Contact__c>{ member2 };

        Test.stopTest();

        member2 = [SELECT Id, BU_User_Id__c FROM Business_Unit_Contact__c WHERE Id = :member2.Id LIMIT 1];
        cgroup = [SELECT Id, OwnerId FROM CollaborationGroup WHERE Id = :bu1.Chatter_Group_Id__c LIMIT 1];
        Assert.areNotEqual(member2.BU_User_Id__c, cgroup.OwnerId);
    }

    /**
     * test_insertInactiveBusinessGroupMember
     *    GIVEN:  Business Unit 'Test Business Unit 1' with Chatter Group owned by non-member
     *    EVENT:  Add Business Unit Member
     *    RESULT: No changes
     */
    @isTest
    public static void test_insertInactiveBusinessGroupMember() {
        getTestData();

        Test.startTest();

        Business_Unit_Contact__c member1 = TestFactoryBusinessUnitContact.makeBusinessUnitContact(bu1, false, 'HR Consultant', c1);
        insert new List<Business_Unit_Contact__c>{ member1 };

        Test.stopTest();

        List<Id> cMemberIds = new List<Id>{ member1.Id };

        member1 = [SELECT Id, Chatter_Group_Member_Id__c FROM Business_Unit_Contact__c WHERE Id = :member1.Id LIMIT 1];

        List<CollaborationGroupMember> cg1Members = [SELECT Id, CollaborationGroupId, CollaborationRole, MemberId, NotificationFrequency
                                                     FROM CollaborationGroupMember
                                                     WHERE CollaborationGroupId = :cg1.Id];
        Assert.areEqual(true, cg1Members.size() > 0);
        Assert.areEqual(false, isMemberInList(cg1Members, member1.Chatter_Group_Member_Id__c));

        CollaborationGroup cgroup = [SELECT Id, OwnerId FROM CollaborationGroup WHERE Id = :bu1.Chatter_Group_Id__c LIMIT 1];
        Assert.areEqual(uAdmin.Id, cgroup.OwnerId);
    }

    /**
     * test_deactivateBusinessGroupMemberNotOwner
     *    GIVEN:  Business Unit 'Test Business Unit 1' exists with members
     *    EVENT:  Deactivate a member
     *    RESULT: Member is removed from the Chatter Group
     */
    @isTest
    public static void test_deactivateBusinessGroupMemberNotOwner() {
        getTestData();

        Test.startTest();

        Business_Unit_Contact__c member1 = TestFactoryBusinessUnitContact.makeBusinessUnitContact(bu1, true, 'HR Consultant', c1);
        insert member1;

        member1 = [SELECT Id, Name, Active__c, Role__c, Business_Unit__c, BU_Member__c, Chatter_Group_Member_Id__c, BU_User_Id__c
                   FROM Business_Unit_Contact__c
                   WHERE Id = :member1.Id
                   LIMIT 1];
        cg1 = [SELECT Id, Name, CollaborationType, OwnerId FROM CollaborationGroup WHERE Name = 'Test Business Unit 1' LIMIT 1];
        Assert.areEqual(cg1.OwnerId, member1.BU_User_Id__c);

        Business_Unit_Contact__c member2 = TestFactoryBusinessUnitContact.makeBusinessUnitContact(bu1, true, 'HR Consultant', c2);
        insert member2;

        member2 = [SELECT Id, Name, Active__c, Role__c, Business_Unit__c, BU_Member__c, Chatter_Group_Member_Id__c, BU_User_Id__c
                   FROM Business_Unit_Contact__c
                   WHERE Id = :member2.Id
                   LIMIT 1];
        cg1 = [SELECT Id, Name, CollaborationType, OwnerId FROM CollaborationGroup WHERE Name = 'Test Business Unit 1' LIMIT 1];
        Assert.areEqual(cg1.OwnerId, member1.BU_User_Id__c);

        Test.stopTest();

        List<CollaborationGroupMember> cg1Members = [SELECT Id, CollaborationGroupId, CollaborationRole, MemberId, NotificationFrequency
                                                     FROM CollaborationGroupMember
                                                     WHERE CollaborationGroupId = :cg1.Id];
        Assert.areEqual(true, isMemberInList(cg1Members, member1.Chatter_Group_Member_Id__c));
        Assert.areEqual(true, isMemberInList(cg1Members, member2.Chatter_Group_Member_Id__c));
        Integer size = cg1Members.size();
        Assert.areEqual(2, cg1Members.size());

        CollaborationGroup cgroup = [SELECT Id, OwnerId FROM CollaborationGroup WHERE Id = :bu1.Chatter_Group_Id__c LIMIT 1];

        Assert.areEqual(member1.BU_User_Id__c, cgroup.OwnerId);

        member2.Active__c = false;
        member2.Inactive_Date__c = Date.today();
        update member2;

        member2 = [SELECT Id, Name, Active__c, Role__c, Business_Unit__c, BU_Member__c, Chatter_Group_Member_Id__c, BU_User_Id__c
                   FROM Business_Unit_Contact__c
                   WHERE Id = :member2.Id
                   LIMIT 1];

        cg1Members = [SELECT Id, CollaborationGroupId, CollaborationRole, MemberId, NotificationFrequency
                      FROM CollaborationGroupMember
                      WHERE CollaborationGroupId = :cg1.Id];
        Assert.areEqual(1, cg1Members.size());
        Assert.areEqual(true, isMemberInList(cg1Members, member1.Chatter_Group_Member_Id__c));
        Assert.areEqual(false, isMemberInList(cg1Members, member2.Chatter_Group_Member_Id__c));

        cgroup = [SELECT Id, OwnerId FROM CollaborationGroup WHERE Id = :bu1.Chatter_Group_Id__c LIMIT 1];
        Assert.areEqual(u1.Id, cgroup.OwnerId, 'u1 is only active member should be owner');
    }

    /**
     * test_deactivateBusinessGroupMemberOwner
     *    GIVEN:  Business Unit 'Test Business Unit 1' exists with members
     *    EVENT:  Deactivate a member
     *    RESULT: Member is removed from the Chatter Group, Owner is changed
     */
    @isTest
    public static void test_deactivateBusinessGroupMemberOwner() {
        getTestData();

        Test.startTest();

        Business_Unit_Contact__c member1 = TestFactoryBusinessUnitContact.makeBusinessUnitContact(bu1, true, 'HR Consultant', c1);
        insert member1;
        member1 = [SELECT Id, Chatter_Group_Member_Id__c, BU_User_Id__c, Active__c, Inactive_Date__c FROM Business_Unit_Contact__c WHERE Id = :member1.Id LIMIT 1];

        cg1 = [SELECT Id, Name, CollaborationType, OwnerId FROM CollaborationGroup WHERE Name = 'Test Business Unit 1' LIMIT 1];
        Assert.areEqual(cg1.OwnerId, member1.BU_User_Id__c);

        Business_Unit_Contact__c member2 = TestFactoryBusinessUnitContact.makeBusinessUnitContact(bu1, true, 'HR Consultant', c2);
        insert member2;
        member2 = [SELECT Id, Chatter_Group_Member_Id__c, BU_User_Id__c, Active__c, Inactive_Date__c FROM Business_Unit_Contact__c WHERE Id = :member2.Id LIMIT 1];

        Test.stopTest();

        List<CollaborationGroupMember> cg1Members = [SELECT Id, CollaborationGroupId, CollaborationRole, MemberId, NotificationFrequency
                                                     FROM CollaborationGroupMember
                                                     WHERE CollaborationGroupId = :cg1.Id];
        Assert.areEqual(true, isMemberInList(cg1Members, member1.Chatter_Group_Member_Id__c));
        Assert.areEqual(true, isMemberInList(cg1Members, member2.Chatter_Group_Member_Id__c));
        Assert.areEqual(2, cg1Members.size());

        CollaborationGroup cgroup = [SELECT Id, OwnerId FROM CollaborationGroup WHERE Id = :bu1.Chatter_Group_Id__c LIMIT 1];
        Assert.areEqual(true, member1.BU_User_Id__c == cgroup.OwnerId);

        member1.Active__c = false;
        member1.Inactive_Date__c = Date.today();
        update member1;

        cg1Members = [SELECT Id, CollaborationGroupId, CollaborationRole, MemberId, NotificationFrequency
                      FROM CollaborationGroupMember
                      WHERE CollaborationGroupId = :cg1.Id];
        Assert.areEqual(1, cg1Members.size());
        Assert.areEqual(false, isMemberInList(cg1Members, member1.Chatter_Group_Member_Id__c));
        Assert.areEqual(true, isMemberInList(cg1Members, member2.Chatter_Group_Member_Id__c));

        cgroup = [SELECT Id, OwnerId FROM CollaborationGroup WHERE Id = :bu1.Chatter_Group_Id__c LIMIT 1];
        Assert.areEqual(u2.Id, cgroup.OwnerId);
    }

    /**
     * test_reactivateBusinessGroupMember
     *    GIVEN:  Business Unit 'Test Business Unit 1' exists with members
     *    EVENT:  Deactivate a member
     *    RESULT: Member is removed from the Chatter Group
     */
    @isTest
    public static void test_reactivateBusinessGroupMember() {
        getTestData();

        Test.startTest();

        Business_Unit_Contact__c member1 = TestFactoryBusinessUnitContact.makeBusinessUnitContact(bu1, true, 'HR Consultant', c1);
        insert member1;
        Business_Unit_Contact__c member2 = TestFactoryBusinessUnitContact.makeBusinessUnitContact(bu1, false, 'HR Consultant', c1);
        insert member2;

        Test.stopTest();

        List<Id> cMemberIds = new List<Id>{ member1.Id };

        member1 = [SELECT Id, Chatter_Group_Member_Id__c, BU_User_Id__c FROM Business_Unit_Contact__c WHERE Id = :member1.Id LIMIT 1];
        member2 = [SELECT Id, Chatter_Group_Member_Id__c, BU_User_Id__c FROM Business_Unit_Contact__c WHERE Id = :member2.Id LIMIT 1];

        List<CollaborationGroupMember> cg1Members = [SELECT Id, CollaborationGroupId, CollaborationRole, MemberId, NotificationFrequency
                                                     FROM CollaborationGroupMember
                                                     WHERE CollaborationGroupId = :cg1.Id];
        Assert.areEqual(1, cg1Members.size());
        Assert.areEqual(true, isMemberInList(cg1Members, member1.Chatter_Group_Member_Id__c));
        Assert.areEqual(false, isMemberInList(cg1Members, member2.Chatter_Group_Member_Id__c));

        CollaborationGroup cgroup = [SELECT Id, OwnerId FROM CollaborationGroup WHERE Id = :bu1.Chatter_Group_Id__c LIMIT 1];
        Assert.areEqual(member1.BU_User_Id__c, cgroup.OwnerId);

        member2.Active__c = true;
        member2.Inactive_Date__c = null;
        member2.Active_Date__c = Date.today();
        update member2;

        cg1Members = [SELECT Id, CollaborationGroupId, CollaborationRole, MemberId, NotificationFrequency
                      FROM CollaborationGroupMember
                      WHERE CollaborationGroupId = :cg1.Id];
        Assert.areEqual(1, cg1Members.size());
        Assert.areEqual(true, isMemberInList(cg1Members, member1.Chatter_Group_Member_Id__c));
        Assert.areEqual(false, isMemberInList(cg1Members, member2.Chatter_Group_Member_Id__c));

        cgroup = [SELECT Id, OwnerId FROM CollaborationGroup WHERE Id = :bu1.Chatter_Group_Id__c LIMIT 1];
        Assert.areEqual(u1.Id, cgroup.OwnerId);
    }

    /**
     * test_deleteBusinessGroupMemberOwner
     *    GIVEN:  Business Unit 'Test Business Unit 1' exists with members
     *    EVENT:  Delete the owning member
     *    RESULT: Member is removed from the Chatter Group, Owner is changed
     */
    @isTest
    public static void test_deleteBusinessGroupMemberOwner() {
        getTestData();

        Test.startTest();

        Business_Unit_Contact__c member1 = TestFactoryBusinessUnitContact.makeBusinessUnitContact(bu1, true, 'HR Consultant', c1);
        insert member1;
        member1 = [SELECT Id, Chatter_Group_Member_Id__c, BU_User_Id__c, Active__c, Inactive_Date__c FROM Business_Unit_Contact__c WHERE Id = :member1.Id LIMIT 1];

        cg1 = [SELECT Id, Name, CollaborationType, OwnerId FROM CollaborationGroup WHERE Name = 'Test Business Unit 1' LIMIT 1];
        Assert.areEqual(cg1.OwnerId, member1.BU_User_Id__c);

        Business_Unit_Contact__c member2 = TestFactoryBusinessUnitContact.makeBusinessUnitContact(bu1, true, 'HR Consultant', c2);
        insert member2;
        member2 = [SELECT Id, Chatter_Group_Member_Id__c, BU_User_Id__c, Active__c, Inactive_Date__c FROM Business_Unit_Contact__c WHERE Id = :member2.Id LIMIT 1];

        Test.stopTest();

        List<CollaborationGroupMember> cg1Members = [SELECT Id, CollaborationGroupId, CollaborationRole, MemberId, NotificationFrequency
                                                     FROM CollaborationGroupMember
                                                     WHERE CollaborationGroupId = :cg1.Id];
        Assert.areEqual(true, isMemberInList(cg1Members, member1.Chatter_Group_Member_Id__c));
        Assert.areEqual(true, isMemberInList(cg1Members, member2.Chatter_Group_Member_Id__c));
        Assert.areEqual(2, cg1Members.size());

        CollaborationGroup cgroup = [SELECT Id, OwnerId FROM CollaborationGroup WHERE Id = :bu1.Chatter_Group_Id__c LIMIT 1];
        Assert.areEqual(cgroup.OwnerId, member1.BU_User_Id__c);

        member1.Active__c = false;
        member1.Inactive_Date__c = Date.today();
        delete member1;

        cg1Members = [SELECT Id, CollaborationGroupId, CollaborationRole, MemberId, NotificationFrequency
                      FROM CollaborationGroupMember
                      WHERE CollaborationGroupId = :cg1.Id];
        Assert.areEqual(1, cg1Members.size());
        Assert.areEqual(false, isMemberInList(cg1Members, member1.Chatter_Group_Member_Id__c));
        Assert.areEqual(true, isMemberInList(cg1Members, member2.Chatter_Group_Member_Id__c));

        cgroup = [SELECT Id, OwnerId FROM CollaborationGroup WHERE Id = :bu1.Chatter_Group_Id__c LIMIT 1];
        Assert.areEqual(u2.Id, cgroup.OwnerId);
    }

    @isTest
    public static void test_removeDuplicateCGMs() {
        getTestData();

        List<CollaborationGroupMember> listCGMs = new List<CollaborationGroupMember>();

        listCGMs.add(
            new CollaborationGroupMember(
                CollaborationGroupId = cg1.Id,
                CollaborationRole = 'Admin',
                MemberId = u1.Id
            )
        );
        listCGMs.add(
            new CollaborationGroupMember(
                CollaborationGroupId = cg1.Id,
                CollaborationRole = 'Admin',
                MemberId = u1.Id
            )
        );
        listCGMs.add(
            new CollaborationGroupMember(
                CollaborationGroupId = cg1.Id,
                CollaborationRole = 'Admin',
                MemberId = u2.Id
            )
        );
        listCGMs.add(
            new CollaborationGroupMember(
                CollaborationGroupId = cg1.Id,
                CollaborationRole = 'Standard',
                MemberId = u1.Id
            )
        );
        listCGMs.add(
            new CollaborationGroupMember(
                CollaborationGroupId = cg2.Id,
                CollaborationRole = 'Admin',
                MemberId = u2.Id
            )
        );
        listCGMs.add(
            new CollaborationGroupMember(
                CollaborationGroupId = cg2.Id,
                CollaborationRole = 'Standard',
                MemberId = u2.Id
            )
        );

        BusinessUnitMember_Service service = new BusinessUnitMember_Service();
        List<CollaborationGroupMember> result = service.removeDuplicateCGMs(listCGMs);

        Assert.areEqual(3, result.size());
    }


    private static Boolean isMemberInList(List<CollaborationGroupMember> members, Id idMember) {
        for (CollaborationGroupMember m : members) {
            if (m.Id == idMember) {
                return true;
            }
        }
        return false;
    }
}