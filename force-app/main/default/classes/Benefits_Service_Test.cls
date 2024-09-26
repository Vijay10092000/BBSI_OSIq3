/**
 * @description Benefits_Service_Test contains test methods for the Benefits_Service class.
 */
@IsTest
@SuppressWarnings('PMD.ApexAssertionsShouldIncludeMessage')
public without sharing class Benefits_Service_Test {
	private static final String FAKE_BENEFITS_ID = 'a29Ec0000012c8oDBA';

	private static Account branch1;
	private static Account branch2;
	private static Account referralPartner;
	private static Account client1;
	private static Account client2;
	private static Account clientPrimary;

	private static User employee;
	private static User specialist;
	private static Contact producer;

	private static Opportunity opp1;
	private static Opportunity opp2;
    private static Opportunity opp3;
	private static Opportunity oppPrimary;    

	@TestSetup
	static void makeData() {
		Test.startTest();
		branch1 = TestFactoryAccount.makeBranch('TEST_BRANCH_ONE');		
		branch2 = TestFactoryAccount.makeBranch('TEST_BRANCH_TWO');
		insert new List<Account>{ branch1, branch2 };

		employee = TestFactoryUser.makeUser('TEST', 'EMPLOYEE', 'BBSI Standard', branch1.External_Id__c);
		specialist = TestFactoryUser.makeUser('TEST', 'SPECIALIST', 'BBSI Standard', branch1.External_Id__c);
		insert new List<User>{ employee, specialist };

		referralPartner = TestFactoryAccount.makeReferralPartner('TEST_REFERRALPARTNER', '% of Margin', 12.0, null);
		
		client1 = TestFactoryAccount.makeClient('TEST_CLIENT_ONE', null, null);
		client1.Prospect_Branch__c = branch1.Id;
		client1.NumberOfEmployees = 110;
		client1.Active_Employees_Full_Time__c = 100;
		client1.Active_Employees_Part_Time__c = 10;
		client1.Benefits_Representative__c = specialist.Id;
        client1.BBSI_Benefits_Renewal_Date__c = Date.today().addDays(90);
		
		client2 = TestFactoryAccount.makeClient('TEST_CLIENT_TWO', null, null);
		client2.Prospect_Branch__c = branch2.Id;
		client2.NumberOfEmployees = 220;
		client2.Active_Employees_Full_Time__c = 200;
		client2.Active_Employees_Part_Time__c = 20;
		client2.Benefits_Representative__c = specialist.Id;		
		
		insert new List<Account>{ referralPartner, client1, client2 };		
        
		producer = TestFactoryContact.createProducer('TEST', 'PRODUCER', referralPartner.Id);
		clientPrimary = TestFactoryAccount.makeClient('TEST_CLIENT_Primary', referralPartner.Id, producer.Id, '% of WC Eligible Payroll', 1.11);
		clientPrimary.NumberOfEmployees = 220;
		clientPrimary.Active_Employees_Full_Time__c = 200;
		clientPrimary.Active_Employees_Part_Time__c = 20;
		clientPrimary.Benefits_Representative__c = specialist.Id;	
		clientPrimary.Headquarters_State__c = 'CA';
        clientPrimary.BBSI_Benefits__c = true;
        clientPrimary.Referral_Partner_for_Benefits__c = referralPartner.Id;	
		clientPrimary.Is_there_a_benefits_referral_partner__c = 'Yes';
		insert clientPrimary; 
        opp1 = TestFactoryOpportunity.makeBenefits('BENEFITS: TEST CLIENT ONE', client1.Id, Date.today().addDays(20), 'Pending Submission');
		opp1.Active_Employees_Full_Time__c = 100;
		opp1.Benefits_Specialist__c = specialist.Id;
		
        opp2 = TestFactoryOpportunity.makeBenefits('BENEFITS: TEST CLIENT TWO', client2.Id, Date.today().addDays(50), 'Pending Submission');
		opp2.Active_Employees_Full_Time__c = 200;
		opp2.Benefits_Specialist__c = specialist.Id;
        oppPrimary = TestFactoryOpportunity.makeBenefits('BENEFITS: TEST CLIENT PRIMARY', clientPrimary.Id, Date.today().addDays(60), 'Pending Submission');
		oppPrimary.Active_Employees_Full_Time__c = 200;
		oppPrimary.Benefits_Specialist__c = specialist.Id;
		insert new List<Opportunity>{ opp1, opp2, oppPrimary };
            
		Benefits_Discovery_Questionnaire__c bdq1 = new Benefits_Discovery_Questionnaire__c(
			OpportunityId__c = opp1.Id
		);
		Benefits_Discovery_Questionnaire__c bdq2 = new Benefits_Discovery_Questionnaire__c(
			OpportunityId__c = opp2.Id
		);
        insert new List<Benefits_Discovery_Questionnaire__c>{ bdq1, bdq2};
		Test.stopTest();
    }

	static void loadData() {
		List<Account> accounts = [
			SELECT Id, Name, RecordTypeId
			FROM Account
			WHERE Name LIKE 'TEST_%'
			ORDER BY Name ASC
		];
		for(Account acc:accounts){
			if(acc.Name == 'TEST_BRANCH_ONE'){
				branch1 = acc;
			}
			if(acc.Name == 'TEST_BRANCH_TWO'){
				branch2 = acc;
			}
			if(acc.Name == 'TEST_CLIENT_Primary'){
				clientPrimary = acc;
			}
			if(acc.Name == 'TEST_CLIENT_ONE'){
				client1 = acc;
			}
			if(acc.Name == 'TEST_CLIENT_TWO'){
				client2 = acc;
			}
			if(acc.Name == 'TEST_REFERRALPARTNER'){
				referralPartner = acc;
			}
		}

		employee = [SELECT Id, Name FROM User WHERE FirstName = 'TEST' AND LastName = 'EMPLOYEE'];
		specialist = [SELECT Id, Name FROM User WHERE FirstName = 'TEST' AND LastName = 'SPECIALIST'];

		producer = [
			SELECT Id, Name, RecordTypeId
			FROM Contact
			WHERE FirstName = 'TEST' 
			AND LastName = 'PRODUCER'
			LIMIT 1
		];

		List<Opportunity> opps = [
			SELECT
				Id, Name, RecordTypeId, AccountId, StageName, Quoted_Annualized_Medical_Premium__c,
				Benefits_Type__c,  Benefits_Coordinator__c, Benefits_Specialist__c, Benefits_Consultant__c,L_H_Referral_Partner__c, L_H_Producer__c, 
				Employees_Enrolled_in_Medical__c, Estimated_Subscriber_Count__c, Is_there_a_benefits_referral_partner__c,
				Benefits_Effective_Date__c, Effective_Month__c, Benefits_Affiliates__c, Benefits_Affiliated_Companies__c,
				Active_Employees_All_Affiliates__c, Full_Time_Employees_All_Affiliates__c, Part_Time_Employees_All_Affiliates__c,
				Active_Employees_Full_Time__c,Insurance_Medical_Renewal__c,EE_Enrolled_Count_All_Affiliates__c,Benefits_Participation__c
			FROM Opportunity
			WHERE Name LIKE 'BENEFITS: TEST CLIENT %'
			ORDER BY Name ASC
		];
		opp1 = opps.get(0);
        oppPrimary = opps.get(1);
		opp2 = opps.get(2);
	}

	@IsTest
	static void test_onClosedWonCreateBenefits() {
		loadData();

		Assert.areEqual(100, opp1.Active_Employees_Full_Time__c);
		Assert.areEqual(200, opp2.Active_Employees_Full_Time__c);

		Test.startTest();
		opp1.Insurance_Medical_Renewal__c=system.Today();
		opp1.StageName = 'Benefits Closed Won';
		opp1.Admin_Factor__c = 1.0;
		opp1.Bucket__c = 3;
		opp1.Active_Employees_Part_Time__c = 0;
		opp1.Have_Documents_Been_Submitted__c = true;
		opp1.Benefits_Consultant__c = employee.Id;
		opp2.Is_there_a_benefits_referral_partner__c = 'Yes';
		opp2.L_H_Referral_Partner__c = referralPartner.Id;
		opp2.L_H_Producer__c = producer.Id;
		opp2.StageName = 'Benefits Closed Won';
        opp2.Insurance_Medical_Renewal__c=system.Today();
		opp2.Admin_Factor__c = 1.0;
		opp2.Bucket__c = 3;
		opp2.Active_Employees_Part_Time__c = 0;
		opp2.Have_Documents_Been_Submitted__c = true;
		opp2.Benefits_Consultant__c = employee.Id;
		opp2.Is_there_a_benefits_referral_partner__c = 'Yes';
		opp2.L_H_Referral_Partner__c = referralPartner.Id;
		opp2.L_H_Producer__c = producer.Id;
		opp2.Benefits_Consultant__c = specialist.Id;

		update new List<Opportunity>{ opp1, opp2 };

		Test.stopTest();

		List<Benefits__c> benefits = [
			SELECT Id, Name, Opportunity__c, Benefits_Consultant__c
			FROM Benefits__c
			WHERE Name LIKE 'BENEFITS: %'
			ORDER BY Name ASC
		];
		Assert.areEqual(2, benefits.size());
		Benefits__c benefits1 = benefits.get(0);
        		Benefits__c benefits2 = benefits.get(1);
        
		Assert.areEqual('BENEFITS: TEST CLIENT ONE', benefits1.Name);
		Assert.areEqual(opp1.Id, benefits1.Opportunity__c);
        
        Assert.areEqual('BENEFITS: TEST CLIENT TWO', benefits2.Name);
		Assert.areEqual(opp2.Id, benefits2.Opportunity__c);

		Assert.areEqual(benefits1.Benefits_Consultant__c, opp1.Benefits_Consultant__c);
		Assert.areEqual(benefits2.Benefits_Consultant__c, opp2.Benefits_Consultant__c);

		List<Account> clients = [
			SELECT Id, Name, Benefits__c, BBSI_Benefits__c, Benefits_Consultant__c
			FROM Account
			WHERE Id IN (:client1.Id, :client2.Id)
			ORDER BY Name
		];

		Assert.areEqual(2, clients.size());
		client1 = clients.get(0);
		client2 = clients.get(1);

		Assert.isTrue(client1.BBSI_Benefits__c, 'BBSI_Benefits should be set');
		Assert.isTrue(client2.BBSI_Benefits__c, 'BBSI_Benefits should be set');
	}

	@IsTest
	static void onClosedLostCancelTasks() {
        Test.startTest();

		loadData();
		
		client1.NumberOfEmployees = 100;
		client1.Active_Employees_Full_Time__c = 100;
		client1.Active_Employees_Part_Time__c = 0;
		update client1;

		opp1.StageName = 'Benefits Closed Won';
		opp1.Admin_Factor__c = 1.0;
		opp1.Bucket__c = 3;
		opp1.Active_Employees_Full_Time__c = 100;
		opp1.Active_Employees_Part_Time__c = 0;
		opp1.Have_Documents_Been_Submitted__c = true;
        opp1.Insurance_Medical_Renewal__c=system.Today();
		opp1.Benefits_Consultant__c = employee.Id;
		opp1.Closed_Reason_Comments__c = 'Testing';
		update opp1;     
		
		Id idrtBenefitsTask = RecordTypeService.getId('Task', 'Benefits Task');

		Task task1 = Task_Service.createTask(
			'Email',
			null,
			opp1.Id,
			employee.Id,
			'Task 1: Should be Cancel',
			'Description',
			Date.today().addDays(7)
		);
		task1.RecordTypeId = idrtBenefitsTask;

		Task task2 = Task_Service.createTaskCompleted(
			'Email',
			null,
			opp1.Id,
			employee.Id,
			'Task 2: Should be Completed',
			'Description'
		);
		task2.RecordTypeId = idrtBenefitsTask;

		Task task3 = Task_Service.createTask(
			'Email',
			null,
			opp1.Id,
			employee.Id,
			'Task 3: No Change',
			'Description',
			Date.today().addDays(7)
		);
		task3.Status = 'Discovery Meeting';

		insert new List<Task>{ task1, task2, task3 };

				//Test.startTest();
		opp1.StageName = 'Benefits Closed Lost';
		opp1.Closed_Reason__c = 'Testing';
		update opp1;

		Test.stopTest();
		
		List<Task> tasks = [
			SELECT Id, IsClosed, Status
			FROM Task
			WHERE WhatId = :opp1.Id
			AND Subject LIKE 'Task %'
			ORDER BY Subject
		];

		Assert.areEqual(3, tasks.size());

		Task task;

		task = tasks.get(0);
		Assert.areEqual(true, task.IsClosed);
		Assert.areEqual('Cancelled', task.Status);
		task = tasks.get(1);
		Assert.areEqual(true, task.IsClosed);
		Assert.areEqual('Completed', task.Status);
		task = tasks.get(2);
		Assert.areEqual(true, task.IsClosed);
		Assert.areEqual('Cancelled', task.Status);
	}

	@IsTest
	static void test_getQuestionnaires() {
		loadData();
		Test.startTest();

		Map<Id, Benefits_Discovery_Questionnaire__c> mapBdqs = Benefits_Service.getQuestionnaires(new List<Opportunity>{ opp1, opp2 });

		Test.stopTest();

		Assert.isTrue(mapBdqs.containsKey(opp1.Id));
		Assert.isTrue(mapBdqs.containsKey(opp2.Id));
	}

	@IsTest
	static void test_createBenefitsQuery() {
		List<Id> idOpps = new List<Id>{ '0061900000AoidgZZB'};

		String query = Benefits_Service.createBenefitsQuery(idOpps);

		Assert.isTrue(query.contains('Opportunity__c,'));
	}

	@IsTest
	static void test_createInitialTasks() {
		loadData();

		List<Task> tasks = [
			SELECT Id, Category__c, Subject FROM Task
			WHERE RecordType.Name = 'Benefits Task'
			AND WhatId = :opp1.Id
			ORDER BY Category__c ASC
		];

		Assert.areEqual(0, tasks.size(), 'Create the initial tasks for the Discovery stage');
	}

	@IsTest
	static void test_updateBenefitsByOpportunity() {
		List<Benefits__c> benefits;

		loadData();

		Benefits_Service.onClosedWonCreateBenefits(
			new List<Opportunity>{ opp2 }
		);

		benefits = [
			SELECT Id, Name, L_H_Referral_Partner__c, L_H_Producer__c, Opportunity__c
			FROM Benefits__c
			WHERE Name LIKE 'BENEFITS: %'
			ORDER BY Name ASC
		];
        if(benefits.size()>0){
        
		Benefits__c beforeBenefits = benefits.get(0);
        
		opp1.StageName = 'Benefits Closed Won';
		opp1.Admin_Factor__c = 1.0;
		opp1.Bucket__c = 3;
		opp1.Active_Employees_Full_Time__c = 100;
		opp1.Active_Employees_Part_Time__c = 0;
		opp1.Have_Documents_Been_Submitted__c = true;
		opp1.Benefits_Consultant__c = employee.Id;
		opp1.Is_there_a_benefits_referral_partner__c = 'No';
		opp2.StageName = 'Benefits Closed Won';
        opp2.Insurance_Medical_Renewal__c=system.Today();
		opp2.Admin_Factor__c = 1.0;
		opp2.Bucket__c = 3;
		opp2.Active_Employees_Full_Time__c = 100;
		opp2.Active_Employees_Part_Time__c = 0;
		opp2.Have_Documents_Been_Submitted__c = true;
		opp2.Benefits_Consultant__c = employee.Id;
		opp2.Is_there_a_benefits_referral_partner__c = 'No';

		Test.startTest();

		update new List<Opportunity>{ opp1, opp2 };

		Test.stopTest();

		benefits = [
			SELECT Id, Name, L_H_Referral_Partner__c, L_H_Producer__c, Opportunity__c
			FROM Benefits__c
			WHERE Name LIKE 'BENEFITS: %'
			ORDER BY Name ASC
		];

		Assert.areEqual(2, benefits.size());

		Assert.areEqual('BENEFITS: TEST CLIENT ONE', benefits.get(0).Name);

		Assert.areEqual('BENEFITS: TEST CLIENT TWO', benefits.get(1).Name);
		Assert.areEqual(beforeBenefits.Id, benefits.get(1).Id, 'A new Benefits should not be created');
	}
}
    //This  Method Added For Benefits Phase 6- Renewals 
    
    @IsTest
	static void test_onClosedWonCreateBenefitsRenewal() {
		loadData();

		Assert.areEqual(100, opp1.Active_Employees_Full_Time__c);
		Assert.areEqual(200, opp2.Active_Employees_Full_Time__c);
		List<Account> clients = new List<Account>();
        Test.startTest();
        Account acc = new Account();
		Benefits__c ben = new Benefits__c();
        ben.Full_Time_Employees_All_Affiliates__c = 10;
        ben.Part_Time_Employees_All_Affiliates__c = 20;
        ben.Active_Employees_All_Affiliates__c = 30;
        ben.AccountId__c=client1.id;
        ben.Opportunity__c = opp1.Id;
        insert ben;
        client1.Benefits__c = ben.id;
        update client1;
        
        opp1.StageName = Opportunity_Service.STAGE_PENDED_UNDERWRITING;
		opp1.Have_Common_Ownership__c = 'Yes';
        opp1.Have_Documents_Been_Submitted__c = true;
        opp1.Benefits_Specialist__c = userinfo.getUserId();
		opp1.Benefits_Consultant__c = userinfo.getUserId();
		opp1.Benefits_Coordinator__c = userinfo.getUserId();
        opp1.Have_Common_Ownership__c = 'Yes';
        opp1.Is_there_a_benefits_referral_partner__c = 'No';
		opp1.Security_Deposit_Required__c = 'No';
        update opp1;
        
        date renewalDate = system.Today().addDays(90);
		renewalDate = renewalDate.addYears(-1);

		opp1.Insurance_Medical_Renewal__c = renewalDate;
		opp1.StageName = 'Benefits Closed Won';
		opp1.Admin_Factor__c = 1.0;
		opp1.Bucket__c = 3;
		opp1.Active_Employees_Part_Time__c = 0;
		opp1.Active_Employees_Full_Time__c = 100;
		opp1.Have_Documents_Been_Submitted__c = true;		
		opp1.Have_Common_Ownership__c = 'Yes';
		opp1.Is_there_a_benefits_referral_partner__c = 'Yes';
		opp1.L_H_Referral_Partner__c = referralPartner.Id;
        opp1.L_H_Producer__c = producer.Id;
        update opp1;
        
		clients = [
			SELECT 	Id,
					Name,
					OwnerId,
					Benefits_Affiliates__c,
					Benefits_Affiliates__r.Benefits_Affiliated_Companies_Count__c, 
					Benefits_Affiliated_Companies__c,
					Client_Benefits_Renewal_Month__c,
					Name_Branch__c,
					Benefits_Representative__c,
					NumberOfEmployees,
					Active_Employees_Full_Time__c,
					Active_Employees_Part_Time__c,
					Producer__c, 
					Assigned_Referral_Partner__c, 
					BBSI_Benefits__c,
					RecordType.DeveloperName,
					Benefits_Affiliates_Type__c,
					BBSI_Benefits_Renewal_Date__c,
					Benefits_Type2__c,
					(SELECT Id, Active_Employees_All_Affiliates__c, 
							Full_Time_Employees_All_Affiliates__c, 
							Part_Time_Employees_All_Affiliates__c,
							Bucket__c,
							Admin_Factor__c,
							Is_there_common_ownership__c,
							Benefits_Coordinator__c,
							Benefits_Specialist__c,
							L_H_Referral_Partner__c,
							L_H_Producer__c,
							Is_there_a_benefits_referral_partner__c,
                     		Name, 
                     		Opportunity__c, 
                     		Benefits_Affiliates__c
						FROM BenefitsClient__r),
					(SELECT Id, Benefits_Consultant__c, RecordType.Id
						FROM Opportunities WHERE StageName = :Opportunity_Service.STAGE_BENEFITS_CLOSED_WON) 
			FROM Account WHERE Id =: client1.Id
		];
        Assert.areEqual(1, clients.size());
		acc = clients.get(0);
		Benefits__c benefits1 = acc.BenefitsClient__r.get(0);
        Benefits_Service.referralSourcesNeedtoInsert = new Map<Id,Referral_Partner__c>();
        Test.stopTest();
        Opportunity opp3 = TestFactoryOpportunity.makeBenefitsRenewal('BENEFITS: TEST CLIENT Three', acc.Id, acc.BBSI_Benefits_Renewal_Date__c, Opportunity_Service.STAGE_PENDED_UNDERWRITING);
        insert opp3; 
        opp3.Insurance_Medical_Renewal__c=system.Today(); 
        opp3.Admin_Factor__c = 1.0;
		opp3.Bucket__c = 3;
		opp3.Active_Employees_Part_Time__c = 0;
		opp3.Have_Documents_Been_Submitted__c = true;
		opp3.Benefits_Consultant__c = userinfo.getUserId();
        opp3.Renewal_Admin_Factor__c=20;
        opp3.Renewal_Bucket__c=30;
        opp3.Benefits_Affiliates__c = benefits1.Benefits_Affiliates__c;        
        opp3.StageName = Opportunity_Service.STAGE_BENEFITS_CLOSED_WON;
		opp3.Closed_Reason_Comments__c = 'Testing';
        update opp3;
        Benefits_Service.referralSourcesNeedtoInsert = new Map<Id,Referral_Partner__c>();
        opp3.StageName = Opportunity_Service.STAGE_BENEFITS_CLOSED_LOST;
        update opp3;
        Assert.areEqual(1, acc.BenefitsClient__r.size());
        Assert.areEqual(opp1.Id, benefits1.Opportunity__c);
    }	

	/**
	 * @description test_setBranchInsert performs a test on the test_setBranch
	 * method during an INSERT.
	 */
	@IsTest
	public static void test_setBranchInsert() {
		loadData();		
		Test.startTest();
		Benefits__c b1 = new Benefits__c(
			AccountId__c = client1.Id
		);
		Benefits_Service.setBranch(null, new List<Benefits__c>{ b1 });		
		Test.stopTest();		
		Assert.areEqual(branch1.Name, b1.Branch_Name__c);
	}

	/**
	 * @description test_setBranchUpdate performs a test on the test_setBranch
	 * method during an UPDATE.
	 */
	@IsTest
	public static void test_setBranchUpdate() {
		loadData();		
		Test.startTest();
		Benefits__c b1 = new Benefits__c(
			Id = FAKE_BENEFITS_ID,
			AccountId__c = client1.Id,
			Branch_Name__c = branch2.Id
		);
		Benefits__c b1Old = new Benefits__c(
			Id = FAKE_BENEFITS_ID,
			AccountId__c = client2.Id,
			Branch_Name__c = branch2.Id
		);		
		Benefits_Service.setBranch(new Map<Id, Benefits__c>{ FAKE_BENEFITS_ID => b1Old }, new List<Benefits__c>{ b1 });		
		Test.stopTest();		
		Assert.areEqual(branch1.Name, b1.Branch_Name__c);
	}

    //This  Method Added For Benefits Phase 2- Commissions     
    @IsTest
	static void test_onClosedWonCreateBenefitsRenewalPrimary() {
		loadData();
		
		Assert.areEqual(100, opp1.Active_Employees_Full_Time__c);
		Assert.areEqual(200, opp2.Active_Employees_Full_Time__c);
		List<Account> clients = new List<Account>();
        Test.startTest();
        Account acc = new Account();
		
        date renewalDate = system.Today().addDays(90);
        renewalDate = renewalDate.addYears(-1);
		oppPrimary.Insurance_Medical_Renewal__c= renewalDate;
		oppPrimary.StageName = 'Benefits Closed Won';
		oppPrimary.Admin_Factor__c = 1.0;
		oppPrimary.Bucket__c = 3;
		oppPrimary.Active_Employees_Part_Time__c = 0;
        oppPrimary.Active_Employees_Full_Time__c = 100;
		oppPrimary.Have_Documents_Been_Submitted__c = true;
		oppPrimary.Benefits_Consultant__c = employee.Id;	
        oppPrimary.Have_Common_Ownership__c = 'Yes';
        oppPrimary.Benefits_Specialist__c = specialist.Id;
        oppPrimary.Benefits_Consultant__c = specialist.Id;
        oppPrimary.Benefits_Coordinator__c = specialist.Id;
		update new List<Opportunity>{ oppPrimary };
        clients = [
			SELECT Id, Name, Benefits__c, Benefits_Affiliates__c,Benefits_Affiliates__r.Benefits_Affiliated_Companies_Count__c, 
            Benefits_Affiliated_Companies__c, Producer__c, Assigned_Referral_Partner__c, BBSI_Benefits__c, RecordType.DeveloperName, 
            Benefits_Affiliates_Type__c, BBSI_Benefits_Renewal_Date__c, Benefits_Representative__c, OwnerId
			FROM Account
			WHERE Id IN (:clientPrimary.Id)
			ORDER BY Name
		];
        Assert.areEqual(1, clients.size());
		acc = clients.get(0);
		List<Benefits__c> benefits = [
			SELECT Id, Name, Opportunity__c, Benefits_Affiliates__c, AccountId__c
			FROM Benefits__c
			WHERE Name LIKE 'BENEFITS: %'
			ORDER BY Name ASC
		];
		Assert.areEqual(1, benefits.size());
		Benefits__c benefits1 = benefits.get(0);        
		Benefits_Service.referralSourcesNeedtoInsert = new Map<Id,Referral_Partner__c>();
        Test.stopTest();
        Opportunity opp3 = TestFactory.opportunityBenefitsRenewal('BENEFITS: TEST CLIENT Three', acc.Id, acc.BBSI_Benefits_Renewal_Date__c, '', false);
		
		opp3.Insurance_Medical_Renewal__c=system.Today(); 
        opp3.Admin_Factor__c = 1.0;
		opp3.Bucket__c = 3;
		opp3.Active_Employees_Part_Time__c = 0;
		opp3.Have_Documents_Been_Submitted__c = true;
		opp3.Benefits_Consultant__c = employee.Id;	
        opp3.Renewal_Admin_Factor__c=20;
        opp3.Renewal_Bucket__c=30;
        opp3.Benefits_Affiliates__c = benefits1.Benefits_Affiliates__c;
		opp3.Closed_Reason_Comments__c = 'Testing';
        insert opp3;         
        opp3.StageName = Opportunity_Service.STAGE_BENEFITS_CLOSED_LOST;
        update opp3;                  
        BenefitsAffiliatesBenefits.selectBenefitsByName(new Set<String>{benefits1.Name});
        BenefitsAffiliatesBenefits.selectBenefitsByAccounts(new Set<Id>{benefits1.AccountId__c});   
        Assert.areEqual('BENEFITS: TEST CLIENT PRIMARY', benefits1.Name);
		Assert.areEqual(oppPrimary.Id, benefits1.Opportunity__c);     
	}
}