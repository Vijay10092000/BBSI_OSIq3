/**
 * @description Lead_Dlrs_TriggerHandler performs Declarative Lookup Roll-up Summaries
 * on Leads.
 */
public with sharing class Lead_Dlrs_TriggerHandler extends TriggerHandlerInvoker.TriggerHandler_Abstract {
	/**
	 * @description beforeInsert performs actions on the mapNew sObjects before the insert happens.
	 * NOTE: Before Insert records have no Id, so are not be able to use Map<>.
	 * @param listNew is the list of new sObjects
	 */
	override public void beforeInsert(List<SObject> listNew) {
		dlrs.RollupService.triggerHandler(Lead.SObjectType);
	}

	/**
	 * @description afterInsert performs actions on related objects to the mapNew sObjects after
	 * the insert.
	 * @param mapNew is the map of sObjects after being saved
	 */
	override public void afterInsert(Map<Id, SObject> mapNew) {
		dlrs.RollupService.triggerHandler(Lead.SObjectType);
	}

	/**
	 * @description beforeUpdate performs actions on the mapNew sObjects before the update happens.
	 * @param mapOld is the map of sObjects before the new changes
	 * @param mapNew is the map of sObjects with the changes
	 */
	override public void beforeUpdate(Map<Id, SObject> mapOld, Map<Id, SObject> mapNew) {
		dlrs.RollupService.triggerHandler(Lead.SObjectType);
	}

	/**
	 * @description afterUpdate performs actions on related objects to the mapNew sObjects after
	 * the update.
	 * @param mapOld is the map of sObjects before the new changes
	 * @param mapNew is the map of sObjects with the saved changes
	 */
	override public void afterUpdate(Map<Id, SObject> mapOld, Map<Id, SObject> mapNew) {
		dlrs.RollupService.triggerHandler(Lead.SObjectType);
	}

	/**
	 * @description beforeDelete performs actions on the mapOld sObjects before the delete happens.
	 * @param mapOld is the map of sObjects before deletion
	 */
	override public void beforeDelete(Map<Id, SObject> mapOld) {
		dlrs.RollupService.triggerHandler(Lead.SObjectType);
	}

	/**
	 * @description afterDelete performs actions on related to the mapOld sObjects after
	 * the delete.
	 * @param mapOld is the map of sObjects which have been deleted
	 */
	override public void afterDelete(Map<Id, SObject> mapOld) {
		dlrs.RollupService.triggerHandler(Lead.SObjectType);
	}

	/**
	 * @description beforeUpdate performs actions on the mapNew sObjects after the undelete happens.
	 *
	 * @param mapNew is the map of sObjects which have been undeleted
	 */
	override public void afterUndelete(Map<Id, SObject> mapNew) {
		dlrs.RollupService.triggerHandler(Lead.SObjectType);
	}
}