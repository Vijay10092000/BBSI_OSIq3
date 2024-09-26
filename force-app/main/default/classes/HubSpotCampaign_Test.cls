/**
 * @description HubSpotCampaign_Test contains tests for the HubSpotCampaign class.
 */
@IsTest
public without sharing class HubSpotCampaign_Test {
	@IsTest
    static void test_getCampaignName() {
		Assert.IsNull(HubSpotCampaign.getCampaignName(null));
		Assert.IsNull(HubSpotCampaign.getCampaignName('Unknown ID'));

		Assert.areEqual('TEST CAMPAIGN NAME', HubSpotCampaign.getCampaignName('TEST CAMPAIGN ID'));
	}
	
	@IsTest
    static void test_updateLastTouchCampaign() {
		Lead lead1 = TestFactoryLead.makeClientLead('TEST', 'LEAD1', 'A', null, null);
		lead1.HubSpot_Last_Touch_Converting_Campaign__c = 'TEST CAMPAIGN ID';
		Lead lead2 = TestFactoryLead.makeClientLead('TEST', 'LEAD2', 'A', null, null);
		lead2.HubSpot_Last_Touch_Converting_Campaign__c = null;
		Lead lead3 = TestFactoryLead.makeClientLead('TEST', 'LEAD3', 'A', null, null);
		lead3.HubSpot_Last_Touch_Converting_Campaign__c = 'UNKNOWN CAMPAIGN ID';

		HubSpotCampaign.updateLastTouchCampaign(null, new List<Lead>{ lead1, lead2, lead3 });

		Assert.areEqual('TEST CAMPAIGN NAME', lead1.HubSpot_Last_Touch_Converting_Campaign__c);
		Assert.isNull(lead2.HubSpot_Last_Touch_Converting_Campaign__c);
		Assert.areEqual('UNKNOWN CAMPAIGN ID', lead3.HubSpot_Last_Touch_Converting_Campaign__c);
	}
}