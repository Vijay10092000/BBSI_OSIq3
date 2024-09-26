/**
 * @description WorkCompPolicyRelatedListExtensionTest contains the tests for
 * the WorkCompPolicyRelatedListExtension controller.
 */
@IsTest
private class WorkCompPolicyRelatedListExtensionTest {
	@TestSetup
	static void makeData() {
		Account testAccount = TestFactoryAccount.createClient('TestAccount', null, null);

		Work_Comp_Policy__c wcp1 = TestFactoryWorkCompPolicy.makeWorkCompPolicy(
			'testWorkCompPolicy1',
			System.today().addDays(1),
			System.today(),
			null
		);
		Work_Comp_Policy__c wcp2 = TestFactoryWorkCompPolicy.makeWorkCompPolicy(
			'testWorkCompPolicy2',
			System.today().addDays(1),
			System.today(),
			null
		);
		Work_Comp_Policy__c wcp3 = TestFactoryWorkCompPolicy.makeWorkCompPolicy(
			'testWorkCompPolicy3',
			System.today().addDays(1),
			System.today(),
			null
		);
		insert new List<Work_Comp_Policy__c>{ wcp1, wcp2, wcp3 };

		WorkCompPolicyAccount__c wcpa1 = TestFactoryWorkCompPolicyAccount.makeWorkCompPolicyAccount(
			'NeedChange1',
			wcp1,
			testAccount,
			null
		);
		WorkCompPolicyAccount__c wcpa2 = TestFactoryWorkCompPolicyAccount.makeWorkCompPolicyAccount(
			'NeedChange2',
			wcp2,
			testAccount,
			null
		);
		insert new List<WorkCompPolicyAccount__c>{ wcpa1, wcpa2 };
	}

	@IsTest
	static void policyViewTest() {
        Account testAccount = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount' LIMIT 1];

        Assert.areNotEqual(null, testAccount, 'Test account did not get created');

		PageReference pageRef = Page.WorkCompPolicyRelatedList;
		pageRef.getParameters().put('ID', testAccount.Id);
		Test.setCurrentPage(pageRef);

		ApexPages.StandardController controllerAccount = new ApexPages.StandardController(testAccount);
		WorkCompPolicyRelatedListExtension controllerWCP = new WorkCompPolicyRelatedListExtension(controllerAccount);

		Assert.areEqual(
			'TestAccount',
			controllerWCP.workingAccount.Name,
			'Account should be the created test account'
		);
		Assert.areEqual(2, controllerWCP.wcPolicies.size(), 'Only 2 entries relate to the test acccount');
		Assert.areEqual(2, controllerWCP.relatedPolicies.size(), 'Only 2 entries in related to the test acccount');
	}
}