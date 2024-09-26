@isTest
private class AddCaseTeamMemberControllerTest {

    @testSetup
    static void setup(){
        User u = TestFactoryUser.makeUser('TestBP', 'last1', 'System Administrator', '910', 'testBBSI@bbsihq.com', 'testBBSI@bbsihq.com');
        User testUser1 = TestFactoryUser.makeUser('firstuser','Test User1', 'BBSI Standard', '910','testUser1@bbsihq.com', 'testUser1@bbsihq.com');

        User testUser2 = TestFactoryUser.makeUser('seconduser', 'Test User2', 'BBSI Standard', '910','testUser2@bbsihq.com', 'testUser2@bbsihq.com');
        User testUser3 = TestFactoryUser.makeUser('Thirduser', 'Test User3', 'BBSI Standard', '910','testUser3@bbsihq.com', 'testUser3@bbsihq.com');
        List<User> users = new List<User>{ testUser1, testUser2, testUser3 };
        insert users;
        System.runAs(u) {
            Account client = TestFactoryAccount.makeClient('Test Client',null,null);
            insert client;
            Account testBranch = TestFactoryAccount.makeBranch('Test Branch', '98662', null,null);
            testBranch.Region__c = 'SoCal';
            testBranch.Zone__c = '1';
            testBranch.External_ID__c = '910';
            insert testBranch;
            List<Contact> listContacts = new List<Contact>();
            Contact testContact1 = TestFactoryContact.makeEmployee(testUser1.Id, null, 'TestContact1', testBranch.Id);
            listContacts.add(testContact1);
            Contact testContact2 = TestFactoryContact.makeEmployee(testUser2.Id, null, 'TestContact2', testBranch.Id);
            listContacts.add(testContact2);
            Contact testContact3 = TestFactoryContact.makeEmployee(testUser3.Id, null, 'TestContact3', testBranch.Id);
            listContacts.add(testContact3);
            Contact testContact4 = TestFactoryContact.makeEmployee(u.Id, null, 'TestContact4', testBranch.Id);
            listContacts.add(testContact4);
            insert listContacts;
            Business_Unit__c testBU = TestFactoryBusinessUnit.makeBusinessUnit('Add Case Team Test BU', testBranch.Id);
            insert testBU;
            Business_Unit_Contact__c buMember1 = TestFactoryBusinessUnitContact.makeBusinessUnitContact(testBU, true, 'Payroll', testContact1);
            Business_Unit_Contact__c buMember2 = TestFactoryBusinessUnitContact.makeBusinessUnitContact(testBU, true, 'Risk Consultant', testContact2);
            Business_Unit_Contact__c buMember3 = TestFactoryBusinessUnitContact.makeBusinessUnitContact(testBU, true, 'Business Partner', testContact4);
            List<Business_Unit_Contact__c> bucontacts = new List<Business_Unit_Contact__c>{ buMember1, buMember2, buMember3 };
            insert bucontacts;
        }

    }

    @isTest
    static void testGetUsers() {
        Account branch = [Select ID, OwnerID from Account where Name = 'Test Branch'];
        Account client = [Select ID, OwnerID from Account where Name = 'Test Client'];
        Contact contact1 = [Select Id From Contact Where LastName = 'TestContact1'];
        Contact contact2 = [Select Id From Contact Where LastName = 'TestContact2'];
        Contact contact3 = [Select Id From Contact Where LastName = 'TestContact3'];
        Contact contact4 = [Select Id From Contact Where LastName = 'TestContact4'];
        User user1 = [Select Id From User Where LastName = 'Test User1'];
        User user2 = [Select Id From User Where LastName = 'Test User2'];
        User user3 = [Select Id From User Where LastName = 'Test User3'];
        
        Case testCase = TestFactoryCase.createCase('Test', 'Test Description', contact4.Id, branch.Id, client.Id, 'Email to Case', null);    

        Test.startTest();
        List<User> listUsersDefault = AddCaseTeamMemberController.getUsers(testCase.Id, null);
        List<User> listUsersForBU = AddCaseTeamMemberController.getUsers(testCase.Id, 'BU');
        List<User> listUsersForBranch = AddCaseTeamMemberController.getUsers(testCase.Id, 'Branch');
        Test.stopTest();

        Set<Id> setUserIdsDefaultOrBU = new Set<Id>();
        for (User u: listUsersDefault) {
            setUserIdsDefaultOrBU.add(u.Id);
        }

        Assert.areEqual(2, listUsersDefault.size());
        Assert.areEqual(2, listUsersForBU.size());
        Assert.isTrue(setUserIdsDefaultOrBU.contains(user1.Id));
        Assert.isTrue(setUserIdsDefaultOrBU.contains(user2.Id));

        Set<Id> setUserIdsForBranch = new Set<Id>();
        for (User u: listUsersForBranch) {
            setUserIdsForBranch.add(u.Id);
        }

        Assert.areEqual(3, listUsersForBranch.size());
        Assert.isTrue(setUserIdsForBranch.contains(user1.Id));
        Assert.isTrue(setUserIdsForBranch.contains(user2.Id));
        Assert.isTrue(setUserIdsForBranch.contains(user3.Id));
    }


    @isTest
    static void testAddUsersToCaseTeam() {
        Account branch = [Select ID, OwnerID from Account where Name = 'Test Branch'];
        Account client = [Select ID, OwnerID from Account where Name = 'Test Client'];
        Contact contact1 = [Select Id From Contact Where LastName = 'TestContact1'];
        Contact contact2 = [Select Id From Contact Where LastName = 'TestContact2'];
        Contact contact3 = [Select Id From Contact Where LastName = 'TestContact3'];
        Contact contact4 = [Select Id From Contact Where LastName = 'TestContact4'];
        
        User user1 = [Select Id From User Where LastName = 'Test User1'];
        User user2 = [Select Id From User Where LastName = 'Test User2'];
        User user3 = [Select Id From User Where LastName = 'Test User3'];
        
        Id externalCaseRecordTypeId = RecordTypeService.getId('Case','Email to Case');
        Map<Id, CaseTeamMember> mapCaseTeamMembers = new Map<Id, CaseTeamMember>();

        Case testCase = TestFactoryCase.createCase('Test', 'Test Description', contact4.Id, branch.Id, client.Id, 'Email to Case', null);        

        List<User> listUsersDefault = AddCaseTeamMemberController.getUsers(testCase.Id, null);
        List<Id> listUserIds = new List<Id>();
        for (User u: listUsersDefault) {
            listUserIds.add(u.Id);
        }

        Test.startTest();
        String returnMessage = AddCaseTeamMemberController.addUsersToCaseTeam(testCase.Id, listUserIds);
        Test.stopTest();

        for (CaseTeamMember ctm: [Select Id, ParentId, MemberId, TeamRoleId From CaseTeamMember Where ParentId =: testCase.Id]) {
            mapCaseTeamMembers.put(ctm.MemberId, ctm);
        }

        Assert.areEqual('User(s) added to Case Team', returnMessage);
        Assert.areEqual(4, mapCaseTeamMembers.size());
        Assert.isTrue(mapCaseTeamMembers.containsKey(user1.Id));
        Assert.isTrue(mapCaseTeamMembers.containsKey(user2.Id));

    }
}