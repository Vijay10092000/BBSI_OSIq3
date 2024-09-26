@IsTest
@SuppressWarnings('PMD.ApexAssertionsShouldIncludeMessage')
private class DupeCatcherTest {
	@SuppressWarnings('PMD.AvoidSystemDebugUsage')
	private static void dumpMatches(List<possibleMatches> matches) {
		String log = 'MATCHES:';
		for (possibleMatches match : matches) {
			log += '\n------------' +
			'\nName: ' + match.Name +
			'\nCompany: ' + match.Company +
			'\nDBAName: ' + match.DBAName +
			'\nFEIN: ' + match.FEIN;
		}
		System.debug(LoggingLevel.DEBUG, log);
	}

	@IsTest
	static void clientLeadWithDupes() {
		User bdm = TestFactoryUser.createBDM(null, 'TestBDM', 'BBSI Standard', '910');

		System.runAs(bdm) {
			List<Account> newAccounts = new List<Account>();
			Account branch = TestFactoryAccount.makeBranch('TestBranch');
			branch.External_ID__c = '910';
			branch.FEIN__c = '99-9999999';
			newAccounts.add(branch);
			Account rp = TestFactoryAccount.makeAccount('Test Referral Partner', 'Referral Partner');
			rp.Referral_Partner_Status__c = 'Active';
			rp.FEIN__c = '99-9999999';
			rp.Status__c = null;
			newAccounts.add(rp);
			insert newAccounts;
			Lead l1 = TestFactoryLead.makeClientLead(null,'Test', 'Test Company', branch.id, BDM.id);
            Lead l2 = TestFactoryLead.makeClientLead(null,'Test Company', 'Test Company2', branch.id, BDM.id);
			l1.Status = 'Assigned';
			l2.Status = 'Assigned';

			Contact c1 = TestFactoryContact.createClient(null, 'Test1', rp.id);
			Contact c2 = TestFactoryContact.createClient(null, 'Test1', rp.id);
			l1.Referral_Partner__c = rp.id;
			l1.Producer__c = c1.id;
			l2.Referral_Partner__c = rp.id;
			l2.Producer__c = c2.id;
			list<lead> leads = new List<Lead>();
			leads.add(l1);
			leads.add(l2);
			insert leads;

			l1.FEIN__c = '99-9999999';
			update l1;

			l2.FEIN__c = '99-9999999';
			update l2;

			List<Id> fixedSearchResults = new List<Id>();
			fixedSearchResults.add(branch.Id);
			fixedSearchResults.add(rp.Id);
			fixedSearchResults.add(l2.Id);
			Test.setFixedSearchResults(fixedSearchResults);

			PageReference pageRef = Page.DupeCatcherPage;
			test.setCurrentPage(pageRef);
			pageRef.getParameters().put('id', l1.Id);
			pageRef.getParameters().put('Type', 'New');
			DupeCatcherController controller = new DupeCatcherController();
			Assert.areEqual(l1.Id, controller.dupeLead.Id);
			Assert.areEqual(2, controller.allMatches.size());
			controller.saveMatches(controller.dupeLead, controller.allMatches);

			pageRef = Page.DupeCatcherPage;
			test.setCurrentPage(pageRef);
			pageRef.getParameters().put('id', [SELECT ID FROM Lead_Duplicate_Log__c WHERE Lead__c = :l1.ID].ID);
			pageRef.getParameters().put('Type', 'Archive');
			controller = new DupeCatcherController();
			if (controller.allMatches != null) {
				Assert.areEqual(3, controller.allMatches.size());
			}
		}
	}

	@IsTest
	static void clientLeadWithDupesLightning() {		
		User bdm = TestFactoryUser.createBDM(null, 'TestBDM', 'BBSI Standard', '910');

		System.runAs(bdm) {
			List<Account> newAccounts = new List<Account>();
			Account branch = TestFactoryAccount.makeBranch('TestBranch');
			branch.External_ID__c = '910';
			branch.FEIN__c = '99-9999999';
			newAccounts.add(branch);
            Account rp = TestFactoryAccount.makeAccount('Test Referral Partner', 'Client');
			rp.Referral_Partner_Status__c = 'Active';
			rp.FEIN__c = '99-9999999';
			rp.Status__c = null;
			newAccounts.add(rp);
			insert newAccounts;
			Lead l1 = TestFactoryLead.makeClientLead(null,'Test', 'Test Company', branch.id, BDM.id);
            Lead l2 = TestFactoryLead.makeClientLead(null,'Test Company', 'Test Company2', branch.id, BDM.id);
			l1.Status = 'Assigned';
			l2.Status = 'Assigned';

			Contact c1 = TestFactoryContact.createClient(null, 'Test1', rp.id);
			Contact c2 = TestFactoryContact.createClient(null, 'Test1', rp.id);
			l1.Referral_Partner__c = rp.id;
			l1.Producer__c = c1.id;
			l2.Referral_Partner__c = rp.id;
			l2.Producer__c = c2.id;
			list<lead> leads = new List<Lead>();
			leads.add(l1);
			leads.add(l2);
			insert leads;

			l1.FEIN__c = '99-9999999';
			update l1;

			l2.FEIN__c = '99-9999999';
			update l2;

			List<Id> fixedSearchResults = new List<Id>();
			fixedSearchResults.add(branch.Id);
			fixedSearchResults.add(rp.Id);
			fixedSearchResults.add(l2.Id);
			Test.setFixedSearchResults(fixedSearchResults);

			PageReference pageRef = Page.DupeCatcherPage;
			test.setCurrentPage(pageRef);
			Id leadId = l1.Id;
			List<dupecatcherlightningWrapper> matches = DupeCatcherController.getDupesLightning(leadId, false);
			Assert.areEqual(2, matches[0].allMatches.size());
		}
	}

