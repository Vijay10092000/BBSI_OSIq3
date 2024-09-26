/**
 * @description BusinessActivityReportSetup_Test contains tests for BusinessActivityReportSetup.
 */
@IsTest
@SuppressWarnings('PMD.ApexAssertionsShouldIncludeMessage')
public without sharing class BusinessActivityReportSetup_Test {
	@TestSetup
	static void makeTestData() {
		(new BusinessActivityReport_TestEnv()).createData();
	}

	@IsTest
	public static void test_AreaManager() {
		BusinessActivityReport_TestEnv testEnv = new BusinessActivityReport_TestEnv();
		testEnv.loadData();

		Test.startTest();

		BusinessActivityReportSetup setup;
		System.runAs(testEnv.areaManagerOne) {
			setup = new BusinessActivityReportSetup();
			setup.readData();
		}

		Test.stopTest();

		DateTime now = DateTime.now();
		Integer numberPickYears = 1 + (now.year() - BusinessActivityReportSetup.START_YEAR);

		Assert.areEqual('AreaManagerOne', setup.userName);
		Assert.areEqual(testEnv.areaManagerOne.Id, setup.userId);
		Assert.areEqual(String.valueOf(now.year()), setup.year);
		Assert.areNotEqual(null, setup.quarter);
		Assert.areEqual(testEnv.areaManagerOne.Id, setup.userId);
		Assert.areEqual(true, setup.allowSelection);
		Assert.areEqual(false, setup.isBDM);
		Assert.areEqual(1, setup.optionBDMs.size());
		Assert.areEqual(2, setup.optionAdvBDMs.size());
		Assert.areEqual(numberPickYears, setup.optionYears.size());
		Assert.areEqual(5, setup.optionQuarters.size());
	}

	@IsTest
	public static void test_PermissionSet() {
		BusinessActivityReport_TestEnv testEnv = new BusinessActivityReport_TestEnv();
		testEnv.loadData();

		Test.startTest();

		BusinessActivityReportSetup setup;
		System.runAs(testEnv.userReportManager) {
			setup = new BusinessActivityReportSetup();
			setup.readData();
		}

		Test.stopTest();

		DateTime now = DateTime.now();
		Integer numberPickYears = 1 + (now.year() - BusinessActivityReportSetup.START_YEAR);

		Assert.areEqual('userReportManager', setup.userName);
		Assert.areEqual(testEnv.userReportManager.Id, setup.userId);
		Assert.areEqual(String.valueOf(now.year()), setup.year);
		Assert.areNotEqual(null, setup.quarter);
		Assert.areEqual(true, setup.allowSelection);
		Assert.areEqual(false, setup.isBDM);
		Assert.areEqual(numberPickYears, setup.optionYears.size());
		Assert.areEqual(5, setup.optionQuarters.size());
	}

	@IsTest
	public static void test_BDM() {
		BusinessActivityReport_TestEnv testEnv = new BusinessActivityReport_TestEnv();
		testEnv.loadData();

		Test.startTest();

		BusinessActivityReportSetup setup;
		System.runAs(testEnv.bdmTwo) {
			setup = new BusinessActivityReportSetup();
			setup.readData();
		}

		Test.stopTest();

		DateTime now = DateTime.now();
		Integer numberPickYears = 1 + (now.year() - BusinessActivityReportSetup.START_YEAR);

		Assert.areEqual('Bdm2', setup.userName);
		Assert.areEqual(testEnv.bdmTwo.Id, setup.userId);
		Assert.areEqual(String.valueOf(now.year()), setup.year);
		Assert.areNotEqual(null, setup.quarter);
		Assert.areEqual(false, setup.allowSelection);
		Assert.areEqual(true, setup.isBDM);
		Assert.areEqual(1, setup.optionBDMs.size());
		Assert.areEqual(numberPickYears, setup.optionYears.size());
		Assert.areEqual(5, setup.optionQuarters.size());
	}

	@IsTest
	public static void test_ReportManager() {
		BusinessActivityReport_TestEnv testEnv = new BusinessActivityReport_TestEnv();
		testEnv.loadData();

		Test.startTest();

		BusinessActivityReportSetup setup;
		System.runAs(testEnv.userReportManager) {
			setup = new BusinessActivityReportSetup();
			setup.readData();
		}

		Test.stopTest();

		DateTime now = DateTime.now();
		Integer numberPickYears = 1 + (now.year() - BusinessActivityReportSetup.START_YEAR);

		Assert.areEqual('userReportManager', setup.userName);
		Assert.areEqual(testEnv.userReportManager.Id, setup.userId);
		Assert.areEqual(String.valueOf(now.year()), setup.year);
		Assert.areNotEqual(null, setup.quarter);
		Assert.areEqual(true, setup.allowSelection);
		Assert.areEqual(false, setup.isBDM);
		Assert.areEqual(numberPickYears, setup.optionYears.size());
		Assert.areEqual(5, setup.optionQuarters.size());
	}

	@IsTest
	public static void test_Other() {
		BusinessActivityReport_TestEnv testEnv = new BusinessActivityReport_TestEnv();
		testEnv.loadData();

		Test.startTest();

		BusinessActivityReportSetup setup;
		System.runAs(testEnv.userOther) {
			setup = new BusinessActivityReportSetup();
			setup.readData();
		}

		Test.stopTest();

		DateTime now = DateTime.now();
		Integer numberPickYears = 1 + (now.year() - BusinessActivityReportSetup.START_YEAR);

		Assert.areEqual('', setup.userName);
		Assert.areEqual('', setup.userId);
		Assert.areEqual(String.valueOf(now.year()), setup.year);
		Assert.areNotEqual(null, setup.quarter);
		Assert.areEqual(false, setup.allowSelection);
		Assert.areEqual(false, setup.isBDM);
		Assert.areEqual(0, setup.optionBDMs.size());
		Assert.areEqual(numberPickYears, setup.optionYears.size());
		Assert.areEqual(5, setup.optionQuarters.size());
	}

	@IsTest
	public static void test_getAllBdms() {
		BusinessActivityReportSetup setup = new BusinessActivityReportSetup();
		Map<String, String> allBdms = setup.getAllBdms();

		for (String key : allBdms.keySet()) {
			Assert.areNotEqual(null, allBdms.get(key));
		}
	}
}