/**
 * @description SandboxRefresh_TestEnv creates data for testing the SandboxRefresh classes.
 */
@IsTest
public without sharing class SandboxRefresh_TestEnv {
	// @description TEST_SANDBOX_NAME is a test name for the sandbox.
	public static final String TEST_SANDBOX_NAME = 'TestSandbox';
	
	// Rules set during testing
	private static List<Sandbox_Refresh_User__mdt> testRules;

    private static final String BRANCH_NUMBER = 'TEST';
    
	public static final String PROFILE_READ_ONLY = 'Read Only';
	public static final String PROFILE_MARKETING_USER = 'Marketing User';
	public static final String PROFILE_STANDARD_USER = 'Standard User';
	public static final String PROFILE_SYS_ADMIN = 'System Administrator';

	public static final String ROLE_TEST_NAME = 'TestRole';

	public User userOne;
	public User userTwo;
	public User userInactive;
	public User userDeployer;

	/**
	 * @description makeData creates a Role and a few user for testing.
	 */
	@TestSetup
	public static void makeData() {		
        Account branch = TestFactoryAccount.createBranch('TEST BRANCH', BRANCH_NUMBER, null, null);

        String extensionSandbox = '.' + TEST_SANDBOX_NAME;
        String extensionInvalid = '.invalid';

		User userDeployer = TestFactoryUser.makeUser('Test', 'Developer', PROFILE_SYS_ADMIN, BRANCH_NUMBER);
		userDeployer.UserName = userDeployer.Username + extensionSandbox;
        userDeployer.Email = userDeployer.Email + extensionInvalid;

		User userInactive = TestFactoryUser.makeUser('Test', 'Inactive', PROFILE_STANDARD_USER, BRANCH_NUMBER);
		userInactive.UserName = userInactive.Username + extensionSandbox;
        userInactive.Email = userInactive.Email + extensionInvalid;
        userInactive.IsActive = false;

		User userOne = TestFactoryUser.makeUser('Test', 'One', PROFILE_READ_ONLY, BRANCH_NUMBER);
		userOne.UserName = userOne.Username + extensionSandbox;
        userOne.Email = userOne.Email + extensionInvalid;

		User userTwo = TestFactoryUser.makeUser('Test', 'Two', PROFILE_MARKETING_USER, BRANCH_NUMBER);
		userTwo.UserName = userTwo.Username + extensionSandbox;
        userTwo.Email = userTwo.Email + extensionInvalid;

		insert new List<User>{ userDeployer, userInactive, userOne, userTwo };
	}

	/**
	 * @description makeRule makes a new Sandbox_Refresh_User__mdt object.
	 * @param  username  Username (if has sandbox name at end it is removed)
	 * @param  sandbox   Sandbox rule applies to
	 * @param  profile   Name of profile to change user to
	 * @param  role      Name of role to change user to
	 * @return Sandbox_Refresh_User__mdt
	 */
	public static Sandbox_Refresh_User__mdt makeRule(String username, String sandbox, String profile, String role) {
		if (!username.endswith('@bbsi.zzz')) {
			username = username.SubStringBeforeLast('.');
		}

		return new Sandbox_Refresh_User__mdt(
			Username__c = username,
			Sandbox__c = sandbox,
			Profile__c = profile,
			Role__c = role,
			Active__c = true
		);
	}

	/**
	 * @description getTestSandboxName retrieves the test sandbox name
	 * @return Name of the test sandbox
	 */
	public static String getTestSandboxName() {
		return TEST_SANDBOX_NAME;
	}

	/**
	 * @description getTestRules retrieves the set of rules.
	 * @return List<Sandbox_Refresh_User__mdt>
	 */
	public static List<Sandbox_Refresh_User__mdt> getTestRules() {
		return testRules;
	}

	/**
	 * @description getTestSandboxName set the set of rules.
	 */
	public static void setTestRules(List<Sandbox_Refresh_User__mdt> rules) {
		testRules = rules;
	}

	/**
	 * @description SandboxRefresh_TestEnv constructor.
	 */
	public SandboxRefresh_TestEnv() {
		userInactive = null;
		userDeployer = null;
		userOne = null;
		userTwo = null;
		String pattern = '%@bbsitest.zzz.' + TEST_SANDBOX_NAME;

		List<User> users = [
			SELECT LastName, UserName, Id, EMail, ProfileId, Profile.Name, UserRoleId, UserRole.Name
			FROM User
			WHERE UserName LIKE :pattern
            ORDER BY LastName ASC
		];

		Assert.areEqual(4, users.size());

        userDeployer = users[0];
        userInactive = users[1];
		userOne = users[2];
        userTwo = users[3];

		Assert.areNotEqual(null, userDeployer, 'userDeployer needs to be created');
		Assert.areNotEqual(null, userInactive, 'userInactive needs to be created');
		Assert.areNotEqual(null, userOne, 'userOne needs to be created');
		Assert.areNotEqual(null, userTwo, 'userTwo needs to be created');
	}
}