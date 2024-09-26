/**
 * @description Event_TriggerHandler controls trigger events for Event objects.
 */
public without sharing class Event_TriggerHandler extends TriggerHandlerInvoker.TriggerHandler_Abstract {
	/**
	 * @description afterInsert performs actions on the objects before saving
	 * @param listNew  New Leads before save
	 */
	override public void beforeInsert(List<SObject> listNew) {
		List<Event> newEvents = (List<Event>) listNew;

		Event_Services.blockInvalidCreation(newEvents);
		Event_Services.validateFields(null, newEvents);
		Event_Services.setRecordType(newEvents);
		Event_Services.setInitialFields(newEvents);
	}

	/**
	 * @description afterInsert performs actions on related objects to the mapNew sObjects after
	 * the insert.
	 * @param mapNew  is the map of sObjects after being saved
	 */
	override public void afterInsert(Map<Id, SObject> mapNew) {
		Map<Id, Event> newEvents = (Map<Id, Event>) mapNew;

		Event_Services.updateRelatedRecords(newEvents);
		Event_Services.createTasks(null, newEvents.values());
	}

	/**
	* @description beforeUpdate performs actions on the mapNew sObjects before
	* the update.
	* @param mapOld  is the map of sObjects before the new changes
	* @param mapNew  is the map of sObjects with the saved changes
	*/
	override public void beforeUpdate(Map<Id, SObject> mapOld, Map<Id, SObject> mapNew) {
		Map<Id, Event> oldEvents = (Map<Id, Event>) mapOld;
		Map<Id, Event> newEvents = (Map<Id, Event>) mapNew;

		Event_Services.validateFields(oldEvents, newEvents.values());
		Event_Services.updateFields(oldEvents, newEvents.values());
	}

	/**
	* @description afterUpdate performs actions on related objects to the mapNew sObjects after
	* the update.
	* @param mapOld  is the map of sObjects before the new changes
	* @param mapNew  is the map of sObjects with the saved changes
	*/
	override public void afterUpdate(Map<Id, SObject> mapOld, Map<Id, SObject> mapNew) {
		Map<Id, Event> oldEvents = (Map<Id, Event>) mapOld;
		Map<Id, Event> newEvents = (Map<Id, Event>) mapNew;

		Event_Services.createTasks(oldEvents, newEvents.values());
		Event_Services.updateFirstMeeting(oldEvents, newEvents.values());
	}
}