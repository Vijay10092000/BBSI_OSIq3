/**
 * @description ContactClient contains methods to help handle the Client Contacts.
 */
public without sharing class ContactClient {
	/**
	 * @description updateFields updates fields on related Contacts.
	 * @param  oldAccounts  oldAccounts before changes
	 * @param  newAccounts  newAccounts with changes
	 */
    public static void updateFields(Map<Id, Account> oldAccounts, Map<Id, Account> newAccounts) {
		Set<Id> idChanged = new Set<Id>();

		for (Account account : newAccounts.values()) {
			if (oldAccounts.get(account.Id).Assigned_Referral_Partner__c != account.Assigned_Referral_Partner__c) {
				idChanged.add(account.Id);
			} else {
				if (oldAccounts.get(account.Id).Producer__c != account.Producer__c) {
					idChanged.add(account.Id);
				}
			}
		}

		if (idChanged.isEmpty()) {
			return;
		}

		List<Contact> contacts = [
			SELECT Id, Name, AccountId, Producer__c, Referral_Partner__c
			FROM Contact
			WHERE AccountId IN :idChanged
		];

		if (contacts.isEmpty()) {
			return;
		}

		Account account;
		for (Contact contact : contacts) {
			account = newAccounts.get(contact.AccountId);

			contact.Producer__c = account.Producer__c;
			contact.Referral_Partner__c = account.Assigned_Referral_Partner__c;
		}

		DatabaseUpdateBatch.dispatch(contacts, false, 'Contacts', 'ContactClient.updateFields Failed');
    }
}