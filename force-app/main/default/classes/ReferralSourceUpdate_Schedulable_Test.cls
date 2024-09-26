/**
 * ReferralSourceUpdate_Schedulable_Test contains test for the
 * ReferralSourceUpdate_Schedulable and ReferralSourceUpdate_Batch
 * classes.
 */
@IsTest
public without sharing class ReferralSourceUpdate_Schedulable_Test {

    /*
     * CRON_EXP set to 1 January 2090 at 01:01:01.  For the most part, the given
     * time does not matter during the testing.  But, don't make it too short
     * or too often. The stopTest() will call the job, then end it.
     */
    private static final String CRON_EXP = '0 0 1 1 * ?';

    /**
     * NAME_TEST_JOB is a name for the scheduled job
     */
    private static final String NAME_TEST_JOB = 'TestReferralSourceUpdate';

    @isTest
    static void test_Schedule() {
        Test.startTest();

        String jobId = System.schedule(NAME_TEST_JOB, CRON_EXP, new ReferralSourceUpdate_Schedulable());

        CronTrigger cronTrigger = [
            SELECT Id, CronExpression, TimesTriggered, NextFireTime
            FROM CronTrigger 
            WHERE Id = :jobId
        ];
        Assert.areEqual(CRON_EXP, cronTrigger.CronExpression);
        Assert.areEqual(0, cronTrigger.TimesTriggered);

        Test.stopTest();

        // Unable to ASSERT at this time.  The scheduled job has finished,
        // but the batch processing is incomplete.  At present, there is not
        // a tread sleep method to wait for the batch processing to finish.
    }
    
}