/**
 * @description AccountHierarchy_Test
 */
@IsTest
public without sharing class AccountHierarchy_Test {
	@IsTest
	static void testAccountHierarchy() {
		test.startTest();

		Account topAccount = TestFactoryAccount.makeAccount('Test Name One', 'Parent');
		topAccount.Comments__c = 'HierarchyTest0';
		insert topAccount;

		Account middleAccount = TestFactoryAccount.makeClient('Test Name Two', null, null);
		middleAccount.Comments__c = 'HierarchyTest4';
		middleAccount.ParentId = middleAccount.Id;
		insert middleAccount;

		Account bottomAccount = TestFactoryAccount.makeClient('Test Name Three', null, null);
		bottomAccount.Comments__c = 'HierarchyTest9';
		bottomAccount.ParentId = middleAccount.Id;
		insert bottomAccount;

		PageReference pageAccountHierarchy = Page.AccountHierarchyPage;
		Test.setCurrentPage(pageAccountHierarchy);
		ApexPages.currentPage().getParameters().put('id', topAccount.id);

		// Instanciate Controller
		AccountStructure controller = new AccountStructure();

		// Call Methodes for top account
		controller.setcurrentId(null);
		AccountStructure.ObjectStructureMap[] smt1 = new List<AccountStructure.ObjectStructureMap>{};
		smt1 = controller.getObjectStructure();
		Assert.isTrue(smt1.size() > 0, 'Test failed at Top account, no Id');

		controller.setcurrentId(String.valueOf(topAccount.id));
		AccountStructure.ObjectStructureMap[] smt2 = new List<AccountStructure.ObjectStructureMap>{};
		smt2 = controller.getObjectStructure();
		Assert.isTrue(smt2.size() > 0, 'Test failed at Top account, with Id: ' + smt2.size());

		// Call ObjectStructureMap methodes
		smt2[0].setnodeId('1234567890');
		smt2[0].setlevelFlag(true);
		smt2[0].setlcloseFlag(false);
		smt2[0].setnodeType('parent');
		smt2[0].setcurrentNode(false);
		smt2[0].setaccount(topAccount);

		// Call Methodes for middle account
		controller.setcurrentId(String.valueOf(middleAccount.id));
		AccountStructure.ObjectStructureMap[] smm = new List<AccountStructure.ObjectStructureMap>{};
		smm = controller.getObjectStructure();
		Assert.isTrue(smm.size() > 0, 'Test failed at middle account');

		// Call Methodes for bottom account
		controller.setcurrentId(String.valueOf(bottomAccount.id));
		AccountStructure.ObjectStructureMap[] smb = new List<AccountStructure.ObjectStructureMap>{};
		smb = controller.getObjectStructure();
		Assert.isTrue(smb.size() > 0, 'Test failed at top account');

		test.stopTest();
	}
}