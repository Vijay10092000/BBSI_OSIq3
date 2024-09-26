public without sharing class Lead_UpdateTriggers {
	public void handle() {
		if (Trigger.isUpdate) {
			if (Trigger.isBefore) {
				beforeUpdate(Trigger.oldMap, Trigger.newMap);
			}
			else {
				afterUpdate(Trigger.oldMap, Trigger.newMap);
			}
		}
	}

	public void beforeUpdate(Map<Id, SObject> mapOld, Map<Id, SObject> mapNew) {
		Map<Id, Lead> newLeads = (Map<Id, Lead>) mapNew;
		Map<Id, Lead> oldLeads = (Map<Id, Lead>) mapOld;

		Lead_Services.setBranches(newLeads.values(), oldLeads);

		DupeCatcher.leadConversion(newLeads.values());
		Lead_Services.setUnverify(newLeads, oldLeads);
		Lead_Services.assignLeadFEINs(newLeads.values(), oldLeads.values());
	}

	public void afterUpdate(Map<Id, SObject> mapOld, Map<Id, SObject> mapNew) {
		Map<Id, Lead> newLeads = (Map<Id, Lead>) mapNew;
		Map<Id, Lead> oldLeads = (Map<Id, Lead>) mapOld;

		Lead_Services.updateReferralSourceForLead(oldLeads, newLeads.values());
		LeadConvert.performConvertActions(oldLeads, newLeads);
		Lead_Services.updateLeadFEINs(newLeads.values(), null);
		Lead_Services.addAdditionalContacts(oldLeads, newLeads.values());
		Lead_Services.taskOnQualified(oldLeads, newLeads);
	}
}