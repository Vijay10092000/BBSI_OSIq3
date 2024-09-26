@IsTest
private class PricingScenarioCloneDirector_Test 
{
    @TestSetup static void setup() {}

	@IsTest static void CloneDirectorWithData() 
	{
        // Create Classes and Store Test Data
        Integer numPricingScenarios = 2;
        Integer numClients = 2;
        Integer numEmployees = 5;

        PricingScenario__c[] pricingScenarios = TestFactoryRenewals.createPricingScenarios(numPricingScenarios, numClients, numEmployees);

		PricingScenarioCloneDirector cloneDirector = new PricingScenarioCloneDirector();
		cloneDirector.CloneScenario(pricingScenarios[0], 'My NEW Pricing Scenario');

		cloneDirector.CloneScenario('old', 'new', pricingScenarios[0].Renewal__c);
		cloneDirector.CloneScenario(new PricingScenario__c(),'clone new');

		PricingScenario__c[] pricingScenarioSource = [
				SELECT Id, CreatedDate__c, LastModifiedDate__c, Renewal__c, ScenarioName__c, Status__c,
				(
						SELECT  Id, BDM__c, BDM_Rate__c, BDM_Basis__c, ClientId__c, ClientName__c, Published_Xmod__c,
								ReferralPartner__c, ReferralPartnerRate__c, Xmod__c, commAcronym__c, commCompany__c, commRate__c, commType__c, 
								commBasis__c, commBlendedFactor__c, commChksInPeriod__c, commWeeksInPeriod__c
						FROM ClientPricingScenarios__r
				)
				FROM PricingScenario__c
		];
		
		for(PricingScenario__c item : pricingScenarioSource) {
			System.debug('ScenarioName__c: ' + item.ScenarioName__c );
			System.debug('Renewal__c: ' + item.Renewal__c);
		}

		cloneDirector.CloneScenario(pricingScenarios[0].ScenarioName__c, 'My NEWEST Pricing Scenario', pricingScenarios[0].Renewal__c);
		
		// one more, but this one will generate an error as the name won't be unique
		cloneDirector.CloneScenario(pricingScenarios[0].ScenarioName__c, pricingScenarios[0].ScenarioName__c, pricingScenarios[0].Renewal__c);

		// Count records
		PricingScenario__c[] ps = [SELECT Id FROM PricingScenario__c];
		ClientPricingScenario__c[] cps = [SELECT Id, PricingScenario__c FROM ClientPricingScenario__c];
		PricingEmployee__c[] ees = [SELECT Id, ClientPricingScenario__c FROM PricingEmployee__c];
		PricingXmod__c[] xmods = [SELECT Id, ClientPricingScenario__c FROM PricingXmod__c];

		System.assertEquals(numPricingScenarios + 2, ps.size());
		System.assertEquals(ps.size() * numClients, cps.size());
		System.assertEquals(cps.size() * numEmployees, ees.size());
		System.assertEquals(24, xmods.size());

		ClientPricingScenario__c cps1 = cps[0];
		TestFactoryRenewals.createPricingClientInvestments(cps1, 5, true);

		PricingClientInvestment__c[] investments = [SELECT Id, ClientPricingScenario__c FROM PricingClientInvestment__c];
		System.assertEquals(5, investments.size());
	}
}