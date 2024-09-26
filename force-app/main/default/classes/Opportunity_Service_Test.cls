/**
 * @description Opportunity_Service_Test tests methods in the Opportunity_Service class.
 */
@IsTest
public without sharing class Opportunity_Service_Test {
	private static User userBDM;
	private static Account branch;
	private static Account referralPartner;
	private static Contact producer;
	private static Lead leadWithEstimate;
	private static Lead leadWithoutEstimate;
	private static Lead leadRP;

	/**
	 * @description makeData creates a few Leads for testing.
	 */
	@TestSetup
	static void makeData() {
        userBDM = TestFactoryUser.createBDM('Test', 'BdmUser', 'Area Manager', '910');
		branch = TestFactoryAccount.makeBranch('TEST_BRANCH', '999', userBDM.Name, userBDM.Email);
		referralPartner = TestFactoryAccount.makeReferralPartner(
			'ReferralPartner Test',
			'% of Margin',
			12.0,
			null
		);
		insert new List<Account>{ branch, referralPartner };

		producer = TestFactoryContact.createContact('Contact', 'Producer', 'Producer', referralPartner.Id);

		leadWithEstimate = TestFactoryLead.makeClientLead(
			'TEST',
			'ClientLeadWith',
			'EmailCompany',
			branch.Id,
			userBDM.Id
		);
		leadWithEstimate.Request_Area_Manager_Approval__c = false;
		leadWithEstimate.Referral_Partner__c = referralPartner.Id;
		leadWithEstimate.Producer__c = producer.Id;
		leadWithEstimate.Estimated_Annual_Billing__c = 2300000;

		leadWithoutEstimate = TestFactoryLead.makeClientLead(
			'TEST',
			'ClientLeadWithout',
			'EmailCompany',
			branch.Id,
			userBDM.Id
		);
		leadWithoutEstimate.Request_Area_Manager_Approval__c = false;
		leadWithoutEstimate.Referral_Partner__c = referralPartner.Id;
		leadWithoutEstimate.Producer__c = producer.Id;

		leadRP = TestFactoryLead.makeLeadRP(
			'TEST',
			'ReferralPartnerLead',
			'EmailCompany'
		);

		insert new List<Lead>{ leadWithEstimate, leadWithoutEstimate, leadRP };
	}

	/**
	 * @description loadData retrieves the setup data into static fields.
	 */
	static void loadData() {
		userBDM = [SELECT Id, Name FROM User WHERE Name = 'Test BdmUser'];
		branch = [SELECT Id, Name FROM Account WHERE Name = 'TEST_BRANCH'];
		referralPartner = [SELECT Id, Name FROM Account WHERE Name = 'ReferralPartner Test'];
		producer = [SELECT Id, Name FROM Contact WHERE Name = 'Contact Producer'];

		leadWithEstimate = [
			SELECT Id, Name, RecordTypeId, Estimated_Annual_Billing__c
			FROM Lead
			WHERE LastName = 'ClientLeadWith'
		];
		leadWithoutEstimate = [
			SELECT Id, Name, RecordTypeId, Estimated_Annual_Billing__c
			FROM Lead
			WHERE LastName = 'ClientLeadWithout'
		];
		leadRP = [
			SELECT Id, Name, RecordTypeId, Estimated_Annual_Billing__c
			FROM Lead
			WHERE LastName = 'ReferralPartnerLead'
		];
	}

	/**
	 * @description test_updateFieldsFromLead tests the future method call by converting
	 * the Leads.
	 */
	@IsTest
	public static void test_updateFieldsFromLeadClient() {
		loadData();

		
		Test.startTest();
		Database.LeadConvertResult resultWith = LeadConvert.convert(leadWithEstimate.Id, true);
        Test.stopTest();
		try {
			LeadConvert.convert(leadWithoutEstimate.Id, true);
		} catch (Exception e) {
			System.assert(true, 'Should not throw exception.');
		}

		

		System.assert(resultWith.isSuccess(), 'Convert of "WITH" Failed');
		Opportunity oppWith = [SELECT Id, Amount FROM Opportunity WHERE Id = :resultWith.opportunityid];
		System.assertEquals(
			leadWithEstimate.Estimated_Annual_Billing__c,
			oppWith.Amount,
			'Opportunity\'s Estimated Annual Billing should be same as lead came from.'
		);
		System.assert(oppWith.Amount > 0, 'Opportunity\'s Estimated Annual Billing should be greater than 0.');
	}

	/**
	 * @description test_updateFieldsFromLead tests the future method call by converting
	 * the Leads.
	 */
	@IsTest
	public static void test_updateFieldsFromLeadRP() {
		loadData();

		Test.startTest();

		Database.LeadConvertResult resultRP = LeadConvert.convert(leadRP.Id, false);

		Test.stopTest();

		System.assert(resultRP.isSuccess(), 'Convert of "RP" Failed');
		System.assertEquals(null, resultRP.opportunityid, 'No opportunity should have been created');
	}

	@IsTest
	public static void test_setInitialValues() {
		Account client = TestFactoryAccount.makeClient('!!!BBSI TEST CLIENT', null, null);
		client.External_Id__c = 'TEST';
		insert client;

		Id idrtBenefits = RecordTypeService.getId('Opportunity', 'Benefits');
		Id idrtClient = RecordTypeService.getId('Opportunity', 'Client');

		Opportunity opp1 = new Opportunity(
			Name = 'TEST BENEFITS',
			AccountId = client.Id,
			RecordTypeId = idrtBenefits
		);

		Test.startTest();

		OpportunityBenefits_Service.setInitialValues(new List<Opportunity>{ opp1 });

		Test.stopTest();

		System.assertEquals(0, opp1.Amount, 'Benefits Opportunity should update');
	}

	@IsTest
	public static void test_onClose_SetBDM() {
		loadData();

		Account client1 = TestFactoryAccount.makeClient('CLIENT 1', null, null);
		Account client2 = TestFactoryAccount.makeClient('CLIENT 2', null, null);
		client1.Business_Development_Manager__c = userBDM.Id;
		client1.External_Id__c = null;
		client2.Business_Development_Manager__c = userBDM.Id;
		client2.External_Id__c = null;
		insert new List<Account>{ client1, client2 };

		Opportunity opp1 = TestFactoryOpportunity.makeClient('OPP 1', client1.Id, Date.today().addMonths(7), Opportunity_Service.STAGE_DISCOVERY_MEETING);
		Opportunity opp2 = TestFactoryOpportunity.makeClient('OPP 2', client2.Id, Date.today().addDays(-7), Opportunity_Service.STAGE_CLOSED_LOST);
		opp1.Amount = 100000;
		opp2.Amount = 200000;
		opp2.Closed_Reason__c = 'TEST CLOSED';
		insert new List<Opportunity>{ opp1, opp2 };

		List<Opportunity> opps;
		opps = [
			SELECT Id, Name, IsClosed, BDM_at_Time_of_Close__c 
			FROM Opportunity 
			WHERE Id = :opp1.Id OR Id = :opp2.Id
			ORDER BY Name ASC
		];
		opp1 = opps.get(0);
		opp2 = opps.get(1);

		Assert.isFalse(opp1.IsClosed);
		Assert.isTrue(opp2.IsClosed);
		Assert.isNull(opp1.BDM_at_Time_of_Close__c);
		Assert.areEqual(userBDM.Id, opp2.BDM_at_Time_of_Close__c);

		Test.startTest();

		opp1.StageName = Opportunity_Service.STAGE_BENEFITS_CLOSED_WON;
		update opp1;

		Test.stopTest();
		
		opps = [
			SELECT Id, Name, IsClosed, BDM_at_Time_of_Close__c 
			FROM Opportunity 
			WHERE Id = :opp1.Id OR Id = :opp2.Id
			ORDER BY Name ASC
		];
		opp1 = opps.get(0);
		opp2 = opps.get(1);

		Assert.isTrue(opp1.IsClosed);
		Assert.isTrue(opp2.IsClosed);
		Assert.areEqual(userBDM.Id, opp1.BDM_at_Time_of_Close__c);
		Assert.areEqual(userBDM.Id, opp2.BDM_at_Time_of_Close__c);
	}
    
    @IsTest
	public static void test_getOwners() {
		loadData();

		Account client1 = TestFactoryAccount.makeClient('CLIENT 1', null, null);
		client1.Business_Development_Manager__c = userBDM.Id;
		client1.External_Id__c = null;
		insert new List<Account>{ client1 };

		Opportunity opp1 = TestFactoryOpportunity.makeClient('OPP 1', client1.Id, Date.today().addMonths(7), Opportunity_Service.STAGE_DISCOVERY_MEETING);
		opp1.Amount = 100000;
		opp1.OwnerId = userBDM.Id;
		insert new List<Opportunity>{ opp1 };

		Assert.isNotNull(opp1.Id);
		
		Test.startTest();
		
		Map<Id, User> result = Opportunity_Service.getOwners(new List<Opportunity>{ opp1 });
		
		Test.stopTest();

		Assert.areEqual(1, result.keySet().size());

		User user = result.get(opp1.Id);
		Assert.areEqual(userBDM.Id, user.Id);
	}

	@IsTest
	public static void test_getAccountOwners() {
		loadData();

		Account client1 = TestFactoryAccount.makeClient('CLIENT 1', null, null);
		client1.Business_Development_Manager__c = userBDM.Id;
		client1.External_Id__c = null;
		client1.OwnerId = userBDM.Id;
		insert new List<Account>{ client1 };

		Opportunity opp1 = TestFactoryOpportunity.makeClient('OPP 1', client1.Id, Date.today().addMonths(7), Opportunity_Service.STAGE_DISCOVERY_MEETING);
		opp1.Amount = 100000;
		insert new List<Opportunity>{ opp1 };

		Assert.isNotNull(opp1.Id);
		
		Test.startTest();
		
		Map<Id, User> result = Opportunity_Service.getAccountOwners(new List<Opportunity>{ opp1 });
		
		Test.stopTest();

		Assert.areEqual(1, result.keySet().size());

		User user = result.get(opp1.Id);
		Assert.areEqual(userBDM.Id, user.Id);
	}
	
	@IsTest
	public static void test_makeClientEvent() {
		loadData();
        Test.startTest();
        User user1 = TestFactoryUser.createUser('TEST', 'user1', 'BBSI Standard', '910');
        Account client1 = TestFactoryAccount.makeClient('CLIENT 1', null, null);
        insert client1;
        Opportunity opp1 = TestFactoryOpportunity.makeClient('OPP 1', client1.Id, Date.today().addMonths(2), Opportunity_Service.STAGE_PRE_DISCOVERY);
        insert opp1;
        Opportunity_Service.makeClientEvent('Testopp',client1.id,user1.id);
        
        Test.stopTest();
        Assert.areEqual(Opportunity_Service.STAGE_PRE_DISCOVERY, opp1.StageName, 'Stage should be Pre-Discovery'); 
    }
    
    @IsTest
	public static void test_getAccountOpportunities() {
        loadData();
        Test.startTest();
		Set<id> Accountset = new Set<Id>();
		Account client1 = TestFactoryAccount.makeClient('CLIENT 1', null, null);
		Account client2 = TestFactoryAccount.makeClient('CLIENT 2', null, null);
		List<Account> acclist = new List<Account>{ client1, client2 };

		for (Account acc : acclist) {
			Accountset.add(acc.id);
		}                    
			
		Opportunity opp1 = TestFactoryOpportunity.makeClient('OPP 1', client1.Id, null,Opportunity_Service.RECORDTYPE_CLIENT);
		Opportunity opp2 = TestFactoryOpportunity.makeClient('OPP 2', client1.Id, null,Opportunity_Service.RECORDTYPE_CLIENT);

		insert new List<Opportunity>{opp1,opp2};
			
		Map<Id, Map<Id, List<Opportunity>>> oppMap = Opportunity_Service.getAccountOpportunities(Accountset);
		Assert.isNotNull(oppMap, 'Should Not be null');
		Map<String, Schema.DisplayType> displayTypeMap = Opportunity_Service.getOpportunityFieldTypes('');
		Assert.isNull(displayTypeMap, 'Should be null');
		displayTypeMap = Opportunity_Service.getOpportunityFieldTypes('Opportunity');
		Assert.isNotNull(displayTypeMap, 'Should Not be null');
        Test.stopTest();        
    }
}