/**
 * @description BenefitsAffiliatesAccount contains methods to handle the object
 * Benefits Affiliates on Account Records.
 */
public without sharing class BenefitsAffiliatesAccount {
	public static final String ERROR_NO_CHANGE_AFFILIATES = 'Cannot change Benefits affiliation.  Must remove first.';
	public static final String ERROR_BLOCK_REMOVE_PRIMARY = 'Cannot remove the primary account from a Benefits Affiliates';

	/**
	 * @description BenefitsAffiliatesAccountHandler handles changes to the Client Accounts
	 * with Benefits related changes.
	 */
	private without sharing class BenefitsAffiliatesAccountHandler {
		private Boolean haveClients;

		private Set<Id> idAffiliates;
		private Map<Id, Account> oldClients;
		private List<Account> newAccounts;
		private Map<Id, Account> newClients;
		private Map<Id, Account> branches;
		private List<Account> removedClients;
		private List<Account> addedClients;
		private Map<Id, Benefits_Affiliates__c> affiliates;

		/**
		 * @description BenefitsAffiliatesAccountHandler constructor.
		 * @param  oldAccounts  Accounts before changes
		 * @param  newAccounts  Accounts with changes
		 */
		BenefitsAffiliatesAccountHandler(Map<Id, Account> oldAccounts, List<Account> newAccounts) {
			this.oldClients = oldAccounts;
			this.newAccounts = newAccounts;
		}

		/**
		 * @description handleBefore Benefits related stuff for BEFORE insert or update of Accounts.
		 */
		@SuppressWarnings('PMD.EmptyIfStmt, PMD.EmptyStatementBlock')
		public void handleBefore() {
			if (oldClients == null) {
				return;
			}
			newClients = Account_Services.onlyClientLikeAccounts(newAccounts);
			haveClients = !newClients.isEmpty();
			if (!haveClients) {
				return;
			}

			if (oldClients == null) {
				// INSERT has no changes
			} else {
				blockAffiliateChange();

				checkEmployeeChange();

				getRemovedFromAffiliates();
				getAddedToAffiliates();

				getWorkingAffiliateIds();

				selectBenefitsAffiliates(idAffiliates);

				if (!removedClients.isEmpty()) {
					blockRemovePrimary();
					updateRemovedClients();
				}

				if (!addedClients.isEmpty()) {
					updateAddedClients();
				}
			}
		}

		/**
		 * @description handleAfter Benefits related stuff for AFTER insert or update of Accounts.
		 */
		public void handleAfter() {
			branches = Account_Services.onlyBranches(newAccounts);

			newClients = Account_Services.onlyClientLikeAccounts(newAccounts);
			haveClients = !newClients.isEmpty();

			updateAccountBenefitsConsultantsFromBranches();


			if (oldClients != null && haveClients) {
				performBenefitsChanged();
				performReferralSourceChanges(); 
			}
		}

		/**
		 * @description blockAffiliateChange blocks the changing of Benefit Affiliations.
		 * An account cannot move from one affiliate to another, it must first be removed
		 * from the affliate and then added to the other.
		 */
		@TestVisible
		private void blockAffiliateChange() {
			if (oldClients != null) {
				for (Account client : newClients.values()) {
					if (client.Benefits_Affiliates__c != null) {
						Account oldClient = oldClients.get(client.Id);

						if (oldClient.Benefits_Affiliates__c != null) {
							if (client.Benefits_Affiliates__c != oldClient.Benefits_Affiliates__c) {
								client.addError(ERROR_NO_CHANGE_AFFILIATES);
							}
						}
					}
				}
			}
		}

		/**
		 * @description getAddedToAffiliates sets the addedClients to the clients added to a Benefits Affiliates.
		 */
		@TestVisible
		private void getAddedToAffiliates() {
			addedClients = new List<Account>();

			for (Account client : newClients.values()) {
				if (client.Benefits_Affiliates__c != null) {
					if (
						oldClients == null ||
						oldClients.get(client.Id).Benefits_Affiliates__c != client.Benefits_Affiliates__c
					) {
						addedClients.add(client);
					}
				}
			}
		}

		/**
		 * @description getRemovedFromAffiliates sets the removedClients to the clients removed from a Benefits Affiliates.
		 */
		@TestVisible
		private void getRemovedFromAffiliates() {
			removedClients = new List<Account>();

			if (oldClients != null) {
				for (Account client : newClients.values()) {
					Account oldClient = oldClients.get(client.Id);

					if (oldClient.Benefits_Affiliates__c != null) {
						if (client.Benefits_Affiliates__c != oldClient.Benefits_Affiliates__c) {
							removedClients.add(client);
						}
					}
				}
			}
		}

		/**
		 * @description getWorkingAffiliateIds runs through the added and removed Clients
		 * to retrieve the related Benefits Affliates identifiers.
		 */
		@TestVisible
		private void getWorkingAffiliateIds() {
			idAffiliates = new Set<Id>();

			for (Account client : addedClients) {
				idAffiliates.add(client.Benefits_Affiliates__c);
			}

			for (Account client : removedClients) {
				if (oldClients.containsKey(client.Id)) {
					idAffiliates.add(oldClients.get(client.Id).Benefits_Affiliates__c);
				}
			}

			idAffiliates.remove(null);
		}

		/**
		 * @description selectBenefitsAffiliates sets the affiliates to a map of Benefits Affiliates.
		 * @param idAffiliates  Identifiers of Benefits Affiliates
		 */
		@TestVisible
		private void selectBenefitsAffiliates(Set<Id> idAffiliates) {
			affiliates = BenefitsAffiliates.selectAffiliates(idAffiliates);
		}

		/**
		 * @description blockRemovePrimary stops the removal of the primary account
		 * on a Benefits Affilaites.
		 */
		@TestVisible
		private void blockRemovePrimary() {
			if (removedClients != null) {
				for (Account client : removedClients) {
					if (oldClients.containsKey(client.Id)) {
						Account oldClient = oldClients.get(client.Id);

						if (affiliates.containsKey(oldClient.Benefits_Affiliates__c)) {
							Benefits_Affiliates__c ba = affiliates.get(oldClient.Benefits_Affiliates__c);

							if (
								0 < ba.Benefits_Affiliated_Companies_Count__c &&
								oldClient.Id == ba.Primary_Account__c
							) {
								client.addError(ERROR_BLOCK_REMOVE_PRIMARY);
							}
						}
					}
				}
			}
		}

		private void checkEmployeeChange() {
			if (oldClients != null) {
				for (Account client : newAccounts) {
					Account oldClient = oldClients.get(client.Id);

					if (
						oldClient.NumberOfEmployees != client.NumberOfEmployees ||
						oldClient.Active_Employees_Full_Time__c != client.Active_Employees_Full_Time__c ||
						oldClient.Active_Employees_Part_Time__c != client.Active_Employees_Part_Time__c
					) {
						client.Active_Employees_All_Affiliates__c = 0;
						client.Full_Time_Employees_All_Affiliates__c = 0;
						client.Part_Time_Employees_All_Affiliates__c = 0;
					}
				}
			}
		}

		/**
		 * @description updateAddedClients set the added clients Benefits data to the Benefits Affiliates data.
		 */
		@TestVisible
		private void updateAddedClients() {
			if (!addedClients.isEmpty()) {
				Benefits_Affiliates__c ba;

				for (Account client : addedClients) {
					if (affiliates.containsKey(client.Benefits_Affiliates__c)) {
						ba = affiliates.get(client.Benefits_Affiliates__c);

						client.Benefits_Representative__c = ba.Benefits_Representative__c;
					}
				}
			}
		}

		/**
		 * @description updateRemovedClients clears Benefits Affiliates data from the Accounts.
		 */
		@TestVisible
		private void updateRemovedClients() {
			if (!removedClients.isEmpty()) {
				Set<Id> idBranches = new Set<Id>();
				Set<Id> idBAs = new Set<Id>();

				for (Account client : removedClients) {
					idBranches.add(client.Prospect_Branch__c);
					idBAs.add(client.Benefits_Affiliates__c);
				}

				Map<Id, Account> branches = new Map<Id, Account>(
					[SELECT Id, Benefits_Consultant__c FROM Account WHERE Id IN :idBranches]
				);
				Map<Id, Benefits__c> benefits = BenefitsAffiliatesBenefits.selectBenefitsByAffiliates(idBAs);

				for (Account client : removedClients) {
					BenefitsAffiliatesUpdates.clearAffiliatesData(
						client,
						branches.get(client.Prospect_Branch__c),
						benefits.values()
					);
				}
			}
		}

		/**
		 * @description performBenefitsChanged determines of the changes in the Accounts should
		 * cause changes to relate records.  If the Account is part of a Benefits Affiliates,
		 * then only it should be updated.  Else if the Account has a related Benefits record,
		 * it should be update.  Finally, if the Account has a related Benefits Opportunity that
		 * is OPEN, it should be updated.
		 */
		private void performBenefitsChanged() {
			Map<Id, Account> modifiedAccounts = modifiedBenefitsData();

			Set<Id> updateAffiliates = new Set<Id>();
			Map<Id, Account> updateBenefits = new Map<Id, Account>();
			Map<Id, Account> updateOpps = new Map<Id, Account>();

			for (Account client : modifiedAccounts.values()) {
				Account oldClient = oldClients.get(client.Id);

				if (oldClient.Benefits_Affiliates__c != client.Benefits_Affiliates__c) {
					// Added, changed or removed affiliation
					updateAffiliates.add(oldClient.Benefits_Affiliates__c);
					updateAffiliates.add(client.Benefits_Affiliates__c);
				} else if (client.Benefits_Affiliates__c != null) {
					// Part of an affiliation
					updateAffiliates.add(client.Benefits_Affiliates__c);
				} else if (client.Benefits__c != null) {
					// Have Benefits - Do now update the Opportunity
					updateBenefits.put(client.Benefits__c, client);
					//updateOpps.put(client.Id, client);
				} else {
					// Have Opportunity, but no Benefit
					updateOpps.put(client.Id, client);
				}
			}

			updateAffiliates.remove(null);

			update updateRelatedOpportunities(updateOpps);
			update updateRelatedBenefits(updateBenefits);
			update updatedRelatedAffiliates(updateAffiliates, modifiedAccounts.values());
		}

		/**
		 * @description modifiedBenefitsData determines the accounts which have made changes
		 * that need to be deployed through the Benefits system.
		 * @return Map<Id, Account>
		 */
		private Map<Id, Account> modifiedBenefitsData() {
			Map<Id, Account> result = new Map<Id, Account>();

			for (Account client : newClients.values()) {
				if (!BenefitsAffiliatesUpdates.sameAs(oldClients?.get(client.Id), client)) {
					result.put(client.Id, client);
				}
			}

			return result;
		}

		private List<Opportunity> updateRelatedOpportunities(Map<Id, Account> mapClientIdtoAccount) {
			Map<Id, Opportunity> result = new Map<Id, Opportunity>();

			if (mapClientIdtoAccount.isEmpty()) {
				return result.values();
			}

			Map<Id, Opportunity> opps = BenefitsAffiliatesOpportunity.selectOpportuntiesByAccounts(
				mapClientIdtoAccount.keySet()
			);

			for (Opportunity opp : opps.values()) {
				Account client = mapClientIdtoAccount.get(opp.AccountId);

				if (client.Benefits__c != null) {
					// Opportunties are not update once a Benefits is created.
					continue;
				}

				if (client.Benefits_Affiliates__c == null) {
					if (oldClients.get(client.Id).Benefits_Affiliates__c != null) {
						BenefitsAffiliatesUpdates.clearAffiliatesData(opp, client, null);
						result.put(opp.Id, opp);
					}

					if (BenefitsAffiliatesUpdates.updateRelated(opp, client)) {
						result.put(opp.Id, opp);
					}
				} else {
					if (BenefitsAffiliatesUpdates.updateRelated(opp, client)) {
						result.put(opp.Id, opp);
					}
				}
			}

			return result.values();
		}

		private List<Benefits__c> updateRelatedBenefits(Map<Id, Account> mapBenefitsToAccount) {
			Map<Id, Benefits__c> result = new Map<Id, Benefits__c>();

			if (mapBenefitsToAccount.isEmpty()) {
				return result.values();
			}

			Map<Id, Benefits__c> benefits = BenefitsAffiliatesBenefits.selectBenefits(mapBenefitsToAccount.keySet());

			for (Benefits__c b : benefits.values()) {
				Account client = mapBenefitsToAccount.get(b.id);

				if (client.Benefits_Affiliates__c == null) {
					if (b.Benefits_Affiliates__c != null) {
						BenefitsAffiliatesUpdates.clearAffiliatesData(b, client, null);
						result.put(b.Id, b);
					}

					if (BenefitsAffiliatesUpdates.updateRelated(b, client)) {
						result.put(b.Id, b);
					}
				} else {
					if (BenefitsAffiliatesUpdates.updateRelated(b, client)) {
						result.put(b.Id, b);
					}
				}
			}
			return result.values();
		}

		/**
		 * @description updatedRelatedAffiliates sends a message to the related Benefits Affiliates
		 * to update the affiliates records.
		 * @param  affiliates  Benefits Affiliates Ids
		 * @return Set of changed Benefits Affiliates
		 */
		private List<Benefits_Affiliates__c> updatedRelatedAffiliates(Set<Id> idAffiliates, List<Account> clients) {
			Map<Id, Benefits_Affiliates__c> result = new Map<Id, Benefits_Affiliates__c>();

			if (idAffiliates.isEmpty() || clients.isEmpty()) {
				return result.values();
			}

			Map<Id, Benefits_Affiliates__c> affiliates = BenefitsAffiliates.selectAffiliates(idAffiliates);

			for (Account client : clients) {
				if (affiliates.containsKey(client.Benefits_Affiliates__c)) {
					Benefits_Affiliates__c ba = affiliates.get(client.Benefits_Affiliates__c);

					if (BenefitsAffiliatesUpdates.updateRelated(ba, client)) {
						ba.Toggle_Update__c = true;
						result.put(ba.Id, ba);
					}
				}
			}

			return result.values();
		}

		/**
		 * @description updateAccountBenefitsConsultantsFromBranches update Client Account's Benefits Consultant (Benefits_Representative__c)
		 * when changed on the Branch.
		 * Do not update if:
		 *     Client has a no Open Benefits Opportunities
		 *     Client's Benefits_Representative__c has been manually changed
		 */
		private void updateAccountBenefitsConsultantsFromBranches() {
			if (oldClients == null || branches.isEmpty()) {
				return;
			}

			Map<Id, Account> changedBranches = new Map<Id, Account>();
			for (Account branch : branches.values()) {
				if (oldClients.get(branch.Id).Benefits_Consultant__c != branch.Benefits_Consultant__c) {
					changedBranches.put(branch.Id, branch);
				}
			}

			if (changedBranches.isEmpty()) {
				return;
			}

			Map<Id, Account> clients = new Map<Id, Account>([
				SELECT Id, Name, Prospect_Branch__c, Benefits_Representative__c
				FROM Account
				WHERE Prospect_Branch__c IN :changedBranches.keySet()
			]);

			if (!clients.isEmpty()) {
				Account oldBranch;

				for (Account client : clients.values()) {
					oldBranch = oldClients.get(client.Prospect_Branch__c);

					if (
						String.isBlank(client.Benefits_Representative__c) ||
						client.Benefits_Representative__c == oldBranch.Benefits_Consultant__c
					) {
						client.Benefits_Representative__c = branches.get(client.Prospect_Branch__c).Benefits_Consultant__c;
					}
				}

				DatabaseUpdateBatch.dispatch(clients.values(), false, 'Benefits Affiliates', 'Update Consultants');
			}
		}
		/** Added For USER STORY 52175 
		 * @description performReferralSourceChanges determines are ReferralSource Records are 
		 * created for accounts with Beneftis Closed Won Opportunities
		 */
		@TestVisible
		private void performReferralSourceChanges() {
			if(!newClients.isEmpty()) {
				Map<Id,Account> accountMap = new Map<Id,Account>();	
				Map<Id,Referral_Partner__c> referralSourcesNeedtoInsert = new Map<Id,Referral_Partner__c>();		
				accountMap = Account_Services.getAccountsMapWithBenefitsOpportunities(newClients.keySet());
				ReferralPartnerChange_Process.getRPCommissions();
				for (Account client : accountMap.values()) {
					//Latest Benefits Closed Won Opportunity realted Client
					List<Opportunity> benefitsClosedOwnOpps = new List<Opportunity>();
					if(oldClients.containsKey(client.Id)){
						Account oldClient = oldClients.get(client.Id);
						if(oldClient.BBSI_Benefits__c != client.BBSI_Benefits__c && Account_Services.isPrimary(client) && client.Opportunities != null && client.Opportunities.size()>0){
							for (Opportunity opp : client.Opportunities) {
								if(opp.Is_there_a_benefits_referral_partner__c == 'Yes'){
									Boolean needToCreateRS = false;
									if(client.Referral_Partners__r != null && client.Referral_Partners__r.size()>0){
										Boolean isRSNotCreated = true;
										for (Referral_Partner__c rs : client.Referral_Partners__r) {
											if(rs.Opportunity__c == opp.Id && rs.RecordTypeId == ReferralSource_Service.idrtClientRP && String.isNotBlank(rs.Referral_Partner_Commission_Type__c)){
												isRSNotCreated = false;
											}
										}
										if(isRSNotCreated){
											needToCreateRS = true;
										}
									}
									else{
										needToCreateRS = true;
									}
									if(needToCreateRS){
										benefitsClosedOwnOpps.add(opp);
									}
								}							
							}						
						}
						System.debug(benefitsClosedOwnOpps.size());
						if(benefitsClosedOwnOpps.size()>0){
							for (Opportunity opp : benefitsClosedOwnOpps) {
								Referral_Partner__c newRS = new Referral_Partner__c(
									OwnerId = client.OwnerId,
									RecordTypeId = ReferralSource_Service.idrtClientRP,
									Opportunity__c = opp.Id,
									Account__c = opp.AccountId,
									Referral_Partner__c = opp.L_H_Referral_Partner__c,
									Producer__c = opp.L_H_Producer__c,
									Effective_Date__c = opp.Benefits_Effective_Date__c
								);
																
								Referral_Partner_Commissions__mdt commissionRate = ReferralPartnerChange_Process.getMatchingCommission(client, ReferralPartnerChange_Const.PLTYPE_BENEFITS);
								newRS.Commission_Rate__c = commissionRate.Commission_Rate__c;
								newRS.Referral_Partner_Commission_Type__c = commissionRate.Commission_Type__c;
								referralSourcesNeedtoInsert.put(opp.Id, newRS);
							}
							
						}
					}				
				}
				if(!referralSourcesNeedtoInsert.isEmpty()){
					insert referralSourcesNeedtoInsert.values();
				}
			}
		}
	}

	/**
	 * @description handleBefore Benefits related stuff for BEFORE insert or update of Accounts.
	 * @param  oldAccounts  Accounts before changes
	 * @param  newAccounts  Accounts with changes
	 */
	public static void handleBefore(Map<Id, Account> oldAccounts, List<Account> newAccounts) {
		(new BenefitsAffiliatesAccountHandler(oldAccounts, newAccounts)).handleBefore();
	}

	/**
	 * @description handleAfter Benefits related stuff for BEFORE insert or update of Accounts.
	 * @param  oldAccounts  Accounts before changes
	 * @param  newAccounts  Accounts with changes
	 */
	public static void handleAfter(Map<Id, Account> oldAccounts, List<Account> newAccounts) {
		(new BenefitsAffiliatesAccountHandler(oldAccounts, newAccounts)).handleAfter();
	}

	/**
	 * @description selectAccounts reads the Account records for the given ids.
	 * @param idAccounts  Set of Account identifiers
	 * @return Map<Id, Account>
	 */
	public static Map<Id, Account> selectAccounts(Set<Id> idAccounts) {
		return Account_Services.getAccountsMap(idAccounts);		
	}
	/**
	 * @description selectAccountsByAffiliates reads the Account records for the given ids.
	 * @param idAffiliates Affiliates getting Accounts for.
	 * @return Map<Id, Account>
	 */
	public static Map<Id, Account> selectAccountsByAffiliates(Set<Id> idAffiliates) {
		Map<Id, Account> result = new Map<Id, Account>(
			[
				SELECT
					Id,
					OwnerId,
					Name,
					External_Id__c,
					Prospect_Branch__c,
					BBSI_Benefits__c,
					Benefits_Representative__c,
					Benefits_Affiliates__c,
					Benefits_Affiliates_Type__c, 
					Headquarters_State__c, 
					Referral_Partner_for_Benefits__c, 
					Producer_for_Benefits__c,
					Benefits__c,
					Benefits_Type__c,
					Benefits_Affiliated_Companies__c,
					NumberOfEmployees,
					Active_Employees_Full_Time__c,
					Active_Employees_Part_Time__c,
					Active_Employees_All_Affiliates__c,
					Full_Time_Employees_All_Affiliates__c,
					Part_Time_Employees_All_Affiliates__c,
					BBSI_Benefits_Renewal_Date__c,
					(select id, 
						Benefits_Affiliated_Companies__c 
						from Referral_Partners__r 
						WHERE Account__r.Benefits_Affiliates_Type__c = 'Primary' 
						and Termination_Date__c = null)
				FROM Account
				WHERE Benefits_Affiliates__c IN :idAffiliates
			]
		);

		return result;
	}
}