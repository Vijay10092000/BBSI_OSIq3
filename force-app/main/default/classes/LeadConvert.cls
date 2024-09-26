/**
 * @description LeadConvert contains methods for when a Lead is converted
 * into a Contact, an Account, and an Opportunity.
 */
public without sharing class LeadConvert {
	/**
	 * @description convert performs the actions to convert a Lead to Contact,
	 * Account and possible Opportunity.  Only create the Opportunity when a
	 * Client Lead.
	 * @param  idLead        Lead Identifier
	 * @param  isClientLead  If true creates an Opportunity
	 * @return Database.LeadConvertResult
	 */
	public static Database.LeadConvertResult convert(Id idLead, Boolean isClientLead) {
		Database.LeadConvert lc = new Database.LeadConvert();
		lc.setLeadId(idLead);
		lc.setDoNotCreateOpportunity(!isClientLead);

		return internalConvert(lc);
	}

	/**
	 * @description convert converts a Lead to a Contact under the given Account.
	 * @param  idLead     Lead identifier
	 * @param  idAccount  Account identifier
	 * @return Database.LeadConvertResult
	 */
	public static Database.LeadConvertResult convert(Id idLead, Id idAccount) {
		Database.LeadConvert lc = new Database.LeadConvert();
		lc.setLeadId(idLead);
		lc.setAccountId(idAccount);
		lc.setDoNotCreateOpportunity(true);

		return internalConvert(lc);
	}

	/**
	 * @description internalConvert performs the convert and returns the result.
	 * @param  lc  Convert information
	 * @return Database.LeadConvertResult
	 */
	private static Database.LeadConvertResult internalConvert(Database.LeadConvert lc) {
		LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = TRUE LIMIT 1];

		lc.setConvertedStatus(convertStatus.MasterLabel);

		Database.LeadConvertResult result = Database.convertLead(lc);

		Log.writeIfError(
			'Lead',
			'Lead Conversion Failed',
			'Error converting Lead ' + lc.getLeadId(),
			result
		);

		return result;
	}

	/**
	 * @description getConvertedLeads retrieves the converted Leads from the given.
	 * @param  mapOld  Map of Leads before the changes
	 * @param  mapNew  Map of Leads with changes
	 * @return Map<Id, Lead>
	 */
	public static Map<Id, Lead> getConvertedLeads(Map<Id, Lead> mapOld, Map<Id, Lead> mapNew) {
		Map<Id, Lead> result = new Map<Id, Lead>();

		for (Lead lead : mapNew.values()) {
			if (lead.isConverted) {
				if (mapOld == null || lead.isConverted != mapOld.get(lead.Id).isConverted) {
					result.put(lead.Id, lead);
				}
			}
		}

		return result;
	}

	/**
	 * @description performConvertActions perform actions to converted Leads.  The converted Leads
	 * have work done on them through a Platform Event named Lead Conversion.
	 * @param  mapOld  Map of Leads before the changes
	 * @param  mapNew  Map of Leads with changes
	 */
	public static void performConvertActions(Map<Id, Lead> mapOld, Map<Id, Lead> mapNew) {
		Map<Id, Lead> converted = getConvertedLeads(mapOld, mapNew);

		if (!converted.isEmpty()) {
			PlatformEvent.fireLeadConversion(converted.keySet());
		}
	}
}