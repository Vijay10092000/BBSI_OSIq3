/**
 * @description ContactPrimary handles changes to an Account's Primary Contact.
 */
public without sharing class ContactPrimary {
	/**
	 * @description checkForDuplicatePrimaryContacts checks if an new Contact is being
	 * set as a Primary on an Account when one already exists.  Add an error message
	 * to the Primary__c field if so.
	 * @param  mapOldContacts  Map if Contacts before change
	 * @param  newContacts     List of Contacts with changes
	 */
	public static void checkForDuplicatePrimaryContacts(Map<Id, Contact> mapOldContacts, List<Contact> newContacts) {
		Set<Contact> workingContacts = new Set<Contact>();
		Set<Id> idAccounts = new Set<Id>();

		// Check all Contacts for change to Primary flag to true
		for (Contact contact : newContacts) {
			if (contact.Primary__c) {
				if (mapOldContacts == null || !mapOldContacts.get(contact.Id).Primary__c) {
					workingContacts.add(contact);
					idAccounts.add(contact.AccountId);
				}
			}
		}

		if (!workingContacts.isEmpty() && !idAccounts.isEmpty()) {
			Map<Id, Contact> mapAccountToPrimary = queryPrimaryContacts(idAccounts);

			for (Contact contact : workingContacts) {
				if (mapAccountToPrimary.containsKey(contact.AccountId)) {
					if (contact.Id != mapAccountToPrimary.get(contact.AccountId).Id) {
						contact.Primary__c.addError('There is already a Primary Contact for this Account.');
					}
				}
			}
		}
	}

	/**
	 * @description updatePrimaryContacts determines the Primary Contacts which have
	 * changed and updates the related Account.
	 * @param  mapOld   Map if Contacts before change
	 * @param  listNew  List of Contacts with changes
	 */
	public static void updatePrimaryContacts(Map<Id, Contact> mapOld, List<Contact> listNew) {
		Map<Id, Contact> primaryContacts = modifiedPrimaryContacts(mapOld, listNew);

		if (!primaryContacts.isEmpty()) {
			updateAccountPrimary(primaryContacts);
		}
	}

	/**
	 * @description modifiedPrimaryContacts creates a Map relating the changed Primary Account
	 * to the Primary Contact data.
	 * @param  mapOld   Map if Contacts before change
	 * @param  listNew  List of Contacts with changes
	 * @return Map<Id, Contact>
	 */
	private static Map<Id, Contact> modifiedPrimaryContacts(Map<Id, Contact> mapOld, List<Contact> listNew) {
		Map<Id, Contact> primaryContacts = new Map<Id, Contact>();

		for (Contact contact : listNew) {
			if (!contact.Primary__c) {
				continue;
			}

			if (mapOld == null) {
				primaryContacts.put(contact.AccountId, contact);
			} else {
				if (changesMade(mapOld.get(contact.Id), contact)) {
					primaryContacts.put(contact.AccountId, contact);
				}
			}
		}

		return primaryContacts;
	}

	/**
	 * @description changesMade determines if a Primary Contact change has been made to a Contact.
	 * @param  oldContact  Contact before changes
	 * @param  newContact  Contact with changes
	 * @return Boolean
	 */
	@TestVisible
	private static Boolean changesMade(Contact oldContact, Contact newContact) {
		return newContact.Primary__c != oldContact.Primary__c ||
			newContact.FirstName != oldContact.FirstName ||
			newContact.LastName != oldContact.LastName ||
			newContact.Email != oldContact.Email ||
			newContact.Phone != oldContact.Phone ||
			newContact.MobilePhone != oldContact.MobilePhone ||
			newContact.Direct__c != oldContact.Direct__c ||
			newContact.Direct_Extension__c != oldContact.Direct_Extension__c;
	}

	/**
	 * @description updateAccountPrimary updates the Accounts from the changed Primary Contacts.
	 * @param  primaryContacts  Map of changed Primary Contacts
	 */
	private static void updateAccountPrimary(Map<Id, Contact> primaryContacts) {
		Map<Id, Account> updateAccounts = queryAccounts(primaryContacts.keySet());

		for (Contact c : PrimaryContacts.values()) {
			if (updateAccounts.containsKey(c.accountId)) {
				updateAccounts.get(c.AccountId).Primary_Contact_Name__c = makeFullname(c.FirstName, c.LastName);
				updateAccounts.get(c.AccountId).Primary_Contact_Email__c = c.Email;
				updateAccounts.get(c.AccountId).Primary_Contact_Direct__c = c.Direct__c;
				updateAccounts.get(c.AccountId).Primary_Contact_Direct_Extension__c = c.Direct_Extension__c;
				updateAccounts.get(c.AccountId).Primary_Contact_Phone__c = c.Phone;
				updateAccounts.get(c.AccountId).Primary_Contact_Mobile__c = c.MobilePhone;
			}
		}

		if (!updateAccounts.isEmpty()) {
			update updateAccounts.values();
		}
	}

	/**
	 * @description queryAccounts retrieves Primary Contact information for the given Account Ids.
	 * @param  idAccounts  Set of Account Ids
	 * @return Map of Accounts
	 */
	private static Map<Id, Account> queryAccounts(Set<Id> idAccounts) {
		return new Map<Id, Account>(
			[
				SELECT
					Id,
					Name,
					Primary_Contact_Name__c,
					Primary_Contact_Direct__c,
					Primary_Contact_Direct_Extension__c,
					Primary_Contact_Email__c,
					Primary_Contact_Phone__c,
					Primary_Contact_Mobile__c
				FROM Account
				WHERE Id IN :idAccounts
			]
		);
	}

	/**
	 * @description queryPrimaryContacts retrieves a Map relating the Account Ids
	 * to their related Primary Contact.
	 * @param  idAccounts  Set of Account Ids
	 * @return Map<Id, Contact>
	 */
	private static Map<Id, Contact> queryPrimaryContacts(Set<Id> idAccounts) {
		Map<Id, Contact> mapAccountIdToPrimary = new Map<Id, Contact>();

		List<Contact> primaries = [
			SELECT Id, AccountId, Name, Primary__c
			FROM Contact
			WHERE AccountId IN :idAccounts AND Primary__c = TRUE
		];

		for (Contact contact : primaries) {
			mapAccountIdToPrimary.put(contact.AccountId, contact);
		}

		return mapAccountIdToPrimary;
	}

	/**
	 * @description makeFullname creates a name.
	 * @param  firstname  First name
	 * @param  lastname   Last name
	 * @return Combined Name
	 */
	private static String makeFullname(string firstname, string lastname) {
		String fullname = '';

		if (firstname != null) {
			fullname += firstname + ' ';
		}

		if (lastname != null) {
			fullname += lastname;
		}

		return fullname.trim();
	}
}