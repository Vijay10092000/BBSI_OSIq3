/**
 * @description UserBdms_Test contains tests for the class UserBdms.
 */
@IsTest
public without sharing class UserBdms_Test {
	@IsTest
	public static void test_getAllReportBdms() {
		TestFactoryAccount.createBranch('TEST BRANCH', 'TEST', null, null);

		User bdm1 = TestFactoryUser.makeBDM('Bdm1', 'bdm1', 'BBSI Standard', 'TEST');
		bdm1.Business_Activity_Report_BDM__c = true;

		User bdm2 = TestFactoryUser.makeBDM('Bdm2', 'bdm2', 'BBSI Standard', 'TEST');
		bdm2.Business_Activity_Report_BDM__c = false;

		User bdm3 = TestFactoryUser.makeBDM('Bdm3', 'bdm3', 'BBSI Standard', 'TEST');
		bdm3.Business_Activity_Report_BDM__c = true;
		bdm3.IsActive = false;

		User user1 = TestFactoryUser.makeUser(null, 'User1', 'BBSI Standard', 'TEST');
		user1.Business_Activity_Report_BDM__c = true;

		User user2 = TestFactoryUser.makeUser(null, 'User2', 'BBSI Standard', 'TEST');
		user2.Business_Activity_Report_BDM__c = false;

		User user3 = TestFactoryUser.makeUser(null, 'User3', 'BBSI Standard', 'TEST');
		user3.Business_Activity_Report_BDM__c = true;
		user3.IsActive = false;

		insert new List<User>{ bdm1, bdm2, bdm3, user1, user2, user3 };

		Map<Id, User> activeOnly;
		Map<Id, User> all;

		Test.startTest();

		activeOnly = UserBdms.getAllReportBdms(true);
		all = UserBdms.getAllReportBdms(false);

		Test.stopTest();

		Set<Id> setActiveOnlyIds = activeOnly.keySet();
		Assert.areEqual(true, setActiveOnlyIds.contains(bdm1.Id), 'Bdm1 is active and has report flag set');
		Assert.areEqual(false, setActiveOnlyIds.contains(bdm2.Id), 'Bdm2 is active, but report flag is not set');
		Assert.areEqual(false, setActiveOnlyIds.contains(bdm3.Id), 'Bdm3 not active and has report flag set');
		Assert.areEqual(true, setActiveOnlyIds.contains(user1.Id), 'User1 is active and has report flag set');
		Assert.areEqual(false, setActiveOnlyIds.contains(user2.Id), 'User2 is active, but report flag is not set');
		Assert.areEqual(false, setActiveOnlyIds.contains(user3.Id), 'User3 not active and has report flag set');

		Set<Id> setAllIds = all.keySet();
		Assert.areEqual(true, setAllIds.contains(bdm1.Id), 'Bdm1 has report flag set');
		Assert.areEqual(false, setAllIds.contains(bdm2.Id), 'Bdm2 has report flag not set');
		Assert.areEqual(true, setAllIds.contains(bdm3.Id), 'Bdm3 has report flag set');
		Assert.areEqual(true, setAllIds.contains(user1.Id), 'User1 has report flag set');
		Assert.areEqual(false, setAllIds.contains(user2.Id), 'User2 has report flag not set');
		Assert.areEqual(true, setAllIds.contains(user3.Id), 'User3 has report flag set');
	}
}