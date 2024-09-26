/**
 * @description EventRegistration_TriggerHandler performs the trigger events for
 * a Event Registration (Event_Registration__c) SObject.
 */
public with sharing class EventRegistration_TriggerHandler extends TriggerHandlerInvoker.TriggerHandler_Abstract {
    /**
     * @description beforeInsert performs actions on the mapNew sObjects before the insert happens.
     * NOTE: Before Insert records have no Id, so are not be able to use Map<>.
     * @param newList is the list of new sObjects
     */
    override public void beforeInsert(List<SObject> newList) {
		List<Event_Registration__c> listNew = (List<Event_Registration__c>) newList;

		EventRegistration_Services.setRegistrantCompany(null, listNew);
		EventRegistration_Services.addAttendeeEvents(null, listNew);
	}

    /**
     * @description beforeUpdate performs actions on the mapNew sObjects before the update happens.
     * @param oldMap is the map of sObjects before the new changes
     * @param newMap is the map of sObjects with the changes
     */
	@SuppressWarnings('PMD.UnusedLocalVariable')
	override public void beforeUpdate(Map<Id, SObject> oldMap, Map<Id, SObject> newMap) {
		Map<Id, Event_Registration__c> mapOld = (Map<Id, Event_Registration__c>) oldMap;
		Map<Id, Event_Registration__c> mapNew = (Map<Id, Event_Registration__c>) newMap;

		EventRegistration_Services.setRegistrantCompany(mapOld, mapNew.values());
		EventRegistration_Services.addAttendeeEvents(mapOld, mapNew.values());
	}
}