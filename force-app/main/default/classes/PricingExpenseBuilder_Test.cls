@isTest
private class PricingExpenseBuilder_Test {
	
	@testSetup static void setup() {
		// Implement test code
		Renewal__c myRenewal = new Renewal__c(
			Name = 'Tester DEF',
			FEIN__c = '99-1234567',
			Status__c = 'New');
		insert(myRenewal);

	}
	
	@isTest static void EnumerateExpenses() {
		Integer client = 900022;
		Account account = TestFactory.createAccount('' + client, '98662', 'Client', true);
		account.External_ID__c = '' + client;
		update account;

		// Implement test code
		Renewal__c myRenewal = [SELECT Id FROM Renewal__c WHERE FEIN__c = '99-1234567'];

		String scenarioName = 'My Pricing Scenario';

		PricingScenarioBuilder psBuilder = new PricingScenarioBuilder(scenarioName, myRenewal.Id);
		PricingScenario__c pScenario = psBuilder.GetResult();

		Test.startTest();
        Test.setMock(HttpCalloutMock.class, new PricingDataCalloutClass_Mock('','',''));

		PricingScenarioDataModel pricingScenarioModel = new PricingScenarioDataModel(client, Date.today().addDays(45));
		pricingScenarioModel.GetData();
    	
		Test.stopTest();

    	Map<String, PricingScenarioDataModel> PricingScenarioModelMap = new Map<String, PricingScenarioDataModel>();
		PricingScenarioModelMap.put('900022', pricingScenarioModel);

		ClientPricingScenarioBuilder cpsBuilder = new ClientPricingScenarioBuilder(pScenario, myRenewal.Id, PricingScenarioModelMap);
		Map<String, ClientPricingScenario__c> ClientPricingScenarioMap = cpsBuilder.GetResult();

		PricingExpenseBuilder expenseBuilder = new PricingExpenseBuilder(ClientPricingScenarioMap.get('900022'));
		expenseBuilder.GetResult();
		List<PricingExpense__c> pricingExpenses = expenseBuilder.PricingExpenses;

		System.assert(pricingExpenses != null);
		System.assert(pricingExpenses.size() == 3);
		System.assert(pricingExpenses[0].Category__c == 'Time Clocks');
		System.assert(pricingExpenses[0].Cost_Each__c == 0);
		System.assert(pricingExpenses[0].Quantity__c == 0);
		System.assert(pricingExpenses[0].Total__c == 0);

		List<PricingClientInvestment__c> pricingClientInvestments = expenseBuilder.PricingClientInvestments;
		System.assert(pricingClientInvestments != null);
		System.assert(pricingClientInvestments.size() == 1);
		System.assert(pricingClientInvestments[0].Description__c == 'Client Investment');
		System.assert(pricingClientInvestments[0].Rate__c == 0.39);
	}
	
}