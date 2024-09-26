/**
 * @description TestFactoryCase contains methods to create test Case.
 */
@IsTest
public without sharing class TestFactoryCase {
	/**
	 * @description createCase creates a new Case record in the database.
	 * @param  subject       subject of the Case
	 * @param  description   description of the Case
	 * @param  contactId     contact Id of the Case
	 * @param  branchId      branch Id of the Case
	 * @param  clientId      client Id of the Case
	 * @param  recordType 	Record Type name for the Case
	 * @param  fldMap 		additional field values for the Case
	 * @return Case
	 */
	public static Case createCase(String subject, String description,String contactId, String branchId,String clientId, String recordType, Map<String, Object> fldMap) {
		Case testCase = makeCase(subject, description, contactId, branchId, clientId, recordType, fldMap);
		insert testCase;
		return testCase;
	}

	/**
	 * @description makeCase makes a new Case record in the database.
	 * @param  subject       subject of the Case
	 * @param  description   description of the Case
	 * @param  contactId     contact Id of the Case
	 * @param  branchId      branch Id of the Case
	 * @param  clientId      client Id of the Case
	 * @param  recordType 	Record Type name for the Case
	 * @param  fldMap 		additional field values for the Case
	 * @return Case
	 */
	public static Case makeCase(String subject, String description,String contactId, String branchId,String clientId, String recordType, Map<String, Object> fldMap) {
		Case testCase = new Case(
			Subject = subject,
            Description = description,
            ContactId = contactId,
            AccountId = branchId,
            Related_Account__c = clientId,
            Skip_Automation__c = true
		); 
		if(String.isNotBlank(recordType)){
			Id idrtCase = RecordTypeService.getId('Case', recordType);
			testCase.RecordTypeId = idrtCase;
		}         
        if (fldMap != null) {
			testCase = (Case) TestFactory.assignFields(fldMap, testCase);
		}
		return testCase;
	}	

	/**
	 * @description createCase creates a new Case record in the database.
	 * @param  recordType       recordType of the Case
	 * @param  fldMap 		additional field values for the Case
	 * @return Case
	 */
	public static Case createCase(String recordType, Map<String, Object> fldMap) {
		Case testCase = makeCase(recordType, fldMap);
		insert testCase;
		return testCase;
	}

	/**
	 * @description makeCase makes a new Case record in the database.
	 * @param  recordType       recordType of the Case
	 * @param  fldMap 		additional field values for the Case
	 * @return Case
	 */
	public static Case makeCase(String recordType, Map<String, Object> fldMap) {        
		Case testCase = new Case();
		if(String.isNotBlank(recordType)){
			Id idrtCase = RecordTypeService.getId('Case', recordType);
			testCase.RecordTypeId = idrtCase;
		}        
        if (fldMap != null) {
			testCase = (Case) TestFactory.assignFields(fldMap, testCase);
		}
		return testCase;
	}
}