/**
 * @description MassEmailController handles the server side calls from the Email Sender component.
 *
 *    | Type          | Code | File Description                                                   |
 *    |---------------|------|--------------------------------------------------------------------|
 *    | AccountId     |  001 | First column is the Account Id.  Second column may have overriding |
 *    |               |      | Contact Emails.  If no override, then Primary Contact is used.     |
 *    | ContactId     |  003 | Single column of Contact Ids                                       |
 *    | Email Address |      | Single column of Contact email addresses.                          |
 */
public without sharing class MassEmailController {
	/**
	 * @description DataResult handles initialization data for the MassEmail component.
	 */
	public without sharing class DataResult {
		/**
		 * @description optionFolders
		 */
		@AuraEnabled
		public List<Option> optionFolders { get; private set; }

		/**
		 * @description optionTemplates is the available Email Templates
		 */
		@AuraEnabled
		public List<Option> optionTemplates { get; private set; }

		/**
		 * @description typeFile type of CSV file read
		 */
		@AuraEnabled
		public String typeFile { get; private set; }

		/**
		 * @description idFile is the identifier of the file read.
		 */
		@AuraEnabled
		public String idFile { get; private set; }

		/**
		 * @description persons is the list of Leads or Contacts for emails
		 */
		@AuraEnabled
		public List<MassEmailPerson> persons { get; private set; }
	}

	/**
	 * @description setup determines the data needed for opening the component.
	 * @return DataResult containing requested data
	 */
	@AuraEnabled
	public static DataResult setup() {
		try {
			DataResult dr = new DataResult();
			dr.optionFolders = getEmailFolders();
			return dr;
		} catch (Exception e) {
			System.debug(LoggingLevel.ERROR, 'MassEmailController.setup Exception: ' + e);
			throw new AuraHandledException(e.getMessage());
		}
	}

	/**
	 * @description readFolder reads the email templates for the given folder id.
	 * @param idFolder  Folder reading
	 * @return DataResult containing requested data
	 */
	@AuraEnabled
	public static DataResult readFolder(String idFolder) {
		try {
			DataResult dr = new DataResult();
			dr.optionTemplates = getEmailTemplates(idFolder);
			return dr;
		} catch (Exception e) {
			System.debug(LoggingLevel.ERROR, 'MassEmailController.setup Exception: ' + e);
			throw new AuraHandledException(e.getMessage());
		}
	}

	/**
	 * @description readData determines the data needed for the component.
	 * @param  idFile  File identifier
	 * @return DataResult containing requested data
	 */
	@AuraEnabled
	public static DataResult readData(String idFile) {
		try {
			MassEmailCsvFile csvFile = new MassEmailCsvFile(idFile);

			DataResult dr = new DataResult();
			dr.persons = csvFile.persons;
			dr.typeFile = csvFile.typeFile;
			dr.idFile = idFile;
			return dr;
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	/**
	 * @description deleteFile .
	 * @param  idFile	File Id
	 */
	@AuraEnabled
	public static void deleteFile(String idFile) {
		try {
			File_Service.deleteFile(Id.valueOf(idFile));
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	/**
	 * @description sendEmails sends the emails using a batch process.
	 * @param  action      Determines the additional methods to call
	 * @param  idFile      Initial File identifier
	 * @param  idTemplate  Email Template identifier
	 * @param  sender      Owner, Benefits Rep or Current User
	 * @param  typeFile    What was in the CSV
	 * @param  carbonCopy  Who to CC on email
	 * @param  persons     Information about the persons to send to
	 * @param  selected    Records selected for email send
	 * @param  typeTask    If Task is created, type to create
	 */
	@AuraEnabled
	@SuppressWarnings('PMD.ExcessiveParameterList')
	public static void sendEmails(
		String action,
		String idFile,
		String idTemplate,
		String sender,
		String typeFile,
		List<String> carbonCopy,
		List<MassEmailPerson> persons,
		List<String> selected,
		String typeTask
	) {
		System.debug(
			LoggingLevel.INFO,
			'MassEmailController.sendEmails:' +
			'\n action: ' + action +
			'\n idFile: ' +  idFile +
			'\n idTemplate: ' +  idTemplate +
			'\n sender: ' +  sender +
			'\n typeFile: ' +  typeFile +
			'\n carbonCopy: ' +  carbonCopy +
			'\n persons: ' +  persons +
			'\n selected: ' +  selected +
			'\n typeTask: ' +  typeTask
		);

		try {
			List<MassEmailPerson> sendTo = onlySendTo(persons, selected);
			List<MassEmailPerson> sent = MassEmailSend.send(idTemplate, idFile, sendTo, sender, typeFile, carbonCopy);
			MassEmailTasks.create(sent, typeTask);
		} catch (Exception e) {
			System.debug(LoggingLevel.ERROR, 'MassEmailController.sendEmails() - EXCEPTION: ' + e);
			throw new AuraHandledException(e.getMessage());
		}
	}

	/**
	 * @description getEmailFolders retrieves all Email Template folders
	 * and builds a list of options.
	 * @return List<Option>
	 */
	@TestVisible
	public static List<Option> getEmailFolders() {
		List<Option> result = new List<Option>();

		Map<Id, Folder> mapFolders = new Map<Id, Folder>(
			[SELECT Id, Name, Type, ParentId FROM Folder WHERE Type = 'EmailTemplate']
		);

		Map<String, Id> mapNames = new Map<String, Id>();

		for (Id idFolder : mapFolders.keySet()) {
			Folder folder = mapFolders.get(idFolder);

			String name = folder.Name;

			Id idParent = folder.ParentId;

			while (idParent != null) {
				name = mapFolders.get(idParent).Name + '\\' + name;
			}

			mapNames.put(name, idFolder);
		}

		List<String> sortedKeys = new List<String>(mapNames.keySet());
		sortedKeys.sort();

		for (String name : sortedKeys) {
			result.add(new Option((String) mapNames.get(name), name, false));
		}

		return result;
	}

	/**
	 * @description getEmailTemplates retrieves all custom active EmailTemplates in the folder
	 * and builds a list of options.
	 * @param  idFolder Identifier of folder to look in
	 * @return List<Option>
	 */
	@TestVisible
	public static List<Option> getEmailTemplates(Id idFolder) {
		List<Option> result = new List<Option>();

		List<EmailTemplate> templates = [
			SELECT Id, Name, DeveloperName, Description
			FROM EmailTemplate
			WHERE FolderId = :idFolder
			AND IsActive = TRUE
// TODO: DETERMINE			AND RelatedEntityType = 'Account'
			ORDER BY Name ASC
		];

		//System.debug('TEMPATES FOUND: ' + templates.size());

		for (EmailTemplate et : templates) {
			result.add(new Option((String) et.Id, et.Name, false));
		}

		return result;
	}

	/**
	 * @description onlySendTo Removes unselected persons.
	 * @param persons   List of persons
	 * @param selected  String indices to keep
	 * @return List<MassEmailPerson>
	 */
	private static List<MassEmailPerson> onlySendTo(List<MassEmailPerson> persons, List<String> selected) {
		List<MassEmailPerson> result = new List<MassEmailPerson>();

		for (String text : selected) {
			Integer index = Integer.valueOf(text.trim()) - 1;

			result.add(persons.get(index));
		}

		return result;
	}
}