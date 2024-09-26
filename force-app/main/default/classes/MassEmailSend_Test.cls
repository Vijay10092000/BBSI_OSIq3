@IsTest
@SuppressWarnings('PMD.ApexAssertionsShouldIncludeMessage, PMD.AvoidHardcodingId')
public with sharing class MassEmailSend_Test {
	private final static String FORMAT_CONTENT_CSV = 'ID,Name\n{0},{1}\n{2},{3}';

	private final static String EMAIL_TEMPLATE_NAME = 'TEST_EMAIL_TEMPLATE_1';

	private final static Id ID_FILE = Id.valueOf('0692f000002WwNPAA0');

	//private static Folder folderEmail;
	private static EmailTemplate template;

	private static User sysAdmin;
	private static User owner;
	private static User userBenefitsRep;

	private static Account branch;
	private static Account client1;
	private static Account client2;

	private static Contact contact1;
	private static Contact contact2;

	private static MassEmailPerson person1;
	private static MassEmailPerson person2;

	@TestSetup
	static void makeData() {
		// branch = TestFactory.createAccountBranch('TEST BRANCH', '99999', 'a1000', true);
		branch = TestFactoryAccount.makeBranch('TEST BRANCH');
		branch.BillingPostalCode = '99999';
		branch.ShippingPostalCode = '99999';
		branch.External_Id__c = 'a1000';
		insert branch;

		// sysAdmin = TestFactory.createUser('SYSADMIN', 'System Administrator', 'a1000', false);
		sysAdmin = TestFactoryUser.makeUser('SYSADMIN', 'SYSADMIN', 'System Administrator', 'a1000');
		// owner = TestFactory.createUser('TEST_OWNER', 'BBSI Standard', 'a1000', false);
		owner = TestFactoryUser.makeUser('TEST_OWNER', 'TEST_OWNER', 'BBSI Standard', 'a1000');

		insert new List<User>{ owner, sysAdmin };

		// userBenefitsRep = TestFactory.createUser('TEST_REP', 'BBSI Standard', 'a1000', false);
		userBenefitsRep = TestFactoryUser.makeUser('TEST_REP', 'TEST_REP', 'BBSI Standard', 'a1000');
		userBenefitsRep.Is_Benefits_Representative__c = true;
		insert userBenefitsRep;

		branch.Benefits_Representative__c = userBenefitsRep.Id;
		update branch;

		// client1 = TestFactory.createAccountClient('CLIENT_1', false);
		client1 = TestFactoryAccount.makeClient('CLIENT_1', null, null);
		client1.Primary_Contact_Name__c = 'CONTACT_1';
		client1.Primary_Contact_Email__c = 'CONTACT_1@client1.zzz';
		client1.Benefits_Representative__c = userBenefitsRep.Id;

		// client2 = TestFactory.createAccountClient('CLIENT_2', false);
		client2 = TestFactoryAccount.makeClient('CLIENT_2', null, null);
		client2.Primary_Contact_Name__c = 'CONTACT_2';
		client2.Primary_Contact_Email__c = 'CONTACT_2@client2.zzz';
		client2.Benefits_Representative__c = userBenefitsRep.Id;

		System.runAs(owner) {
			insert new List<Account>{ client1, client2 };
		}

		// contact1 = TestFactory.createContact(client1, 'CONTACT_1', 'Client Contact', false);
		contact1 = TestFactoryContact.makeContact('CONTACT_1', 'CONTACT_1', 'Client Contact', client1.Id);
		contact1.Email = 'CONTACT_1@client1.zzz';
		contact1.Primary__c = true;
		// contact2 = TestFactory.createContact(client2, 'CONTACT_2', 'Client Contact', false);
		contact2 = TestFactoryContact.makeContact('CONTACT_2', 'CONTACT_2', 'Client Contact', client2.Id);
		contact2.Email = 'CONTACT_2@client2.zzz';
		contact2.Primary__c = true;
		insert new List<Contact>{ contact1, contact2 };

		/*template = new EmailTemplate(
			Name = EMAIL_TEMPLATE_NAME,
			DeveloperName = EMAIL_TEMPLATE_NAME,
			IsActive = true,
			FolderId = owner.Id,
			TemplateType = 'custom'
		);*/

		Map<String,Object> fldMap = new Map<String,Object> {
			'DeveloperName' => EMAIL_TEMPLATE_NAME,
			'IsActive' => true,
			'FolderId' => owner.Id,
			'TemplateType' => 'custom'
		};
		template = TestFactoryEmailTemplate.makeTemplate(EMAIL_TEMPLATE_NAME, fldMap);

		System.runAs(owner) {
			insert template;
		}
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

		template = [SELECT Id, Name FROM EmailTemplate WHERE Name = :EMAIL_TEMPLATE_NAME LIMIT 1];

		Assert.areNotEqual(null, template);
		Assert.areNotEqual(null, template.Id);

		person1 = new MassEmailPerson(
			'Id1',
			client1.Id,
			client1.Name,
			contact1.Id,
			'CONTACT',
			contact1.Name,
			contact1.Email,
			owner.Id,
			owner.Name,
			owner.Email,
			userBenefitsRep.Id,
			userBenefitsRep.Name,
			userBenefitsRep.Email
		);

		person2 = new MassEmailPerson(
			'Id2',
			client2.Id,
			client2.Name,
			contact2.Id,
			'CONTACT',
			contact2.Name,
			contact2.Email,
			owner.Id,
			owner.Name,
			owner.Email,
			userBenefitsRep.Id,
			userBenefitsRep.Name,
			userBenefitsRep.Email
		);
	}

	@IsTest
	public static void test_constructor() {
		readData();

		List<MassEmailPerson> persons = new List<MassEmailPerson>{ person1, person2 };

		MassEmailSend sender;

		Test.startTest();

		sender = new MassEmailSend(
			template.Id,
			ID_FILE,
			persons,
			'Current User',
			'Contact Ids',
			new List<String>{ 'Owner' }
		);

		Test.stopTest();

		Assert.areEqual(template, sender.template);
		Assert.areEqual(ID_FILE, sender.idFile);
		Assert.areEqual('Contact Ids', sender.typeFile);
		Assert.areEqual(1, sender.carbonCopy.size());
	}

	@IsTest
	public static void test_preSend() {
		readData();

		List<MassEmailPerson> persons = new List<MassEmailPerson>{ person1, person2 };

		MassEmailSend sender;

		Test.startTest();

		sender = new MassEmailSend(template.Id, ID_FILE, persons, 'Account Owner', 'Contact Ids', new List<String>{});
		sender.preSend();

		Test.stopTest();

		Assert.areNotEqual(null, sender.history);
	}

	@IsTest
	public static void test_sendEmails() {
		readData();

		List<MassEmailPerson> persons = new List<MassEmailPerson>{ person1, person2 };

		Test.startTest();

		MassEmailSend sender = new MassEmailSend(
			template.Id,
			null,
			persons,
			'Benefits Representative',
			'Contact Ids',
			new List<String>{}
		);
		sender.preSend();
		sender.sendEmails();

		Test.stopTest();

		Assert.areNotEqual(null, sender.preEmailsSent);
		Assert.areEqual('SENDING', sender.history.Status__c);
		Assert.areEqual(sender.template.Name, sender.history.Email_Template__c);
	}

	@IsTest
	public static void test_sendEmailsWithBlankBenRep() {
		readData();
		person2.nameBenefitsRep = '';

		List<MassEmailPerson> persons = new List<MassEmailPerson>{ person1, person2 };

		Test.startTest();

		MassEmailSend sender = new MassEmailSend(
			template.Id,
			null,
			persons,
			'Benefits Representative',
			'Contact Ids',
			new List<String>{}
		);
		sender.preSend();
		sender.sendEmails();

		Test.stopTest();

		Assert.areNotEqual(null, sender.preEmailsSent);
		Assert.areEqual('SENDING', sender.history.Status__c);
		Assert.areEqual(sender.template.Name, sender.history.Email_Template__c);
	}

	@IsTest
	public static void test_sendEmailsForAccountOwner() {
		readData();

		List<MassEmailPerson> persons = new List<MassEmailPerson>{ person1, person2 };

		Test.startTest();

		MassEmailSend sender = new MassEmailSend(
			template.Id,
			null,
			persons,
			'Account Owner',
			'Contact Ids',
			new List<String>{}
		);
		sender.preSend();
		sender.sendEmails();

		Test.stopTest();

		Assert.areNotEqual(null, sender.preEmailsSent);
		Assert.areEqual('SENDING', sender.history.Status__c);
		Assert.areEqual(sender.template.Name, sender.history.Email_Template__c);
	}

	@IsTest
	public static void test_sendEmailsForNone() {
		readData();

		List<MassEmailPerson> persons = new List<MassEmailPerson>{ person1, person2 };

		Test.startTest();

		MassEmailSend sender = new MassEmailSend(
			template.Id,
			null,
			persons,
			'Current User',
			'Contact Ids',
			new List<String>{ 'some.test@account.test.sample.email' }
		);
		sender.preSend();
		sender.sendEmails();

		Test.stopTest();

		Assert.areNotEqual(null, sender.preEmailsSent);
		Assert.areEqual('SENDING', sender.history.Status__c);
		Assert.areEqual(sender.template.Name, sender.history.Email_Template__c);
	}

	@IsTest
	public static void test_sendEmailsWithBlankIdPerson() {
		readData();
		person2.idPerson = '';

		List<MassEmailPerson> persons = new List<MassEmailPerson>{ person1, person2 };

		Test.startTest();

		MassEmailSend sender = new MassEmailSend(
			template.Id,
			null,
			persons,
			'Current User',
			'Contact Ids',
			new List<String>{ 'Current User' }
		);
		sender.addToSubject = 'Subject Suffix';
		sender.preSend();
		sender.sendEmails();

		Test.stopTest();

		Assert.areNotEqual(null, sender.preEmailsSent);
		Assert.areEqual('SENDING', sender.history.Status__c);
		Assert.areEqual(sender.template.Name, sender.history.Email_Template__c);
	}

	@IsTest
	public static void test_postSend() {
		DateTime testStart = DateTime.now();

		List<MassEmailPerson> persons = new List<MassEmailPerson>{ person1, person2 };

		readData();

		Test.startTest();

		MassEmailSend sender = new MassEmailSend(
			template.Id,
			null,
			persons,
			'Current User',
			'Contact Ids',
			new List<String>{}
		);
		sender.insertNewHistory();
		sender.postSend();

		Test.stopTest();

		Assert.areNotEqual(null, sender.postEmailsSent);
		Assert.areEqual('COMPLETE', sender.history.Status__c);

		List<Log__c> logs = Log_Test.recentLogs(testStart);
		Assert.areEqual(1, logs.size());
		Assert.areEqual('MassEmailSend', logs[0].Scope__c);
	}

	@IsTest
	public static void test_buildLine() {
		readData();

		List<MassEmailPerson> persons = new List<MassEmailPerson>{ person1, person2 };

		Test.startTest();

		MassEmailSend sender = new MassEmailSend(
			template.Id,
			null,
			persons,
			'Current User',
			'Contact Ids',
			new List<String>{}
		);
		String line = sender.buildLine(person1);

		Test.stopTest();

		Assert.areNotEqual(null, line);
		Assert.isTrue(line.contains(person1.idPerson));
		Assert.isTrue(line.contains(person1.namePerson));
		Assert.isTrue(line.contains(person1.emailPerson));
	}

	@IsTest
	public static void test_buildResultsTable() {
		readData();

		List<MassEmailPerson> persons = new List<MassEmailPerson>{ person1, person2 };

		MassEmailSend sender;

		Test.startTest();

		sender = new MassEmailSend(
			template.Id,
			null,
			persons,
			'Current User',
			'Contact Ids',
			new List<String>{}
		);

		sender.sent.add(person1);
		sender.failed.add(person2);
		sender.insertNewHistory();

		String body = sender.buildResultsTable();

		Test.stopTest();

		Assert.areNotEqual(null, body);
		Assert.isTrue(body.contains('MASS EMAIL Sent On'));
		Assert.isTrue(body.contains('EMAIL TEMPLATE'));
		Assert.isTrue(body.contains('Count Sent'));
	}

	@IsTest
	public static void test_determineCarbonCopy() {
		readData();

		List<MassEmailPerson> persons = new List<MassEmailPerson>{ person1, person2 };

		Test.startTest();

		MassEmailSend sender = new MassEmailSend(
			template.Id,
			null,
			persons,
			'Current User',
			'Contact Ids',
			new List<String>{ 'Account Owner', 'Benefits Representative', 'Current User' }
		);

		List<String> listCC = sender.determineCarbonCopy(person1);

		Test.stopTest();

		Assert.areEqual(3, listCC.size());
		Assert.isTrue(listCC.contains(person1.emailOwner));
		Assert.isTrue(listCC.contains(person1.emailBenefitsRep));
		Assert.isTrue(listCC.contains(UserInfo.getUserEmail()));
	}

	@IsTest
	public static void test_send() {
		readData();

		List<MassEmailPerson> persons = new List<MassEmailPerson>{ person1, person2 };

		Test.startTest();

		List<MassEmailPerson> personsRet = MassEmailSend.send(
			template.Id,
			null,
			persons,
			'Benefits Representative',
			'Contact Ids',
			new List<String>{}
		);
		// sender.preSend();
		// sender.sendEmails();

		Test.stopTest();

		Assert.areNotEqual(null, personsRet);
		Assert.areEqual(2, personsRet.size());
	}
}