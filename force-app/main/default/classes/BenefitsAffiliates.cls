/**
 * @description BenefitsAffiliates contains methods to handle the object Benefits Affiliates.
 */
public without sharing class BenefitsAffiliates {
	public static final String ERROR_MUST_HAVE_PRIMARY_ACCOUNT = 'Primary Account must have a value.';
	public static final String ERROR_ONLY_ONE_BEFORE_DELETE = 'Cannot delete when there are multiple affiliated companies.';
	public static final String ERROR_NO_CHANGE_AFFILIATES = 'Cannot change Benefits affiliation.  Must remove first.';
	public static final String ERROR_MUST_REMOVE_MULTIPLES_BEFORE_DELETE = 'Must remove all but one affiliate before can delete.';
	public static final String ERROR_REMOVE_FROM_AFFILIATES_BEFORE_DELETE = 'Remove from Benefits Affiliates record before delete.';
	public static final String ERROR_PRIMARY_MUST_BELONG = 'Primary account must belong to the Benefits Affiliates.';

	/**
	 * @description make creates a Benefits Affiliations record based on the given
	 * parameters.
	 * @param  client          Account identifier
	 * @param  idOpp           Opportunity identifier
	 * @param  idBenefits      Benefits__c identifiter
	 * @param  coordinator     User Id of Benefits Coordinator
	 * @param  representative  User Id of Benefits Representative
	 * @return Benefits_Affiliates__c
	 */
	private static Benefits_Affiliates__c make(
		Account client,
		Id idOpp,
		Id idBenefits,
		Id coordinator,
		Id representative
	) {
		if (representative == null) {
			representative = UserInfo.getUserId();
		}

		String clientId = (client.External_Id__c == null) ? '' : client.External_Id__c;

		return new Benefits_Affiliates__c(
			OwnerId = representative,
			Name = client.Name,
			Primary_Account__c = client.Id,
			Benefits__c = idBenefits,
			Benefits_Coordinator__c = coordinator,
			Benefits_Representative__c = representative,
			Benefits_Opportunity__c = idOpp,
			Benefits_Affiliated_Companies__c = clientId + '  ' + client.Name,
			Benefits_Affiliated_Companies_Count__c = 1,
			Active_Employees_All_Affiliates__c = Sobject_Services.getValue(client.NumberOfEmployees, 0),
			Full_Time_Employees_All_Affiliates__c = Sobject_Services.getValue(client.Active_Employees_Full_Time__c, 0),
			Part_Time_Employees_All_Affiliates__c = Sobject_Services.getValue(client.Active_Employees_Part_Time__c, 0)
		);
	}

	/**
	 * @description make creates a Benefits Affiliations record based on a Benefits Opportunity.
	 * @param  toMake   Account Id to Opportunity information
	 * @return Benefits_Affiliates__c
	 */
	public static List<Benefits_Affiliates__c> make(Map<Id, Opportunity> toMake) {
		Map<Id, Account> accounts = BenefitsAffiliatesAccount.selectAccounts(toMake.keySet());

		List<Benefits_Affiliates__c> result = new List<Benefits_Affiliates__c>();

		for (Id idAccount : toMake.keySet()) {
			Opportunity opp = toMake.get(idAccount);

			if (opp.Benefits_Consultant__c == null) {
				opp.addError('Benefits_Consultant__c not set so cannot create Benefits Affiliates.');
			} else {
				Account client = accounts.get(idAccount);

				Benefits_Affiliates__c ba = make(
					client,
					opp.Id,
					null,
					opp.Benefits_Coordinator__c,
					client.Benefits_Representative__c
				);
				result.add(ba);
			}
		}

		return result;
	}

	/**
	 * @description make creates a Benefits Affiliations record based on a Benefits record.
	 * @param  toMake   AccountId to Benefits information
	 * @return Benefits_Affiliates__c
	 */
	public static List<Benefits_Affiliates__c> make(Map<Id, Benefits__c> toMake) {
		Map<Id, Account> accounts = BenefitsAffiliatesAccount.selectAccounts(toMake.keySet());

		List<Benefits_Affiliates__c> result = new List<Benefits_Affiliates__c>();

		for (Id idAccount : toMake.keySet()) {
			Benefits__c benefits = toMake.get(idAccount);

			if (benefits.Benefits_Specialist__c == null) {
				benefits.addError('Benefits_Specialist__c not set so cannot create Benefits Affiliates.');
			} else {
				Benefits_Affiliates__c ba = make(
					accounts.get(idAccount),
					benefits.Opportunity__c,
					benefits.Id,
					benefits.Benefits_Coordinator__c,
					benefits.Benefits_Specialist__c
				);
				result.add(ba);
			}
		}

		return result;
	}

	/**
	 * @description selectAffiliates reads a List of Benefits_Affiliates__c records
	 * by their identifiers.
	 * @param  idAffiliates  Benefits_Affiliates__c identifiers
	 * @return Map<Id, Benefits_Affiliates__c>
	 */
	public static Map<Id, Benefits_Affiliates__c> selectAffiliates(Set<Id> idAffiliates) {
		return new Map<Id, Benefits_Affiliates__c>(
			[
				SELECT
					Id,
					Name,
					OwnerId,
					Active_Employees_All_Affiliates__c,
					Benefits__c,
					Benefits_Affiliated_Companies_Count__c,
					Benefits_Affiliated_Companies__c,
					Benefits_Coordinator__c,
					Benefits_Opportunity__c,
					Benefits_Opportunity_Stage__c,
					Benefits_Representative__c,
					Benefits_Type__c,
					Full_Time_Employees_All_Affiliates__c,
					Part_Time_Employees_All_Affiliates__c,
					Primary_Account__c,
					Toggle_Update__c,
					Primary_Account__r.Is_there_a_benefits_referral_partner__c, 
					Primary_Account__r.Benefits_Effective_Date__c,
					Primary_Account__r.BBSI_Benefits_Renewal_Date__c
				FROM Benefits_Affiliates__c
				WHERE Id IN :idAffiliates
			]
		);
	}

	/**
	 * @description selectAffiliates reads a List of Benefits_Affiliates__c records
	 * by their names.
	 * @param  names  Benefits_Affiliates__c names
	 * @return Map<Id, Benefits_Affiliates__c>
	 */
	public static Map<Id, Benefits_Affiliates__c> selectAffiliates(Set<String> names) {
		return new Map<Id, Benefits_Affiliates__c>(
			[
				SELECT
					Id,
					Name,
					OwnerId,
					Active_Employees_All_Affiliates__c,
					Benefits__c,
					Benefits_Affiliated_Companies_Count__c,
					Benefits_Affiliated_Companies__c,
					Benefits_Coordinator__c,
					Benefits_Opportunity__c,
					Benefits_Opportunity_Stage__c,
					Benefits_Representative__c,
					Benefits_Type__c,
					Full_Time_Employees_All_Affiliates__c,
					Part_Time_Employees_All_Affiliates__c,
					Primary_Account__c,
					Toggle_Update__c
				FROM Benefits_Affiliates__c
				WHERE Name IN :names
			]
		);
	}

	/**
	 * @description confirmInitialData called from BEFORE INSERT Trigger to initialize values.
	 * Called for Trigger Before Insert
	 * @param  newAffiliates newAffiliates description
	 */
	public static void confirmInitialData(List<Benefits_Affiliates__c> newAffiliates) {
		for (Benefits_Affiliates__c affiliate : newAffiliates) {
			if (affiliate.Primary_Account__c == null) {
				affiliate.addError(ERROR_MUST_HAVE_PRIMARY_ACCOUNT);
			}
		}
	}

	/**
	 * @description updateFromBenefits confirms Owner is correct
	 * Called for Trigger Before Insert/Update
	 * @param  oldAffiliates Benefits_Affiliates__c before changes
	 * @param  newAffiliates Benefits_Affiliates__c with changes
	 */
	public static void updateFromBenefits(Map<Id, Benefits_Affiliates__c> oldAffiliates, List<Benefits_Affiliates__c> newAffiliates) {
		Set<Id> idOpps = new Set<id>();
		List<Benefits_Affiliates__c> changedAffiliates = new List<Benefits_Affiliates__c>();

		for (Benefits_Affiliates__c affiliate : newAffiliates) {
			if (affiliate.Benefits__c != null) {
				if (oldAffiliates == null || oldAffiliates.get(affiliate.Id).Benefits__c != affiliate.Benefits__c) {
					idOpps.add(affiliate.Benefits_Opportunity__c);
					changedAffiliates.add(affiliate);
				}
			}
		}
		idOpps.remove(null);

		if (!idOpps.isEmpty()) {
			Map<Id, Opportunity> opps = BenefitsAffiliatesOpportunity.selectOpportunities(idOpps);

			for (Benefits_Affiliates__c affiliate: changedAffiliates) {
				if (opps.containsKey(affiliate.Benefits_Opportunity__c)) {
					Opportunity opp = opps.get(affiliate.Benefits_Opportunity__c);

					if (opp.Benefits_Specialist__c != null) {
						affiliate.OwnerId = opp.Benefits_Specialist__c;
						affiliate.Benefits_Representative__c = opp.Benefits_Specialist__c;
					}
				}
			}
		}
	}


	/**
	 * @description setCounts adds employees of affiliated accounts.
	 * @param affiliates  Benefits Affiliates
	 */
	public static void setCounts(Map<Id, Benefits_Affiliates__c> affiliates) {
		Map<Id, Account> accounts = BenefitsAffiliatesAccount.selectAccountsByAffiliates(affiliates.keySet());
		System.debug('BenefitsAffiliates :: setCounts :: accounts ::' + accounts);

		for (Benefits_Affiliates__c affiliate : affiliates.values()) {
			affiliate.Benefits_Affiliated_Companies__c = '';
			affiliate.Benefits_Affiliated_Companies_Count__c = 0;
			affiliate.Active_Employees_All_Affiliates__c = 0;
			affiliate.Full_Time_Employees_All_Affiliates__c = 0;
			affiliate.Part_Time_Employees_All_Affiliates__c = 0;
			System.debug('BenefitsAffiliates :: setCounts :: cleared count in affiliate ::' + affiliate);
		}

		Benefits_Affiliates__c affiliate;
		String clientId;

		for (Account account : accounts.values()) {
			if (affiliates.containsKey(account.Benefits_Affiliates__c)) {
				affiliate = affiliates.get(account.Benefits_Affiliates__c);

				if (!String.isBlank(affiliate.Benefits_Affiliated_Companies__c)) {
					affiliate.Benefits_Affiliated_Companies__c += ',\n';
				}

				clientId = (account.External_Id__c == null) ? '' : account.External_Id__c;

				affiliate.Benefits_Affiliated_Companies__c += clientId + '  ' + account.Name;
				affiliate.Benefits_Affiliated_Companies_Count__c += 1;

				affiliate.Active_Employees_All_Affiliates__c += Sobject_Services.getValue(account.NumberOfEmployees, 0);
				affiliate.Full_Time_Employees_All_Affiliates__c += Sobject_Services.getValue(
					account.Active_Employees_Full_Time__c,
					0
				);
				affiliate.Part_Time_Employees_All_Affiliates__c += Sobject_Services.getValue(
					account.Active_Employees_Part_Time__c,
					0
				);
			}
			System.debug('BenefitsAffiliates :: setCounts :: set count in affiliate ::' + affiliate);
		}
	}

	/**
	 * @description checkDeletionAllowed puts an error on records which cannot be deleted at this time.
	 * Trigger: Before Delete
	 * @param  oldAffiliates   Benefits_Affiliates__c before delete
	 */
	public static void checkDeletionAllowed(Map<Id, Benefits_Affiliates__c> oldAffiliates) {
		for (Benefits_Affiliates__c affiliate : oldAffiliates.values()) {
			if (1 < affiliate.Benefits_Affiliated_Companies_Count__c) {
				affiliate.addError(ERROR_MUST_REMOVE_MULTIPLES_BEFORE_DELETE);
			}
		}
	}

	/**
	 * @description updatePrimaryRecords updates the company information and other data on
	 * records related to the Benefits Affiliates.  Accounts, Opportunities, and Benefits
	 * records.
	 * @param  newAffiliates  Benefits Affliates with changes
	 */
	public static void updatePrimaryRecords(Map<Id, Benefits_Affiliates__c> newAffiliates) {
		Set<Id> idPrimaries = new Set<Id>();
		Set<Id> idOpps = new Set<Id>();
		Set<Id> idBenefits = new Set<Id>();

		for (Benefits_Affiliates__c affiliate : newAffiliates.values()) {
			idPrimaries.add(affiliate.Primary_Account__c);
			idOpps.add(affiliate.Benefits_Opportunity__c);
			idBenefits.add(affiliate.Benefits__c);
		}

		idPrimaries.remove(null);
		idOpps.remove(null);
		idBenefits.remove(null);

		Map<Id, Account> primaries = BenefitsAffiliatesAccount.selectAccounts(idPrimaries);
		Map<Id, Opportunity> opps = BenefitsAffiliatesOpportunity.selectOpportunities(idOpps);
		Map<Id, Benefits__c> benefits = BenefitsAffiliatesBenefits.selectBenefits(idBenefits);

		for (Benefits_Affiliates__c ba : newAffiliates.values()) {
			Account p = primaries.get(ba.Primary_Account__c);
			BenefitsAffiliatesUpdates.updateRelated(p, ba);

			if (opps.containsKey(ba.Benefits_Opportunity__c)) {
				Opportunity o = opps.get(ba.Benefits_Opportunity__c);

				BenefitsAffiliatesUpdates.updateRelated(o, ba);
				o.Benefits_Affiliates__c = ba.Id;
				o.AccountId = ba.Primary_Account__c;
			}

			if (benefits.containsKey(ba.Benefits__c)) {
				Benefits__c b = benefits.get(ba.Benefits__c);

				BenefitsAffiliatesUpdates.updateRelated(b, ba);
				b.AccountId__c = ba.Primary_Account__c;

				p.BBSI_Benefits__c = true;
			} else {
				p.BBSI_Benefits__c = false;
			}

			p.Benefits_Affiliates__c = ba.Id;

		}

		update opps.values();
		update benefits.values();
		update primaries.values();

		BenefitsAffiliatesUpdate_Queueable.updateRelatedRecords(newAffiliates.keySet());
	}

	/**
	 * @description updateRelatedRecords updates the records related to this Benefits Affiliates
	 * (Accounts, Opportunities, and Benefits).
	 * @param  newAffiliates  Benefits Affliates with changes
	 */
	public static void updateRelatedRecords(Map<Id, Benefits_Affiliates__c> newAffiliates) {
		BenefitsAffiliatesUpdate_Queueable.updateRelatedRecords(newAffiliates.keySet());
	}

	/**
	 * @description clearRelatedRecords clears Benefits Affiliates related data on a delete of the
	 * Benefits Affiliation.  Clears the affiliation data from the clients, Opportunities and Benefits.
	 * @param  oldAffiliates  Benefits Affiliates before delete
	 */
	public static void clearRelatedRecords(Map<Id, Benefits_Affiliates__c> oldAffiliates) {
		Set<Id> idAffiliates = new Set<Id>();

		for (Benefits_Affiliates__c ba : oldAffiliates.values()) {
			if (!ba.hasErrors()) {
				idAffiliates.add(ba.Id);
			}
		}

		if (idAffiliates.isEmpty()) {
			return;
		}

		Map<Id, Account> clients = BenefitsAffiliatesAccount.selectAccountsByAffiliates(idAffiliates);
		Map<Id, Opportunity> opps = BenefitsAffiliatesOpportunity.selectOpportuntiesByAffiliates(idAffiliates);
		Map<Id, Benefits__c> benefits = BenefitsAffiliatesBenefits.selectBenefitsByAffiliates(idAffiliates);
		Map<Id, Account> branches = getRelatedBranches(clients.values());

		for (Account client : clients.values()) {
			BenefitsAffiliatesUpdates.clearAffiliatesData(client, branches.get(client.Prospect_Branch__c), benefits.values());
		}

		for (Opportunity opp : opps.values()) {
			BenefitsAffiliatesUpdates.clearAffiliatesData(opp, clients.get(opp.AccountId), branches.get(opp.AccountId));
		}

		for (Benefits__c b : benefits.values()) {
			BenefitsAffiliatesUpdates.clearAffiliatesData(b, clients.get(b.AccountId__c), branches.get(b.AccountId__c));
		}

		DatabaseUpdateBatch.dispatch(clients.values(), false, 'Benefits Affiliates', 'Clear Affiliate Data From Accounts Failed');
		DatabaseUpdateBatch.dispatch(opps.values(), false, 'Benefits Affiliates', 'Clear Affiliate Data From Opportunties Failed');
		DatabaseUpdateBatch.dispatch(benefits.values(), false, 'Benefits Affiliates', 'Clear Affiliate Data From Benefits__c Failed');
	}

	/**
	 * @description confirmPrimaryAccount confirms the Primary Account is in the affiliation.
	 * @param  oldBAs  Benefits Affiliates before changes
	 * @param  newBAs  Benefits Affiliates with changes
	 */
	public static void confirmPrimaryAccount(
		Map<Id, Benefits_Affiliates__c> oldBAs,
		Map<Id, Benefits_Affiliates__c> newBAs
	) {
		Map<Id, Id> idTestClient = new Map<Id, Id>();

		for (Benefits_Affiliates__c affiliate : newBAs.values()) {
			if (affiliate.Primary_Account__c == null) {
				affiliate.addError(ERROR_MUST_HAVE_PRIMARY_ACCOUNT);
			} else {
				Benefits_Affiliates__c oldaffiliate = oldBAs.get(affiliate.Id);

				if (affiliate.Primary_Account__c != oldaffiliate.Primary_Account__c) {
					idTestClient.put(affiliate.Primary_Account__c, affiliate.Id);
				}
			}
		}

		if (!idTestClient.isEmpty()) {
			Map<Id, Account> testAccounts = BenefitsAffiliatesAccount.selectAccounts(idTestClient.keySet());

			for (Account client : testAccounts.values()) {
				Id idAffiliate = idTestClient.get(client.Id);

				if (client.Benefits_Affiliates__c != idAffiliate) {
					Benefits_Affiliates__c affiliate = newBAs.get(idAffiliate);
					affiliate.addError(ERROR_PRIMARY_MUST_BELONG);
				}
			}
		}
	}

	/**
	 * @description getRelatedBranches retrieves the related Branches to the given
	 * Accounts.
	 * @param  accounts  Accounts looking at
	 * @return Map<Id, Account>
	 */
	private static Map<Id, Account> getRelatedBranches(List<Account> accounts) {
		Set<Id> idBranches = new Set<Id>();

		for (Account a : accounts) {
			idBranches.add(a.Prospect_Branch__c);
		}
		idBranches.remove(null);

		return new Map<Id, Account>([SELECT Id, Name, Benefits_Consultant__c FROM Account WHERE Id IN :idBranches]);
	}

	/**
	 * @description deleteAffiliates delete Benefits Affiliates from identifiers.
	 * @param  idAffiliates  Benefits Affiliates identifiers
	 */
	public static void deleteAffiliates(Set<Id> idAffiliates) {
		if (idAffiliates != null && !idAffiliates.isEmpty()) {
			List<Benefits_Affiliates__c> affiliates = new List<Benefits_Affiliates__c>();

			for (Id idAffliate : idAffiliates) {
				affiliates.add(new Benefits_Affiliates__c(Id = idAffliate));
			}

			delete affiliates;
		}
	}

	/**
	 * @description clearAffiliatesData updates Benefits by removing data about a Benefits Affiliates.
	 * @param  benefits  Benefits__c
	 * @param  account   Account related to the Benefits
	 * @param  branch    Related Branch
	 */
	public static void clearAffiliatesData(Benefits__c benefits, Account account, Account branch) {
		benefits.Benefits_Affiliates__c = null;
		benefits.Benefits_Affiliated_Companies__c = null;
		benefits.Is_there_common_ownership__c = 'No';
		benefits.Active_Employees_All_Affiliates__c = 0;
		benefits.Full_Time_Employees_All_Affiliates__c = 0;
		benefits.Part_Time_Employees_All_Affiliates__c = 0;
	}
}