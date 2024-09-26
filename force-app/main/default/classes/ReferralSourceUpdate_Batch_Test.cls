/**
 * @description ReferralSourceUpdate_Batch_Test contains test for ReferralSourceUpdate_Batch
 */
@IsTest
public without sharing class ReferralSourceUpdate_Batch_Test {
    /**
     * @description testReferralSourceUpdate_Batch runs the batch.
     */
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    @IsTest
    static void testReferralSourceUpdate_Batch() {
        Test.startTest();

        ReferralSourceUpdate_Batch batch = new ReferralSourceUpdate_Batch();
        DataBase.executeBatch(batch);

        Test.stopTest();
    }

    /**
     * @description test_execute runs the execute().
     */
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    @IsTest
    static void test_execute() {
        Test.startTest();

        ReferralSourceUpdate_Batch batch = new ReferralSourceUpdate_Batch();
        batch.execute(null, new List<Referral_Partner_Change_Request__c>());

        Test.stopTest();
    }

    /**
     * @description test_sendExceptionEmail sends the exception email.
     */
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    @IsTest
    static void test_sendExceptionEmail() {
        Test.startTest();

        try {
            throw new InvalidValueException('There is bad stuff happening.');
        } catch (Exception e) {
            ReferralSourceUpdate_Batch batch = new ReferralSourceUpdate_Batch();
            batch.sendExceptionEmail(e);
        }

        Test.stopTest();
    }

    /**
     * @description test_buildExceptionEmail runs the batch.
     */
    @IsTest
    static void test_buildExceptionEmail() {
        String bodySandbox;
        String bodyProduction;

        Test.startTest();

        try {
            throw new InvalidValueException('There is bad stuff happening.');
        } catch (Exception e) {
            ReferralSourceUpdate_Batch batch = new ReferralSourceUpdate_Batch();
            bodySandbox = batch.buildExceptionEmail('Fake', e);
            bodyProduction = batch.buildExceptionEmail(null, e);
        }

        Test.stopTest();

        System.assertNotEquals(null, bodySandbox, 'Sandbox email body should have been created');
        System.assert(bodySandbox.startsWith('SANDBOX'), 'Body should start with SANDBOX');

        System.assertNotEquals(null, bodyProduction, 'Production email body should have been created');
        System.assert(bodyProduction.startsWith('PRODUCTION'), 'Body should start with PRODUCTION');
    }

    @IsTest
    static void test_BatchError() {
        ReferralPartner_TestEnv testEnv = new ReferralPartner_TestEnv();
        testEnv.build();
        testEnv.read();

        Date today = Date.today();
        Date tomorrow = today.addDays(1);

        Referral_Partner_Change_Request__c rpcr1 = new Referral_Partner_Change_Request__c(
            RecordTypeId = ReferralPartnerChange_Const.idrtHoldClient,
            Client__c = testEnv.client11.Id,
            Effective_Date__c = tomorrow,
            Comments__c = 'Hold',
            Status__c = 'Approved',
            Product_Line__c = ReferralPartnerChange_Const.PLTYPE_WORKERSCOMP
        );

        Referral_Partner_Change_Request__c rpcr2 = new Referral_Partner_Change_Request__c(
            RecordTypeId = ReferralPartnerChange_Const.idrtReleaseHoldClient,
            Client__c = testEnv.client11.Id,
            Effective_Date__c = tomorrow,
            Comments__c = 'Release Hold',
            Status__c = 'Approved',
            Product_Line__c = ReferralPartnerChange_Const.PLTYPE_WORKERSCOMP
        );

        List<Referral_Partner_Change_Request__c> requests = new List<Referral_Partner_Change_Request__c>{
            rpcr1,
            rpcr2
        };

        System.RunAs(testEnv.sysAdmin) {
            try {
                insert requests;
            } catch (Exception e) {
                System.assert(false, 'Insert Failed: ' + e.getMessage());
            }

            delete [
                SELECT Id
                FROM Referral_Partner__c
                WHERE Account__c = :testEnv.Client11.Id
            ];

            rpcr1.Effective_Date__c = today;
            rpcr1.Status__c = 'Approved';
            rpcr2.Effective_Date__c = today;
            rpcr2.Status__c = 'Approved';

            update requests;
        }

        Test.startTest();

        ReferralSourceUpdate_Batch batch = new ReferralSourceUpdate_Batch();
        batch.execute((Database.BatchableContext) null, requests);

        test.stopTest();

        System.assertEquals(1, Email_Service.testEmails.size(), 'Should have failed');
    }
}