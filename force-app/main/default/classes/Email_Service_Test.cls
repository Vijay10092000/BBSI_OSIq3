/**
 * @description Email_Service_Test
 */
@IsTest
@SuppressWarnings('PMD.ApexAssertionsShouldIncludeMessage')
public without sharing class Email_Service_Test {
	private static final String EMAILTEMPLATE_NAME = 'EmailTemplate Test';
	private static final String EMAILTEMPLATE_DEVELOPER_NAME = 'unique_name_TestEmailTemplate';
	private static final String EMAILTEMPLATE_BODY = 'Template Body';

	private static User admin;
	private static Account branch;

	@TestSetup
	static void makeData() {
		TestFactory.createAccountBranch('BranchTest', '99999', '1001', true);
		TestFactory.createUser('AdminTest', 'admin@bbsi.zzz', 'admin@bbsi.zzz', 'System Administrator', '1001', true);
	}

	static void loadData() {
		admin = [SELECT Id, Name FROM User WHERE LastName = 'AdminTest' LIMIT 1];
		branch = [SELECT Id, Name, External_Id__c FROM Account WHERE Name = 'BranchTest' LIMIT 1];
	}

	@IsTest
	public static void test_makeBaseEmail() {
		List<String> addresses = new List<String>{ 'fake1@bbsi.zzz', 'fake2@bbsi.zzz' };
		Messaging.SingleEmailMessage email = Email_Service.makeBaseEmail(addresses, null, 'Test Subject');

		System.assert(email.getSubject().endsWith('Test Subject'));
		System.assertEquals(2, email.getToAddresses().size());
		System.assertEquals(null, email.getCcAddresses());
		System.assertEquals(Email_Service.DEFAULT_SENDER, email.getSenderDisplayName());
		System.assertEquals(Email_Service.NO_REPLY_EMAIL, email.getReplyTo());
		System.assertEquals(false, email.getUseSignature());
		System.assertEquals(false, email.getBccSender());
		System.assertEquals(false, email.getSaveAsActivity());
	}

	@IsTest
	static void test_send() {
		List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

		Email_Service.send(emails);
		System.assertEquals(0, emails.size());

		List<String> addresses = new List<String>{ 'fake@bbsi.zzz' };
		Messaging.SingleEmailMessage email = Email_Service.makeBaseEmail(addresses, null, 'Test Subject');
		emails.add(email);

		Email_Service.send(emails);
		System.assertEquals(1, Email_Service.testEmails.size());

		Email_Service.send(Email_Service.makeBaseEmail(addresses, null, 'Test Subject2'));
		System.assertEquals(2, Email_Service.testEmails.size());
	}

	@IsTest
	static void test_sendTemplateEmail() {
		insert new EmailTemplate(
			isActive = true,
			FolderId = UserInfo.getUserId(),
			Name = EMAILTEMPLATE_NAME,
			DeveloperName = EMAILTEMPLATE_DEVELOPER_NAME,
			TemplateType = 'text',
			Subject = 'Test Subject',
			Body = EMAILTEMPLATE_BODY
		);

		List<String> addresses = new List<String>{ 'fake@bbsi.zzz' };
		Email_Service.sendTemplateEmail(addresses, null, EMAILTEMPLATE_DEVELOPER_NAME, null, null);

		System.assertEquals(1, Email_Service.testEmails.size());
	}

	@IsTest
	static void test_getEmailTemplateId() {
		EmailTemplate template = new EmailTemplate(
			isActive = true,
			FolderId = UserInfo.getUserId(),
			Name = EMAILTEMPLATE_NAME,
			DeveloperName = EMAILTEMPLATE_DEVELOPER_NAME,
			TemplateType = 'text',
			Subject = 'Test Subject',
			Body = EMAILTEMPLATE_BODY
		);
		insert template;

		Test.startTest();

		Id idTemplate = Email_Service.getEmailTemplateId(EMAILTEMPLATE_DEVELOPER_NAME);

		Test.stopTest();

		System.assertEquals(template.Id, idTemplate);
	}

	@IsTest
	static void test_buildHtmlEmail() {
		loadData();

		List<String> addresses = new List<String>{ 'fake@bbsi.zzz' };
		Messaging.SingleEmailMessage email = Email_Service.buildPlainEmail(addresses, null, 'HTML', '<b>HTML</b>');

		System.assertEquals(Email_Service.DEFAULT_SENDER, email.getSenderDisplayName());
		System.assert(email.getSubject().endsWith('HTML'));
	}

	@IsTest
	static void test_sendPlainEmail() {
		/* insert new EmailTemplate(
			isActive = true,
			FolderId = UserInfo.getUserId(),
			Name = EMAILTEMPLATE_NAME,
			DeveloperName = EMAILTEMPLATE_DEVELOPER_NAME,
			TemplateType = 'text',
			Subject = 'Test Subject',
			Body = EMAILTEMPLATE_BODY
		); */

		List<String> addresses = new List<String>{ 'fake@bbsi.zzz' };
		Email_Service.sendPlainEmail(addresses, null, 'PLAIN', 'Plain Text');

		System.assertEquals(1, Email_Service.testEmails.size());
	}

	@IsTest
	static void test_buildPlainEmail() {
		loadData();

		List<String> addresses = new List<String>{ 'fake@bbsi.zzz' };
		Messaging.SingleEmailMessage email = Email_Service.buildPlainEmail(addresses, null, 'PLAIN', 'Plain Text');

		System.assertEquals(Email_Service.DEFAULT_SENDER, email.getSenderDisplayName());
		System.assert(email.getSubject().endsWith('PLAIN'));
		System.assertEquals('Plain Text', email.getPlainTextBody());
	}

	@IsTest
	static void test_getEmailAddressesWithPermissionSet() {
		loadData();

		User userSA = [SELECT Id FROM User WHERE Email = 'admin@bbsi.zzz'];
		System.assertNotEquals(null, userSA);

		PermissionSet ps = [SELECT Id, Name, Label FROM PermissionSet LIMIT 1];

		insert new PermissionSetAssignment(
			PermissionSetId = ps.Id,
			AssigneeId = userSA.Id
		);

		List<String> addresses;

		addresses = Email_Service.getEmailAddressesWithPermissionSet(new List<String>{ ps.Name });
		System.assert(addresses.contains('admin@bbsi.zzz'));

		addresses = Email_Service.getEmailAddressesWithPermissionSet(new List<String>{ ps.Label });
		System.assert(addresses.contains('admin@bbsi.zzz'));
	}

	@IsTest
	static void test_LogError() {
		Messaging.SingleEmailMessage email = EMail_Service.buildPlainEmail(
			new List<String>{ 'test@bbsi.zzz' },
			null,
			'Plain',
			'Nothing'
		);

		DateTime now = DateTime.now();

		Email_Service.logError(new IllegalArgumentException('error'), new List<Messaging.SingleEmailMessage>{ email });

		List<Log__c> logs = Log_Test.recentLogs(now);

		System.assertEquals(1, logs.size(), 'A log should have been written');
		Log__c log = logs.get(0);
		System.assertEquals('send', log.Subject__c, 'Wrong Subject');
	}
}