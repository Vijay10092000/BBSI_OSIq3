@isTest
public class TestFactoryPosition {
    /**
	 * @description createPosition creates a new Position record in the database.
	 * @param  branchId       branchId of the Position
	 * @param  recordType     recordType of the Position
	 * @param  fldMap 		additional field values for the Position
	 * @return Position__c
	 */
	 public static Position__c createPosition(String branchId, String recordtype, Map<String, Object> fldMap) {
        Position__c testpos = makePosition(branchId, recordtype, fldMap);
        insert testpos;
        return testpos;
    }
    /**
	 * @description makePosition makes a new Position record in the database.
	 * @param  branchId       branchId of the Position
	 * @param  recordType       recordType of the Position
	 * @param  fldMap 		additional field values for the Position
	 * @return Position__c
	 */
    public static Position__c makePosition(String branchId, String recordtype, Map<String, Object> fldMap) {        
        Position__c testpos = new Position__c(Branch__c = branchId, Status__c = 'open');
        if(String.isNotBlank(recordType)){
			Id idrtPosition = RecordTypeService.getId('Position__c', recordType);
			testpos.RecordTypeId = idrtPosition;
		}        
        if (fldMap != null) {
            testpos = (Position__c) TestFactory.assignFields(fldMap, testpos);
        }
        return testpos;
    }

}