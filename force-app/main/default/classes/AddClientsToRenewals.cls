/**
 * @description AddClientsToRenewals
 */
public without sharing class AddClientsToRenewals {
	/**
	 * @description addClients
	 * @param  clients Client Accounts
	 */
	public static void addClients(List<Account> clients) {
		if (clients == null || clients.isEmpty()) {
			return;
		}

		Set<String> feins = new Set<String>();
		Map<String, Set<Account>> accountsByFeinBU = new Map<String, Set<Account>>();

		for (Account client : clients) {
			feins.add(client.FEIN__c);

			String key = client.Fein__c + client.Business_Unit__r.Name;

			if (!accountsByFeinBU.containsKey(key)) {
				accountsByFeinBU.put(key, new Set<Account>());
			}

			accountsByFeinBU.get(key).add(client);
		}

		List<Renewal__c> renewals = [
			SELECT Id, FEIN__c, Business_Unit__c, Clients__c
			FROM Renewal__c
			WHERE FEIN__c IN :feins
			AND Status__c NOT IN ('Completed', 'Terminated', 'Incomplete')
			ORDER BY LastModifiedDate ASC
		];

		if (renewals.isEmpty()) {
			return;
		}

		Map<Id, Account> updateAccounts = new Map<Id, Account>();
		List<RenewalClientAssoc__c> newJuncObjects = new List<RenewalClientAssoc__c>();

		for (Renewal__c renewal : renewals) {
			String key = renewal.FEIN__c + renewal.Business_Unit__c;

			if (accountsByFeinBU.containsKey(key)) {
				if (renewal.Clients__c == null) {
					renewal.Clients__c = 0;
				}

				for (Account client : accountsByFeinBU.get(key)) {
					client.Renewal__c = renewal.Id;
					updateAccounts.put(client.Id, client);

					renewal.Clients__c += 1;

					newJuncObjects.add(
						new RenewalClientAssoc__c(
							Client__c = client.Id,
							Renewal__c = renewal.Id
						)
					);
				}
			}
		}

		Database.SaveResult[] srList;

		String exceptions = '';

		try{
			srList = Database.update(new List<Account>(updateAccounts.values()), false);
			Log.writeIfError('Renewals', 'AddClientsToRenewals', 'Accounts to Update',  srList);
		} catch (Exception e) {
			exceptions += '\n\nAccounts to Update\n' + e;
		}

		try {
			srList = Database.update(renewals, false);
			Log.writeIfError('Renewals', 'AddClientsToRenewals', 'Renewals to Update', srList);
		} catch (Exception e) {
			exceptions += '\n\nRenewals to Update\n' + e;
		}

		try{
			srList = Database.insert(newJuncObjects, false);
			Log.writeIfError('Renewals', 'AddClientsToRenewals', 'New Junction objects', srList);
		} catch (Exception e) {
			exceptions += '\n\nNew Junction objects\n' + e;
		}

		if (!String.isBlank(exceptions)) {
			Log.error('Renewals', 'AddClientsToRenewals', exceptions);
		}
	}
}