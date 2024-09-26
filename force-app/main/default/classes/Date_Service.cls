/**
 * @description Date_Service
 *
 * The weekday methods added have the start of the week being SUNDAY.
 * Dates before 7 January 1900 may not work correctly.
 * 
 * TODO: FUTURE: Determine how to handle HOIDAYS
 */
public without sharing class Date_Service {
	private static final Date DATE_WEEKDAY_START = Date.newInstance(1900, 1, 7);

	private static final List<String> DAYS_SHORT = new List<String>{
		'SUN',
		'MON',
		'TUE',
		'WED',
		'THU',
		'FRI',
		'SAT'
	};

	private static final List<String> MONTHS_SHORT = new List<String>{
		'JAN',
		'FEB',
		'MAR',
		'APR',
		'MAY',
		'JUN',
		'JUL',
		'AUG',
		'SEP',
		'OCT',
		'NOV',
		'DEC'
	};

	public enum Weekday {
		SUNDAY,
		MONDAY,
		TUESDAY,
		WEDNESDAY,
		THURSDAY,
		FRIDAY,
		SATURDAY
	}

	public enum Month {
		JANUARY,
		FEBRUARY,
		MARCH,
		APRIL,
		MAY,
		JUNE,
		JULY,
		AUGUST,
		SEPTEMBER,
		OCTOBER,
		NOVEMBER,
		DECEMBER
	}

	/**
	 * @description getWeekdayName retrieves the name of the week day
	 * @param  weekday Weekday enum value
	 * @return String
	 */
	public static String getWeekdayName(Weekday weekday) {
		return weekday.name().toLowerCase().capitalize();
	}

	/**
	 * @description getWeekdayName retrieves the 3 character abbreviation for the name of the week day
	 * @param  weekday Weekday enum value
	 * @return String
	 */
	public static String getWeekdayNameShort(Weekday weekday) {
		return DAYS_SHORT.get(weekday.ordinal());
	}

	/**
	 * @description getWeekday retrieves Weekday enum related to the given date.
	 * @param  dateCheck  Date looking at
	 * @return Weekday enum
	 */
	public static Weekday getWeekday(Date dateCheck) {
		Integer index = Math.mod(DATE_WEEKDAY_START.daysBetween(dateCheck), 7);

		return getWeekday(index);
	}

	/**
	 * @description getWeekday retrieves Weekday enum based on the ordinal day (Sunday = 0).
	 * @param  ordinal  Day of week as number
	 * @return Weekday enum
	 */
	public static Weekday getWeekday(Integer ordinal) {
		for (Date_Service.Weekday enumValue : Date_Service.Weekday.values()) {
			if (enumValue.ordinal() == ordinal) {
				return enumValue;
			}
		}
		return null;
	}

	/**
	 * @description getWeekday retrieves Weekday enum based on the ordinal day (Sunday = 0).
	 * @param  ordinal  Day of week as number
	 * @return Weekday enum
	 */
	public static String getWeekdayName(Integer ordinal) {
		for (Date_Service.Weekday enumValue : Date_Service.Weekday.values()) {
			if (enumValue.ordinal() == ordinal) {
				return enumValue.name();
			}
		}
		return null;
	}

	/**
	 * @description getWeekday retrieves Weekday enum based name of day.
	 * @param  name  Name of the day
	 * @return Weekday enum
	 */
	public static Weekday getWeekday(String name) {
		name = name.toUpperCase();

		for (Date_Service.Weekday enumValue : Date_Service.Weekday.values()) {
			if (enumValue.name() == name) {
				return enumValue;
			}
		}
		return null;
	}

	/**
	 * @description startOfWeek determines the Sunday on or before the given date.
	 * @param  dateCheck  Day looking at
	 * @return Date
	 */
	public static Date startOfWeek(Date dateCheck) {
		Integer offset = Math.mod(DATE_WEEKDAY_START.daysBetween(dateCheck), 7);

		return dateCheck.addDays(0 - offset);
	}

	/**
	 * @description endOfWeek determines the Saturday on or after the given date.
	 * @param  dateCheck  Day looking at
	 * @return Date
	 */
	public static Date endOfWeek(Date dateCheck) {
		Integer offset = Math.mod(DATE_WEEKDAY_START.daysBetween(dateCheck), 7);

		return dateCheck.addDays(6 - offset);
	}

	/**
	 * @description getMonthNumber determines the number of the given month (1- 12).
	 * @param  month  Full String month name
	 * @return 1-12
	 */
	public static Integer getMonthNumber(String month) {
		return 1 + (Date_Service.Month.valueOf(month.toUpperCase())).ordinal();
	}

	/**
	 * @description getMonthName retrieves the name of the week day
	 * @param  month  Month enum value
	 * @return String
	 */
	public static String getMonthName(Month month) {
		return month.name().toLowerCase().capitalize();
	}

	/**
	 * @description getMonthName retrieves name of the month on the omonth number (January = 1).
	 * @param  ordinal  Number of month (1-12)
	 * @return Name of Month
	 */
	public static String getMonthName(Integer ordinal) {
		--ordinal;

		for (Date_Service.Month enumValue : Date_Service.Month.values()) {
			if (enumValue.ordinal() == ordinal) {
				return enumValue.name();
			}
		}
		return null;
	}

	/**
	 * @description getMonthNameShort retrieves the name of the month first letter capitolized.
	 * @param  month   Month enum value
	 * @return String
	 */
	public static String getMonthNameShort(Month month) {
		return MONTHS_SHORT.get(month.ordinal());
	}

	/**
	 * @description maxDate determines the maximum between two dates.
	 * @param  date1 First date
	 * @param  date2 Second date
	 * @return Date
	 */
	public static Date maxDate(Date date1, Date date2) {
		if (date1 > date2) {
			return date1;
		}
		return date2;
	}

	/**
	 * @description maxDate determines highest date from the given list.
	 * @param  dates  Dates looking at
	 * @return Date
	 */
	public static Date maxDate(List<Date> dates) {
		if (!dates.isEmpty()) {
			Date max = dates.get(0);

			for (Date test : dates) {
				if (max < test) {
					max = test;
				}
			}

			return max;
		}
		return null;
	}

	/**
	 * @description minDate determines the minimum between two dates.
	 * @param  date1 First date
	 * @param  date2 Second date
	 * @return Date
	 */
	public static Date minDate(Date date1, Date date2) {
		if (date1 < date2) {
			return date1;
		}
		return date2;
	}

	/**
	 * @description minDate determines lowest date from the given list.
	 * @param  dates  Dates looking at
	 * @return Date
	 */
	public static Date minDate(List<Date> dates) {
		if (!dates.isEmpty()) {
			Date min = dates.get(0);

			for (Date test : dates) {
				if (min > test) {
					min = test;
				}
			}

			return min;
		}
		return null;
	}

	/**
	 * @description getYearMonthDifference creates a string indicating the number of years
	 * and months between the two dates.  The dateStart must be before the dateEnd value.
	 * @param  dateStart dateStart description
	 * @param  dateEnd   dateEnd description
	 * @return A string in the form '# Year[s][ - # Month[s]]' or on error '-- Invalid Dates --'
	 */
	public static String getYearMonthDifference(Date dateStart, Date dateEnd) {
		String result = '';

		if (dateStart != null && dateEnd != null && dateStart < dateEnd) {
			Integer diffYears = dateEnd.year() - dateStart.year();
			Integer diffMonths = Math.Mod(12 + dateEnd.month() - dateStart.month(), 12);

			if (diffYears > 0) {
				result = diffYears + ' Year';

				if (diffYears > 1) {
					result += 's';
				}
			}
			if (diffMonths > 0) {
				if (!String.isEmpty(result)) {
					result += ' - ';
				}
				result += diffMonths + ' Month';

				if (diffMonths > 1) {
					result += 's';
				}
			}

			if (String.isEmpty(result)) {
				result = '0 Months';
			}
		} else {
			result = '-- Invalid Dates --';
		}

		return result;
	}

	/**
	 * @description toYearMonthDay converts the date to a String of format YYYY-MM-DD.
	 * @param  workDate  Date to convert
	 * @return String of date
	 */
	public static String toYearMonthDay(DateTime workDate) {
		return workDate.format('yyyy-MM-dd');
	}

	/**
	 * @description toYearMonthDay converts the date to a String of format YYYY-MM-DD.
	 * @param  workDate  Date to convert
	 * @return String of date
	 */
	public static String toYearMonthDay(Date workDate) {
		return toYearMonthDay(DateTime.newInstance(workDate.year(), workDate.month(), workDate.day()));
	}

	/**
	 * @description addWeekdays adds the number of weekdays to the given Date
	 * @param  workDate  Start Date
	 * @param  count     Number of workdays to offset
	 * @return New Date
	 */
	public static Date addWeekdays(Date workDate, Integer count) {
		Date result = workDate;
		Integer fullWeeks;

		Weekday wd = getWeekday(result);

		if (0 < count) {
			if (wd == WeekDay.SATURDAY) {
				result = result.addDays(-1);
			}
			if (wd == WeekDay.SUNDAY) {
				result = result.addDays(-2);
			}

			// After given Date
			fullWeeks = count / 5;
			result = result.AddDays((7 * fullWeeks));
			count -= (5 * fullWeeks);

			while (0 < count) {
				count--;

				wd = getWeekday(result);

				if (wd == WeekDay.FRIDAY) {
					result = result.AddDays(3);
				} else {
					result = result.AddDays(1);
				}
			}
		}
		else if (count < 0) {
			if (wd == WeekDay.SATURDAY) {
				result = result.addDays(2);
			}
			if (wd == WeekDay.SUNDAY) {
				result = result.addDays(1);
			}

			// Before given Date\
			fullWeeks = (0 - count) / 5;
			result = result.AddDays(0 - (7 * fullWeeks));
			count += (5 * fullWeeks);

			while (count < 0) {
				count++;

				wd = getWeekday(result);

				if (wd == WeekDay.MONDAY) {
					result = result.AddDays(-3);
				} else {
					result = result.AddDays(-1);
				}
			}
		}

		return result;
	}

	/**
	 * @description toDate converts a DateTime to Date.
	 * @param  dt  DateTime converting
	 * @return Date
	 */
	public static Date toDate(DateTime dt) {
		return date.newInstance(dt.year(), dt.month(), dt.day());
	}

	/**
	 * @description nearestNonWeekend returns the nearest non-Weekend.
	 * @param  day  Date working with
	 * @return Date
	 */
	public static Date nearestNonWeekend(Date day) {
		switch on getWeekday(day) {
			when SATURDAY {
				return day.addDays(-1);
			}
			when SUNDAY {
				return day.addDays(1);
			}
		}
		return Date.newInstance(day.year(), day.month(), day.day());
	}

	/**
	 * @description nextNonWeekend returns the next non-Weekend.  For weekdays the 
	 * next non-Weekend is the same date.
	 * @param  datdaye  Date working with
	 * @return Date
	 */
	public static Date nextNonWeekend(Date day) {
		switch on getWeekday(day) {
			when SATURDAY {
				return day.addDays(2);
			}
			when SUNDAY {
				return day.addDays(1);
			}
		}
		return Date.newInstance(day.year(), day.month(), day.day());
	}
}