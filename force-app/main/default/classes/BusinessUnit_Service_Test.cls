/**
 *  BusinessUnit_Service_Test
 */
@isTest
public class BusinessUnit_Service_Test {

    @testSetup 
    static void setupTests() {
        
        Account a1 = TestFactoryAccount.makeBranch('--Test Account One--');
        Account a2 = TestFactoryAccount.makeBranch('--Test Account Two--');
        insert new List<Account>{ a1, a2 };
    }

    @isTest
    public static void test_makeBusinessUnitGroup() {
        CollaborationGroup cp = BusinessUnit_Service.makeBusinessUnitGroup('Test Name');

        Assert.areEqual('Test Name', cp.Name, 'Name was not set correctly');
        Assert.areEqual(false, cp.CanHaveGuests, 'Can Have Guests should be false');
        Assert.areEqual('Public', cp.CollaborationType, 'Should be Public in type');
        Assert.areEqual(true, cp.IsBroadcast, 'Broadcast should be set true');
        Assert.areEqual(BusinessUnit_Service.makeDescription('Test Name'), cp.Description, 'Description should be created through makeDescription');
    }

    @isTest
    public static void test_insertChatterGroups() {
        Account a1 = [SELECT Id, Name FROM Account WHERE Name = '--Test Account One--' LIMIT 1];
        Account a2 = [SELECT Id, Name FROM Account WHERE Name = '--Test Account Two--' LIMIT 1];

        Test.startTest();

        Business_Unit__c bu1 = TestFactoryBusinessUnit.makeBusinessUnit('Test Business Unit 1', a1.Id);
        Business_Unit__c bu2 = TestFactoryBusinessUnit.makeBusinessUnit('Test Business Unit 2', a2.Id);
        insert new List<Business_Unit__c>{ bu1, bu2 };

        Test.stopTest();

        List<CollaborationGroup> groups = [SELECT Id, Name, CollaborationType, Description, OwnerId
                                           FROM CollaborationGroup 
                                           WHERE Name LIKE 'Test Business Unit %'];

        Assert.areEqual(2, groups.size(), '2 groups should have been created');
        for (CollaborationGroup g : groups) {
            Assert.areEqual(BusinessUnit_Service.makeDescription(g.Name), g.Description, 'Description was not set correctly.');
        }
    }

    @isTest
    public static void test_updateChatterGroups() {
        String name = 'Test Business Unit 1';
        Account a1 = [SELECT Id, Name FROM Account WHERE Name = '--Test Account One--' LIMIT 1];

        Business_Unit__c bu1 = TestFactoryBusinessUnit.makeBusinessUnit(name, a1.Id);
        insert bu1;
        
        List<CollaborationGroup> groups;
        groups = [SELECT Id, Name, CollaborationType, Description, OwnerId
                  FROM CollaborationGroup 
                  WHERE Name = :name];
        Assert.areEqual(1, groups.size(), '1 group should have been created');
        Assert.areEqual(BusinessUnit_Service.makeDescription(name), groups.get(0).Description, 'Description was not set correctly.');

        Test.startTest();

        String newName = 'Test Business Unit Renamed';
        bu1.Name = newName;
        update bu1;       

        Test.stopTest();

        groups = [SELECT Id, Name, CollaborationType, Description, OwnerId
                  FROM CollaborationGroup 
                  WHERE Name = :newName];
        Assert.areEqual(1, groups.size(), '1 group should have been created');
        Assert.areEqual(BusinessUnit_Service.makeDescription(newName), groups.get(0).Description, 'Description was not set correctly.');
    }

    @isTest
    public static void testInsertChatterGroupMembers() {
        buildBusinessUnitEnvironment();
        Map<Id, Business_Unit__c> newValues = new Map<Id, Business_Unit__c>([SELECT Id, Chatter_Group_Id__c FROM Business_Unit__c]);
        BusinessUnit_Service.insertChatterGroupMembers(newValues);
        Assert.areEqual(0, [
            SELECT Id, BU_User_Id__c, Business_Unit__c, Chatter_Group_Member_Id__c
            FROM Business_Unit_Contact__c
            WHERE Business_Unit__c IN :newValues.keySet()
            AND Chatter_Group_Member_Id__c = NULL
        ].size());
    }
    
    @isTest
    public static void testGetBusinessUnitMembersWithoutChatter() {
        List<Id> idBUs = new List<Id>();
        Map<Id, Business_Unit_Contact__c> mapBUMs = BusinessUnit_Service.getBusinessUnitMembersWithoutChatter(idBUs);

        for (Business_Unit_Contact__c bum : mapBUMs.values()) {
            Assert.areEqual(true, null != bum.BU_User_Id__c);
            Assert.areEqual(true, null == bum.Chatter_Group_Member_Id__c);
        }
    }

    @isTest
    public static void testCreateNewMembers() {
        buildBusinessUnitEnvironment();
        Map<Id, Business_Unit__c> newValues = new Map<Id, Business_Unit__c>([SELECT Id, Chatter_Group_Id__c FROM Business_Unit__c]);
        Map<Id, Business_Unit_Contact__c> mapBUMs = new Map<Id, Business_Unit_Contact__c>([SELECT Id, Business_Unit__c, BU_User_Id__c FROM Business_Unit_Contact__c]);
        Map<Id, CollaborationGroupMember> members = BusinessUnit_Service.createNewMembers(newValues, mapBUMs);
        Assert.areEqual(members.size(), mapBUMs.size());
    }

