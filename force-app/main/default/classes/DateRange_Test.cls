/**
 * @description DateRange_Test
 */
@IsTest
public without sharing class DateRange_Test {
    private static DateRange range2019Q4 = new DateRange(Date.newInstance(2019, 10, 1), Date.newInstance(2019, 12, 31));
    private static DateRange range2020 = new DateRange(Date.newInstance(2020, 1, 1), Date.newInstance(2020, 12, 31));
    private static DateRange range2020Q1 = new DateRange(Date.newInstance(2020, 1, 1), Date.newInstance(2020, 3, 31));
    private static DateRange range2020Q1W1 = new DateRange(Date.newInstance(2020, 1, 1), Date.newInstance(2020, 1, 4));
    private static DateRange range2020Q1W3 = new DateRange(
        Date.newInstance(2020, 1, 12),
        Date.newInstance(2020, 1, 18)
    );
    private static DateRange range2021Q1W1 = new DateRange(Date.newInstance(2021, 1, 1), Date.newInstance(2021, 1, 2));
    private static DateRange range2019Q4thru2020Q1 = new DateRange(
        Date.newInstance(2019, 10, 1),
        Date.newInstance(2020, 3, 31)
    );
    private static DateRange range2021JAN01 = new DateRange(Date.newInstance(2021, 1, 1), Date.newInstance(2021, 1, 1));
    private static DateRange range2023Q1 = new DateRange(Date.newInstance(2023, 1, 1), Date.newInstance(2023, 3, 31));

    private static Date date2020NewYears = Date.newInstance(2020, 1, 1);
    private static Date date2020March31 = Date.newInstance(2020, 3, 31);
    private static Date date2019Halloween = Date.newInstance(2019, 10, 31);
    private static Date date2020Halloween = Date.newInstance(2020, 10, 31);
    private static Date date2021Halloween = Date.newInstance(2021, 10, 31);

    @IsTest
    public static void test_constructor() {
        DateRange range2020Q1W3 = new DateRange(date2020March31, date2020NewYears);
        Assert.areEqual(date2020NewYears, range2020Q1W3.dateFrom, 'Date was ordered');
        Assert.areEqual(date2020March31, range2020Q1W3.dateTo, 'Date was ordered');

        DateRange range2 = new DateRange(2019, 7, 2020, 5);
        Date date2019July01 = Date.newInstance(2019, 7, 1);
        Date date2020May31 = Date.newInstance(2020, 5, 31);
        Assert.areEqual(date2019July01, range2.dateFrom);
        Assert.areEqual(date2020May31, range2.dateTo);

        DateRange range3 = new DateRange(2020, 8, 2020, 8);
        Date date2020Aug01 = Date.newInstance(2020, 8, 1);
        Date date2020Aug31 = Date.newInstance(2020, 8, 31);
        Assert.areEqual(date2020Aug01, range3.dateFrom);
        Assert.areEqual(date2020Aug31, range3.dateTo);

        try {
            DateRange range4 = new DateRange(2021, 7, 2019, 4);
            Assert.isTrue(false, 'Exception should be thrown');
        } catch (Exception e) {
            Assert.isTrue(true, 'Exception should be thrown');
        }
    }

    @IsTest
    public static void test_numberDays() {
        Assert.areEqual(366, range2020.numberDays(), '2020');
        Assert.areEqual(91, range2020Q1.numberDays(), '2020 Quarter 1');
        Assert.areEqual(4, range2020Q1W1.numberDays(), '2020 Quarter 1 Week 1');
        Assert.areEqual(7, range2020Q1W3.numberDays(), '2020 Quarter 1 Week 3');
    }

    @IsTest
    public static void test_weeksInRange() {
        Assert.areEqual(1, range2021JAN01.weeksInRange(), 'Single Day');
        Assert.areEqual(1, range2020Q1W1.weeksInRange(), '2020 Quarter 1 Week 1');
        Assert.areEqual(14, range2020Q1.weeksInRange(), '2020 Quarter 1');
        Assert.areEqual(13, range2023Q1.weeksInRange(), '2023 Quarter 1');
    }

    @IsTest
    public static void test_contains_Date() {
        Assert.areEqual(true, range2020.contains(date2020NewYears), '2020 does contain its New Years Day');
        Assert.areEqual(true, range2020.contains(date2020Halloween), '2020 does contain Halloween from its year');
        Assert.areEqual(
            false,
            range2020.contains(date2021Halloween),
            '2020 does not contain Halloween of another year'
        );
    }

    @IsTest
    public static void test_isBefore_Date() {
        Assert.areEqual(
            false,
            range2020Q1W1.isBefore(date2019Halloween),
            '2020 Q1 Week 1 is not before 2019 Halloween'
        );
        Assert.areEqual(true, range2020Q1W1.isBefore(date2020Halloween), '2020 Q1 Week 1 is before 2020 Halloween');
        Assert.areEqual(
            false,
            range2020Q1W1.isBefore(date2020NewYears),
            '2020 Q1 Week 1 is not before 2020 New Years'
        );
    }

    @IsTest
    public static void test_isAfter_Date() {
        Assert.areEqual(true, range2020Q1W1.isAfter(date2019Halloween), '2020 Q1 Week 1 is after 2019 Halloween');
        Assert.areEqual(
            false,
            range2020Q1W1.isAfter(date2020Halloween),
            '2020 Q1 Week 1 is not after 2020 Halloween'
        );
        Assert.areEqual(
            false,
            range2020Q1W1.isAfter(date2020NewYears),
            '2020 Q1 Week 1 is not after 2020 New Years'
        );
    }

    @IsTest
    public static void test_contains_DateRange() {
        Assert.areEqual(true, range2020.contains(range2020), '2020 contains itself');
        Assert.areEqual(true, range2020.contains(range2020Q1), '2020 contains its first quarter');
        Assert.areEqual(true, range2020.contains(range2020Q1W1), '2020 contains week from its first quarter');
        Assert.areEqual(true, range2020.contains(range2020Q1W3), '2020 contains week from its first quarter');
        Assert.areEqual(false, range2020.contains(range2021Q1W1), '2020 does not contain week from another year');
        Assert.areEqual(false, range2020Q1W3.contains(range2020Q1), '2020 Q1 W3 does not contain the whole year');
    }

    @IsTest
    public static void test_overlaps() {
        Assert.areEqual(true, range2019Q4thru2020Q1.overlaps(range2020), '2019 Q4 - 2020 Q1 overlaps 2020');
        Assert.areEqual(true, range2020.overlaps(range2019Q4thru2020Q1), '2020 overlaps 2019 Q4 - 2020 Q1');
        Assert.areEqual(true, range2020Q1.overlaps(range2020Q1W1), '2020 Q1 overlaps 2020 Q1 W1');
        Assert.areEqual(false, range2020Q1W1.overlaps(range2020Q1W3), '2020 Q1 W1 does not overlap 2020 Q1 W3');
        Assert.areEqual(false, range2020Q1W3.overlaps(range2020Q1W1), '2020 Q1 W3 does not overlap 2020 Q1 W1');
    }

    @IsTest
    public static void test_isBefore_DateRange() {
        Assert.areEqual(true, range2019Q4.isBefore(range2020), '2019 Q1 is 2020');
        Assert.areEqual(true, range2019Q4.isBefore(range2020Q1W3), '2019 Q1 is before 2020 Quarter 1 Week 3');
        Assert.areEqual(false, range2020.isBefore(range2020Q1W1), '2020 is not before 2020 Quarter 1 Week 1');
        Assert.areEqual(true, range2020Q1W1.isBefore(range2020Q1W3), '2020 Q1 Week 1 is before 2020 Q1 Week 3');
        Assert.areEqual(false, range2020Q1W3.isBefore(range2020Q1), '2020 Q1 W3 is not before the whole year');
        Assert.areEqual(
            false,
            range2020Q1W3.isBefore(range2020Q1W1),
            '2020 Q1 Week 3 is not before 2020 Q1 Week 1'
        );
    }

    @IsTest
    public static void test_isAfter_DateRange() {
        Assert.areEqual(false, range2020Q1W1.isAfter(range2020Q1W3), '2020 Q1 Week 1 is after 2020 Q1 Week 3');
        Assert.areEqual(true, range2020Q1W3.isAfter(range2020Q1W1), '2020 Q1 Week 3 is not after 2020 Q1 Week 1');
        Assert.areEqual(false, range2020.isAfter(range2020Q1W1), '2020 is not after week from its first quarter');
        Assert.areEqual(false, range2020.isAfter(range2020Q1W3), '2020 is not after week from its first quarter');
    }
    @IsTest
    public static void test_isFullFirstWeek() {
        Assert.areEqual(false, range2021JAN01.isFullFirstWeek(), 'range2021JAN01 is not Sunday');
        Assert.areEqual(false, range2020Q1W1.isFullFirstWeek(), 'range2020Q1W1 is not Sunday');
        Assert.areEqual(false, range2020Q1.isFullFirstWeek(), 'range2020Q1 is not Sunday');
        Assert.areEqual(true, range2023Q1.isFullFirstWeek(), 'range2023Q1 is Sunday');
    }
    @IsTest
    public static void test_isFullLastWeek() {
        Assert.areEqual(false, range2021JAN01.isFullLastWeek(), 'range2021JAN01 is not Saturday');
        Assert.areEqual(false, range2020Q1W1.isFullLastWeek(), 'range2020Q1W1 is not Saturday');
        Assert.areEqual(false, range2020Q1.isFullLastWeek(), 'range2020Q1 is not Saturday');
        Assert.areEqual(false, range2023Q1.isFullLastWeek(), 'range2023Q1 is not Saturday');
    }
}