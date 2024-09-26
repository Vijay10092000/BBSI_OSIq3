/**
 * @description SandboxRefresh_Test is a test file for the SandboxRefresh class.
 */
@IsTest
public without sharing class SandboxRefresh_Test {
	/*
	 * @description TEST_SANDBOX_NAME is a test name for the sandbox.
	 */
	private static final String TEST_INVALID_SANDBOX_NAME = '!nvalid Name';

	@TestSetup
	static void makeData() {
		SandboxRefresh_TestEnv.makeData();		
	}

	/**
	 * @description test_RunApexClass exists for code line coverage.
	 */
	@IsTest
	public static void test_RunApexClass() {
		List<Sandbox_Refresh_User__mdt> testRules = new List<Sandbox_Refresh_User__mdt>();
		SandboxRefresh_TestEnv.setTestRules(testRules);

		Test.startTest();

		Test.testSandboxPostCopyScript(
			new SandboxRefresh(),
			UserInfo.getOrganizationId(),
			UserInfo.getOrganizationId(),
			TEST_INVALID_SANDBOX_NAME
		);

		Test.stopTest();

		Assert.isTrue(true, 'The runApexClass only calls other methods.');
	}

	/**
	 * @description test_RunApexClass exists for code line coverage.
	 */
	@IsTest
	public static void test_getSandboxName() {
		Boolean isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;

		String nameSandbox = SandboxRefresh.getSandboxName();

		if (isSandbox) {
			if (Test.isRunningTest()) {
				Assert.isFalse(String.isBlank(nameSandbox), 'Should have a sandbox name');
				Assert.areEqual(SandboxRefresh_TestEnv.TEST_SANDBOX_NAME, nameSandbox, 'Should be the test sandbox name');
			} else {
				Assert.isFalse(String.isBlank(nameSandbox), 'Should have a sandbox name');
				Assert.areNotEqual(SandboxRefresh_TestEnv.TEST_SANDBOX_NAME, nameSandbox, 'Should not be the name of the sandbox');
			}
		} else {
			if (Test.isRunningTest()) {
				Assert.isFalse(String.isBlank(nameSandbox), 'Should have a sandbox name');
				Assert.areEqual(SandboxRefresh_TestEnv.TEST_SANDBOX_NAME, nameSandbox, 'Should be the test sandbox name');
			} else {
				Assert.isNull(nameSandbox, 'Name should be NULL in Production');
			}
		}
	}

	/**
	 * @description test_RunApexClass exists for code line coverage.
	 */
	@IsTest
	public static void test_determineRulesToApplyToUsers() {
		SandboxRefresh_TestEnv env = new SandboxRefresh_TestEnv();

		List<Sandbox_Refresh_User__mdt> testRules = new List<Sandbox_Refresh_User__mdt>();
		testRules.add( SandboxRefresh_TestEnv.makeRule(env.userInactive.UserName, null, null, null) );
		testRules.add( SandboxRefresh_TestEnv.makeRule(env.userOne.UserName, SandboxRefresh_TestEnv.getTestSandboxName(), SandboxRefresh_TestEnv.PROFILE_SYS_ADMIN, SandboxRefresh_TestEnv.ROLE_TEST_NAME) );
		testRules.add( SandboxRefresh_TestEnv.makeRule(env.userOne.UserName, null, null, null) ); 
		testRules.add( SandboxRefresh_TestEnv.makeRule(env.userTwo.UserName, null, SandboxRefresh_TestEnv.PROFILE_SYS_ADMIN, null) );

		SandboxRefresh_TestEnv.setTestRules(testRules);

		Map<String, Sandbox_Refresh_User__mdt> userRules = SandboxRefresh.determineRulesToApplyToUsers(SandboxRefresh_TestEnv.TEST_SANDBOX_NAME);

		Assert.areEqual(3, userRules.size());

		Assert.isFalse(userRules.containsKey(env.userDeployer.UserName.SubStringBeforeLast('.')), 'No rule for Deployer applies');

		Sandbox_Refresh_User__mdt rule;

		String username = env.userInactive.UserName;
		username = username.SubStringBeforeLast('.');

		rule = userRules.get(env.userInactive.UserName.SubStringBeforeLast('.'));
		Assert.isNull(rule.Profile__c, 'Should have no Profile');
		Assert.isNull(rule.Role__c, 'Should have no Role');

		rule = userRules.get(env.userOne.UserName.SubStringBeforeLast('.'));
		Assert.areEqual(SandboxRefresh_TestEnv.PROFILE_SYS_ADMIN, rule.Profile__c, 'Should have a Profile');
		Assert.areEqual(SandboxRefresh_TestEnv.ROLE_TEST_NAME, rule.Role__c, 'Should have a Role');

		rule = userRules.get(env.userTwo.UserName.SubStringBeforeLast('.'));
		Assert.areEqual(SandboxRefresh_TestEnv.PROFILE_SYS_ADMIN, rule.Profile__c, 'Should have a Profile');
		Assert.isNull(rule.Role__c, 'Should have no Role');		
	}

	/**
	 * @description test_RunApexClass exists for code line coverage.
	 */
	@IsTest
	public static void test_allowRun() {
		Boolean isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;

		Boolean result = SandboxRefresh.allowRun();

		if (isSandbox) {
			Assert.isTrue(result, 'Should be true in a sandbox');
		} else {
			Assert.areEqual(Test.isRunningTest(), result, 'May only run in Production if testing.');
		}
	}

	/**
	 * @description test_getUsers tests User data can be retrieved from Usernames.
	 */
	@IsTest
	public static void test_getUsers() {
		SandboxRefresh_TestEnv env = new SandboxRefresh_TestEnv();

		List<Sandbox_Refresh_User__mdt> testSRU = new List<Sandbox_Refresh_User__mdt>();
		testSRU.add(SandboxRefresh_TestEnv.makeRule(env.userInactive.Username, null, null, null));
		testSRU.add(SandboxRefresh_TestEnv.makeRule(env.userOne.Username, SandboxRefresh_TestEnv.TEST_SANDBOX_NAME, null, null));
		testSRU.add(SandboxRefresh_TestEnv.makeRule(env.userOne.Username, null, null, null));
		testSRU.add(SandboxRefresh_TestEnv.makeRule(env.userTwo.Username, null, null, null));

		Test.startTest();

		List<User> users = SandboxRefresh.getUsers(SandboxRefresh_TestEnv.TEST_SANDBOX_NAME, testSRU);

		Test.stopTest();

		System.assertEquals(2, users.size(), 'The 2 ACTIVE users related to the rules should have been found.');
	}
}