/**
 * @description LeadClientBdmShare_Test contains tests for the LeadClientBdmShare class.
 */
@IsTest
@SuppressWarnings('PMD.ApexAssertionsShouldIncludeMessage')
public without sharing class LeadClientBdmShare_Test {
	@TestSetup
	static void setup() {
		User u1 = TestFactoryUser.makeBDM('TEST', 'BDMUser1', 'Area Manager', '910');
		User u2 = TestFactoryUser.makeBDM('TEST', 'BDMUser2', 'Area Manager', '910');
		insert new List<User>{ u1, u2 };

		Account client = TestFactoryAccount.makeClient('BDMTest');
		Account prospect = TestFactoryAccount.makeProspect('TEST_PROSPECT');
		insert new List<Account>{ client, prospect };
	}

	@IsTest
	static void insertBDMClientAccount() {
		User u = [SELECT Id FROM User WHERE LastName = 'BDMUser1'];
		Account a = TestFactoryAccount.makeClient('BDMTestClient');
		a.Business_Development_Manager__c = u.Id;
		insert a;

		Assert.areEqual(
			1,
			[
				SELECT Id
				FROM AccountShare
				WHERE AccountId = :a.Id 
				AND UserOrGroupId = :u.Id 
				AND AccountAccessLevel = 'Read'
			]
			.size()
		);
	}

	@IsTest
	static void updateAccountOwner() {
		User u = [SELECT Id, ProfileId FROM User WHERE LastName = 'BDMUser1'];
		User u2 = [SELECT Id FROM User WHERE LastName = 'BDMUser2'];

		Account a;

		System.runAs(u) {
			a = TestFactoryAccount.makeProspect('BDMUpdateField');
			a.Business_Development_Manager__c = u2.Id;
			insert a;

			a.Business_Development_Manager__c = u2.Id;
			a.OwnerId = u.Id;
			update a;
		}

		Assert.areEqual(4, [SELECT Id FROM AccountShare WHERE accountId = :a.Id].size());
	}

	@IsTest
	static void updateBDMClientAccount() {
		User u1 = [SELECT Id FROM User WHERE LastName = 'BDMUser1'];
		User u2 = [SELECT Id FROM User WHERE LastName = 'BDMUser2'];
		Account a = [SELECT Id FROM Account WHERE Name = 'BDMTest'];

		Assert.areEqual(
			0,
			[
				SELECT Id
				FROM AccountShare
				WHERE AccountId = :a.Id 
				AND UserOrGroupId = :u1.Id 
				AND AccountAccessLevel = 'Read'
			]
			.size()
		);

		a.Business_Development_Manager__c = u1.Id;

		update a;

		Assert.areEqual(
			1,
			[
				SELECT Id
				FROM AccountShare
				WHERE AccountId = :a.Id 
				AND UserOrGroupId = :u1.Id 
				AND AccountAccessLevel = 'Read'
			]
			.size()
		);

		a.Business_Development_Manager__c = u2.Id;

		update a;

		Assert.areEqual(
			1,
			[
				SELECT Id
				FROM AccountShare
				WHERE AccountId = :a.Id 
				AND UserOrGroupId = :u2.Id 
				AND AccountAccessLevel = 'Read'
			]
			.size()
		);
		Assert.areEqual(
			0,
			[
				SELECT Id
				FROM AccountShare
				WHERE AccountId = :a.Id 
				AND UserOrGroupId = :u1.Id 
				AND AccountAccessLevel = 'Read'
			]
			.size()
		);

		a.Business_Development_Manager__c = null;

		update a;

		Assert.areEqual(
			0,
			[
				SELECT Id
				FROM AccountShare
				WHERE AccountId = :a.Id 
				AND UserOrGroupId = :u2.Id 
				AND AccountAccessLevel = 'Read'
			]
			.size()
		);
		Assert.areEqual(
			0,
			[
				SELECT Id
				FROM AccountShare
				WHERE AccountId = :a.Id 
				AND UserOrGroupId = :u1.Id 
				AND AccountAccessLevel = 'Read'
			]
			.size()
		);
	}

	@IsTest
	static void insertBDMProspectAccount() {
		User u = [SELECT Id FROM User WHERE LastName = 'BDMUser1'];
		Account a = TestFactoryAccount.makeProspect('BDMTestProspect');
		a.Business_Development_Manager__c = u.Id;
		insert a;

		Assert.areEqual(
			1,
			[
				SELECT Id
				FROM AccountShare
				WHERE AccountId = :a.Id 
				AND UserOrGroupId = :u.Id 
				AND AccountAccessLevel = 'Edit'
			]
			.size()
		);
	}

	@IsTest
	static void updateBDMProspectAccount() {
		User u1 = [SELECT Id FROM User WHERE LastName = 'BDMUser1'];
		User u2 = [SELECT Id FROM User WHERE LastName = 'BDMUser2'];
		Account a = [SELECT Id FROM Account WHERE Name = 'TEST_PROSPECT'];

		Assert.areEqual(
			0,
			[
				SELECT Id
				FROM AccountShare
				WHERE AccountId = :a.Id 
				AND UserOrGroupId = :u1.Id 
				AND AccountAccessLevel = 'Edit'
			]
			.size()
		);

		a.Business_Development_Manager__c = u1.Id;

		update a;

		Assert.areEqual(
			1,
			[
				SELECT Id
				FROM AccountShare
				WHERE AccountId = :a.Id 
				AND UserOrGroupId = :u1.Id 
				AND AccountAccessLevel = 'Edit'
			]
			.size()
		);

		a.Business_Development_Manager__c = u2.Id;

		update a;

		Assert.areEqual(
			1,
			[
				SELECT Id
				FROM AccountShare
				WHERE AccountId = :a.Id 
				AND UserOrGroupId = :u2.Id 
				AND AccountAccessLevel = 'Edit'
			]
			.size()
		);
		Assert.areEqual(
			0,
			[
				SELECT Id
				FROM AccountShare
				WHERE AccountId = :a.Id 
				AND UserOrGroupId = :u1.Id 
				AND AccountAccessLevel = 'Edit'
			]
			.size()
		);

		a.Business_Development_Manager__c = null;

		update a;

		Assert.areEqual(
			0,
			[
				SELECT Id
				FROM AccountShare
				WHERE AccountId = :a.Id 
				AND UserOrGroupId = :u2.Id 
				AND AccountAccessLevel = 'Edit'
			]
			.size()
		);
		Assert.areEqual(
			0,
			[
				SELECT Id
				FROM AccountShare
				WHERE AccountId = :a.Id 
				AND UserOrGroupId = :u1.Id 
				AND AccountAccessLevel = 'Edit'
			]
			.size()
		);
	}

	@IsTest
	static void convertLeadBDM() {
		User u1 = [SELECT Id FROM User WHERE LastName = 'BDMUser1'];
		User u2 = [SELECT Id FROM User WHERE LastName = 'BDMUser2'];

		Lead lead;

		System.runAs(u2) {
			Account branch = TestFactoryAccount.createBranch('TEST_BRANCH');
			Account rp = TestFactoryAccount.createReferralPartner(
				'TEST_REFERRAL_PARTNER', 
				'% of Margin',
				12.00,
				null
			);

			Contact producer = TestFactoryContact.createProducer('TEST', 'Contact', rp.Id);

			lead = TestFactoryLead.makeClientLead('John', 'Doe', 'Test', branch.Id, u1.Id);
			lead .OwnerId = u2.Id;
			lead.Status = 'Qualified';
			lead.Lead_Stage__c = 'Nurture';
			lead.Duplicate_Check_Status__c = true;
			lead.Referral_Partner__c = rp.Id;
			lead.Producer__c = producer.Id;
			lead.Estimated_Annual_Billing__c = 500000;

			insert lead;
		}

		Test.startTest();

		Database.LeadConvertResult lcr = LeadConvert.convert(lead.Id, false);
		Assert.isTrue(lcr.isSuccess(), 'Lead conversion failed');

		Test.stopTest();
	}

	// NEW TESTS:
	//    Exisiting Lead changes BDM  - Add & REMOVE
	//    Previous Lead BDM is not OWner - REMOVE
	//    BDM inactive?
}