/**
 *  CaseTeamMember_Services_Test
 */
@isTest
public class CaseTeamMember_Services_Test {

    @testSetup
    static void setupTests() {
        User u1 = TestFactoryUser.makeUser('firstname','One Test','System Administrator', '910', 'one.test@bbsi.zzz', 'one.test@bbsi.zzz');
        User u2 = TestFactoryUser.makeUser('firstname1','Two Test','BBSI Standard', '910', 'two.test@bbsi.zzz', 'two.test@bbsi.zzz');
        User u3 = TestFactoryUser.makeUser('firstname2','Three Test','BBSI Standard', '910', 'three.test@bbsi.zzz', 'three.test@bbsi.zzz');
        insert new List<User>{ u1, u2, u3 };

        Account a = TestFactoryAccount.createBranch('--Test Account--','99999',null,null);

        Contact c1 = TestFactoryContact.makeContact('contactOne', 'One TestContact', 'BBSI Employee',a.id,'test1@bbsi.zzz');
        Contact c2 = TestFactoryContact.makeContact('contactTwo', 'Two TestContact', 'BBSI Employee',a.id,'test2@bbsi.zzz');
        Contact c3 = TestFactoryContact.makeContact('contactThree', 'Three TestContact', 'BBSI Employee',a.id,'test3@bbsi.zzz');
        insert new List<Contact>{ c1, c2, c3 };

        System.runAs(u1) {
            Map<String, Object> fldMap = new Map<String, Object>();
            fldMap.put('Type', 'Feature');
            Case case1 = TestFactoryCase.makeCase('--First Test Case', 'Test Description', c1.Id, a.Id, null, null, fldMap);
            Case case2 = TestFactoryCase.makeCase('--Second Test Case', 'Test Description', c1.Id, a.Id, null, null, fldMap);
            Case case3 = TestFactoryCase.makeCase('--Third Test Case', 'Test Description', c1.Id, a.Id, null, null, fldMap);
            insert new List<Case>{ case1, case2, case3 };

            CaseTeamRole role1 = TestFactoryCaseTeamRole.makeCaseTeamRole('Role 1',  'None', true);
            CaseTeamRole role2 = TestFactoryCaseTeamRole.makeCaseTeamRole('Role 2',  'Read', false);
            insert new List<CaseTeamRole>{ role1, role2 };

            CaseTeamMember member2  = TestFactoryCaseTeamMember.makeCaseTeamMember(case1.Id,u2.Id,role1.Id);
            CaseTeamMember member3  = TestFactoryCaseTeamMember.makeCaseTeamMember(case1.Id,c1.Id,role2.Id);
            CaseTeamMember member4  = TestFactoryCaseTeamMember.makeCaseTeamMember(case1.Id,c2.Id,role2.Id);
            CaseTeamMember member5  = TestFactoryCaseTeamMember.makeCaseTeamMember(case2.Id,u3.Id,role1.Id);
            CaseTeamMember member6  = TestFactoryCaseTeamMember.makeCaseTeamMember(case2.Id,c1.Id,role2.Id);
            insert new List<CaseTeamMember>{ member2, member3, member4, member5, member6 };
        }
    }

    @isTest
    static void testCaseTeamRolesByName() {
         Assert.areEqual(null, CaseTeamMember_Services.getCaseTeamRoleByName('Bad Test'), 'Should not have found an invalid Role');
         Assert.arenotEqual(null, CaseTeamMember_Services.getCaseTeamRoleByName('Role 1'), 'Role1 should exist');
         Assert.arenotEqual(null, CaseTeamMember_Services.getCaseTeamRoleByName('Role 2'), 'Role2 should exist');
    }

    @isTest
    static void testGetCaseTeamRoleByName() {
        CaseTeamRole role1 = [SELECT Id, Name FROM CaseTeamRole WHERE Name = 'Role 1' LIMIT 1];
        CaseTeamRole role2 = [SELECT Id, Name FROM CaseTeamRole WHERE Name = 'Role 2' LIMIT 1];

        Assert.areEqual(role1.Id, CaseTeamMember_Services.getCaseTeamRoleByName('Role 1'), 'Role1 should exist');
        Assert.areEqual(role2.Id, CaseTeamMember_Services.getCaseTeamRoleByName('Role 2'), 'Role2 should exist');
    }

