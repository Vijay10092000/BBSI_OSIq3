/**
 * @description Contact_services general methods to aid with the
 * Contact object and triggers.
 */
public with sharing class contact_services {
	/**
	 * @description setContactOwner sets the Contact Owner to the Account Owner.
	 * @param  contacts  Contacts to update
	 */
	public static void setContactOwner(List<Contact> contacts) {
		Set<Id> accountIds = new Set<Id>();

		for (Contact c : contacts) {
			accountIds.add(c.AccountId);
		}

		Map<Id, Id> ownerByAccount = new Map<Id, Id>();
		for (Account a : [SELECT Id, OwnerId FROM Account WHERE Id IN :accountIds]) {
			ownerByAccount.put(a.Id, a.OwnerId);
		}

		for (Contact c : contacts) {
			if (ownerByAccount.containsKey(c.AccountId)) {
				c.OwnerId = ownerByAccount.get(c.AccountId);
			}
		}
	}

	/**
	 * @description setPrimaryOnInsert description
	 * @param  contacts contacts description
	 */
	public static void setPrimaryOnInsert(List<Contact> contacts) {
		Map<Id, Contact> contactByAccount = new Map<Id, Contact>();
		Set<Id> multipleContacts = new Set<Id>();

		for (Contact c : contacts) {
			if (c.AccountId != null && !contactByAccount.containsKey(c.AccountId)) {
				contactByAccount.put(c.AccountId, c);
			} else {
				if (c.AccountId != null) {
					// Cannot update the primary checkbox if multiple contacts for the same account being inserted
					multipleContacts.add(c.AccountId);
				}
			}
		}

		if (multipleContacts.size() > 0) {
			for (Id acctId : multipleContacts) {
				// Remove any that were multiples before updating primary__c
				contactByAccount.remove(acctId);
			}
		}

		if (contactByAccount.size() > 0) {
			setPrimary(contacts, contactByAccount);
		}
	}

	/**
	 * @description setPrimary sets the contact to primary if there are
	 * no other contacts on the account.
	 * @param  contacts         List of contacts testing
	 * @param  contactByAccount Mapped account to Contact
	 */
	@TestVisible
	private static void setPrimary(List<Contact> contacts, Map<id, Contact> contactByAccount) {
		if (!contactByAccount.isEmpty()) {
			Map<Id, Integer> mapAccoutToCount = Account_Services.getContactCount(contactByAccount.keyset());

			for (Contact c : contactByAccount.values()) {
				if (!mapAccoutToCount.containsKey(c.AccountId) || mapAccoutToCount.get(c.AccountId) == 0) {
					c.Primary__c = true;
				}
			}
		}
	}

	/**
	 * @description updateUserAcronym if BDM Acronym changed on a BBSI Employee, update the related User.
	 * @param  oldContacts  Map of Contacts before changes
	 * @param  newContacts  List of Contacts with changes
	 */
	public static void updateUserAcronym(Map<Id, Contact> oldContacts, List<Contact> newContacts) {
		Id idrtContactBbsiEmployee = RecordTypeService.getId('Contact', 'BBSI Employee');
		Boolean callQueueable = false;

		for (Contact contact : newContacts) {
			if (contact.RecordTypeId == idrtContactBbsiEmployee) {
				if (contact.User_Id__c != null) {
					if (oldContacts == null) {
						callQueueable = true;
						break;
					} else if (contact.BDM_Acronym__c != oldContacts.get(contact.Id).BDM_Acronym__c) {
						callQueueable = true;
						break;
					}
				}
			}
		}

		if (callQueueable) {
			// Using a Queueable call because we are changing User records
			// and will throw and exception otherwise.
			System.enqueueJob(new UserAcronymQueueable());
		}
	}

	/**
	 * @description getContactAttachments retrieves Attachments related to the given Contact Ids.
	 * All fields are returned.
	 * @param idContacts  Identifiers of Contacts to get Attachments for
	 * @return List of attachments related to the contacts ordered newest to oldest
	 */
	public static List<Attachment> getContactAttachments(Set<Id> idContacts) {
		Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.Attachment.fields.getMap();

		String fields = String.join(new List<String>(schemaFieldMap.keySet()), ',');

		String query = String.format(
			'SELECT {0} FROM Attachment WHERE ParentId IN :idContacts ORDER BY CreatedDate DESC',
			new List<String>{ fields }
		);

		return (List<Attachment>) Database.Query(query);
	}

	/**
	 * @description getContactNotes retrieves Attachments related to the given Contact Ids.
	 * All fields are returned.
	 * @param idContacts  Identifiers of Contacts to get Notes for
	 * @return List of notes related to the contacts ordered newest to oldest
	 */
	public static List<Note> getContactNotes(Set<Id> idContacts) {
		Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.Note.fields.getMap();

		String fields = String.join(new List<String>(schemaFieldMap.keySet()), ',');

		String query = String.format(
			'SELECT {0} FROM Note WHERE ParentId IN :idContacts ORDER BY CreatedDate DESC',
			new List<String>{ fields }
		);

		return (List<Note>) Database.Query(query);
	}

	/**
	 * @description getContactEvents retrieves Events related to the given Contact Ids.
	 * All fields are returned.
	 * @param idContacts  Identifiers of Contacts to get Events for
	 * @return List of Events related to the contacts ordered newest to oldest
	 */
	public static List<Event> getContactEvents(Set<Id> idContacts) {
		Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.Event.fields.getMap();

		String fields = String.join(new List<String>(schemaFieldMap.keySet()), ',');

		String query = String.format(
			'SELECT {0} FROM Event WHERE WhoId IN :idContacts ORDER BY CreatedDate DESC',
			new List<String>{ fields }
		);

		return (List<Event>) Database.Query(query);
	}

	/**
	 * @description getContactTasks retrieves Tasks related to the given Contact Ids.
	 * All fields are returned.
	 * @param idContacts  Identifiers of Contacts to get Tasks for
	 * @return List of Tasks related to the contacts ordered newest to oldest
	 */
	public static List<Task> getContactTasks(Set<Id> idContacts) {
		Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.Task.fields.getMap();

		String fields = String.join(new List<String>(schemaFieldMap.keySet()), ',');

		String query = String.format(
			'SELECT {0} FROM Task WHERE WhoId IN :idContacts ORDER BY CreatedDate DESC',
			new List<String>{ fields }
		);

		return (List<Task>) Database.Query(query);
	}

	/**
	 * @description getRelatedAccountId retrieves the related Account Ids to the
	 * given Contact Ids.
	 * @param  contactIds  Set of Contact Ids
	 * @return Map relating Contact Id to Account Id
	 */
	public static Map<Id, Id> getRelatedAccountId(Set<Id> contactIds) {
		List<Contact> contacts = [SELECT Id, AccountId, Name FROM Contact WHERE Id IN :contactIds];

		Map<Id, Id> result = new Map<Id, Id>();

		for (Contact c : contacts) {
			if (c.AccountId != null) {
				result.put(c.Id, c.AccountId);
			}
		}

		return result;
	}

	/**
	 * @description setFields sets some of the default fields for a Contact.
	 * @param  oldContacts  Contacts before changes
	 * @param  newContacts  Contacts with changes
	 */
	public static void setFields(Map<Id, Contact> oldContacts, List<Contact> newContacts) {
		Set<Id> idAccounts = new Set<Id>();

		for (Contact contact : newContacts) {
			idAccounts.add(contact.AccountId);
		}

		idAccounts.remove(null);

		if (idAccounts.isEmpty()) {
			return;
		}

		Map<Id, Account> accounts = new Map<Id, Account>([
			SELECT Id, Name, Assigned_Referral_Partner__c, Producer__c
			FROM Account
			WHERE Id IN :idAccounts
		]);

		Account account;
		for (Contact contact : newContacts) {
			if (accounts.containsKey(contact.AccountId)) {
				account = accounts.get(contact.AccountId);

				contact.Producer__c = account.Producer__c;
				contact.Referral_Partner__c = account.Assigned_Referral_Partner__c;
			}
		}
	}
}