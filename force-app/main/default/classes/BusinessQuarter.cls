/**
 * @description BusinessQuarter
 */
@SuppressWarnings('PMD.ApexDoc')
public without sharing class BusinessQuarter {
    public static final String QUARTER_1 = 'Quarter 1';
    public static final String QUARTER_2 = 'Quarter 2';
    public static final String QUARTER_3 = 'Quarter 3';
    public static final String QUARTER_4 = 'Quarter 4';
    public static final String QUARTER_ALL = 'All Quarters';

    public static final String QUARTER_1_SHORT = 'Q1';
    public static final String QUARTER_2_SHORT = 'Q2';
    public static final String QUARTER_3_SHORT = 'Q3';
    public static final String QUARTER_4_SHORT = 'Q4';
    public static final String QUARTER_ALL_SHORT = 'ALL';

    public static final Integer Q1_FIRST_MONTH = 1;
    public static final Integer Q2_FIRST_MONTH = 4;
    public static final Integer Q3_FIRST_MONTH = 7;
    public static final Integer Q4_FIRST_MONTH = 10;

    public static final Integer Q1_LAST_MONTH = 3;
    public static final Integer Q2_LAST_MONTH = 6;
    public static final Integer Q3_LAST_MONTH = 9;
    public static final Integer Q4_LAST_MONTH = 12;

    public Integer quarter { get; private set; }
    public Integer year { get; private set; }
    public DateRange dateRange { get; private set; }

    /**
     * @description BusinessQuarter constructor.
     * @param  dateWork Date in the quarter
     */
    public BusinessQuarter(Date dateWork) {
        setup(dateWork.year(), getQuarter(dateWork));
    }

    /**
     * @description BusinessQuarter constructor
     * @param  quarter Quarter of the year
     * @param  year    Year
     * @return         return description
     */
    public BusinessQuarter(Integer year, Integer quarter) {
        setup(year, quarter);
    }

    public BusinessQuarter getNextQuarter() {
        return new BusinessQuarter(this.dateRange.dateTo.addDays(1));
    }

    public BusinessQuarter getPreviousQuarter() {
        return new BusinessQuarter(this.dateRange.dateFrom.addDays(-1));
    }

    private void setup(Integer year, Integer quarter) {
        if (quarter < 0 || 4 < quarter) {
            throw new IllegalArgumentException('Invalid quarter: ' + quarter);
        }

        this.quarter = quarter;
        this.year = year;

        if (quarter == 0) {
            this.dateRange = new DateRange(getQuarterStart(year, 1), getQuarterEnd(year, 4));
        } else {
            this.dateRange = new DateRange(getQuarterStart(year, quarter), getQuarterEnd(year, quarter));
        }
    }

    /**
     * @description getWeekStartDatesForQuarter retrieves the Date for the start of each week of a quarter
     * @return   List<Date>
     */
    public List<DateRange> getWeekRangesForQuarter() {
        List<DateRange> result = new List<DateRange>();

        Date dateWork = this.dateRange.dateFrom;
        Date dateWorkEnd = Date_Service.endOfWeek(this.dateRange.dateFrom);

        do {
            DateRange range = new DateRange(dateWork, dateWorkEnd);
            result.add(range);

            dateWork = dateWorkEnd.addDays(1);
            dateWorkEnd = Date_Service.endOfWeek(dateWork);

            if (this.dateRange.dateTo < dateWorkEnd) {
                dateWorkEnd = this.dateRange.dateTo;
            }
        } while (dateWork < this.dateRange.dateTo);

        return result;
    }

    /**
     * @description getQuarterStart returns the start date of the quarter for given quarter and year.
     * @return Date
     */
    public Date getQuarterStart() {
        return BusinessQuarter.getQuarterStart(year, quarter);
    }

    /**
     * @description getQuarterEnd returns the last date of the quarter for given quarter and year.
     * @return Date
     */
    public Date getQuarterEnd() {
        return BusinessQuarter.getQuarterEnd(year, quarter);
    }

    /**
     * @description getQuarterStart returns the start date of the quarter for given quarter and year.
     * @param  year    Year
     * @param  quarter Quarter of year
     * @return Date
     */
    public static Date getQuarterStart(Integer year, Integer quarter) {
        Integer day = 1;
        Integer month = 1;

        switch on quarter {
            when 0 {
                month = Q1_FIRST_MONTH;
            }
            when 1 {
                month = Q1_FIRST_MONTH;
            }
            when 2 {
                month = Q2_FIRST_MONTH;
            }
            when 3 {
                month = Q3_FIRST_MONTH;
            }
            when 4 {
                month = Q4_FIRST_MONTH;
            }
            when else {
                throw new IllegalArgumentException('Invalid quarter: ' + quarter);
            }
        }

        return Date.newInstance(year, month, day);
    }

    /**
     * @description getQuarterEnd returns the last date of the quarter for given quarter and year.
     * @param  year    Year
     * @param  quarter Quarter of year
     * @return Date
     */
    public static Date getQuarterEnd(Integer year, Integer quarter) {
        if (quarter < 0 || 4 < quarter) {
            throw new IllegalArgumentException('Invalid quarter: ' + quarter);
        }

        Integer workYear = year;
        Integer nextQuarter;

        if (quarter == 0) {
            nextQuarter = 5;
        } else {
            nextQuarter = quarter + 1;
        }

        if (nextQuarter == 5) {
            nextQuarter = 1;
            ++workYear;
        }

        Date dateEnd = getQuarterStart(workYear, nextQuarter);

        return dateEnd.addDays(-1);
    }

    /**
     * @description getQuarter returns the quarter from the given date.
     * @param  dateWork Date checking
     * @return Integer
     */
    public static Integer getQuarter(Date dateWork) {
        if (dateWork.month() <= Q1_LAST_MONTH) {
            return 1;
        }
        if (dateWork.month() <= Q2_LAST_MONTH) {
            return 2;
        }
        if (dateWork.month() <= Q3_LAST_MONTH) {
            return 3;
        }
        return 4;
    }

    /**
     * @description getWeek returns the week of the quarter for the given date.
     * @param  dateWork Date checking
     * @return Integer
     */
    public static Integer getWeek(Date dateWork, Boolean forWholeYear) {
        Integer startQuarter = (forWholeYear) ? 1 : getQuarter(dateWork);
        Date dateStart = getQuarterStart(dateWork.year(), startQuarter);

        Date dateStartOfFirstWeek = Date_Service.startOfWeek(dateStart);

        Integer diff = dateStartOfFirstWeek.daysBetween(dateWork);

        return 1 + (diff / 7);
    }

    /**
     * @description asString returns a string of from the given quarter.
     * @param  quarter Quarter number
     * @return String
     */
    public static String asString(Integer quarter) {
        switch on quarter {
            when 0 {
                return QUARTER_ALL;
            }
            when 1 {
                return QUARTER_1;
            }
            when 2 {
                return QUARTER_2;
            }
            when 3 {
                return QUARTER_3;
            }
            when 4 {
                return QUARTER_4;
            }
        }

        throw new IllegalArgumentException('Invalid quarter: ' + String.valueOf(quarter));
    }

    /**
     * @description asStringShort returns a short string of from the given quarter.
     * @param  quarter Quarter number
     * @return String
     */
    public static String asStringShort(Integer quarter) {
        switch on quarter {
            when 0 {
                return QUARTER_ALL_SHORT;
            }
            when 1 {
                return QUARTER_1_SHORT;
            }
            when 2 {
                return QUARTER_2_SHORT;
            }
            when 3 {
                return QUARTER_3_SHORT;
            }
            when 4 {
                return QUARTER_4_SHORT;
            }
        }

        throw new IllegalArgumentException('Invalid quarter: ' + String.valueOf(quarter));
    }

    /**
     * @description integerOf returns an integer from the quarter string.
     * @param  quarter Quarter string
     * @return Integer
     */
    public static Integer integerOf(String quarter) {
        switch on quarter.toUpperCase() {
            when 'ALL QUARTERS', 'ALL', '0', 'ZERO', 'YEAR' {
                return 1;
            }
            when 'QUARTER 1', 'Q1', '1', 'ONE' {
                return 1;
            }
            when 'QUARTER 2', 'Q2', '2', 'TWO' {
                return 2;
            }
            when 'QUARTER 3', 'Q3', '3', 'THREE' {
                return 3;
            }
            when 'QUARTER 4', 'Q4', '4', 'FOUR' {
                return 4;
            }
        }

        throw new IllegalArgumentException('Invalid quarter: ' + quarter);
    }

    /**
     * @description listQuarters returns a list of strings of quarter names.
     * @return List<String>
     */
    public static List<String> listQuarters() {
        return new List<String>{ QUARTER_1, QUARTER_2, QUARTER_3, QUARTER_4, QUARTER_ALL };
    }

    /**
     * @description listQuartersShort returns a list of strings of quarter short names.
     * @return List<String>
     */
    public static List<String> listQuartersShort() {
        return new List<String>{ QUARTER_1_SHORT, QUARTER_2_SHORT, QUARTER_3_SHORT, QUARTER_4_SHORT, QUARTER_ALL_SHORT };
    }
}