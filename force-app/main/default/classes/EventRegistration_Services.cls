/**
 * @description EventRegistration_Services handles events from triggers and has
 * addtional methods for handling Event_Registratio__c records.
 */
public without sharing class EventRegistration_Services {
	/**
	 * @description setRegistrantCompany set the company's Account Id in the Event Registration record.
	 * @param  mapOld   Event_Registration__c records before changes
	 * @param  listNew  Event_Registration__c records with changes
	 */
	public static void setRegistrantCompany(Map<Id, Event_Registration__c> mapOld, List<Event_Registration__c> listNew) {
		Map<Id, Event_Registration__c> mapContactRegistrations = new Map<Id, Event_Registration__c>();

		for (Event_Registration__c er : listNew) {
			if (er.Contact__c != null) {
				mapContactRegistrations.put(er.Contact__c, er);
			}
		}

		if (!mapContactRegistrations.isEmpty()) {
			Map<Id, Id> mapContactAccount = Contact_Services.getRelatedAccountId(mapContactRegistrations.keySet());

			for (Event_Registration__c er : mapContactRegistrations.values()) {
				if (mapContactAccount.containsKey(er.Contact__c)) {
					er.Company1__c = mapContactAccount.get(er.Contact__c);
				}
			}
		}
	}

	/**
	 * @description addAttendeeEvents determines which Event_Registration__c need to have
	 * Events created for them, then perform the action.
	 * has been attended.
	 * @param  mapOld   Event_Registration__c records before changes
	 * @param  listNew  Event_Registration__c records with changes
	 */
	public static void addAttendeeEvents(Map<Id, Event_Registration__c> mapOld, List<Event_Registration__c> listNew) {
		List<Event_Registration__c> listWork = new List<Event_Registration__c>();

		for (Event_Registration__c er : listNew) {
			if (er.Attended__c) {
				if (mapOld == null || !mapOld.get(er.Id).Attended__c) {
					listWork.add(er);
				}
			}
		}

		if (!listWork.isEmpty()) {
			(new EventRegistration_AttendedEvent()).perform(listWork);
		}
	}
}