/**
 * @description RenewalChangeOwner updates the renewal owner when owner changes on an Account.
 * Created by CElim on 7/23/2019.
 */
public without sharing class RenewalChangeOwner {
	/**
	 * @description processRenewalChangeOwner updates the Renewal when owner changes on an Account.
	 * @param  oldAccounts  Accounts before the change
	 * @param  newAccounts  Accounts with the change
	 */
	public static void processRenewalChangeOwner(Map<id, Account> oldAccounts, List<Account> newAccounts) {
		Map<Id, Id> renewalOwnerIdMap = new Map<Id, Id>();

		for (Account account : newAccounts) {
			if (account.Renewal__c != null) {
				if (oldAccounts == null || oldAccounts.get(account.Id).OwnerId != account.OwnerId) {
					renewalOwnerIdMap.put(account.Renewal__c, account.OwnerId);
				}
			}
		}

		if (!renewalOwnerIdMap.isEmpty()) {
			List<Renewal__c> renewals = [
				SELECT Id, OwnerId
				FROM Renewal__c
				WHERE Id = :renewalOwnerIdMap.keySet()
			];

			for (Renewal__c renewal : renewals) {
				renewal.OwnerId = renewalOwnerIdMap.get(renewal.Id);
			}

			Database.update(renewals);
		}
	}
}