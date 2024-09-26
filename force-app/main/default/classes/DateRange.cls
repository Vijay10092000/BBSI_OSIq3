/**
 * @description DateRange handles a range of dates.
 */
public without sharing class DateRange {
    /**
     * @description dateFrom is the start date of the range.
     */
    public Date dateFrom { get; private set; }

    /**
     * @description dateTo is the end date of the range.
     */
    public Date dateTo { get; private set; }

    /**
     * @description DateRange constructor.
     * @param date1 First date in the range
     * @param date2 Second date in the range
     */
    public DateRange(Date date1, Date date2) {
        if (date1 < date2) {
            dateFrom = date1;
            dateTo = date2;
        } else {
            dateFrom = date2;
            dateTo = date1;
        }
    }

    /**
     * @description DateRange constructor.
     * @param year1  Year which starts the range
     * @param month1 Month which starts the range. Ranges starts on day 1 of this month
     * @param year2  Year which ends the range
     * @param month2 Month which starts the range. Ranges ends on last day of this month
     */
    public DateRange(Integer year1, Integer month1, Integer year2, Integer month2) {
        if (year1 < year2 || (year1 == year2 && month1 <= month2)) {
            dateFrom = Date.newInstance(year1, month1, 1);
            dateTo = Date.newInstance(year2, month2, Date.daysInMonth(year2, month2));
        } else {
            throw new IllegalArgumentException('Dates are out of order');
        }
    }

    /**
     * @description numberDays retrieves the number of days in the range.
     * @return Integer
     */
    public Integer numberDays() {
        return dateFrom.daysBetween(dateTo) + 1;
    }

    /**
     * @description weeksInRange calculates the number of weeks in the current range.
     * Weeks start on SUNDAY and end on SATURDAY.  Partial weeks are counted a the start
     * and end of the range.
     * @return Number of weeks in range
     */
    public Integer weeksInRange() {
        Date dateStart = Date_Service.startOfWeek(dateFrom);
        Date dateStop = Date_Service.endOfWeek(dateTo);

        return (dateStart.daysBetween(dateStop) + 1) / 7;
    }

    /**
     * @description isPartialFirstWeek determines if the ranges starts on SUNDAY
     * and is at least 7 days long.
     * @return Boolean
     */
    public Boolean isFullFirstWeek() {
        return 7 <= numberDays() && Date_Service.Weekday.SUNDAY == Date_Service.getWeekday(dateFrom);
    }

    /**
     * @description isFullLastWeek determines if the ranges ends on SATURDAY
     * and is at least 7 days long.
     * @return Boolean
     */
    public Boolean isFullLastWeek() {
        return 7 <= numberDays() && Date_Service.Weekday.SATURDAY == Date_Service.getWeekday(dateFrom);
    }

    /**
     * @description contains determines if the given Date is this range.
     * @param dateCheck Date testing
     * @return Boolean
     */
    public Boolean contains(Date dateCheck) {
        return dateFrom <= dateCheck && dateCheck <= dateTo;
    }

    /**
     * @description isBefore determines if the given Date is before this range.
     * @param dateCheck Date testing
     * @return Boolean
     */
    public Boolean isBefore(Date dateCheck) {
        return dateTo < dateCheck;
    }

    /**
     * @description isAfter determines if the given Date is after this range.
     * @param dateCheck Date testing
     * @return Boolean
     */
    public Boolean isAfter(Date dateCheck) {
        return dateCheck < dateFrom;
    }

    /**
     * @description contains determines if the given DateRange is completely in this range.
     * @param rangeCheck DateRange testing
     * @return Boolean
     */
    public Boolean contains(DateRange rangeCheck) {
        return dateFrom <= rangeCheck.dateFrom && rangeCheck.dateTo <= dateTo;
    }

    /**
     * @description overlaps determines if the any part of the given DateRange is in this range.
     * @param rangeCheck DateRange testing
     * @return Boolean
     */
    public Boolean overlaps(DateRange rangeCheck) {
        return contains(rangeCheck.dateFrom) || contains(rangeCheck.dateTo);
    }

    /**
     * @description isBefore determines if the whole given DateRage is before this range.
     * @param rangeCheck DateRange testing
     * @return Boolean
     */
    public Boolean isBefore(DateRange rangeCheck) {
        return dateTo < rangeCheck.dateFrom;
    }

    /**
     * @description isAfter determines if the whole given DateRage is after this range.
     * @param rangeCheck DateRange testing
     * @return Boolean
     */
    public Boolean isAfter(DateRange rangeCheck) {
        return rangeCheck.dateTo < dateFrom;
    }
}