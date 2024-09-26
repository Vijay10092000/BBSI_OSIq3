/**
 * @description BenefitsAffiliatesBenefits contains methods to handle the object
 * Benefits Affiliates on Benefits__c Records.
 */
public without sharing class BenefitsAffiliatesBenefits {
	/**
	 * @description checkCommonOwnership handles a change to Is Common Ownership flag on
	 * Opportunity.  A change to the flag will either create a related Benefits Affiliates
	 * record or delete it.
	 * @param  mapOld   Benefits__cs before changes
	 * @param  listNew  Benefits__cs after changes
	 */
	public static void checkCommonOwnership(Map<Id, Benefits__c> mapOld, List<Benefits__c> listNew) {
		Set<Id> deleteAffiliates = new Set<Id>();

		Map<Id, Benefits__c> newAffiliates = new Map<Id, Benefits__c>();

		for (Benefits__c benefits : listNew) {
			if (benefits.Is_there_common_ownership__c == 'Yes') {
				if (mapOld == null || mapOld.get(benefits.Id).Is_there_common_ownership__c != 'Yes') {
					if (benefits.Benefits_Affiliates__c == null) {
						newAffiliates.put(benefits.AccountId__c, benefits);
					}
				}
			} else {
				if (mapOld != null && mapOld.get(benefits.Id).Is_there_common_ownership__c == 'Yes') {
					if (benefits.Benefits_Affiliates__c != null) {
						deleteAffiliates.add(benefits.Benefits_Affiliates__c);
					}
				}
			}
		}

		List<Benefits_Affiliates__c> affiliates = BenefitsAffiliates.make(newAffiliates);
		if (!affiliates.isEmpty()) {
			insert affiliates;
		}

		if (!deleteAffiliates.isEmpty()) {
			BenefitsAffiliates.deleteAffiliates(deleteAffiliates);
		}
	}

	/**
	 * @description updateRelatedRecords updates related Accounts or if the Benefits
	 * has a Benefits Affiliates it updates that which will update its related clients.
	 * @param  newBenefits  List of Benefits__c
	 */
	public static void updateRelatedRecords(List<Benefits__c> newBenefits) {
		Set<Id> idPrimaries = new Set<Id>();
		Set<Id> idAffiliates = new Set<Id>();

		for (Benefits__c b : newBenefits) {
			if (b.Benefits_Affiliates__c == null) {
				idPrimaries.add(b.AccountId__c);
			} else {
				idAffiliates.add(b.Benefits_Affiliates__c);
			}
		}

		idPrimaries.remove(null);
		idAffiliates.remove(null);

		List<Account> updateClients = new List<Account>();
		List<Benefits_Affiliates__c> updateAffiliates = new List<Benefits_Affiliates__c>();

		Map<Id, Account> clients = BenefitsAffiliatesAccount.selectAccounts(idPrimaries);
		System.debug('==================  clients.size = ' + clients.size());
		MAp<Id, Benefits_Affiliates__c> affiliates = BenefitsAffiliates.selectAffiliates(idAffiliates);
		System.debug('==================  affiliates.size = ' + idAffiliates.size());

		for (Benefits__c b : newBenefits) {
			if (affiliates.containsKey(b.Benefits_Affiliates__c)) {
				Benefits_Affiliates__c affiliate = affiliates.get(b.Benefits_Affiliates__c);

				if (BenefitsAffiliatesUpdates.updateRelated(affiliate, b)) {
					updateAffiliates.add(affiliate);
				}
			} else if (clients.containsKey(b.AccountId__c)) {
				if(!Benefits_Service.companiesNeedtoUpdate.isEmpty() && Benefits_Service.companiesNeedtoUpdate.containsKey(b.AccountId__c)){
					Account client = Benefits_Service.companiesNeedtoUpdate.get(b.AccountId__c);
					if (BenefitsAffiliatesUpdates.updateRelated(client, b)) {
						Benefits_Service.companiesNeedtoUpdate.put(client.Id,client);
					}
				}	
				else{
					Account client = clients.get(b.AccountId__c);
					if (BenefitsAffiliatesUpdates.updateRelated(client, b)) {
						updateClients.add(client);
					}
				}			
			}
		}
		if(!updateClients.isEmpty()){
			update updateClients;
		}
		if(!updateAffiliates.isEmpty()){
			update updateAffiliates;
		}
	}

	/**
	 * @description selectBenefits reads the Benefits fields of the given Benefits identifiers.
	 * @param idBenefits  Benefits identifiers
	 * @return Map<Id, Benefits__c>
	 */
	public static Map<Id, Benefits__c> selectBenefits(Set<Id> idBenefits) {
		Map<Id, Benefits__c> result = new Map<Id, Benefits__c>(
			[
				SELECT
					Id,
					OwnerId,
					Name,
					AccountId__c,
					Opportunity__c,
					Benefits_Affiliates__c,
					Benefits_Type__c,
					Benefits_Affiliated_Companies__c,
					Benefits_Specialist__c,
					Benefits_Coordinator__c,
					Active_Employees_All_Affiliates__c,
					Full_Time_Employees_All_Affiliates__c,
					Part_Time_Employees_All_Affiliates__c
				FROM Benefits__c
				WHERE Id IN :idBenefits
			]
		);

		String textDebug = 'BenefitsAffiliatesBenefits.selectBenefits';
		for (Benefits__c b : result.values()) {
			textDebug += '\nBENEFITS: ' + b.Id + '  '     + b.Name;
			textDebug += '\n  OwnerId'                    + b.OwnerId;
			textDebug += '\n  Opportunity__c'             + b.Opportunity__c;
			textDebug += '\n  Benefits_Specialist__c: '   + b.Benefits_Specialist__c;
			textDebug += '\n  Benefits_Coordinator__c: '  + b.Benefits_Coordinator__c;
			textDebug += '\n  Benefits_Affiliated_Companies__c: '  + b.Benefits_Affiliated_Companies__c;
		}
		System.debug(LoggingLevel.DEBUG, textDebug);

		return result;
	}

	/**
	 * @description selectBenefitsByAffiliates reads the Account Benefits records for the given ids.
	 * @param idAffiliates  BenefitsByAffiliates identifiers
	 * @return Map<Id, Account>
	 */
	public static Map<Id, Benefits__c> selectBenefitsByAffiliates(Set<Id> idAffiliates) {
		Map<Id, Benefits__c> result = new Map<Id, Benefits__c>(
			[
				SELECT
					Id,
					OwnerId,
					Name,
					AccountId__c,
					Opportunity__c,
					Benefits_Affiliates__c,
					Benefits_Type__c,
					Benefits_Affiliated_Companies__c,
					Benefits_Specialist__c,
					Benefits_Coordinator__c,
					Active_Employees_All_Affiliates__c,
					Full_Time_Employees_All_Affiliates__c,
					Part_Time_Employees_All_Affiliates__c
				FROM Benefits__C
				WHERE Benefits_Affiliates__c IN :idAffiliates
				ORDER BY Benefits_Affiliates__c ASC
			]
		);

		String textDebug = 'BenefitsAffiliatesBenefits.selectBenefitsByAffiliates';
		for (Benefits__c b : result.values()) {
			textDebug += '\nBENEFITS: ' + b.Id + '  '     + b.Name;
			textDebug += '\n  OwnerId'                    + b.OwnerId;
			textDebug += '\n  Opportunity__c'             + b.Opportunity__c;
			textDebug += '\n  Benefits_Specialist__c: '   + b.Benefits_Specialist__c;
			textDebug += '\n  Benefits_Coordinator__c: '  + b.Benefits_Coordinator__c;
			textDebug += '\n  Benefits_Affiliated_Companies__c: '  + b.Benefits_Affiliated_Companies__c;
		}
		System.debug(LoggingLevel.DEBUG, textDebug);

		return result;
	}

	/**
	 * @description selectBenefitsByName reads the Account Benefits records for the given names.
	 * @param names   BenefitsByAffiliates names
	 * @return Map<Id, Benefits__c>
	 */
	public static Map<Id, Benefits__c> selectBenefitsByName(Set<String> names) {
		Map<Id, Benefits__c> result = new Map<Id, Benefits__c>(
			[
				SELECT
					Id,
					OwnerId,
					Name,
					AccountId__c,
					Opportunity__c,
					Benefits_Affiliates__c,
					Benefits_Type__c,
					Benefits_Affiliated_Companies__c,
					Benefits_Specialist__c,
					Benefits_Coordinator__c,
					Active_Employees_All_Affiliates__c,
					Full_Time_Employees_All_Affiliates__c,
					Part_Time_Employees_All_Affiliates__c
				FROM Benefits__C
				WHERE Name IN :names
				ORDER BY Benefits_Affiliates__c ASC
			]
		);

		String textDebug = 'BenefitsAffiliatesBenefits.selectBenefitsByName';
		for (Benefits__c b : result.values()) {
			textDebug += '\nBENEFITS: ' + b.Id + '  '     + b.Name;
			textDebug += '\n  OwnerId'                    + b.OwnerId;
			textDebug += '\n  Opportunity__c'             + b.Opportunity__c;
			textDebug += '\n  Benefits_Specialist__c: '   + b.Benefits_Specialist__c;
			textDebug += '\n  Benefits_Coordinator__c: '  + b.Benefits_Coordinator__c;
			textDebug += '\n  Benefits_Affiliated_Companies__c: '  + b.Benefits_Affiliated_Companies__c;
		}
		System.debug(LoggingLevel.DEBUG, textDebug);

		return result;
	}

	/**
	 * @description selectBenefitsByAccounts reads the Benefits records for the given ids.
	 * @param idAccounts Accounts getting Benefits for.
	 * @return Map<Id, Benefits__c>
	 */
	public static Map<Id, Benefits__c> selectBenefitsByAccounts(Set<Id> idAccounts) {
		Map<Id, Benefits__c> result = new Map<Id, Benefits__c>(
			[
				SELECT
					Id,
					OwnerId,
					Name,
					AccountId__c,
					Opportunity__c,
					Benefits_Affiliates__c,
					Benefits_Type__c,
					Benefits_Affiliated_Companies__c,
					Benefits_Specialist__c,
					Benefits_Coordinator__c,
					Active_Employees_All_Affiliates__c,
					Full_Time_Employees_All_Affiliates__c,
					Part_Time_Employees_All_Affiliates__c
				FROM Benefits__c
				WHERE AccountId__c IN :idAccounts
			]
		);

		String textDebug = 'BenefitsAffiliatesBenefits.selectBenefitsByName';
		for (Benefits__c b : result.values()) {
			textDebug += 'BENEFITS: ' + b.Id + '  '     + b.Name;
			textDebug += '  OwnerId'                    + b.OwnerId;
			textDebug += '  Opportunity__c'             + b.Opportunity__c;
			textDebug += '  Benefits_Specialist__c: '   + b.Benefits_Specialist__c;
			textDebug += '  Benefits_Coordinator__c: '  + b.Benefits_Coordinator__c;
			textDebug += '\n  Benefits_Affiliated_Companies__c: '  + b.Benefits_Affiliated_Companies__c;
		}
		System.debug(LoggingLevel.DEBUG, textDebug);

		return result;
	}

	/**
	 * @description getBenefitContacts retrieves Benefits Contacts for the given Account ids (Clients).
	 * @param  idAccounts  Account Ids searching
	 * @return Map<Id, Contact>
	 */
	public static Map<Id, Contact> getBenefitContacts(Set<Id> idAccounts) {
		Map<Id, Contact> result = new Map<Id, Contact>();

		for (Id id : idAccounts) {
			result.put(id, null);
		}

		String query =
			SOQL_Services.getFullObjectQuery('Contact') +
			' WHERE AccountId IN :idAccounts' +
			' AND Active__c = TRUE' +
			' AND Benefits_Contact__c = TRUE' +
			' ORDER BY CreatedDate ASC';

		List<Contact> contacts = Database.query(query);

		for (Contact contact : contacts) {
			result.put(contact.AccountId, contact);
		}

		return result;
	}

	/**
	 * @description updateRelatedBenefitsAffiliates updates Benefits Affiliates related
	 * to the Benefits changes.
	 * @param  oldBenefits  Benefits__c before changes
	 * @param  newBenefits  Benefits__c with changes
	 */
	/* DELETE
	public static void updateRelatedBenefitsAffiliates(
		Map<Id, Benefits__c> oldBenefits,
		List<Benefits__c> newBenefits
	) {
		Set<Id> idAffiliates = new Set<Id>();

		for (Benefits__c b : newBenefits) {
			idAffiliates.add(b.Benefits_Affiliates__c);
		}

		idAffiliates.remove(null);

		if (!idAffiliates.isEmpty()) {
			Map<Id, Benefits_Affiliates__c> affiliates = BenefitsAffiliates.selectAffiliates(idAffiliates);

			List<Benefits_Affiliates__c> changedAffiliates = new List<Benefits_Affiliates__c>();

			for (Benefits__c b : newBenefits) {
				Benefits_Affiliates__c ba = affiliates.get(b.Benefits_Affiliates__c);

				if (BenefitsAffiliatesUpdates.updateRelated(ba, b)) {
					System.debug('*************************** Changing AFFILATES FROM BENEFITS');
					changedAffiliates.add(ba);
				}
			}

			update changedAffiliates;
		}
	}
	*/

	/**
	 * @description updateRelatedRecords updates the related Accounts based on changes to a Benefits__c.
	 * @param  oldBenefits  Benefits__c before changes
	 * @param  newBenefits  Benefits__c with changes
	 */
	/* DELETE
	public static void updateRelatedRecords(Map<Id, Benefits__c> oldBenefits, List<Benefits__c> newBenefits) {
		Map<Id, Benefits__c> accountsToBenefits = new Map<Id, Benefits__c>();

		for (Benefits__c b : newBenefits) {
			accountsToBenefits.put(b.AccountId__c, b);
		}

		accountsToBenefits.remove(null);

		if (accountsToBenefits.isEmpty()) {
			return;
		}

		List<Account> updateAccounts = new List<Account>();

		Map<Id, Account> accounts = BenefitsAffiliatesAccount.selectAccounts(accountsToBenefits.keySet());

		for (Account client : accounts.values()) {
			Benefits__c b = accountsToBenefits.get(client.Id);

			if (BenefitsAffiliatesUpdates.updateRelated(client, b)) {
				updateAccounts.add(client);
			}
		}

		update updateAccounts;
	}
	*/
}