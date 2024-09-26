/**
 * @description BdmSharing handles Lead and Account sharing for the Business Development Manager (BDM).
 */
public without sharing class BdmSharing {
	private Map<Account, Id> followAccount = new Map<Account, Id>();
	private Map<Id, Id> unfollowAccount = new Map<Id, Id>();

	private Map<Id, Id> followLead = new Map<Id, Id>();
	private Map<Id, Id> unfollowLead = new Map<Id, Id>();

	/**
	 * @description processLeads reviews the given Leads and determines if the BDM
	 * sharing needs to change.
	 * @param  oldLeads  Leads before change
	 * @param  newLeads  Leads with changes
	 */
	public void processLeads(Map<Id, Lead> oldLeads, List<Lead> newLeads) {
		checkLeads(oldLeads, newLeads);

		insertLeadShares();
		removeLeadShares();
	}

	/**
	 * @description processAccounts reviews the given Accounts and determines if the BDM
	 * sharing needs to change.
	 * @param  oldAccounts  Accounts before change
	 * @param  newAccounts  Accounts with changes
	 */
	public void processAccounts(Map<Id, Account> oldAccounts, List<Account> newAccounts) {
		checkAccounts(oldAccounts, newAccounts);
		
		insertAccountShares();
		removeAccountShares();
	}

	/**
	 * @description checkLeads determines the changes to sharing which needs to be performed for the Leads.
	 * @param  oldLeads  Leads before change
	 * @param  newLeads  Leads with changes
	 */
	private void checkLeads(Map<Id, Lead> oldLeads, List<Lead> newLeads) {
		List<Lead> leads = RecordTypeService.getByRecordTypes(newLeads, 'Lead', new List<String>{ 'Client_Lead' });

		for (Lead lead : leads) {
			if (oldLeads == null) {
				// INSERT
				if (lead.Business_Development_Manager__c != null) {
					if (lead.OwnerId == lead.Business_Development_Manager__c) {
						unfollowLead.put(lead.Id, lead.Business_Development_Manager__c);
					} else {
						if (lead.BDM_Active__c) {
							followLead.put(lead.Id, lead.Business_Development_Manager__c);
						}
					}
				}
			} else {
				// UPDATE
				if (lead.Business_Development_Manager__c != oldLeads.get(lead.Id).Business_Development_Manager__c) {
					if (lead.OwnerId != lead.Business_Development_Manager__c) {
						if (lead.BDM_Active__c) {
							followLead.put(lead.Id, lead.Business_Development_Manager__c);
						}
					}

					if (oldLeads.get(lead.Id).Business_Development_Manager__c != lead.OwnerId) {
						unfollowLead.put(lead.Id, oldLeads.get(lead.Id).Business_Development_Manager__c);
					}
				} else if (lead.OwnerId != oldLeads.get(lead.Id).OwnerId) {
					if (lead.OwnerId == lead.Business_Development_Manager__c) {
						unfollowLead.put(lead.Id, lead.Business_Development_Manager__c);
					} else {
						if (lead.BDM_Active__c) {
							followLead.put(lead.Id, lead.Business_Development_Manager__c);
						}
					}
				}
			}
		}
	}
	
	/**
	 * @description checkAccounts determines the changes to sharing which needs to be performed for the Accounts.
	 * @param  oldAccounts  Accounts before change
	 * @param  newAccounts  Accounts with changes
	 */
	private void checkAccounts(Map<Id, Account> mapOldAccounts, List<Account> listAccounts) {
		List<Account> accounts = RecordTypeService.getByRecordTypes(listAccounts, 'Account', new List<String>{'Client', 'Prospect'});
		if (mapOldAccounts == null) {
			// INSERT
			for (Account account : accounts) {
				if (account.Business_Development_Manager__c != null) {
					if (account.OwnerId != account.Business_Development_Manager__c) {
						followAccount.put(account, account.Business_Development_Manager__c);
					}
				}
			}			
		} else  {
			// UPDATE
			for (Account account : accounts) {
				if (account.Business_Development_Manager__c != null) {
					if (account.Business_Development_Manager__c != mapOldAccounts.get(account.Id).Business_Development_Manager__c) {
						if (account.OwnerId != account.Business_Development_Manager__c) {
							if (account.BDM_Active__c) {
								unfollowAccount.put(account.Id, mapOldAccounts.get(account.Id).Business_Development_Manager__c);
								followAccount.put(account, account.Business_Development_Manager__c);
							}
						}
					} else if (account.OwnerId != mapOldAccounts.get(account.Id).OwnerId) {
						if (account.OwnerId != account.Business_Development_Manager__c) {
							if (account.BDM_Active__c) {
								followAccount.put(account, account.Business_Development_Manager__c);
							}
						}
					}  
				} else {
					if (mapOldAccounts.get(account.Id).Business_Development_Manager__c != null) {
						unfollowAccount.put(account.Id, mapOldAccounts.get(account.Id).Business_Development_Manager__c); 
					}   
				}            
			}
		} 
	}
	
	/**
	 * @description insertLeadShares adds any Lead shares for the BDM.
	 */
	private void insertLeadShares() {
		if (followLead.isEmpty()) {
			return;
		}

		List<LeadShare> shares = new List<LeadShare>();

		for (Id id : followLead.keySet()) {
			shares.add(
				new LeadShare(
					LeadId = id,
					UserOrGroupId = followLead.get(id),
					LeadAccessLevel = 'Edit'
				)
			);
		}

		Database.SaveResult[] results = Database.insert(shares, false);
		Log.writeIfError('BDM Sharing', 'BdmSharing.insertLeadShare', followLead.toString(), results);
	}
	
	/**
	 * @description removeShareLeads removes any Lead shares for the BDM.
	 */
	private void removeLeadShares() {
		if (unfollowLead.isEmpty()) {
			return;
		}

		List<Database.DeleteResult> results = Database.delete([
			SELECT Id 
			FROM LeadShare
			WHERE LeadId IN :unfollowLead.keySet()
			AND UserOrGroupId IN: unfollowLead.values() 
			AND RowCause = 'Manual'
		], false);
		Log.writeIfError('BDM Sharing', 'BdmSharing.removeShareLead', unfollowLead.toString(), results);
	}
	
	/**
	 * @description insertAccountShares adds any Account shares for the BDM.
	 */
	private void insertAccountShares() {		
		if (followAccount.isEmpty()) {
			return;
		}

		Id idrtProspect = recordTypeService.getId('Account', 'Prospect');
		
		List<AccountShare> shares = new List<AccountShare>();

		for (Account account : followAccount.keySet()) {
			shares.add(
				new AccountShare(
					AccountId = account.Id,
					UserOrGroupId = followAccount.get(account),
					AccountAccessLevel = (account.RecordTypeId == idrtProspect) ? 'Edit' : 'Read',
					OpportunityAccessLevel = 'Edit',
					CaseAccessLevel = 'Edit',
					RowCause = 'Manual'
				)
			);
		}

		Database.SaveResult[] results = Database.insert(shares, false);
		Log.writeIfError('BDM Sharing', 'BdmSharing.insertAccountShares', shares.toString(), results);
	}
	
	/**
	 * @description removeAccountShares removes any Account shares for the BDM.
	 */
	private void removeAccountShares() {
		if (unfollowAccount.values().isEmpty()) {
			return;
		}

		List<Database.DeleteResult> results = Database.delete([
			SELECT Id 
			FROM AccountShare 
			WHERE AccountId IN: unfollowAccount.keySet() 
			AND UserOrGroupId IN: unfollowAccount.values() 
			AND AccountAccessLevel IN ('Read', 'Edit') 
			AND RowCause = 'Manual'
		], false);
		Log.writeIfError('BDM Sharing', 'BdmSharing.removeAccountShares', unfollowAccount.toString(), results);
	}
}