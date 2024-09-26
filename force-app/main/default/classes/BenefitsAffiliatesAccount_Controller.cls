/**
 * @description BenefitsAffiliatesAccount_Controller controls the selection of accounts
 * for a Benefits Affiliates record.
 */
public without sharing class BenefitsAffiliatesAccount_Controller {
	// Maximum number of Accounts to return from filter
	private static final Integer MAX_ACCOUNTS = 25;

	/**
	 * @description getSelected retrieves the accounts already affiliated to
	 * the given Benefits Affiliates.
	 * @param  idRecord  Benefits Affiliates identifier
	 * @return List<Option>
	 */
	@AuraEnabled
	public static List<Option> getSelected(Id idRecord) {
		Benefits_Affiliates__c ba = getBenefitsAffiliated(idRecord);
		List<Account> accounts = getAffiliatedAccounts(idRecord);

		List<Option> result = new List<Option>();

		for (Account account : accounts) {
			Option option = new Option(String.valueOf(account.Id), account.Name, true);

			option.required = (ba.Primary_Account__c == account.Id);

			result.add(option);
		}

		return result;
	}

	/**
	 * @description getAccounts retrieves Prospect, Client and Terminated accounts
	 * based on the given filter for selection.
	 * @param  filter      Filter to find an Account
	 * @param  idAccounts  identifiers of the current selected accounts
	 * @return List<Option>
	 */
	@AuraEnabled
	public static List<Option> getAccounts(String filter, List<Id> idAccounts) {
		List<Option> options = new List<Option>();

		if (idAccounts == null) {
			idAccounts = new List<Id>();
		}

		if (!String.isBlank(filter)) {
			String internalFilter = filter + '%';

			for (Account account : [
				SELECT Id, Name, External_Id__c, Benefits_Affiliates__c
				FROM Account
				WHERE
					Id IN :idAccounts
					OR (
						RecordType.Name IN ('Prospect', 'Client', 'Terminated')
						AND (Name LIKE :internalFilter OR External_Id__c LIKE :internalFilter)
					)
				ORDER BY Name ASC
				LIMIT :MAX_ACCOUNTS
			]) {
				options.add(new Option(String.valueOf(account.Id), account.Name, false));
			}
		}

		return options;
	}

	/**
	 * @description setSelected adds and removes accounts from the Benefits Affiliates.
	 * @param  idRecord    Benefits Affiliates identifier
	 * @param  idAccounts  identifiers of the accounts in the Benefits Affiliates
	 */
	@AuraEnabled
	public static String setSelected(Id idRecord, List<Id> idAccounts) {
		try {
			if (idAccounts.isEmpty()) {
				// Removed all accounts, so delete Benefits Affiliate
				BenefitsAffiliates.deleteAffiliates(new Set<Id>{ idRecord });
				return null;
			}

			Map<Id, Account> clearAccounts = new Map<Id, Account>(getAffiliatedAccounts(idRecord));

			Map<Id, Account> selectedAccounts = new Map<Id, Account>([
				SELECT Id, Name, Benefits_Affiliates__c, Part_of_a_Franchise__c
				FROM Account
				WHERE Id IN :idAccounts
			]);


			List<Account> updateAccounts = new List<Account>();

			String textError = '';
			String textDebug = '';

			Boolean onlyDeletes = false;

			for (Account client : clearAccounts.values()) {
				if (!selectedAccounts.containsKey(client.Id)) {
					client.Benefits_Affiliates__c = null;
					updateAccounts.add(client);
					onlyDeletes = true;

					textDebug += '\n  REMOVE  ' + client.Id + '  ' + client.Name;
				}
			}

			Benefits_Affiliates__c ba = getBenefitsAffiliated(idRecord);

			for (Account client : selectedAccounts.values()) {
				if (String.isBlank(client.Part_of_a_Franchise__c)) {
					textError += '\n ' + client.Name + ' needs field "Part of a Franchise?" set';
				} else {
					if (client.Benefits_Affiliates__c != idRecord) {
						if (client.Benefits_Affiliates__c == null) {
							client.Benefits_Affiliates__c = ba.Id;
							client.Benefits__c = ba.Benefits__c;

							updateAccounts.add(client);
							onlyDeletes = false;

							textDebug += '\n  INSERT  ' + client.Id + '  ' + client.Name;
						} else {
							textError += '\n' + client.Name + ' already member of a different affiliate';
						}
					} else {
						textDebug += '\n  KEEP    ' + client.Id + '  ' + client.Name;
					}
				}
			}

			if (!String.isBlank(textError)) {
				return textError;
			}

			if (!updateAccounts.isEmpty()) {
				update updateAccounts;

				if (onlyDeletes) {
					updateBenefitsAffiliates(idRecord);
				}
			}

			return null;
		} catch (Exception e) {
            return 'Exception: ' + e.getMessage();
		}
	}

	/**
	 * @description getAffiliatedAccounts retrieves the affiliated accounts for the given
	 * Benefits Affiliates identifier.
	 * @param  idAffiliates  Identifier of the Benefits Affiliates record
	 * @return List<Account>
	 */
	@TestVisible
	private static Benefits_Affiliates__c getBenefitsAffiliated(Id idAffiliates) {
		return BenefitsAffiliates.selectAffiliates(new Set<Id>{idAffiliates}).get(idAffiliates);
	}

	/**
	 * @description getAffiliatedAccounts retrieves the affiliated accounts for the given
	 * Benefits Affiliates identifier.
	 * @param  idAffiliates  Identifier of the Benefits Affiliates record
	 * @return List<Account>
	 */
	@TestVisible
	private static List<Account> getAffiliatedAccounts(Id idAffiliates) {
		return [
			SELECT Id, Name, Benefits_Affiliates__c, Benefits__c
			FROM Account
			WHERE Benefits_Affiliates__c = :idAffiliates
			ORDER BY Name ASC
		];
	}

	/**
	 * @description updateBenefitsAffiliates forces an update on the given Benefits Affliates.
	 * @param idAffiliates  Benefits Affilaites identifiers
	 */
	@TestVisible
	private static void updateBenefitsAffiliates(Id idAffiliates) {
		Map<Id, Benefits_Affiliates__c> affiliates = BenefitsAffiliates.selectAffiliates(new Set<Id>{idAffiliates});

		List<Benefits_Affiliates__c> changed = new List<Benefits_Affiliates__c>();

		for (Benefits_Affiliates__c ba : affiliates.values()) {
			changed.add(
				new Benefits_Affiliates__c(
					Id = ba.Id,
					Toggle_Update__c = !ba.Toggle_Update__c
				)
			);
		}

		update changed;
	}
}