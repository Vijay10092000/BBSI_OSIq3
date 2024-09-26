/**
 * @description updatePayDay
 */
public class updatePayDay {
	private static final Map<String, String> mapToWeekDay = new Map<String, String> {
		'0' => 'Sunday',
		'1' => 'Monday',
		'2' => 'Tuesday',
		'3' => 'Wednesday',
		'4' => 'Thursday',
		'5' => 'Friday',
		'6' => 'Saturday'
	};

	/**
	 * @description findPayDays runs through the list and converts a day number to day name for
	 * Pay Periods: Weekly and Bi-weekly.
	 * @param  payrolls List of Payroll__c
	 */
	public void findPayDays(List<Payroll__c> payrolls) {
		for (Payroll__c p : payrolls) {
			if (p.Pay_Period__c == 'B' || p.Pay_Period__c == 'W') {
				if (mapToWeekDay.containsKey(p.Payday__c)) {
					p.Payday__c = mapToWeekDay.get(p.Payday__c);
				}
			}
		}
	}
}