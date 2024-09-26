/**
 * @description Log_Schedule
 */
public without sharing class Log_Schedule implements Schedulable {
	private static final Integer MONTHS_OLD = 2;

	/**
	 * @description execute deletes all non-critial Log message older than MONTHS_OLD.
	 * @param  sc  Job Content
	 */
	public void execute(SchedulableContext sc) {
		DateTime limitDateTime = System.now().addMonths(0 - MONTHS_OLD);

		List<Log__c> logs = [
			SELECT Id
			FROM Log__c
			WHERE CreatedDate < :limitDateTime
			AND Severity__c != 'Error'
			AND Severity__c != 'History'
			ORDER BY CreatedDate ASC
			LIMIT 1000
		];

		if (!logs.isEmpty()) {
			System.debug(LoggingLevel.FINE, 'Log_Schedule: Number of Logs to delete: ' + logs.size());
			delete logs;
		}
	}
}