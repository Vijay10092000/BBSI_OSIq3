/**
 * @description BusinessActivityReportData_Test contains test for the class BusinessActivityReportData.
 */
@IsTest
@SuppressWarnings('PMD.ApexAssertionsShouldIncludeMessage, PMD.AvoidSystemDebugUsage, PMD.ApexDoc')
public without sharing class BusinessActivityReportData_Test {
	@TestSetup
	static void makeTestData() {
		(new BusinessActivityReport_TestEnv()).createData();
	}

	@IsTest
	static void test_ActivityData() {
		Date dateStart = Date.newInstance(2021, 10, 9);
		Date dateEnd = Date.newInstance(2021, 10, 3);
		Integer week = 2;

		BusinessActivityReportData.ActivityData activityData = new BusinessActivityReportData.ActivityData(
			dateStart,
			dateEnd,
			week
		);

		Assert.areEqual(dateEnd, activityData.dateStart);
		Assert.areEqual(dateStart, activityData.dateEnd);
		Assert.areEqual(week, activityData.week);
		Assert.areEqual(0, activityData.newLeads);
		Assert.areEqual(0, activityData.discoveryMeetings);
		Assert.areEqual(0, activityData.newClients);
		Assert.areEqual(0, activityData.rpTouchesInPerson);
		Assert.areEqual(0, activityData.rpTouchesVirtual);
		Assert.areEqual(0, activityData.producerTracks);
		Assert.areEqual(0, activityData.newRPs);
		Assert.areEqual(0, activityData.numberEvents);
		Assert.areEqual(0, activityData.rpPlans);
		Assert.areEqual(0, activityData.numberLostClients);
		Assert.areEqual(0, activityData.numberLostLeads);
		Assert.areEqual(0, activityData.numberAddedWSE);
	}

	@IsTest
	static void test_setReportBuilderInfo() {
		BusinessActivityReport_TestEnv testEnv = new BusinessActivityReport_TestEnv();
		testEnv.loadData();

		BusinessActivityReportData reportData = new BusinessActivityReportData();

		System.runAs(testEnv.userReportManager) {
			reportData.creatorName = testEnv.userReportManager.Name;
			reportData.creatorId = testEnv.userReportManager.Id;
			reportData.creatorProfileId = testEnv.userReportManager.ProfileId;
			reportData.setReportBuilderInfo(false, false, false);

			Assert.areEqual(true, reportData.isCreatorReportManager);
			Assert.areEqual(false, reportData.isCreatorAreaManager);
		}

		System.runAs(testEnv.areaManagerOne) {
			reportData.creatorName = testEnv.areaManagerOne.Name;
			reportData.creatorId = testEnv.areaManagerOne.Id;
			reportData.creatorProfileId = testEnv.areaManagerOne.ProfileId;
			reportData.setReportBuilderInfo(false, false, false);

			Assert.areEqual(false, reportData.isCreatorReportManager);
			Assert.areEqual(true, reportData.isCreatorAreaManager);
		}

		System.runAs(testEnv.bdmOne) {
			reportData.creatorName = testEnv.bdmOne.Name;
			reportData.creatorId = testEnv.bdmOne.Id;
			reportData.creatorProfileId = testEnv.bdmOne.ProfileId;
			reportData.setReportBuilderInfo(false, false, false);

			Assert.areEqual(false, reportData.isCreatorReportManager);
			Assert.areEqual(false, reportData.isCreatorAreaManager);
		}
	}

	@IsTest
	static void test_setRange() {
		BusinessActivityReportData reportData = new BusinessActivityReportData();

		Date today = Date.today();
		reportData.setRange(null, null);
		Assert.areEqual(today.year(), reportData.bQuarter.year);
		Assert.areNotEqual(null, reportData.bQuarter.quarter);
		Assert.areNotEqual(null, reportData.dtQuarterFirstDay);
		Assert.areNotEqual(null, reportData.dtQuarterLastDay);

		reportData.setRange(2020, 1);
		Assert.areEqual(2020, reportData.bQuarter.year);
		Assert.areEqual(1, reportData.bQuarter.quarter);
		Assert.areEqual(1, reportData.dtQuarterFirstDay.month());
		Assert.areEqual(1, reportData.dtQuarterFirstDay.day());
		Assert.areEqual(3, reportData.dtQuarterLastDay.month());
		Assert.areEqual(31, reportData.dtQuarterLastDay.day());

		reportData.setRange(2020, 0);
		Assert.areEqual(2020, reportData.bQuarter.year);
		Assert.areEqual(0, reportData.bQuarter.quarter);
		Assert.areEqual(1, reportData.dtQuarterFirstDay.month());
		Assert.areEqual(1, reportData.dtQuarterFirstDay.day());
		Assert.areEqual(12, reportData.dtQuarterLastDay.month());
		Assert.areEqual(31, reportData.dtQuarterLastDay.day());
	}

	@IsTest
	static void test_setBdmInfo() {
		BusinessActivityReport_TestEnv testEnv = new BusinessActivityReport_TestEnv();
		testEnv.loadData();

		BusinessActivityReportData reportData = new BusinessActivityReportData();

		System.runAs(testEnv.userReportManager) {
			reportData.setUserInfo(new List<String>{ UserInfo.getUserId() });

			Assert.areEqual(1, reportData.reportUsersInfo.size());
			Assert.isTrue(reportData.reportUsersInfo.containsKey(UserInfo.getUserId()));
			Assert.areEqual(UserInfo.getName(), reportData.reportUsersInfo.get(UserInfo.getUserId()));

			reportData.setUserInfo(new List<String>{ testEnv.bdmOne.Id });

			Assert.areEqual(1, reportData.reportUsersInfo.size());
			Assert.isTrue(reportData.reportUsersInfo.containsKey(testEnv.bdmOne.Id));
			Assert.areEqual(testEnv.bdmOne.Name, reportData.reportUsersInfo.get(testEnv.bdmOne.Id));
		}
	}

	@IsTest
	static void test_readNewLeads_BDM() {
		BusinessActivityReport_TestEnv testEnv = new BusinessActivityReport_TestEnv();
		testEnv.loadData();

		testEnv.leadClient3_1.OwnerId = testEnv.bdmOne.Id;
		testEnv.leadClient3_1.Business_Development_Manager__c = testEnv.bdmOne.Id;
		update testEnv.leadClient3_1;

		Date today = Date.today();
		Integer quarter = BusinessQuarter.getQuarter(today);
		Integer week = BusinessQuarter.getWeek(today, false);

		BusinessActivityReportData builder;

		Test.startTest();

		System.runAs(testEnv.bdmOne) {
			builder = new BusinessActivityReportData();
			builder.setReportBuilderInfo(false, false, false);
			builder.readAllBranches();
			builder.setRange(today.year(), quarter);
			builder.setUserInfo(new List<String>{ testEnv.bdmOne.Id });
			builder.createActivityData();

			builder.readNewLeads();
		}

		Test.stopTest();

		Assert.areEqual(4, builder.activityData.get(week).newLeads);
		Assert.areEqual(1, builder.activityData.get(week).newRPs);
	}

	@IsTest
	static void test_readNewLeads_AM() {
		BusinessActivityReport_TestEnv testEnv = new BusinessActivityReport_TestEnv();
		testEnv.loadData();

		testEnv.leadClient3_1.OwnerId = testEnv.bdmOne.Id;
		testEnv.leadClient3_1.Business_Development_Manager__c = testEnv.bdmOne.Id;
		update testEnv.leadClient3_1;

		Date today = Date.today();
		Integer quarter = BusinessQuarter.getQuarter(today);
		Integer week = BusinessQuarter.getWeek(today, false);

		BusinessActivityReportData builder;

		Test.startTest();

		System.runAs(testEnv.areaManagerOne) {
			builder = new BusinessActivityReportData();
			builder.setReportBuilderInfo(false, false, false);
			builder.readAmBranches();
			builder.setRange(today.year(), quarter);
			builder.setUserInfo(new List<String>{ testEnv.bdmOne.Id });
			builder.createActivityData();

			builder.readNewLeads();
		}

		Test.stopTest();

		Assert.areEqual(3, builder.activityData.get(week).newLeads);
		Assert.areEqual(1, builder.activityData.get(week).newRPs);
	}

	@IsTest
	static void test_readNewClients_BDM() {
		BusinessActivityReport_TestEnv testEnv = new BusinessActivityReport_TestEnv();
		testEnv.loadData();

		testEnv.accountClient3_1.OwnerId = testEnv.bdmOne.Id;
		testEnv.accountClient3_1.Business_Development_Manager__c = testEnv.bdmOne.Id;
		update testEnv.accountClient3_1;

		Date today = Date.today();
		Integer quarter = BusinessQuarter.getQuarter(today);
		Integer week = BusinessQuarter.getWeek(today, false);

		BusinessActivityReportData builder;

		Test.startTest();

		System.runAs(testEnv.bdmOne) {
			builder = new BusinessActivityReportData();
			builder.setReportBuilderInfo(false, false, false);
			builder.readAllBranches();
			builder.setRange(today.year(), quarter);
			builder.setUserInfo(new List<String>{ testEnv.bdmOne.Id });
			builder.createActivityData();

			builder.readNewClients();
		}

		Test.stopTest();

		Assert.areEqual(4, builder.activityData.get(week).newClients);
	}

	@IsTest
	static void test_readNewClients_AM() {
		BusinessActivityReport_TestEnv testEnv = new BusinessActivityReport_TestEnv();
		testEnv.loadData();

		testEnv.accountClient3_1.OwnerId = testEnv.bdmOne.Id;
		testEnv.accountClient3_1.Business_Development_Manager__c = testEnv.bdmOne.Id;
		update testEnv.accountClient3_1;

		Date today = Date.today();
		Integer quarter = BusinessQuarter.getQuarter(today);
		Integer week = BusinessQuarter.getWeek(today, false);

		BusinessActivityReportData builder;

		Test.startTest();

		System.runAs(testEnv.areaManagerOne) {
			builder = new BusinessActivityReportData();
			builder.setReportBuilderInfo(false, false, false);
			builder.readAmBranches();
			builder.setRange(today.year(), quarter);
			builder.setUserInfo(new List<String>{ testEnv.bdmOne.Id });
			builder.createActivityData();

			builder.readNewClients();
		}

		Test.stopTest();

		Assert.areEqual(2, builder.activityData.get(week).newClients);
	}

	@IsTest
	public static void test_readAmBranches() {
		BusinessActivityReport_TestEnv testEnv = new BusinessActivityReport_TestEnv();
		testEnv.loadData();

		BusinessActivityReportData builder;
		builder = new BusinessActivityReportData();

		builder.creatorId = testEnv.areaManagerOne.Id;
		builder.readAmBranches();
		Assert.areEqual(1, builder.workingBranches.size(), 'Should have 1');
		Assert.isTrue(builder.workingBranches.containsKey(testEnv.branchOne.Id));

		builder.creatorId = testEnv.areaManagerTwo.Id;
		builder.readAmBranches();
		Assert.areEqual(1, builder.workingBranches.size(), 'Should have 1');
		Assert.isTrue(builder.workingBranches.containsKey(testEnv.branchTwo.Id));
	}

	@IsTest
	public static void test_readAllBranches() {
		BusinessActivityReport_TestEnv testEnv = new BusinessActivityReport_TestEnv();
		testEnv.loadData();

		BusinessActivityReportData builder;
		builder = new BusinessActivityReportData();

		Test.startTest();

		builder.readAllBranches();

		Test.stopTest();

		Assert.areEqual(4, builder.workingBranches.size(), 'Should have ALL');
	}


	@IsTest
	public static void test_readData() {
		BusinessActivityReport_TestEnv testEnv = new BusinessActivityReport_TestEnv();
		testEnv.loadData();

		BusinessActivityReportData builder;
		builder = new BusinessActivityReportData();

		Test.startTest();

		Date today = Date.today();
		Integer quarter = BusinessQuarter.getQuarter(today);
		builder.readData(
			new List<String>{ testEnv.bdmOne.Id }, 
			new List<String>{ testEnv.branchOne.Id },
			today.year(), quarter,
			false, false, false
		);

		builder.readData(
			new List<String>{ testEnv.bdmOne.Id }, 
			new List<String>{ testEnv.branchOne.Id },
			today.year(), quarter,
			true, false, false
		);

		builder.readData(
			new List<String>{ testEnv.bdmOne.Id }, 
			new List<String>{ testEnv.branchOne.Id },
			today.year(), quarter,
			false, true, false
		);

		builder.readData(
			new List<String>{ testEnv.bdmOne.Id }, 
			new List<String>{ testEnv.branchOne.Id },
			today.year(), quarter,
			false, false, true
		);

		Test.stopTest();

		Assert.areEqual(1, builder.workingBranches.size(), 'Should have only 1');
	}
    
/***
	@IsTest
	public static void test_readGivenBranches() {
		BusinessActivityReport_TestEnv testEnv = new BusinessActivityReport_TestEnv();
		testEnv.loadData();

		BusinessActivityReportData builder;
		builder = new BusinessActivityReportData();

		Test.startTest();

		List<String> idBranches = new List<String>{
			String.valueOf(testEnv.branchHome.Id),
			String.valueOf(testEnv.branchOne.Id)
		};

		builder.readGivenBranches(idBranches);

		Test.stopTest();

		Assert.areEqual(2, builder.workingBranches.size(), 'Should have Home and One');
		Assert.isTrue(builder.workingBranches.containsKey(testEnv.branchHome.Id));
		Assert.isTrue(builder.workingBranches.containsKey(testEnv.branchOne.Id));
	}
***/

	@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
	@IsTest
	public static void test_dumpData() {
		BusinessActivityReportData builder;
		builder = new BusinessActivityReportData();

		builder.workingBranches = new Map<Id, Account>();
		builder.reportUsersInfo = new Map<Id, String>();
		builder.bQuarter = new BusinessQuarter(Date.today());

		builder.dumpData();

		// No asserts needed - method dumps to System Debug
	}
    /**
	 * @description Added For Negativ Testing
	 */
    @IsTest
    static void test_NegativTest() {
        Date dateStart = Date.newInstance(2021, 10, 9);
		Date dateEnd = Date.newInstance(2021, 10, 3);
		Integer week = 2;

		BusinessActivityReportData.ActivityData activityData = new BusinessActivityReportData.ActivityData(
			dateEnd,
			dateStart,
			week
		);
    }
}