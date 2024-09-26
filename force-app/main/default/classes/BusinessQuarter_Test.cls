/**
 * @description BusinessQuarter_Test
 */
@SuppressWarnings('PMD.ApexAssertionsShouldIncludeMessage')
@IsTest
public without sharing class BusinessQuarter_Test {
	@IsTest
	public static void test_constructor() {
		BusinessQuarter bq1 = new BusinessQuarter(Date.newInstance(2021, 2, 11));
		Assert.areEqual(1, bq1.quarter);
		Assert.areEqual(2021, bq1.year);
		Assert.areEqual(Date.newInstance(2021, 1, 1), bq1.dateRange.dateFrom);
		Assert.areEqual(Date.newInstance(2021, 3, 31), bq1.dateRange.dateTo);
        Assert.areEqual(bq1.getQuarterStart(), BusinessQuarter.getQuarterStart(2021, 1));
        Assert.areEqual(BusinessQuarter.QUARTER_ALL, BusinessQuarter.asString(0));
        Assert.areEqual(BusinessQuarter.QUARTER_ALL_SHORT, BusinessQuarter.asStringShort(0));
        Assert.areEqual(1, BusinessQuarter.integerOf('0'));

		BusinessQuarter bq2 = new BusinessQuarter(2020, 2);
		Assert.areEqual(2, bq2.quarter);
		Assert.areEqual(2020, bq2.year);
		Assert.areEqual(Date.newInstance(2020, 4, 1), bq2.dateRange.dateFrom);
		Assert.areEqual(Date.newInstance(2020, 6, 30), bq2.dateRange.dateTo);
        Assert.areEqual(bq2.getQuarterEnd(), BusinessQuarter.getQuarterEnd(2020, 2));

		try {
			new BusinessQuarter(2020, 7);
			Assert.isTrue(false, 'Should throw exception');
		} catch (Exception e) {
			Assert.isTrue(true, 'Should throw exception');
		}
	}

	@IsTest
	public static void test_getNextQuarter() {
		BusinessQuarter bqNext;

		bqNext = (new BusinessQuarter(2021, 2)).getNextQuarter();
		Assert.areEqual(3, bqNext.quarter);
		Assert.areEqual(2021, bqNext.year);
		Assert.areEqual(Date.newInstance(2021, 7, 1), bqNext.dateRange.dateFrom);
		Assert.areEqual(Date.newInstance(2021, 9, 30), bqNext.dateRange.dateTo);

		bqNext = (new BusinessQuarter(2021, 4)).getNextQuarter();
		Assert.areEqual(1, bqNext.quarter);
		Assert.areEqual(2022, bqNext.year);
		Assert.areEqual(Date.newInstance(2022, 1, 1), bqNext.dateRange.dateFrom);
		Assert.areEqual(Date.newInstance(2022, 3, 31), bqNext.dateRange.dateTo);
	}

	@IsTest
	public static void test_getPreviousQuarter() {
		BusinessQuarter bqNext;

		bqNext = (new BusinessQuarter(2021, 2)).getPreviousQuarter();
		Assert.areEqual(1, bqNext.quarter);
		Assert.areEqual(2021, bqNext.year);
		Assert.areEqual(Date.newInstance(2021, 1, 1), bqNext.dateRange.dateFrom);
		Assert.areEqual(Date.newInstance(2021, 3, 31), bqNext.dateRange.dateTo);

		bqNext = (new BusinessQuarter(2022, 1)).getPreviousQuarter();
		Assert.areEqual(4, bqNext.quarter);
		Assert.areEqual(2021, bqNext.year);
		Assert.areEqual(Date.newInstance(2021, 10, 1), bqNext.dateRange.dateFrom);
		Assert.areEqual(Date.newInstance(2021, 12, 31), bqNext.dateRange.dateTo);
	}

	@IsTest
	public static void test_getWeekRangesForQuarter() {
		BusinessQuarter bq2020Q1 = new BusinessQuarter(2021, 1);

		List<DateRange> ranges = bq2020Q1.getWeekRangesForQuarter();

		Assert.areEqual(14, ranges.size());

		Assert.areEqual(Date.newInstance(2021, 1, 1), ranges.get(0).dateFrom);
		Assert.areEqual(Date.newInstance(2021, 1, 2), ranges.get(0).dateTo);
		Assert.areEqual(Date.newInstance(2021, 1, 3), ranges.get(1).dateFrom);
		Assert.areEqual(Date.newInstance(2021, 1, 9), ranges.get(1).dateTo);
		Assert.areEqual(Date.newInstance(2021, 1, 10), ranges.get(2).dateFrom);
		Assert.areEqual(Date.newInstance(2021, 1, 16), ranges.get(2).dateTo);
		Assert.areEqual(Date.newInstance(2021, 1, 17), ranges.get(3).dateFrom);
		Assert.areEqual(Date.newInstance(2021, 1, 23), ranges.get(3).dateTo);

		Assert.areEqual(Date.newInstance(2021, 3, 28), ranges.get(13).dateFrom);
		Assert.areEqual(Date.newInstance(2021, 3, 31), ranges.get(13).dateTo);
	}

	@IsTest
	public static void test_getQuarterStart() {
		Assert.areEqual(Date.newInstance(2021, 1, 1), BusinessQuarter.getQuarterStart(2021, 0));
		Assert.areEqual(Date.newInstance(2021, 1, 1), BusinessQuarter.getQuarterStart(2021, 1));
		Assert.areEqual(Date.newInstance(2022, 4, 1), BusinessQuarter.getQuarterStart(2022, 2));
		Assert.areEqual(Date.newInstance(2019, 7, 1), BusinessQuarter.getQuarterStart(2019, 3));
		Assert.areEqual(Date.newInstance(2021, 10, 1), BusinessQuarter.getQuarterStart(2021, 4));

		try {
			BusinessQuarter.getQuarterStart(2021, 5);
			Assert.isTrue(false, 'Should throw exception');
		} catch (Exception e) {
			Assert.isTrue(true, 'Should throw exception');
		}
	}

	@IsTest
	public static void test_getQuarterEnd() {
		Assert.areEqual(Date.newInstance(2021, 12, 31), BusinessQuarter.getQuarterEnd(2021, 0));
		Assert.areEqual(Date.newInstance(2021, 3, 31), BusinessQuarter.getQuarterEnd(2021, 1));
		Assert.areEqual(Date.newInstance(2022, 6, 30), BusinessQuarter.getQuarterEnd(2022, 2));
		Assert.areEqual(Date.newInstance(2019, 9, 30), BusinessQuarter.getQuarterEnd(2019, 3));
		Assert.areEqual(Date.newInstance(2021, 12, 31), BusinessQuarter.getQuarterEnd(2021, 4));

		try {
			BusinessQuarter.getQuarterEnd(2021, 5);
			Assert.isTrue(false, 'Should throw exception');
		} catch (Exception e) {
			Assert.isTrue(true, 'Should throw exception');
		}
	}

	@IsTest
	public static void test_getQuarter() {
		Assert.areEqual(1, BusinessQuarter.getQuarter(Date.newInstance(2021, 3, 31)));
		Assert.areEqual(2, BusinessQuarter.getQuarter(Date.newInstance(2022, 5, 18)));
		Assert.areEqual(3, BusinessQuarter.getQuarter(Date.newInstance(2019, 8, 3)));
		Assert.areEqual(4, BusinessQuarter.getQuarter(Date.newInstance(2020, 10, 1)));
	}

	@IsTest
	public static void test_getWeek() {
		Assert.areEqual(1, BusinessQuarter.getWeek(Date.newInstance(2021, 1, 1), false));
		Assert.areEqual(2, BusinessQuarter.getWeek(Date.newInstance(2021, 1, 3), false));
		Assert.areEqual(14, BusinessQuarter.getWeek(Date.newInstance(2021, 3, 31), false));
		Assert.areEqual(4, BusinessQuarter.getWeek(Date.newInstance(2021, 4, 21), false));
		Assert.areEqual(9, BusinessQuarter.getWeek(Date.newInstance(2021, 8, 23), false));
		Assert.areEqual(11, BusinessQuarter.getWeek(Date.newInstance(2021, 9, 8), false));
		Assert.areEqual(14, BusinessQuarter.getWeek(Date.newInstance(2021, 9, 30), false));

		Assert.areEqual(14, BusinessQuarter.getWeek(Date.newInstance(2021, 4, 2), true));
		Assert.areEqual(40, BusinessQuarter.getWeek(Date.newInstance(2021, 9, 30), true));
	}

	@IsTest
	public static void test_asString() {
		Assert.areEqual('Quarter 1', BusinessQuarter.asString(1));
		Assert.areEqual('Quarter 2', BusinessQuarter.asString(2));
		Assert.areEqual('Quarter 3', BusinessQuarter.asString(3));
		Assert.areEqual('Quarter 4', BusinessQuarter.asString(4));

		try {
			BusinessQuarter.asString(5);
			Assert.isTrue(false, 'Should throw exception');
		} catch (Exception e) {
			Assert.isTrue(true, 'Should throw exception');
		}
	}

	@IsTest
	public static void test_asStringShort() {
		Assert.areEqual('Q1', BusinessQuarter.asStringShort(1));
		Assert.areEqual('Q2', BusinessQuarter.asStringShort(2));
		Assert.areEqual('Q3', BusinessQuarter.asStringShort(3));
		Assert.areEqual('Q4', BusinessQuarter.asStringShort(4));

		try {
			BusinessQuarter.asStringShort(5);
			Assert.isTrue(false, 'Should throw exception');
		} catch (Exception e) {
			Assert.isTrue(true, 'Should throw exception');
		}
	}

	@IsTest
	public static void test_integerOf() {
		Assert.areEqual(1, BusinessQuarter.integerOf('Quarter 1'));
		Assert.areEqual(2, BusinessQuarter.integerOf('Q2'));
		Assert.areEqual(3, BusinessQuarter.integerOf('THREE'));
		Assert.areEqual(4, BusinessQuarter.integerOf('4'));

		try {
			BusinessQuarter.integerOf('Blurt');
			Assert.isTrue(false, 'Should throw exception');
		} catch (Exception e) {
			Assert.isTrue(true, 'Should throw exception');
		}
	}

	@IsTest
	public static void test_listQuarters() {
		List<String> nameQuarters = BusinessQuarter.listQuarters();

		Assert.areEqual(5, nameQuarters.size());
		Assert.areEqual('Quarter 1', nameQuarters.get(0));
		Assert.areEqual('Quarter 2', nameQuarters.get(1));
		Assert.areEqual('Quarter 3', nameQuarters.get(2));
		Assert.areEqual('Quarter 4', nameQuarters.get(3));
		Assert.areEqual('All Quarters', nameQuarters.get(4));
	}

	@IsTest
	public static void test_listQuartersShort() {
		List<String> nameQuarters = BusinessQuarter.listQuartersShort();

		Assert.areEqual(5, nameQuarters.size());
		Assert.areEqual('Q1', nameQuarters.get(0));
		Assert.areEqual('Q2', nameQuarters.get(1));
		Assert.areEqual('Q3', nameQuarters.get(2));
		Assert.areEqual('Q4', nameQuarters.get(3));
		Assert.areEqual('ALL', nameQuarters.get(4));
	}
    
    @IsTest
	public static void test_constructorWith0Quarter() {
		BusinessQuarter bq2 = new BusinessQuarter(2020, 0);
		Assert.areEqual(0, bq2.quarter);
		Assert.areEqual(2020, bq2.year);
		Assert.areEqual(Date.newInstance(2020, 1, 1), bq2.dateRange.dateFrom);
		Assert.areEqual(Date.newInstance(2020, 12, 31), bq2.dateRange.dateTo);
	}
}