/**
 * @description Lead_InsertUpdateTrigger_Test
 */
@IsTest
@SuppressWarnings('PMD.ApexAssertionsShouldIncludeMessage')
public class Lead_InsertUpdateTrigger_Test {
	static Account branchA;
	static Account branchB;
	static Account referralPartner1;
	static Account referralPartner2;

	static User areaManager;
	static User bdm;

	static Contact producer1;
	static Contact producer2;

	@TestSetup
	static void makeData() {
		branchA = TestFactoryAccount.makeBranch('TEST_BRANCH_A');
		branchB = TestFactoryAccount.makeBranch('TEST_BRANCH_B');
		referralPartner1 = TestFactoryAccount.makeReferralPartner('TEST_REFERRAL_PARTNER_1');
		referralPartner1.Zone__c = '1';
        referralPartner2 = TestFactoryAccount.makeReferralPartner('TEST_REFERRAL_PARTNER_2');
		referralPartner1.Region__c = 'SoCal';
		referralPartner2.Region__c = 'SoCal';
		referralPartner2.Zone__c = '1';		
		insert new List<Account>{ branchA, branchB, referralPartner1, referralPartner2 };

		areaManager = TestFactoryUser.makeAreaManager('TEST', 'AREA_MANAGER', branchA.External_Id__c);
		bdm = TestFactoryUser.makeBDM('TEST', 'BDM', 'BBSI Standard', branchB.External_Id__c);
		insert new List<User>{ areaManager, bdm };

		branchA.Branch_Manager__c = areaManager.FirstName + ' ' + areaManager.LastName;
		branchA.Branch_Manager_Email__c = areaManager.Email;
		update branchA;
		
		producer1 = TestFactoryContact.makeProducer('testcontact1', 'Referral Partner', referralPartner1.Id);
        producer2 = TestFactoryContact.makeProducer('testcontact2', 'Referral Partner', referralPartner2.Id);
		insert new List<Contact>{ producer1, producer2 };

        Branch_Region__c region1 = TestFactoryBranchRegion.makeBranchreg('SoCal', 'Area Manager', null);
        Branch_Region__c regionAll = TestFactoryBranchRegion.makeBranchreg('All', 'Area Manager', null);
		insert new List<Branch_Region__c>{ region1, regionAll };
	}

	static void loadData() {
		branchA = [SELECT Id, Name FROM Account WHERE Name = 'TEST_BRANCH_A'];
		branchA = [SELECT Id, Name FROM Account WHERE Name = 'TEST_BRANCH_B'];

		referralPartner1 = [
			SELECT Id
			FROM Account
			WHERE Name = 'TEST_REFERRAL_PARTNER_1' 
			LIMIT 1
		];
		referralPartner2 = [
			SELECT Id
			FROM Account
			WHERE Name = 'TEST_REFERRAL_PARTNER_2'
			LIMIT 1
		];

		areaManager = [
			SELECT Id, Branch_Id__c 
			FROM User 
			WHERE Name = 'TEST AREA_MANAGER'
			LIMIT 1
		];
		bdm = [
			SELECT Id, Branch_Id__c
			FROM User
			WHERE Name = 'TEST BDM'
			LIMIT 1
		];

		producer1 = [SELECT Id FROM Contact WHERE AccountId = :ReferralPartner1.Id];
		producer2 = [SELECT Id FROM Contact WHERE AccountId = :ReferralPartner2.Id];
	}

	@IsTest
	static void testInsertLeadAndTestBranchMatchesOwner() {
		loadData();
		Id idrtClient = recordTypeService.getId('Lead', 'Client_Lead');
		Map<String, Account> branches = AccountBranch.getBranchesByNumber();
		referralPartner1.OwnerId = areaManager.Id;
		update referralPartner1;

		Test.startTest();

		System.runAs(areaManager) {
            Lead newLead = TestFactoryLead.makeClientLead('Test', 'Lead', 'Test Lead', null, bdm.Id);
            newLead.Referral_Partner__c = ReferralPartner1.Id;
            newLead.Producer__c = producer1.Id;
			insert newLead;
			newLead = [SELECT Id, RecordTypeId, Branch__c, OwnerId FROM Lead WHERE Id = :newLead.Id LIMIT 1];
			Assert.areEqual(newLead.OwnerId, areaManager.Id);
			Assert.areEqual(newLead.Branch__c, branches.get(areaManager.Branch_Id__c).Id);
			Assert.areEqual(newLead.RecordTypeId, idrtClient, 'RecordType Not correct');

			newLead.OwnerId = bdm.Id;
			update newLead;
		}
		Test.stopTest();

		Lead newLead = [SELECT Id, RecordTypeId, Branch__c, OwnerId FROM Lead WHERE Company = 'Test Lead' LIMIT 1];

		Assert.areEqual(newLead.OwnerId, bdm.Id, 'BDM not set correctly');
		Assert.areEqual(newLead.Branch__c, branches.get(bdm.Branch_Id__c).Id, 'Wrong branch');
		Assert.areEqual(newLead.RecordTypeId, idrtClient, 'Incorrect RecordType');
	}

