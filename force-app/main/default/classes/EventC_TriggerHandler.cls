/**
 * @description EventC_TriggerHandler controls trigger events for Event__c objects.
 */
public without sharing class EventC_TriggerHandler extends TriggerHandlerInvoker.TriggerHandler_Abstract {
	/**
	 * @description beforeInsert performs actions on the mapNew sObjects before the insert happens.
	 * NOTE: Before Insert records have no Id, so are not be able to use Map<>.
	 * @param listNew  is the list of new sObjects
	 */
	override public void beforeInsert(List<SObject> listNew) {
		List<Event__c> newEvents = (List<Event__c>) listNew;

		EventC_Services.correctFields(null, newEvents);
	}

	/**
	 * @description afterInsert performs actions on related objects to the mapNew sObjects after
	 * the insert.
	 * @param mapNew  is the map of sObjects after being saved
	 */
	override public void afterInsert(Map<Id, SObject> mapNew) {
		Map<Id, Event__c> newEvents = (Map<Id, Event__c>) mapNew;

		EventC_Services.createTasks(null, newEvents.values());
	}

	/**
	 * @description beforeUpdate performs actions on the mapNew sObjects before the update happens.
	 * @param mapOld  is the map of sObjects before the new changes
	 * @param mapNew  is the map of sObjects with the changes
	 */
	override public void beforeupdate(Map<Id, SObject> mapOld, Map<Id, SObject> mapNew) {
		Map<Id, Event__c> oldEvents = (Map<Id, Event__c>) mapOld;
		Map<Id, Event__c> newEvents = (Map<Id, Event__c>) mapNew;

		EventC_Services.correctFields(oldEvents, newEvents.values());
	}

	/**
	 * @description afterUpdate performs actions on related objects to the mapNew sObjects after
	 * the update.
	 * @param mapOld  is the map of sObjects before the new changes
	 * @param mapNew  is the map of sObjects with the saved changes
	 */
	override public void afterUpdate(Map<Id, SObject> mapOld, Map<Id, SObject> mapNew) {
		Map<Id, Event__c> oldEvents = (Map<Id, Event__c>) mapOld;
		Map<Id, Event__c> newEvents = (Map<Id, Event__c>) mapNew;

		EventC_Services.createTasks(oldEvents, newEvents.values());
	}
}