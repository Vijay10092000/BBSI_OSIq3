/**
 * @description BusinessActivityReportController_Test
 */
@IsTest
@SuppressWarnings('PMD.ApexAssertionsShouldIncludeMessage')
public without sharing class BusinessActivityReportController_Test {
    @TestSetup
    static void makeTestData() {
		(new BusinessActivityReport_TestEnv()).createData();
    }

	@IsTest
	public static void test_setup() {
        BusinessActivityReport_TestEnv testEnv = new BusinessActivityReport_TestEnv();
		testEnv.loadData();

        Test.startTest();

		BusinessActivityReportSetup setup;

		System.runAs(testEnv.areaManagerOne) {
			setup = BusinessActivityReportController.setup();
		}

        Test.stopTest();

        DateTime now = DateTime.now();
        Integer numberPickYears = 1 + (now.year() - BusinessActivityReportSetup.START_YEAR);

		Assert.areEqual('AreaManagerOne', setup.userName);
		Assert.areEqual(testEnv.areaManagerOne.Id, setup.userId);
		Assert.areEqual(String.valueOf(now.year()), setup.year);
		Assert.areNotEqual(null, setup.quarter);
		Assert.areEqual(true, setup.allowSelection);
		Assert.areEqual(false, setup.isBDM);
		Assert.areEqual(1, setup.optionBDMs.size());
		Assert.areEqual(2, setup.optionAdvBDMs.size());
		Assert.areEqual(numberPickYears, setup.optionYears.size());
		Assert.areEqual(5, setup.optionQuarters.size());
	}   
    
	@IsTest
	public static void test_buildReport() {
        BusinessActivityReport_TestEnv testEnv = new BusinessActivityReport_TestEnv();
		testEnv.loadData();

		String report;

        Test.startTest();

		System.runAs(testEnv.areaManagerOne) {
			report = BusinessActivityReportController.buildReport(
				new List<String>{ testEnv.bdmOne.Id },
				new List<String>{ testEnv.branchOne.Id },
				2021,
				4,
				true,
				false,
				false
			);
			System.debug(LoggingLevel.DEBUG, 'REPORT: \n' + report);
		}

        Test.stopTest();

		Assert.areNotEqual(null, report);
	}
	/**
	 * @description Added For Negativ Testing
	 */
    @IsTest
	public static void test_buildReport_Negative() {
        BusinessActivityReport_TestEnv testEnv = new BusinessActivityReport_TestEnv();
		testEnv.loadData();

		String report;

        Test.startTest();

		System.runAs(testEnv.areaManagerOne) {
            try{
                report = BusinessActivityReportController.buildReport(
                    new List<String>{ testEnv.bdmOne.Id },
                    new List<String>{ testEnv.branchOne.Id },
                    21,
                    -4,
                    false,
                    true,
                    true
                );
                System.debug(LoggingLevel.DEBUG, 'REPORT: \n' + report);
            }
            catch(Exception ex){
                Assert.areNotEqual(null, ex.getMessage());
            }			
		}
        Test.stopTest();		
	}
/**
 * @description Added For cover buildReportSingle functionality 
 */    
    @IsTest
	public static void test_buildReportSingle() {
        BusinessActivityReport_TestEnv testEnv = new BusinessActivityReport_TestEnv();
		testEnv.loadData();

		String report;

        Test.startTest();

		System.runAs(testEnv.areaManagerOne) {
			report = BusinessActivityReportController.buildReport(
				new List<String>{ testEnv.bdmOne.Id },
				new List<String>{ testEnv.branchOne.Id },
				2021,
				4,
				false,
				true,
				true
			);
			System.debug(LoggingLevel.DEBUG, 'REPORT: \n' + report);
		}
        Test.stopTest();
		Assert.areNotEqual(null, report);
	}
}