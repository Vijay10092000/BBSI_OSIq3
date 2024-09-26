/**
 * CaseTeamRole_Services
 *
 * @see https://developer.salesforce.com/docs/atlas.en-us.api.meta/api/sforce_api_objects_caseteamrole.htm
 */
public without sharing class CaseTeamRole_Services {

    private static Map<String, CaseTeamRole> roles = null;

    public static CaseTeamRole getRole(String name) {
        if (roles == null) {
            roles = getCaseTeamRolesByName();
        }

        if (roles.keySet().contains(name)) {
            return roles.get(name);
        }

        return null;
    }

    @testVisible
    private static Map<String, CaseTeamRole> getCaseTeamRolesByName() {
        Map<String, CaseTeamRole> results = new Map<String, CaseTeamRole>();

        List<CaseTeamRole> roles = [SELECT Id, Name, AccessLevel, PreferencesVisibleInCSP FROM CaseTeamRole];
        for (CaseTeamRole role : roles) {
System.debug('ROLE  ' + role);
            results.put(role.Name, role);
        }

        return results;
    }
    
}