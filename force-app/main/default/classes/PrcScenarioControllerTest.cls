/**
 * Created by CElim on 12/17/2018.
 */

@isTest
private class PrcScenarioControllerTest
{
    @isTest static void PricingScenarioTest()
    {
        PricingScenario__c initPricingScenario = TestFactoryRenewals.createPricingScenario('Test Scenario', true);

        PricingScenario__c ps = PrcScenarioController.getPricingScenario(initPricingScenario.Id);
        System.assertEquals('Test Scenario', ps.ScenarioName__c);

        ps.ScenarioName__c = 'Renamed Scenario';
        PrcScenarioController.SavePricingScenario(ps);
        System.assertEquals('Renamed Scenario', PrcScenarioController.getPricingScenario(initPricingScenario.Id).ScenarioName__c);

        Id renewalId = initPricingScenario.Renewal__c;
        Renewal__c renewal = PrcScenarioController.getRenewal(renewalId);
        System.assertEquals('Tester DEF', renewal.Name);
        System.assertEquals('99-1234567', renewal.FEIN__c);

        renewal.Name = 'Renewal Test';
        PrcScenarioController.SaveRenewal(renewal);
        System.assertEquals('Renewal Test', PrcScenarioController.getRenewal(renewalId).Name);
    }

}