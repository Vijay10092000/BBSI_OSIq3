/**
 * @description MassEmailCsvFile
 */
public with sharing class MassEmailCsvFile {
	public List<MassEmailPerson> persons;
	public String typeFile;

	/**
	 * @description MassEmailReadCsv constructor.
	 */
	@TestVisible
	@SuppressWarnings('PMD.EmptyStatementBlock')
	private MassEmailCsvFile() {
	}

	/**
	 * @description MassEmailCsvFile constructor.
	 * @param  mapCsv  Row-Column to value map within map
	 */
	public MassEmailCsvFile(Map<Integer, Map<Integer, String>> mapCsv) {
		extractData(mapCsv);
	}

	/**
	 * @description MassEmailCsvFile constructor.
	 * @param  idFile File to read
	 */
	public MassEmailCsvFile(Id idFile) {
		extractData(readCsvFile(idFile));
	}

	/**
	 * @description readCsvFile reads the data from the file.
	 * @param  idFile File to read
	 * @return Csv file as Map<Integer, Map<Integer, String>>
	 */
	@TestVisible
	private Map<Integer, Map<Integer, String>> readCsvFile(Id idFile) {
		return Csv_Service.readAsMatrix(File_Service.read(idFile));
	}

	/**
	 * @description extractData determines type of data and extracts it.
	 * @param  csv Data from the file
	 */
	@TestVisible
	private void extractData(Map<Integer, Map<Integer, String>> csv) {
		persons = new List<MassEmailPerson>();

		Set<Id> idAccounts = new Set<Id>();
		Set<Id> idContacts = new Set<Id>();
		Set<String> emails = new Set<String>();

		if (1 < csv.size()) {
			for (Integer row = 1; row < csv.size(); ++row) {
				Map<Integer, String> rowData = csv.get(row);

				if (rowData.size() > 0) {
					String value = rowData.get(0);

					if (value.startsWith('001')) {
						idAccounts.add(Id.valueOf(value));
					} else if (value.startsWith('003')) {
						idContacts.add(Id.valueOf(value));
					} else if (value.contains('@')) {
						emails.add(value);
					} else {
						throw new IllegalArgumentException('Invalid file.');
					}
				}
			}

			if (!idAccounts.isEmpty()) {
				typeFile = 'Account Ids';
				persons.addAll(readAccounts(idAccounts));
			} else if (!idContacts.isEmpty()) {
				typeFile = 'Contact Ids';
				persons.addAll(readContactsById(idContacts));
			} else {
				typeFile = 'Contact Email Addresses';
				persons.addAll(readContactsByEmail(emails));
			}
		}
	}

	/**
	 * @description readAccounts reads the Account information for the component.
	 * @param  idAccounts  Account identifiers
	 * @return List of MassEmailPerson
	 */
	@TestVisible
	private List<MassEmailPerson> readAccounts(Set<Id> idAccounts) {
		Map<Id, MassEmailPerson> persons = new Map<Id, MassEmailPerson>();

		Map<String, Contact> mapEmailToContacts = new Map<String, Contact>();

		for (Contact contact : [SELECT Id, Name, Email, AccountId FROM Contact WHERE AccountId IN :idAccounts]) {
			mapEmailToContacts.put(contact.Email, contact);
		}

		if (!idAccounts.isEmpty()) {
			Integer count = 0;

			for (Account a : [
				SELECT
					Id,
					Name,
					RecordType.Name,
					Primary_Contact_Name__c,
					Primary_Contact_Email__c,
					OwnerId,
					Owner.Name,
					Owner.Email,
					Benefits_Representative__c,
					Benefits_Representative__r.Name,
					Benefits_Representative__r.Email
				FROM Account
				WHERE Id IN :idAccounts
				ORDER BY Name ASC
			]) {
				++count;

				String idPerson = null;

				if (mapEmailToContacts.containsKey(a.Primary_Contact_Email__c)) {
					idPerson = String.valueOf(mapEmailToContacts.get(a.Primary_Contact_Email__c).Id);
				}

				MassEmailPerson person = new MassEmailPerson(
					String.valueOf(count),
					a.Id,
					a.Name,
					idPerson,
					'Contact',
					a.Primary_Contact_Name__c,
					a.Primary_Contact_Email__c,
					a.OwnerId,
					a.Owner.Name,
					a.Owner.Email,
					a.Benefits_Representative__c,
					a.Benefits_Representative__r.Name,
					a.Benefits_Representative__r.Email
				);

				persons.put(a.Id, person);
			}
		}

		return persons.values();
	}

	/**
	 * @description readContactsById reads the Contact information for the component.
	 * @param  idContacts  Contact identifiers
	 * @return List of MassEmailPerson
	 */
	@TestVisible
	private List<MassEmailPerson> readContactsById(Set<Id> idContacts) {
		Map<Id, MassEmailPerson> persons = new Map<Id, MassEmailPerson>();

		List<Contact> contacts = [
			SELECT
				Id,
				Name,
				EMail,
				AccountId,
				Account.Name,
				Account.OwnerId,
				Account.Owner.Name,
				Account.Owner.Email,
				Account.Benefits_Representative__c,
				Account.Benefits_Representative__r.Name,
				Account.Benefits_Representative__r.Email
			FROM Contact
			WHERE Id IN :idContacts
		];

		Integer count = 0;
		for (Contact c : contacts) {
			++count;

			MassEmailPerson person = new MassEmailPerson(
				String.valueOf(count),
				c.AccountId,
				c.Account.Name,
				c.Id,
				'Contact',
				c.Name,
				c.Email,
				c.Account.OwnerId,
				c.Account.Owner.Name,
				c.Account.Owner.Email,
				c.Account.Benefits_Representative__c,
				c.Account.Benefits_Representative__r.Name,
				c.Account.Benefits_Representative__r.Email
			);

			persons.put(c.AccountId, person);
		}

		return persons.values();
	}

	/**
	 * @description readContactsByEmail reads the Contact information for the component.
	 * @param  emailContacts  Contact email addresses
	 * @return List of MassEmailPerson
	 */
	@TestVisible
	private List<MassEmailPerson> readContactsByEmail(Set<String> emailContacts) {
		Map<Id, MassEmailPerson> persons = new Map<Id, MassEmailPerson>();

		List<Contact> contacts = [
			SELECT
				Id,
				Name,
				EMail,
				AccountId,
				Account.Name,
				Account.OwnerId,
				Account.Owner.Name,
				Account.Owner.Email,
				Account.Benefits_Representative__c,
				Account.Benefits_Representative__r.Name,
				Account.Benefits_Representative__r.Email
			FROM Contact
			WHERE EMail IN :emailContacts
		];

		Integer count = 0;
		for (Contact c : contacts) {
			++count;

			MassEmailPerson person = new MassEmailPerson(
				String.valueOf(count),
				c.AccountId,
				c.Account.Name,
				c.Id,
				'Contact',
				c.Name,
				c.Email,
				c.Account.OwnerId,
				c.Account.Owner.Name,
				c.Account.Owner.Email,
				c.Account.Benefits_Representative__c,
				c.Account.Benefits_Representative__r.Name,
				c.Account.Benefits_Representative__r.Email
			);

			persons.put(c.AccountId, person);
		}

		return persons.values();
	}
}