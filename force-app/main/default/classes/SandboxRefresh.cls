/**
 * @description SandboxRefresh may be used during a Sandbox create or refresh to perform actions on
 * the sandbox.
 *
 * The call to the SandboxPostCopy.runApexClass method is made near the end of the refresh
 * when the User table has not been updated. Actions against User objects need to be 
 * performed after the refresh, so theser are placed in SandboxRefresh.SandboxPostRefreshQueueable.
 * 
 * This class calls other classes to perform the SandboxRefresh.
 *
 * The class SandboxRefreshUser_Test updates the emails, profiles and roles of users specified
 * in the Custom Metadata Settings Sandbox_Refresh_User__mdt.  The Sandbox_Refresh_User_mdt holds
 * the rules to update User emails, profiles and roles during a sandbox refresh.
 * FIELDS:
 *   Username__c          TEXT(80)  Rule is applied to this Production Username.  Required.
 *   Sandbox__c           TEXT(12)  Rule applies to this Sandbox.  A blank applies to any sandbox.
 *   Profile__c           TEXT(80)  Profile to assign user.  A blank means don't change.
 *   Role__c              TEXT(80)  Role to assign user.  A blank means don't change.
 * 
 * The class SandboxRefreshSettings is currently not working.
 *
 * To test before deploying or refresh a sandbox without a Apex Class, add Sandbox_Refresh_User__mdt
 * and Sandbox_Refresh_Setting__mdt rules to the sandbox. Then from Developer Console, go to 
 * Debug - Open Excute Anonymous Window and run the code below.  When completed, confirm that it
 * worked by reviewing the Users and Setting defined.
 *
 *     (new SandboxRefresh()).runApexClass(null);
 *
 * @see https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_interface_System_SandboxPostCopy.htm
 * @see https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/api/apex_queueing_jobs.htm#!
 */
