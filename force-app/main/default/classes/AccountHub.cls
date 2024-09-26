/**
 * @description AccountHub contains methods to help handle the BBSI Hub Accounts.
 */
public without sharing class AccountHub {
	public static final String BBSI_HUB = 'BBSI Hub';

	public static void setRegion(Map<Id, Account> oldAccounts, List<Account> newAccounts) {
		List<Account> branches = RecordTypeService.getByRecordType(newAccounts, 'Account', 'BBSI Branch');

		if (branches.isEmpty()) {
			return;
		}

		Set<Id> idHubs = new Set<Id>();

		for (Account branch : branches) {
			if (oldAccounts == null) {
				if (branch.BBSI_Hub__c != null) {
					idHubs.add(branch.BBSI_Hub__c);
				}
			} else if (oldAccounts.get(branch.Id).BBSI_Hub__c != branch.BBSI_Hub__c) {
				idHubs.add(branch.BBSI_Hub__c);
			}
		}

		if (!idHubs.isEmpty()) {
			Map<Id, Account> hubs = new Map<Id, Account>([
				SELECT Id, Name, Region__c
				FROM Account
				WHERE Id IN :idHubs
			]);

			for (Account branch : branches) {
				if (hubs.containsKey(branch.BBSI_Hub__c)) {
					branch.Region__c = hubs.get(branch.BBSI_Hub__c).Region__c;
				}
			}
		}
	}

	/**
	 * @description updateHubBranches updates Branch region if needed.
	 * @param  oldAccounts  Accounts before changes
	 * @param  newAccounts  Accounts with changes
	 */
	public static void updateHubBranches(Map<Id, Account> oldAccounts, Map<Id, Account> newAccounts) {
		Map<Id, Account> hubs = new Map<Id, Account>((List<Account>) RecordTypeService.getByRecordType(newAccounts.values(), 'Account', BBSI_HUB));

		if (hubs.isEmpty()) {
			return;
		}
		List<Account> updateAccounts = new List<Account>();

		String region;
		Map<Id, List<Account>> hubBranches = getHubBranches(hubs.keySet());

		for (List<Account> branches : hubBranches.values()) {
			for (Account branch : branches) {
				region = newAccounts.get(branch.BBSI_Hub__c).Region__c;

				if (branch.Region__c != region) {
					branch.Region__c = region;

					updateAccounts.add(branch);
				}
			}
		}

		update updateAccounts;
	}

	/**
	 * @description getHubBranches retrieve the related branch acccounts to the
	 * given BBSI Hub identifiers.
	 * @param  idHubs  BBSI Hub identifiers
	 * @return Map<Id, List<Account>>
	 */
	public static Map<Id, List<Account>> getHubBranches(Set<Id> idHubs) {
		Map<Id, List<Account>> result = new Map<Id, List<Account>>();

		if (!idHubs.isEmpty()) {
			for (Id idhub : idHubs) {
				result.put(idHub, new List<Account>());
			}

			for (Account branch : [
				SELECT Id, Name, BBSI_Hub__c, Region__c
				FROM Account
				WHERE RecordType.Name = 'BBSI Branch'
				AND BBSI_Hub__c IN :idHubs
			]) {
				result.get(branch.BBSI_Hub__c).add(branch);
			}
		}

		return result;
	}
}