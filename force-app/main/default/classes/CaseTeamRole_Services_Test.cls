/**
 *  CaseTeamRole_Services_Test
 */
@isTest
public class CaseTeamRole_Services_Test {

    @TestSetup static void setupTests() {
        CaseTeamRole role1 = TestFactoryCaseTeamRole.makeCaseTeamRole('Role 1',  'None', true);
        CaseTeamRole role2 = TestFactoryCaseTeamRole.makeCaseTeamRole('Role 2',  'Read', false);
        CaseTeamRole role3 = TestFactoryCaseTeamRole.makeCaseTeamRole('Role 3',  'Edit', true);
        
        insert new List<CaseTeamRole>{ role1, role2, role3 };
    }
    
    @isTest
    static void getRole() {
        Test.startTest();
        CaseTeamRole role;
        role = CaseTeamRole_Services.getRole('Role 1');
        Assert.areEqual('Role 1', role.Name);
        role = CaseTeamRole_Services.getRole('Role 2');
        Assert.areEqual('Role 2', role.Name);
        role = CaseTeamRole_Services.getRole('Role 3');
        Assert.areEqual('Role 3', role.Name);
        role = CaseTeamRole_Services.getRole('Not A Role ');
        Assert.areEqual(null, role);
        Assert.areEqual(1, Limits.getQueries());
        Test.stopTest();
    }

    @isTest
    static void getCaseTeamRolesByName() {
        Map<String, CaseTeamRole> roles = CaseTeamRole_Services.getCaseTeamRolesByName();
        Assert.areEqual(true, roles.size() >= 3);
        Assert.areEqual(true, roles.keySet().contains('Role 1'));
        Assert.areEqual(true, roles.keySet().contains('Role 2'));
        Assert.areEqual(true, roles.keySet().contains('Role 3'));
    }
    
}