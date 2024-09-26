/**
 * @description Lead_TriggerHandler controls trigger events for Lead objects.
 */
public without sharing class Lead_TriggerHandler extends TriggerHandlerInvoker.TriggerHandler_Abstract {
	override public void beforeInsert(List<SObject> listNew) {
		List<Lead> newLeads = (List<Lead>) listNew;

		Lead_Services.setStatus(null, newLeads);
		Lead_Services.fixPhoneNumbers(newLeads);
		Lead_Services.hasOnePhoneNumber(null, newLeads);

		(new LeadValidation()).handle();
		(new Lead_InsertTriggers()).handle();
		LeadHubSpotRP.updateReferralPartners(null, listNew);
		Naics_Service.populateNAICS(null, newLeads);
		Lead_Services.setFields(null, newLeads);
		HubSpotCampaign.updateLastTouchCampaign(null, newLeads);
	}

	override public void afterInsert(Map<Id, SObject> mapNew) {
		Map<Id, Lead> newLeads = (Map<Id, Lead>) mapNew;

		(new BdmSharing()).processLeads(null, newLeads.values());

		(new LeadValidation()).handle();
		(new Lead_InsertTriggers()).handle();
	}

	override public void beforeUpdate(Map<Id, SObject> mapOld, Map<Id, SObject> mapNew) {
		Map<Id, Lead> oldLeads = (Map<Id, Lead>) mapOld;
		Map<Id, Lead> newLeads = (Map<Id, Lead>) mapNew;

		Lead_Services.setStatus(oldLeads, newLeads.values());
		Lead_Services.fixPhoneNumbers(newLeads.values());
		Lead_Services.hasOnePhoneNumber(oldLeads, newLeads.values());

		(new LeadValidation()).handle();
		(new Lead_UpdateTriggers()).handle();
		LeadHubSpotRP.updateReferralPartners(oldLeads, newLeads.values());
		Naics_Service.populateNAICS(oldLeads, newLeads.values());
		Lead_Services.setFields(oldLeads, newLeads.values());
		HubSpotCampaign.updateLastTouchCampaign(oldLeads, newLeads.values());
	}

	override public void afterUpdate(Map<Id, SObject> mapOld, Map<Id, SObject> mapNew) {
		Map<Id, Lead> mapOldLeads = (Map<Id, Lead>) mapOld;
		Map<Id, Lead> mapNewLeads = (Map<Id, Lead>) mapNew;

		(new BdmSharing()).processLeads(mapOldLeads, mapNewLeads.values());

		(new ReferralPartnerOnConversion()).handle();
		(new Lead_UpdateTriggers()).handle();
	}
}