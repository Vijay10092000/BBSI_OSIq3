/**
* @description TestFactoryCaseTeamMember contains methods to create test CaseTeamMember.
*/
@isTest
public class TestFactoryCaseTeamMember {
    /**
* @description createCaseTeamMember creates a CaseTeamMember in the database.
* @param  ParentId   case of CaseTeamMember
* @param   MemberId  contact of CaseTeamMember
* @param TeamRoleId   CaseTeamRole of CaseTeamMember
* @return casteam
*/
    
    public static CaseTeamMember  createCaseTeamMember(Id ParentId,Id MemberId,Id TeamRoleId) {
        CaseTeamMember  casteam = makeCaseTeamMember(ParentId,MemberId,TeamRoleId);
        insert casteam;
        return casteam;
    }
    /**
* @description makeCaseTeamMember creates a CaseTeamMember in the database.
* @param  ParentId   case of CaseTeamMember
* @param   MemberId  contact of CaseTeamMember
* @param TeamRoleId   CaseTeamRole of CaseTeamMember
* @return casteam
*/
    public static CaseTeamMember makeCaseTeamMember(Id ParentId,Id MemberId,Id TeamRoleId) {
        CaseTeamMember casteam =  new CaseTeamMember(
            ParentId=ParentId,
            MemberId=MemberId,
            TeamRoleId=TeamRoleId
            
        );
        return casteam;
    }
    
}