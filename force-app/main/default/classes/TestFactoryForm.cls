@isTest
public class TestFactoryForm {
    /**
    * @description createForm creates a Form record.
    * @param  fldMap  Additional fields to set on Form
    * @return Form
    */
    public static Form__c createForm( Map<String, Object> fldMap) {
        Form__c testForm = makeForm( fldMap);
        insert testForm;
        return testForm;
    }
    
    /**
    * @description makeForm creates a Form record.
    * @param  fldMap  Additional fields to set on Form
    * @return Form
    */
    public static Form__c makeForm( Map<String, Object> fldMap) {        
        Form__c testForm = new Form__c();
        
        if (fldMap != null) {
            testForm = (Form__c) TestFactory.assignFields(fldMap, testForm);
        }
        return testForm;
    }
    
}