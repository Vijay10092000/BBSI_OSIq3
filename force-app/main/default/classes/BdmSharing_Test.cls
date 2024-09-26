/**
 * @description BdmSharing_Test contains tests for the BdmSharing class.
 */
@IsTest
@SuppressWarnings('PMD.ApexAssertionsShouldIncludeMessage')
private class BdmSharing_Test {
	private static User user1;
	private static User user2;
	private static User user3;
	private static User userConfig;
	private static Account branch1;
	private static Account branch2;
	private static Account client;
	private static Account prospect;

	@TestSetup
	static void setup() {
		branch1 = TestFactoryAccount.makeBranch('TEST_BRANCH_1');
		branch2 = TestFactoryAccount.makeBranch('TEST_BRANCH_2');
		client = TestFactoryAccount.makeClient('TEST_CLIENT', null, null);
		prospect = TestFactoryAccount.makeProspect('TEST_PROSPECT', null, null);
		insert new List<Account>{ branch1, branch2, client, prospect };  

        user1 = TestFactoryUser.makeBDM('!~!TEST', 'BDM_USER_1', 'Area Manager', branch1.External_Id__c);
        user2 = TestFactoryUser.makeBDM('!~!TEST', 'BDM_USER_2', 'Area Manager', branch1.External_Id__c);
        user3 = TestFactoryUser.makeBDM('!~!TEST', 'BDM_USER_3', 'Area Manager', branch1.External_Id__c);
        userConfig = TestFactoryUser.makeUser('!~!TEST', 'CONFIG_ADMIN', 'Configuration Admin', branch2.External_Id__c);
		insert new List<User>{ user1, user2, user3, userConfig };
	}

	private static void loadData() {
		List<User> users = [SELECT Id, Name FROM User WHERE FirstName = '!~!TEST' ORDER BY LastName ASC];
		user1 = users.get(0);
		user2 = users.get(1);
		user3 = users.get(2);
		userConfig = users.get(3);

		List<Account> accounts = [SELECT Id, Name FROM Account WHERE Name LIKE 'TEST_%' ORDER BY Name ASC];
		branch1 = accounts.get(0);
		branch2 = accounts.get(1);
		client = accounts.get(2);
		prospect = accounts.get(3);
	}
	
	@IsTest
	static void leadBDMs() {
		loadData();

		Lead lead1 = TestFactoryLead.makeClientLead('TEST', 'LEAD_1', 'TEST_COMPANY_ONE', branch1.Id, null);
		Lead lead2 = TestFactoryLead.makeClientLead('TEST', 'LEAD_2', 'TEST_COMPANY_TWO', branch1.Id, null);

		lead1.OwnerId = user1.Id;
		lead1.Business_Development_Manager__c = user1.Id;

		lead2.OwnerId = user1.Id;
		lead2.Business_Development_Manager__c = user2.Id;
		List<Lead> leads = new List<Lead>{ lead1, lead2 };

		insert leads;

		Assert.areEqual(0, countLeadShares(lead1.Id, user1.Id), 'User1 is owner and BDM');
		Assert.areEqual(0, countLeadShares(lead1.Id, user2.Id), 'User2 has no relationship');
		Assert.areEqual(0, countLeadShares(lead2.Id, user1.Id), 'User1 is owner');
		Assert.areEqual(1, countLeadShares(lead2.Id, user2.Id), 'User2 is BDM');

		lead1.Business_Development_Manager__c = user2.Id;
		lead2.Business_Development_Manager__c = user1.Id;
		update leads;

		Assert.areEqual(0, countLeadShares(lead1.Id, user1.Id), 'User1 is owner');
		Assert.areEqual(1, countLeadShares(lead1.Id, user2.Id), 'User2 is BDM');
		Assert.areEqual(0, countLeadShares(lead2.Id, user1.Id), 'User1 is owner and BDM');
		Assert.areEqual(0, countLeadShares(lead2.Id, user2.Id), 'User2 has no relationship');

		lead1.OwnerId = user2.Id;
		lead2.OwnerId = user3.Id;
		update leads;
		
		Assert.areEqual(0, countLeadShares(lead1.Id, user1.Id), 'User1 has no relationship');
		Assert.areEqual(0, countLeadShares(lead1.Id, user2.Id), 'User2 is Owner and BDM');
		Assert.areEqual(0, countLeadShares(lead1.Id, user3.Id), 'User3 has no relationship');
		Assert.areEqual(1, countLeadShares(lead2.Id, user1.Id), 'User1 is BDM');
		Assert.areEqual(0, countLeadShares(lead2.Id, user2.Id), 'User2 has no relationship');
		Assert.areEqual(0, countLeadShares(lead1.Id, user3.Id), 'User3 is owner');
	}
	
