/**
 * @description MassEmail_Batch sends the emails from a CSV file.
 */
public without sharing class MassEmailSend {
	@TestVisible
	private static final String FORMAT_INFO_SEND_EMAILS =
		'MassEmailController.sendEmails() Parameters:' +
		'\n FILE ID: {0}' +
		'\n TEMPLATE ID: {1}' +
		'\n PERSONS SIZE: {2}' +
		'\n SENDER: {3}' +
		'\n CARBON COPY: {4}';

	private static final String FORMAT_LOG_RECORD =
		'MASS EMAIL' +
		'\nHISTORY ID: {0}' +
		'\nEMAIL TEMPLATE: ({1}) + {2}' +
		'\nNUMBER SENT: {3}' +
		'\nNUMBER FAILED: {4}' +
		'\nEMAIL: LIMIT: {5}  PRE: {6}  POST: {7}';

	private static final String FORMAT_RESULT_SUBJECT = 'Mass Email Results for: {0}';
	private static final String FORMAT_RESULT_EMAIL =
		'Mass Emails has finished sending the emails with template {0}' +
		'\nNumber sent: {1}' +
		'\nNumber failed: {2}' +
		'\n\nLink to Mass Email History: {3}';

	@TestVisible
	private static final String FORMAT_SEND =
		'MassEmailSend.send() parameters:' +
		'\n HISTORY ID: {0}' +
		'\n TEMPLATE ID: {1}' +
		'\n PERSONS SIZE: {2}';

	private static final String RESULT_FILE_NAME = 'MassEmail_Results.csv';
	private static final String RESULT_FILE_TITLE = 'MassEmailResult';

	private static final String FORMAT_CSV_TOP_LINES =
		'MASS EMAIL Sent On: {0}' +
		'\nEMAIL TEMPLATE: {2} ({1})' +
		'\nCount Sent: {3}' +
		'\nCount Failed: {4}' +
		'\n\n';

	@TestVisible
	private static final String FORMAT_CSV_HEADER = 'AccountId,AccountName,ContactId,ContactName,ContactEmail,Sender,Status';
	private static final String FORMAT_CSV_LINE = '\n{0},{1},{2},{3},{4},{5},{6}';

	@TestVisible
	private static final String FAILED_EXPLAINATION = '\nNOT SENT may be caused by missing email address';

	@TestVisible
	private Integer preEmailsSent = 0;
	@TestVisible
	private Integer postEmailsSent = 0;

	@TestVisible
	private Mass_Email_History__c history;

	@TestVisible
	private Id idFile;

	@TestVisible
	private EmailTemplate template;

	@TestVisible
	private String addToSubject = '';

	@TestVisible
	private String message = '';

	@TestVisible
	private List<MassEmailPerson> persons;

	@TestVisible
	private String fromType;

	@TestVisible
	private String typeFile;

	@TestVisible
	private List<String> carbonCopy;

	@TestVisible
	private List<MassEmailPerson> sendPersons = new List<MassEmailPerson>();

	@TestVisible
	private List<MassEmailPerson> sent = new List<MassEmailPerson>();

	@TestVisible
	private List<MassEmailPerson> failed = new List<MassEmailPerson>();

	List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();

	/**
	 * @description send sends emails to the given list of people.
	 * @param  idTemplate  EmailTemplate identifier
	 * @param  idFile      Identifier of initial file
	 * @param  persons     Persons sending email to
	 * @param  fromType    Owner, Benefits Rep or Current User
	 * @param  typeFile    Account
	 * @param  carbonCopy  Who to Carbon Copy
	 * @return List<MassEmailPerson> of successful sends
	 */
	@SuppressWarnings('PMD.ExcessiveParameterList')
	public static List<MassEmailPerson> send(
		Id idTemplate,
		Id idFile,
		List<MassEmailPerson> persons,
		String fromType,
		String typeFile,
		List<String> carbonCopy
	) {
		if (persons.isEmpty()) {
			return new List<MassEmailPerson>();
		}

		MassEmailSend sender = new MassEmailSend(idTemplate, idFile, persons, fromType, typeFile, carbonCopy);

		sender.preSend();
		sender.sendEmails();
		sender.postSend();

		return sender.sent;
	}

	/**
	 * @description MassEmailSend constructor.
	 * @param  idTemplate  EmailTemplate identifier
	 * @param  idFile      Initial file identifier
	 * @param  persons     List of persons to send to
	 * @param  fromType    Who is shown as sender of the email
	 * @param  typeFile    Account
	 * @param  carbonCopy  Who to Carbon Copy
	 */
	@SuppressWarnings('PMD.ExcessiveParameterList')
	public MassEmailSend(
		Id idTemplate,
		Id idFile,
		List<MassEmailPerson> persons,
		String fromType,
		String typeFile,
		List<String> carbonCopy
	) {
		template = [SELECT Id, Name FROM EmailTemplate WHERE Id = :idTemplate];
		this.idFile = idFile;
		this.persons = persons;
		this.fromType = fromType;
		this.typeFile = typeFile;
		this.carbonCopy = carbonCopy;
	}

	/**
	 * @description preSend performs any action needed before the send.
	 */
	@TestVisible
	private void preSend() {
		history = insertNewHistory();

		File_Service.attachFile(history.Id, idFile, 'V');

		// Remove all which are not selected or invalid.
		List<MassEmailPerson> sendTo = new List<MassEmailPerson>();

		for (MassEmailPerson person : persons) {
			if (person.isValid()) {
				sendTo.add(person);
			} else {
				failed.add(person);
			}
		}

		persons = sendTo;
	}

	/**
	 * @description sendEmails builds and sends the emails.
	 */
	@TestVisible
	private void sendEmails() {
		preEmailsSent = Limits.getEmailInvocations();
		System.debug(LoggingLevel.INFO, 'Total emails sent before Mass Email: ' + preEmailsSent);

		try {
			List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

			attachments = getAttachments();

			for (MassEmailPerson person : persons) {
				if (!String.isBlank(person.idPerson)) {
					person.dump(LoggingLevel.FINE);

					Messaging.SingleEmailMessage email = buildEmail(person);

					List<String> cc = determineCarbonCopy(person);

					if (!cc.isEmpty()) {
						email.setCcAddresses(cc);
					}

					Id idAddress = Email_Service.getOrgWideEmailAddressId('BBSI Benefits');
					System.debug(LoggingLevel.FINE, 'OrgWide Email Address Id: ' + idAddress);
					email.setOrgWideEmailAddressId(idAddress);

					switch on fromType {
						when 'Account Owner' {
							//email.setSenderDisplayName(person.nameOwner);
							email.setReplyTo(person.emailOwner);

							System.debug(
								LoggingLevel.DEBUG,
								'Reply To: Account Owner: ' +
								person.nameOwner +
								'  -  ' +
								person.emailOwner
							);
						}
						when 'Benefits Representative' {
							if (String.isNotBlank(person.nameBenefitsRep)) {
								//email.setSenderDisplayName(person.nameBenefitsRep);
								email.setReplyTo(person.emailBenefitsRep);

								System.debug(
									LoggingLevel.DEBUG,
									'Reply To: Benefits Representative: ' +
									person.nameBenefitsRep +
									'  -  ' +
									person.emailBenefitsRep
								);
							} else {
								person.status = 'Missing Benefits Representative';
								failed.add(person);
								continue;
							}
						}
						when else {
							// Send from current user
							email.setReplyTo(UserInfo.getUserEmail());

							System.debug(
								LoggingLevel.FINE,
								'Reply To: Current User: ' +
								UserInfo.getName() +
								'  -  ' +
								UserInfo.getUserEmail()
							);
						}
					}

					emails.add(email);
					sendPersons.add(person);

					history.Email_Subject__c = email.getSubject();

					person.emailSubject = email.getSubject();
					person.emailBody = email.getHtmlBody();
				} else {
					person.status = 'Failed: Missing Person Id';
					failed.add(person);
				}
			}

			if (Email_Service.send(emails)) {
				message = 'Success';
				sent.addAll(sendPersons);
			} else {
				message = 'Failed to send';
				failed.addAll(sendPersons);
			}
		} catch (Exception e) {
			message = 'Failed to send due to exception: ' + e.getMessage();
			failed.addAll(sendPersons);
		}

		postEmailsSent = Limits.getEmailInvocations();
		System.debug(LoggingLevel.INFO, 'Total emails sent after Mass Email: ' + postEmailsSent);
	}

	@TestVisible
	private void postSend() {
		history.Status__c = 'COMPLETE';
		history.Number_Sent__c = sent.size();
		history.Number_Failed__c = failed.size();
		update history;

		Log.history(
			'MassEmailSend',
			'Send',
			String.format(
				FORMAT_LOG_RECORD,
				new List<String>{
					history.Id,
					history.Email_Template_Id__c,
					history.Email_Template__c,
					String.valueOf(Integer.valueOf(history.Number_Sent__c)),
					String.valueOf(Integer.valueOf(history.Number_Failed__c)),
					String.valueOf(Limits.getLimitEmailInvocations()),
					String.valueOf(preEmailsSent),
					String.valueOf(postEmailsSent)
				}
			)
		);

		Id idDocument = buildResultsDocument(template.Name, history);

		sendResultsEmail(idDocument, template.Name, history);
	}

	/**
	 * @description buildEmail builds an email by first rendering the template, then adjusting
	 * the subject and body.
	 * @param person
	 * @return An email
	 */
	@TestVisible
	private Messaging.SingleEmailMessage buildEmail(MassEmailPerson person) {
		Messaging.SingleEmailMessage emailSample = Messaging.renderStoredEmailTemplate(
			template.Id,
			person.idPerson,
			person.idAccount
		);

		if (!String.isBlank(addToSubject)) {
			String subject = emailSample.getSubject() + ' ' + addToSubject;
			emailSample.setSubject(subject);
		}

		emailSample.setToAddresses(new List<String>{ person.emailPerson });
		emailSample.setFileAttachments(attachments);
		emailSample.saveAsActivity = true;

		return emailSample;
	}

	/**
	 * @description buildResultDocument creates the Document attached to the history record containing
	 * information on how the send faired.
	 * @param  nameTemplate  Email Template used in send
	 * @param  history       Information about the send
	 * @return Idenifier of the created Document
	 */
	@TestVisible
	private Id buildResultsDocument(String nameTemplate, Mass_Email_History__c history) {
		String text = buildResultsTable();

		return File_Service.createfile(history.Id, RESULT_FILE_NAME, RESULT_FILE_TITLE, Blob.valueOf(text));
	}

	@TestVisible
	private void sendResultsEmail(Id idDocument, String nameTemplate, Mass_Email_History__c history) {
		Messaging.SingleEmailMessage email = Email_Service.buildPlainEmail(
			new List<String>{ UserInfo.getUserEmail() },
			null,
			String.format(FORMAT_RESULT_SUBJECT, new List<String>{ nameTemplate }),
			String.format(
				FORMAT_RESULT_EMAIL,
				new List<String>{
					nameTemplate,
					String.valueOf(Integer.valueOf(history.Number_Sent__c)),
					String.valueOf(Integer.valueOf(history.Number_Failed__c)),
					URL.getSalesforceBaseUrl().toExternalForm() +
					'/' +
					history.Id
				}
			)
		);

		Email_Service.send(email);
	}

	/**
	 * @description buildResultsTable builds the text for the results file.
	 * @return Body of the result email
	 */
	@TestVisible
	private String buildResultsTable() {
		String body = String.format(
			FORMAT_CSV_TOP_LINES,
			new List<String>{
				DateTime.now().format('yyyy-MM-dd HH:mm z', userinfo.getTimeZone().toString()),
				template.Id,
				template.Name,
				String.valueOf(Integer.valueOf(sent.size())),
				String.valueOf(Integer.valueOf(failed.size()))
			}
		);

		body += FORMAT_CSV_HEADER;

		for (MassEmailPerson person : failed) {
			if (String.isBlank(person.status)) {
				person.status = 'Failed';
			}

			body += buildLine(person);
		}

		for (MassEmailPerson person : sent) {
			if (String.isBlank(person.status)) {
				person.status = 'Sent';
			}

			body += buildLine(person);
		}

		return body;
	}

	/**
	 * @description buildLine creates a single line of client data
	 * @param  person
	 * @return String
	 */
	@TestVisible
	@SuppressWarnings('PMD.ExcessiveParameterList')
	private String buildLine(MassEmailPerson person) {
		return String.format(
			FORMAT_CSV_LINE,
			new List<String>{
				person.idAccount,
				handleComma(person.nameAccount),
				person.idPerson,
				handleComma(person.namePerson),
				person.emailPerson,
				handleComma(person.nameOwner),
				handleComma(person.status)
			}
		);
	}

	private String handleComma(String text) {
		if (!String.isBlank(text)) {
			if (text.contains(',')) {
				return '"' + text + '"';
			}
		}

		return text;
	}

	/**
	 * @description insertNewHistory create and insert a new history record based on the email send.
	 * @return Mass_Email_History__c
	 */
	@TestVisible
	private Mass_Email_History__c insertNewHistory() {
		history = new Mass_Email_History__c(
			Status__c = 'SENDING',
			Produced_By__c = UserInfo.getUserId(),
			Date_Sent__c = DateTime.now(),
			Email_Subject__c = '',
			Number_Failed__c = 0,
			Number_Sent__c = 0,
			Email_Template__c = template.Name,
			Email_Template_Id__c = template.Id,
			Type_CSV__c = typeFile,
			Carbon_Copied__c = String.join(carbonCopy, ', '),
			Sent_From__c = fromType
		);

		insert history;

		return history;
	}

	/**
	 * @description determineCarbonCopy who should recieve a CC of the email
	 * @param  person  MassEmailPerson looking at
	 * @return List of email addresses
	 */
	@TestVisible
	private List<String> determineCarbonCopy(MassEmailPerson person) {
		List<String> result = new List<String>();

		for (String who : carbonCopy) {
			switch on who {
				when 'Account Owner' {
					System.debug(LoggingLevel.FINE, 'Carbon Copy: Account Owner:' + person.emailOwner);
					if (String.isNotBlank(person.emailOwner)) {
						result.add(person.emailOwner);
					}
				}
				when 'Benefits Representative' {
					System.debug(LoggingLevel.FINE, 'Carbon Copy: Benefits Representative:' + person.emailBenefitsRep);
					if (String.isNotBlank(person.emailBenefitsRep)) {
						result.add(person.emailBenefitsRep);
					}
				}
				when 'Current User' {
					System.debug(LoggingLevel.FINE, 'Carbon Copy: Current User:' + UserInfo.getUserEmail());
					result.add(UserInfo.getUserEmail());
				}
			}
		}

		return result;
	}

	/**
	 * @description getAttachments retrive the attachments from the template.
	 * @return List<Messaging.EmailFileAttachment>
	 */
	private List<Messaging.EmailFileAttachment> getAttachments() {
		List<Messaging.EmailFileAttachment> result = new List<Messaging.EmailFileAttachment>();

		List<Id> idContentDocuments = new List<id>();

		for (ContentDocumentLink cdLink : [
			SELECT ContentDocumentId
			FROM ContentDocumentLink
			WHERE LinkedEntityId = :template.Id
		]) {
			idContentDocuments.add(cdLink.ContentDocumentId);
		}

		String filename;

		for (ContentVersion version : [
			SELECT Title, FileType, FileExtension, VersionData
			FROM ContentVersion
			WHERE ContentDocumentId IN :idContentDocuments
		]) {
			filename = version.Title + '.' + version.FileExtension;
			System.debug(LoggingLevel.DEBUG, 'Attachment Filename: ' + filename);

			Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
			efa.setBody((Blob) version.VersionData);
			efa.setFileName(filename);

			result.add(efa);
		}

		return result;
	}
}