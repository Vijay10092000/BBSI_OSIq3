/**
 * @description Opportunity_TriggerHandler performs the trigger events
 * for the Opportunity object.
 */
public without sharing class Opportunity_TriggerHandler extends TriggerHandlerInvoker.TriggerHandler_Abstract {
	/**
	 * @description beforeInsert performs actions on the mapNew sObjects before the insert happens.
	 * NOTE: Before Insert records have no Id, so are not be able to use Map<>.
	 * @param listNew is the list of new sObjects
	 */
	override public void beforeInsert(List<SObject> listNew) {
		List<Opportunity> newOpps = (List<Opportunity>) listNew;

		Opportunity_Service.newOpportunity(newOpps);
		Opportunity_Service.setFields(null, newOpps);
		Opportunity_Service.onClose(null, newOpps);

		(new OpportunityProducts_Handler(null, listNew)).beforeInsert();
	}

	/**
	 * @description afterInsert performs actions on related objects to the mapNew sObjects after
	 * the insert.
	 * @param mapNew is the map of sObjects after being saved
	 */
	override public void afterInsert(Map<Id, SObject> mapNew) {
		Map<Id, Opportunity> mapNewOpps = (Map<Id, Opportunity>) mapNew;
		
		/* 
		 * updateFieldsFromLead is Future method.
		 * When we run the BenefitsRenewalBatch to create Benefits Renewal Opp, 
		 * it fails. Hence added a check for isBatch.
		 * Also we don't need this function for Benefits Renewal Opportunities
		 */
		if (!System.isBatch()) {
			Opportunity_Service.updateFieldsFromLead(mapNewOpps.KeySet());
		}
		
		Opportunity_Service.sendEmailOpportunityClosed(null, mapNewOpps);

		(new OpportunityProducts_Handler(null, mapNewOpps.values())).afterInsert();
	}

	/**
	 * @description beforeUpdate performs actions on the mapNew sObjects before the update happens.
	 *
	 * @param mapOld is the map of sObjects before the new changes
	 * @param mapNew is the map of sObjects with the changes
	 */
	override public void beforeUpdate(Map<Id, SObject> mapOld, Map<Id, SObject> mapNew) {
		Map<Id, Opportunity> mapOldOpps = (Map<Id, Opportunity>) mapOld;
		Map<Id, Opportunity> mapNewOpps = (Map<Id, Opportunity>) mapNew;

		Opportunity_Service.setFields(mapOldOpps, mapNewOpps.values());
		Opportunity_Service.onClose(mapOldOpps, mapNewOpps.values());

		(new OpportunityValidation(mapOldOpps, mapNewOpps.values())).beforeUpdate();
	}

	/**
	 * @description afterUpdate performs actions on related objects to the mapNew sObjects after
	 * the update.
	 *
	 * @param mapOld is the map of sObjects before the new changes
	 * @param mapNew is the map of sObjects with the saved changes
	 */
	override public void afterUpdate(Map<Id, SObject> mapOld, Map<Id, SObject> mapNew) {
		Map<Id, Opportunity> mapOldOpps = (Map<Id, Opportunity>) mapOld;
		Map<Id, Opportunity> mapNewOpps = (Map<Id, Opportunity>) mapNew;

		Opportunity_Service.sendEmailOpportunityClosed(mapOldOpps, mapNewOpps);

		(new OpportunityProducts_Handler(mapOldOpps, mapNewOpps.values())).afterUpdate();
	}
}