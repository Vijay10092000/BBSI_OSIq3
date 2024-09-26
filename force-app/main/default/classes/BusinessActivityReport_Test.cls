/**
 * @description BusinessActivityReport_Test
 */
@IsTest
@SuppressWarnings('PMD.ApexAssertionsShouldIncludeMessage')
public without sharing class BusinessActivityReport_Test {
	@TestSetup
	static void makeData() {
		(new BusinessActivityReport_TestEnv()).createData();
	}

	@IsTest
	@SuppressWarnings('PMD.AvoidHardcodingId')
	static void test_buildReport() {
		BusinessActivityReport_TestEnv testEnv = new BusinessActivityReport_TestEnv();
		testEnv.loadData();

		Id idFakeUser = Id.valueOf('00550000003Zt4cAAC');
		List<Id> idBranches = new List<Id>{ testEnv.branchHome.Id, testEnv.branchOne.Id, testEnv.branchTwo.Id, testEnv.branchThree.Id };

		String textReport = (new BusinessActivityReport()).create(new List<String>{ idFakeUser }, idBranches, 2020, 2, false, false, false);
		textReport = textReport.deleteWhitespace();

		String expectedResult = '<?xmlversion="1.0"?><?mso-applicationprogid="Excel.Sheet"?><Workbookxmlns="urn:schemas-microsoft-com:office:spreadsheet"xmlns:o="urn:schemas-microsoft-com:office:office"xmlns:x="urn:schemas-microsoft-com:office:excel"xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"xmlns:html="http://www.w3.org/TR/REC-html40">';
		Assert.isTrue(textReport.startsWith(expectedResult), 'Start should match');
	}
}