    /**
     * testGetCaseTeamMembersByCase
     * REMEMBER: The user to insert the Case is added as a member
     */
    @isTest
    static void testGetCaseTeamMembersByCase() {
        Id case1Id = [SELECT Id, Subject FROM Case WHERE Subject = '--First Test Case' LIMIT 1].Id;
        Id case2Id = [SELECT Id, Subject FROM Case WHERE Subject = '--Second Test Case' LIMIT 1].Id;
        Id case3Id = [SELECT Id, Subject FROM Case WHERE Subject = '--Third Test Case' LIMIT 1].Id;
        Set<Id> ids = new Set<Id>{ case1Id, case2Id, case3Id };

        Test.startTest();
        Map<Id, Set<CaseTeamMember>> mapCaseMembers = CaseTeamMember_Services.getCaseTeamMembersByCase(ids);
        Test.stopTest();

        Assert.areEqual(3, mapCaseMembers.size(), 'There should be one for each case.');
        Assert.areEqual(4, mapCaseMembers.get(case1Id).size());
        Assert.areEqual(3, mapCaseMembers.get(case2Id).size());
        Assert.areEqual(1, mapCaseMembers.get(case3Id).size());
    }

    /**
     * testGetCaseTeamMembers
     * REMEMBER: The user to insert the Case is added as a member
     */
    @isTest
    static void testGetCaseTeamMembers() {
        Id user1Id = [SELECT Id, UserName FROM User WHERE UserName = 'one.test@bbsi.zzz' LIMIT 1].Id;
        Id user2Id = [SELECT Id, UserName FROM User WHERE UserName = 'two.test@bbsi.zzz' LIMIT 1].Id;
        Id user3Id = [SELECT Id, UserName FROM User WHERE UserName = 'three.test@bbsi.zzz' LIMIT 1].Id;
        Id contact1Id = [SELECT Id, Name FROM Contact WHERE LastName = 'One TestContact' LIMIT 1].Id;
        Id contact2Id = [SELECT Id, Name FROM Contact WHERE LastName = 'Two TestContact' LIMIT 1].Id;
        Id contact3Id = [SELECT Id, Name FROM Contact WHERE LastName = 'Three TestContact' LIMIT 1].Id;

        Set<Id> ids = new Set<Id>{ user1Id, user2Id, user3Id, contact1Id, contact2Id, contact3Id };

        Test.startTest();
        Map<Id, Set<CaseTeamMember>> mapMembers = CaseTeamMember_Services.getCaseTeamMembersByMembers(ids);
        Test.stopTest();

        Assert.areEqual(5, mapMembers.size());
        Assert.areEqual(3, mapMembers.get(user1Id).size());
        Assert.areEqual(1, mapMembers.get(user2Id).size());
        Assert.areEqual(1, mapMembers.get(user3Id).size());
        Assert.areEqual(2, mapMembers.get(contact1Id).size());
        Assert.areEqual(1, mapMembers.get(contact2Id).size());
        Assert.areEqual(false, mapMembers.keySet().contains(contact3ID));
    }

    @isTest
    private static void createMember() {
        Case c = [SELECT Id, Subject FROM Case WHERE Subject = '--First Test Case' LIMIT 1];
        User u = [SELECT Id, UserName FROM User WHERE UserName = 'one.test@bbsi.zzz' LIMIT 1];
        Contact con = [SELECT Id, Name FROM Contact WHERE LastName = 'One TestContact' LIMIT 1];

        Id role1Id = CaseTeamRole_Services.getRole('Role 1').Id;
        Id role2Id = CaseTeamRole_Services.getRole('Role 2').Id;

        Test.startTest();
        CaseTeamMember member;
        member = CaseTeamMember_Services.CreateMember(c.Id, u.Id, role1Id);
        Assert.areEqual(role1Id, member.TeamRoleId);

        member = CaseTeamMember_Services.CreateMember(c.Id, con.Id, role2Id);
        Assert.areEqual(role2Id, member.TeamRoleId);
        Test.stopTest();
    }

}