	@IsTest
	static void leadConfigManager() {
		loadData();

		Lead lead1 = TestFactoryLead.makeClientLead('TEST', 'LEAD_1', 'TEST_COMPANY_ONE', branch1.Id, null);
		Lead lead2 = TestFactoryLead.makeClientLead('TEST', 'LEAD_2', 'TEST_COMPANY_TWO', branch1.Id, null);

		lead1.OwnerId = user1.Id;
		lead1.Business_Development_Manager__c = user1.Id;

		lead2.OwnerId = user2.Id;
		lead2.Business_Development_Manager__c = user2.Id;
		List<Lead> leads = new List<Lead>{ lead1, lead2 };

		insert leads;

		Test.startTest();

		System.runAs(userConfig) {
			lead1.Business_Development_Manager__c = user3.Id;
			lead2.Business_Development_Manager__c = user3.Id;
			update leads;
		}

		Test.stopTest();

		Assert.areEqual(0, countLeadShares(lead1.Id, user1.Id), 'User1 has no relationship');
		Assert.areEqual(0, countLeadShares(lead1.Id, user2.Id), 'User2 is Owner and BDM');
		Assert.areEqual(1, countLeadShares(lead1.Id, user3.Id), 'User3 has no relationship');
		Assert.areEqual(0, countLeadShares(lead2.Id, user1.Id), 'User1 is BDM');
		Assert.areEqual(0, countLeadShares(lead2.Id, user2.Id), 'User2 has no relationship');
		Assert.areEqual(1, countLeadShares(lead1.Id, user3.Id), 'User3 is owner');
	}

	@IsTest
	static void convertLeadBDM() {  // TODO: FAILS!
		loadData();

		Lead lead;

		System.runAs(user1) {
			lead = TestFactoryLead.makeClientLead('Doe', 'John', 'TEST', null, null);
			lead.Status = 'Qualified';
			lead.Lead_Stage__c = 'Nurture';
			lead.Business_Development_Manager__c = user2.Id;
			lead.Duplicate_Check_Status__c = true;
			insert lead;
		}

		Test.startTest();

		Database.LeadConvertResult lcr = LeadConvert.convert(lead.Id, false);
		Assert.isTrue(lcr.isSuccess(), 'Lead conversion failed');

		Test.stopTest();

		lead = [SELECT Id, ConvertedAccountId FROM Lead WHERE Id = :lead.Id];

		Account newProspect = [SELECT Id, Name FROM Account WHERE Id = :lead.ConvertedAccountId];

		Assert.areEqual(0, countAccountShares(newProspect.Id, user1.Id, 'Edit'));
		Assert.areEqual(1, countAccountShares(newProspect.Id, user2.Id, 'Edit'));
	}

	@IsTest
	static void insertBDMClientAccount() {
		loadData();
       
        Account clientTest = TestFactoryAccount.makeClient('CLIENT_TEST_2', null, null);

		clientTest.Business_Development_Manager__c = user1.Id;

		insert clientTest;
		
		Assert.areEqual(1, countAccountShares(clientTest.Id, user1.Id, 'Read'));
	}

	@IsTest
	static void updateAccountOwner() {
		loadData();
		
		Account prospectTest;

		System.runAs(user1) {
            prospectTest = TestFactoryAccount.makeProspect('PROSPECT_TEST_2', null, null);
			prospectTest.Business_Development_Manager__c = user2.Id;
			insert prospectTest;

			prospectTest.Business_Development_Manager__c = user2.Id;
			prospectTest.OwnerId = user1.Id;

			update prospectTest;
		}

		Assert.areEqual(4, [SELECT Id FROM AccountShare WHERE AccountId = :prospectTest.Id].size());
	}

