/**
 * @description SandboxPostRefreshBatchable contains methods executied after a sandbox
 * refresh has finished.  It uses the Database.Batchable so it will automatially run
 * only once.  The code the emails, roles, profiles, and may send email to change password.
 *
 * WARNING: This class should only be called from the SandboxRefresh.cls or
 * during testing.
 * 
 * Run the process anonymously:
 *     SandboxRefreshUsers.updateUsers();
 * 
 * @see SandboxRefresh.cls
 */
@SuppressWarnings('PMD.AvoidGlobalModifier')
global without sharing class SandboxRefreshUsers implements Database.Batchable<sObject>, Database.Stateful {
	@TestVisible
	private static final String SCHEDULED_JOB_NAME = 'Sandbox Refresh Users';
	
	// Extention put on emails to block sandbox access
	@TestVisible
	private static final String USER_EMAIL_INVALID_EXTENSION = '.invalid';

	// Format of a User log line
	private static final String FORMAT_USER = '{0}:  {1}  {2}     Profile: {3}  Role: {4}  Email: {5}';

	// Map of Profile Name to Id
	@TestVisible
	private Map<String, Id> mapNameProfiles;

	// Map of Role Name to Id
	@TestVisible
	private Map<String, Id> mapNameRoles;

	// Map of UserName to Sandbox Refresh User rule
	@TestVisible
	private Map<String, Sandbox_Refresh_User__mdt> mapUserToRules;

	// Name of the sandbox working in
	@TestVisible
	private String nameSandbox;

	// Log record of the User Refresh
	@TestVisible
	private Log logUsers;

	/**
	 * @description updateUsers resets the User information.
	 * @param  delay  Number of minutes to wait before start
	 * @return Scheduled Job Id
	 */
	public static String updateUsers(Integer delay) {
		String jobId =  System.scheduleBatch(new SandboxRefreshUsers(), SCHEDULED_JOB_NAME, delay);
		System.debug(LoggingLevel.INFO, 'SandboxRefreshPasswords.updateUsers jobId = ' + jobId);

		return jobId;
	}

	/**
	 * @description SandboxRefreshUsers constructor.
	 */
	public SandboxRefreshUsers() {
		nameSandbox = SandboxRefresh.getSandboxName();
		logUsers = new Log(Log.Severity.INFO, 'Sandbox Refresh',  nameSandbox + ': Refreshing the Users - Running Tests: ' + Test.isRunningTest());
	}

	/**
	 * @description start description
	 * @param  context  Contains the current job id.
	 * @return An empty Iterable
	 */
	global System.Iterable<sObject> start(Database.BatchableContext context) {
		List<User> users = new List<User>();

		if (SandboxRefresh.allowRun()) {
			mapUserToRules = SandboxRefresh.determineRulesToApplyToUsers(nameSandbox);

			if (!mapUserToRules.isEmpty()) {
				logUsers.addLine('UPDATING USERS');

				mapNameProfiles = getNameToProfiles();
				mapNameRoles = getNameToRoles();

				users = SandboxRefresh.getUsers(nameSandbox, mapUserToRules.values());
			} else {
				logUsers.addLine('NO WORK PERFORMED: No users to update.');
			}
		}

		return users;
	}

	/**
	 * @description execute updates user information.
	 * @param  context  Contains the current job id.
	 * @param  objects  Records for batch processing
	 */
	@SuppressWarnings('PMD.EmptyStatementBlock')
	global void execute(Database.BatchableContext context, List<sObject> objects) {
		try {
			if (SandboxRefresh.allowRun()) {
				List<User> users = (List<User>) objects;
				Boolean hadError = true;

				if (!users.isEmpty()) {				
					List<User> updateUsers = activateUsers(users);
					
					if (!updateUsers.isEmpty()) {
						List<Database.SaveResult> listSaves = Database.update(updateUsers, false);
						hadError = Log.writeIfError('Sandbox Refresh', 'Update Users Failed', 'Failed Update Users', listSaves);
					} else {
						logUsers.addLine('NO WORK PERFORMED: No updated users.');
					}
				} else {
					logUsers.addLine('NO WORK PERFORMED: No users to update.');
				}
			} else {
				logUsers.addLine('NO WORK PERFORMED: Running in Production and not testing.');
			}
		} catch (Exception e) {
			logUsers.addLine();
			logUsers.addLine('EXCEPTION: ' + e.getMessage() + '\n\n' + e.getCause());
		}
	}

	/**
	 * @description finish performs User updates for the sandbox refresh or test.
	 * @param  context   Contains the current job id.
	 */
	global void finish(Database.BatchableContext context) {
		logUsers.write();
	}

	/**
	 * @description activateUsers updates the User Emails, Profiles and Roles based on the
	 * current sandbox rules found in Sandbox_Refresh_User__mdt.
	 * @return List<User> which were changed
	 */
	@TestVisible
	private List<User> activateUsers(List<User> users) {
		String extensionSandbox = '.' + nameSandbox;

		List<User> updateUsers = new List<User>();

		for (User user : users) {
			Boolean updated = false;
			String username = user.Username.removeEndIgnoreCase(extensionSandbox);
			Sandbox_Refresh_User__mdt sru = mapUserToRules.get(username);

			if (updateUser(user, sru)) {
				updateUsers.add(user);

				updated = true;
			}

			logUsers.addLine(
				String.format(
					FORMAT_USER,
					new List<String>{ 
						(updated) ? 'CHANGED  ' : 'UNCHANGED',
						user.Id,  
						user.UserName, 
						user.ProfileId, 
						user.UserRoleId,
						user.Email
					}
				)
			);
		}

		return updateUsers;
	}

	/**
	 * @description updateUser updates the email, profile and role for the given user
	 * based on the given Sandbox_Refresh_User__mdt.
	 * @param  user  User to update
	 * @param  sru   Rules to update by
	 * @return true if a change was made to the User
	 */
	@TestVisible
	private Boolean updateUser(User user, Sandbox_Refresh_User__mdt sru) {
		Boolean change = false;

		if (sru != null) {
			change |= fixUserEmail(user);
			change |= fixUserProfile(user, sru.Profile__c);
			change |= fixUserRole(user, sru.Role__c);
		}

		return change;
	}

	/**
	 * @description fixUserEmail updates the User's email.
	 * @param  user  User to update
	 * @return true if the email was changed
	 */
	@TestVisible
	private Boolean fixUserEmail(User user) {
		String email = user.Email;

		if (email.endsWith(USER_EMAIL_INVALID_EXTENSION)) {
			user.Email = email.removeEndIgnoreCase(USER_EMAIL_INVALID_EXTENSION);
			return true;
		}

		return false;
	}

	/**
	 * @description fixUserProfile updates the User's Profile Id.
	 * @param  user         User to update
	 * @param  nameProfile  Profile Id to change to
	 * @return true if the Profile Id was changed
	 */
	@TestVisible
	private Boolean fixUserProfile(User user, String nameProfile) {
		if (mapNameProfiles.containsKey(nameProfile)) {
			Id idProfile = mapNameProfiles.get(nameProfile);

			if (user.ProfileId != idProfile) {
				user.ProfileId = idProfile;
				return true;
			}
		}

		return false;
	}

	/**
	 * @description fixUserRole updates the User's Role Id.
	 * @param  user      User to update
	 * @param  nameRole  Role Id to change to
	 * @return true if the Role Id was changed
	 */
	@TestVisible
	private Boolean fixUserRole(User user, String nameRole) {
		if (mapNameRoles.containsKey(nameRole)) {
			Id idRole = mapNameRoles.get(nameRole);

			if (user.UserRoleId != idRole) {
				user.UserRoleId = idRole;
				return true;
			}
		}

		return false;
	}

	/**
	 * @description getNameToProfiles retrieves a Map relating Profile Name to Profile Id.
	 * @return Map<String, Id>
	 */
	@TestVisible
	private Map<String, Id> getNameToProfiles() {
		Map<String, Id> result = new Map<String, Id>();

		for (Profile p : [SELECT Id, Name FROM Profile]) {
			result.put(p.Name, p.Id);
		}

		return result;
	}

	/**
	 * @description getNameToRoles retrieves a Map relating Role Name to Role Id.
	 * @return Map<String, Id>
	 */
	@TestVisible
	private Map<String, Id> getNameToRoles() {
		Map<String, Id> result = new Map<String, Id>();

		for (UserRole r : [SELECT Id, Name FROM UserRole]) {
			result.put(r.Name, r.Id);
		}

		return result;
	}
}