@isTest
public class TestFactoryEventc {
    /**
	 * @description createEvent creates a new Event record in the database.
	 * @param  recordType       recordType of the Event__c
	 * @param  fldMap 		additional field values for the Event__c
	 * @return Event__c
	 */
	public static Event__c createEvent(String recordType, Map<String, Object> fldMap) {
		Event__c testEvent = makeEvent(recordType, fldMap);
		insert testEvent;
		return testEvent;
	}

	/**
	 * @description makeEvent makes a new Event record in the database.
	 * @param  recordType       recordType of the Event__c
	 * @param  fldMap 		additional field values for the Event__c
	 * @return Event__c
	 */
	public static Event__c makeEvent(String recordType, Map<String, Object> fldMap) {        
		Event__c testEvent = new Event__c();
		if(String.isNotBlank(recordType)){
			Id idrtEvent = RecordTypeService.getId('Event__c', recordType);
			testEvent.RecordTypeId = idrtEvent;
		}        
        if (fldMap != null) {
			testEvent = (Event__c) TestFactory.assignFields(fldMap, testEvent);
		}
		return testEvent;
	}
}