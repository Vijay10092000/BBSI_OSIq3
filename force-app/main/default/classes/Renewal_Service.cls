/**
 * @description Renewal_Service methods to handle trigger events.
 */
public without sharing class  Renewal_Service {
	private static Set<String> doneStatuses = new Set<String>{ 'Completed', 'Terminated', 'Incomplete' };

	/**
	 * @description setIncompleteRenewals sets previous renewals to "Incomplete" if a new renewal is created
	 * on a FEIN.
	 */
    public static void setIncompleteRenewals(List<Renewal__c> newRenewals) {
		Set<Id> idRenewals = new Set<Id>();
		Set<String> idFeins = new Set<String>();

		for (Renewal__c renewal : newRenewals) {
			if (!doneStatuses.contains(renewal.Status__c)) {
				idRenewals.add(renewal.Id);
				idFeins.add(renewal.Fein__c);
			}
		}

		if (!idFeins.isEmpty()) {
			List<Renewal__c> renewals = [
				SELECT Id, Status__c
				FROM Renewal__c
				WHERE Id NOT IN :idRenewals
				AND Fein__c IN :idFeins
				AND Status__c NOT IN :doneStatuses
			];

			for (Renewal__c renewal : renewals) {
				renewal.Status__c = 'Incomplete';
			}

			update renewals;
		}
    }
}