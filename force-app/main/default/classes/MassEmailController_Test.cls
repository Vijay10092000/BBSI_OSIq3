/**
 * @description MassEmailController_Test contains tests for the MassEmailController class.
 */
@IsTest
@SuppressWarnings('PMD.ApexAssertionsShouldIncludeMessage, PMD.AvoidHardcodingId')
public without sharing class MassEmailController_Test {
	private static final String FORMAT_CONTENT_CSV = 'ID,Name\n{0},{1}\n{2},{3}';

	private static Folder folderEmail;
	private static EmailTemplate e1;
	private static EmailTemplate e2;
	private static EmailTemplate e3;

	private static User sysAdmin;
	private static User owner;
	private static User userBenefitsRep;

	private static Account branch;
	private static Account client1;
	private static Account client2;

	private static Contact contact1;
	private static Contact contact2;

	@TestSetup
	static void makeData() {
		branch = TestFactoryAccount.makeBranch('TEST BRANCH');
		branch.BillingPostalCode = '99999';
		branch.ShippingPostalCode = '99999';
		branch.External_Id__c = 'a1000';
		insert branch;

		sysAdmin = TestFactoryUser.makeUser('SYSADMIN', 'SYSADMIN', 'System Administrator', 'a1000');
		owner = TestFactoryUser.makeUser('TEST_OWNER', 'TEST_OWNER', 'BBSI Standard', 'a1000');

		insert new List<User>{ owner, sysAdmin };

		userBenefitsRep = TestFactoryUser.makeUser('TEST_REP', 'TEST_REP', 'BBSI Standard', 'a1000');
		userBenefitsRep.Is_Benefits_Representative__c = true;
		insert userBenefitsRep;

		branch.Benefits_Representative__c = userBenefitsRep.Id;
		update branch;

		client1 = TestFactoryAccount.makeClient('CLIENT_1', null, null);
		client1.Primary_Contact_Name__c = 'CONTACT_1';
		client1.Primary_Contact_Email__c = 'CONTACT_1@client1.zzz';
		client1.Benefits_Representative__c = userBenefitsRep.Id;

		client2 = TestFactoryAccount.makeClient('CLIENT_2', null, null);
		client2.Primary_Contact_Name__c = 'CONTACT_2';
		client2.Primary_Contact_Email__c = 'CONTACT_2@client2.zzz';
		client2.Benefits_Representative__c = userBenefitsRep.Id;

		System.runAs(owner) {
			insert new List<Account>{ client1, client2 };
		}

		contact1 = TestFactoryContact.makeContact('CONTACT_1', 'CONTACT_1', 'Client Contact', client1.Id);
		contact1.Email = 'CONTACT_1@client1.zzz';
		contact1.Primary__c = true;
		contact2 = TestFactoryContact.makeContact('CONTACT_2', 'CONTACT_2', 'Client Contact', client2.Id);
		contact2.Email = 'CONTACT_2@client2.zzz';
		contact2.Primary__c = true;
		insert new List<Contact>{ contact1, contact2 };
	}

	static void readData() {
		List<User> users = [
			SELECT Id, Name, Email
			FROM User
			WHERE LastName IN ('SYSADMIN', 'TEST_OWNER', 'TEST_REP')
			ORDER BY LastName ASC
		];

		Assert.areEqual(3, users.size());
		sysAdmin = users.get(0);
		owner = users.get(1);
		userBenefitsRep = users.get(2);

		List<Account> accounts = [
			SELECT
				Id,
				Name,
				OwnerId,
				Owner.Name,
				Owner.Email,
				Benefits_Representative__r.Name,
				Benefits_Representative__r.Email
			FROM Account
			WHERE NAME IN ('CLIENT_1', 'CLIENT_2', 'TEST BRANCH')
			ORDER BY Name ASC
		];

		Assert.areEqual(3, accounts.size());
		client1 = accounts.get(0);
		client2 = accounts.get(1);
		branch = accounts.get(2);

		List<Contact> contacts = [
			SELECT Id, Name, Email
			FROM Contact
			WHERE LastName IN ('CONTACT_1', 'CONTACT_2')
			ORDER BY LastName ASC
		];
		contact1 = contacts.get(0);
		contact2 = contacts.get(1);
	}

	@IsTest
	// @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
	public static void test_setup() {
		Test.startTest();

		MassEmailController.DataResult result = MassEmailController.setup();

		Test.stopTest();

		Assert.areNotEqual(null, result);

		for (Option o : result.optionFolders) {
			System.debug(LoggingLevel.INFO, 'FOLDER: ' + o.label);
		}
	}

	@IsTest
	public static void test_readData() {
		readData();

		String csvText = String.format(
			FORMAT_CONTENT_CSV,
			new List<String>{ client1.Id, client1.Name, client2.Id, client2.Name }
		);

		Id idFile = File_Service.createFile(null, 'TestFile', 'TestFile', Blob.valueOf(csvText));

		Test.startTest();

		MassEmailController.DataResult result = MassEmailController.readData(String.valueOf(idFile));

		Test.stopTest();

		Assert.areNotEqual(null, result);
		Assert.areEqual(null, result.optionTemplates);

		Assert.areNotEqual(null, result.persons);
		Assert.areEqual(2, result.persons.size());

		MassEmailPerson person1 = result.persons.get(0);
		Assert.areEqual(client1.Id, person1.idAccount);
		Assert.areEqual(client1.Name, person1.nameAccount);
		Assert.areEqual(contact1.Id, person1.idPerson);
		Assert.areEqual('Contact', person1.typePerson);
		Assert.areEqual(contact1.Name, person1.namePerson);
		Assert.areEqual(contact1.Email, person1.emailPerson);
		Assert.areEqual(client1.Owner.Name, person1.nameOwner);
		Assert.areEqual(client1.Owner.Email, person1.emailOwner);
		Assert.areEqual(client1.Benefits_Representative__r.Name, person1.nameBenefitsRep);
		Assert.areEqual(client1.Benefits_Representative__r.Email, person1.emailBenefitsRep);

		MassEmailPerson person2 = result.persons.get(1);
		Assert.areEqual(client2.Id, person2.idAccount);
		Assert.areEqual(client2.Name, person2.nameAccount);
		Assert.areEqual(contact2.Id, person2.idPerson);
		Assert.areEqual('Contact', person2.typePerson);
		Assert.areEqual(contact2.Name, person2.namePerson);
		Assert.areEqual(contact2.Email, person2.emailPerson);
		Assert.areEqual(client2.Owner.Name, person2.nameOwner);
		Assert.areEqual(client2.Owner.Email, person2.emailOwner);
		Assert.areEqual(client2.Benefits_Representative__r.Name, person2.nameBenefitsRep);
		Assert.areEqual(client2.Benefits_Representative__r.Email, person2.emailBenefitsRep);
	}
    
    @IsTest
	public static void test_readData_error() {
		Test.startTest();

        try {
			MassEmailController.DataResult result = MassEmailController.readData('SomeJunkId');
			Assert.isTrue(false, 'Should have thrown an exception');
		} catch (Exception e) {
            // 
		}

		Test.stopTest();
	}

	@IsTest
	public static void test_sendEmails() {
		DateTime dtTestStart = DateTime.now();

		readData();

		EmailTemplate template = TestFactoryEmailTemplate.createTemplate('MassEmail');
		Assert.areNotEqual(null, template.Id);

		String csvText = String.format(
			FORMAT_CONTENT_CSV,
			new List<String>{ client1.Id, client1.Name, client2.Id, client2.Name }
		);

		Map<Integer, Map<Integer, String>> csv = Csv_Service.readAsMatrix(csvText);
		List<MassEmailPerson> persons = (new MassEmailCsvFile(csv)).persons;

		String idFile;
		System.runAs(owner) {
			idFile = String.valueOf(File_Service.createFile(null, 'TestFile', 'TestFile', Blob.valueOf(csvText)));
		}

		String sender = 'Account Owner';
		List<String> cc = new List<String>{ 'Owner', 'User' };
		List<String> selected = new List<String>{ '1', '2' };

		Test.startTest();

        try {
            MassEmailController.sendEmails('ACTION', 'SomeJunkId', 'SomeJunkId', 'SomeJunkSender', 'Contact Ids', null, null, null, 'CompleteEmailTask');
			Assert.isTrue(false, 'Should have thrown an exception');
        }
        catch (Exception e) {}
        
		System.runAs(sysAdmin) {
			MassEmailController.sendEmails('ACTION', idFile, Template.Id, sender, 'Contact Ids', cc, persons, selected, 'CompleteEmailTask');
		}

		Test.stopTest();

		List<Log__c> logs = Log_Test.recentLogs(dtTestStart);
		Assert.areEqual(1, logs.size());

		List<Mass_Email_History__c> histories = [
			SELECT Status__c, Produced_By__c, Date_Sent__c, Email_Subject__c, Number_Sent__c, Number_Failed__c
			FROM Mass_Email_History__c
			WHERE CreatedDate >= :dtTestStart
		];

		Assert.areNotEqual(null, histories);
		Assert.areEqual(1, histories.size());

		Mass_Email_History__c history = histories.get(0);

		Assert.areEqual(2, history.Number_Sent__c);
		Assert.areEqual(0, history.Number_Failed__c);
		Assert.areEqual('COMPLETE', history.Status__c);
		Assert.areEqual(sysAdmin.Id, history.Produced_By__c);
	}

	@IsTest
	// @SuppressWarnings('PMD.EmptyStatementBlock, PMD.ApexUnitTestClassShouldHaveAsserts')
	public static void test_getEmailTemplates() {
		EmailTemplate template = TestFactoryEmailTemplate.createTemplate('MassEmail');
		Assert.areNotEqual(null, template.Id);

		Test.startTest();

		try {
			MassEmailController.getEmailTemplates(UserInfo.getUserId());
		} catch (Exception e) {
			Assert.isTrue(false, 'Should not throw an exception');
		}

		Test.stopTest();
	}

	@IsTest
	public static void test_deleteFile() {
		Id idFile = File_Service.createFile(null, 'FILE1.txt', 'TEST FILE', Blob.valueOf('TEST'));

		Test.startTest();

		try {
			MassEmailController.deleteFile(idFile);
		} catch (Exception e) {
			Assert.isTrue(false, 'Should not throw an exception');
		}
        
        try {
			MassEmailController.deleteFile('SomeJunkId');
			Assert.isTrue(false, 'Should have thrown an exception');
		} catch (Exception e) {
		}

		Test.stopTest();
	}
    
    @IsTest
	public static void test_readFolder() {
		EmailTemplate template = TestFactoryEmailTemplate.createTemplate('MassEmail');
		Assert.areNotEqual(null, template.Id);

		Test.startTest();

		try {
			MassEmailController.readFolder(UserInfo.getUserId());
		} catch (Exception e) {
			Assert.isTrue(false, 'Should not throw an exception');
		}
        
        try {
			MassEmailController.readFolder('SomeJunkId');
			Assert.isTrue(false, 'Should have thrown an exception');
		} catch (Exception e) {
            // 
		}

		Test.stopTest();
	}
}