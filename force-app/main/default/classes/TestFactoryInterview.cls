@isTest
public class TestFactoryInterview {
	/**
	 * @description createInterview creates a new Interview__c record in the database.
     * @param  name             name of the Interview
     * @param  candidateId      candidate Id of the Interview
     * @param  interviewerId    interviewer Id of the Interview
	 * @param  fldMap 		    additional field values for the Interview
	 * @return Interview__c
	 */
    public static Interview__c createInterview(String name, String candidateId, String interviewerId, Map<String, Object> fldMap) {
        Interview__c testinter = makeInterview( name, candidateId, interviewerId, fldMap);
        insert testinter;
        return testinter;
    }
    /**
	 * @description makeInterview makes a new Interview__c record in the database.
     * @param  name             name of the Interview
     * @param  candidateId      candidate Id of the Interview
     * @param  interviewerId    interviewer Id of the Interview
	 * @param  fldMap 		additional field values for the Interview
	 * @return Interview__c
	 */
    public static Interview__c makeInterview(String name, String candidateId, String interviewerId, Map<String, Object> fldMap) {        
        Interview__c testinter = new Interview__c(Name = name, Candidate__c = candidateId, Interviewer__c = interviewerId, When__c = System.today());
             
        if (fldMap != null) {
            testinter = (Interview__c) TestFactory.assignFields(fldMap, testinter);
        }
        return testinter;
    }

}