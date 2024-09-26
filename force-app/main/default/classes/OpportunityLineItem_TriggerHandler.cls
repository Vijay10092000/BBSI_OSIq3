/**
 * @description OpportunityLineItem_TriggerHandler performs the trigger events
 * for the OpportunityLineItem object.
 */
public without sharing class OpportunityLineItem_TriggerHandler extends TriggerHandlerInvoker.TriggerHandler_Abstract {
	/**
	 * @description afterInsert performs actions on related objects to the mapNew sObjects after
	 * the insert.
	 * @param mapNew is the map of sObjects after being saved
	 */
	override public void afterInsert(Map<Id, SObject> mapNew) {
		Map<Id, OpportunityLineItem> mapNewItems = (Map<Id, OpportunityLineItem>) mapNew;

		OpportunityLineItem_Service.updateOpportunityProducts(mapNewItems.values());
	}

	/**
	 * @description afterUpdate performs actions on related objects to the mapNew sObjects after
	 * the update.
	 *
	 * @param mapOld is the map of sObjects before the new changes
	 * @param mapNew is the map of sObjects with the saved changes
	 */
	override public void afterUpdate(Map<Id, SObject> mapOld, Map<Id, SObject> mapNew) {
		Map<Id, OpportunityLineItem> mapOldItems = (Map<Id, OpportunityLineItem>) mapOld;
		Map<Id, OpportunityLineItem> mapNewItems = (Map<Id, OpportunityLineItem>) mapNew;

		OpportunityLineItem_Service.updateOpportunityProducts(mapNewItems.values());
	}

	/**
	 * @description afterDelete performs actions on related to the mapOld sObjects after
	 * the delete.
	 * @param mapOld is the map of sObjects which have been deleted
	 */
	override public void afterDelete(Map<Id, SObject> mapOld) {
		Map<Id, OpportunityLineItem> mapOldItems = (Map<Id, OpportunityLineItem>) mapOld;

		OpportunityLineItem_Service.updateOpportunityProducts(mapOldItems.values());
	}
}