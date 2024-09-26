/**
 * @description Account_Services_Test contains tests for the Account_Services class.
 */
@IsTest
@SuppressWarnings('PMD.ApexAssertionsShouldIncludeMessage')
public without sharing class Account_Services_Test {
	
	/**
	 * @description testGetContactCount check the number of contacts on an account
	 */
	@IsTest
	static void testGetContactCount() {
		Account a1 = TestFactory.createAccount('TEST ACCOUNT 1', '99999', 'BBSI Branch', false);
		Account a2 = TestFactory.createAccount('TEST ACCOUNT 2', '99999', 'BBSI Branch', false);
		Account a3 = TestFactory.createAccount('TEST ACCOUNT 3', '99999', 'BBSI Branch', false);
		Account a4 = TestFactory.createAccount('TEST ACCOUNT 4', '99999', 'BBSI Branch', false);
		insert new List<Account>{ a1, a2, a3, a4 };

		Contact c1a1 = TestFactory.createContact(a1, 'Lastname1', 'BBSI Employee', false);
		Contact c2a2 = TestFactory.createContact(a2, 'Lastname2', 'BBSI Employee', false);
		Contact c3a1 = TestFactory.createContact(a1, 'Lastname3', 'BBSI Employee', false);
		Contact c4a4 = TestFactory.createContact(a4, 'Lastname4', 'BBSI Employee', false);
		Contact c5a2 = TestFactory.createContact(a2, 'Lastname5', 'BBSI Employee', false);
		Contact c6a1 = TestFactory.createContact(a1, 'Lastname6', 'BBSI Employee', false);
		Contact c7a3 = TestFactory.createContact(a3, 'Lastname7', 'BBSI Employee', false);
		Contact c8a1 = TestFactory.createContact(a1, 'Lastname8', 'BBSI Employee', false);
		insert new List<Contact>{ c1a1, c2a2, c3a1, c4a4, c5a2, c6a1, c7a3, c8a1 };

		Test.startTest();

		Map<Id, Integer> mapAccountContactCounts = Account_Services.getContactCount(
			new Set<Id>{ a1.Id, a2.Id, a3.Id, a4.Id }
		);

		System.assertEquals(4, mapAccountContactCounts.get(a1.Id));
		System.assertEquals(2, mapAccountContactCounts.get(a2.Id));
		System.assertEquals(1, mapAccountContactCounts.get(a3.Id));
		System.assertEquals(1, mapAccountContactCounts.get(a4.Id));

		Test.stopTest();
	}

	@IsTest
	static void test_populateReferralPartnerStatus() {
		Account rp1 = TestFactory.createAccountReferralPartner(
			'TEST REFERRAL PARTNER 1',
			null,
			'% of Margin',
			2.12,
			null,
			false
		);
		Account rp2 = TestFactory.createAccountReferralPartner(
			'TEST REFERRAL PARTNER 2',
			'Active',
			'% of Margin',
			2.12,
			null,
			false
		);
		Account rp3 = TestFactory.createAccountReferralPartner(
			'TEST REFERRAL PARTNER 3',
			'Inactive',
			'% of Margin',
			2.12,
			null,
			false
		);
		Account c1 = TestFactory.createAccountClient('TEST CLIENT ACCOUNT 1', false);
		Account b1 = TestFactory.createAccountBranch('TEST BRANCH 1', '000', 'TEST AM', 'test.am@bbsi.zzz', false);

		List<Account> accounts = new List<Account>{ rp1, rp2, rp3, c1, b1 };

		Account_Services.populateReferralPartnerStatus(accounts);

		System.assertEquals(
			'Pending',
			accounts.get(0).Referral_Partner_Status__c,
			'Referral Partner Status should have changed to Pending'
		);
		System.assertEquals(
			'Active',
			accounts.get(1).Referral_Partner_Status__c,
			'Referral Partner Status should not have changed'
		);
		System.assertEquals(
			'Inactive',
			accounts.get(2).Referral_Partner_Status__c,
			'Referral Partner Status should not have changed'
		);
		System.assert(
			String.isBlank(accounts.get(3).Referral_Partner_Status__c),
			'Client should not have a Referral Partner Status'
		);
		System.assert(
			String.isBlank(accounts.get(4).Referral_Partner_Status__c),
			'Branch should not have a Referral Partner Status'
		);
	}

	@IsTest
	static void test_updateProspectReferralSources() {
		Account referralPartner1 = TestFactory.createAccountReferralPartner(
			'ReferralPartner',
			'Active',
			'% of Margin',
			8.9,
			null,
			false
		);
		Account referralPartner2 = TestFactory.createAccountReferralPartner(
			'ReferralPartner',
			'Active',
			'% of WC Eligible Payroll',
			10.9,
			null,
			false
		);
		Contact producer1 = TestFactory.createContact(referralPartner1, 'Lastname1', 'Producer', false);
		Contact producer2 = TestFactory.createContact(referralPartner2, 'Lastname2', 'Producer', false);

		insert new List<Account>{ referralPartner1, referralPartner2 };
		insert new List<Contact>{ producer1, producer2 };

		Account prospect = TestFactory.createAccount('Prospect', '88889', 'Prospect', false);
		prospect.Producer__c = producer1.Id;
		prospect.Assigned_Referral_Partner__c = referralPartner1.Id;
		insert prospect;

		List<Referral_Partner__c> referralSources = [
			SELECT
				Id,
				Account__c,
				Effective_Date__c,
				Termination_Date__c,
				Producer__c,
				Referral_Partner__c,
				Commission_Rate__c,
				Referral_Partner_Commission_Type__c
			FROM Referral_Partner__c
			WHERE Account__c = :prospect.Id
		];

		System.assertEquals(1, referralSources.size(), '1 Referral Source should have been created');

		Referral_Partner__c rs = referralSources.get(0);
		System.assertEquals(prospect.Id, rs.Account__c, 'Account should have been set to prospect');
		System.assertEquals(System.today(), rs.Effective_Date__c, 'Effective date should have been set to today');
		System.assertEquals(null, rs.Termination_Date__c, 'Termination date should not have a value');
		System.assertEquals(producer1.Id, rs.Producer__c, 'Producer should have been set');
		System.assertEquals(referralPartner1.Id, rs.Referral_Partner__c, 'Referral Partner should have been set');
		System.assertEquals(8.9, rs.Commission_Rate__c, 'Commission Rate should have been set');
		System.assertEquals(
			'% of Margin',
			rs.Referral_Partner_Commission_Type__c,
			'Commission Type should have been set'
		);

		Test.startTest();

		prospect.Producer__c = producer2.Id;
		prospect.Assigned_Referral_Partner__c = referralPartner2.Id;
		update prospect;

		Test.stopTest();

		referralSources = [
			SELECT
				Id,
				Account__c,
				Effective_Date__c,
				Termination_Date__c,
				Producer__c,
				Referral_Partner__c,
				Commission_Rate__c,
				Referral_Partner_Commission_Type__c
			FROM Referral_Partner__c
			WHERE Account__c = :prospect.Id
		];

		System.assertEquals(2, referralSources.size(), '2 Referral Source should exist');

		for (Referral_Partner__c referralSource : referralSources) {
			if (referralSource.Termination_Date__c == null) {
				System.assertEquals(prospect.Id, referralSource.Account__c, 'Account should have been set to prospect');
				System.assertEquals(
					System.today(),
					referralSource.Effective_Date__c,
					'Effective date should have been set to today'
				);
				System.assertEquals(
					null,
					referralSource.Termination_Date__c,
					'Termination date should not have a value'
				);
				System.assertEquals(producer2.Id, referralSource.Producer__c, 'Producer should have been set');
				System.assertEquals(
					referralPartner2.Id,
					referralSource.Referral_Partner__c,
					'Referral Partner should have been set'
				);
				System.assertEquals(10.9, referralSource.Commission_Rate__c, 'Commission Rate should have been set');
				System.assertEquals(
					'% of WC Eligible Payroll',
					referralSource.Referral_Partner_Commission_Type__c,
					'Commission Type should have been set'
				);
			} else {
				System.assertNotEquals(
					null,
					referralSource.Termination_Date__c,
					'Termination date should have a value'
				);
				System.assertEquals(producer1.Id, referralSource.Producer__c, 'Producer should have been set');
				System.assertEquals(
					referralPartner1.Id,
					referralSource.Referral_Partner__c,
					'Referral Partner should have been set'
				);
			}
		}
	}

	@IsTest
	@SuppressWarnings('PMD.AvoidHardcodingId')
	static void setHeadquarterState() {
		Account client1 = new Account(
			ID = '0012h00000aaaYSAAY',
			Name = 'Client1',
			ShippingState = 'IO',
			Headquarters_State__c = null
		);
		Account client2 = new Account(
			ID = '0012h00000bbbYSAAY',
			Name = 'Client1',
			ShippingState = null,
			Headquarters_State__c = null
		);
		Account client3 = new Account(
			ID = '0012h00000cccYSAAY',
			Name = 'Client1',
			ShippingState = 'IO',
			Headquarters_State__c = 'UT'
		);
		Account client4 = new Account(
			ID = '0012h00000dddYSAAY',
			Name = 'Client1',
			ShippingState = 'Iowa',
			Headquarters_State__c = null
		);

		List<Account> listNew = new List<Account>{ client1, client2, client3, client4 };

		Account_Services.setHeadquarterState(null, listNew);

		System.assertEquals('IO', client1.Headquarters_State__c, 'Set the state');
		System.assertEquals(null, client2.Headquarters_State__c, 'No state to set');
		System.assertEquals('UT', client3.Headquarters_State__c, 'Headquarters already set');
		System.assertEquals(null, client4.Headquarters_State__c, 'Not 2 letter abbreviation');
	}

	@IsTest
	static void test_formatPhoneNumber() {
		Account prospect1 = TestFactory.createAccountProspect('!!PROSPECT1', false);
		Account prospect2 = TestFactory.createAccountProspect('!!PROSPECT2', false);
		Account prospect3 = TestFactory.createAccountProspect('!!PROSPECT3', false);
		Account prospect4 = TestFactory.createAccountProspect('!!PROSPECT4', false);
		List<Account> prospects = new List<Account>{ prospect1, prospect2, prospect3, prospect4 };

		Test.startTest();

		prospect1.put('Phone', '1360./789/0000 ext.89');
		prospect2.put('Phone', '1.360.789.0000');
		prospect3.put('Phone', '1 360/789/0000 ex 801');
		prospect4.put('Phone', '360./789/09');

		Account_Services.formatPhoneNumber(null, prospects);

		Test.stopTest();

		System.assertEquals('360-789-0000 ext 89', prospect1.Phone);
		System.assertEquals('360-789-0000', prospect2.Phone);
		System.assertEquals('360-789-0000 ex 801', prospect3.Phone);

		List<Database.Error> errors = prospect4.getErrors();
		System.assertEquals(1, errors.size(), 'Should have an error');
	}

	@IsTest
	static void test_getAccountsByType() {
		Account branch = TestFactory.createAccountBranch('!!TESTBRANCH1', '99999', '1111', false);
		Account client1 = TestFactory.createAccountClient('!!TESTCLIENT1', false);
		Account client2 = TestFactory.createAccountClient('!!TESTCLIENT2', false);
		Account prospect1 = TestFactory.createAccountProspect('!!TESTPROSPECT1', false);
		Account prospect2 = TestFactory.createAccountProspect('!!TESTPROSPECT2', false);
		List<Account> accounts = new List<Account>{ branch, client1, client2, prospect1, prospect2 };
		insert accounts;

		List<Account> branches = Account_Services.getAccountsByType(accounts, 'BBSI Branch');
		System.assertEquals(1, branches.size());
		List<Account> clients = Account_Services.getAccountsByType(accounts, 'Client');
		System.assertEquals(2, clients.size());
		List<Account> prospects = Account_Services.getAccountsByType(accounts, 'Prospect');
		System.assertEquals(2, prospects.size());

		try {
			Account_Services.getAccountsByType(accounts, 'BAD TYPE');
			System.assert(false, 'Exception should have been thrown');
		} catch (Exception e) {
			System.assert(true, 'Exception thrown');
		}
		try {
			Account_Services.getAccountsByType(accounts, (Id) null);
			System.assert(false, 'Exception should have been thrown');
		} catch (Exception e) {
			System.assert(true, 'Exception thrown');
		}
	}

	@IsTest
	static void test_BranchName() {
		Account branch1 = TestFactoryAccount.makeBranch('TESTBRANCH ONE');
		Account branch2 = TestFactoryAccount.makeBranch('TESTBRANCH TWO');
		insert new List<Account>{ branch1, branch2 };

		Account client1 = TestFactoryAccount.makeClient('!!!Test Client 1', null, null);
		Account client2 = TestFactoryAccount.makeClient('!!!Test Client 2', null, null);
		client1.Prospect_Branch__c = branch1.Id;
		insert new List<Account>{ client1, client2 };

		Opportunity opp1 = TestFactoryOpportunity.makeClient(
			'CLIENT OPP 1',
			client1.Id,
			Date.today().addDays(30),
			'Proposal'
		);
		Opportunity opp2 = TestFactoryOpportunity.makeClient(
			'CLIENT OPP 2',
			client1.Id,
			Date.today().addDays(30),
			'Proposal'
		);
		insert new List<Opportunity>{ opp1, opp2 };

		List<Account> accounts = [
			SELECT Id, Name, Name_Branch__c
			FROM Account
			WHERE Name LIKE '!!!Test Client %'
			ORDER BY Name ASC
		];
		List<Opportunity> opps = [
			SELECT Id, Name, Name_Branch__c, AccountId
			FROM Opportunity
			WHERE Name LIKE 'CLIENT OPP %'
			ORDER BY Name ASC
		];

		Assert.areEqual(2, accounts.size());
		client1 = accounts.get(0);
		client2 = accounts.get(1);
		Assert.areEqual('TESTBRANCH ONE', client1.Name_Branch__c);
		Assert.areEqual(null, client2.Name_Branch__c);

		Assert.areEqual(2, opps.size());
		opp1 = opps.get(0);
		opp2 = opps.get(1);
		Assert.areEqual(client1.Id, opp1.AccountId);
		Assert.areEqual('TESTBRANCH ONE', opp1.Name_Branch__c);
		Assert.areEqual(client1.Id, opp2.AccountId);
		Assert.areEqual('TESTBRANCH ONE', opp2.Name_Branch__c);

		Test.startTest();

		opp2.AccountId = client2.Id;
		opp2.Amount = 3000;
		update opp2;

		opp2 = [SELECT Id, Name, Name_Branch__c, AccountId FROM Opportunity WHERE Name LIKE 'CLIENT OPP 2' LIMIT 1];
		Assert.areEqual(client2.Id, opp2.AccountId);
		Assert.areEqual(null, opp2.Name_Branch__c);

		client2.Prospect_Branch__c = branch2.Id;
		update client2;

		Test.stopTest();

		accounts = [SELECT Id, Name, Name_Branch__c FROM Account WHERE Name LIKE '!!!Test Client %' ORDER BY Name ASC];
		opps = [
			SELECT Id, Name, Name_Branch__c, AccountId
			FROM Opportunity
			WHERE Name LIKE 'CLIENT OPP %'
			ORDER BY Name ASC
		];

		Assert.areEqual(2, accounts.size());
		client1 = accounts.get(0);
		client2 = accounts.get(1);
		Assert.areEqual('TESTBRANCH ONE', client1.Name_Branch__c);
		Assert.areEqual('TESTBRANCH TWO', client2.Name_Branch__c);

		Assert.areEqual(2, opps.size());
		opp1 = opps.get(0);
		Assert.areEqual(client1.Id, opp1.AccountId);
		Assert.areEqual('TESTBRANCH ONE', opp1.Name_Branch__c);
		opp2 = opps.get(1);
		Assert.areEqual(client2.Id, opp2.AccountId);
		Assert.areEqual('TESTBRANCH TWO', opp2.Name_Branch__c);
	}

	@IsTest
	public static void test_onlyClientLikeAccounts() {
		Account branch = TestFactoryAccount.makeBranch('TEST BRANCH!!!');
		Account client1 = TestFactoryAccount.makeClient('TEST CLIENT 1 !!!', null, null);
		Account client2 = TestFactoryAccount.makeClient('TEST CLIENT 1 !!!', null, null);
		Account prospect1 = TestFactoryAccount.makeProspect('TEST PROSPECT 1 !!!', null, null);

		List<Account> accounts = new List<Account>{ branch, client1, client2, prospect1 };
		insert accounts;

		Test.startTest();

		Map<Id, Account> clients = Account_Services.onlyClientLikeAccounts( accounts );

		Test.stopTest();

		Assert.areEqual(3, clients.size(), 'There are 3 clients');
		Assert.isTrue(clients.containsKey(client1.Id));
		Assert.isTrue(clients.containsKey(client1.Id));
		Assert.isTrue(clients.containsKey(prospect1.Id));
	}
    
     @IsTest
	public static void test_onlyClientAccounts() {
		Account client1 = TestFactoryAccount.makeClient('TEST CLIENT 1 !!!', null, null);
		Account client2 = TestFactoryAccount.makeClient('TEST CLIENT 2 !!!', null, null);

		List<Account> accounts = new List<Account>{ client1, client2};
		insert accounts;

		Test.startTest();

		Map<Id, Account> clients = Account_Services.onlyClientAccounts( accounts );

		Test.stopTest();

		Assert.areEqual(2, clients.size(), 'There are 2 clients');
		Assert.isTrue(clients.containsKey(client1.Id));
	}
    
     

	/**
	 * @description method performs a test on .
	 */
	@IsTest
	public static void test_method() {
		Account branch = TestFactoryAccount.createBranch('TEST BRANCH');
		User user = TestFactoryUser.createUser('TEST', 'USER', 'BBSI Standard', branch.External_Id__c);
		Account prospect = TestFactoryAccount.createProspect('TEST PROSPECT', null, null);
		Opportunity opp = TestFactoryOpportunity.makeClient('TEST OPP', prospect.Id, Date.today(), Opportunity_Service.STAGE_DISCOVERY_MEETING);
		opp.Amount = 3.00;
		insert opp;
		
		Test.startTest();
		
		prospect.Sales_Development_Representative__c = user.Id;
		update prospect;
		
		Test.stopTest();

		opp = [SELECT Id, Sales_Development_Representative__c FROM Opportunity WHERE Id = :opp.Id];

		Assert.areEqual(User.Id, opp.Sales_Development_Representative__c);
	}
    @IsTest
	public static void test_getAccountOpportunities() {
        Account client1 = TestFactoryAccount.makeClient('TEST CLIENT 1 !!!', null, null);
		Account client2 = TestFactoryAccount.makeClient('TEST CLIENT 2 !!!', null, null);

		List<Account> accounts = new List<Account>{ client1, client2};
		insert accounts;
         RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType = 'Opportunity' LIMIT 1];

        // Create test data - Opportunities associated with the Accounts
        Opportunity opp1 = new Opportunity(Name = 'Test Opportunity 1',CloseDate=System.today(), StageName = 'Prospecting', AccountId = client1.Id, RecordTypeId = rt.Id);
        Opportunity opp2 = new Opportunity(Name = 'Test Opportunity 2',CloseDate=System.today(), StageName = 'Closed Won', AccountId = client2.Id, RecordTypeId = rt.Id);
        insert new List<Opportunity>{opp1, opp2};
         Set<Id> accountIds = new Set<Id>{client1.Id, client2.Id};
        Map<Id, Map<Id, List<Opportunity>>> result = Account_Services.getAccountOpportunities(accountIds);
		Assert.isNotNull(result, 'Should Not be Null');
    }

    @IsTest
	public static void test_getReferralPartnersByExternalID() {
        
		Set<String> externalIDs = new Set<String>{'ext1', 'ext2'};

        // Create test data - Accounts with matching External IDs
        Account acc1 = new Account(External_ID__c = 'ext1', Name = 'Test Account 1');
        Account acc2 = new Account(External_ID__c = 'ext2', Name = 'Test Account 2');
		Account rp1 = TestFactory.createAccountReferralPartner(
			'TEST REFERRAL PARTNER 1',
			null,
			'% of Margin',
			2.12,
			null,
			false
		);
        insert new List<Account>{acc1, acc2,rp1};

        // Create an Account with a non-matching External ID
        Account acc3 = new Account(External_ID__c = 'ext3', Name = 'Test Account 3', Referral_Partner_ID__c = rp1.External_ID__c);
        insert acc3;
        Referral_Partner_Group__c rpGroup = new Referral_Partner_Group__c(
            Name = 'Test Group Name',
            Group_Commission_Rate__c = 10.3,
            Group_Commission_Type__c = '% of Margin'
        );

        insert rpGroup;
		acc1.Referral_Partner_ID__c = rp1.External_ID__c;           
		update acc1;
        rp1.Referral_Partner_Group__c = rpGroup.Id;
        Account_Services.onReferralPartnerGroupChange(null, new Map<Id, Account>{rp1.Id => rp1});
        Account_Services.onReferralPartnerGroupChange(new Map<Id, Account>{rp1.Id => new Account(Id = rp1.Id)}, new Map<Id, Account>{rp1.Id => rp1});
        acc1.Status__c = 'Terminated';
        acc1.Referral_Partner_Status__c = 'Inactive';
        Account_Services.onAccountTermination(null, new Map<Id, Account>{acc1.Id => acc1});
		List<Account> acclist = [select id from account where Assigned_Referral_Partner__c =: rp1.Id];
		Assert.areEqual(acclist.Size(), 1, 'Should be 2 related Clients');
        // Call the method being tested
        //Map<String, Account> result = Account_Services.getReferralPartnersByExternalID(externalIDs);     
    }
	
    @IsTest
	public static void test_updateCampaignListNameOnOpportunity() {
		Account prospect = TestFactoryAccount.makeProspect('TEST PROSPECT ACCOUNT');
		prospect.Campaign_List_Name__c = 'OLD CAMPAIGN';
		insert prospect;

		Opportunity closedOpp = TestFactoryOpportunity.makeClient('~~~CLOSED OPP~~~', prospect.Id, Date.today().addDays(-100), 'Closed Won');
		closedOpp.Campaign_List_Name__c = 'OLD CAMPAIGN';
		closedOpp.Amount = 100000;
		insert closedOpp;

		Opportunity openOpp = TestFactoryOpportunity.makeClient('~~~OPEN OPP~~~', prospect.Id, Date.today().addDays(30), 'Pre-Discovery');
		openOpp.Campaign_List_Name__c = 'OLD CAMPAIGN';
		openOpp.Amount = 100000;
		insert openOpp;

		closedOpp = [SELECT Id, AccountId, IsClosed, StageName FROM Opportunity WHERE Id = :closedOpp.Id];

		openOpp = [SELECT Id, AccountId, IsClosed, StageName FROM Opportunity WHERE Id = :openOpp.Id];

		Test.startTest();

		prospect.Campaign_List_Name__c = 'NEW CAMPAIGN';
		update prospect;

		Test.stopTest();

		closedOpp = [SELECT Id, Campaign_List_Name__c FROM Opportunity WHERE Id = :closedOpp.Id];
		Assert.areEqual('OLD CAMPAIGN', closedOpp.Campaign_List_Name__c, 'Campaign should NOT have updated');

		openOpp = [SELECT Id, Campaign_List_Name__c FROM Opportunity WHERE Id = :openOpp.Id];
		Assert.areEqual('NEW CAMPAIGN', openOpp.Campaign_List_Name__c, 'Campaign should have updated');
	}
}