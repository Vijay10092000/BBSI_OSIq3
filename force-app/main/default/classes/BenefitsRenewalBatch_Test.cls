@IsTest
@SuppressWarnings('PMD.ApexAssertionsShouldIncludeMessage')
public without sharing class BenefitsRenewalBatch_Test {
	private static Account branch;
	private static Account client1;
	private static Opportunity opp1;
	private static User employee;
	private static User specialist;

	@TestSetup
	static void makeData() {
		Test.startTest();
		branch = TestFactoryAccount.createBranch('TEST_BRANCH');

		employee = TestFactoryUser.makeUser('TEST', 'EMPLOYEE', 'BBSI Standard', branch.External_Id__c);
		specialist = TestFactoryUser.makeUser('TEST', 'SPECIALIST', 'BBSI Standard', branch.External_Id__c);
		insert new List<User>{ employee, specialist };

		client1 = TestFactoryAccount.makeClient('TEST_CLIENT_ONE', null, null);
		client1.NumberOfEmployees = 110;
		client1.Active_Employees_Full_Time__c = 100;
		client1.Active_Employees_Part_Time__c = 10;
		client1.Benefits_Representative__c = specialist.Id;
		client1.BBSI_Benefits_Renewal_Date__c = Date.today().addDays(90);
		insert client1;

		opp1 = TestFactoryOpportunity.makeBenefits(
			'BENEFITS: TEST_CLIENT_ONE',
			client1.Id,
			Date.today().addDays(20),
			'Pending Submission'
		);
		opp1.Active_Employees_Full_Time__c = 100;
		opp1.Benefits_Specialist__c = specialist.Id;
		opp1.Insurance_Medical_Renewal__c = system.today();
		insert opp1;
		Test.stopTest();
	}

	static void loadData() {
		branch = [SELECT Id, Name FROM Account WHERE Name = 'TEST_BRANCH'];
		
		employee = [SELECT Id, Name FROM User WHERE FirstName = 'TEST' AND LastName = 'EMPLOYEE'];
		specialist = [SELECT Id, Name FROM User WHERE FirstName = 'TEST' AND LastName = 'SPECIALIST'];

		opp1 = [
			SELECT
				Id,
				Name,
				RecordTypeId,
				AccountId,
				StageName,
				Quoted_Annualized_Medical_Premium__c,
				Benefits_Type__c,
				Benefits_Coordinator__c,
				Benefits_Specialist__c,
				Employees_Enrolled_in_Medical__c,
				Estimated_Subscriber_Count__c,
				Is_there_a_benefits_referral_partner__c,
				Benefits_Effective_Date__c,
				Effective_Month__c,
				Benefits_Affiliates__c,
				Benefits_Affiliated_Companies__c,
				Active_Employees_All_Affiliates__c,
				Full_Time_Employees_All_Affiliates__c,
				Part_Time_Employees_All_Affiliates__c,
				Active_Employees_Full_Time__c,
				Insurance_Medical_Renewal__c,
				EE_Enrolled_Count_All_Affiliates__c,
				Benefits_Participation__c
			FROM Opportunity
			WHERE Name = 'BENEFITS: TEST_CLIENT_ONE'
			ORDER BY Name ASC
			LIMIT 1
		];
	}

	@IsTest
	static void test_benefitsRenewal() {
		loadData();

		date renewalDate = system.Today().addDays(90);
		renewalDate = renewalDate.addYears(-1);

		opp1.Insurance_Medical_Renewal__c = renewalDate;
		opp1.StageName = 'Benefits Closed Won';
		opp1.Admin_Factor__c = 1.0;
		opp1.Bucket__c = 3;
		opp1.Active_Employees_Part_Time__c = 0;
		opp1.Active_Employees_Full_Time__c = 100;
		opp1.Have_Documents_Been_Submitted__c = true;
		opp1.Benefits_Consultant__c = employee.Id;
		opp1.Have_Common_Ownership__c = 'Yes';
		opp1.Is_there_a_benefits_referral_partner__c = 'No';
		opp1.Benefits_Specialist__c = specialist.Id;
		opp1.Benefits_Consultant__c = specialist.Id;
		opp1.Benefits_Coordinator__c = specialist.Id;
		update new List<Opportunity>{ opp1 };

		Test.startTest();

		Database.executeBatch(new BenefitsRenewalBatch(), 100);

		Test.stopTest();
	}
}