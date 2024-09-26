/**
 * @description SandboxRefreshPasswords contains methods executied after a sandbox
 * refresh has finished.  It uses the Database.Batchable so it will automatially run
 * only once.  The code the emails, roles, profiles, and may send email to change password.
 *
 * WARNING: This class should only be called from the SandboxRefresh.cls or
 * during testing.
 * 
 * Run the process anonymously:
 *     SandboxRefreshPasswords.resetPasswords(1);
 * 
 * @see SandboxRefresh.cls
 */
@SuppressWarnings('PMD.AvoidGlobalModifier')
global without sharing class SandboxRefreshPasswords implements Database.Batchable<sObject>, Database.Stateful {
	@TestVisible
	private static final String SCHEDULED_JOB_NAME = 'Sandbox Refresh Passwords';

	// Format of a User log line
	private static final String FORMAT_USER = '{0} {1}    Email: {2}';

	// List of User to change password
	private List<User> users;

	// Name of the sandbox working in
	@TestVisible
	private String nameSandbox;
	
	// Log record of the User Refresh
	@TestVisible
	private Log logPasswords;

	/**
	 * @description resetPasswords resets the passwords to all active Users.
	 * @param  delay  Number of minutes to wait before start
	 * @return Scheduled Job Id
	 */
	public static String resetPasswords(Integer delay) {
		String jobId =  System.scheduleBatch(new SandboxRefreshPasswords(), SCHEDULED_JOB_NAME, delay);
		System.debug(LoggingLevel.INFO, 'SandboxRefreshPasswords.resetPassword jobId = ' + jobId);

		return jobId;
	}

	/**
	 * @description SandboxRefreshPasswords constructor.
	 * @param  users  List of users to reset passwords
	 */
	public SandboxRefreshPasswords() {
		this.nameSandbox = SandboxRefresh.getSandboxName();
		this.logPasswords = new Log(Log.Severity.INFO, 'Sandbox Refresh', nameSandbox + ' SandboxRefresh: Resetting the User Passwords - Running Tests: ' + Test.isRunningTest());
	}

	/**
	 * @description start description
	 * @param  context  Contains the current job id.
	 * @return An empty Iterable
	 */
	global System.Iterable<sObject> start(Database.BatchableContext context) {
		List<User> users = new List<User>();

		if (SandboxRefresh.allowRun()) {			
			Map<String, Sandbox_Refresh_User__mdt> mapUserToRules = SandboxRefresh.determineRulesToApplyToUsers(nameSandbox);

			if (!mapUserToRules.isEmpty()) {
				logPasswords.addLine('UPDATING PASSWORDS');
				users = SandboxRefresh.getUsers(nameSandbox, mapUserToRules.values());
			} else {
				logPasswords.addLine('NO WORK PERFORMED: No users to update.');
			}
		} else {
			logPasswords.addLine('NO WORK PERFORMED: In Production and not running tests.');
		}

		return users;
	}

	/**
	 * @description execute updates user passwords.
	 * @param  context  Contains the current job id.
	 * @param  objects  Records for batch processing
	 */
	@SuppressWarnings('PMD.EmptyStatementBlock')
	global void execute(Database.BatchableContext context, List<sObject> objects) {
		List<User> users = (List<User>) objects;

		for (User user : users) {
			if (!Test.isRunningTest()) {
				System.resetPassword(user.Id, true);
			}

			logPasswords.addLine(
				String.format(
					FORMAT_USER, 
					new List<String>{user.Id, user.UserName, user.Email}
				)
			);
		}
	}

	/**
	 * @description finish performs User updates for the sandbox refresh or test.
	 * @param  context   Contains the current job id.
	 */
	global void finish(Database.BatchableContext context) {
		logPasswords.write();
	}
}