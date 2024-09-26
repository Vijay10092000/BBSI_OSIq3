@IsTest
@SuppressWarnings('PMD.ApexAssertionsShouldIncludeMessage')
private class PricingScenarioBuildDirector_Test {
    @testSetup
	static void setup() {
        // Create Tax Table data
		List<ER_Payroll_Tax_Master__c> taxTable = new List<ER_Payroll_Tax_Master__c>();

		taxTable.add(TestFactoryRenewals.createErPayrollTaxMaster('FED', 'FICA', 6.2, 127200, false));
		taxTable.add(TestFactoryRenewals.createErPayrollTaxMaster('FED', 'MEDI', 1.45, 0, false));
		taxTable.add(TestFactoryRenewals.createErPayrollTaxMaster('FED', 'FUTA', 2.1, 7000, false));
		taxTable.add(TestFactoryRenewals.createErPayrollTaxMaster('CA', 'SUTA', 6.2, 7000, false));
		taxTable.add(TestFactoryRenewals.createErPayrollTaxMaster('NV', 'SUTA', 6.2, 7000, false));
		insert taxTable;

		Account account = TestFactory.createAccount('900022', '98662', 'Client', true);
		account.External_ID__c = '900022';
		update account;

		Renewal__c myRenewal = TestFactoryRenewals.createRenewal('Tester DEF', '99-1234567', 'New', false);
		insert(myRenewal);
    }

	@IsTest
	static void test_BuildDirectorWithData() {
		LdfModel.useTestRate = 1.5;

		Renewal__c renewal = [SELECT Id, (SELECT Id, External_ID__c FROM Clients__r) FROM Renewal__c WHERE FEIN__c = '99-1234567' LIMIT 1];

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new PricingDataCalloutClass_Mock('','',''));
		integer client = 901153;
		PricingDataModel pricingModel = new PricingDataModel(client, Date.today().addDays(45));

		pricingModel.GetData();

		PricingSummaryDataModel pricingSummaryModel = new PricingSummaryDataModel(client, Date.today().addDays(45), 'fein_here');

		pricingSummaryModel.GetData();

		Test.setMock(HttpCalloutMock.class, new WorkCompCalloutClass_Mock('','',''));
		client = 905158;
		WorkCompRenewalsDataModel workCompModel = new WorkCompRenewalsDataModel(client, Date.today().addDays(45));

		workCompModel.GetData();

		Test.setMock(HttpCalloutMock.class, new PricingDataCalloutClass_Mock('','',''));
		PricingScenarioDataModel pricingScenarioModel = new PricingScenarioDataModel(client, Date.today().addDays(45));

		pricingScenarioModel.GetData();

		Map<String, PricingDataModel> pricingModelMap = new Map<String, PricingDataModel>();
		pricingModelMap.put('900022', pricingModel);
		Map<String, PricingSummaryDataModel> pricingSummaryModelMap = new Map<String, PricingSummaryDataModel>();
		pricingSummaryModelMap.put('900022', pricingSummaryModel);
		Map<String, PricingScenarioDataModel> pricingScenarioDataModelMap = new Map<String, PricingScenarioDataModel>();
		pricingScenarioDataModelMap.put('900022', pricingScenarioModel);

		PricingScenarioBuildDirector buildDirector = new PricingScenarioBuildDirector('My Pricing Scenario', renewal.Id,
				pricingModelMap, pricingScenarioDataModelMap, pricingSummaryModelMap);

		buildDirector.BuildAll();

		ERPayrollTax__c[] prTaxes = [SELECT Id from ERPayrollTax__c];
		system.assert(prTaxes.size() > 0);

		PricingExpense__c[] prExp = [SELECT Id from PricingExpense__c];
		system.assert(prExp.size() > 0);

		PricingEmployee__c[] ees = [SELECT Id from PricingEmployee__c];
		system.assert(ees != null);

		PricingWcCode__c[] wcs = [SELECT Id from PricingWcCode__c];
		system.assert(wcs != null);

		PricingEEtoWcCodeAssoc__c[] assoc = [SELECT Id from PricingEEtoWcCodeAssoc__c];
		system.assert(assoc != null);

		System.assert(buildDirector.PricingScenario != null);
		System.assert(buildDirector.PricingScenario.ScenarioName__c == 'My Pricing Scenario');

		System.assert(buildDirector.ClientPricingScenarioMap.values() != null);

		System.assert(buildDirector.ClientPricingScenarioMap != null);
		System.assert(buildDirector.ErPayrollTaxesMap != null);
		System.assert(buildDirector.PricingExpensesMap != null);
		System.assert(buildDirector.PricingEmployeesMap != null);

    	Test.stopTest();
	}
}