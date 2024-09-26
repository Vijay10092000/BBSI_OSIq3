/**
 * @description LeadConversion_EventHandler_Test contains tests for the LeadConversion_EventHandler class.
 */
@IsTest
public with sharing class LeadConversion_EventHandler_Test {
	static User am;
	static User bdm;
	static Account branch;
	static Contact producer;
	static Account referralPartner;

	@TestSetup
	static void makeData() {
		branch = TestFactory.createAccountBranch('TEST BRANCH', 'AAA', 'AreaManager', 'Test.AreaManager@bbsi.zzz', false);
		referralPartner = TestFactory.createAccountReferralPartner('ReferralPartner', 'Active', '% of Margin', 10.0, null, false);
		insert new List<Account>{ branch, referralPartner };

		am = TestFactory.createUserAM('AreaManager', 'AAA', false);
		bdm = TestFactory.createUserBDM('BDM', 'acronym', 'BBSI Standard', 'AAA', false);
		insert new List<User>{ am, bdm };

		producer = TestFactory.createContact(referralPartner, 'Producer', 'Producer', true);
	}

	static void loadData() {
		am = [SELECT Id, Name FROM User WHERE LastName = 'AreaManager'];
		bdm = [SELECT Id, Name FROM User WHERE LastName = 'BDM'];
		branch = [SELECT Id, Name FROM Account WHERE Name = 'TEST BRANCH'];
		referralPartner = [SELECT Id, Name FROM Account WHERE Name = 'ReferralPartner'];
		producer = [SELECT Id, Name FROM Contact WHERE LastName = 'Producer'];
	}

	// TODO: FINISH TESTS
/*
	@isTest
	static void test_moveAttachmentsAndNotes() {
		loadData();

		Lead newLead = TestFactoryLead.makeClientLead('Lead', 'Lead Company', 'Active', branch.Id, bdm.Id);
		newLead.Referral_Partner__c = ReferralPartner.Id;
		newLead.Producer__c = producer.id;
		newLead.Referral_Comments__c = 'Referral Comments';
		newLead.Duplicate_Check_Status__c = true;
		newLead.Estimated_Annual_Billing__c = 500000;
		insert newLead;

		Attachment attachment = new Attachment();
		attachment.Name='Unit Test Attachment';
		Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
		attachment.Body = bodyBlob;
		attachment.ParentId = newLead.Id;
		insert attachment;

		Note note = new Note();
		note.Title = 'Test Note';
		note.ParentID = newLead.Id;
		note.Body = 'Body of text';
		insert note;

		Test.startTest();

		Database.LeadConvertResult lcr = LeadConvert.convert(newLead.Id, true);
		System.assert(lcr.isSuccess(), 'Lead conversion failed');

		Test.stopTest();

		Lead convertedLead = [SELECT Id, ConvertedContactId, ConvertedOpportunityId FROM Lead WHERE Company = 'Lead Company' LIMIT 1];

		List<Attachment> oppAttach = [SELECT Id FROM Attachment WHERE ParentId = :convertedLead.ConvertedOpportunityId];
		List<Attachment> contAttach = [SELECT Id FROM Attachment WHERE ParentId = :convertedLead.ConvertedContactId];
		System.assertEquals(1, oppAttach.size(), 'Attachment not moved to Opportunity');
		System.assertEquals(0, contAttach.size(), 'Attachment not removed from Lead');

		List<Note> oppNotes = [SELECT Id FROM Note WHERE ParentId = :convertedLead.ConvertedOpportunityId];
		List<Note> contNotes = [SELECT Id FROM Note WHERE ParentId = :convertedLead.ConvertedContactId];
		System.assertEquals(1, oppNotes.size(), 'Note not moved to Opportunity');
		System.assertEquals(0, contNotes.size(), 'Note not removed from Lead');
	}

	@IsTest
	static void test_moveEventsToAccount() {
		loadData();

		Lead newLead = TestFactoryLead.makeLeadRP('TEST', 'Lead', 'Lead Company');
		newLead.Referral_Comments__c = 'Referral Comments';
		newLead.Duplicate_Check_Status__c = true;
		newLead.Estimated_Annual_Billing__c = 500000;
		insert newLead;

		Event e = new Event(
			Type = 'Email',
			Description = 'TEST EVENT',
			OwnerId = am.Id,
			WhoId = newLead.Id,
			StartDateTime = datetime.now(),
			EndDateTime = datetime.now()
		);

        insert e;

		Test.startTest();

		Database.LeadConvertResult lcr = LeadConvert.convert(newLead.Id, false);
		System.assert(lcr.isSuccess(), 'Lead conversion failed');

		Test.stopTest();

		Lead convertedLead = [SELECT Id, ConvertedAccountId, ConvertedContactId FROM Lead WHERE Id = :newLead.Id];
		e = [SELECT Id, WhoId, WhatId FROM Event WHERE Id = :e.Id];

		System.assertEquals(convertedLead.ConvertedContactId, e.WhoId, 'Event should be connected to the new Contact');
		System.assertEquals(convertedLead.ConvertedAccountId, e.WhatId, 'Event should be connected to the new Account');
	}

	@isTest
	static void test_moveTasksToAccount() {
		loadData();

		Lead newLead = TestFactoryLead.makeLeadRP('TEST', 'Lead', 'Lead Company');
		newLead.Referral_Comments__c = 'Referral Comments';
		newLead.Duplicate_Check_Status__c = true;
		newLead.Estimated_Annual_Billing__c = 500000;
		insert newLead;

		Task t = new Task(
			Type = 'Email',
			Subject = 'Task',
			Status = 'Open',
			Priority = 'Normal',
			OwnerId = am.Id,
			WhoId = newLead.Id
		);

        insert t;

		Test.startTest();

		Database.LeadConvertResult lcr = LeadConvert.convert(newLead.Id, false);
		System.assert(lcr.isSuccess(), 'Lead conversion failed');

		Test.stopTest();

		Lead convertedLead = [SELECT Id, ConvertedAccountId, ConvertedContactId FROM Lead WHERE Id = :newLead.Id];
		t = [SELECT Id, WhoId, WhatId FROM Task WHERE Id = :t.Id];

		System.assertEquals(convertedLead.ConvertedContactId, t.WhoId, 'Event should be connected to the new Contact');
		System.assertEquals(convertedLead.ConvertedAccountId, t.WhatId, 'Event should be connected to the new Account');
	}
*/
}