@isTest
public class RenewalDateOpportunityTest {
    public static String CRON_EXP = '0 0 1 1 * ?';

    @isTest static void test_method_one() {
        Test.startTest();

        // Account Prospect = TestFactory.createAccount('Test Branch', '98662', 'Prospect', true);
        Account Prospect = TestFactoryAccount.createProspect('Test Branch', null, null);

        // Opportunity o = TestFactory.createOpportunity('Opportunity Renewal Test', Prospect, System.today(), 'Identifiying', false);
        Opportunity o = TestFactoryOpportunity.makeClient('Opportunity Renewal Test', Prospect.Id, System.today(), 'Identifiying');
        o.Renewal_Date__c = System.today();
        o.Amount = 1000000;   // Set field: Estimated Annual Billing
        insert o;

        Date d = date.newInstance(o.Renewal_Date__c.Year()+1, o.Renewal_Date__c.Month(), o.Renewal_Date__c.Day());

        if([SELECT Id, Name FROM CronJobDetail where name = 'RenewalDateOpportunity'].size() > 0){
            ID checkJob = [SELECT Id, Name FROM CronJobDetail where name = 'RenewalDateOpportunity' limit 1].ID;
            System.debug('Chceck Job: ' + checkJob);
            System.abortJob([SELECT Id FROM CronTrigger WHERE CronJobDetailID = :checkJob].ID);
        }

        // Schedule the test job
        String jobId = System.schedule('RenewalDateOpportunity',
                                       CRON_EXP,
                                       new RenewalDateOpportunity());

        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered,
                          NextFireTime
                          FROM CronTrigger WHERE id = :jobId];

        // Verify the expressions are the same
        Assert.areEqual(CRON_EXP,
                            ct.CronExpression);

        // Verify the job has not run
        Assert.areEqual(0, ct.TimesTriggered);

        // Verify the scheduled job hasn't run yet.
        o = [Select Renewal_Date__c from Opportunity where ID =: o.ID limit 1];
        Assert.areEqual(o.Renewal_Date__c, System.today());
        Test.stopTest();

        // Now that the scheduled job has executed after Test.stopTest(),
        //   fetch the new merchandise that got added.
        o = [Select Renewal_Date__c from Opportunity where ID =: o.ID limit 1];

        Assert.areEqual(d,o.Renewal_Date__c);
    }
}