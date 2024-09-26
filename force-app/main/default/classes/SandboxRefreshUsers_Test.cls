/**
 * @description SandboxRefreshUsers_Test contains tests for the SandboxRefreshUser class.
 *
 * Tests with Sandbox_Refresh_User__mdt should rules are ordered correctly by checking
 * SandboxRefreshUser.getRefreshUserRules().
 */
@IsTest
public without sharing class SandboxRefreshUsers_Test {
	private static final String EMAIL_TEST_ONE = 'test.one@bbsihq.tst';
	private static final String EMAIL_TEST_TWO = 'test.two@bbsihq.tst';
	private static final String EMAIL_TEST_INACTIVE = 'test.inactive@bbsihq.tst';
	private static final String EMAIL_TEST_ADMIN = 'test.admin@bbsihq.tst';

	private static final String ROLE_TEST_NAME = 'TestRole';

	/**
	 * @description makeData creates a Role and a few user for testing.
	 */
	@TestSetup
	static void makeData() {
		SandboxRefresh_TestEnv.makeData(); 
	}

	@IsTest
	static void test_getNameToProfiles() {
		SandboxRefreshUsers sru = new SandboxRefreshUsers();

		Map<String, Id> profiles = sru.getNameToProfiles();

		Assert.isFalse(profiles.isEmpty());
		Assert.isTrue(profiles.containsKey(SandboxRefresh_TestEnv.PROFILE_SYS_ADMIN));
		Assert.isTrue(profiles.containsKey(SandboxRefresh_TestEnv.PROFILE_READ_ONLY));
		Assert.isFalse(profiles.containsKey('!BAD - ~ PROFILE += Name'));
	}

	@IsTest
	static void test_getNameToRoles() {
		SandboxRefreshUsers sru = new SandboxRefreshUsers();

		Map<String, Id> roles = sru.getNameToRoles();

		Assert.isFalse(roles.isEmpty());
		Assert.isTrue(roles.containsKey('Executives'));
		Assert.isFalse(roles.containsKey('!BAD - ~ ROLE += Name'));
	}

	@IsTest
	static void test_fixUserEmail() {
		SandboxRefresh_TestEnv env = new SandboxRefresh_TestEnv();

		SandboxRefreshUsers sru = new SandboxRefreshUsers();

		Assert.isTrue(sru.fixUserEmail(env.userOne), 'Email should be changed');
		Assert.isTrue(!env.userOne.Email.endsWith(SandboxRefreshUsers.USER_EMAIL_INVALID_EXTENSION), 'Email should not end in ".invalid"');

		Assert.isFalse(sru.fixUserEmail(env.userOne), 'Email should not be changed');
	}

	@IsTest
	static void test_fixUserProfile() {
		SandboxRefresh_TestEnv env = new SandboxRefresh_TestEnv();

		SandboxRefreshUsers sru = new SandboxRefreshUsers();

		sru.mapNameProfiles = new Map<String, Id>();
		sru.mapNameProfiles.put(SandboxRefresh_TestEnv.PROFILE_READ_ONLY, '001000000000000000');

		Assert.isTrue(sru.fixUserProfile(env.userOne, SandboxRefresh_TestEnv.PROFILE_READ_ONLY), 'Profile should be changed');
		Assert.isFalse(sru.fixUserProfile(env.userOne, null), 'Profile should not be changed');
		Assert.isFalse(sru.fixUserProfile(env.userOne, env.userOne.ProfileId), 'Profile should not be changed');
	}

	@IsTest
	static void test_fixUserRole() {
		SandboxRefresh_TestEnv env = new SandboxRefresh_TestEnv();

		SandboxRefreshUsers sru = new SandboxRefreshUsers();

		sru.mapNameRoles = new Map<String, Id>();
		sru.mapNameRoles.put('TEST ROLE', '001000000000000000');

		Assert.isTrue(sru.fixUserRole(env.userOne, 'TEST ROLE'), 'Role should be changed');
		Assert.isFalse(sru.fixUserRole(env.userOne, null), 'Role should not be changed');
		Assert.isFalse(sru.fixUserRole(env.userOne, null), 'Role should not be changed');
	}

	@IsTest
	static void test_updateUser() {
		SandboxRefresh_TestEnv env = new SandboxRefresh_TestEnv();

		Sandbox_Refresh_User__mdt rule = SandboxRefresh_TestEnv.makeRule(env.userInactive.Username, null, SandboxRefresh_TestEnv.PROFILE_READ_ONLY, 'TEST ROLE');

		SandboxRefreshUsers sru = new SandboxRefreshUsers();

		sru.mapNameProfiles = new Map<String, Id>();
		sru.mapNameProfiles.put(SandboxRefresh_TestEnv.PROFILE_READ_ONLY, '003000000000000000');

		sru.mapNameRoles = new Map<String, Id>();
		sru.mapNameRoles.put('TEST ROLE', '004000000000000000');

		Assert.isTrue(sru.updateUser(env.userOne, rule), 'Should have changed the user');

		Assert.isTrue(!env.userOne.Email.endsWith(SandboxRefreshUsers.USER_EMAIL_INVALID_EXTENSION), 'Email should not end in ".invalid"');

		Assert.areEqual('003000000000000000', String.valueOf(env.userOne.ProfileId), 'Profile should be changed');
		Assert.areEqual('004000000000000000', String.valueOf(env.userOne.UserRoleId), 'Role should be changed');
	}

	@IsTest
	static void test_activateUsers() {
		SandboxRefresh_TestEnv env = new SandboxRefresh_TestEnv();

		Sandbox_Refresh_User__mdt ruleOne = SandboxRefresh_TestEnv.makeRule(env.userOne.Username, null, SandboxRefresh_TestEnv.PROFILE_READ_ONLY, 'TEST ROLE');
		Sandbox_Refresh_User__mdt ruleTwo = SandboxRefresh_TestEnv.makeRule(env.userTwo.Username, null, SandboxRefresh_TestEnv.PROFILE_READ_ONLY, null);

		SandboxRefreshUsers sru = new SandboxRefreshUsers();

		sru.mapUserToRules = new Map<String, Sandbox_Refresh_User__mdt>();
		sru.mapUserToRules.put(env.userOne.Username.SubStringBeforeLast('.'), ruleOne);
		sru.mapUserToRules.put(env.userTwo.Username.SubStringBeforeLast('.'), ruleTwo);

		for (String name : sru.mapUserToRules.keySet()) {
			system.debug('name: ' + name);
		}

		sru.mapNameProfiles = new Map<String, Id>();
		sru.mapNameProfiles.put(SandboxRefresh_TestEnv.PROFILE_READ_ONLY, '003000000000000000');

		sru.mapNameRoles = new Map<String, Id>();
		sru.mapNameRoles.put('TEST ROLE', '004000000000000000');

		List<User> changedUsers = sru.activateUsers(new List<User>{env.userOne, env.userTwo});

		Assert.areEqual(2, changedUsers.size());
	}

	/**
	@IsTest
	static void test_updateUsers() {
		SandboxRefresh_TestEnv env = new SandboxRefresh_TestEnv();

		Sandbox_Refresh_User__mdt ruleOne = SandboxRefresh_TestEnv.makeRule(env.userOne.Username, null, SandboxRefresh_TestEnv.PROFILE_READ_ONLY, 'TEST ROLE');
		Sandbox_Refresh_User__mdt ruleTwo = SandboxRefresh_TestEnv.makeRule(env.userTwo.Username, null, SandboxRefresh_TestEnv.PROFILE_STANDARD_USER, null);

		SandboxRefreshUsers sru = new SandboxRefreshUsers();

		sru.mapNameProfiles = new Map<String, Id>();
		sru.mapNameProfiles.put(SandboxRefresh_TestEnv.PROFILE_READ_ONLY, '001000000000000000');
		sru.mapNameProfiles.put(SandboxRefresh_TestEnv.PROFILE_STANDARD_USER, '001000000000000001');

		sru.mapNameRoles = new Map<String, Id>();
		sru.mapNameRoles.put('TEST ROLE', '004000000000000000');

		sru.mapUserToRules = new Map<String, Sandbox_Refresh_User__mdt>();
		sru.mapUserToRules.put(env.userOne.Username.SubStringBeforeLast('.'), ruleOne);
		sru.mapUserToRules.put(env.userTwo.Username.SubStringBeforeLast('.'), ruleTwo);

		Test.startTest();

		List<User> updatedUsers = sru.updateUsers();

		Test.stopTest();

		Assert.areEqual(2, updatedUsers.size());

		User one = updatedUsers.get(0);
		Assert.isFalse(one.Email.endsWith('.invalid'));
		Assert.areEqual('001000000000000000', one.ProfileId, 'Wrong updated Profile Id');
		Assert.areEqual('004000000000000000', one.UserRoleId, 'Wrong updated Role Id');

		User two = updatedUsers.get(1);
		Assert.isFalse(two.Email.endsWith('.invalid'));
		Assert.areEqual('001000000000000001', two.ProfileId, 'Wrong updated Profile Id');
	}
	**/
}