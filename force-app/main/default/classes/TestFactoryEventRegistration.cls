@isTest
public class TestFactoryEventRegistration {
    /**
    * @description createEventRegtePayrollmaster creates a EventRegistration record.
    * @param  fldMap  Additional fields to set on EventRegistration
    * @return EventRegistration
    */
    public static Event_Registration__c createEventReg( Map<String, Object> fldMap) {
        Event_Registration__c testEventReg = makeEventReg( fldMap);
        insert testEventReg;
        return testEventReg;
    }
    
    /**
    * @description makeEventReg creates a EventRegistration record.
    * @param  fldMap  Additional fields to set on EventRegistration
    * @return EventRegistration
    */
    public static Event_Registration__c makeEventReg( Map<String, Object> fldMap) {        
        Event_Registration__c testEventReg = new Event_Registration__c();
        
        if (fldMap != null) {
            testEventReg = (Event_Registration__c) TestFactory.assignFields(fldMap, testEventReg);
        }
        return testEventReg;
    }
    
}