/**
 * @description ContentDocumentFileAttached_Test contains tests for the ContentDocumentFileAttached class.
 */
@IsTest
public without sharing class ContentDocumentFileAttached_Test {
	private static User user;
	private static Event__c event;
	private static ContentVersion version1;
	private static ContentVersion version2;
	private static ContentDocument document1;
	private static ContentDocument document2;

	@TestSetup
	static void makeData() {
		Account branch = TestFactoryAccount.createBranch('TEST BRANCH');
		user = TestFactoryUser.createUser('TESTING', 'USER!!', 'BBSI Standard', branch.External_Id__c);
		
		Date today = Date.today();
        Id idrtEventClient = RecordTypeService.getId('Event__c', 'Client Event');

		event = new Event__c(
			OwnerId = user.Id,
            RecordTypeId = idrtEventClient,
            Event_Start_Date__c = today.addDays(7),
            Event_End_Date__c = today.addDays(7),
            Event_Type__c = 'Meeting',
            Event_Type_Other__c = '',
            Event_Manager__c = user.Id,
            Budget_Overall__c = 10000,
            Final_Cost__c = 10000,
            Region__c = 'NoCal'
        );
		insert event;
		
		version1 = new ContentVersion(
			Title = 'TestFileONE',
			PathOnClient = 'TestFileONE.txt',
			VersionData = Blob.valueOf('ONE'),
			IsMajorVersion = true
		);		

		version2 = new ContentVersion(
			Title = 'TestFileTWO',
			PathOnClient = 'TestFileTWO.txt',
			VersionData = Blob.valueOf('TWO'),
			IsMajorVersion = true
		);

		insert new List<ContentVersion>{ version1, version2 };	
	}

	static void loadData() {
		user = [SELECT Id FROM User WHERE Name = 'TESTING USER!!'];
		event = [SELECT Id, Files_Attached__c FROM Event__c WHERE OwnerId = :user.Id];

		List<ContentVersion> versions = [SELECT Id, Title FROM ContentVersion WHERE Title LIKE 'TestFile%' ORDER BY Title ASC];
		version1 = versions.get(0);
		version2 = versions.get(1);

		List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument WHERE Title LIKE 'TestFile%' ORDER BY Title ASC];
		document1 = documents.get(0);
		document2 = documents.get(1);
	}

	@IsTest
	static void test_AddFiles() {
		loadData();

		Test.startTest();

		ContentDocumentLink link1 = new ContentDocumentLink(
			LinkedEntityId = event.Id,
			ContentDocumentId = document1.Id,
			shareType = 'V'
		);

		ContentDocumentLink link2 = new ContentDocumentLink(
			LinkedEntityId = event.Id,
			ContentDocumentId = document2.Id,
			shareType = 'V'
		);

		insert new List<ContentDocumentLink>{ link1, link2 };

		Test.stopTest();

		ContentDocumentFileAttached fa = new ContentDocumentFileAttached();
		fa.idRecords = new Set<Id>{ event.Id };
		fa.getCountAttachedFiles();
		
		Assert.areEqual(1, fa.counts.size(), 'Should have a record');
		Assert.isTrue(fa.counts.keySet().contains(event.Id), 'Should have the Event record');
		Assert.areEqual(2, fa.counts.get(event.Id), 'Event should have two files attached to it');

		Event__c event = [SELECT Id, Files_Attached__c FROM Event__c WHERE Id = :event.Id];
		Assert.isTrue(event.Files_Attached__c, 'Event should have the Files_Attached__c checked');
	}

	@IsTest
	static void test_RemoveLink() {		
		loadData();
		
		ContentDocumentLink link = new ContentDocumentLink(
			LinkedEntityId = event.Id,
			ContentDocumentId = document1.Id,
			shareType = 'V'
		);
		insert link;
				
		ContentDocumentFileAttached fa = new ContentDocumentFileAttached();
		fa.idRecords = new Set<Id>{ event.Id };
		fa.getCountAttachedFiles();
		
		Assert.areEqual(1, fa.counts.size(), 'Should have a record');
		Assert.isTrue(fa.counts.keySet().contains(event.Id), 'Should have the Event record');
		Assert.areEqual(1, fa.counts.get(event.Id), 'Event should have one file attached to it');

		Test.startTest();

		delete link;

		Test.stopTest();
		
		fa.getCountAttachedFiles();
		
		Assert.areEqual(1, fa.counts.size(), 'Should have a record');
		Assert.isTrue(fa.counts.keySet().contains(event.Id), 'Should have the Event record');
		Assert.areEqual(0, fa.counts.get(event.Id), 'Event should have no files attached to it');

		Event__c event = [SELECT Id, Files_Attached__c FROM Event__c WHERE Id = :event.Id];
		Assert.isFalse(event.Files_Attached__c, 'Event should have the Files_Attached__c unchecked');
	}

	@IsTest
	static void test_RemoveFile() {		
		loadData();
		
		ContentDocumentLink link = new ContentDocumentLink(
			LinkedEntityId = event.Id,
			ContentDocumentId = document1.Id,
			shareType = 'V'
		);
		insert link;
				
		ContentDocumentFileAttached fa = new ContentDocumentFileAttached();
		fa.idRecords = new Set<Id>{ event.Id };
		fa.getCountAttachedFiles();
		
		Assert.areEqual(1, fa.counts.size(), 'Should have a record');
		Assert.isTrue(fa.counts.keySet().contains(event.Id), 'Should have the Event record');
		Assert.areEqual(1, fa.counts.get(event.Id), 'Event should have one file attached to it');

		Test.startTest();

		delete document1;

		Test.stopTest();
		
		fa.getCountAttachedFiles();
		
		Assert.areEqual(1, fa.counts.size(), 'Should have a record');
		Assert.isTrue(fa.counts.keySet().contains(event.Id), 'Should have the Event record');
		Assert.areEqual(0, fa.counts.get(event.Id), 'Event should have no files attached to it');

		Event__c event = [SELECT Id, Files_Attached__c FROM Event__c WHERE Id = :event.Id];
		Assert.isFalse(event.Files_Attached__c, 'Event should have the Files_Attached__c unchecked');
	}
}