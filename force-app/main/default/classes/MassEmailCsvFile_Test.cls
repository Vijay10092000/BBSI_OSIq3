/**
 * @description MassEmailCsvFile_Test contains test for the MassEmailCsvFile class.  , PMD.AvoidHardcodingId
 */
@SuppressWarnings('PMD.ApexAssertionsShouldIncludeMessage')
@IsTest
public with sharing class MassEmailCsvFile_Test {
	private final static String FORMAT_CONTENT_CSV = 'ID,Name\n{0},{1}\n{2},{3}';

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
			SELECT Id, Name, OwnerId, Owner.Name, Owner.Email, Benefits_Representative__r.Name, Benefits_Representative__r.Email
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
	public static void test_readAccounts() {
		readData();

		Test.startTest();
		Set<Id> idAccounts = new Set<Id>{ client1.Id, client2.Id };
		MassEmailCsvFile csvFile = new MassEmailCsvFile();
		List<MassEmailPerson> persons = csvFile.readAccounts(idAccounts);
		Test.stopTest();

		Assert.areEqual(2, persons.size());

		MassEmailPerson person1 = persons.get(0);
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

		MassEmailPerson person2 = persons.get(1);
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
	public static void test_extractData() {
		readData();

		String csvText = String.format(
			FORMAT_CONTENT_CSV,
			new List<String>{ client1.Id, client1.Name, client2.Id, client2.Name }
		);

		Map<Integer, Map<Integer, String>> csv = Csv_Service.readAsMatrix(csvText);

		Test.startTest();
		MassEmailCsvFile csvFile = new MassEmailCsvFile(csv);
		List<MassEmailPerson> persons = csvFile.persons;
		Test.stopTest();

		Assert.areEqual(2, persons.size());

		MassEmailPerson person1 = persons.get(0);
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

		MassEmailPerson person2 = persons.get(1);
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
	public static void test_readCsvFile() {
		readData();

		String csvText = String.format(
			FORMAT_CONTENT_CSV,
			new List<String>{ client1.Id, client1.Name, client2.Id, client2.Name }
		);

		Id idFile = File_Service.createFile(null, 'TestFile', 'TestFile', Blob.valueOf(csvText));

		Test.startTest();
		MassEmailCsvFile csvFile = new MassEmailCsvFile(idFile);
		Map<Integer, Map<Integer, String>> csvData = csvFile.readCsvFile(idFile);
		Test.stopTest();

		Assert.areEqual(3, csvData.size());

		Map<Integer, String> columnsRow;
		columnsRow = csvData.get(0);
		Assert.areEqual(2, columnsRow.size());
		Assert.areEqual('ID', columnsRow.get(0));
		Assert.areEqual('Name', columnsRow.get(1));

		columnsRow = csvData.get(1);
		Assert.areEqual(2, columnsRow.size());
		Assert.areEqual(client1.Id, columnsRow.get(0));
		Assert.areEqual(client1.Name, columnsRow.get(1));

		columnsRow = csvData.get(2);
		Assert.areEqual(2, columnsRow.size());
		Assert.areEqual(client2.Id, columnsRow.get(0));
		Assert.areEqual(client2.Name, columnsRow.get(1));
	}

	@IsTest
	public static void test_extractDataWithContactId() {
		readData();

		String csvText = String.format(
			FORMAT_CONTENT_CSV,
			new List<String>{ contact1.Id, contact1.Name, contact2.Id, contact2.Name }
		);

		Map<Integer, Map<Integer, String>> csv = Csv_Service.readAsMatrix(csvText);

		Test.startTest();
		MassEmailCsvFile csvFile = new MassEmailCsvFile(csv);
		List<MassEmailPerson> persons = csvFile.persons;
		Test.stopTest();

		Assert.areEqual(2, persons.size());

		MassEmailPerson person1 = persons.get(0);
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

		MassEmailPerson person2 = persons.get(1);
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
	public static void test_extractDataWithContactEmail() {
		readData();

		String csvText = String.format(
			FORMAT_CONTENT_CSV,
			new List<String>{ contact1.Email, contact1.Name, contact2.Email, contact2.Name }
		);

		Map<Integer, Map<Integer, String>> csv = Csv_Service.readAsMatrix(csvText);

		Test.startTest();
		MassEmailCsvFile csvFile = new MassEmailCsvFile(csv);
		List<MassEmailPerson> persons = csvFile.persons;
		Test.stopTest();

		Assert.areEqual(2, persons.size());

		MassEmailPerson person1 = persons.get(0);
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

		MassEmailPerson person2 = persons.get(1);
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
	public static void test_extractDataWithError() {
		readData();

		String csvText = String.format(
			FORMAT_CONTENT_CSV,
			new List<String>{ 'SomeJunkId1', contact1.Name, 'SomeJunkId2', contact2.Name }
		);

		Map<Integer, Map<Integer, String>> csv = Csv_Service.readAsMatrix(csvText);

		Test.startTest();
		try {
			MassEmailCsvFile csvFile = new MassEmailCsvFile(csv);
			Assert.isTrue(false, 'Should have thrown an exception');
		}
		catch (Exception e) { }
		Test.stopTest();
	}

	@IsTest
	public static void test_readContactsByEmail() {
		readData();

		Test.startTest();
		Set<String> emailContacts = new Set<String>{ contact1.Email, contact2.Email };
		MassEmailCsvFile csvFile = new MassEmailCsvFile();
		List<MassEmailPerson> persons = csvFile.readContactsByEmail(emailContacts);
		Test.stopTest();

		Assert.areEqual(2, persons.size());

		MassEmailPerson person1 = persons.get(0);
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

		MassEmailPerson person2 = persons.get(1);
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
}