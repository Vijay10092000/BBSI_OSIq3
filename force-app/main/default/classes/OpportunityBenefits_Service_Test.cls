/**
 * @description OpportunityBenefits_Service_Test contains tests for the OpportunityBenefits_Service class
 */
@IsTest
public with sharing class OpportunityBenefits_Service_Test {
	private static Account branch;
	private static Account referralPartner;
	private static Account client1;
	private static Account client2;

	private static User employee;
	private static User specialist;
	private static Contact producer;

	private static Opportunity opp1;
	private static Opportunity opp2;

	@TestSetup
	static void makeData() {
		branch = TestFactoryAccount.createBranch('TEST_BRANCH');

		employee = TestFactoryUser.makeUser('TEST', 'EMPLOYEE', 'BBSI Standard', branch.External_Id__c);
		specialist = TestFactoryUser.makeUser('TEST', 'SPECIALIST', 'BBSI Standard', branch.External_Id__c);
		insert new List<User>{ employee, specialist };

		referralPartner = TestFactoryAccount.makeReferralPartner('TEST_REFERRALPARTNER', '% of Margin', 12.0, null);

		client1 = TestFactoryAccount.makeClient('TEST_CLIENT_1', null, null);
		client1.Benefits_Representative__c = employee.Id;
		client1.NumberOfEmployees = 100;
		client1.Active_Employees_Full_Time__c = 100;
        client1.Part_of_a_Franchise__c = 'No';
        client1.Business_Entity_Type__c = 'Church Organization';
        client1.Est_Annual_Payroll__c  = 20000000 ;

		client2 = TestFactoryAccount.makeClient('TEST_CLIENT_2', null, null);
		client2.NumberOfEmployees = 200;
		client2.Active_Employees_Full_Time__c = 200;
		client2.Benefits_Representative__c = employee.Id;
        client2.Part_of_a_Franchise__c = 'No';
        client2.Business_Entity_Type__c = 'Church Organization';
        client2.Est_Annual_Payroll__c  = 20000000 ;

		insert new List<Account>{ referralPartner, client1, client2 };

		producer = TestFactoryContact.createProducer('TEST', 'PRODUCER', referralPartner.Id);

		opp1 = TestFactoryOpportunity.makeBenefits('BENEFITS: CLIENT_1', client1.Id, Date.today().addDays(20), 'Pending Submission');
		opp1.Active_Employees_Full_Time__c = 100;
		opp2 = TestFactoryOpportunity.makeBenefits('BENEFITS: CLIENT_2', client2.Id, Date.today().addDays(50), 'Pending Submission');
		opp2.Active_Employees_Full_Time__c = 200;
		insert new List<Opportunity>{ opp1, opp2 };

		Benefits_Discovery_Questionnaire__c bdq1 = new Benefits_Discovery_Questionnaire__c(
			OpportunityId__c = opp1.Id
		);
	}

	static void loadData() {
		List<Account> accounts = [
			SELECT Id, Name, OwnerId, RecordTypeId
			FROM Account
			WHERE Name LIKE 'TEST_%'
			ORDER BY Name ASC
		];
		branch = accounts.get(0);
		client1 = accounts.get(1);
		client2 = accounts.get(2);
		referralPartner = accounts.get(3);

		employee = [SELECT Id, Name FROM User WHERE FirstName = 'TEST' AND LastName = 'EMPLOYEE' LIMIT 1];
		specialist = [SELECT Id, Name FROM User WHERE FirstName = 'TEST' AND LastName = 'SPECIALIST' LIMIT 1];

		producer = [
			SELECT Id, Name, RecordTypeId
			FROM Contact
			WHERE FirstName = 'TEST' AND LastName = 'PRODUCER'
			LIMIT 1
		];

		List<Opportunity> opps = [
			SELECT
				Id, Name, RecordTypeId, AccountId, StageName, Quoted_Annualized_Medical_Premium__c,
				OwnerId, Benefits_Type__c,  Benefits_Coordinator__c, Benefits_Specialist__c,
				Employees_Enrolled_in_Medical__c, Estimated_Subscriber_Count__c,
				Benefits_Effective_Date__c, Effective_Month__c, Benefits_Affiliates__c,
				Active_Employees_All_Affiliates__c, Full_Time_Employees_All_Affiliates__c, Part_Time_Employees_All_Affiliates__c
			FROM Opportunity
			WHERE Name LIKE 'BENEFITS: CLIENT_%'
			ORDER BY Name ASC
		];
		opp1 = opps.get(0);
		opp2 = opps.get(1);
	}

	/* DELETE: User Story 66133 - No automatic change of stage Pending Submission
	@IsTest
	static void test_haveDocumentChangesStage() {
		loadData();

		Test.startTest();

		opp1.Have_Documents_Been_Submitted__c = true;
		opp1.All_Fields_for_Submission_Completed__c = true;
        opp1.Benefits_Effective_Date__c = system.today();
        opp1.Benefits_Type__c = 'Ancillary Only';
        opp1.BBSI_Medical_Plan_Carrier__c  = 'Aetna';
        opp1.Prospective_BBSI_PEO_Client__c = true;
        opp1.Is_there_a_benefits_referral_partner__c  = 'No';
        opp1.Incumbent_Medical_Plan_Funding__c  = 'Full Insured';
        opp1.Illustrative_Only__c  = 'Yes';
        opp1.Total_COBRA_Participants__c  = 1;
        opp1.Currently_with_a_PEO_or_Association__c = 'No';
		update new List<Opportunity>{ opp1 };

		Test.stopTest();

		opp1 = [
			SELECT Id, Name, StageName
			FROM Opportunity
			WHERE Id = :opp1.Id
			LIMIT 1
		];

		Assert.areEqual(Opportunity_Service.STAGE_UNDERWRITING, opp1.StageName, 'Stage should be Underwriting');
	}
	*/ 

	@IsTest
	static void test_emailStageChanges() {
		loadData();

		Test.startTest();

		opp1.StageName = Opportunity_Service.STAGE_PRE_ENROLLMENT;

		OpportunityBenefits_Service.emailStageChanges(null, new List<Opportunity>{ opp1 });

		Test.stopTest();
		
		Assert.areEqual(2, Email_Service.testEmails.size(), 'Should send two emails one to owner and another to Benefits Notification group.');
	}

	@IsTest
	static void test_updateAccounts() {
		loadData();

		Test.startTest();

		opp1.StageName = 'Benefits Closed Won';
		opp1.Benefits_Specialist__c = specialist.Id;

		opp2.Benefits_Specialist__c = employee.Id;

		OpportunityBenefits_Service.updateAccounts(new List<Opportunity>{ opp1, opp2 });

		Test.stopTest();

		List<Id> idAccounts = new List<Id>{ client1.Id, client2.Id };

		List<Account> clients = [
			SELECT Id, Name, Benefits_Specialist__c, Benefits_Specialist__r.Name
			FROM Account 
			WHERE Id IN :idAccounts 
			ORDER BY Name ASC
		];

		Assert.areEqual(2, clients.size());

		Assert.areEqual(specialist.Id, clients[0].Benefits_Specialist__c, 'Specialist Expected: ' + specialist.Name + '  Actual: ' + clients[0].Benefits_Specialist__r.Name);
		Assert.areEqual(null, clients[1].Benefits_Specialist__c);	
	}
    
    
    @IsTest
    static void test_taskCreationOnFieldChange() {
        loadData();
 
        Test.startTest();
 
        opp1.StageName = Opportunity_Service.STAGE_ENROLLMENT;
        opp1.Bucket__c = 1;
        opp1.Admin_Factor__c = 1;
        opp1.Benefits_Specialist__c= specialist.Id;
        opp1.Enrollment_Start_Date__c=Date.today();
        opp1.Enrollment_End_Date__c=Date.today();
        opp1.Have_Documents_Been_Submitted__c = true;
        update opp1;
        
        Test.stopTest();
        opp1.Final_OE_End_Date__c = Date.today();
        update opp1;
        List<Task> tasks = [ SELECT Id  FROM Task WHERE WhatId =: opp1.Id ];
        
        Assert.isTrue(tasks.size()>0, 'Tasks should be there');
        
       	
    }
}