	@IsTest
	static void testInsertUpdateLeadWithReferralPartner() {
		loadData();
		referralPartner1.OwnerId = areaManager.Id;
		referralPartner2.OwnerId = areaManager.Id;
		update new List<Account>{ referralPartner1, referralPartner2 };

		Test.startTest();
		System.runAs(areaManager) {			
            Lead newLead = TestFactoryLead.makeClientLead('Test', 'Lead', 'Test Lead', null, bdm.Id);
            newLead.Referral_Partner__c = ReferralPartner1.Id;
            newLead.Producer__c = producer1.Id;
            newLead.Referral_Comments__c = 'Referral Comments';
            insert newLead;

			Referral_Partner__c rp = [
				SELECT Referral_Partner__c, Comments__c
				FROM Referral_Partner__c
				WHERE Lead__c = :newLead.Id
				LIMIT 1
			];

			Assert.areEqual(rp.Referral_Partner__c, ReferralPartner1.Id);
			Assert.areEqual(rp.Comments__c, 'Referral Comments');

			newLead = [SELECT Id, RecordTypeId, Branch__c, OwnerId FROM Lead WHERE Id = :newLead.Id LIMIT 1];
			newLead.Referral_Partner__c = ReferralPartner2.Id;
			newLead.Producer__c = producer2.Id;
			update NewLead;

			rp = [
				SELECT Referral_Partner__c, Comments__c
				FROM Referral_Partner__c
				WHERE Lead__c = :NewLead.Id AND Termination_Date__c = NULL
				LIMIT 1
			];
			Assert.areEqual(rp.Referral_Partner__c, ReferralPartner2.Id);
		}
		Test.stopTest();
	}

	@IsTest
	static void testAttachmentMovesFromContactToOpportunityOnConvert() {
		loadData();
		
		referralPartner1.OwnerId = areaManager.Id;
		referralPartner2.OwnerId = areaManager.Id;
		update new List<Account>{ referralPartner1, referralPartner2 };

		Test.startTest();

		System.runAs(areaManager) {
            Lead newLead = TestFactoryLead.makeClientLead('Test','Lead','Test Lead',null,bdm.Id);
			newLead.Referral_Partner__c = ReferralPartner1.Id;
            newLead.Producer__c = producer1.Id;
            newLead.Referral_Comments__c = 'Referral Comments';
			newLead.Duplicate_Check_Status__c = true;
			newLead.Estimated_Annual_Billing__c = 500000;
			insert newLead;
			
            Attachment attach = TestFactoryAttachment.createAttachment('Unit Test Attachment','Unit Test Attachment Body',newLead.Id,null);
			Note note = TestFactoryNote.createNote(NewLead.Id,'Test Note','Body of text',null);
			Database.LeadConvertResult lcr = LeadConvert.convert(newLead.Id, true);
			Assert.isTrue(lcr.isSuccess(), 'Lead conversion failed');
		}

		Test.stopTest();

		Lead testLead = [
			SELECT Id, ConvertedContactId, ConvertedOpportunityId
			FROM Lead
			WHERE Company = 'Test Lead'
			LIMIT 1
		];

		List<Attachment> oppAttach = [SELECT Id FROM Attachment WHERE ParentId = :testLead.ConvertedOpportunityId];
		Assert.areEqual(1, oppAttach.size());

		List<Attachment> contAttach = [SELECT Id FROM Attachment WHERE ParentId = :testLead.ConvertedContactId];
		Assert.areEqual(0, contAttach.size());

		List<Note> oppNotes = [SELECT Id FROM Note WHERE ParentId = :testLead.ConvertedOpportunityId];
		Assert.areEqual(1, oppNotes.size());

		List<Note> contNotes = [SELECT Id FROM Note WHERE ParentId = :testLead.ConvertedContactId];
		Assert.areEqual(0, contNotes.size());
	}
}