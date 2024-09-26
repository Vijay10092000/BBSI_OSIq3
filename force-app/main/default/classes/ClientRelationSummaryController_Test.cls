/**
 * @description ClientRelationSummaryController_Test contains tests
 * for the ClientRelationSummaryController class.
 */
@IsTest
private class ClientRelationSummaryController_Test {
	private static final String TEST_ACCOUNT_ID = '001000000000000001234';
	
	@TestSetup
	static void setup() {
		List<User> uList = new List<User>();
		List<Account> testAccts = new List<Account>();

		Account branch = TestFactoryAccount.makeBranch('TestBranch1', 'AAA', null, null);
		branch.Region__c = 'SoCal';
		branch.Zone__c = '1';
		testAccts.add(branch);
		insert testAccts;

		User areaManager = TestFactoryUser.makeUser('Area', 'Manager', 'Area Manager', 'AAA');
        areaManager.Email = 'AreaManager@bbsihq.com';
        areaManager.Username = 'AreaManager@bbsihq.com';
		areaManager.Title = 'Area Manager';
		areaManager.IsActive = true;
		uList.add(areaManager);

		User user = TestFactoryUser.makeUser('BDMUser', 'BDMUser', 'BBSI Standard', 'AAA');
        user.Email = 'TestBBSI_deleteAttachment@bbsihq.com';
        user.Username = 'TestBBSI_deleteAttachment@bbsihq.com';
		user.Title = 'Business Development Manager';
		user.IsActive = true;
		uList.add(user);

		insert uList;

		Business_Unit__c bu1 = TestFactoryBusinessUnit.createBusinessUnit('Test BU', Branch.Id);
		Contact contact = TestFactoryContact.makeContact('BU', 'Contact', 'BBSI Employee', branch.Id);
		contact.User_Id__c = user.Id;
		insert contact;

		Business_Unit_Contact__c buc = TestFactoryBusinessUnitContact.makeBusinessUnitContact(bu1, true, 'Payroll Specialist', contact);
		insert buc;

		TestFactoryContact.createContact('Dave', 'Smith', 'Client Contact', branch.Id);
	}

	@IsTest
	static void testClientRelation() {
		Business_Unit__c bu = [SELECT Id FROM Business_Unit__c WHERE Name = 'Test BU' LIMIT 1];

		ClientRelationSummaryController controller = new ClientRelationSummaryController();
		controller.BUid = bu.Id;
		controller.accountID = TEST_ACCOUNT_ID;

		List<Business_Unit_Contact__c> teams = controller.getBUteams();

		Assert.areEqual(teams.size(), 1);
		Assert.areEqual(teams[0].Role__c, 'Payroll Specialist');
		Assert.areEqual(TEST_ACCOUNT_ID, controller.accountID);
	}
}