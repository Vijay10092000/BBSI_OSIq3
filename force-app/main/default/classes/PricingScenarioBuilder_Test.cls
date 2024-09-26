@isTest
private class PricingScenarioBuilder_Test {
	
	@isTest static void createPricingScenario() {

		String scenarioName = 'My Pricing Scenario';

		Renewal__c myRenewal = new Renewal__c(
			Name = 'Tester DEF',
			FEIN__c = '99-1234567',
			Status__c = 'New');

		insert myRenewal;

		PricingScenarioBuilder psBuilder;
		PricingScenario__c pScenario;
		Integer recCount;

		If(PricingScenarioBuilder.IsNameUnique(scenarioName, myRenewal.Id)) {

			psBuilder = new PricingScenarioBuilder(scenarioName, myRenewal.Id);
			pScenario = psBuilder.GetResult();
		}

		System.assert(PricingScenarioBuilder.IsNameUniqueinEdit(scenarioName, myRenewal.Id, pScenario.Id) == true);
		recCount = [SELECT COUNT() FROM PricingScenario__c
					WHERE ScenarioName__c like :scenarioName 
					AND Renewal__r.Id = :myRenewal.Id];

		System.assertEquals(recCount, 1);
		System.assert(pScenario != null);
		System.assert(psBuilder.HasData == true);
	}
	
	
}