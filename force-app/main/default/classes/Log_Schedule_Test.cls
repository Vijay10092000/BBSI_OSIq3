/**
 * @description Log_Schedule_Test contains tests for the Log_Schedule class.
 */
@IsTest
public without sharing class Log_Schedule_Test {
    /*
     * CRON_EXP set to 1 January 2090 at 01:01:01.  For the most part, the given
     * time does not matter during the testing.  But, don't make it too short
     * or too often. The stopTest() will call the job, then end it.
     */
    private static final String CRON_EXP = '0 0 1 1 * ?';

    /**
     * NAME_TEST_JOB is a name for the scheduled job
     */
    private static final String NAME_TEST_JOB = 'TestLogSchedule';

    @IsTest
    static void test_Schedule() {
		Log.logSeverity = Log.Severity.INFO;

		Log.info('App 1', 'NEW Info 1', 'Additional 1');
		Log.warn('App 2', 'NEW Warn 2', 'Additional 2');
		Log.error('App 3', 'NEW Error 3', 'Additional 3');
		Log.history('HISTORY', 'NEW History 4', 'Additional 4');

		Log.info('App 1', 'OLD Info 1', 'Additional 1');
		Log.warn('App 2', 'OLD Warn 2', 'Additional 2');
		Log.error('App 3', 'OLD Error 3', 'Additional 3');
		Log.history('HISTORY', 'OLD History 4', 'Additional 4');

		DateTime dtOld = DateTime.newInstance(2000, 1, 1);
		for (Log__c log : [SELECT Id FROM Log__c WHERE Subject__c LIKE 'OLD%']) {
			Test.setCreatedDate(log.Id, dtOld);
		}

		List<Log__c> logs = Log_Test.recentLogs(dtOld.addDays(-1));
		Assert.areEqual(8, logs.size(), 'Number of Log records written');

        Test.startTest();

        String jobId = System.schedule(NAME_TEST_JOB, CRON_EXP, new Log_Schedule());

        CronTrigger cronTrigger = [
            SELECT Id, CronExpression, TimesTriggered, NextFireTime
            FROM CronTrigger
            WHERE Id = :jobId
        ];
        Assert.areEqual(CRON_EXP, cronTrigger.CronExpression, 'Incorrect schedule');
        Assert.areEqual(0, cronTrigger.TimesTriggered, 'Not triggered');

        Test.stopTest();

		logs = Log_Test.recentLogs(dtOld.addDays(-1));
		Assert.areEqual(6, logs.size(), '1 info and 1 warn Removed');
	}
}