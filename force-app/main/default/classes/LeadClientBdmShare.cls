/**
 * @description LeadClientBdmShare creates and removes Lead sharing
 * for related BDMs.
 */
public without sharing class LeadClientBdmShare {
	private List<Lead> clientLeads;
	private Map<Id, Lead> mapOldLeads;

	private Map<Id, Id> sharesRemove = new Map<Id, Id>();
	private List<AccountShare> sharesAccount = new List<AccountShare>();
	private List<LeadShare> sharesLead = new List<LeadShare>();

	private String errors = '';

	/**
	 * @description shareLeadRecords get the Client Leads, then check and create needed shares.
	 * @param  mapOldLeads  Leads before the changes
	 * @param  newLeads     Leads with the changes
	 */
	public static void shareLeadRecords(Map<Id, Lead> mapOldLeads, List<Lead> newLeads) {
		LeadClientBdmShare sharer = new LeadClientBdmShare(mapOldLeads, newLeads);

		sharer.determineShares();
		sharer.removeShares();
		sharer.writeShares();
		sharer.checkErrors();
	}

	/**
	 * @description LeadClientBdmShare constructor.
	 * @param  mapOldLeads  Leads before the changes
	 * @param  newLeads     Leads with the changes
	 */
	private LeadClientBdmShare(Map<Id, Lead> mapOldLeads, List<Lead> newLeads) {
		this.clientLeads = RecordTypeService.getByRecordType(newLeads, 'Lead', 'Client_Lead');
		this.mapOldLeads = mapOldLeads;
	}

	/**
	 * @description determineActions determines which Leads or converted Leads need share records
	 * and creates them.
	 */
	@SuppressWarnings('PMD.CyclomaticComplexity')
	private void determineShares() {
		for (Lead lead : clientLeads) {
			Id idNewBdm = lead?.Business_Development_Manager__c;
			Id idOldBdm = (mapOldLeads == null) ? null : mapOldLeads.get(lead.Id).Business_Development_Manager__c;

			if (lead.isConverted) {
				if (idNewBdm != null) {
					if (lead.OwnerId != idNewBdm && lead.BDM_Active__c) {
						addAccountShare(idNewBdm, lead.ConvertedAccountId);
					}
				}
			} else if (mapOldLeads != null && idNewBdm != idOldBdm) {
				if (lead.OwnerId != idNewBdm && lead.BDM_Active__c) {
					addLeadShare(idNewBdm, lead.Id);
				}

				if (idOldBdm != lead.OwnerId) {
					sharesRemove.put(lead.Id, idOldBdm);
				}
			} else if (
				(mapOldLeads == null && idNewBdm != null) ||
				(mapOldLeads != null && lead.OwnerId != mapOldLeads.get(lead.Id).OwnerId)
			) {
				if (lead.OwnerId != idNewBdm && lead.BDM_Active__c) {
					addLeadShare(idNewBdm, lead.Id);
				} else {
					if (lead.OwnerId == idNewBdm) {
						sharesRemove.put(lead.Id, idNewBdm);
					}
				}
			}
		}
	}

	/**
	 * @description addLeadShare creates a LeadShare object and adds to write list.
	 * @param  idBdm   BDM to receive sharing
	 * @param  idLead  Lead being shared
	 */
	private void addLeadShare(Id idBdm, Id idLead) {
		sharesLead.add(
			new LeadShare(
				LeadId = idLead,
				UserOrGroupId = idBdm,
				LeadAccessLevel = 'Edit'
			)
		);
	}

	/**
	 * @description addAccountShare creates a AccountShare object and adds to write list.
	 * @param  idBdm      BDM to receive sharing
	 * @param  idAccount  Account being shared
	 */
	private void addAccountShare(Id idBdm, Id idAccount) {
		sharesAccount.add(
			new AccountShare(
				AccountId = idAccount,
				UserOrGroupId = idBdm,
				AccountAccessLevel = 'Edit',
				OpportunityAccessLevel = 'Edit',
				CaseAccessLevel = 'Edit'
			)
		);
	}

	/**
	 * @description removeShares deletes the sharesRemove records from the database.
	 */
	private void removeShares() {
		if (!sharesRemove.isEmpty()) {
			List<LeadShare> shares = [
				SELECT Id
				FROM LeadShare
				WHERE
					LeadId IN :sharesRemove.keySet()
					AND UserOrGroupId IN :sharesRemove.values()
					AND RowCause = 'Manual'
			];

			List<Database.DeleteResult> listDeletes = Database.delete(shares);

			String description = '';
			description += 'SharesRemove:\n' + sharesRemove;

			if (!Log.writeIfError('LeadClientBdmShare', 'Failed to Delete Lead Shares', description, listDeletes)) {
				errors += '\nFailed to remove all related shares.';
			}
		}
	}

	/**
	 * @description writeShares writes the LeadShare and AccountShare records.
	 */
	private void writeShares() {
		List<Database.SaveResult> listDeletes;

		if (!sharesLead.isEmpty()) {
			listDeletes = Database.insert(sharesLead, false);

			String description = '';
			description += 'sharesLead:\n' + sharesLead;

			if (Log.writeIfError('LeadClientBdmShare', 'Failed to Insert Lead Shares', description, listDeletes)) {
				errors += '\nFailed to add all LeadShares.';
			}
		}

		if (!sharesAccount.isEmpty()) {
			listDeletes = Database.insert(sharesAccount, false);

			String description = '';
			description += 'sharesAccount:\n' + sharesAccount;

			if (Log.writeIfError('LeadClientBdmShare', 'Failed to Insert Account Shares', description, listDeletes)) {
				errors += '\nFailed to add all AccountShares.';
			}
		}
	}

	private void checkErrors() {
		if (!String.isBlank(errors)) {
			errors = errors.trim();
			errors += '\nHave your Administrator check the Log records for more details.';

			throw new DmlException(errors);
		}
	}
}