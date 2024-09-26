/**
 * @description UserAcronymQueueable keeps in sync the User record's Acronym
 * field when the related Contact record's BDM Acronym has changed.
 */
public without sharing class UserAcronymQueueable implements Queueable {
	/**
	 * @description execute updates Contact related Users who have a different
	 * acronym.
	 * @param  context QueuableContext
	 */
	public void execute(QueueableContext context) {
		List<Contact> contacts = [
			SELECT Id, BDM_Acronym__c, User_Id__c, User_Id__r.Acronym__c
			FROM Contact
			WHERE RecordType.Name = 'BBSI Employee'
			AND User_Id__c != NULL
		];

		if (!contacts.isEmpty()) {
			Map<Id, String> idUserToAcronym = new Map<Id, String>();

			for (Contact contact : contacts) {
				idUserToAcronym.put(contact.User_Id__c, contact.Bdm_Acronym__c);
			}

			List<User> updateUsers = new List<User>();
			Map<Id, User> users = new Map<Id, User>([SELECT Id, LastName, Acronym__c FROM User WHERE Id IN :idUserToAcronym.keySet()]);

			for (User user : users.values()) {
				if (idUserToAcronym.containsKey(user.Id)) {
					if (user.Acronym__c != idUserToAcronym.get(user.Id)) {
						user.Acronym__c = idUserToAcronym.get(user.Id);

						updateUsers.add(user);
					}
				}
			}

			if (!updateUsers.isEmpty()) {
				update updateUsers;
			}
		}
	}
}