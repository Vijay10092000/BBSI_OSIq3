@isTest
public class TestFactoryBranchRegion {
	/**
	 * @description createBranchreg creates a new Branch Region record in the database.
	 * @param  name     Name of the Branch Region
	 * @param  user     User of the Branch Region
	 * @param  fldMap 	additional field values for the Branch Region
	 * @return Branch_Region__c
	 */
    public static Branch_Region__c createBranchreg(String name, String user, Map<String, Object> fldMap) {
        Branch_Region__c testbranchreg = makeBranchreg(name, user, fldMap);
        insert testbranchreg;
        return testbranchreg;
    }
    
    /**
	 * @description makePosition makes a new Branch Region record in the database.
	 * @param  name     Name of the Branch Region
	 * @param  user     User of the Branch Region
	 * @param  fldMap 	additional field values for the Branch Region
	 * @return Branch_Region__c
	 */
	public static Branch_Region__c makeBranchreg(String name, String user, Map<String, Object> fldMap) {        
        Branch_Region__c testbranchreg = new Branch_Region__c( Name = name, User__c = user);
        if (fldMap != null) {
            testbranchreg = (Branch_Region__c) TestFactory.assignFields(fldMap, testbranchreg);
        }
        return testbranchreg;
    }  
}