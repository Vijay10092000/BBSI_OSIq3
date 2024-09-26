@isTest
public class TestFactoryEvent {
    /**
	 * @description createEvent creates a new Event record in the database.
	 * @param  recordType       RecordType of the Event
	 * @param  fldMap 		additional field values for the Event
	 * @return Event
	 */
	public static Event createEvent(String recordType, Map<String, Object> fldMap) {
		Event testEvent = makeEvent(recordType, fldMap);
		insert testEvent;
		return testEvent;
	}

	/**
	 * @description makeEvent makes a new Event record in the database.
	 * @param  recordType       RecordType of the Event
	 * @param  fldMap 		additional field values for the Event
	 * @return Event
	 */
	public static Event makeEvent(String recordType, Map<String, Object> fldMap) {        
		Event testEvent = new Event();
		if(String.isNotBlank(recordType)){
			Id idrtEvent = RecordTypeService.getId('Event', recordType);
			testEvent.RecordTypeId = idrtEvent;
		}        
        if (fldMap != null) {
			testEvent = (Event) TestFactory.assignFields(fldMap, testEvent);
		}
		return testEvent;
	}

	/**
	 * @description createReferralPartnerGeneralEvent Creates a new Referral Partner General Event record in the database.
	 * @param  userId       	Owner Id of the Event
	 * @param  WhatId			Parent record Id of the Event
	 * @param  Type       		Type of the Event
	 * @param  fldMap 			additional field values for the Event
	 * @return Event
	 */
	public static Event createReferralPartnerGeneralEvent(String userId, String WhatId, String whoId, String Type, Map<String, Object> fldMap) {
		Event testEvent = makeEvent('Referral Partner General', userId, WhatId, whoId, Type, fldMap);
		insert testEvent;
		return testEvent;
	}

	/**
	 * @description createEvent Creates a new Event record in the database.
	 * @param  recordType       RecordType of the Event
	 * @param  userId       	Owner Id of the Event
	 * @param  WhatId			WhatId of the Event
	 * @param  whoId			whoId of the Event
	 * @param  Type       		Type of the Event
	 * @param  fldMap 			additional field values for the Event
	 * @return Event
	 */
	public static Event createEvent(String recordType, String userId, String WhatId, String whoId, String Type, Map<String, Object> fldMap) {
		Event testEvent = makeEvent(recordType, userId, WhatId, whoId, Type, fldMap);
		insert testEvent;
		return testEvent;
	}

	/**
	 * @description makeEvent makes a new Event record in the database.
	 * @param  recordType       RecordType of the Event
	 * @param  userId       	Owner Id of the Event
	 * @param  WhatId			WhatId of the Event
	 * @param  whoId			whoId of the Event
	 * @param  Type       		Type of the Event
	 * @param  fldMap 			additional field values for the Event
	 * @return Event
	 */
	public static Event makeEvent(String recordType, String userId, String WhatId, String whoId, String Type, Map<String, Object> fldMap) {        
		Event testEvent = new Event( ActivityDateTime = DateTime.now(), Description = 'EVENT 1', DurationInMinutes = 60);
		if(String.isNotBlank(userId)){
			testEvent.OwnerId = userId;
		}
		if(String.isNotBlank(WhatId)){
			testEvent.WhatId = WhatId;
		}
		if(String.isNotBlank(whoId)){
			testEvent.whoId = whoId;
		}
		if(String.isNotBlank(Type)){
			testEvent.Type = Type;
		}
		if(String.isNotBlank(recordType)){
			Id idrtEvent = RecordTypeService.getId('Event', recordType);
			testEvent.RecordTypeId = idrtEvent;
		}      
		if (fldMap != null) {
			testEvent = (Event) TestFactory.assignFields(fldMap, testEvent);
		}
		return testEvent;
	}
}