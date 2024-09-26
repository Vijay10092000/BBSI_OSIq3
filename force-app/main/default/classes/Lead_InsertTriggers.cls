public without sharing class Lead_InsertTriggers {
	public void handle() {
		if (Trigger.isInsert) {
			if (Trigger.isBefore) {
				beforeInsert(Trigger.new);
			}
			else {
				afterInsert(Trigger.newMap);
			}
		}
	}

	private void beforeInsert(List<SObject> listNew) {
		List<Lead> newLeads = (List<Lead>) listNew;
		Lead_Services.setBranches(newLeads);
		Lead_Services.assignLeadFEINs(newLeads, null);
	}

	private void afterInsert(Map<Id, SObject> mapNew) {
		Map<Id, Lead> newLeads = (Map<Id, Lead>) mapNew;

		Lead_Services.updateReferralSourceForLead(null, newLeads.values());
		Lead_Services.updateLeadFEINs(newLeads.values(), null);

		Lead_Services.taskOnQualified(null, newLeads);
	}
}