	@IsTest
	static void testClientsWithDifferentDegressOfChange() {
		User bdm = TestFactoryUser.createBDM(null, 'TestBDM', 'BBSI Standard', '910');

		System.runAs(bdm) {
			Account branch = TestFactoryAccount.makeBranch('TestBranch');
			branch.External_ID__c = '910';
			branch.FEIN__c = '99-9999999';
            Account rp = TestFactoryAccount.makeReferralPartner('RP Test',  '% of Margin', 12.0, null);
			Account client = TestFactoryAccount.makeAccount('Test 123', 'Client');
			client.Referral_Partner_Status__c = 'Active';
			client.FEIN__c = '99-9999999';
			client.Status__c = null;
            client.DBA_Name__c = 'Test';
            Account clientClose = TestFactoryAccount.makeAccount('Test Inc', 'Client');
			Account clientNo = TestFactoryAccount.makeAccount('clientNo', 'Client');
			insert new List<Account>{ branch, rp, client, clientClose, clientNo };

            Lead l1 = TestFactoryLead.makeClientLead(null,'Test', 'Test Incorporated', branch.id, BDM.id);
			l1.Referral_Partner__c = rp.id;
			l1.Producer__c = TestFactory.CreateContact(rp, 'Producer', 'Producer', true).id;
			l1.DBA_Name__c = 'Test Inc';
			insert l1;

			List<Id> fixedSearchResults = new List<Id>();
			fixedSearchResults.add(rp.Id);
			fixedSearchResults.add(client.Id);
			fixedSearchResults.add(clientClose.Id);
			Test.setFixedSearchResults(fixedSearchResults);

			PageReference pageRef = Page.lightning_DupeChecker;
			test.setCurrentPage(pageRef);
			pageRef.getParameters().put('id', l1.Id);
			pageRef.getParameters().put('Type', 'New');
			DupeCatcherController controller = new DupeCatcherController();
			Assert.areEqual(l1.Id, controller.DupeLead.Id);

			dumpMatches(controller.allMatches.values());
			Assert.areEqual(3, controller.allMatches.size());
		}
	}

	@IsTest
	static void testNoMatches() {
        Account branch = TestFactoryAccount.makeBranch('TestBranch');
			branch.External_ID__c = '910';
			branch.FEIN__c = '99-9999999';
        insert branch;
		
        User bdm = TestFactoryUser.createBDM(null, 'TestBDM', 'BBSI Standard', '910');
		bdm.Title = 'Business Development Manager';
		update bdm;
        
		Account rp = TestFactoryAccount.makeReferralPartner('RP Test',  '% of Margin', 12.0, null);
		Lead l = TestFactoryLead.makeClientLead(null,'Test', 'TestCompany', branch.id, bdm.id);
        l.FEIN__c = null;
		l.Referral_Partner__c = rp.id;
		//l.Producer__c = TestFactory.CreateContact(rp, 'Producer', 'Producer', true).id;
        l.Producer__c = TestFactoryContact.createContact('testcontact','Producer','Producer',rp.id).id;
		insert l;

		PageReference pageRef = Page.DupeCatcherPage;
		test.setCurrentPage(pageRef);
		pageRef.getParameters().put('id', l.ID);
		pageRef.getParameters().put('Type', 'New');
		DupeCatcherController controller = new DupeCatcherController();
	}

	@IsTest
	public static void test_LeadAndAccount() {
		String testCompanyName = 'TEST Insurance ABC Company';

        Account branch = TestFactoryAccount.makeBranch('TestBranch');
			branch.External_ID__c = '1000';
			branch.FEIN__c = '99-9999999';
        Account client = TestFactoryAccount.makeClient(testCompanyName,null,null);
		insert new List<Account>{ branch, client };

        User bdm = TestFactoryUser.makeBDM('','TestBDM', 'BBSI Standard', '910');

        Lead testLead = TestFactoryLead.makeClientLead(null,'Test', testCompanyName, branch.id, bdm.id);
		testLead.FirstName = 'DUP';
		insert testLead;
		Test.startTest();

		client = [SELECT Id, Name FROM Account WHERE Id = :client.Id];
		Assert.areEqual(testCompanyName, client.Name);
		testLead = [SELECT Id, Name, Company, DBA_Name__c, FEIN__c FROM Lead WHERE Id = :testLead.Id LIMIT 1];
		Assert.areEqual(testCompanyName, testLead.Company);
		Map<Id, possibleMatches> mapMatches = (new DupeCatcher()).populateMatches(testLead); // CONFIRM WORKS
		Test.stopTest();

		Assert.areEqual(1, mapMatches.size(), 'Should have been found a match');
	}



	@IsTest
	public static void test_getLevenshteinValue() {
		DupeCatcher catcher = new DupeCatcher();

		Assert.areEqual(0, catcher.getLevenshteinValue('abC', 'Abc'));
		Assert.areEqual(1, catcher.getLevenshteinValue('ab C', 'Abc'));
		Assert.areEqual(4, catcher.getLevenshteinValue('ab Cd', 'Abcefg'));
		Assert.areEqual(-1, catcher.getLevenshteinValue(null, 'Abcefg'));
		Assert.areEqual(-1, catcher.getLevenshteinValue('Abcefg', null));
	}
}