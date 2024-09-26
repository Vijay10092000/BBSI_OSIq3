/**
 * @description UserBdms contains methods to access Business Developer Manager Users.
 */
public without sharing class UserBdms {
	private static final String FORMAT_ONLY_ACTIVE_BDMS =
		'SELECT Id, Name, IsActive, FirstName, LastName, Email, ManagerId, UserRoleId, UserType, UserName, ContactId, Branch_ID__c' +
		' FROM User' +
		' WHERE Business_Activity_Report_BDM__c = TRUE';

	/**
	 * @description getAllReportBdms retrieves all Users information for the BDMs marked
	 * as having report ability.
	 * @param activeOnly  Only include Active users?
	 * @return A Map of User Id to User object
	 */
	public static Map<Id, User> getAllReportBdms(Boolean activeOnly) {
		String active = (activeOnly) ? ' AND IsActive = TRUE' : '';

		String query = FORMAT_ONLY_ACTIVE_BDMS + active;

		return new Map<Id, User>((List<User>) Database.query(query));
	}
}