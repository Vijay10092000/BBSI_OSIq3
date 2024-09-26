/*
 #####################################################
 # Created By....................: Deval Shah
 # Created Date................: 29 May, 2019
 # Last Modified By..........: Loch MacLeod
 # Last Modified Date......: 2019-08-29
 # Description...................: This is test class for FieldSetController, Wrapperclass class.
 #####################################################
*/
@isTest
private class FieldSetControllerTest {
    /**
     * @author : Deval Shah
     * @date : 29 May, 2019
     * @description : This method create test data.
    */
    @testSetup
    private static void setup() {
        Account a1 = TestFactoryAccount.createBranch('TEST ACCOUNT 1');
        Contact con = TestFactoryContact.createEmployee(null, null, 'Lastname1', a1.Id);        
        Form__c formObj1 = TestFactoryForm.createForm(new Map<String, Object>{ 'Name' => 'W2c' });        

        Case case1 = TestFactoryCase.makeCase(null, new Map<String, Object>{
            'ContactId' => con.Id,
            'Primary_Form__c' => formObj1.Id,
            'Skip_Automation__c' => true
        });
        Case case2 = TestFactoryCase.makeCase(null, new Map<String, Object>{
            'ContactId' => con.Id,
            'Skip_Automation__c' => true
        });
        insert new List<Case> {case1, case2};
    }
    
    /**
     * @author : Deval Shah
     * @date : 29 May, 2019
     * @description : This method is to test FieldSetController fieldList method.
    */
    @isTest static void testFieldList() {
        // query all Case records
        List<Case> caseObjList = [SELECT Id, Primary_Form__c FROM Case];
        Assert.areEqual(2, caseObjList.size(), 'Outcome Should be 2');
        
        test.startTest();
        Wrapperclass wrapClassObj = FieldSetController.fieldList(caseObjList[0].Id);
        Assert.areEqual(caseObjList[0].Primary_Form__c, wrapClassObj.formId, 'Outcome Should match');
        
        wrapClassObj = FieldSetController.fieldList(caseObjList[1].Id);
        Assert.areEqual(null, wrapClassObj, 'Outcome Should be null');
        test.stopTest();
    }
}