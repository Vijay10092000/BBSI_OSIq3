/**
 * @description TaskBenefits_Test contains test methods for the TaskBenefits class.
 */
@IsTest
@SuppressWarnings('PMD.AvoidHardcodingId, PMD.ApexAssertionsShouldIncludeMessage')
public with sharing class TaskBenefits_Test {
	private static final Id TEST_QUEUE_BENEFITS_ID = Id.valueOf('00G2J000003i0dw');
	private static final Id TEST_QUEUE_BENEFITS_COORDINATOR_ID = Id.valueOf('00G2J0000031wdw');
	private static final Id TEST_QUEUE_BENEFITS_UNDERWRITER_ID = Id.valueOf('00G2J00000389dw');

	private static Account branch;
	private static Account referralPartner;
	private static Account client;
	private static User owner;
	private static User payrollSpecialistUser;
	private static User benefitsRep;

	@TestSetup
	static void makeData() {
		branch = TestFactory.createAccountBranch('__TEST BRANCH', '99999', '1000', false);
		referralPartner = TestFactory.createAccountReferralPartner(
			'__TEST REFERRAL PARTNER',
			'Active',
			'% of Margin',
			3.0,
			null,
			false
		);
		client = TestFactory.createAccountClient('__TEST CLIENT', false);
		insert new List<Account>{ branch, referralPartner, client };

		owner = TestFactory.createUser('TEST USER', 'BBSI Standard', '1000', true);
		benefitsRep = TestFactory.createUser('TEST BENEFITS REP', 'BBSI Standard', '1000', true);
		payrollSpecialistUser = TestFactory.createUser('TEST PAYROLL SPECIALIST', 'BBSI Standard', '1000', true);

		client.Benefits_Representative__c = benefitsRep.Id;
		client.Payroll_Specialist__c = payrollSpecialistUser.Id;
		update client;
	}

	static void loadData() {
		for (Account a : [SELECT Id, Name FROM Account WHERE Name LIKE '__%']) {
			switch on a.Name {
				when '__TEST BRANCH' {
					branch = a;
				}
				when '__TEST REFERRAL PARTNER' {
					referralPartner = a;
				}
				when '__TEST CLIENT' {
					client = a;
				}
			}
		}

		owner = [SELECT Id, Name FROM User WHERE LastName = 'TEST USER'];
		benefitsRep = [SELECT Id, Name FROM User WHERE LastName = 'TEST BENEFITS REP'];
		payrollSpecialistUser = [SELECT Id, Name FROM User WHERE LastName = 'TEST PAYROLL SPECIALIST'];
	}

	/**
	 * @description filename_Test contains test for the filename class
	 */
	@IsTest
	@SuppressWarnings('PMD.UnusedLocalVariable')
	static void test_loadBenefitsTaskDefinitions() {
		TaskBenefits tbs = new TaskBenefits();

		Assert.isTrue(1 < TaskBenefits.taskDefs.size(), 'There should alway be at least one definition');
	}

	@IsTest
	static void test_createFirstTask() {
		/*
		loadData();

		Test.startTest();

		Opportunity opp = TestFactory.createOpportunityBenefits(
			'__TEST OPPORTUNITY',
			client.Id,
			Date.today().addDays(30),
			'Benefits Client Data Gathering',
			false
		);
		opp.OwnerId = owner.Id;

		insert opp;

		Test.stopTest();

		List<Task> oppTasks = [
			SELECT Id, OwnerId, WhoId, WhatId
			FROM Task
			WHERE WhatId = :opp.Id AND RecordType.Name = 'Benefits Task'
			ORDER BY CreatedDate DESC
		];

		System.assertEquals(5, oppTasks.size(), 'First set of Tasks');
		*/
	}

	@IsTest
	static void test_determineOwner() {
		loadData();
		/*

		Opportunity opp = TestFactory.createOpportunityBenefits(
			'__TEST OPPORTUNITY',
			client.Id,
			Date.today().addDays(30),
			'Benefits Client Data Gathering',
			false
		);
		opp.OwnerId = owner.Id;

		insert opp;

		Test.startTest();

		opp = [
			SELECT Id, Name, StageName, OwnerId, Account.Benefits_Representative__c, Account.PayrollSpecialist__r.User_Id__c, Account.Benefits_Coordinator__c
			FROM Opportunity
			WHERE Id = :opp.Id
		];

		TaskBenefits.idQueueBenefits = TEST_QUEUE_BENEFITS_ID;
		TaskBenefits.idQueueBenefitsCoordinator = TEST_QUEUE_BENEFITS_COORDINATOR_ID;
		TaskBenefits.idQueueBenefitsUnderwriting = TEST_QUEUE_BENEFITS_UNDERWRITER_ID;

		Test.stopTest();

		TaskBenefits taskBenfits = new TaskBenefits();

		Assert.areEqual(
			TEST_QUEUE_BENEFITS_COORDINATOR_ID,
			TaskBenefits.determineOwner('Benefits Coordinator', opp)
		);
		Assert.areEqual(
			TEST_QUEUE_BENEFITS_UNDERWRITER_ID,
			TaskBenefits.determineOwner('Benefits Underwriting', opp)
		);
		Assert.areEqual(benefitsRep.Id, TaskBenefits.determineOwner('Benefits Specialist', opp));
		Assert.areEqual(payrollSpecialist.User_Id__c, TaskBenefits.determineOwner('Payroll Specialist', opp));

		Assert.areEqual(opp.OwnerId, TaskBenefits.determineOwner('UNKNOWN', opp));
		*/
	}

	/*
	@IsTest
	static void test_setOpportunityStage() {
		loadData();

		Opportunity opp = TestFactory.createOpportunityBenefits(
			'__TEST OPPORTUNITY',
			client.Id,
			Date.today().addDays(30),
			'Benefits Client Data Gathering',
			false
		);
		opp.OwnerId = owner.Id;
		opp.Admin_Factor__c = 1.0;
		opp.Bucket__c = 3;

		insert opp;

		TaskBenefits tb = new TaskBenefits();

		Task task = Task_Service.createTask(
			'Task',
			null,
			opp.Id,
			TaskBenefits.determineOwner('Benefits Underwriting', opp),
			'Enter Finalized Data',
			null,
			Date.today().addDays(3)
		);

		task.Category__c = 'Enter_Finalized_Data';
		task.RecordTypeId = TaskBenefits.idrtBenefitsTask;

		insert task;

		Test.startTest();

		task.Status = 'Completed';
		update task;

		Test.stopTest();

		opp = [
			SELECT Id, Name, StageName, OwnerId, Account.Benefits_Representative__c, Account.PayrollSpecialist__c
			FROM Opportunity
			WHERE Id = :opp.Id
		];

		Assert.areEqual('approved by underwriting', opp.StageName.toLowerCase());
	}
	*/

	@IsTest
	static void test_calculateDueDate() {
		Date today = Date.today();

		loadData();

		Opportunity opp = TestFactoryOpportunity.makeBenefits(
			'__TEST OPPORTUNITY',
			client.Id,
			Date.today().addDays(30),
			'Benefits Client Data Gathering'
		);
		Date dateEndDate = today.addDays(30);
        Date startDate = today.addDays(30);

		insert opp;

		TaskBenefits taskBenefits = new TaskBenefits();

		opp.Current_Medical_Renewal_Month__c = Date_Service.getMonthName(today.month());
		Assert.isTrue(
			today <= TaskBenefits.calculateDueDate('Current Medical Renewal Month', 90, false, opp),
			'Should be 90 days ahead.'
		);

		opp.Enrollment_End_Date__c = dateEndDate;
		Assert.areEqual(dateEndDate, TaskBenefits.calculateDueDate('Enrollment End Date', 0, false, opp));
        
        opp.Enrollment_Start_Date__c = startDate;
        Assert.areEqual(startDate, TaskBenefits.calculateDueDate('Enrollment Start Date', 0, false, opp));
        
        
        Assert.areEqual(Date.today(), TaskBenefits.calculateDueDate('', 0, false, opp));
        
        Assert.areEqual(Date.today(), TaskBenefits.calculateDueDate('', 0, true, opp));
        
        
        opp.Current_Medical_Renewal_Month__c = null;
		Assert.isTrue(
			today <= TaskBenefits.calculateDueDate('Current Medical Renewal Month', 90, false, opp),
			'Should be 90 days ahead.'
		);
        
        
        
	        
        
	}

	@IsTest
	static void test_createBenefitsFollowUp() {
		Date today = Date.today();
		Date dueDate = today.addDays(90);
		Opportunity opp1 = new Opportunity();
		opp1.Name = 'TEST OPPORTUNITY';

		//Date.today().addDays(30),
		opp1.StageName = 'Benefits Client Data Gathering';
		opp1.CloseDate = system.Today();

		opp1.Current_Medical_Renewal_Month__c = 'January';
		insert opp1;
		Test.startTest();
		TaskBenefits.createBenefitsFollowUp(opp1);
		Test.stopTest();
	}
    
    @IsTest
	static void test_isFieldValueValid() {
        
		//field value not blank and type is string
       	Assert.isTrue(
    		TaskBenefits.isFieldValueValid(Schema.DisplayType.String, '__NOTBLANK', 'testString'),
    		'New value should be of string'
			);
        
        //field value not blank and type is integer
       Assert.isTrue(
    		TaskBenefits.isFieldValueValid(Schema.DisplayType.Integer, '__NOTBLANK', 123),
    		'New value should be of Integer'
			);
        
       //field value not blank and type is boolean
       Assert.isTrue(
    		TaskBenefits.isFieldValueValid(Schema.DisplayType.Boolean, '__NOTBLANK', 123),
    		'Any new value converted to String'
			);
		
		
       //field value blank and type is boolean 
       Assert.isTrue(
    		TaskBenefits.isFieldValueValid(Schema.DisplayType.Boolean, 'BLANK', 'blank'),
    		'Lower case of field value should be equal to new value'
			);
        
        
		//field value is blank and type is date, new value is null
	   Assert.isTrue(
    		TaskBenefits.isFieldValueValid(Schema.DisplayType.Date, '', null),
    		'when field value is empty new value should be null'
			);
        
        
        Assert.isTrue(
    		TaskBenefits.isFieldValueValid(Schema.DisplayType.String, '', null),
    		'when field value is empty new value should be null'
			);
        
        Assert.isTrue(
    		TaskBenefits.isFieldValueValid(Schema.DisplayType.Integer, '0', null),
    		'when field value is 0 new value should be null'
			);
        
        Assert.isTrue(
    		TaskBenefits.isFieldValueValid(Schema.DisplayType.Phone, '', null),
    		'when field value is empty new value should be null'
			);
	}
    
    
    
}