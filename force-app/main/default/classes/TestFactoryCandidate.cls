@isTest
public class TestFactoryCandidate {
    /**
	 * @description createCandidate creates a new Candidate__c record in the database.
     * @param  name         name of the Candidate
     * @param  positionId   position Id of the Candidate
	 * @param  fldMap 		additional field values for the Candidate
	 * @return Candidate__c
	 */
 public static Candidate__c createCandidate(String name, String positionId, Map<String, Object> fldMap) {
        Candidate__c testcand = makeCandidate(name, positionId, fldMap);
        insert testcand;
        return testcand;
    }
	/**
	 * @description makePosition makes a new Candidate__c record in the database.
	 * @param  name         name of the Candidate
     * @param  positionId   position Id of the Candidate
     * @param  fldMap 		additional field values for the Candidate
	 * @return Candidate__c
	 */
    public static Candidate__c makeCandidate(String name, String positionId, Map<String, Object> fldMap) {        
        Candidate__c testcand = new Candidate__c(Name = name, Position__c = positionId);
             
        if (fldMap != null) {
            testcand = (Candidate__c) TestFactory.assignFields(fldMap, testcand);
        }
        return testcand;
    }
   
}