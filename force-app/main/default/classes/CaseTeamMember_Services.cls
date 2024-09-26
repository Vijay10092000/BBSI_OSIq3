/**
 * CaseTeamMember_Service
 *
 * @see https://developer.salesforce.com/docs/atlas.en-us.api.meta/api/sforce_api_objects_caseteammember.htm
 */
public without sharing class CaseTeamMember_Services {

    private static Map<String, Id> caseTeamRolesByName = null;

    public static Id getCaseTeamRoleByName(String roleName) {
		if (caseTeamRolesByName == null) {
		    caseTeamRolesByName = new Map<String,Id>();
		    for (CaseTeamRole ctr: [SELECT Id, Name FROM CaseTeamRole]) {
		        caseTeamRolesByName.put(ctr.Name, ctr.Id);
		    }
		}

        Id caseTeamRoleId;
        
        if (roleName != null && caseTeamRolesByName.containsKey(roleName)) {
            caseTeamRoleId = caseTeamRolesByName.get(roleName);
        }
        
        return caseTeamRoleId;

    }
    
    /**
     * createMember makes a CaseTeamMember object from the given Id.
     * CaseTeamRole is assigned using the SObject type of memberId.
     * If User, then role is
     * If Contact, then role is
     * Otherwise, no role is given.
     *
     * @param caseId - Related Case identfier
     * @param memberId - The new member's identfier
     * @param role - name of the role for the member
     * @return A CaseTeamMember object or null
     */
    public static CaseTeamMember createMember(Id caseId, Id memberId, String role) {        
        return createMember(caseId, MemberId = memberId, getCaseTeamRoleByName(role));
    }
    
    /**
     * createMember makes a CaseTeamMember object from the given Id.
     * CaseTeamRole is assigned using the SObject type of memberId.
     * If User, then role is
     * If Contact, then role is
     * Otherwise, no role is given.
     *
     * @param caseId - Related Case identfier
     * @param memberId - The new member's identfier
     * @param role - Identifier of the role for the member
     * @return A CaseTeamMember object or null
     */
    public static CaseTeamMember createMember(Id caseId, Id memberId, Id roleId) {        
        return new CaseTeamMember(
            ParentId = caseId,
            MemberId = memberId,
            TeamRoleId = roleId
        );
    }
    
    /**
     * getCaseTeamMembersByCase retrieves a map relating Case Ids to their
     * team members.  If no relationshipd to a caseId is found,
     * then the return object will not have an element for it.
     *
     * @param caseIds - Case Identifiers to get members for
     * @return A map relating Case Ids to their team members
     */
    public static Map<Id, Set<CaseTeamMember>> getCaseTeamMembersByCase(Set<Id> caseIds) {
        Map<Id, Set<CaseTeamMember>> results = new Map<Id, Set<CaseTeamMember>>();

        List<CaseTeamMember> members = [
            SELECT Id, ParentId, MemberId, TeamRoleId, TeamTemplateId, TeamTemplateMemberId 
            FROM CaseTeamMember 
            WHERE ParentId IN :caseIds
        ];

        for (CaseTeamMember member : members) {
            if (!results.keySet().contains(member.ParentId)) {
                results.put(member.parentId, new Set<CaseTeamMember>());                                  
            }
            results.get(member.parentId).add(member);
        }

        return results;
    }

    /**
     * getCaseTeamMembers retrieves the CaseTeamMember objects for the
     * given member ids.  If no relationshipd to a memberId is found,
     * then the return object will not have an element for it.
     *
     * @param memberId - List of User and/or Contact Identifiers
     * @return A map of CaseTeamMembers relating the member Id to the CaseTeamMembers.
     */
    public static Map<Id, Set<CaseTeamMember>> getCaseTeamMembersByMembers(Set<Id> memberIds) {
        Map<Id, Set<CaseTeamMember>> results = new Map<Id, Set<CaseTeamMember>>();
        
        List<CaseTeamMember> members = [
            SELECT Id, ParentId, MemberId, TeamRoleId, TeamTemplateId, TeamTemplateMemberId
            FROM CaseTeamMember
            WHERE MemberId IN :memberIds
        ];
        
        for (CaseTeamMember member : members) {
            if (!results.keySet().contains(member.MemberId)) {
                results.put(member.MemberId, new Set<CaseTeamMember>());                                  
            }
            results.get(member.MemberId).add(member);
        }

        return results;
    }

}