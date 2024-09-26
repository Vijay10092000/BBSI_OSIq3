@IsTest
@SuppressWarnings('PMD.ApexAssertionsShouldIncludeMessage ')
public without sharing class BenefitsPlansSelection_Controller_Test {
	private static Account client;
	private static Opportunity opp1;
	private static Benefits_Plan__c plan1;
	private static Benefits_Plan__c plan2;
	private static Benefits_Plan__c plan3;
	private static Benefits_Plan__c plan4;
	private static Benefits_Plan_Opp_Junction__c junctionOpp1;
	private static Benefits_Plan_Opp_Junction__c junctionOpp2;
	private static Benefits_Plan_Benefits_Junction__c junctionBen1;
	private static Benefits_Plan_Benefits_Junction__c junctionBen2;
	private static Benefits__c benefits1;

	@TestSetup
	static void makeData() {
        client = TestFactoryAccount.createClient('!!TEST_CLIENT_SERVICE',null,null);
        opp1 = TestFactoryOpportunity.createBenefits('!!BENEFITS_TEST_CLIENT_SERVICE', client.Id, Date.Today().addDays(7), 'Benefits Client Data Gathering');
        Benefits__c benefits1 = TestFactoryBenefits.createBenefits('testbenefits1',client.id,null,opp1.id,'Yes');
        Benefits_Plan__c plan1 = TestFactoryBenefitsPlan.makeBenefitsPlan('Testbenplan1','Dental','!!TEST PLAN 1');
        Benefits_Plan__c plan2 = TestFactoryBenefitsPlan.makeBenefitsPlan('Testbenplan2','Dental','!!TEST PLAN 2');
        Benefits_Plan__c plan3 = TestFactoryBenefitsPlan.makeBenefitsPlan('Testbenplan3','Dental','!!TEST PLAN 3');
        Benefits_Plan__c plan4 = TestFactoryBenefitsPlan.makeBenefitsPlan('Testbenplan4','Dental','!!TEST PLAN 4');
		insert new List<Benefits_Plan__c>{ plan1, plan2, plan3, plan4 };
		
        junctionOpp1 = TestFactoryBenefitsPlanOppJunction.makeBenefitsPlanOppJunction(opp1.id,plan1.id);
        junctionOpp2 = TestFactoryBenefitsPlanOppJunction.makeBenefitsPlanOppJunction(opp1.id,plan4.id);
		insert new List<Benefits_Plan_Opp_Junction__c>{ junctionOpp1, junctionOpp2 };

        junctionBen1=TestFactoryBenefitsPlanBenefitsJunction.makeBenefitsPlanBenJunction(benefits1.Id,plan1.Id);
        junctionBen2=TestFactoryBenefitsPlanBenefitsJunction.makeBenefitsPlanBenJunction(benefits1.Id,plan4.Id);
		insert new List<Benefits_Plan_Benefits_Junction__c>{ junctionBen1, junctionBen2 };
	}

	static void loadData() {
		client = [SELECT Id, Name FROM Account WHERE Name = '!!TEST_CLIENT_SERVICE' LIMIT 1];
		opp1 = [SELECT Id, Name FROM Opportunity WHERE Name = '!!BENEFITS_TEST_CLIENT_SERVICE' LIMIT 1];
		benefits1 = [SELECT Id, Name, Opportunity__c FROM Benefits__c WHERE AccountId__c = :client.Id LIMIT 1];

		List<Benefits_Plan__c> plans = [
			SELECT Id, Plan_Name__c, Product__c
			FROM Benefits_Plan__c
			WHERE Plan_Name__c LIKE '!!TEST PLAN %'
			ORDER BY Plan_Name__c ASC
		];
		plan1 = plans.get(0);
		plan2 = plans.get(1);
		plan3 = plans.get(2);
		plan4 = plans.get(3);

		List<Benefits_Plan_Opp_Junction__c> listJunctionOpps = [
			SELECT Id, Opportunity__c, Benefits_Plan__c
			FROM Benefits_Plan_Opp_Junction__c
			WHERE Opportunity__c = :opp1.Id
		];

		Assert.areEqual(2, listJunctionOpps.size());
		junctionOpp1 = listJunctionOpps.get(0);
		junctionOpp2 = listJunctionOpps.get(1);

		List<Benefits_Plan_Benefits_Junction__c> listJunctionBens = [
			SELECT Id, Benefits__c, Benefits_Plan__c
			FROM Benefits_Plan_Benefits_Junction__c
			WHERE Benefits__r.AccountId__c = :client.Id
		];

		Assert.areEqual(2, listJunctionBens.size());
		junctionBen1 = listJunctionBens.get(0);
		junctionBen2 = listJunctionBens.get(1);
	}

	@IsTest
	public static void test_setupOpportunity() {
		loadData();
		BenefitsPlansSelection_Controller.InitData data = BenefitsPlansSelection_Controller.setup(opp1.Id);
		Assert.areEqual('Add Benefits Plans for Opportunity', data.title);
		Assert.areEqual('Opportunity', data.typeRecord);
		Assert.areEqual(opp1.Id, data.idRecord);
		Assert.areEqual(opp1.Name, data.nameRecord);
		Assert.areEqual(4, data.optionsAll.size());
		Assert.areEqual(2, data.optionsSelected.size());
		Assert.areEqual(0, data.optionsRequired.size());
	}

	@IsTest
	public static void test_setupBenefits() {
		loadData();
		BenefitsPlansSelection_Controller.InitData data = BenefitsPlansSelection_Controller.setup(benefits1.Id);
		Assert.areEqual('Add Benefits Plans for Benefits', data.title);
		Assert.areEqual('Benefits', data.typeRecord);
		Assert.areEqual(benefits1.Id, data.idRecord);
		Assert.areEqual(benefits1.Name, data.nameRecord);
		Assert.areEqual(4, data.optionsAll.size());
		Assert.areEqual(2, data.optionsSelected.size());
		Assert.areEqual(0, data.optionsRequired.size());
	}

	@IsTest
	public static void test_setupUnknown() {
		loadData();
		BenefitsPlansSelection_Controller.InitData data = BenefitsPlansSelection_Controller.setup(client.Id);
		Assert.areEqual(client.Id, data.idRecord);
		Assert.areEqual('NONE', data.nameRecord);
		Assert.areEqual('UNKNOWN', data.typeRecord);
	}

	@IsTest
	public static void test_onSaveOpportunity() {
		loadData();
		Test.startTest();
		BenefitsPlansSelection_Controller.onSave(opp1.Id, new List<Id>{ plan2.Id, plan4.Id });
		Test.stopTest();
		List<Benefits_Plan_Opp_Junction__c> junctions = [
            SELECT Id, Opportunity__c, Benefits_Plan__c, Benefits_Plan__r.Name
            FROM Benefits_Plan_Opp_Junction__c
            WHERE Opportunity__c = :opp1.Id
        ];

		Boolean hasPlan2 = false;
		Boolean hasPlan4 = false;

		for (Benefits_Plan_Opp_Junction__c junction : junctions) {
			if (junction.Benefits_Plan__c == plan2.Id) {
				hasPlan2 = true;
			}
			else if (junction.Benefits_Plan__c == plan4.Id) {
				hasPlan4 = true;
			}
		}

		Assert.areEqual(2, junctions.size());
		Assert.isTrue(hasPlan2);
		Assert.isTrue(hasPlan4);
	}

	@IsTest
	public static void test_onSaveBenefits() {
		loadData();
		Test.startTest();
		BenefitsPlansSelection_Controller.onSave(benefits1.Id, new List<Id>{ plan2.Id, plan4.Id });
		Test.stopTest();
		List<Benefits_Plan_Benefits_Junction__c> junctions = [
            SELECT Id, Benefits__c, Benefits_Plan__c, Benefits_Plan__r.Name
            FROM Benefits_Plan_Benefits_Junction__c
            WHERE Benefits__c = :benefits1.Id
        ];

		Boolean hasPlan2 = false;
		Boolean hasPlan4 = false;

		for (Benefits_Plan_Benefits_Junction__c junction : junctions) {
			if (junction.Benefits_Plan__c == plan2.Id) {
				hasPlan2 = true;
			}
			else if (junction.Benefits_Plan__c == plan4.Id) {
				hasPlan4 = true;
			}
		}

		Assert.areEqual(2, junctions.size());
		Assert.isTrue(hasPlan2);
		Assert.isTrue(hasPlan4);
	}
}