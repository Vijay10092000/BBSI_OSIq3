/**
 * @description XmodRecommendedControllerTest contains test methods for the XmodRecommendedController class.
 * Created by CElim on 3/8/2019.
 */
@IsTest
@SuppressWarnings('PMD.ApexAssertionsShouldIncludeMessage')
public with sharing class XmodRecommendedControllerTest {
	static Account client1;
	static Account client2;
	static Work_Comp_Policy__c wcp;
	static WorkCompPolicyAccount__c wcpa1;
	static WorkCompPolicyAccount__c wcpa2;

	@TestSetup
	static void makeData() {
		client1 = TestFactoryAccount.makeClient('TEST CLIENT 1', null, null);
		client2 = TestFactoryAccount.makeClient('TEST CLIENT 2', null, null);
		insert new List<Account>{ client1, client2 };

		Date today = Date.today();

		wcp = TestFactoryWorkCompPolicy.createWorkCompPolicy('C64375416', today.addDays(-7), today.addDays(77), null);
		wcpa2 = TestFactoryWorkCompPolicyAccount.createWorkCompPolicyAccount('C64375416', wcp, client1, null);
		wcpa1 = TestFactoryWorkCompPolicyAccount.createWorkCompPolicyAccount('C64375416', wcp, client2, null);
	}

	static void readData() {
		List<Account> accounts = [SELECT Id, Name, External_Id__c FROM Account WHERE Name LIKE 'TEST CLIENT %' ORDER BY Name ASC];
		client1 = accounts.get(0);
		client2 = accounts.get(1);

		wcp = [SELECT Id, Name, External_ID__c, Effective_Date__c, Term_Date__c FROM Work_Comp_Policy__c LIMIT 1];

		Map<Id, WorkCompPolicyAccount__c> wcpas = new Map<Id, WorkCompPolicyAccount__c>([
			SELECT Id, Name, Client__c, Work_Comp_Policy__c
			FROM WorkCompPolicyAccount__c
			WHERE Client__c IN ( :client1.Id, :client2.Id )
		]);

		wcpa1 = wcpas.get(client1.Id);
		wcpa2 = wcpas.get(client2.Id);
	}

	@IsTest
	static void test_saveXmodRecommended_Simple() {
		readData();

		XmodRecommended__c xmod1 = new XmodRecommended__c();
		xmod1.Policy_Number__c = 'C64375416';
		xmod1.State_Code__c = 'CA';
		xmod1.Effective_Date__c = Date.newInstance(2019, 3, 1);
		xmod1.Xmod__c = 1.25;

		XmodRecommendedController.saveXmodRecommended(new List<XmodRecommended__c>{xmod1});

		List<XmodRecommended__c> xmods;

		xmods = XmodRecommendedController.getXmodRecommended();
		Assert.areEqual(2, xmods.size());
		Assert.areEqual(1.25, xmods[0].Xmod__c);
		Assert.areEqual(null, xmods[0].Client_Info__c);
		Assert.areEqual(1.25, xmods[1].Xmod__c);
		Assert.areEqual(null, xmods[1].Client_Info__c);

		XmodRecommended__c updateXmod = xmods[0];
		updateXmod.Xmod__c = 1.35;

		XmodRecommendedController.saveXmodRecommended(new List<XmodRecommended__c>{updateXmod});

		xmods = XmodRecommendedController.getXmodRecommended();
		Assert.areEqual(2, xmods.size());
		Assert.areEqual(1.35, xmods[0].Xmod__c);
		Assert.areEqual(1.35, xmods[1].Xmod__c);
	}

	@IsTest
	static void test_saveXmodRecommended() {
		readData();

		XmodRecommended__c xmod1 = new XmodRecommended__c(
			Policy_Number__c = 'C64375416',
			State_Code__c = 'CA',
			Effective_Date__c = Date.newInstance(2019, 3, 1),
			Xmod__c = 1.25
		);
		XmodRecommended__c xmod2 = new XmodRecommended__c(
			Client_Info__c = client1.External_Id__c,
			Policy_Number__c = 'C64375422',
			State_Code__c = 'OR',
			Effective_Date__c = Date.newInstance(2019, 3, 1),
			Xmod__c = 1.50
		);

		XmodRecommendedController.saveXmodRecommended(new List<XmodRecommended__c>{ xmod1, xmod2 });

		List<XmodRecommended__c> xmods;

		xmods = XmodRecommendedController.getXmodRecommended();
		System.debug('xmods V1 ::' + xmods);
	//	Assert.areEqual(2, xmods.size());
		Assert.areEqual(1.25, xmods[0].Xmod__c);
		Assert.areEqual(null, xmods[0].Client_Info__c);
		Assert.areEqual(1.25, xmods[1].Xmod__c);
		Assert.areEqual(null, xmods[1].Client_Info__c);

		xmods[0].Xmod__c = 1.35;
		xmods[1].Policy_Number__c = '';
		xmods[1].Xmod__c = 1.89;

		XmodRecommendedController.saveXmodRecommended(xmods);

		xmods = XmodRecommendedController.getXmodRecommended();
		System.debug('xmods V2 ::' + xmods);
		Assert.areEqual(2, xmods.size());
		Assert.areEqual(1.35, xmods[0].Xmod__c);
		Assert.areEqual(1.35, xmods[1].Xmod__c);
	}


	@IsTest
	static void test_saveXmodRecommended_WorkCompPolicyDisplayName() {

		WorkCompPolicyDisplayName__c newPolicy = TestFactoryWorkCompPolicyDisplayName.makeWorkCompPolicyDisplayName('Corvell', 'BBSI', false, null);
		XmodRecommendedController.addWorkCompPolicyDisplayNameMappings(new List<WorkCompPolicyDisplayName__c>{newPolicy});
		List<WorkCompPolicyDisplayName__c> policies = XmodRecommendedController.getWorkCompPolicyDisplayNameMappings();
        Assert.isTrue(policies.size() > 0);
        Assert.areEqual(false, policies[0].Include__c);
		policies[0].Include__c  = true;
		XmodRecommendedController.saveWorkCompPolicyDisplayNameMappings(policies);
		policies = XmodRecommendedController.getWorkCompPolicyDisplayNameMappings();
        Assert.isTrue(policies.size() > 0);
        Assert.areEqual(true, policies[0].Include__c);
	}
}