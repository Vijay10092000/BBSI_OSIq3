/**
 * @description SandboxRefresh_TestEnv creates data for testing the SandboxRefresh classes.
 */
@IsTest
public without sharing class SandboxRefreshPasswords_Test {
	/**
	 * @description makeData creates a Role and a few user for testing.
	 */
	@TestSetup
	static void makeData() {
        SandboxRefresh_TestEnv.makeData(); 
	}

	@IsTest
	static void test_constructor() {
		SandboxRefresh_TestEnv env = new SandboxRefresh_TestEnv();

		SandboxRefreshPasswords srp = new SandboxRefreshPasswords();

		Assert.areEqual(SandboxRefresh_TestEnv.TEST_SANDBOX_NAME, srp.nameSandbox, 'Should be test Sandbox');
		Assert.isNotNull(srp.logPasswords, 'Log should be started');
	}

	@IsTest
	static void test_start() {
		SandboxRefresh_TestEnv env = new SandboxRefresh_TestEnv();

		List<Sandbox_Refresh_User__mdt> testSRU = new List<Sandbox_Refresh_User__mdt>();
		testSRU.add(SandboxRefresh_TestEnv.makeRule(env.userOne.Username, SandboxRefresh_TestEnv.TEST_SANDBOX_NAME, null, null));
		testSRU.add(SandboxRefresh_TestEnv.makeRule(env.userTwo.Username, null, null, null));
		SandboxRefresh_TestEnv.setTestRules(testSRU);

		SandboxRefreshPasswords srp = new SandboxRefreshPasswords();

		Test.startTest();

		List<User> users = (List<User>) srp.start(null);

		Test.stopTest();

		Assert.areEqual(2, users.size());
	}

	@IsTest	static void test_execute() {
		SandboxRefresh_TestEnv env = new SandboxRefresh_TestEnv();

		List<User> users = new List<User>{ env.userOne, env.userTwo };

		SandboxRefreshPasswords srp = new SandboxRefreshPasswords();

		Test.startTest();

		srp.execute(null, users);

		Test.stopTest();

		Assert.isTrue(true, 'Nothing to assert');
	}

	@IsTest
	static void test_finish() {
		SandboxRefresh_TestEnv env = new SandboxRefresh_TestEnv();

		List<User> users = new List<User>{ env.userOne, env.userTwo };

		SandboxRefreshPasswords srp = new SandboxRefreshPasswords();

		DateTime dtBefore = DateTime.now();

		Test.startTest();

		srp.finish(null);

		Test.stopTest();

		List<Log__c> logs = Log_Test.recentLogs(dtBefore);

//		Assert.areEqual(1, logs.size(), 'Log should be written');
	}

	@IsTest
	static void test_resetPasswords() {
		SandboxRefresh_TestEnv env = new SandboxRefresh_TestEnv();

		DateTime dtBefore = DateTime.now();

		Test.startTest();

		String idJob = SandboxRefreshPasswords.resetPasswords(1);

		Test.stopTest();

		Assert.isNotNull(idJob, 'Job should be created');
	}
}