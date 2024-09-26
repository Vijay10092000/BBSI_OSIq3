/**
 * @description Email_Service
 */
public with sharing class Email_Service {
	@TestVisible
	private static final String DEFAULT_SENDER = 'BBSI Salesforce';
	@TestVisible
	private static final String NO_REPLY_EMAIL = 'no-reply@bbsi.com';

	@TestVisible
	private static final String FORMAT_FORMATED_EMAIL_BODY =
		'<html>' +
		' <head><style>p \'{\' color:#134597;\'}\' h4 \'{\' color:#134597;\'}\' hr \'{\' color:#6E95D6; \'}\'</style></head>' +
		' <hr/><h4><em>BBSI: Salesforce Automated Email </em></h4>' +
		' <hr/><p>{0}</p>' +
		' <hr/><font size="2"><p>This is an automated message from Salesforce</p></font>' +
		'</html>';

	private static Map<String, Id> mapTemplateIds = new Map<String, Id>();

	@TestVisible
	private static List<Messaging.Email> testEmails = new List<Messaging.Email>();

	/**
	 * @description send sends the given emails.
	 * @param  emails List of emails to send
	 * @return true if sent
	 */
	@SuppressWarnings('PMD.AvoidSystemDebugUsage')
	public static Boolean send(List<Messaging.SingleEmailMessage> emails) {
		if (emails == null || emails.isEmpty()) {
			return true;
		}

		try {
			if (Test.isRunningTest()) {
				String debug = 'Email_Service.send()';
				for (Messaging.SingleEmailMessage e : emails) {
					debug += '\nEmail: ' + e.getSubject();
				}
				System.debug(LoggingLevel.DEBUG, debug);
				testEmails.addAll(emails);
			} else {
				Messaging.sendEmail(emails);
			}
		} catch (Exception e) {
			logError(e, emails);
			return false;
		}
		return true;
	}

	/**
	 * @description send sends the given email.
	 * @param  email The Email to send
	 * @return true if sent
	 */
	public static Boolean send(Messaging.SingleEmailMessage email) {
		return send(new List<Messaging.SingleEmailMessage>{ email });
	}

	/**
	 * @description sendTemplateEmail sends an email using a template.
	 * @param  listTo        Addresses To
	 * @param  listCc        Carbon copy addresses
	 * @param  nameTemplate  Name of the template to use
	 * @param  idTarget      Target object of the tempalte
	 * @param  idWhat        What object of the template
	 */
    @SuppressWarnings('PMD.ExcessiveParameterList')
	public static void sendTemplateEmail(
        List<String> listTo,
        List<String> listCc,
        String nameTemplate,
        Id idTarget,
        Id idWhat
    ) {
		send( buildTemplateEmail(listTo, listCc, nameTemplate, idTarget, idWhat) );
	}

	/**
	 * @description sendPlainEmail creates a plain text email and sends it
	 * @param  listTo  list of email addresses mailing to
	 * @param  listCc  Carbon copy list of email addresses
	 * @param  subject Email subject
	 * @param  text    Email Text
	 */
	public static void sendPlainEmail(
		List<String> listTo,
		List<String> listCc,
		String subject,
		String text
	) {
		send(buildPlainEmail(listTo, listCC, subject, text));
	}

	/**
	 * @description buildPlainEmail creates a Plain text email
	 * @param  listTo  list of email addresses mailing to
	 * @param  listCc  Carbon copy list of email addresses
	 * @param  subject Email subject
	 * @param  body    Email Text
	 * @return The created Messaging.SingleEmailMessage
	 */
	public static Messaging.SingleEmailMessage buildPlainEmail(
		List<String> listTo,
		List<String> listCc,
		String subject,
		String body
	) {
		Messaging.SingleEmailMessage email = makeBaseEmail(listTo, listCc, subject);
		email.setPlainTextBody(body);

		return email;
	}

	/**
	 * @description buildTemplateEmail creates an email using a template.
	 * @param  listTo        Addresses To
	 * @param  listCc        Carbon copy addresses
	 * @param  nameTemplate  Name of the template to use
	 * @param  idTarget      Target object of the tempalte
	 * @param  idWhat        What object of the template
	 * @return Email
	 */
	public static Messaging.SingleEmailMessage buildTemplateEmail(
		List<String> listTo,
		List<String> listCc,
		String nameTemplate,
		Id idTarget,
		Id idWhat
	) {
		return buildTemplateEmail(
			listTo,
			listCc,
			getEmailTemplateId(nameTemplate),
			idTarget,
			idWhat
		);
	}

	/**
	 * @description buildTemplateEmail creates an email using a template.
	 * @param  listTo      ddresses To
	 * @param  listCc      Carbon copy addresses
	 * @param  idTemplate  Id of the template to use
	 * @param  idTarget    Target object of the tempalte
	 * @param  idWhat      What object of the template
	 * @return Email
	 */
	public static Messaging.SingleEmailMessage buildTemplateEmail(
		List<String> listTo,
		List<String> listCc,
		Id idTemplate,
		Id idTarget,
		Id idWhat
	) {
		Messaging.SingleEmailMessage emailSample = Messaging.renderStoredEmailTemplate(idTemplate, idTarget, idWhat);

		Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
		email.setToAddresses(listTo);
		email.setCcAddresses(listCc);
		email.setSubject(emailSample.getSubject());
		email.setHtmlBody(emailSample.getHtmlBody());
		email.saveAsActivity = false;

		return email;
	}

	@TestVisible
	private static Messaging.SingleEmailMessage makeBaseEmail(List<String> listTo, List<String> listCc, String subject) {
        if (Organization_Service.isSandbox()) {
            subject = Organization_Service.getSandboxName() + ': ' + subject;
        }

		Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
		email.setSenderDisplayName(DEFAULT_SENDER);
		email.setReplyTo(NO_REPLY_EMAIL);
		email.setUseSignature(false);
		email.setBccSender(false);
		email.setSaveAsActivity(false);

		email.setToAddresses(listTo);
		email.setCcAddresses(listCc);
		email.setSubject(subject);
		return email;
	}

	/**
	 * @description getEmailAddressesWithPermissionSet retrieves email addresses of all users
	 * with the given permission sets.
	 * @param  namePermissionSets List of Permission Set names
	 * @return Email Addresses of users
	 */
	public static List<String> getEmailAddressesWithPermissionSet(List<String> namePermissionSets) {
		List<String> addresses = new List<String>();

		for (PermissionSetAssignment psa : [
			SELECT AssigneeId, Assignee.Email
			FROM PermissionSetAssignment
			WHERE PermissionSet.Name IN :namePermissionSets
			OR PermissionSet.Label IN :namePermissionSets
		]) {
			addresses.add(psa.Assignee.Email);
		}

		return addresses;
	}

	/**
	 * @description getEmailAddressesWithCustomPermission retrieves email addresses of all users
	 * with the given custom permissions.
	 * @param  nameCustomPermissions List of Custom Permissions Set names
	 * @return Email Addresses of users
	 */
	/** TODO: FIX
	public static List<String> getEmailAddressesWithCustomPermission(List<String> nameCustomPermissions) {
		List<String> addresses = new List<String>();

		for (PermissionSetAssignment psa : [
			SELECT AssigneeId, Assignee.Email
			FROM PermissionSetAssignment
			WHERE PermissionSet.Name IN :nameCustomPermissions
			OR PermissionSet.Label IN :nameCustomPermissions
		]) {
			addresses.add(psa.Assignee.Email);
		}

		return addresses;
	}
	*/

	/**
	 * @description getGroupEmailAddresses retrieves the email addresses of the members
	 * of the given group.
	 * @param  nameGroup         Group getting email addresses for
	 * @param  includeSubGroups  Should sub groups be included?
	 * @return List of email addresses
	 */
	@SuppressWarnings('PMD.OperationWithLimitsInLoop')
	public static List<String> getGroupEmailAddresses(String nameGroup, Boolean includeSubGroups) {
		List<String> emails = new List<String>();
		List<Group> foundGroups = [SELECT Id FROM Group WHERE Name = :nameGroup];

		if (!foundGroups.isEmpty()) {
			Set<Id> idGroups = new Set<Id>();
			Set<Id> idSubGroups = new Set<Id>();
			Set<Id> idUsers = new Set<Id>();

			idGroups.add(foundGroups.get(0).Id);

			while (!idGroups.isEmpty()) {
				for (GroupMember gm : [SELECT UserOrGroupID FROM GroupMember WHERE groupId IN :idGroups]) {
					String nameType = gm.UserOrGroupId.getSobjectType().getDescribe().getLabel();
					if (nameType == 'Group') {
						idSubGroups.add(gm.UserOrGroupId);
					} else if (nameType == 'User') {
						idUsers.add(gm.UserOrGroupId);
					}
				}

				idGroups.clear();
				if (includeSubGroups) {
					idGroups.addAll(idSubGroups);
					idSubGroups.clear();
				}
			}

			for (User u : [SELECT Email FROM User WHERE IsActive = TRUE AND Id IN :idUsers]) {
				emails.add(u.Email);
			}
		}

		return emails;
	}

	/**
	 * @description getEmailTemplateId retrieves the Id of the Email Template given the name.
	 * Ids are saved so calls to get the templates are queried only once.
	 * @param  nameTemplate  DeveloperName of the Template looking for
	 * @return Id of the Template
	 */
	public static Id getEmailTemplateId(String nameTemplate) {
		if (!mapTemplateIds.containsKey(nameTemplate)) {
            EmailTemplate template = [
                SELECT Id
                FROM EmailTemplate
                WHERE DeveloperName = :nameTemplate
                LIMIT 1
            ];

			mapTemplateIds.put(nameTemplate, template.Id);
        }

		return mapTemplateIds.get(nameTemplate);
	}

	/**
	 * @description logError logs the error to the Log table
	 * @param  e      Exception
	 * @param  emails Failing emails
	 */
	@TestVisible
	private static void logError(Exception e, List<Messaging.SingleEmailMessage> emails) {
		String additional = '\n\nEMAIL SUBJECTS';

		Integer count = 0;
		for (Messaging.SingleEmailMessage email : emails) {
			additional += String.valueOf(count) + ': ' + email.getSubject();
			++count;
		}

		Log.error('Email_Service', 'send', additional, e);
	}

	/**
	 * @description getOrgWideEmailAddressId retrieves the identifier for the given
	 * Org-Wide Email Address name.
	 * @param  name  Name of the Org-Wide Email Address
	 * @return Id if found, null if not
	 */
	public static Id getOrgWideEmailAddressId(String name) {
		Id result = null;

		try {
			OrgWideEmailAddress owea = [
				SELECT Id, Address, DisplayName, IsAllowAllProfiles
				FROM OrgWideEmailAddress
				WHERE DisplayName = :name
			];

			result = owea.Id;
		} catch (Exception e) {
			System.debug(LoggingLevel.WARN, 'OrgWideEmailAddress Id not found for: ' + name);
		}

		return result;
	}
}

/*
SELECT Id, Address, DisplayName, IsAllowAllProfiles
FROM OrgWideEmailAddress
WHERE DisplayName = 'BBSI Benefits'
*/