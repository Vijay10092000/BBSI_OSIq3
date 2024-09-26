/**
 * @description TestFactoryCaseTeamRole contains methods to create test CaseTeamRole.
 */
@isTest
public class TestFactoryCaseTeamRole {
    /**
	 * @description createCaseTeamRole creates a CaseTeamRole in the database.
	 * @param  name    createCaseTeamRole Name
	 * @param   AccessLevel  AccessLevel of CaseTeamRole
	 * @param PreferencesVisibleInCSP   PreferencesVisibleInCSP of CaseTeamRole
	 * @return CaseTeamRole
	 */
    
     public static CaseTeamRole  createCaseTeamRole(String Name, String AccessLevel,Boolean PreferencesVisibleInCSP) {
		CaseTeamRole  casteam = makeCaseTeamRole(Name,AccessLevel,PreferencesVisibleInCSP);
		insert casteam;
		return casteam;
	}
	/**
	 * @description makeCaseTeamRole creates a CaseTeamRole in the database.
	 * @param  name    createCaseTeamRole Name
	 * @param   AccessLevel  AccessLevel of CaseTeamRole
	 * @param PreferencesVisibleInCSP   PreferencesVisibleInCSP of CaseTeamRole
	 * @return CaseTeamRole
	 */
	 public static CaseTeamRole makeCaseTeamRole(String Name, String AccessLevel,Boolean PreferencesVisibleInCSP) {
        CaseTeamRole casteam =  new CaseTeamRole(

        Name = Name,
        AccessLevel = AccessLevel,
		PreferencesVisibleInCSP=PreferencesVisibleInCSP
         );
        return casteam;
    }

}