@SuppressWarnings('PMD.AvoidGlobalModifier')
global without sharing class SandboxRefresh implements SandboxPostCopy {
	// Schedule the processing in minutes into the future
	public static final Integer DELAY_BEFORE_PROCESS_MINUTES_PASSWORDS = 7;
	// Schedule the processing in minutes into the future
	public static final Integer DELAY_BEFORE_PROCESS_MINUTES_USERS = 10;
	
	// Information about the User update scheduled job
	private static final String FORMAT_CRON_DATA_USERS = '\nUpdate Users called:  CRON JOB Id: {0}    EXECUTE TIME: {1}';

	// Information about the Password update scheduled job
	private static final String FORMAT_CRON_DATA_PASSWORDS = '\nUpdate Passwords called:  CRON JOB Id: {0}    EXECUTE TIME: {1}';

	/**
	 * @description runApexClass executes actions in a new sandbox to prepare it for use.  
     * This method is called at the end of a Sandbox Refresh.
	 * @param  context is information about the sandbox being refreshed.
	 */
	global void runApexClass(SandboxContext context) {
		String nameSandbox = SandboxRefresh.getSandboxName();

		Log log = new Log(Log.Severity.INFO, 'Sandbox Refresh', nameSandbox + ' SandboxRefresh', 'REFRESHING SANDBOX');
		log.addLine();
		log.addLine('Testing: ' + Test.isRunningTest());
		log.addLine('Allow Run: ' + allowRun());
		log.addLine('Organization Id: ' + context?.organizationId());
		log.addLine('Sandbox Id: ' + context?.sandboxId());
		log.addLine('Sandbox Name: ' + context?.sandboxName());
		log.write();
		
		callRefreshUsers();

		/* TODO: FUTURE: If found to be needed.
		callRefreshPasswords()
		*/
	}

	/**
	 * @description allowRun determines if the Sandbox Refresh code may run.
	 * @return Boolean
	 */
	public static Boolean allowRun() {
		return (!String.isBlank(getSandboxName()) || Test.isRunningTest());
	}
	
	/**
	 * @description getSandboxName gets the current running sandbox name.
	 * WARNING: This assumes a domain has been created for the company.
	 * @return Sandbox name
	 */
	public static String getSandboxName() {
		String nameSandbox = null;

		String urlOrg = URL.getOrgDomainUrl().toExternalForm();
		Integer indexStart = urlOrg.indexOf('--');

		if (indexStart > 0) {
			Integer indexEnd = urlOrg.indexOf('.', indexStart);

			if (indexEnd > 0) {
				nameSandbox = urlOrg.substring(indexStart + 2, indexEnd).ToUpperCase();
			}
		}

		if (Test.isRunningTest()) {
			nameSandbox = SandboxRefresh_TestEnv.getTestSandboxName();
		}

		return nameSandbox;
	}

	/**
	 * @description determineRulesToApplyToUsers determines which rule is applied to each
	 * user of the sandbox.
	 * @param  nameSandbox  Name of the sandbox working on
	 * @return Map<String, Sandbox_Refresh_User__mdt> relating UserName to rule
	 */
	public static Map<String, Sandbox_Refresh_User__mdt> determineRulesToApplyToUsers(String nameSandbox) {
		Map<String, Sandbox_Refresh_User__mdt> mapUserToRule = new Map<String, Sandbox_Refresh_User__mdt>();

		for (Sandbox_Refresh_User__mdt sru : getRefreshUserRules(nameSandbox)) {
			if (!mapUserToRule.containsKey(sru.Username__c) || sru.Sandbox__c != null) {
				// The user is not in the current map OR this is a sandbox specific rule
				mapUserToRule.put(sru.Username__c, sru);
			}
		}

		return mapUserToRule;
	}

	/**
	 * @description getRefreshUserRules retrieves the rules which apply to the given sandbox
	 * or any sandbox.
	 * Queried rules are ordered making it easier to determine which rule to apply to a user.
	 * @param  nameSandbox  Name of the sandbox working on
	 * @return List<Sandbox_Refresh_User__mdt>
	 */
	@TestVisible
	private static List<Sandbox_Refresh_User__mdt> getRefreshUserRules(String nameSandbox) {
		List<Sandbox_Refresh_User__mdt> result = [
			SELECT Username__c, Sandbox__c, Profile__c, Role__c
			FROM Sandbox_Refresh_User__mdt
			WHERE Active__c = TRUE AND (Sandbox__c = :nameSandbox OR Sandbox__c = NULL)
			ORDER BY Username__c, Sandbox__c DESC NULLS LAST
		];

		if (Test.isRunningTest() && SandboxRefresh_TestEnv.getTestRules() != null) {
			result = SandboxRefresh_TestEnv.getTestRules();
		}

		return result;
	}

	/**
	 * @description getUsers retrieves active Users for the sandbox which may have
	 * changes made to their Email, Profile and Role.
	 * @param srus  Set of rules with Usernames
	 * @return List<User>
	 */
	public static List<User> getUsers(String nameSandbox, List<Sandbox_Refresh_User__mdt> srus) {
		String extensionSandbox = '.' + nameSandbox;

		Set<String> nameUsers = new Set<String>();
		for (Sandbox_Refresh_User__mdt sru : srus) {
			nameUsers.add(sru.Username__c + extensionSandbox);
		}

		List<User> result = [
			SELECT Id, Name, Username, ProfileId, UserRoleId, Email
			FROM User
			WHERE IsActive = TRUE 
			AND Username IN :nameUsers
			ORDER BY Username ASC
		];

		return result;
	}
	
	/**
	 * @description callRefreshUsers schedules a run of SandboxRefreshUsers.updateUsers.
	 */
	private static void callRefreshUsers() {
		String idCron = SandboxRefreshUsers.updateUsers(DELAY_BEFORE_PROCESS_MINUTES_PASSWORDS);

		if (String.isNotBlank(idCron)) {			
			CronTrigger ct = [SELECT Id, NextFireTime FROM CronTrigger WHERE Id = :idCron];
			System.debug(LoggingLevel.INFO, String.format(FORMAT_CRON_DATA_USERS, new List<String>{ ct.Id, ct.NextFireTime.format() }));
		} else {
			System.debug(LoggingLevel.ERROR, 'Did not create SandboxRefreshUsers job');
		}
	}
	
	/**
	 * @description callRefreshPasswords schedules a run of SandboxRefreshPasswords.resetPasswords.
	 */
	private static void callRefreshPasswords() {
		String idCron = SandboxRefreshPasswords.resetPasswords(DELAY_BEFORE_PROCESS_MINUTES_USERS);

		if (String.isNotBlank(idCron)) {			
			CronTrigger ct = [SELECT Id, NextFireTime FROM CronTrigger WHERE Id = :idCron];
			System.debug(LoggingLevel.INFO, String.format(FORMAT_CRON_DATA_PASSWORDS, new List<String>{ ct.Id, ct.NextFireTime.format() }));
		} else {
			System.debug(LoggingLevel.ERROR, 'Did not create SandboxRefreshPasswords job');
		}
	}
}