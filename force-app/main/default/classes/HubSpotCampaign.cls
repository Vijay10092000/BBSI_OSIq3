/**
 * @description HubSpotCampaign contains methods to handle the Custom Metadata 
 * Setting HubSpot Campaign.
 */
public without sharing class HubSpotCampaign {
	private static final String TEST_CAMPAIGN_ID = 'TEST CAMPAIGN ID';
	private static final String TEST_CAMPAIGN_NAME = 'TEST CAMPAIGN NAME';

	// Map relating the Campaign Id to the Campaign Name
	private static Map<String, String> mapIdToName = null;
	
	/**
	 * @description updateLastTouchCampaign converts a HubSpot Campaign Id to the related 
	 * HubSpot Campaign Name using the Custom Metadata Setting: HubSpot Campaign.  The
	 * update field isHubSpot_Last_Touch_Converting_Campaign__c.
	 * @param  oldLeads  Leads before changes
	 * @param  newLeads  Leads with changes being made
	 */
	public static void updateLastTouchCampaign(Map<Id, Lead> oldLeads, List<Lead> newLeads) {
		for (Lead lead : newLeads) {
			if (lead.HubSpot_Last_Touch_Converting_Campaign__c != null) {
				if (oldLeads?.get(lead.Id).HubSpot_Last_Touch_Converting_Campaign__c != lead.HubSpot_Last_Touch_Converting_Campaign__c) {
					String newName = HubSpotCampaign.getCampaignName(lead.HubSpot_Last_Touch_Converting_Campaign__c);

					if (newName != null) {
						lead.HubSpot_Last_Touch_Converting_Campaign__c = newName;
					}
				}
			}
		}
	}

	/**
	 * @description getCampaignName retrieves the Campaign Name from a Campaign Id.
	 * @param  idCampaign  The identifier searching for
	 * @return The Campaign Name or null if not found.
	 */
    public static String getCampaignName(String idCampaign) {
		if (mapIdToName == null) {
			List<HubSpot_Campaign__mdt> campaigns;

			if (Test.isRunningTest()) {
				campaigns = new List<HubSpot_Campaign__mdt>{
					new HubSpot_Campaign__mdt(
						Campaign_Id__c = TEST_CAMPAIGN_ID,
						Name__c = TEST_CAMPAIGN_NAME
					)
				};
			} else {
				campaigns = HubSpot_Campaign__mdt.getAll().values();
			}

			mapIdToName = new Map<String, String>();

			for (HubSpot_Campaign__mdt hc : campaigns) {
				mapIdToName.put(hc.Campaign_Id__c, hc.Name__c);
			}
		}

		String result = null;

		if (mapIdToName.containsKey(idCampaign)) {
			result = mapIdToName.get(idCampaign); 
		}

		return result;
    }
}