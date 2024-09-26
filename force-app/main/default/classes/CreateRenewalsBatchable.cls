/**
 * @description CreateRenewalsBatchable
 */
@SuppressWarnings('PMD.AvoidGlobalModifier')
global class CreateRenewalsBatchable implements Database.Batchable<RenewalsWrapper> {
	private static final Integer MAX_NAME_LEN = 80;

	//	Corporate FEIN numbers (do not create renewals for these!)
	//	20-2761056 � AZ Lease
	//	26-0435502 � Strategic Staffing
	//	52-0812977 � BBSI
	public List<String> corporateFeins = new List<String>{ '20-2761056', '26-0435502', '52-0812977' };

	/**
	 * @description start determines the items which will be process in the batches.
	 * @param  context Information about the Batch Context
	 * @return List of objects
	 */
	global List<RenewalsWrapper> start(Database.batchableContext context) {
		return getRenewalsWrapper();
	}

	/**
	 * @description execute performes actions on the batched objects.
	 * @param  context Information about the Batch Context
	 * @param  scope   Objects to process
	 */
   	global void execute(Database.BatchableContext context, List<RenewalsWrapper> scope) {
   		createRenewals(scope);
	}

	/**
	 * @description finish allows actions after the batch processing is complete.
	 * @param  context Information about the Batch Context
	 */
	global void finish(Database.BatchableContext context) {
		Database.executebatch(new AddClientsToRenewalsBatch(), 100);
	}

	/**
	 * @description getRenewalsWrapper create a list of RenewalsWrappers to process.
	 * @return List<RenewalsWrapper>
	 */
	@TestVisible
	private List<RenewalsWrapper> getRenewalsWrapper() {
		Map<String, List<Account>> mapAccountsByFEINBU = new Map<String, List<Account>>();
		List<RenewalsWrapper> results = new List<RenewalsWrapper>();

		for (Account a : [
			SELECT
				Id,
				OwnerId,
				Name,
				FEIN__c,
				Business_Unit__r.Name,
				Renewal_Date__c,
				Location_Primary_Contact__c,
				Renewal__c,
				(SELECT Id, Active__c FROM Contacts)
			FROM Account
			WHERE
				RecordType.Name = 'Client'
				AND External_ID__c LIKE '9%'
				AND (NOT External_ID__c LIKE '99%')
				AND Account.Renewal_Date__c <= NEXT_90_DAYS
				AND Account.Renewal_Date__c > LAST_90_DAYS
				AND Account.Start_Date__c < LAST_90_DAYS
				AND Account.FEIN__c != NULL
				AND Account.FEIN__c NOT IN :corporateFeins
				AND Account.Status__c = 'ACTIVE'
				AND (Account.Renewal__c = NULL
				OR Renewal__r.Renewal_Date__c < LAST_90_DAYS)
			ORDER BY FEIN__c, Business_Unit__r.Name
		]) {
			String key = String.format('{0}-{1}', new List<String>{ a.FEIN__c, a.Business_Unit__r.Name });

			if (mapAccountsByFEINBU.containsKey(key)) {
				mapAccountsByFEINBU.get(key).add(a);
			} else {
				mapAccountsByFEINBU.put(key, new List<Account>{ a });
			}
		}

		for (String key : mapAccountsByFEINBU.keySet()) {
			results.add(new RenewalsWrapper(key, mapAccountsByFEINBU.get(key)));
		}

		return results;
	}

	/**
	 * @description createRenewals process a batch of the Renewal
	 * @param  values RenewalsWrappers to process
	 */
	@TestVisible
	private void createRenewals(List<RenewalsWrapper> values) {
		Map<String, List<Account>> accountsbyfeinBU = new Map<String, List<Account>>();
        List<Renewal__c> newRenewalObjects = new List<Renewal__c>();

		for (RenewalsWrapper wp : values) {
			accountsByFeinBU.put(wp.Key, wp.values);

			String name;

			if (wp.values[0].Name.length() <= MAX_NAME_LEN) {
				name = wp.values[0].Name;
			} else {
				wp.values[0].Name.left(wp.values[0].Name.lastIndexOf(' ', MAX_NAME_LEN));
			}

			Renewal__c myRenewal = new Renewal__c();
			myRenewal.Name = name;
			myRenewal.FEIN__c = wp.values[0].FEIN__c;
			myRenewal.Business_Unit__c = wp.values[0].Business_Unit__r.Name;

			if (wp.values[0].Location_Primary_Contact__c != null) {
				myRenewal.Contact__c = wp.values[0].Location_Primary_Contact__c;
			}
			else if (wp.values[0].Contacts != null && wp.values[0].Contacts.size() > 0) {
				myRenewal.Contact__c = wp.values[0].Contacts[0].Id;
			}

			myRenewal.OwnerId = wp.values[0].OwnerId;

			newRenewalObjects.add(myRenewal);

			//update the date and the client count here, not need to reprocess you have info
			for (Account client : wp.values) {
				if (myRenewal.Renewal_Date__c == null || myRenewal.Renewal_Date__c > client.Renewal_Date__c) {
					myRenewal.Renewal_Date__c = client.Renewal_Date__c;
				}
			}

			myRenewal.Clients__c = wp.values.size();
		}

		Database.SaveResult[] srList;

		srList = Database.insert (newRenewalObjects, false);
		Log.writeIfError('Renewals - CreateRenewalsBatchable.createRenewals()', 'Database Insert New Renewal Failed', null, srList);

		List<Account> updateAccounts = new List<Account>();
		List<RenewalClientAssoc__c> newJuncObjects = new List<RenewalClientAssoc__c>();
		RenewalClientAssoc__c juncObject;

		for (Renewal__c renewal: newRenewalObjects) {
			String key = String.format('{0}-{1}', new List<String>{ renewal.FEIN__c, renewal.Business_Unit__c });
			List<Account> clients = accountsbyfeinBU.get(key);

			for (Account client: clients) {
				if (renewal.Id != null) {
					juncObject = new RenewalClientAssoc__c();
					juncObject.Client__c = client.Id;
					juncObject.Renewal__c = renewal.Id;
					newJuncObjects.add(juncObject);
					client.Renewal__c = renewal.Id;
					updateAccounts.add(client);
				}
			}
		}

		srList = Database.insert(newJuncObjects, false);
		Log.writeIfError('Renewals - CreateRenewalsBatchable.createRenewals()', 'Database Insert New Junction Failed', null, srList);

		srList = Database.update(updateAccounts, false);
		Log.writeIfError('Renewals - CreateRenewalsBatchable.createRenewals()', 'Database Update Accounts Failed', null, srList);

		Log.info(
			'Renewals - CreateRenewalsBatchable.createRenewals()',
			'Renewals Created',
			'New Renewal Objects: ' + newRenewalObjects.size() +
			'\nNew Junction Objects: ' + newJuncObjects.size() +
			'\nUpdate Accounts: ' + updateAccounts.size()
		);
	}
}