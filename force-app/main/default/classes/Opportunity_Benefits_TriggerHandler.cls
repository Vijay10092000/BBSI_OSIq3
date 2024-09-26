/**
 * @description Opportunity_Benefits_TriggerHandler performs the trigger events
 * for the a Benefits Opportunity object.
 */
public with sharing class Opportunity_Benefits_TriggerHandler extends TriggerHandlerInvoker.TriggerHandler_Abstract {
	/**
	 * @description beforeInsert performs actions on the mapNew sObjects before the insert happens.
	 * NOTE: Before Insert records have no Id, so are not be able to use Map<>.
	 * @param listNew is the list of new sObjects
	 */
	override public void beforeInsert(List<SObject> listNew) {
		List<Opportunity> listOppsNew = (List<Opportunity>) listNew;

		OpportunityBenefits_Service.beforeInsert(listOppsNew);
	}

	/**
	 * @description afterInsert performs actions on related objects to the mapNew sObjects after
	 * the insert.
	 * @param mapNew is the map of sObjects after being saved
	 */
	override public void afterInsert(Map<Id, SObject> mapNew) {
		Map<Id, Opportunity> mapNewOpps = (Map<Id, Opportunity>) mapNew;

		OpportunityBenefits_Service.afterInsert(mapNewOpps.values());
	}

	/**
	 * @description beforeUpdate performs actions on the mapNew sObjects before the update happens.
	 *
	 * @param mapOld is the map of sObjects before the new changes
	 * @param mapNew is the map of sObjects with the changes
	 */
	override public void beforeUpdate(Map<Id, SObject> mapOld, Map<Id, SObject> mapNew) {
		Debug_Service.differences(
			LoggingLevel.DEBUG,
			'Opportunity_Benefits_TriggerHandler changes BEFORE UPDATE - START',
			mapOld,
			mapNew
		);

		Map<Id, Opportunity> mapOldOpps = (Map<Id, Opportunity>) mapOld;
		Map<Id, Opportunity> mapNewOpps = (Map<Id, Opportunity>) mapNew;

		OpportunityBenefits_Service.beforeUpdate(mapOldOpps, mapNewOpps.values());

		System.debug('Opportunity_Benefits_TriggerHandler BEFORE UPDATE - END');
	}

	/**
	 * @description afterUpdate performs actions on related objects to the mapNew sObjects after
	 * the update.
	 *
	 * @param mapOld is the map of sObjects before the new changes
	 * @param mapNew is the map of sObjects with the saved changes
	 */
	override public void afterUpdate(Map<Id, SObject> mapOld, Map<Id, SObject> mapNew) {
		Debug_Service.differences(
			LoggingLevel.DEBUG,
			'Opportunity_Benefits_TriggerHandler AFTER UPDATE - START',
			mapOld,
			mapNew
		);

		Map<Id, Opportunity> mapOldOpps = (Map<Id, Opportunity>) mapOld;
		Map<Id, Opportunity> mapNewOpps = (Map<Id, Opportunity>) mapNew;

		OpportunityBenefits_Service.afterUpdate(mapOldOpps, mapNewOpps.values());

		System.debug('Opportunity_Benefits_TriggerHandler AFTER UPDATE - END');
	}
}