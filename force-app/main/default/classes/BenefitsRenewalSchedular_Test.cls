@IsTest
public without sharing class BenefitsRenewalSchedular_Test {
    private static final String CRON_EXP = '0 0 1 1 * ?';
    private static final String NAME_TEST_JOB = 'TestBenefitsSchedule';

    @IsTest
    static void test_Schedule() {
        Test.startTest();

        String jobId = System.schedule(NAME_TEST_JOB, CRON_EXP, new BenefitsRenewalScheduler());

        CronTrigger cronTrigger = [
            SELECT Id, CronExpression, TimesTriggered, NextFireTime
            FROM CronTrigger
            WHERE Id = :jobId
        ];
        Assert.areEqual(CRON_EXP, cronTrigger.CronExpression, 'Incorrect schedule');
        Assert.areEqual(0, cronTrigger.TimesTriggered, 'Not triggered');

        Test.stopTest();

        // Unable to ASSERT at this time.  The scheduled job has finished,
        // but the batch processing is incomplete.  At present, there is not
        // a tread sleep method to wait for the batch processing to finish.
    }

}