    @isTest
    public static void test_getBusinessUnitEmails() {
        buildBusinessUnitEnvironment();

        Business_Unit__c bu1A = [SELECT Id FROM Business_Unit__c WHERE Name = 'Test BU 1A'];
        Business_Unit__c bu1B = [SELECT Id FROM Business_Unit__c WHERE Name = 'Test BU 1B'];
        Business_Unit__c bu2 = [SELECT Id FROM Business_Unit__c WHERE Name = 'Test BU 2'];

        Test.startTest();

        List<String> emailsBU1A = BusinessUnit_Service.getBusinessUnitEmails(bu1A.Id);
        List<String> emailsBU1B = BusinessUnit_Service.getBusinessUnitEmails(bu1B.Id);
        List<String> emailsBU2 = BusinessUnit_Service.getBusinessUnitEmails(bu2.Id);
        List<String> emailsBUInvalid = BusinessUnit_Service.getBusinessUnitEmails(null);

        Test.stopTest();

        Assert.areEqual(2, emailsBU1A.size(), 'Users 1 and 2 are in BU1A');
        Assert.isTrue(emailsBU1A.contains('user1@bbsi.zzz'), 'User 1 is in BU1A');
        Assert.isTrue(emailsBU1A.contains('user2@bbsi.zzz'), 'User 2 is in BU1A');
        Assert.areEqual(2, emailsBU1B.size(), 'Users 1 and 2 are in BU1B');
        Assert.isTrue(emailsBU1A.contains('user1@bbsi.zzz'), 'User 1 is in BU1B');
        Assert.isTrue(emailsBU1A.contains('user2@bbsi.zzz'), 'User 2 is in BU1B');
        Assert.areEqual(1, emailsBU2.size(), 'User 3 is in BU2');
        Assert.isTrue(emailsBU1A.contains('user1@bbsi.zzz'), 'User 3 is in BU2');
        Assert.areEqual(0, emailsBUInvalid.size(), 'Invalid Id was given, so no entries');
    }

    private static void buildBusinessUnitEnvironment() {
        Account branch1 = TestFactoryAccount.makeBranch('Branch 1', '001', 'Jon Noone', 'jon.noone@bbsi.zzz');
        Account branch2 = TestFactoryAccount.makeBranch('Branch 2', '002', 'Jane Noone', 'jane.noone@bbsi.zzz');
        Account client1 = TestFactoryAccount.makeAccount('Client 1', 'Client');
        Account client2 = TestFactoryAccount.makeAccount('Client 2', 'Client');
        Account client3 = TestFactoryAccount.makeAccount('Client 3', 'Client');
        insert new List<Account>{ branch1, branch2, client1, client2, client3 };

        User user1 = TestFactoryUser.makeUser(null, 'User1', 'BBSI Standard', '001', 'user1@bbsi.zzz', 'user1@bbsi.zzz');
        User user2 = TestFactoryUser.makeUser(null, 'User2', 'BBSI Standard', '001', 'user2@bbsi.zzz', 'user2@bbsi.zzz');
        User user3 = TestFactoryUser.makeUser(null, 'User3', 'BBSI Standard', '002', 'user3@bbsi.zzz', 'user3@bbsi.zzz');
        insert new List<User>{ user1, user2, user3 };

        Contact contact1 = TestFactoryContact.makeEmployee(user1.Id, null, 'User1', branch1.Id);
        Contact contact2 = TestFactoryContact.makeEmployee(user2.Id, null, 'User2', branch1.Id);
        Contact contact3 = TestFactoryContact.makeEmployee(user3.Id, null, 'User3', branch2.Id);
        insert new List<Contact>{ contact1, contact2, contact3 };

        Business_Unit__c bu1A = TestFactoryBusinessUnit.makeBusinessUnit('Test BU 1A', branch1.Id);
        Business_Unit__c bu1B = TestFactoryBusinessUnit.makeBusinessUnit('Test BU 1B', branch1.Id);
        Business_Unit__c bu2 = TestFactoryBusinessUnit.makeBusinessUnit('Test BU 2', branch2.Id);
        insert new List<Business_Unit__c>{ bu1A, bu1B, bu2 };

        Business_Unit_Contact__c buc11A = TestFactoryBusinessUnitContact.makeBusinessUnitContact(bu1A, true, 'Business Partner', contact1);
        Business_Unit_Contact__c buc11B = TestFactoryBusinessUnitContact.makeBusinessUnitContact(bu1B, true, 'Payroll Specialist', contact1);
        Business_Unit_Contact__c buc21A = TestFactoryBusinessUnitContact.makeBusinessUnitContact(bu1A, true, 'Business Partner', contact2);
        Business_Unit_Contact__c buc21B = TestFactoryBusinessUnitContact.makeBusinessUnitContact(bu1B, true, 'Payroll Specialist', contact2);
        Business_Unit_Contact__c buc32 = TestFactoryBusinessUnitContact.makeBusinessUnitContact(bu2, true, 'Business Partner', contact3);
        insert new List<Business_Unit_Contact__c>{ buc11A, buc11B, buc21A, buc21B, buc32 };

        Business_Unit_Member__c bum1 = TestFactoryBusinessUnitMember.makeBusinessUnitMember(buc11A, client1);
        Business_Unit_Member__c bum2 = TestFactoryBusinessUnitMember.makeBusinessUnitMember(buc21B, client2);
        Business_Unit_Member__c bum3 = TestFactoryBusinessUnitMember.makeBusinessUnitMember(buc32, client3);
        insert new List<Business_Unit_Member__c>{ bum1, bum2, bum3 };
    }
}