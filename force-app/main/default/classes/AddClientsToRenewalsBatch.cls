/**
 * @description AddClientsToRenewalBatch is part of the nightly process which adds
 * Clients to Renewals.
 */
@SuppressWarnings('PMD.AvoidGlobalModifier')
global class AddClientsToRenewalsBatch implements Database.Batchable<Account> {
	/**
	 * @description start retrieves the list of records to process
	 * @param  context Information about the Batch job, including Id
	 * @return An iterator over the Accounts to process
	 */
	global Iterable<Account> start(Database.BatchableContext context) {
		return getClients();
	}

	/**
	 * @description execute performs the operation on a batch of objects.
	 * @param  context Information about the Batch job, including Id
	 * @param  scope   Contains the Client Accounts to process
	 */
   	global void execute(Database.BatchableContext context, List<sObject> scope) {
   		AddClientsToRenewals.addClients((List<Account>) scope);
	}

	/**
	 * @description finish performs actions after processing has completed.
	 * In this case processing continues with a call to CreateRenewalLinksBatch.
	 * @param  context Information about the Batch job, including Id
	 */
	global void finish(Database.BatchableContext context) {
		Database.executebatch(new CreateRenewalLinksBatch(), 10);
	}

	/**
	 * @description getClients determines the Client Accounts to process.
	 * @return A List of Accounts
	 */
	private List<Account> getClients() {
		Set<String> feins = new Set<String>();

		for (Renewal__c renewal : [SELECT FEIN__c FROM Renewal__c WHERE Status__c = 'New']) {
			feins.add(renewal.FEIN__c);
		}

		if (feins.isEmpty()) {
			return new List<Account>();
		}

		return [
			SELECT Id, Name, OwnerId, External_ID__c, FEIN__c, Business_Unit__R.Name, Renewal_Date__c
			FROM Account
			WHERE Status__c = 'ACTIVE'
			AND RecordType.Name = 'Client'
			AND FEIN__c IN :feins
			AND External_ID__c LIKE '9%'
			AND (NOT External_ID__c LIKE '99%')
			AND Start_Date__c < LAST_90_DAYS
			AND (
				Renewal__c = null
				OR (Renewal__r.Status__c = 'Completed'
					AND Renewal__r.Renewal_Date__c < LAST_90_DAYS
				)
			)
			ORDER BY Id
		];
	}
}