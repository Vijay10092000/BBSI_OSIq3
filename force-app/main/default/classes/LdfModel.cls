/**
 * @description LdfModel contains code to determine the Loss Development Factor (LDF) Rate.
 */
public with sharing class LdfModel {
	@TestVisible
	private static Map<String, Map<Integer, Decimal>> mapLdfRates;

	@TestVisible
	private static final Integer MONTHS_MININUM = 12;
	@TestVisible
	private static final Integer MONTHS_MAXINUM = 190;

	// Used to force a test rate when value is positive.
	public static Decimal useTestRate = -1.00;

	/**
	 * @description getLdfRate calcuates the LDF Rate.  Start period date is calculated as minus 1 year then add a day.
	 * @param  stateCode     2-letter state abbreviation
	 * @param  periodEndDate End of period
	 * @return LDF rate
	 */
	public static Decimal getLdfRate(String stateCode, Date periodEndDate) {
		Date ldfStartDate = periodEndDate.addYears(-1).addDays(1);
		Integer months = Date.today().monthsBetween(ldfStartDate);

		return getLdfRate(stateCode, months);
	}

	/**
	 * @description getLdfRate calcuates the LDF Rate.
	 * @param  stateCode 2-letter state abbreviation
	 * @param  numMonths Number of months
	 * @return LDF rate
	 */
	public static Decimal getLdfRate(String stateCode, Integer numMonths) {
		if (0.0 < useTestRate) {
			return useTestRate;
		}

		loadData();

		numMonths = fixNumberMonth(numMonths);

		if (!mapLdfRates.containsKey(stateCode)) {
			stateCode = 'AOS';
		}

		if (mapLdfRates.get(stateCode).containsKey(numMonths)) {
			return mapLdfRates.get(stateCode).get(numMonths);
		}

		Log.error('LDF MODEL - LdfModel.getLdfRate()', 'LDF Rate Missing', 'Missing LDF for State: ' + stateCode + ' Month: ' + numMonths);
		throw new InvalidValueException('LDF Rates are Missing for State: ' + stateCode + ' Month: ' + numMonths);
	}

	/**
	 * @description loadData reads the LDF Rate data only once.
	 */
	@TestVisible
	private static void loadData() {
		if (mapLdfRates == null) {
			mapLdfRates = new Map<String, Map<Integer, Decimal>>();
			mapLdfRates.put('AOS', new Map<Integer, Decimal>());
			mapLdfRates.put('CA', new Map<Integer, Decimal>());

			for (LDF_Rate__c rate : [
				SELECT Name, Month__c, LDF_CA__c, LDF_AOS__c
				FROM LDF_Rate__c
			]) {
				Integer month = Integer.valueOf(rate.Month__c);

				mapLdfRates.get('AOS').put(month, rate.LDF_AOS__c);
				mapLdfRates.get('CA').put(month, rate.LDF_CA__c);
			}
		}
	}

	/**
	 * @description fixNumberMonth corrects the number of months to the correct range.
	 * @param  numMonths Number of months
	 * @return Number of months in range [MONTHS_MININUM, MONTHS_MAXINUM] inclusive.
	 */
	@TestVisible
	public static Integer fixNumberMonth(Integer numMonths) {
		if (numMonths < 0) {
			numMonths = 0 - numMonths;
		}

		if (numMonths < MONTHS_MININUM) {
			numMonths = MONTHS_MININUM;
		} else if (numMonths > MONTHS_MAXINUM) {
			numMonths = MONTHS_MAXINUM;
		}

		return numMonths;
	}
}