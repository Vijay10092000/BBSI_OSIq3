/**
 * @description LeadHubSpotRP handles Referral Partner changes from HubSpot on Leads.
 */
public with sharing class LeadHubSpotRP {
	@TestVisible
	private static Map<String, HubSpot_Referral_Partner__mdt> hubSpotRPs = null;

	/**
	 * @description updateReferralPartners handles changes to HubSpot Referral Partner.  Uses the custom
	 * metadata object HubSpot_Referral_Partner__c to determine the new Referral Partner and Producer.
	 */
	public static void updateReferralPartners(Map<Id, Lead> oldLeads, List<Lead> newLeads) {
		readHubSpotReferralPartners();

		for (Lead lead : newLeads) {
			if (
				oldLeads == null ||
				oldLeads.get(lead.Id).HubSpot_Referral_Partner__c != lead.HubSpot_Referral_Partner__c
			) {
				if (hubSpotRPs.containsKey(lead.HubSpot_Referral_Partner__c)) {
					HubSpot_Referral_Partner__mdt hrp = hubSpotRPs.get(lead.HubSpot_Referral_Partner__c);

					lead.Referral_Partner__c = hrp.Referral_Partner_Id__c;
					lead.Producer__c = hrp.Producer_Id__c;
				}
			}
		}
	}

	/**
	 * @description readHubSpotReferralPartners reads the custom metadata HubSpot_Referral_Partner__mdts
	 * if not already set.
	 */
	@TestVisible
	private static void readHubSpotReferralPartners() {
		if (hubSpotRPs == null) {
			hubSpotRPs = new Map<String, HubSpot_Referral_Partner__mdt>();

			for (HubSpot_Referral_Partner__mdt hrp : [
				SELECT MasterLabel, Referral_Partner_Id__c, Producer_Id__c
				FROM HubSpot_Referral_Partner__mdt
			]) {
				hubSpotRPs.put(hrp.MasterLabel, hrp);
			}
		}
	}
}