/**
 * @description RenewalDateLeadTest contains tests for the RenewalDateLead class.
 */
@IsTest
@SuppressWarnings('PMD.ApexDoc')
private class RenewalDateLeadTest {
	public static final String CRON_EXP = '0 0 1 1 * ?';

	@IsTest
	static void test_schedule() {
		Test.startTest();

		// Schedule the test job
		String jobId = System.schedule('TESTINGRenewalDateLead', CRON_EXP, new RenewalDateLead());

		// Get the information from the CronTrigger API object
		CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];

		Assert.areEqual(CRON_EXP, ct.CronExpression, 'Cron expression should be the same');
		Assert.areEqual(0, ct.TimesTriggered, 'Job should not have run');

        Test.stopTest();

		Assert.isTrue(RenewalDateLead_Batch.constructed, 'RenewalDateLead_Batch should have been created');
	}

	@IsTest
	static void test_execute() {
		Date dateRenewal = Date.today().addDays(-1);
		Date dateRenewalFuture = dateRenewal.addYears(1);

		Account branch = TestFactory.createAccount('Test Branch', '98662', 'BBSI Branch', true);
		Account referralPartner = TestFactory.createAccountReferralPartner(
			'Test Referral Partner',
			'Active',
			'% of Margin',
			12.0,
			null,
			true
		);

		User userBmd = TestFactoryUser.createBDM(null, 'TestBDM', 'BBSI Standard', '910');

		Contact producer = TestFactoryContact.createProducer(null, 'Test Producer', referralPartner.Id);

		Lead lead1 = TestFactoryLead.makeClientLead(null, 'TestLead1', 'TestCompany', branch.Id, userBmd.Id);
		lead1.Status = 'Assigned';
		lead1.Renewal_Date__c = dateRenewal;
		lead1.Referral_Partner__c = ReferralPartner.Id;
		lead1.Producer__c = producer.Id;

		Lead lead2 = TestFactoryLead.makeClientLead(null, 'TestLead2', 'TestCompany', branch.Id, userBmd.Id);
		lead2.Status = 'Assigned';
		lead2.Renewal_Date__c = null;
		lead2.Referral_Partner__c = referralPartner.Id;
		lead2.Producer__c = producer.Id;

		insert new List<Lead>{ lead1, lead2 };

		if ([SELECT Id, Name FROM CronJobDetail WHERE name = 'RenewalDateLead'].size() > 0) {
			Id checkJob = [SELECT Id, Name FROM CronJobDetail WHERE Name = 'RenewalDateLead' LIMIT 1].Id;
			System.abortJob([SELECT Id FROM CronTrigger WHERE CronJobDetailId = :checkJob].Id);
		}

		Test.startTest();
        Database.executebatch(new RenewalDateLead_Batch(), 200);
        Test.stopTest();

		lead1 = [SELECT Renewal_Date__c FROM Lead WHERE Id = :lead1.Id LIMIT 1];
		Assert.areEqual(dateRenewalFuture, lead1.Renewal_Date__c, 'Renewal Date should be updated.');

		lead2 = [SELECT Renewal_Date__c FROM Lead WHERE Id = :lead2.Id LIMIT 1];
		Assert.areEqual(null, lead2.Renewal_Date__c, 'Renewal Date should remain null');
	}

    @IsTest
	static void test_bulk() {
		Date dateRenewal = Date.today().addDays(-1);
		Date dateNoRenewal = Date.today().addDays(+8);
		Date dateRenewalFuture = dateRenewal.addYears(1);

		Account branch = TestFactoryAccount.makeBranch('Test Branch');

		Account referralPartner1 = TestFactoryAccount.makeReferralPartner(
			'Test Referral Partner1',
			'% of Margin',
			12.0,
			null
		);
        referralPartner1.Status__c = 'Active';
        referralPartner1.Referral_Partner_Status__c = 'Active';

		Account referralPartner2 = TestFactoryAccount.makeReferralPartner(
			'Test Referral Partner2',
			'% of Margin',
			12.0,
			null
		);
		referralPartner2.Status__c = 'Active';
        referralPartner2.Referral_Partner_Status__c = 'Active';

		insert new List<Account>{branch, referralPartner1, referralPartner2};

		User userBmd = TestFactoryUser.createBDM(null, 'TestBDM', 'BBSI Standard', '910');

		Contact producer1 = TestFactoryContact.makeProducer(null, 'Test Producer1', referralPartner1.Id);
		Contact producer2 = TestFactoryContact.makeProducer(null, 'Test Producer2', referralPartner2.Id);
		insert new List<Contact>{producer1, producer2};

        List<Lead> leads = new List<Lead>();

		for (Integer i = 1; i <= 20; i++) {
			leads.add(createLead('Renew', i, branch, userBmd, ReferralPartner1.Id, producer1.Id, dateRenewal));
		}
		for (Integer i = 21; i <= 40; i++) {
			leads.add(createLead('NoRenew', i, branch, userBmd, ReferralPartner2.Id, producer2.Id, dateNoRenewal));
		}

		insert leads;

		Test.startTest();
        Database.executebatch(new RenewalDateLead_Batch(), 50);
        Test.stopTest();

		leads = [SELECT Renewal_Date__c FROM Lead WHERE Name LIKE 'Renew%'];
		Assert.areEqual(20, leads.size(), 'Should have 20 renewal Leads');
		for (Lead lead : leads) {
			Assert.areEqual(dateRenewalFuture, lead.Renewal_Date__c, lead.Id + ' Renewal Date should be updated.');
		}

		leads = [SELECT Renewal_Date__c FROM Lead WHERE Name LIKE 'NoRenew%'];
		Assert.areEqual(20, leads.size(), 'Should have 20 no renewal Leads');
		for (Lead lead : leads) {
			Assert.areEqual(dateNoRenewal, lead.Renewal_Date__c, lead.Id + ' Renewal Date should not be updated.');
		}
	}

	@SuppressWarnings('PMD.ExcessiveParameterList')
    private static Lead createLead(String name, Integer index, Account branch, User userBmd, Id idRP, Id idProducer, Date dateRenewal) {
        String strIndex = String.valueOf(index);

		Lead lead = TestFactoryLead.makeClientLead(null, name + strIndex, 'TestCompany' + strIndex, branch.Id, userBmd.Id);
		lead.Status = 'Assigned';
		lead.Referral_Partner__c = idRP;
		lead.Producer__c = idProducer;
        lead.Renewal_Date__c = dateRenewal;

        return lead;
    }

	@IsTest
	public static void test_writeErrorLog() {
		Date dateRenewal = Date.today().addDays(-1);
		DateTime now = DateTime.now();

		Account branch = TestFactoryAccount.createBranch('Test Branch');

		User userBmd = TestFactoryUser.createBDM(null, 'TestBDM', 'BBSI Standard', '910');

		Lead lead1 = TestFactoryLead.makeClientLead(null, 'TestLead1', 'TestCompany', branch.Id, userBmd.Id);
		lead1.Status = 'Assigned';
		lead1.Renewal_Date__c = dateRenewal;

		Lead lead2 = TestFactoryLead.makeClientLead(null, 'TestLead2', 'TestCompany', branch.Id, userBmd.Id);
		lead2.Status = 'Assigned';
		lead2.Renewal_Date__c = null;

		List<Lead> leads = new List<Lead>{ lead1, lead2 };
		insert leads;

		RenewalDateLead_Batch batch = new RenewalDateLead_Batch();

		batch.writeErrorLog(null, leads);

		List<Log__c> logs = Log_Test.recentLogs(now);

		Assert.areEqual(1, logs.size(), 'A log should have been written');
		Log__c log = logs.get(0);
		Assert.areEqual('RenewalDateLead_Batch.execute', log.Subject__c, 'Wrong Subject');
	}

    /**
     * @description 
     * US-41346: otherLeadSourcePositiveTest Added For Checking Lead_Source_Other_Required Validation Rule.
     */
    @IsTest
	static void otherLeadSourcePositiveTest() {
		Date dateRenewal = Date.today().addDays(-1);
		Date dateRenewalFuture = dateRenewal.addYears(1);

		Account branch = TestFactoryAccount.createBranch('Test Branch');

		Account referralPartner = TestFactoryAccount.makeReferralPartner(
			'Test Referral Partner',
			'% of Margin',
			12.0,
			null
		);
		referralPartner.Status__c = 'Active';
        referralPartner.Referral_Partner_Status__c = 'Active';
        insert referralPartner;

		User userBmd = TestFactoryUser.createBDM(null, 'TestBDM', 'BBSI Standard', '910');

		Contact producer = TestFactoryContact.createProducer(null, 'Test Producer', referralPartner.Id);

		Lead lead1 = TestFactoryLead.makeClientLead(null, 'TestLead1', 'TestCompany', branch.Id, userBmd.Id);
		lead1.Status = 'Assigned';
		lead1.Renewal_Date__c = dateRenewal;
		lead1.Referral_Partner__c = ReferralPartner.Id;
		lead1.Producer__c = producer.Id;
		insert lead1;

        Datetime OldDate =  Datetime.newInstance(1960, 2, 17); //Setting Created Date before 2021
        Test.setCreatedDate(lead1.Id, OldDate);  
        lead1.LeadSource = 'Other';
        update lead1;
        
		if ([SELECT Id, Name FROM CronJobDetail WHERE name = 'RenewalDateLead'].size() > 0) {
			Id checkJob = [SELECT Id, Name FROM CronJobDetail WHERE Name = 'RenewalDateLead' LIMIT 1].Id;
			System.abortJob([SELECT Id FROM CronTrigger WHERE CronJobDetailId = :checkJob].Id);
		}

		Test.startTest();
        Database.executebatch(new RenewalDateLead_Batch(), 200);
        Test.stopTest();

		lead1 = [SELECT Renewal_Date__c FROM Lead WHERE Id = :lead1.Id LIMIT 1];
		Assert.areEqual(dateRenewalFuture, lead1.Renewal_Date__c, 'Renewal Date should be updated.');
	}

    /**
     * @description 
     * US-41346: otherLeadSourceValidationTest Added For Checking Lead_Source_Other_Required Validation Rule.
     */
    @IsTest
	static void otherLeadSourceValidationTest() {
		Date dateRenewal = Date.today().addDays(-1);
		Date dateRenewalFuture = dateRenewal.addYears(1);

		Account branch = TestFactoryAccount.createBranch('Test Branch');
		Account referralPartner = TestFactoryAccount.makeReferralPartner(
			'Test Referral Partner',
			'% of Margin',
			12.0,
			null
		);
		referralPartner.Status__c = 'Active';
        referralPartner.Referral_Partner_Status__c = 'Active';
        insert referralPartner;

		User userBmd = TestFactoryUser.createBDM(null, 'TestBDM', 'BBSI Standard', '910');

		Contact producer = TestFactoryContact.createProducer(null, 'Test Producer', referralPartner.Id);

		Lead lead1 = TestFactoryLead.makeClientLead(null, 'TestLead1', 'TestCompany', branch.Id, userBmd.Id);
		lead1.Status = 'Assigned';
		lead1.Renewal_Date__c = dateRenewal;
		lead1.Referral_Partner__c = ReferralPartner.Id;
		lead1.Producer__c = producer.Id;
		insert lead1;
        lead1.LeadSource = 'Other';

       	String ExceptionMessage = '';
        try{
            update lead1;
        }
        catch(Exception ex){
            ExceptionMessage = ex.getMessage();
        }
        Assert.areNotEqual('', ExceptionMessage, 'Lead Validation Should Fire.');
        Assert.areEqual(true, (ExceptionMessage.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION') && ExceptionMessage.contains('Other Lead Source is required')), 'Lead Validation Should Fire.');
	}

    /**
     * @description 
     * US-41346: otherLeadSourceNegativeTest Added For Checking Lead_Source_Other_Required Validation Rule.
     */
    @IsTest
	static void otherLeadSourceNegativeTest() {
		Date dateRenewal = Date.today().addDays(-1);
		Date dateRenewalFuture = dateRenewal.addYears(1);

		Account branch = TestFactoryAccount.createBranch('Test Branch');
		Account referralPartner = TestFactoryAccount.makeReferralPartner(
			'Test Referral Partner',
			'% of Margin',
			12.0,
			null
		);
		referralPartner.Status__c = 'Active';
        referralPartner.Referral_Partner_Status__c = 'Active';
        insert referralPartner;

		User userBmd = TestFactoryUser.createBDM('TEST', 'TestBDM', 'BBSI Standard', '910');

		Contact producer = TestFactoryContact.createProducer('TEST', 'Test Producer', referralPartner.Id);

		Lead lead1 = TestFactoryLead.makeClientLead('Test', 'TestLead1', 'TestCompany', branch.Id, userBmd.Id);
		lead1.Status = 'Assigned';
		lead1.Renewal_Date__c = dateRenewal;
		lead1.Referral_Partner__c = ReferralPartner.Id;
		lead1.Producer__c = producer.Id;
		insert lead1;

        Datetime OldDate =  Datetime.newInstance(1960, 2, 17); //Setting Created Date before 2021
        Test.setCreatedDate(lead1.Id, OldDate);  
        lead1.LeadSource = 'Other';
        update lead1;

        Test.setCreatedDate(lead1.Id, datetime.now());
		if ([SELECT Id, Name FROM CronJobDetail WHERE name = 'RenewalDateLead'].size() > 0) {
			Id checkJob = [SELECT Id, Name FROM CronJobDetail WHERE Name = 'RenewalDateLead' LIMIT 1].Id;
			System.abortJob([SELECT Id FROM CronTrigger WHERE CronJobDetailId = :checkJob].Id);
		}

		Test.startTest();
        Id batchJobId  = Database.executebatch(new RenewalDateLead_Batch(), 200);
        Test.stopTest();

		// Check batch status - IF COMPLETED then 
    	AsyncApexJob Job = [Select Id, Status, NumberOfErrors, JobItemsProcessed,
        TotalJobItems, CreatedBy.Email, ExtendedStatus
        from AsyncApexJob where Id = :batchJobId];   
		lead1 = [SELECT Renewal_Date__c FROM Lead WHERE Id = :lead1.Id LIMIT 1];
		Assert.areNotEqual(dateRenewalFuture, lead1.Renewal_Date__c, 'Renewal Date should Not be updated.');
	}
}