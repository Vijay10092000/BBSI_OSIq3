/**
 * @description Account_ChangeOwnerTrigger
 */
public without sharing class Account_ChangeOwnerTrigger {
	/**
	 * @description populateBranch updates the Branch when the Owner changes
	 * on a Prospect or Client Account.
	 * @param  mapNew Map of Accounts with proposed changes
	 * @param  mapOld Map of Accounts before changes
	 */
	public static void populateBranch(Map<Id, Account> mapOld, Map<Id, Account> mapNew) {
		Set<Id> newOwners = new Set<Id>();
		Id rtIdClient = recordTypeService.getId('Account', 'Client');
		Id rtIdProspect = recordTypeService.getId('Account', 'Prospect');

		// Get Owners of Prospects and Clients where Owner or Branch is changing
		for (Account acc : mapNew.Values()) {
			if (acc.RecordTypeId == rtIdClient || acc.RecordTypeId == rtIdProspect) {
				if (acc.OwnerId != mapOld.get(acc.Id).OwnerId) {
					newOwners.Add(acc.OwnerId);
			} else {
					if (acc.Prospect_Branch__c != mapOld.get(acc.Id).Prospect_Branch__c) {
						newOwners.add(acc.OwnerId);
					}
				}
			}
		}

		if (newOwners.size() > 0) {
			Map<Id, User> users = User_Services.getUserRecordsMap(newOwners);
			Map<String, Account> branches = AccountBranch.getBranchesByNumber();

			for (Account acc : mapNew.Values()) {
				String usrBranch = users.get(acc.OwnerId).Branch_Id__c;

				if (acc.OwnerId != mapOld.get(acc.Id).OwnerId) {
				if (usrBranch != null) {
					Account branch = branches.get(usrBranch);

					if (branch != null) {
							acc.Prospect_Branch__c = branch.Id;
						}
					}
				}
			}
		}
	}
}
/**
List<Account> clients = RecordTypeService.getByRecordTypes(mapNew.values(), 'Account', new List<String>{ 'Client', 'Prospect' });

if (clients.isEmpty()) {
	return;
}

Set<Id> newOwners = new Set<Id>();

for (Account client : clients) {
	if (client.OwnerId != mapOld.get(client.Id).OwnerId) {
		newOwners.Add(client.OwnerId);
	} else {
		if (client.Prospect_Branch__c != mapOld.get(client.Id).Prospect_Branch__c) {
			newOwners.add(client.OwnerId);
		}
	}
}

if (newOwners.size() > 0) {
	Map<String, Account> branches = AccountBranch.getBranchesByNumber();
	Map<Id, User> users = User_Services.getUserRecordsMap(newOwners);

	for (Account client : clients) {
		String usrBranch = users.get(client.OwnerId).Branch_Id__c;

		if (usrBranch != null) {
			Account branch = branches.get(usrBranch);

			if (branch != null) {
				client.Prospect_Branch__c = branch.Id;
			}
		}
	}
}
**/