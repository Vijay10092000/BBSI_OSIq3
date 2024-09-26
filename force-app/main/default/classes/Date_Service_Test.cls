/**
 * @description Date_Service_Test
 */
@SuppressWarnings('PMD.ApexAssertionsShouldIncludeMessage')
@IsTest
public without sharing class Date_Service_Test {
	@IsTest
	static void test_getWeekdayName() {
		Assert.areEqual('Sunday', Date_Service.getWeekdayName(Date_Service.Weekday.SUNDAY));
		Assert.areEqual('Monday', Date_Service.getWeekdayName(Date_Service.Weekday.MONDAY));
		Assert.areEqual('Tuesday', Date_Service.getWeekdayName(Date_Service.Weekday.TUESDAY));
		Assert.areEqual('Wednesday', Date_Service.getWeekdayName(Date_Service.Weekday.WEDNESDAY));
		Assert.areEqual('Thursday', Date_Service.getWeekdayName(Date_Service.Weekday.THURSDAY));
		Assert.areEqual('Friday', Date_Service.getWeekdayName(Date_Service.Weekday.FRIDAY));
		Assert.areEqual('Saturday', Date_Service.getWeekdayName(Date_Service.Weekday.SATURDAY));

		Assert.areEqual('SUNDAY', Date_Service.getWeekdayName(0));
		Assert.areEqual('MONDAY', Date_Service.getWeekdayName(1));
		Assert.areEqual('TUESDAY', Date_Service.getWeekdayName(2));
		Assert.areEqual('WEDNESDAY', Date_Service.getWeekdayName(3));
		Assert.areEqual('THURSDAY', Date_Service.getWeekdayName(4));
		Assert.areEqual('FRIDAY', Date_Service.getWeekdayName(5));
		Assert.areEqual('SATURDAY', Date_Service.getWeekdayName(6));
		Assert.areEqual(null, Date_Service.getWeekdayName(7));
	}

	@IsTest
	static void test_getWeekdayNameShort() {
		Assert.isTrue('SUN'.equals(Date_Service.getWeekdayNameShort(Date_Service.Weekday.SUNDAY)));
		Assert.isTrue('MON'.equals(Date_Service.getWeekdayNameShort(Date_Service.Weekday.MONDAY)));
		Assert.isTrue('TUE'.equals(Date_Service.getWeekdayNameShort(Date_Service.Weekday.TUESDAY)));
		Assert.isTrue('WED'.equals(Date_Service.getWeekdayNameShort(Date_Service.Weekday.WEDNESDAY)));
		Assert.isTrue('THU'.equals(Date_Service.getWeekdayNameShort(Date_Service.Weekday.THURSDAY)));
		Assert.isTrue('FRI'.equals(Date_Service.getWeekdayNameShort(Date_Service.Weekday.FRIDAY)));
		Assert.isTrue('SAT'.equals(Date_Service.getWeekdayNameShort(Date_Service.Weekday.SATURDAY)));
	}

	@IsTest
	static void test_getWeekday_Integer() {
		Assert.areEqual(Date_Service.Weekday.SUNDAY, Date_Service.getWeekday(0));
		Assert.areEqual(Date_Service.Weekday.MONDAY, Date_Service.getWeekday(1));
		Assert.areEqual(Date_Service.Weekday.TUESDAY, Date_Service.getWeekday(2));
		Assert.areEqual(Date_Service.Weekday.WEDNESDAY, Date_Service.getWeekday(3));
		Assert.areEqual(Date_Service.Weekday.THURSDAY, Date_Service.getWeekday(4));
		Assert.areEqual(Date_Service.Weekday.FRIDAY, Date_Service.getWeekday(5));
		Assert.areEqual(Date_Service.Weekday.SATURDAY, Date_Service.getWeekday(6));
		Assert.areEqual(null, Date_Service.getWeekday(8));
	}

	@IsTest
	static void test_getWeekday_String() {
		Assert.areEqual(Date_Service.Weekday.SUNDAY, Date_Service.getWeekday('Sunday'));
		Assert.areEqual(Date_Service.Weekday.MONDAY, Date_Service.getWeekday('MoNDAY'));
		Assert.areEqual(Date_Service.Weekday.TUESDAY, Date_Service.getWeekday('TUESDAY'));
		Assert.areEqual(Date_Service.Weekday.WEDNESDAY, Date_Service.getWeekday('WEDNESDAY'));
		Assert.areEqual(Date_Service.Weekday.THURSDAY, Date_Service.getWeekday('thursDay'));
		Assert.areEqual(Date_Service.Weekday.FRIDAY, Date_Service.getWeekday('friday'));
		Assert.areEqual(Date_Service.Weekday.SATURDAY, Date_Service.getWeekday('Saturday'));
		Assert.areEqual(null, Date_Service.getWeekday('Blurb'));
	}

	@IsTest
	static void test_getWeekday_Date() {
		Assert.areEqual(Date_Service.Weekday.SUNDAY, Date_Service.getWeekday(Date.newInstance(2021, 1, 31)));
		Assert.areEqual(Date_Service.Weekday.MONDAY, Date_Service.getWeekday(Date.newInstance(2021, 2, 1)));
		Assert.areEqual(Date_Service.Weekday.TUESDAY, Date_Service.getWeekday(Date.newInstance(2021, 2, 2)));
		Assert.areEqual(Date_Service.Weekday.WEDNESDAY, Date_Service.getWeekday(Date.newInstance(2021, 2, 3)));
		Assert.areEqual(Date_Service.Weekday.THURSDAY, Date_Service.getWeekday(Date.newInstance(2021, 2, 4)));
		Assert.areEqual(Date_Service.Weekday.FRIDAY, Date_Service.getWeekday(Date.newInstance(2021, 2, 5)));
		Assert.areEqual(Date_Service.Weekday.SATURDAY, Date_Service.getWeekday(Date.newInstance(2021, 2, 6)));

		Assert.areEqual(Date_Service.Weekday.SUNDAY, Date_Service.getWeekday(Date.newInstance(2021, 8, 22)));
		Assert.areEqual(Date_Service.Weekday.MONDAY, Date_Service.getWeekday(Date.newInstance(2020, 12, 28)));
		Assert.areEqual(Date_Service.Weekday.TUESDAY, Date_Service.getWeekday(Date.newInstance(2021, 2, 16)));
		Assert.areEqual(Date_Service.Weekday.WEDNESDAY, Date_Service.getWeekday(Date.newInstance(2020, 4, 22)));
		Assert.areEqual(Date_Service.Weekday.THURSDAY, Date_Service.getWeekday(Date.newInstance(2021, 3, 11)));
		Assert.areEqual(Date_Service.Weekday.FRIDAY, Date_Service.getWeekday(Date.newInstance(2020, 8, 21)));
		Assert.areEqual(Date_Service.Weekday.SATURDAY, Date_Service.getWeekday(Date.newInstance(2021, 6, 5)));
	}

	@IsTest
	static void test_startOfWeek() {
		Date result;
		Date test;

		result = Date.newInstance(2021, 5, 2);
		test = Date_Service.startOfWeek(Date.newInstance(2021, 5, 2));
		Assert.areEqual(result, test);

		result = Date.newInstance(2021, 8, 15);
		test = Date_Service.startOfWeek(Date.newInstance(2021, 8, 20));
		Assert.areEqual(result, test);

		result = Date.newInstance(2021, 6, 13);
		test = Date_Service.startOfWeek(Date.newInstance(2021, 6, 19));
		Assert.areEqual(result, test);
	}

	@IsTest
	static void test_endOfWeek() {
		Date result;
		Date test;

		result = Date.newInstance(2021, 5, 8);
		test = Date_Service.endOfWeek(Date.newInstance(2021, 5, 2));
		Assert.areEqual(result, test);

		result = Date.newInstance(2021, 8, 21);
		test = Date_Service.endOfWeek(Date.newInstance(2021, 8, 20));
		Assert.areEqual(result, test);

		result = Date.newInstance(2021, 6, 19);
		test = Date_Service.endOfWeek(Date.newInstance(2021, 6, 19));
		Assert.areEqual(result, test);
	}

	@IsTest
	static void test_getMonthName() {
		Assert.areEqual('JANUARY', Date_Service.getMonthName(1));
		Assert.areEqual('FEBRUARY', Date_Service.getMonthName(2));
		Assert.areEqual('MARCH', Date_Service.getMonthName(3));
		Assert.areEqual('APRIL', Date_Service.getMonthName(4));
		Assert.areEqual('MAY', Date_Service.getMonthName(5));
		Assert.areEqual('JUNE', Date_Service.getMonthName(6));
		Assert.areEqual('JULY', Date_Service.getMonthName(7));
		Assert.areEqual('AUGUST', Date_Service.getMonthName(8));
		Assert.areEqual('SEPTEMBER', Date_Service.getMonthName(9));
		Assert.areEqual('OCTOBER', Date_Service.getMonthName(10));
		Assert.areEqual('NOVEMBER', Date_Service.getMonthName(11));
		Assert.areEqual('DECEMBER', Date_Service.getMonthName(12));

		Assert.areEqual(null, Date_Service.getMonthName(0));
		Assert.areEqual(null, Date_Service.getMonthName(13));
	}

	@IsTest
	static void test_getMonthName_Integer() {
		Assert.areEqual('January', Date_Service.getMonthName(Date_Service.Month.JANUARY));
		Assert.areEqual('February', Date_Service.getMonthName(Date_Service.Month.FEBRUARY));
		Assert.areEqual('March', Date_Service.getMonthName(Date_Service.Month.MARCH));
		Assert.areEqual('April', Date_Service.getMonthName(Date_Service.Month.APRIL));
		Assert.areEqual('May', Date_Service.getMonthName(Date_Service.Month.MAY));
		Assert.areEqual('June', Date_Service.getMonthName(Date_Service.Month.JUNE));
		Assert.areEqual('July', Date_Service.getMonthName(Date_Service.Month.JULY));
		Assert.areEqual('August', Date_Service.getMonthName(Date_Service.Month.AUGUST));
		Assert.areEqual('September', Date_Service.getMonthName(Date_Service.Month.SEPTEMBER));
		Assert.areEqual('October', Date_Service.getMonthName(Date_Service.Month.OCTOBER));
		Assert.areEqual('November', Date_Service.getMonthName(Date_Service.Month.NOVEMBER));
		Assert.areEqual('December', Date_Service.getMonthName(Date_Service.Month.DECEMBER));
	}

	@IsTest
	static void test_getMonthNameShort() {
		Assert.areEqual('JAN', Date_Service.getMonthNameShort(Date_Service.Month.JANUARY));
		Assert.areEqual('FEB', Date_Service.getMonthNameShort(Date_Service.Month.FEBRUARY));
		Assert.areEqual('MAR', Date_Service.getMonthNameShort(Date_Service.Month.MARCH));
		Assert.areEqual('APR', Date_Service.getMonthNameShort(Date_Service.Month.APRIL));
		Assert.areEqual('MAY', Date_Service.getMonthNameShort(Date_Service.Month.MAY));
		Assert.areEqual('JUN', Date_Service.getMonthNameShort(Date_Service.Month.JUNE));
		Assert.areEqual('JUL', Date_Service.getMonthNameShort(Date_Service.Month.JULY));
		Assert.areEqual('AUG', Date_Service.getMonthNameShort(Date_Service.Month.AUGUST));
		Assert.areEqual('SEP', Date_Service.getMonthNameShort(Date_Service.Month.SEPTEMBER));
		Assert.areEqual('OCT', Date_Service.getMonthNameShort(Date_Service.Month.OCTOBER));
		Assert.areEqual('NOV', Date_Service.getMonthNameShort(Date_Service.Month.NOVEMBER));
		Assert.areEqual('DEC', Date_Service.getMonthNameShort(Date_Service.Month.DECEMBER));
	}

	@IsTest
	static void test_getMonthNumber() {
		Assert.areEqual(1, Date_Service.getMonthNumber('January'));
		Assert.areEqual(2, Date_Service.getMonthNumber('February'));
		Assert.areEqual(3, Date_Service.getMonthNumber('MARCH'));
		Assert.areEqual(4, Date_Service.getMonthNumber('APRIL'));
		Assert.areEqual(5, Date_Service.getMonthNumber('MAY'));
		Assert.areEqual(6, Date_Service.getMonthNumber('JUNE'));
		Assert.areEqual(7, Date_Service.getMonthNumber('JULY'));
		Assert.areEqual(8, Date_Service.getMonthNumber('AUGUST'));
		Assert.areEqual(9, Date_Service.getMonthNumber('SEPTEMBER'));
		Assert.areEqual(10, Date_Service.getMonthNumber('OCTOBER'));
		Assert.areEqual(11, Date_Service.getMonthNumber('NOVEMBER'));
		Assert.areEqual(12, Date_Service.getMonthNumber('DECEMBER'));
	}

	@IsTest
	static void test_MinMaxMethods() {
		Date dateMin = Date.newInstance(2015, 3, 17);
		Date dateMiddle = Date.newInstance(2019, 3, 12);
		Date dateMax = Date.newInstance(2022, 5, 1);

		List<Date> dates = new List<Date>{ dateMiddle, dateMax, dateMin };

		Assert.areEqual(dateMax, Date_Service.maxDate(dateMax, dateMax));
		Assert.areEqual(dateMax, Date_Service.maxDate(dateMin, dateMax));
		Assert.areEqual(dateMax, Date_Service.maxDate(dateMax, dateMin));
		Assert.areEqual(dateMax, Date_Service.maxDate(dates));
		Assert.areEqual(null, Date_Service.maxDate(new List<Date>()));

		Assert.areEqual(dateMin, Date_Service.minDate(dateMin, dateMin));
		Assert.areEqual(dateMin, Date_Service.minDate(dateMin, dateMax));
		Assert.areEqual(dateMin, Date_Service.minDate(dateMax, dateMin));
		Assert.areEqual(dateMin, Date_Service.minDate(dates));
		Assert.areEqual(null, Date_Service.minDate(new List<Date>()));
	}

	@IsTest
	static void test_getYearMonthDifference() {

		Assert.areEqual('0 Months', Date_Service.getYearMonthDifference(Date.newInstance(2020, 1, 17), Date.newInstance(2020, 1, 27)));
		Assert.areEqual('1 Month', Date_Service.getYearMonthDifference(Date.newInstance(2020, 1, 17), Date.newInstance(2020, 2, 27)));
		Assert.areEqual('11 Months', Date_Service.getYearMonthDifference(Date.newInstance(2020, 1, 17), Date.newInstance(2020, 12, 27)));

		Assert.areEqual('1 Year', Date_Service.getYearMonthDifference(Date.newInstance(2020, 1, 17), Date.newInstance(2021, 1, 27)));
		Assert.areEqual('2 Years', Date_Service.getYearMonthDifference(Date.newInstance(2020, 1, 17), Date.newInstance(2022, 1, 27)));

		Assert.areEqual('1 Year - 1 Month', Date_Service.getYearMonthDifference(Date.newInstance(2020, 1, 17), Date.newInstance(2021, 2, 27)));
		Assert.areEqual('5 Years - 9 Months', Date_Service.getYearMonthDifference(Date.newInstance(2015, 1, 17), Date.newInstance(2020, 10, 27)));

		Assert.areEqual('-- Invalid Dates --', Date_Service.getYearMonthDifference(Date.newInstance(2020, 3, 17), Date.newInstance(2015, 3, 17)));
		Assert.areEqual('-- Invalid Dates --', Date_Service.getYearMonthDifference(Date.newInstance(2015, 3, 17), null));
		Assert.areEqual('-- Invalid Dates --', Date_Service.getYearMonthDifference(null, Date.newInstance(2015, 3, 17)));
	}

	@IsTest
	static void test_toYearMonthDay() {
		Assert.areEqual('2020-01-17', Date_Service.toYearMonthDay(Date.newInstance(2020, 1, 17)));
		Assert.areEqual('2019-07-07', Date_Service.toYearMonthDay(Date.newInstance(2019, 7, 7)));
		Assert.areEqual('2022-12-25', Date_Service.toYearMonthDay(Date.newInstance(2022, 12, 25)));

		Assert.areEqual('2020-01-01', Date_Service.toYearMonthDay(DateTime.newInstance(2020, 1, 1)));
		Assert.areEqual('2019-07-07', Date_Service.toYearMonthDay(DateTime.newInstance(2019, 7, 7)));
		Assert.areEqual('2022-12-25', Date_Service.toYearMonthDay(DateTime.newInstance(2022, 12, 25)));
	}

	@IsTest
	static void test_addWeekdays() {
		Date result;

		result = Date.newInstance(2022, 9, 27);
		Assert.areEqual(result, Date_Service.addWeekdays(Date.newInstance(2022, 9, 26), 1));
		result = Date.newInstance(2022, 10, 19);
		Assert.areEqual(result, Date_Service.addWeekdays(Date.newInstance(2022, 9, 26), 17));
		result = Date.newInstance(2022, 11, 7);
		Assert.areEqual(result, Date_Service.addWeekdays(Date.newInstance(2022, 9, 26), 30));
		result = Date.newInstance(2022, 10, 12);
		Assert.areEqual(result, Date_Service.addWeekdays(Date.newInstance(2022, 10, 03), 7));

		result = Date.newInstance(2022, 9, 23);
		Assert.areEqual(result, Date_Service.addWeekdays(Date.newInstance(2022, 9, 26), -1));
		result = Date.newInstance(2022, 9, 6);
		Assert.areEqual(result, Date_Service.addWeekdays(Date.newInstance(2022, 9, 26), -14));
		result = Date.newInstance(2022, 8, 29);
		Assert.areEqual(result, Date_Service.addWeekdays(Date.newInstance(2022, 9, 26), -20));
		result = Date.newInstance(2022, 10, 4);
		Assert.areEqual(result, Date_Service.addWeekdays(Date.newInstance(2022, 10, 21), -13));

		result = Date.newInstance(2022, 11, 11);
		Assert.areEqual(result, Date_Service.addWeekdays(Date.newInstance(2022, 10, 01), 30));
		result = Date.newInstance(2022, 11, 4);
		Assert.areEqual(result, Date_Service.addWeekdays(Date.newInstance(2022, 10, 02), 25));
		result = Date.newInstance(2022, 9, 28);
		Assert.areEqual(result, Date_Service.addWeekdays(Date.newInstance(2022, 10, 01), -3));
		Assert.areEqual(result, Date_Service.addWeekdays(Date.newInstance(2022, 10, 02), -3));

		result = Date.newInstance(2023, 1, 23);
		Assert.areEqual(result, Date_Service.addWeekdays(Date.newInstance(2023, 1, 20), 1));
		result = Date.newInstance(2023, 1, 20);
		Assert.areEqual(result, Date_Service.addWeekdays(Date.newInstance(2023, 1, 23), -1));
		result = Date.newInstance(2023, 1, 30);
		Assert.areEqual(result, Date_Service.addWeekdays(Date.newInstance(2023, 1, 20), 6));
		result = Date.newInstance(2023, 1, 13);
		Assert.areEqual(result, Date_Service.addWeekdays(Date.newInstance(2023, 1, 23), -6));
	}

	@IsTest
	static void test_nearestNonWeekend() {
		Assert.areEqual(
			Date.newInstance(2024, 05, 10), 
			Date_Service.nearestNonWeekend(Date.newInstance(2024, 05, 10))
		);
		Assert.areEqual(
			Date.newInstance(2024, 05, 10), 
			Date_Service.nearestNonWeekend(Date.newInstance(2024, 05, 11))
		);
		Assert.areEqual(
			Date.newInstance(2024, 05, 13), 
			Date_Service.nearestNonWeekend(Date.newInstance(2024, 05, 12))
		);
		Assert.areEqual(
			Date.newInstance(2024, 05, 13), 
			Date_Service.nearestNonWeekend(Date.newInstance(2024, 05, 13))
		);
	}

	@IsTest
	static void test_nextNonWeekend() {
		Assert.areEqual(
			Date.newInstance(2024, 05, 10), 
			Date_Service.nextNonWeekend(Date.newInstance(2024, 05, 10))
		);
		Assert.areEqual(
			Date.newInstance(2024, 05, 13), 
			Date_Service.nextNonWeekend(Date.newInstance(2024, 05, 11))
		);
		Assert.areEqual(
			Date.newInstance(2024, 05, 13), 
			Date_Service.nextNonWeekend(Date.newInstance(2024, 05, 12))
		);
		Assert.areEqual(
			Date.newInstance(2024, 05, 13), 
			Date_Service.nextNonWeekend(Date.newInstance(2024, 05, 13))
		);
	}
}