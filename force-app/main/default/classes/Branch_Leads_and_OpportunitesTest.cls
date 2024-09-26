@IsTest
private class Branch_Leads_and_OpportunitesTest {
	/*
		To do: 
		1. Create 3 Branches
		2. Create 2 users, one per branch
		3. Create 2 leads one for each of 2 branches
		4. Create 2 Prospects on for each of the same 2 branches - set created dates back a couple of days
		5. Create 2 Prospects one of each of the same 2 branches - set created date back 8 days
		6. Create 2 Client records one of each of the same 2 branches - set start_date__c a couple days back
		7. Create 2 Client records one of each of the same 2 branches - set start_date__c 8 days ago
		8. Run tests
	*/

	@TestSetup 
	static void setup() {
		Account branch1 = TestFactoryAccount.makeBranch('Branch 1', '1', null, null);
		Account branch2 = TestFactoryAccount.makeBranch('Branch 2', '2', null, null);
		Account branch3 = TestFactoryAccount.makeBranch('Branch 3', '3', null, null);

		Account referral1 = TestFactoryAccount.makeReferralPartner('Referral1 ', '% of Margin', 10, null);
		referral1.Referral_Partner_Status__c = 'Active';

		insert new List<Account>{ branch1, branch2, branch3, referral1 };

		List<User> bdmUsers = new List<User>();
		User userBranch1 = TestFactoryUser.makeUser('TEST', 'BDMUser1','Area Manager', '1', 'TestBBSI1@bbsihq.com', 'TestBBSI1@bbsihq.com');
		userBranch1.title = 'Business Development Manager';
		
		User userBranch2 = TestFactoryUser.makeUser('TEST', 'BDMUser2','Area Manager', '1', 'TestBBSI2@bbsihq.com', 'TestBBSI2@bbsihq.com');
		userBranch2.title = 'Business Development Manager';

		insert new List<User>{ userBranch1, userBranch2 };

		Contact ReferralContact1 = TestFactoryContact.makeContact('Dave', 'Smith','Producer',Referral1.Id,'TestBBSI2@bbsihq.com');
		Lead branch1Lead = TestFactoryLead.makeClientLead('TEST', 'BR 1 Lead', 'BR 1 Lead', branch1.Id, userBranch1.Id);
		branch1Lead.Referral_Partner__c = Referral1.Id;
		branch1Lead.Producer__c = ReferralContact1.Id;
		branch1Lead.OwnerId = userBranch1.Id;

		Lead branch1RPLead = TestFactoryLead.makeLeadRP('TEST', 'BR 1 Lead', 'BR 1 Lead');
		branch1Lead.OwnerId = userBranch1.Id;

		Lead branch1Lead2 = TestFactoryLead.makeClientLead('TEST', 'BR 2 Lead', 'BR 2 Lead', branch1.Id, userBranch1.Id);
		branch1Lead2.Referral_Partner__c = Referral1.Id;
		branch1Lead2.Producer__c = ReferralContact1.Id;
		branch1Lead2.OwnerId = userBranch1.Id;

		Lead branch2Lead = TestFactoryLead.makeClientLead('TEST', 'BR 1 Lead', 'BR 1 Lead', branch2.Id, userBranch1.Id);
		branch2Lead.Referral_Partner__c = Referral1.Id;
		branch2Lead.Producer__c = ReferralContact1.Id;
		branch2Lead.OwnerId = userBranch2.Id;

		Lead branch2Lead2 = TestFactoryLead.makeClientLead('TEST', 'BR 2 Lead', 'BR 2 Lead', branch2.Id, userBranch1.Id);
		branch2Lead2.Referral_Partner__c = Referral1.Id;
		branch2Lead2.Producer__c = ReferralContact1.Id;
		branch2Lead2.OwnerId = userBranch2.Id;

		insert new List<Lead> { branch1Lead, branch1Lead2, branch2Lead, branch2Lead2, branch1RPLead };
		
		Account branc1Prospect = TestFactoryAccount.makeProspect('Prospect 1');
		branc1Prospect.Prospect_Branch__c = branch1.Id;
		branc1Prospect.OwnerId = userBranch1.Id;

		Account branc1Client = TestFactoryAccount.makeClient('Client 1');
		branc1Client.Prospect_Branch__c = branch1.Id;
		branc1Client.Start_Date__c = System.Today().addDays(-3);
		branc1Client.OwnerId = userBranch1.Id;
		
		Account branc2Prospect = TestFactoryAccount.makeProspect('Prospect 1');
		branc2Prospect.Prospect_Branch__c = branch2.Id;
		branc2Prospect.OwnerId = userBranch2.Id;

		Account branc2Client = TestFactoryAccount.makeClient('Client 1');
		branc2Client.Prospect_Branch__c = branch2.Id;
		branc2Client.OwnerId = userBranch2.Id;
		branc2Client.Start_Date__c = System.Today().addDays(-2);

		List<Account> accounts = new List<Account>();
		insert new List<Account>{ branc1Prospect, branc1Client, branc2Prospect, branc2Client };
	}

	@IsTest 
	static void testGraph() {
		Test.startTest();

		User usr1 = [SELECT Id FROM User WHERE LastName = 'BDMUser1' LIMIT 1];

		System.runAs(usr1) {
			PageReference graph = Page.Branch_Leads_And_Opportunities;
			Test.setCurrentPage(graph);
			BranchLeadsAndOpportunities controller = new BranchLeadsAndOpportunities();
			List<Object> Clients;
			List<Object> Leads;
			List<Object> Prospects;
			
			Clients = (List<Object>) JSON.deserializeUntyped(controller.ClientData);
			Leads = (List<Object>) JSON.deserializeUntyped(controller.LeadData);
			Prospects = (List<Object>) JSON.deserializeUntyped(controller.ProspectData);
			
			Assert.areEqual(3,Clients.size());
			Assert.areEqual(3,Leads.size());
			Assert.areEqual(3,Prospects.size());
			
			controller.daysToProcessString = 'CUSTOM';
			Datetime now = Datetime.now(); 
			controller.hiddenStart = now.format('yyyy-MM-dd');

			now = now+1;
			controller.hiddenEnd = now.format('yyyy/MM/dd');

			controller.loadData();

			controller.getDaysToProcess();
			controller.daysToProcessString = 'C';

			controller.loadData();   

			Assert.areEqual(3,Clients.size());
			Assert.areEqual(3,Leads.size());
			Assert.areEqual(3,Prospects.size());
		}

		Test.stopTest();
	}    
}