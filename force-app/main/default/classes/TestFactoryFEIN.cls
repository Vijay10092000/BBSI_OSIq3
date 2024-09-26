@isTest
public class TestFactoryFEIN {
    /**
    * @description createFEIN creates a FEIN record.
    * @param  fldMap  Additional fields to set on FEIN
    * @return FEIN
    */
    public static FEIN__c createFEIN( Map<String, Object> fldMap) {
        FEIN__c testFEIN = makeFEIN( fldMap);
        insert testFEIN;
        return testFEIN;
    }
    
    /**
    * @description makeFEIN creates a FEIN record.
    * @param  fldMap  Additional fields to set on FEIN
    * @return FEIN
    */
    public static FEIN__c makeFEIN( Map<String, Object> fldMap) {        
        FEIN__c testFEIN = new FEIN__c();
        
        if (fldMap != null) {
            testFEIN = (FEIN__c) TestFactory.assignFields(fldMap, testFEIN);
        }
        return testFEIN;
    }
    
}