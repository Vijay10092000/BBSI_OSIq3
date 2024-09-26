/**
 * @description OpportunityContactRole_TriggerHandler controls trigger events for OpportunityContactRole objects.
 */
public without sharing class OpportunityContactRole_TriggerHandler extends TriggerHandlerInvoker.TriggerHandler_Abstract {
	override public void afterInsert(Map<Id, SObject> mapNew) {
		Map<Id, OpportunityContactRole> newOCRs = (Map<Id, OpportunityContactRole>) mapNew;

		OpportunityContactRole_Service.updateQuestionnaires(null, newOCRs);
		OpportunityContactRole_Service.updateContacts(null, newOCRs.values());
    }

	override public void afterUpdate(Map<Id, SObject> mapOld, Map<Id, SObject> mapNew) {
		Map<Id, OpportunityContactRole> oldOCRs = (Map<Id, OpportunityContactRole>) mapOld;
		Map<Id, OpportunityContactRole> newOCRs = (Map<Id, OpportunityContactRole>) mapNew;

		OpportunityContactRole_Service.updateQuestionnaires(oldOCRs, newOCRs);
		OpportunityContactRole_Service.updateContacts(oldOCRs, newOCRs.values());
	}
}