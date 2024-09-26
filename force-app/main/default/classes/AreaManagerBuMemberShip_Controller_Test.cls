/**
 * @description AreaManagerBuMemberShip_Controller_Test contains tests for the AreaManagerBuMemberShip_Controller class.
 */
@IsTest
private class AreaManagerBuMemberShip_Controller_Test {
	@IsTest
    static void AreaManagerBuMemberShipTest() {
        Account a = TestFactoryAccount.makeAccount('TestAccount', 'BBSI Branch'); 
        insert a;
         
        PageReference pageRef = Page.AreaManagerBUMemberShip;
        pageRef.getParameters().put('BR', a.Id);
        Test.setCurrentPage(pageRef);

        User u = testFactoryUser.makeUser(null,'TestAccount', 'Area Manager', '910', 'test1@bbsihq.com', 'test1@bbsihq.com');
		insert u;

        AreaManagerBuMemberShip_Controller cntrlr = new AreaManagerBuMemberShip_Controller();
        Assert.isNotNull(cntrlr.AreaManager, 'Area Manager should not be empty');
        Assert.isNotNull(cntrlr.BranchId, 'Branch Id should not be empty');
    }

    static testMethod void AreaManagerBuMemberShipTestNegetive() {
        Account a = TestFactoryAccount.makeAccount('TestAccount', 'BBSI Branch'); 
        insert a;

        User u = testFactoryUser.makeUser(null,'TestAccount', 'Area Manager', '910', 'test1@bbsihq.com', 'test1@bbsihq.com');
		insert u;

        AreaManagerBuMemberShip_Controller cntrlr = new AreaManagerBuMemberShip_Controller();
        Assert.isNotNull(cntrlr.AreaManager, 'Area Manager should not be empty');
        Assert.isNotNull(cntrlr.BranchId, 'Branch Id should not be empty');
    } 
}