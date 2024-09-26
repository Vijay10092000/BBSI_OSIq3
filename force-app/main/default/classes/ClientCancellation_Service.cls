/**
 * @description ClientCancellation_Service contains methods for the
 * Client_Cancellation__c object.
 */
public without sharing class ClientCancellation_Service {
	/**
	 * @description updateContactDate updates the Date_Reviewed_by_Contracts__c field when the
	 * Contracts_Reviewed__c is set.
	 */
	public static void updateContactDate(Map<Id, Client_Cancellation__c> oldCancellations, List<Client_Cancellation__c> newCancellations) {
		for (Client_Cancellation__c cancellation : newCancellations) {
			if (cancellation.Contracts_Reviewed__c) {
				if (oldCancellations == null || !oldCancellations.get(cancellation.Id).Contracts_Reviewed__c) {
					cancellation.Date_Reviewed_by_Contracts__c = Date.today();
				}
			}
		}
	}

	/**
	 * @description createStartTasks creates a Task for each new cancellation.
	 * @param  cancellations List of new cancellations
	 */
	public static void createStartTasks(Map<Id, Client_Cancellation__c> cancellations) {
		List<Task> tasks = new List<Task>();

		Set<Id> idClients = new Set<Id>();

		for (Client_Cancellation__c cancellation : cancellations.values()) {
			idClients.add(cancellation.Client__c);
		}

		Map<Id, Account> clients = new Map<Id, Account>( [
			SELECT Id, Name, OwnerId, Location_Primary_Contact__c, Primary_Contact_Name__c FROM Account WHERE Id IN :idClients
		] );

		Map<Id, Contact> mapAccountToPrimary = getPrimaryContacts(clients);

		for (Client_Cancellation__c cancellation : cancellations.values()) {
			Date dateDue;

			if (cancellation.Client_Cancellation_Date__c == null) {
				dateDue = Date.today().addMonths(10);
			} else {
				dateDue = cancellation.Client_Cancellation_Date__c.addMonths(10);
			}

			Id idPrimaryContact = null;
			if (mapAccountToPrimary.containsKey(cancellation.Client__c)) {
				if (null != mapAccountToPrimary.get(cancellation.Client__c)) {
					idPrimaryContact = mapAccountToPrimary.get(cancellation.Client__c).Id;
				}
			}

			tasks.add(
				new Task(
					Subject = 'Client Cancellation Follow-up: ' + clients.get(cancellation.Client__c).Name,
					Status = 'Not Started',
					Priority = 'Normal',
					WhoId = idPrimaryContact,
					WhatId = cancellation.Id,
					OwnerId = clients.get(cancellation.Client__c).OwnerId,
					ActivityDate = dateDue
				)
			);
		}

		if (!tasks.isEmpty()) {
			Database.DMLOptions notifyOption = new Database.DMLOptions();
			notifyOption.EmailHeader.triggerUserEmail = true;

			Database.insert(tasks, notifyOption);
		}
	}

	@TestVisible
	private static Map<Id, Contact> getPrimaryContacts(Map<Id, Account> clients) {
		List<String> names = new List<String>();

		for (Account client : clients.values()) {
			if (String.isNotEmpty(client.Primary_Contact_Name__c)) {
				names.add(client.Primary_Contact_Name__c);
			}
		}
		Map<Id, Contact> mapContacts = new Map<Id, Contact>();

		List<Contact> contacts = [
			SELECT Id, Name, AccountId
			FROM Contact
			WHERE Name IN :names
			AND AccountId IN :clients.keySet()
		];

		for (Account client : clients.values()) {
			mapContacts.put(client.Id, null);

			if (String.isNotEmpty(client.Primary_Contact_Name__c)) {
				for (Contact c : contacts) {
					if (c.Name == client.Primary_Contact_Name__c) {
						mapContacts.put(client.Id, c);
						break;
					}
				}
			}
		}

		return mapContacts;
	}

	/**
	 * @description updateRevoke updates the related Account when the Revoke flag is changed.
	 */
	public static void updateRevoke(Map<Id, Client_Cancellation__c> mapOld, List<Client_Cancellation__c> listNew) {
		Map<Id, string> changeAccounts = new Map<Id, string>();
		Map<Id, Date> revokedClients = new Map<Id, Date>(); // User Story 68090
		for (Client_Cancellation__c cc : listNew) {
			if (mapOld.get(cc.Id).Revoke__c != cc.Revoke__c)
			{
				if (cc.Revoke__c) {
					changeAccounts.put(cc.Client__c, cc.Reason_for_Cancellation__c);					
					if(cc.Client_Cancellation_Date__c != null)
					revokedClients.put(cc.Client__c, cc.Client_Cancellation_Date__c);
				} else {
					changeAccounts.put(cc.Client__c, null);
				}
			}
		}
		// User Story 68090
		if(!revokedClients.isEmpty()){
			ReferralSource_Service.revokeRelatedReferralSources(revokedClients);
		}
		if (!changeAccounts.isEmpty()) {
			List<Account> accounts = [
				SELECT Id, Name, Cancellation_Reason__c
				FROM Account
				WHERE Id IN :changeAccounts.keySet()
			];
			
			for (Account a : accounts) {
				a.Cancellation_Reason__c = changeAccounts.get(a.Id);
			}

			update accounts;
		}
	}
}