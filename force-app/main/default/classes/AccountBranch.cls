/**
 * @description AccountBranch contains methods to handle Branch Accounts.
 */
public without sharing class AccountBranch {
	private static final String QUERY_BRANCHES =
		'SELECT' +
		'	Id,' +
		'	Name,' +
		'	External_Id__c,' + // Branch Number
		'	BBSI_Location__c,' +
		'	Bbsi_Hub__c,' +
		'	Branch_Manager__c,' + // Area Manager
		'	Area_Manager_Email__c,' +
		'	Region__c,' +
		'	Zone__c,' +
		'	BillingAddress,' +
		'	ShippingAddress,' +
		'	Phone,' +
		'	Email_BU_when_Prospect_Assigned__c,' +
		'	Email_on_Closed_Opportunity__c,' +
		'   Benefits_Consultant__c,' +
		'   Benefits_Coordinator__c,' +
		'   Benefits_Representative__c' +
		' FROM Account' +
		' WHERE RecordType.Name = \'BBSI Branch\'' +
		' ORDER BY Name';

	private static final String FORMAT_QUERY_CLIENTS =
		'SELECT {0}' +
		' FROM Account' +
		' WHERE Prospect_Branch__c IN ({1})' +
		' AND RecordType.Name IN (\'Prospect\', \'Client\', \'Terminated\')';

	private static final String FORMAT_USER_BDM_QUERY =
		'SELECT' +
		'   Id,' +
		'   Name' +
		' FROM User' +
		' WHERE' +
		' Business_Activity_Report_BDM__c = TRUE' +
		'	AND IsActive = TRUE' +
		'	AND (Branch_Id__c IN :branchNums {0} )' +
		' ORDER BY Name';

	private static Map<Id, Account> branches = null;

	/**
	 * @description setClientBenefitsFields a NEW Prospect, Client and Terminated
	 * Benefits fields to the related branch values.
	 * @param  newAccounts  Accounts to set to Branch Benefits values
	 */
	public static void setClientBenefitsFields(List<Account> newAccounts) {
		List<Account> clients = (List<Account>) RecordTypeService.getByRecordTypes(
			newAccounts,
			'Account',
			new List<String>{ 'Prospect', 'Client', 'Terminated' }
		);

		if (!clients.isEmpty()) {
			Set<Id> idBranches = new Set<Id>();

			for (Account client : clients) {
				if (client.Prospect_Branch__c != null) {
					idBranches.add(client.Prospect_Branch__c);
				}
			}

			Map<Id, Account> mapBranches = new Map<Id, Account>(getBranches(idBranches));
			Account branch;

			for (Account client : clients) {
				if (client.Prospect_Branch__c != null) {
					if (mapBranches.containsKey(client.Prospect_Branch__c)) {
						branch = mapBranches.get(client.Prospect_Branch__c);

						client.Benefits_Consultant__c = branch.Benefits_Consultant__c;
						client.Benefits_Representative__c = branch.Benefits_Consultant__c;
					}
				}
			}
		}
	}

	/**
	 * @description getAreaManagersBranches retrieves all the Branches related
	 * to Area Managers.
	 * @return Map relating the Branch Id to its Area Manager
	 */
	public static Map<Id, List<Account>> getAreaManagersBranches() {
		getInternalBranches();

		Map<Id, List<Account>> result = new Map<Id, List<Account>>();
		Set<String> nameAMs = new Set<String>();

		for (Account branch : branches.values()) {
			nameAMs.add(branch.Branch_Manager__c);
		}

		for (User user : [SELECT Id, Name FROM User WHERE Name IN :nameAMs]) {
			if (!result.containsKey(user.Id)) {
				result.put(User.Id, new List<Account>());
			}

			for (Account branch : branches.values()) {
				if (branch.Branch_Manager__c == user.Name) {
					result.get(user.Id).add(branch);
				}
			}
		}

		return result;
	}

	/**
	 * @description getAreaManagerBranches retrieves all the Branches related
	 * to each of the given Area Managers.
	 * @param  idUserAMs Set of User IDs to look for
	 * @return Map relating the Area Manager Id to list of Branches
	 */
	public static Map<Id, List<Account>> getAreaManagerBranches(Set<Id> idUserAMs) {
		Map<Id, List<Account>> full = getAreaManagersBranches();

		Map<Id, List<Account>> result = new Map<Id, List<Account>>();

		for (Id idUser : idUserAms) {
			if (full.containsKey(idUser)) {
				result.put(idUser, full.get(idUser));
			} else {
				result.put(idUser, new List<Account>());
			}
		}

		return result;
	}

	/**
	 * @description getRelatedBdms retrieve the BDMs for the given Branch Ids.
	 * "Related" means the BDM has a Lead, Prospect or Client in the branch.
	 * @param  idBranches idBranches description
	 * @return Map of Branch Id to BDM User
	 */
	public static Map<Id, User> getRelatedBdms(Set<Id> idBranches) {
		getInternalBranches();

		Set<String> branchNums = new Set<String>();
		for (Account branch : branches.values()) {
			if (idBranches.contains(branch.Id)) {
				branchNums.add(branch.External_Id__c);
			}
		}

		Set<Id> idBdms = new Set<Id>();

		for (AggregateResult ar : [
			SELECT Business_Development_Manager__c, COUNT(Id) cnt
			FROM Lead
			WHERE Branch__c IN :idBranches
			GROUP BY Business_Development_Manager__c
		]) {
			if (((Integer) ar.get('cnt')) > 0) {
				idBdms.add((Id) ar.get('Business_Development_Manager__c'));
			}
		}

		for (AggregateResult ar : [
			SELECT Business_Development_Manager__c, COUNT(Id) cnt
			FROM Account
			WHERE Prospect_Branch__c IN :idBranches AND RecordType.Name IN ('Prospect', 'Client', 'Terminated')
			GROUP BY Business_Development_Manager__c
		]) {
			if (((Integer) ar.get('cnt')) > 0) {
				idBdms.add((Id) ar.get('Business_Development_Manager__c'));
			}
		}

		String bdmCondition = (idBdms.isEmpty()) ? '' : ' OR Id IN :idBdms';

		String query = String.format(FORMAT_USER_BDM_QUERY, new List<String>{ bdmCondition });

		return new Map<Id, User>((List<User>) Database.query(query));
	}

	/**
	 * @description getBranches retrieves a list of all the Branches.
	 * @return List of Branch Accounts
	 */
	public static Map<Id, Account> getBranches() {
		getInternalBranches();

		return branches;
	}

	/**
	 * @description getBranchesByNumber retrieves a map keyed by the branch number.
	 * @return Map<Id, Account>
	 */
	public static Map<String, Account> getBranchesByNumber() {
		getInternalBranches();

		Map<String, Account> result = new Map<String, Account>();

		for (Account branch : branches.values()) {
			result.put(branch.External_Id__c, branch);
		}

		return result;
	}

	/**
	 * @description getBranches retrieves a list of Branches based on given Ids.
	 * @param  idBranches  Set of branches to read.  null if all.
	 * @return List of Branch Accounts
	 */
	public static List<Account> getBranches(Set<Id> idBranches) {
		getInternalBranches();

		List<Account> result = new List<Account>();

		for (Account branch : branches.values()) {
			if (idBranches == null || idBranches.contains(branch.Id)) {
				result.add(branch);
			}
		}

		result.sort();
		return result;
	}

	/**
	 * @description getRegions retrieve the list of regions from the Account Branches.
	 * @return A List of region Strings
	 */
	public static List<String> getRegions() {
		getInternalBranches();

		Set<String> regions = new Set<String>();

		for (Account branch : branches.values()) {
			regions.add(branch.Region__c);
		}

		List<String> result = new List<String>(regions);
		result.sort();

		return result;
	}

	/**
	 * @description getRegionToBranches get a Map of Regions with their Branches.
	 * @return Map of Region to list of Branches
	 */
	public static Map<String, List<Account>> getRegionToBranches() {
		getInternalBranches();

		Map<String, List<Account>> result = new Map<String, List<Account>>();

		for (Account branch : branches.values()) {
			if (!result.containsKey(branch.Region__c)) {
				result.put(branch.Region__c, new List<Account>());
			}

			result.get(branch.Region__c).add(branch);
		}

		for (List<Account> listBranches : result.values()) {
			listBranches.sort();
		}

		return result;
	}

	/**
	 * @description resetLoadedBranches clears the loaded branches
	 */
	public static void resetLoadedBranches() {
		branches = null;
	}

	/**
	 * @description getInternalBranches retrieves all the Branch data for
	 * all branches.
	 * @return Map<Id, Account>
	 */
	private static Map<Id, Account> getInternalBranches() {
		if (branches == null) {
			branches = new Map<Id, Account>((List<Account>) Database.query(QUERY_BRANCHES));
		}

		return branches;
	}

	/**
	 * @description getBranchToClients retrieve all client records related to the branches
	 * @param  idBranches Branch Account Ids
	 * @param  fields     List of fields to retrieve
	 * @return Map<Id, List<Account>>
	 */
	@TestVisible
	private static Map<Id, List<Account>> getBranchToClients(Set<Id> idBranches, Set<String> fields) {
		Map<Id, List<Account>> result = new Map<Id, List<Account>>();

		for (Id id : idBranches) {
			result.put(Id, new List<Account>());
		}

		String textFields = String.join(new List<String>(fields), ',');
		String textIdBranches = SOQL_Services.joinIds(idBranches);

		String query = String.format(FORMAT_QUERY_CLIENTS, new List<String>{ textFields, textIdBranches });

		List<Account> clients = Database.query(query);

		for (Account client : clients) {
			result.get(client.Prospect_Branch__c).add(client);
		}

		return result;
	}

	/**
	 * @description getBranchNumbersToAreaManagers retrieves the Area Manager User objects
	 * for each of the branches.
	 * @return   A Map relating the Branch Number to the Area Mananger User object.
	 */
	public static Map<String, User> getBranchNumbersToAreaManagers() {
		Map<String, String> mapBranchNumberToNameAM = new Map<String, String>();
		for (Account a : [
			SELECT Id, Name, External_Id__c, Branch_Manager__c
			FROM Account
			WHERE RecordType.Name = 'BBSI Branch'
		]) {
			mapBranchNumberToNameAM.put(a.External_Id__c, a.Branch_Manager__c);
		}

		Map<String, User> mapNameToUser = new Map<String, User>();
		for (User u : [
			SELECT Id, Name, Branch_Id__c, ManagerId, Title
			FROM User
			WHERE Name IN :mapBranchNumberToNameAM.values()
		]) {
			mapNameToUser.put(u.Name, u);
		}

		Map<String, User> result = new Map<String, User>();
		for (String branchNumber : mapBranchNumberToNameAM.keySet()) {
			result.put(branchNumber, mapNameToUser.get(mapBranchNumbertoNameAM.get(branchNumber)));
		}

		return result;
	}

	/**
	 * @description updateAreaManager updates the client account's Area Manager email when
	 * the Branch Manager Email changes.
	 * @param  newValues
	 * @param  oldValues
	 */
	public static void updateAreaManager(Map<Id, Account> newValues, Map<Id, Account> oldValues) {
		Set<String> names = new Set<String>();
		Set<String> branchNumbers = new Set<String>();

		Id idRecordTypeBranch = RecordTypeService.getId('Account', 'BBSI Branch');

		for (Account acc : newValues.values()) {
			if (acc.RecordTypeId == idRecordTypeBranch && !String.isBlank(acc.Branch_Manager__c)) {
				names.add(acc.Branch_Manager__c);
			}
		}

		if (!names.isEmpty()) {
			Boolean mayUpdateAreaManager = Schema.sObjectType.User.fields.ManagerId.isUpdateable();

			Map<String, User> users = new Map<String, User>();

			for (User u : [SELECT Id, Name, EMail FROM User WHERE Name IN :names]) {
				users.put(u.Name, u);
			}

			for (Account acc : newValues.values()) {
				if (acc.Branch_Manager__c != oldValues.get(acc.Id).Branch_Manager__c) {
					if (users.containsKey(acc.Branch_Manager__c)) {
						if (mayUpdateAreaManager) {
							branchNumbers.add(acc.External_Id__c);
						}
						else {
							acc.addError('Insufficient permissions to update Area Manager');
						}
					} else {
						acc.addError('Updated Area Manager name doesn\'t match any users.');
					}
				}
			}

			if (!branchNumbers.isEmpty()) {
				futureUpdateUserManagersForBranch(branchNumbers);
			}
		}

		List<Id> ids = new List<Id>();

		for (Account acc : newValues.values()) {
			if (acc.Branch_Manager_Email__c != oldValues.get(acc.Id).Branch_Manager_Email__c) {
				ids.add(acc.Id);
			}
		}

		if (!ids.isEmpty()) {
			// Made a future call because don't know the number of accounts
			// needing update and don't want to reach governor limits.
			futureSetAreaManagerEmails(ids);
		}
	}

	/**
	 * @description futureSetAreaManagerEmails updates a client Area Manager's email from their controlling branch.
	 * @param  ids Ids of the accounts to update
	 */
	@future
	public static void futureSetAreaManagerEmails(List<id> ids) {
		List<Account> childAccounts = [
			SELECT Id, Name, Area_Manager_Email__c, Prospect_Branch__c, Prospect_Branch__r.Branch_Manager_Email__c
			FROM Account
			WHERE Prospect_Branch__c IN :ids
		];
		List<Account> updateAccounts = new List<Account>();

		for (Account a : childAccounts) {
			if (
				a.Prospect_Branch__c != null &&
				a.Area_Manager_Email__c != a.Prospect_Branch__r.Branch_Manager_Email__c
			) {
				updateAccounts.add(
					new Account(Id = a.Id, Area_Manager_Email__c = a.Prospect_Branch__r.Branch_Manager_Email__c)
				);
			}
		}

		update updateAccounts;
	}

	/**
	 * @description futureUpdateUserManagersForBranch updates User managers for the
	 * give branches.
	 * @param  branchNumbers Ids of the Users to update
	 */
	@future
	public static void futureUpdateUserManagersForBranch(Set<String> branchNumbers) {
		Map<String, User> mapBranchNumberToAreaManager = getBranchNumbersToAreaManagers();

		List<User> updateUsers = new List<User>();

		List<User> users = [
			SELECT Id, ManagerId, Branch_Id__c
			FROM User
			WHERE Branch_Id__c IN :branchNumbers
			AND IsActive = TRUE
		];

		for (User u : users) {
			if (mapBranchNumberToAreaManager.containsKey(u.Branch_Id__c)) {
				Id newManagerId = mapBranchNumberToAreaManager.get(u.Branch_Id__c).Id;

				if (newManagerId != null) {
					// Update if different and block from being own manager
					if (u.ManagerId != newManagerId && u.Id != newManagerId) {
						u.ManagerId = newManagerId;
						updateUsers.add(u);
					}
				}
			}
		}

		if (!updateUsers.isEmpty()) {
			update updateUsers;
		}
	}

	/**
	 * @description updateAreaManagerEmails
	 * @param  newValues
	 * @param  oldValues
	 */
	public static void updateAreaManagerEmails(List<Account> newValues, Map<Id, Account> oldValues) {
		Map<String, Account> changedAMs = new Map<String, Account>();

		Id idRecordTypeBranch = RecordTypeService.getId('Account', 'BBSI Branch');

		for (Account acc : newValues) {
			if (acc.recordTypeId == idRecordTypeBranch) {
				if (oldValues == null) {
					if (acc.Branch_Manager__c != null) {
						changedAMs.put(acc.Branch_Manager__c, acc);
					}
				} else {
					if (acc.Branch_Manager__c != oldValues.get(acc.Id).Branch_Manager__c) {
						if (acc.Branch_Manager__c != null) {
							changedAMs.put(acc.Branch_Manager__c, acc);
						} else {
							acc.addError('Cannot erase the Area Manager on a branch.');
						}
					}
				}
			}
		}

		if (!changedAMs.isEmpty()) {
			Map<String, String> mapNameToEmail = new Map<String, String>();

			for (User u : [SELECT Id, Name, Email FROM User WHERE Name IN :changedAMs.keySet()]) {
				mapNameToEmail.put(u.Name, u.Email);
			}

			for (Account acc : changedAMs.values()) {
				if (mapNameToEmail.containsKey(acc.Branch_Manager__c)) {
					acc.Branch_Manager_Email__c = mapNameToEmail.get(acc.Branch_Manager__c);
				} else {
					acc.addError('Area Manager name doesn\'t match any users.');
				}
			}
		}
	}
	
	public static void updateBenefitsPeople(Map<Id, Account> oldAccounts, List<Account> newAccounts) {
		Id idrtBranch = RecordTypeService.getId('Account', 'BBSI Branch');

		List<Account> fixBranches = new List<Account>();

		Account oldAccount;

		for (Account account : newAccounts) {
			if (account.RecordTypeId == idrtBranch) {	
				oldAccount = oldAccounts.get(account.Id);

				if (oldAccount.Benefits_Consultant__c != account.Benefits_Consultant__c) {
					fixBranches.add(account);
				}
			}
		}

		BranchClientUpdate_Batch.perform(oldAccounts, fixBranches);
	}
}