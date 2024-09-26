/**
 * @description DataType_Utility contains methods to handle Data Types.
 */
@SuppressWarnings('PMD.ApexDoc')
public without sharing class DataType_Utility {

	public static Blob onNull(Blob value, Blob standard) {
		return (value == null) ? standard : value;
	}

	public static Integer onNull(Integer value, Integer standard) {
		return (value == null) ? standard : value;
	}

	public static Long onNull(Long value, Long standard) {
		return (value == null) ? standard : value;
	}

	public static Decimal onNull(Decimal value, Decimal standard) {
		return (value == null) ? standard : value;
	}

	public static Double onNull(Double value, Double standard) {
		return (value == null) ? standard : value;
	}

	public static String onNull(String value, String standard) {
		return (value == null) ? standard : value;
	}

	public static Boolean onNull(Boolean value, Boolean standard) {
		return (value == null) ? standard : value;
	}

	public static Id onNull(Id value, Id standard) {
		return (value == null) ? standard : value;
	}

	public static Date onNull(Date value, Date standard) {
		return (value == null) ? standard : value;
	}

	public static Object onNull(Object value, Object standard) {
		return (value == null) ? standard : value;
	}

	public static DateTime onNull(DateTime value, DateTime standard) {
		return (value == null) ? standard : value;
	}

	public static Time onNull(Time value, Time standard) {
		return (value == null) ? standard : value;
	}

	public static SObject onNull(SObject value, SObject standard) {
		return (value == null) ? standard : value;
	}
}