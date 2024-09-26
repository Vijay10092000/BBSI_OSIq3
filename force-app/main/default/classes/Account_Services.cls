/**
 * @description Account_Services
 */
@SuppressWarnings('PMD.ExcessivePublicCount, PMD.CyclomaticComplexity')
public without sharing class Account_Services {
	public static final String ACCOUNT = 'Account';

	public static final String RECORDTYPE_BRANCH = 'BBSI Branch';
	public static final String RECORDTYPE_CLIENT = 'Client';
	public static final String RECORDTYPE_PROSPECT = 'Prospect';
	public static final String RECORDTYPE_TERMINATED = 'Terminated';

	/**
	 * @description getReferralPartnersByExternalID retrieves a Map relating External Ids to an Account
     * @param  externalIDs External Ids looking for
     * @return Map relating External Ids to Accounts
     */
	public static Map<String, Account> getReferralPartnersByExternalID(Set<String> externalIDs) {
		Map<String, Account> mapReturn = new Map<String, Account>();
		for (Account rp : [SELECT Id, External_ID__c FROM Account WHERE external_ID__c IN :externalIDs]) {
			mapReturn.put(rp.External_ID__c, rp);
		}
		return mapReturn;
	}

    /**
     * @description processReferralPartnerIDChangesBefore sets Assigned_Referral_Partner on the Account if the
     * value Referral_Partner_Id__c has changed.
     * @param  newValues New Accounts with changed values
     * @param  oldValues Accounts before changes were made
     */
	public static void processReferralPartnerIDChangesBefore(Map<id, Account> newValues, Map<id, Account> oldValues) {
		Set<String> referralPartnerExternalIDs = new Set<String>();
		Map<String, Account> rpByID = new Map<String, Account>();
		for (Account newAcct : newValues.Values()) {
			if (
				newAcct.Referral_Partner_ID__c != oldValues.get(newAcct.ID).Referral_Partner_ID__c &&
				newAcct.Referral_Partner_ID__c != '9999'
			) {
				referralPartnerExternalIDs.add(newAcct.Referral_Partner_ID__c);
			}
		}

		if (!referralPartnerExternalIDs.isEmpty()) {
			rpByID = Account_Services.getReferralPartnersByExternalID(referralPartnerExternalIDs);
			if (!rpByID.isEmpty()) {
				for (Account a : newValues.Values()) {
					if (a.Assigned_Referral_Partner__c != rpByID.get(a.Referral_Partner_ID__c).id) {
						a.Assigned_Referral_Partner__c = rpByID.get(a.Referral_Partner_ID__c).id;
					}
				}
			}
		}
	}

	public static void populateOwnerForStaffingAndLocationAccounts(List<Account> newValues) {
		AD_Username.UpdateAccounts(newValues);
	}

	public static void populateNAICSInformation(List<Account> newValues, Map<id, Account> oldValues) {
		Naics_Service.populateNaics(oldValues, newValues);
	}

	public static void populateBranch(Map<ID, Account> newValues, Map<id, Account> oldValues) {
		Account_ChangeOwnerTrigger.populateBranch(oldValues, newValues);
	}

	public static void populateBusinessUnitMembers(List<Account> newValues, Map<id, Account> oldValues) {
		PopulateBusinessUnitMembersAcct.populateBusinessUnitMembers(newValues, oldValues);
	}

	public static void checkReferralPartnerFEIN(Map<ID, Account> newValues, Map<id, Account> oldValues) {
		CheckRPFEIN.checkReferralPartnerFEIN(newValues, oldValues);
	}

	public static void processPriceApproval(Map<ID, Account> newValues, Map<id, Account> oldValues) {
		PriceApproval.processPriceApproval(newValues, oldValues);
	}

	public static void processRenewalTermination(List<Account> newValues, Map<id, Account> oldValues) {
		RenewalTermination.processRenewalTermination(newValues, oldValues);
	}

	public static void assignAccountFEINs(List<Account> newValues, List<Account> oldValues) {
		FEIN_Services.assignAccountFEINs(newValues, oldValues);
	}

	public static void updateAccountFEINs(List<Account> newValues, List<Account> oldValues) {
		FEIN_Services.updateAccountFEINs(newValues, oldValues);
    }

    /**
     * @description formatPhoneNumber formats the account's phone number if it has changed.
     * @param  oldValues Accounts before changes were made
     * @param  newValues New Accounts with changed values
     */
    @SuppressWarnings('PMD.EmptyCatchBlock')
    public static void formatPhoneNumber(Map<Id, Account> oldValues, List<Account> newValues) {
        for (Account a : newValues) {
            if (oldValues == null || oldValues.get(a.Id).Phone != a.Phone) {
                if (!String.isBlank(a.Phone)) {
					try {
                    	a.Phone = PhoneNumber.fixPhoneNumber(a.Phone);
					} catch (Exception e) {
						a.Phone.addError('Invalid phone number');
					}
                }
            }
        }
    }

	/**
	 * @description getContactCount returns a map relating account id to the number of contacts in the account.
	 * @param  idAccounts A Set of account ids
	 * @return A map
	 */
	public static Map<Id, Integer> getContactCount(Set<Id> idAccounts) {
		Map<Id, Integer> mapCounts = new Map<Id, Integer>();

		for (AggregateResult ar : [
			SELECT AccountId, Count(Id) cnt
			FROM Contact
			WHERE AccountId IN :idAccounts
			GROUP BY AccountId
		]) {
			mapCounts.put((Id) ar.get('AccountId'), (Integer) ar.get('cnt'));
		}

		return mapCounts;
	}

	/**
	 * @description populateReferralPartnerStatus finds Referral Partners with an empty
	 * Referral Partner Status and changes it to 'Pending'.
	 * @param  newValues Accounts being modified
	 */
	public static void populateReferralPartnerStatus(List<Account> newValues) {
		Id idReferralPartner = RecordTypeService.getId('Account', 'Referral Partner');
		for (Account a : newValues) {
			if (a.RecordTypeId == idReferralPartner) {
				if (String.isBlank(a.Referral_Partner_Status__c)) {
					a.Referral_Partner_Status__c = 'Pending';
				}
			}
		}
	}

	/**
	 * @description onReferralPartnerGroupChange adds a new Change Request to keep track
	 * of when a Referral Partner is moved in and out of Referral Partner Groups.
	 * @param  oldValues Map of old values
	 * @param  newValues Map of changed values
	 */
	public static void onReferralPartnerGroupChange(Map<Id, Account> oldValues, Map<Id, Account> newValues) {
		List<Account> psGroupChanged = new List<Account>();

		for (Account a : newValues.values()) {
			if (oldValues == null) {
				if (a.Referral_Partner_Group__c != null) {
					psGroupChanged.add(a);
				}
			} else if (a.Referral_Partner_Group__c != oldValues.get(a.Id).Referral_Partner_Group__c) {
				psGroupChanged.add(a);
			}
		}

		if (!psGroupChanged.isEmpty()) {
			Boolean isSysAdmin = Profile_Service.isSystemAdministrator(UserInfo.getProfileId());

			for (Account a : psGroupChanged) {
				if (a.Referral_Partner_Status__c != 'Pending' && a.Referral_Partner_Status__c != 'Active') {
					if (!isSysAdmin) {
						a.addError('Unable to change Referral Partner Group on inactive Referral Partner');
					}
				}
			}
		}
	}

	/**
	 * @description onAccountTermination performs actions on recently terminated Accounts.
	 * @param  oldValues Map of old values
	 * @param  newValues Map of changed values
	 */
	public static void onAccountTermination(Map<Id, Account> oldValues, Map<Id, Account> newValues) {
		Map<Id, Account> terminated = new Map<Id, Account>();

		for (Account a : newValues.values()) {
			// Check Clients
			if (a.Status__c == 'Terminated') {
				if (oldValues == null || oldValues.get(a.Id).Status__c != 'Terminated') {
					terminated.put(a.Id, a);
				}
			}

			// Check Referral Partners
			if (a.Referral_Partner_Status__c == 'Inactive' || a.Referral_Partner_Status__c == 'Not Approved') {
				if (
					oldValues == null ||
					(oldValues.get(a.Id).Referral_Partner_Status__c != 'Inactive' &&
					oldValues.get(a.Id).Referral_Partner_Status__c != 'Not Approved')
				) {
					terminated.put(a.Id, a);
				}
			}
		}

		if (!terminated.isEmpty()) {
			ReferralSource_Service.terminateRelatedReferralSources(terminated);
		}
	}

	/**
	 * @description updateProspectReferralSources checks for changes to the Referral Partner
	 * or Producer on Prospect accounts.
	 * @param  oldValues Map of old Accounts
	 * @param  newValues List of changed Accounts
	 */
	public static void updateProspectReferralSources(Map<Id, Account> oldValues, List<Account> newValues) {
		List<Referral_Partner__c> changes = ReferralSource_Service.updateProspectReferralSources(oldValues, newValues);

		if (!changes.isEmpty()) {
			upsert changes;
		}
	}

	/**
	 * @description confirmReferralSource check that all active Client and Referral Partner accounts
	 * have an active Referral Source.
	 * @param  oldValues Map of old values
	 * @param  newValues Map of changed values
	 */
	public static void confirmReferralSource(Map<Id, Account> oldValues, Map<Id, Account> newValues) {
		Id idRP = RecordTypeService.getId('Account', 'Referral Partner');
		Id idClient = RecordTypeService.getId('Account', 'Client');

		Map<Id, Account> mapReferralPartners = new Map<Id, Account>();
		Map<Id, Account> mapClients = new Map<Id, Account>();

		// Find all Referral Partners and Clients update to 'Active'
		for (Account a : newValues.values()) {
			if (a.RecordTypeId == idRP) {
				if (a.Referral_Partner_Status__c == 'Active') {
					if (oldValues == null || oldValues.get(a.Id).Referral_Partner_Status__c != 'Active') {
						mapReferralPartners.put(a.Id, a);
					}
				}
			} else if (a.RecordTypeId == idClient) {
				if (a.Status__c == 'Active') {
					if (oldValues == null || oldValues.get(a.Id).Status__c == 'Pending') {
						mapClients.put(a.Id, a);
					}
				}
			}
		}

		if (!mapReferralPartners.isEmpty()) {
			ReferralSource_Service.checkReferralSourcesOnReferralPartners(mapReferralPartners);
		}
		if (!mapClients.isEmpty()) {
			ReferralSource_Service.checkReferralSourcesOnClients(mapClients);
		}
	}

	/**
	 * @description getAccountsByType retrives a list of Accounts of the given Record Type.
	 * @param  accounts       Accounts looking at
	 * @param  nameRecordType Name of the Record Type looking for
	 * @return List of Accounts of given type
	 */
	@TestVisible
	private static List<Account> getAccountsByType(List<Account> accounts, String nameRecordType) {
		Id idRecordType = RecordTypeService.getId('Account', nameRecordType);

		if (idRecordType == null) {
			throw new IllegalArgumentException('Invalid Account Record Type name: ' + nameRecordType);
		}

		return getAccountsByType(accounts, idRecordType);
	}

	/**
	 * @description getAccountsByType retrives a list of Accounts of the given Record Type.
	 * @param  accounts      Accounts looking at
	 * @param  idRecordType  Identifier of the Record Type looking for
	 * @return List of Accounts of given type
	 */
	@TestVisible
	private static List<Account> getAccountsByType(List<Account> accounts, Id idRecordType) {
		if (idRecordType == null) {
			throw new IllegalArgumentException('Record Type identifier is null');
		}

		List<Account> result = new List<Account>();

		for (Account a : accounts) {
			if (a.RecordTypeId == idRecordType) {
				result.add(a);
			}
		}

		return result;
	}

    /**
     * @description setHeadquarterState sets the Headquarters State for an Account.
     * @param  oldValues  Previous values of the Accounts
     * @param  newValues  New values for the Accounts
     */
	public static void setHeadquarterState(Map<Id, Account> oldValues, List<Account> newValues) {
		for (Account account : newValues) {
			if (account.ShippingState != null && 2 == account.ShippingState.length()) {
				if (account.Headquarters_State__c == null) {
					account.Headquarters_State__c = account.ShippingState;
				}
			}
		}
	}

	/**
	 * @description setBranchData sets/updates the Name_Branch__c field of the Account.
	 * @param  oldAccounts  Accounts before changes
	 * @param  newAccounts  Accounts with changes
	 */
	public static void setBranchData(Map<Id, Account> oldAccounts, List<Account> newAccounts) {
		Set<Id> idBranches = new Set<Id>();

		for (Account account : newAccounts) {
			if (account.Prospect_Branch__c == null) {
				account.Name_Branch__c = null;
			} else if (oldAccounts == null) {
				idBranches.add(account.Prospect_Branch__c);
			} else if (oldAccounts.get(account.Id).Prospect_Branch__c != account.Prospect_Branch__c) {
				idBranches.add(oldAccounts.get(account.Id).Prospect_Branch__c);
				idBranches.add(account.Prospect_Branch__c);
			}
		}

		idBranches.remove(null);

		if (!idBranches.isEmpty()) {
			Map<Id, Account> mapBranches = new Map<id, Account>([
				SELECT Id, Name, Benefits_Representative__c, Benefits_Consultant__c
				FROM Account
				WHERE Id IN :idBranches
			]);

			for (Account account : newAccounts) {
				if (mapBranches.containsKey(account.Prospect_Branch__c)) {
					Account branch = mapBranches.get(account.Prospect_Branch__c);

					account.Name_Branch__c = branch.Name;
					account.Benefits_Representative__c = branch.Benefits_Consultant__c;

					if (oldAccounts == null) {
						account.Benefits_Consultant__c = branch.Benefits_Consultant__c;
					} else {
						Account oldBranch = oldAccounts.get(account.Id);

						if (account.Benefits_Consultant__c == oldBranch.Benefits_Consultant__c) {
							account.Benefits_Consultant__c = branch.Benefits_Consultant__c;
						}
					}
				}
			}
		}
	}

	/**
	 * @description changeOfBranch sets/updates the benefits representative field of the Client Account
	 * when the related Branch changes.
	 * @param  oldAccounts  Accounts before changes
	 * @param  newAccounts  Accounts with changes
	 */
	public static void changeOfBranch(Map<Id, Account> oldAccounts, List<Account> newAccounts) {
		List<Account> clients = (List<Account>) RecordTypeService.getByRecordTypes(
			newAccounts,
			'Account',
			new List<String>{ 'Prospect', 'Client', 'Terminated' }
		);

		if (clients.isEmpty()) {
			return;
		}

		Set<Id> idBranches = new Set<Id>();

		for (Account client : clients) {
			if (oldAccounts == null || oldAccounts.get(client.Id).Prospect_Branch__c != client.Prospect_Branch__c) {
				idBranches.add(client.Prospect_Branch__c);
			}
		}
		idBranches.remove(null);

		Map<Id, Account> branches = new Map<Id, Account>([
			SELECT Id, Name, Benefits_Consultant__c FROM Account WHERE Id IN :idBranches
		]);

		for (Account client : clients) {
			if (branches.containsKey(client.Prospect_Branch__c)) {
				client.Benefits_Representative__c = branches.get(client.Prospect_Branch__c).Benefits_Consultant__c;
				client.Benefits_Consultant__c = branches.get(client.Prospect_Branch__c).Benefits_Consultant__c;
			}
		}
	}

	/**
	 * @description updateBranchNames sets/updates the Name_Branch__c field of related Opportunities
	 * @param  oldAccounts  Accounts before changes
	 * @param  newAccounts  Accounts with changes
	 */
	public static void updateBranchNames(Map<Id, Account> oldAccounts, Map<Id, Account> newAccounts) {
		Map<Id, Account> changedAccounts = new Map<Id, Account>();

		for (Account account : newAccounts.values()) {
			if (oldAccounts == null) {
				if (!String.isBlank(account.Name_Branch__c)) {
					changedAccounts.put(account.Id, account);
				}
			} else if (oldAccounts.get(account.Id).Name_Branch__c != account.Name_Branch__c) {
				changedAccounts.put(account.Id, account);
			}
		}

		if (!changedAccounts.isEmpty()) {
			List<Opportunity> opps = [
				SELECT Id, Name, Name_Branch__c, AccountId
				FROM Opportunity
				WHERE AccountId IN :changedAccounts.keySet()
			];

			List<Opportunity> changedOpps = new List<Opportunity>();

			for (Opportunity opp : opps) {
				Account account = changedAccounts.get(opp.AccountId);

				if (opp.Name_Branch__c != account.Name_Branch__c) {
					opp.Name_Branch__c = account.Name_Branch__c;
					changedOpps.add(opp);
				}
			}

			update changedOpps;
		}
	}

	/**
	 * @description getAccountOpportunities retrieves the Account's Opportunities
	 * grouped by Record Type.
	 * @param  idAccounts  Accounts looking at
	 * @return Map<Id, Map<Id, Opportunity>>
	 */
	public static Map<Id, Map<Id, List<Opportunity>>> getAccountOpportunities(Set<Id> idAccounts) {
		Map<Id, Map<Id, List<Opportunity>>> result = new Map<Id, Map<Id, List<Opportunity>>>();

		for (Id id : idAccounts) {
			result.put(id, new Map<Id, List<Opportunity>>());
		}

		List<Opportunity> opps = [
			SELECT Id, Name, RecordTypeId, AccountId, StageName
			FROM Opportunity
			WHERE AccountId IN :idAccounts
		];

		for (Opportunity opp : opps) {
			if (!result.get(opp.AccountId).containsKey(opp.RecordTypeId)) {
				result.get(opp.AccountId).put(opp.RecordTypeId, new List<Opportunity>());
			}

			result.get(opp.AccountId).get(opp.RecordTypeId).add(opp);
		}

		return result;
	}

	/**
	 * @description setDefaults set some base values for an Account on creation.
	 * Trigger: Before Insert
	 * @param  accounts  List of accounts to set values for.
	 */
	public static void setDefaults(List<Account> accounts) {
		
	}

	/**
	 * @description onlyBranches retrieves the BBSI Branch accounts from the given list
	 * based on the Record Type.
	 * @param  accounts  List of Accounts
	 * @return Map<Id, Account>
	 */
	public static Map<Id, Account> onlyBranches(List<Account> accounts) {
		if (accounts == null || accounts.isEmpty()) {
			return new Map<Id, Account>();
		}

		return new Map<Id, Account>(
			(List<Account>) RecordTypeService.getByRecordTypes(accounts, ACCOUNT, new List<String>{ RECORDTYPE_BRANCH })
		);
	}

	/**
	 * @description onlyClientLikeAccounts retrieves the Prospect, Client and Terminated
	 * accounts from the given list based on the Record Type.
	 * @param  accounts  List of Accounts
	 * @return Map<Id, Account>
	 */
	public static Map<Id, Account> onlyClientLikeAccounts(List<Account> accounts) {
		return new Map<Id, Account>(
			(List<Account>) RecordTypeService.getByRecordTypes(
				accounts,
				ACCOUNT,
				new List<String>{ RECORDTYPE_PROSPECT, RECORDTYPE_CLIENT, RECORDTYPE_TERMINATED }
			)
		);
	}

	/**
	 * @description onlyClientAccounts retrieves the Client accounts from the given
	 *  list based on the Record Type.	 * @param  accounts  List of Accounts
	 * @return Map<Id, Account>
	 */
	public static Map<Id, Account> onlyClientAccounts(List<Account> accounts) {
		if (accounts == null || accounts.isEmpty()) {
			return new Map<Id, Account>();
		}

		return new Map<Id, Account>(
			(List<Account>) RecordTypeService.getByRecordTypes(
				accounts,
				ACCOUNT,
				new List<String>{ RECORDTYPE_CLIENT }
			)
		);
	}

	/**
	 * @description updateOpportunityFields changes Opportunity fields based on changes to their Accounts.
	 * @param  oldAccounts  Accounts before changes
	 * @param  newAccounts  Accounts with changes
	 */
	public static void updateOpportunityFields(Map<Id, Account> oldAccounts, Map<Id, Account> newAccounts) {
		map<Id, Account> clients = onlyClientLikeAccounts(newAccounts.values());

		if (clients.isEmpty()) {
			return;
		}

		Map<Id, Account> changedSDR = new Map<Id,Account>();
		Map<Id, Account> changedCLN = new Map<Id,Account>();

		for (Account acc : clients.values()) {
			if (acc.Sales_Development_Representative__c != oldAccounts.get(acc.Id).Sales_Development_Representative__c) {
				changedSDR.put(acc.Id, acc);				
			}

			if (acc.Campaign_List_Name__c != oldAccounts.get(acc.Id).Campaign_List_Name__c) {
				changedCLN.put(acc.Id, acc);				
			}
		}

		if (changedSDR.isEmpty() && changedCLn.isEmpty()) {
			return;
		}

		Set<Id> idChangedAccounts = new Set<Id>();
		idChangedAccounts.addAll(changedSDR.keySet());
		idChangedAccounts.addAll(changedCLN.keySet());

		List<Opportunity> opps = [
			SELECT Id, Name, AccountId, Sales_Development_Representative__c, Bypass_Estimated_Annual_Billing__c, Campaign_List_Name__c , IsClosed
			FROM Opportunity
			WHERE AccountId IN :idChangedAccounts
			AND (RecordType.Name = :Opportunity_Service.RECORDTYPE_CLIENT OR RecordType.Name = :Opportunity_Service.RECORDTYPE_SHELL)
			AND IsClosed = FALSE
		];

		for (Opportunity opp : opps) {
			if (changedSDR.containsKey(opp.AccountId)) {
				opp.Sales_Development_Representative__c = clients.get(opp.AccountId).Sales_Development_Representative__c;
				opp.Bypass_Estimated_Annual_Billing__c = !opp.Bypass_Estimated_Annual_Billing__c;
			}

			if (changedCLN.containsKey(opp.AccountId)) {
				opp.Campaign_List_Name__c = clients.get(opp.AccountId).Campaign_List_Name__c;
			}
		}

		update opps;
	}

	/**
	 * @description updateBenefits updates related Benefits__c records.
	 * For now, it is only the Branch Name
	 * @param  oldAccounts  Accounts before changes
	 * @param  newAccounts  Accounts with changes
	 */
	public static void updateBenefits(Map<Id, Account> oldAccounts, List<Account> newAccounts) {
		List<Benefits__c> benefits = new List<Benefits__c>();

		for (Benefits__c b : [
			SELECT Id, Name, AccountId__c, AccountId__r.Prospect_Branch__r.Name, Branch_Name__c
			FROM Benefits__c
			WHERE AccountId__c IN : oldAccounts.keySet()
		]) {
			if (b.Branch_Name__c != b.AccountId__r.Prospect_Branch__r.Name) {
				b.Branch_Name__c = b.AccountId__r.Prospect_Branch__r.Name;
				benefits.add(b);
			}
		}

		update benefits;
	}
	
	/**  USER STORY 51029
     * @description used to check if the client is isPrimary or not
     * @param  client Related Client acount
     * @return Boolean
    */
    public static Boolean isPrimary(Account client) {
        return (client != null && (String.isEmpty(client.Benefits_Affiliates_Type__c) || client.Benefits_Affiliates_Type__c == 'Primary') && client.BBSI_Benefits__c);
    }

	/**Added For USER STORY 52175 
	 * @description getAccountsMap return Account records
	 * @param  Set<Id> Account Ids
	 * @return Map<Id,Account> 
	 */
	public static Map<Id,Account> getAccountsMap(Set<Id> accountIds) {  		
		return new Map<Id,Account> ([
			SELECT Id, Name, Active_Employees_All_Affiliates__c, Active_Employees_Full_Time__c, Active_Employees_Part_Time__c, Assigned_Referral_Partner__c, 
			Commission_Rate__c, BBSI_Benefits__c, BBSI_Benefits_Renewal_Date__c, Benefits__c, Benefits_Affiliated_Companies__c, Benefits_Affiliates__c, 
			Benefits_Affiliates_Type__c, Benefits_Representative__c, Benefits_Type__c, Client__c, Client_Benefits__c, Client_Benefits_Renewal_Month__c, 
			Commission_Type__c, CreatedDate, External_Id__c, Full_Time_Employees_All_Affiliates__c, Headquarters_State__c, Hold__c, Hold_Effective_Date__c, 
			Is_Benefits_Renewal_Opp_Generated__c, Is_there_a_benefits_referral_partner__c, Life_Health_Commission_Rate__c, Life_Health_Commission_Type__c , 
			NumberOfEmployees, OwnerId, Part_Time_Employees_All_Affiliates__c, Producer__c, Producer_for_Benefits__c, Prospect_Branch__c, RecordType.Name, 
			RecordTypeId, Referral_Partner_for_Benefits__c, Referral_Partner_Group__c, Referral_Partner_Status__c, Status__c 
			FROM Account
			WHERE Id IN :accountIds ORDER BY Name ASC
		]);
	} 
	/**Added For USER STORY 52175 
	 * @description getAccountsMap return Account records
	 * @param  Set<Id> Account Ids
	 * @return Map<Id,Account> 
	 */
	public static Map<Id,Account> getAccountsMapWithBenefitsOpportunities(Set<Id> accountIds) { 
		return new Map<Id,Account> ([
			SELECT Id, Name, BBSI_Benefits__c, Client_Benefits__c, Client_Benefits_Renewal_Month__c,
			Benefits_Affiliates__c, BBSI_Benefits_Renewal_Date__c, Is_Benefits_Renewal_Opp_Generated__c, Benefits_Affiliates_Type__c, OwnerId, Headquarters_State__c, Referral_Partner_for_Benefits__c, Producer_for_Benefits__c, 
			(Select Id,
			OwnerId,
			Name,
			AccountId,
			RecordTypeId, 
			RecordType.Name,
			Benefits_Affiliates__c,
			Benefits_Specialist__c,
			Benefits_Consultant__c,
			Benefits_Coordinator__c,
			Benefits_Type__c,
			Benefits_Affiliated_Companies__c,
			Active_Employees_All_Affiliates__c,
			Full_Time_Employees_All_Affiliates__c,
			Part_Time_Employees_All_Affiliates__c,
			Have_Common_Ownership__c,
			IsClosed,			
			Is_there_a_benefits_referral_partner__c,
			L_H_Referral_Partner__c,
			L_H_Producer__c,
			Benefits_Effective_Date__c,
			StageName from Opportunities Where (RecordTypeId =: OpportunityBenefits_Service.BenefitsRT OR RecordTypeId =: OpportunityBenefits_Service.BenefitsRenewalRT) and StageName =: Opportunity_Service.STAGE_BENEFITS_CLOSED_WON),
			(Select Id,
			Opportunity__c, 
			OwnerId, 
			RecordTypeId, 
			Account__c, 
			Referral_Partner__c, 
			Producer__c, 
			Effective_Date__c, 
			Product_Line__c, 
			Commission_Rate__c, Referral_Partner_Commission_Type__c from Referral_Partners__r)   
			FROM Account
			WHERE Id IN :accountIds
		]);
	} 

	/**
	 * @description updateAccountFromFirstMeeting updates Account fields related to the First Meeting event.
	 * @param account  Account updating
	 * @param event    First Meeting event
	 */
	public static void updateAccountFromFirstMeeting(Account account, Event event) {	
		account.First_Meeting_Event_Id__c = event.Id;
		account.First_Meeting_Event_Source__c = event.Event_Source__c;
		account.First_Meeting_Event_Date__c = Date_Service.toDate(event.StartDateTime).format();
		account.First_Meeting_Event_Creator__c = event.CreatedBy.Name;
	}
}