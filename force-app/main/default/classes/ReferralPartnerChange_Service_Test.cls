/**
 * ReferralPartnerChange_Service_Test contains test for the
 * ReferralPartnerChange_Service class.
 */
@IsTest
@SuppressWarnings('PMD.ApexAssertionsShouldIncludeMessage, PMD.ApexDoc')
public without sharing class ReferralPartnerChange_Service_Test {
    private static ReferralPartner_TestEnv testEnv = new ReferralPartner_TestEnv();

    /**
     * makeData creates common test data for all tests in this file.
     */
    @TestSetup
    static void makeData() {
        test.startTest();
        testEnv.build();
        test.stopTest();
    }

    /**
     * getData sets the static variables for use in the tests
     */
    @SuppressWarnings('PMD.ApexUnitTestMethodShouldHaveIsTestAnnotation')
    static void getData() {
        testEnv.read();
    }

    /**
     * testTriggerHandler performs a quick run through of all the
     * Trigger events.
     */
    @IsTest
    static void testTriggerHandler() {
        getData();

        Referral_Partner_Change_Request__c rpcr = new Referral_Partner_Change_Request__c(
            RecordTypeId = ReferralPartnerChange_Const.idrtHoldClient,
            Client__c = testEnv.client11.Id,
            Referral_Partner__c = testEnv.partner1.Id,
            Effective_Date__c = Date.today().addDays(7),
            Override__c = false,
            Comments__c = 'Insert Testing',
            Status__c = 'Approved', 
            Product_Line__c = ReferralPartnerChange_Const.PLTYPE_WORKERSCOMP
        );

        insert rpcr;
        rpcr = [SELECT Id, Name, Comments__c FROM Referral_Partner_Change_Request__c WHERE Id = :rpcr.Id];
        System.assertNotEquals(null, rpcr, 'Referral Partner Change Request not found');
        System.assertEquals('Insert Testing', rpcr.Comments__c, 'Comment did not come through');

        rpcr.Comments__c = 'Update Testing';
        update rpcr;
        rpcr = [SELECT Id, Name, Comments__c FROM Referral_Partner_Change_Request__c WHERE Id = :rpcr.Id];
        System.assertNotEquals(null, rpcr, 'Referral Partner Change Request not found');
        System.assertEquals('Update Testing', rpcr.Comments__c, 'Comment did not come through');

        delete rpcr;
        Map<Id, Referral_Partner_Change_Request__c> rpcrs = new Map<Id, Referral_Partner_Change_Request__c>( [ SELECT Id, Name, Comments__c FROM Referral_Partner_Change_Request__c WHERE Id = :rpcr.Id] );
        System.assertEquals(0, rpcrs.size(), 'Referral Source should have been deleted.');

        undelete rpcr;
        rpcr = [SELECT Id, Name, Comments__c FROM Referral_Partner_Change_Request__c WHERE Id = :rpcr.Id];
        System.assertNotEquals(null, rpcr, 'Referral Partner Change Request not found');
        System.assertEquals('Update Testing', rpcr.Comments__c, 'Comment did not come through');
    }

    @IsTest
    static void testGroupChangeRequestAsAreaManager() {
        getData();

        testEnv.partner1.Referral_Partner_Group__c = null;

        Boolean exceptionThrown = false;
        String exceptionMessage;

        Test.startTest();

        try {
            System.runAs(testEnv.areaManager) {
                update new List<Account> { testEnv.partner1 };
            }
        }
        catch (Exception e) {
            exceptionThrown = true;
            exceptionMessage = e.getMessage();
        }

        Test.stopTest();

        System.assertEquals(true, exceptionThrown, 'An exception should have been thrown.');
        System.assertEquals(true, exceptionMessage.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'), 'Should have failed because of a Validation Rule.');
    }

    @IsTest
    static void testCheckAutoApprove() {
        getData();

        Referral_Partner_Change_Request__c rpcrAutoApprove = new Referral_Partner_Change_Request__c(
            RecordTypeId = RecordTypeService.getId('Referral_Partner_Change_Request__c','Hold Request - Client'),
            Comments__c = 'Test RPCR to Approved',
            Effective_Date__c = System.today().addDays(-3),
            Status__c = 'Pre-Approval',
            OwnerId = testEnv.rpAdmin.Id, 
            Product_Line__c = ReferralPartnerChange_Const.PLTYPE_WORKERSCOMP
        );

        Referral_Partner_Change_Request__c rpcrNoAutoApprove = new Referral_Partner_Change_Request__c(
            RecordTypeId = RecordTypeService.getId('Referral_Partner_Change_Request__c','Hold Request - Client'),
            Comments__c = 'Test RPCR remains Pre-Approval',
            Effective_Date__c = System.today().addDays(-3),
            Status__c = 'Pre-Approval',
            OwnerId = testEnv.bdm.Id, 
            Product_Line__c = ReferralPartnerChange_Const.PLTYPE_WORKERSCOMP
        );

        Referral_Partner_Change_Request__c rpcrRejected = new Referral_Partner_Change_Request__c(
            RecordTypeId = RecordTypeService.getId('Referral_Partner_Change_Request__c','Hold Request - Client'),
            Comments__c = 'Test RPCR remains Rejected',
            Effective_Date__c = System.today().addDays(-3),
            Status__c = 'Rejected',
            OwnerId = testEnv.rpAdmin.Id, 
            Product_Line__c = ReferralPartnerChange_Const.PLTYPE_WORKERSCOMP
        );

        List<Referral_Partner_Change_Request__c> listNew = new List<Referral_Partner_Change_Request__c>{ rpcrAutoApprove, rpcrNoAutoApprove, rpcrRejected };

        Test.startTest();

        ReferralPartnerChange_Service.checkAutoApprove(null, listNew);

        Test.stopTest();

        System.assertEquals('Approved', rpcrAutoApprove.Status__c, 'Status not incorrectly set.');
        System.assertEquals('Pre-Approval', rpcrNoAutoApprove.Status__c, 'Status not incorrectly set.');
        System.assertEquals('Rejected', rpcrRejected.Status__c, 'Status not incorrectly set.');
    }

    @IsTest
    static void testCheckAutoApprove2() {
        getData();

        Referral_Partner_Change_Request__c rpcrAutoApprove = new Referral_Partner_Change_Request__c(
            RecordTypeId = RecordTypeService.getId('Referral_Partner_Change_Request__c','Hold Request - Client'),
            Comments__c = 'Test RPCR to Approved',
            Effective_Date__c = System.today().addDays(-3),
            Status__c = 'Pre-Approval',
            OwnerId = testEnv.rpAdmin.Id,
            Client__c = testEnv.client11.Id,
            Referral_Partner__c = testEnv.partner1.Id, 
            Product_Line__c = ReferralPartnerChange_Const.PLTYPE_WORKERSCOMP
        );
        Referral_Partner_Change_Request__c rpcrAutoApprove1 = new Referral_Partner_Change_Request__c(
            RecordTypeId = RecordTypeService.getId('Referral_Partner_Change_Request__c','Hold Request - Client'),
            Comments__c = 'Test RPCR to Approved',
            Effective_Date__c = System.today().addDays(-3),
            Status__c = 'Pre-Approval',
            OwnerId = testEnv.rpAdmin.Id,
            Client__c = testEnv.client11.Id,
            Referral_Partner__c = testEnv.partner1.Id, 
            Product_Line__c = ReferralPartnerChange_Const.PLTYPE_BENEFITS
        );

        List<Referral_Partner_Change_Request__c> listNew = new List<Referral_Partner_Change_Request__c>{ rpcrAutoApprove, rpcrAutoApprove1 };

        Test.startTest();
        System.runAs(TestEnv.rpAdmin) {
            insert rpcrAutoApprove;
        }

        Test.stopTest();

        rpcrAutoApprove = [SELECT Id, Status__c FROM Referral_Partner_Change_Request__c WHERE Id = :rpcrAutoApprove.Id];
        System.assertEquals('Performed', rpcrAutoApprove.Status__c, 'Status not incorrectly set.');

        Map<Id, List<Referral_Partner__c>> rss = ReferralSource_Service.getAccountReferralSources(new Set<Id>{ testEnv.client11.Id });
        List<Referral_Partner__c> rssClient11 = rss.get(testEnv.client11.Id);

        system.assertEquals(0, rssClient11.size(), 'A Referral Source should have been created');
        /*Referral_Partner__c rs = rssClient11.get(0);

        System.assertEquals(1, rss.size(), 'A Referral Source should have been created');
        System.assertEquals(true, rs.Hold__c, 'The Referral Source should be on Hold.');*/
    }

    @IsTest
    static void test_createNotificiationMessage() {
        getData();

		Map<Id, Account> accounts = new Map<Id, Account>{
			testEnv.client11.Id => testEnv.client11,
			testEnv.partner1.Id => testEnv.partner1
		};
		Map<Id, Referral_Partner_Group__c> groups = new Map<Id, Referral_Partner_Group__c>{
			testEnv.group1.id => testEnv.group1
		};
		Referral_Partner_Change_Request__c rpcr = new Referral_Partner_Change_Request__c(
			Status__c = 'Approved',
			Referral_Partner_Group__c = testEnv.group1.Id,
			Referral_Partner__c = testEnv.partner1.Id,
			Client__c = testEnv.client11.Id
		);

		String nameObject = 'Referral_Partner_Change_Request__c';
		String message;

		rpcr.RecordTypeId = RecordTypeService.getId(nameObject, 'Commission Change - Referral Partner');
		message = ReferralPartnerChange_Service.createNotificiationMessage(rpcr, accounts, groups );
		System.assert(message.startsWith('The commission change'));

		rpcr.RecordTypeId = RecordTypeService.getId(nameObject, 'Group Commission Change');
		message = ReferralPartnerChange_Service.createNotificiationMessage(rpcr, accounts, groups );
		System.assert(message.startsWith('The group commission change'));

		rpcr.RecordTypeId = RecordTypeService.getId(nameObject, 'Hold Request - Client');
		message = ReferralPartnerChange_Service.createNotificiationMessage(rpcr, accounts, groups );
		System.assert(message.startsWith('The hold request for the client'));

		rpcr.RecordTypeId = RecordTypeService.getId(nameObject, 'Hold Request - Referral Partner');
		message = ReferralPartnerChange_Service.createNotificiationMessage(rpcr, accounts, groups );
		System.assert(message.startsWith('The hold request for the referral partner'));

		rpcr.RecordTypeId = RecordTypeService.getId(nameObject, 'Override Request - Client');
		message = ReferralPartnerChange_Service.createNotificiationMessage(rpcr, accounts, groups );
		System.assert(message.startsWith('The override request for the client'));

		rpcr.RecordTypeId = RecordTypeService.getId(nameObject, 'Release Hold - Client');
		message = ReferralPartnerChange_Service.createNotificiationMessage(rpcr, accounts, groups );
		System.assert(message.startsWith('The release hold request for the client'));

		rpcr.RecordTypeId = RecordTypeService.getId(nameObject, 'Release Hold - Referral Partner');
		message = ReferralPartnerChange_Service.createNotificiationMessage(rpcr, accounts, groups );
		System.assert(message.startsWith('The release hold request for the referral partner'));

		rpcr.Status__c = 'Performed';
		rpcr.RecordTypeId = RecordTypeService.getId(nameObject, 'RPOR Change - Client');
		message = ReferralPartnerChange_Service.createNotificiationMessage(rpcr, accounts, groups );
		System.assert(message.startsWith('The RPOR change request for the client'));
		System.assert(message.endsWith('Approved'));
	}

    @IsTest
    static void test_getRequests() {
        getData();

        Referral_Partner_Change_Request__c rpcr1 = new Referral_Partner_Change_Request__c(
            RecordTypeId = ReferralPartnerChange_Const.idrtHoldClient,
            Client__c = testEnv.client11.Id,
            Referral_Partner__c = testEnv.partner1.Id,
            Effective_Date__c = Date.today().addDays(-30),
            Override__c = false,
            Comments__c = 'Hold Client',
            Status__c = 'Approved', 
            Product_Line__c = ReferralPartnerChange_Const.PLTYPE_WORKERSCOMP
        );
		insert rpcr1;

        Referral_Partner_Change_Request__c rpcr2 = new Referral_Partner_Change_Request__c(
            RecordTypeId = ReferralPartnerChange_Const.idrtReleaseHoldClient,
            Client__c = testEnv.client11.Id,
            Referral_Partner__c = testEnv.partner1.Id,
            Effective_Date__c = Date.today().addDays(-1),
            Override__c = false,
            Comments__c = 'Release Client',
            Status__c = 'Approved', 
            Product_Line__c = ReferralPartnerChange_Const.PLTYPE_WORKERSCOMP
        );

		insert rpcr2;

		Test.startTest();

		Map<Id, List<Referral_Partner_Change_Request__c>> rpcrs = ReferralPartnerChange_Service.getRequests(
			new List<Id>{ testEnv.client11.Id }
		);

		Test.stopTest();

		System.assert(rpcrs != null);
		System.assertEquals(1, rpcrs.keySet().size());
		System.assertEquals(2, rpcrs.get(testEnv.client11.Id).size());
	}

    /**
     * USER STORY 48733, USER STORY 48735, USER STORY 48980
     * Added to cover Request Activation RPCR Changes
     */
    @IsTest
    static void test_autoApproveAsRequestActivation() {
        getData();
        Account RP = new Account(Id = testEnv.partner1.Id, Referral_Partner_Status__c = 'Pending');
        update RP;
        Referral_Partner_Change_Request__c rpcrApproved = new Referral_Partner_Change_Request__c(
            RecordTypeId = RecordTypeService.getId('Referral_Partner_Change_Request__c','Request Activation'),
            Comments__c = 'Test RPCR to Approved',
            Effective_Date__c = System.today(),
            Status__c = 'Approved',
            OwnerId = testEnv.rpAdmin.Id,
            Referral_Partner__c = RP.Id,
            Notify_RP_Admins__c = true,
            Client__c = testEnv.client11.Id, 
            Product_Line__c = ReferralPartnerChange_Const.PLTYPE_WORKERSCOMP
        );

        Test.startTest();

        System.runAs(TestEnv.rpAdmin) {
            insert rpcrApproved;
        }

        Test.stopTest();

        rpcrApproved = [SELECT Id, Status__c FROM Referral_Partner_Change_Request__c WHERE Id = :rpcrApproved.Id];
        System.assertEquals('Performed', rpcrApproved.Status__c, 'Status not incorrectly set.');
    }

    /**
     * USER STORY 48733, USER STORY 48735, USER STORY 48980
     * Added to cover Request Activation RPCR Changes
     */
    @IsTest
    static void test_RejectedAsRequestActivation() {
        getData();
        Account RP = new Account(Id = testEnv.partner1.Id, Referral_Partner_Status__c = 'Pending');
        update RP;
        
        Referral_Partner_Change_Request__c rpcrRejected = new Referral_Partner_Change_Request__c(
            RecordTypeId = RecordTypeService.getId('Referral_Partner_Change_Request__c','Request Activation'),
            Effective_Date__c = System.today(),
            Status__c = 'Rejected',
            Referral_Partner__c = RP.Id, 
            Product_Line__c = ReferralPartnerChange_Const.PLTYPE_WORKERSCOMP
        );
       
        Test.startTest();

        System.runAs(TestEnv.rpAdmin) {
            insert rpcrRejected;
        }

        Test.stopTest();

        rpcrRejected = [SELECT Id, Status__c FROM Referral_Partner_Change_Request__c WHERE Id = :rpcrRejected.Id];
        System.assertEquals('Rejected',rpcrRejected.Status__c, 'Status not incorrectly set.');
    }

    /**
     * USER STORY 48733, USER STORY 48735, USER STORY 48980
     * Added to cover Request Activation RPCR Changes
     */
    @IsTest
    static void test_notificationsAsRequestActivation() {
        getData();
        Account RP = new Account(Id = testEnv.partner1.Id, Referral_Partner_Status__c = 'Pending');
        update RP;
        Referral_Partner_Change_Request__c rpcrApproved = new Referral_Partner_Change_Request__c(
            RecordTypeId = RecordTypeService.getId('Referral_Partner_Change_Request__c','Request Activation'),
            Comments__c = 'Test RPCR to Approved',
            Effective_Date__c = System.today(),
            Status__c = 'Pending Approval',
            OwnerId = testEnv.rpAdmin.Id,
            Referral_Partner__c = RP.Id,
            Notify_RP_Admins__c = true,
            Client__c = testEnv.client11.Id, 
            Product_Line__c = ReferralPartnerChange_Const.PLTYPE_WORKERSCOMP            
        );
        Referral_Partner_Change_Request__c rpcrRejected = new Referral_Partner_Change_Request__c(
            RecordTypeId = RecordTypeService.getId('Referral_Partner_Change_Request__c','Request Activation'),
            Comments__c = 'Test RPCR to Approved',
            Effective_Date__c = System.today(),
            Status__c = 'Pending Approval',
            OwnerId = testEnv.rpAdmin.Id,
            Referral_Partner__c = RP.Id,
            Notify_RP_Admins__c = true, 
            Product_Line__c = ReferralPartnerChange_Const.PLTYPE_WORKERSCOMP
        );
        Referral_Partner_Change_Request__c rpcrPendingApproval = new Referral_Partner_Change_Request__c(
            RecordTypeId = RecordTypeService.getId('Referral_Partner_Change_Request__c','Request Activation'),
            Comments__c = 'Test RPCR to Approved',
            Effective_Date__c = System.today(),
            Status__c = 'Pending Approval',
            OwnerId = testEnv.rpAdmin.Id,
            Referral_Partner__c = RP.Id,
            Notify_RP_Admins__c = true, 
            Product_Line__c = ReferralPartnerChange_Const.PLTYPE_BENEFITS
        );
        

        List<Referral_Partner_Change_Request__c> listNew = new List<Referral_Partner_Change_Request__c>{ rpcrApproved, rpcrRejected, rpcrPendingApproval };
        Test.startTest();
            insert listNew;
            listNew[0].Status__c='Approved';
            listNew[0].Approval_Date__c = System.today();
            listNew[1].Status__c='Rejected';
            update listNew;
        Test.stopTest();
            
        rpcrApproved = [SELECT Id, Status__c FROM Referral_Partner_Change_Request__c WHERE Id = :listNew[0].Id];
        System.assertEquals('Performed', rpcrApproved.Status__c, 'Status not incorrectly set.');
        rpcrRejected = [SELECT Id, Status__c FROM Referral_Partner_Change_Request__c WHERE Id = :listNew[1].Id];
        System.assertEquals('Rejected', rpcrRejected.Status__c, 'Status not incorrectly set.');
    }
}