/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class BusinessUnitEmail_Controller_Test {

    static testMethod void testController() {
    	Account a = TestFactoryAccount.createBranch('TestAccount'); // ('TestAccount', '98662', 'BBSI Branch', TRUE);
    	a.Branch_Manager__c = UserInfo.getName();
    	update a;
        Business_Unit__c bu = TestFactoryBusinessUnit.createBusinessUnit('Test BU', a.Id); // ('Test BU', a,TRUE);
        Contact c = TestFactoryContact.createContact(null, 'Test_Contact', 'BBSI Employee', a.Id); // (a, 'Test Contact', 'BBSI Employee',  TRUE);
        c.User_Id__c = UserInfo.getUserId();
        update c;
        Business_Unit_Contact__c bc = TestFactoryBusinessUnitContact.createBusinessUnitContact(bu, TRUE, 'Test', c);
        List<Business_Unit_Contact__c> temp = new List<Business_Unit_Contact__c>();
        temp.add(bc);
		BusinessUnitEmail_Controller cntrlr = new BusinessUnitEmail_Controller();
		cntrlr.AreaManagerID = UserInfo.getUserId();
        cntrlr.getBusinessUnits();
        Assert.areEqual(cntrlr.branchesIdsByBranch.keySet().size(), 1);
        //BusinessUnitEmail_Controller.BU_Wrapper('Test BU',bu.Id,temp);
    }
}