	@IsTest
	static void updateBDMClientAccount() {
		loadData();

		Assert.areEqual(0, countAccountShares(client.Id, user1.Id, 'Read'));

		client.Business_Development_Manager__c = user1.Id;

		update client;

		Assert.areEqual(1, countAccountShares(client.Id, user1.Id, 'Read'));

		client.Business_Development_Manager__c = user2.Id;

		update client;

		client.OwnerId = user1.Id;
		update client;

		Assert.areEqual(0, countAccountShares(client.Id, user1.Id, 'Read'));
		Assert.areEqual(1, countAccountShares(client.Id, user2.Id, 'Read'));

		client.Business_Development_Manager__c = null;
		update client;
		
		Assert.areEqual(0, countAccountShares(client.Id, user1.Id, 'Read'));
		Assert.areEqual(0, countAccountShares(client.Id, user2.Id, 'Read'));
	}

	@IsTest
	static void insertBDMProspectAccount() {
		loadData();

		Account prospectTest = TestFactoryAccount.makeProspect('PROSPECT_TEST_2', null, null);
		prospectTest.Business_Development_Manager__c = user1.Id;

		insert prospectTest;

		Assert.areEqual(1, countAccountShares(prospectTest.Id, user1.Id, 'Edit'));
	}

	@IsTest
	static void updateBDMProspectAccount() {
		loadData();

		Assert.areEqual(0, countAccountShares(prospect.Id, user1.Id, 'Edit'));

		prospect.Business_Development_Manager__c = user1.Id;

		update prospect;

		Assert.areEqual(1, countAccountShares(prospect.Id, user1.Id, 'Edit'));

		prospect.Business_Development_Manager__c = user2.Id;

		update prospect;
		
		Assert.areEqual(0, countAccountShares(prospect.Id, user1.Id, 'Edit'));
		Assert.areEqual(1, countAccountShares(prospect.Id, user2.Id, 'Edit'));

		prospect.Business_Development_Manager__c = null;

		update prospect;
		
		Assert.areEqual(0, countAccountShares(prospect.Id, user1.Id, 'Edit'));
		Assert.areEqual(0, countAccountShares(prospect.Id, user2.Id, 'Edit'));
	}
	
	@IsTest
	static void accountConfigManager() {
		loadData();

		prospect.OwnerId = user2.Id;
		prospect.Business_Development_Manager__c = user2.Id;

		client.OwnerId = user1.Id;
		client.Business_Development_Manager__c = user1.Id;

		update new List<Account>{ prospect, client };

		Assert.areEqual(0, countAccountShares(prospect.Id, user1.Id, 'Edit'), 'User1 is Owner');
		Assert.areEqual(0, countAccountShares(prospect.Id, user2.Id, 'Edit'), 'User2 has no relationship');
		Assert.areEqual(0, countAccountShares(prospect.Id, user3.Id, 'Edit'), 'User3 has no relationship');
		Assert.areEqual(0, countAccountShares(client.Id, user1.Id, 'Read'), 'User1 has no relationship');
		Assert.areEqual(0, countAccountShares(client.Id, user2.Id, 'Read'), 'User2 is Owner');
		Assert.areEqual(0, countAccountShares(client.Id, user3.Id, 'Read'), 'User3 has no relationship');

		Test.startTest();

		System.runAs(userConfig) {
			prospect.Business_Development_Manager__c = user3.Id;
			client.Business_Development_Manager__c = user3.Id;
			update new List<Account>{ prospect, client };
		}

		Test.stopTest();

		Assert.areEqual(0, countAccountShares(prospect.Id, user1.Id, 'Edit'), 'User1 is Owner');
		Assert.areEqual(0, countAccountShares(prospect.Id, user2.Id, 'Edit'), 'User2 has no relationship');
		Assert.areEqual(1, countAccountShares(prospect.Id, user3.Id, 'Edit'), 'User3 is BDM');
		Assert.areEqual(0, countAccountShares(client.Id, user1.Id, 'Read'), 'User1 has no relationship');
		Assert.areEqual(0, countAccountShares(client.Id, user2.Id, 'Read'), 'User2 is Owner');
		Assert.areEqual(1, countAccountShares(client.Id, user3.Id, 'Read'), 'User3 is BDM');
	}

	private static Integer countLeadShares(Id idLead, Id idUser) {
		return [
			SELECT Id
			FROM LeadShare
			WHERE LeadId = :idLead AND UserOrGroupId = :idUser AND RowCause = 'Manual'
		]
		.size();
	}

	private static Integer countAccountShares(Id idAccount, Id idUser, String type) {
		return [
			SELECT Id
			FROM AccountShare
			WHERE AccountId = :idAccount AND UserOrGroupId = :idUser AND AccountAccessLevel = :type AND RowCause = 'Manual'
		]
		.size();
	}
}