/**
 * @description OpportunityStageName updates the Opportunity StageName based on changes
 * to its Account.
 */
public without sharing class OpportunityStageName {
	@TestVisible
	private Map<Id, Account> mapAccounts = new Map<Id, Account>();

	@TestVisible
	private Map<Id, List<Opportunity>> closedWonOpps = new Map<Id, List<Opportunity>>();

	/**
	 * @description updateOpportunityCloseWon updates related Opportunity stages.
	 * @param  mapAccounts  Accounts checking
	 */
	public static void updateOpportunityCloseWon(Map<Id, Account> mapAccounts) {
		OpportunityStageName osn = new OpportunityStageName(mapAccounts);

		osn.findCloseWon();
		osn.updateOpportunities();
	}

	/**
	 * @description OpportunityStageName constructor.  Accounts are only added if they are
	 * Client Accounts.
	 * @param  mapAccounts  Accounts checking
	 */
	@TestVisible
	private OpportunityStageName(Map<Id, Account> mapAccounts) {
		this.mapAccounts = mapAccounts;
	}

	/**
	 * @description findCloseWon reviews the Opportunities related to the Client Accounts.
	 * Accounts and determines which need to be marked as "Closed Won".  The obect field
	 * is set with these values ordered by most recently created.
	 */
	@TestVisible
	private void findCloseWon() {
		for (Opportunity opp : [
			SELECT Id, Name, AccountId, StageName
			FROM Opportunity
			WHERE
				AccountId IN :mapAccounts.keySet()
				AND Account.RecordType.Name = 'Client'
				AND Account.External_Id__c != NULL
				AND RecordType.Name IN ('Client', 'Creation of Shell')
				AND StageName NOT IN ('Closed Won', 'Closed Lost')
			ORDER BY CreatedDate DESC
		]) {
			if (!closedWonOpps.containsKey(opp.AccountId)) {
				closedWonOpps.put(opp.AccountId, new List<Opportunity>());
			}

			closedWonOpps.get(opp.AccountId).add(opp);
		}
	}

	/**
	 * @description updateOpps updates the Opportunities.  The most recent open Opportunity on a
	 * Prospect is marked as Closed Won, additional open Opportunities are marked Closed Lost.
	 */
	private void updateOpportunities() {
		List<Opportunity> updateOpps = new List<Opportunity>();

		Boolean isFirst;

		for (List<Opportunity> opps : closedWonOpps.values()) {
			isFirst = true;

			for (Opportunity opp : opps) {
				opp.StageName = (isFirst) ? 'Closed Won' : 'Closed Lost';

				updateOpps.add(opp);
				
				isFirst = false;
			}
		}

		if (!updateOpps.isEmpty()) {
			List<Database.SaveResult> srs = Database.update(updateOpps, false);
			Log.writeIfError('Opportunity', 'Failed Update to Closed Won', 'OpportunityStageName.updateOpps()', srs);
		}
	}
}