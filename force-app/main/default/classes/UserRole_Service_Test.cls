@IsTest
public with sharing class UserRole_Service_Test {
	@TestSetup
	static void createTestData() {
		// TOP LEVEL
		UserRole role1 = TestFactoryUserRole.makeUserRole('Role 1', 'Role_1');
		UserRole role2 = TestFactoryUserRole.makeUserRole('Role 2', 'Role_2');
		insert new List<UserRole>{ role1, role2 };

		// SECOND LEVEL
		UserRole role11 = TestFactoryUserRole.makeUserRole('Role 1 1', role1.Id, 'Role_1_1');
		UserRole role12 = TestFactoryUserRole.makeUserRole('Role 1 2', role1.Id, 'Role_1_2');
		UserRole role21 = TestFactoryUserRole.makeUserRole('Role 2 1', role2.Id, 'Role_2_1');
		insert new List<UserRole>{ role11, role12, role21 };

		// FINAL LEVEL
		UserRole role111 = TestFactoryUserRole.makeUserRole('Role 1 1 1', role11.Id, 'Role_1_1_1');
		insert new List<UserRole>{ role111 };
	}

	@IsTest
	public static void test_getById() {
		Id idRole11 = [SELECT Id FROM UserRole WHERE Name = 'Role 1 1'].Id;
		Id idRole21 = [SELECT Id FROM UserRole WHERE Name = 'Role 2 1'].Id;

		Test.startTest();

		UserRole role11 = UserRole_Service.getById(idRole11);
		UserRole role21 = UserRole_Service.getById(idRole21);
		UserRole roleNull = UserRole_Service.getById(null);

		Test.stopTest();

		Assert.areNotEqual(null, role11, 'Role11 should exist');
		Assert.areNotEqual(null, role21, 'Role21 should exist');
		Assert.areEqual(null, roleNull, 'null should not exist');
	}

	@IsTest
	public static void test_getByName() {
		Test.startTest();

		UserRole role11 = UserRole_Service.getByName('Role 1 1');
		UserRole role21 = UserRole_Service.getByName('Role 2 1');
		UserRole roleNull = UserRole_Service.getByName(null);

		Test.stopTest();

		Assert.areEqual('Role 1 1', role11.Name, 'Role11 should exist');
		Assert.areEqual('Role 2 1', role21.Name, 'Role21 should exist');
		Assert.areEqual(null, roleNull, 'null should not exist');
	}

	@IsTest
	public static void test_getByDevelperName() {
		Test.startTest();

		UserRole role11 = UserRole_Service.getByDeveloperName('Role_1_1');
		UserRole role21 = UserRole_Service.getByDeveloperName('Role_2_1');
		UserRole roleNull = UserRole_Service.getByDeveloperName(null);

		Test.stopTest();

		Assert.areEqual('Role_1_1', role11.DeveloperName, 'Role11 should exist');
		Assert.areEqual('Role_2_1', role21.DeveloperName, 'Role21 should exist');
		Assert.areEqual(null, roleNull, 'null should not exist');
	}

	@IsTest
	public static void test_contains() {
		Id idRole1 = [SELECT Id FROM UserRole WHERE Name = 'Role 1'].Id;
		Id idRole11 = [SELECT Id FROM UserRole WHERE Name = 'Role 1 1'].Id;
		Id idRole111 = [SELECT Id FROM UserRole WHERE Name = 'Role 1 1 1'].Id;
		Id idRole2 = [SELECT Id FROM UserRole WHERE Name = 'Role 2'].Id;
		Id idRole21 = [SELECT Id FROM UserRole WHERE Name = 'Role 2 1'].Id;

		System.assert(UserRole_Service.contains(idRole1, idRole1, true), 'Role1 has itself');
		System.assert(!UserRole_Service.contains(idRole1, idRole1, false), 'Role1 does not have itself');
		System.assert(UserRole_Service.contains(idRole1, idRole11, true), 'Role1 should have Role11');
		System.assert(UserRole_Service.contains(idRole1, idRole111, true), 'Role1 should have Role111');
		System.assert(UserRole_Service.contains(idRole2, idRole21, true), 'Role2 should have Role21');
		System.assert(!UserRole_Service.contains(idRole1, idRole21, true), 'Role1 should not have Role21');
		System.assert(!UserRole_Service.contains(idRole1, null, true), 'Role1 should not have null');
		System.assert(!UserRole_Service.contains(null, idRole1, true), 'null should not have nothing');
	}

	@IsTest
	public static void test_getUserRoleHeirarchy() {
		Id idRole1 = [SELECT Id FROM UserRole WHERE Name = 'Role 1'].Id;
		Id idRole2 = [SELECT Id FROM UserRole WHERE Name = 'Role 2'].Id;

		Test.startTest();

		Set<UserRole> roles1 = UserRole_Service.getUserRoleHeirarchy(idRole1, true);
		Set<UserRole> roles1ChildrenOnly = UserRole_Service.getUserRoleHeirarchy(idRole1, false);

		Set<UserRole> roles2 = UserRole_Service.getUserRoleHeirarchy(idRole2, true);
		Set<UserRole> roles2ChildrenOnly = UserRole_Service.getUserRoleHeirarchy(idRole2, false);

		Test.stopTest();

		Assert.areEqual(4, roles1.size(), 'Role1 has 4 roles below it, plus itself');
		Assert.areEqual(3, roles1ChildrenOnly.size(), 'Role1 has 4 roles below it');

		Assert.areEqual(2, roles2.size(), 'Role2 has 1 roles below it, plus itself');
		Assert.areEqual(1, roles2ChildrenOnly.size(), 'Role2 has 1 role below it');
	}

	@IsTest
	public static void test_getUserRoleHeirarchyIds() {
		Id idRole1 = [SELECT Id FROM UserRole WHERE Name = 'Role 1'].Id;
		Id idRole2 = [SELECT Id FROM UserRole WHERE Name = 'Role 2'].Id;

		Test.startTest();

		Set<Id> roles1 = UserRole_Service.getUserRoleHeirarcyIds(idRole1, true);
		Set<Id> roles1ChildrenOnly = UserRole_Service.getUserRoleHeirarcyIds(idRole1, false);

		Set<Id> roles2 = UserRole_Service.getUserRoleHeirarcyIds(idRole2, true);
		Set<Id> roles2ChildrenOnly = UserRole_Service.getUserRoleHeirarcyIds(idRole2, false);

		Test.stopTest();

		Assert.areEqual(4, roles1.size(), 'Role_1 has 4 roles below it, plus itself');
		Assert.areEqual(3, roles1ChildrenOnly.size(), 'Role_1 has 4 roles below it');

		Assert.areEqual(2, roles2.size(), 'Role_2 has 1 roles below it, plus itself');
		Assert.areEqual(1, roles2ChildrenOnly.size(), 'Role_2 has 1 role below it');
	}
}