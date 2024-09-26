/**
 * @description LdfModel_Test contains tests for the LdfModel class.
 */
@IsTest
@SuppressWarnings('PMD.ApexAssertionsShouldIncludeMessage')
public without sharing class LdfModel_Test {
	@TestSetup
	static void makeData() {
       insert new List<LDF_Rate__c> {
            TestFactoryLDFRate.makeLDFRate(12,1.91,1.90, null),
            TestFactoryLDFRate.makeLDFRate(13,1.91,1.90, null),
            TestFactoryLDFRate.makeLDFRate(14,1.81,1.80, null),
            TestFactoryLDFRate.makeLDFRate(15,1.81,1.80, null),
            TestFactoryLDFRate.makeLDFRate(16,1.71,1.70, null),
            TestFactoryLDFRate.makeLDFRate(17,1.71,1.70, null),
            TestFactoryLDFRate.makeLDFRate(18,1.61,1.60, null),
            TestFactoryLDFRate.makeLDFRate(19,1.51,1.50, null),
            TestFactoryLDFRate.makeLDFRate(20,1.41,1.40, null),
            TestFactoryLDFRate.makeLDFRate(21,1.31,1.30, null)
        };        
	}

	@IsTest
	public static void test_fixNumberMonth() {
		Assert.areEqual(LdfModel.MONTHS_MAXINUM, LdfModel.fixNumberMonth(-200), 'Must change to absolute value and set maximum');
		Assert.areEqual(100, LdfModel.fixNumberMonth(-100), 'Must change to absolute value');
		Assert.areEqual(LdfModel.MONTHS_MININUM, LdfModel.fixNumberMonth(11), 'Must change to absolute value');
		Assert.areEqual(12, LdfModel.fixNumberMonth(12), 'Must set correctly');
		Assert.areEqual(13, LdfModel.fixNumberMonth(13), 'Must set correctly');
		Assert.areEqual(54, LdfModel.fixNumberMonth(54), 'Must set correctly');
		Assert.areEqual(189, LdfModel.fixNumberMonth(189), 'Must set correctly');
		Assert.areEqual(190, LdfModel.fixNumberMonth(190), 'Must set correctly');
		Assert.areEqual(LdfModel.MONTHS_MAXINUM, LdfModel.fixNumberMonth(191), 'Must set to maximum');
		Assert.areEqual(LdfModel.MONTHS_MAXINUM, LdfModel.fixNumberMonth(430), 'Must set to maximum');
	}

	@IsTest
	public static void test_loadData() {
		LdfModel.loadData();

		Assert.isTrue(0 < LdfModel.mapLdfRates.size(), 'Must have Base LDF data');
		Assert.isTrue(0 < LdfModel.mapLdfRates.get('AOS').size(), 'Must have Base LDF data for AOS');
		Assert.isTrue(0 < LdfModel.mapLdfRates.get('CA').size(), 'Must have Base LDF data for CA');
	}

	@IsTest
	public static void test_getLdfRate_PeriodEndDate() {
		Date date6 = Date.today().addMonths(6);
		Date date14 = Date.today().addMonths(14);
		Date date26 = Date.today().addMonths(26);
		Date date28 = Date.today().addMonths(28);

		Assert.areEqual(1.91, LdfModel.getLdfRate('CA', date6));
		Assert.areEqual(1.90, LdfModel.getLdfRate('AZ', date6));

		Assert.areEqual(1.91, LdfModel.getLdfRate('CA', date14));
		Assert.areEqual(1.90, LdfModel.getLdfRate('AZ', date14));

		Assert.areEqual(1.81, LdfModel.getLdfRate('CA', date26));
		Assert.areEqual(1.80, LdfModel.getLdfRate('AZ', date26));

		Assert.areEqual(1.71, LdfModel.getLdfRate('CA', date28));
		Assert.areEqual(1.70, LdfModel.getLdfRate('AZ', date28));
	}

	@IsTest
	public static void test_getLdfRate_Months() {
		Assert.areEqual(1.91, LdfModel.getLdfRate('CA', 8));
		Assert.areEqual(1.90, LdfModel.getLdfRate('AZ', 8));

		Assert.areEqual(1.71, LdfModel.getLdfRate('CA', 17));
		Assert.areEqual(1.70, LdfModel.getLdfRate('AZ', 17));
	}

	@IsTest
	public static void test_validations() {
		List<Database.SaveResult> listSaves = Database.Insert(
			new List<LDF_Rate__c> {
				TestFactoryLDFRate.makeLDFRate(100, 1.31, 1.30,null),
				TestFactoryLDFRate.makeLDFRate(300, 1.31, 1.30,null), // Bad Month
				TestFactoryLDFRate.makeLDFRate(13, 1.31, 7.30,null), // Duplicate Month
				TestFactoryLDFRate.makeLDFRate(101, -1.31, 1.30,null), // Bad CA
				TestFactoryLDFRate.makeLDFRate(102, 1.31, 7.30,null), // Bad OSA
				TestFactoryLDFRate.makeLDFRate(103, 1.21, 1.20,null)
			},
			false
		);

		Assert.areEqual(true, listSaves.get(0).isSuccess(), 'LDF Rate is valid');
		Assert.areEqual(false, listSaves.get(1).isSuccess(), 'LDF Rate has bad month');
		Assert.areEqual(false, listSaves.get(2).isSuccess(), 'LDF Rate with given month already exists');
		Assert.areEqual(false, listSaves.get(3).isSuccess(), 'LDF Rate California is negative');
		Assert.areEqual(false, listSaves.get(4).isSuccess(), 'LDF Rate AOS is too high');
		Assert.areEqual(true, listSaves.get(5).isSuccess(), 'LDF Rate is valid');
	}
}