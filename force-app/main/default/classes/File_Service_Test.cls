/**
 * @description File_Service_Test contains tests for the File_Service class.
 */
@IsTest
public without sharing class File_Service_Test {
  @IsTest
	static void test_createFile() {
		Account client = TestFactoryAccount.createClient('TEST ACCOUNT', null, null);

		List<ContentDocumentLink> links;
		Blob data = Blob.valueOf('TEST');

		Test.startTest();
		Id idDocument = File_Service.createFile(client.Id, 'FILE1.txt', 'TEST FILE', data);
		Test.stopTest();

		links = [
			SELECT Id, ContentDocumentId
			FROM ContentDocumentLink
			WHERE LinkedEntityId = :client.Id
		];

		Assert.areEqual(1, links.size(), '1 file linked to object');
		Assert.areEqual(idDocument, links.get(0).ContentDocumentId, 'Correct Document');
	}

	@IsTest
	static void test_deleteFile() {
		Account client = TestFactoryAccount.createClient('TEST ACCOUNT', null, null);

		Blob data = Blob.valueOf('TEST');

		File_Service.createFile(client.Id, 'FILE1.txt', 'TEST FILE', data);
		File_Service.createFile(client.Id, 'FILE2.txt', 'TEST FILE', data);
		File_Service.createFile(client.Id, 'FILE3.txt', 'TEST FILE3', data);

		List<ContentDocumentLink> links = [
			SELECT Id, ContentDocumentId
			FROM ContentDocumentLink
			WHERE LinkedEntityId = :client.Id
		];

		Assert.areEqual(3, links.size(), 'Start with 3 files linked');

		Test.startTest();
		File_Service.deleteFile(client.Id, 'TEST FILE');
		Test.stopTest();

		links = [
			SELECT Id, ContentDocumentId
			FROM ContentDocumentLink
			WHERE LinkedEntityId = :client.Id
		];

		Assert.areEqual(1, links.size(), '1 file linked after delete');
	}

	@IsTest
	static void test_deleteFile2() {
		Account client = TestFactoryAccount.createClient('TEST ACCOUNT', null, null);

		Blob data = Blob.valueOf('TEST');

		File_Service.createFile(client.Id, 'FILE1.txt', 'TEST FILE', data);

		List<ContentDocumentLink> links = [
			SELECT Id, ContentDocumentId
			FROM ContentDocumentLink
			WHERE LinkedEntityId = :client.Id
		];

		Assert.areEqual(1, links.size(), 'Start with 1 file');

		Test.startTest();
		File_Service.deleteFile(links.get(0).ContentDocumentId);
		Test.stopTest();

		links = [
			SELECT Id, ContentDocumentId
			FROM ContentDocumentLink
			WHERE LinkedEntityId = :client.Id
		];

		Assert.areEqual(0, links.size(), 'No file linked after delete');
	}

	@IsTest
	static void test_readFile() {
		Account client = TestFactoryAccount.createClient('TEST ACCOUNT', null, null);

		Blob data = Blob.valueOf('TEST');

		Id idFile = File_Service.createFile(client.Id, 'FILE1.txt', 'TEST FILE', data);

		ContentVersion version = File_Service.readFile(idFile);

		Assert.areEqual(true, version.IsLatest, 'Should be latest');
		Assert.areEqual(data.toString(), version.VersionData.toString(), 'Bad data?');
	}

	@IsTest
	static void test_read() {
		Account client = TestFactoryAccount.createClient('TEST ACCOUNT', null, null);

		Blob data = Blob.valueOf('TEST');

		File_Service.createFile(client.Id, 'FILE1.txt', 'TEST FILE', data);

		List<ContentDocumentLink> links = [
			SELECT Id, ContentDocumentId
			FROM ContentDocumentLink
			WHERE LinkedEntityId = :client.Id
		];

		Assert.areEqual(1, links.size(), 'Start with 1 file');

		Test.startTest();
		String text = File_Service.read(links.get(0).ContentDocumentId);
		Test.stopTest();

		Assert.areNotEqual(null, text, 'Should have data');
		Assert.areEqual('TEST', text, 'Should be TEST');
	}
}