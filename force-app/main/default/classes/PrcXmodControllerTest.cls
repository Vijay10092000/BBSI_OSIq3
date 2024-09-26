/**
 * Created by CElim on 12/17/2018.
 */

@isTest
private class PrcXmodControllerTest
{

    @testSetup static void setup() {
    	Account branch = TestFactory.createAccount('Test Branch 3', '98662', 'BBSI Branch', true);
        Business_Unit__c bu = new Business_Unit__c(Name = 'foo unit');
        bu.BBSI_Branch__c = branch.Id;
        insert(bu);
        
    	Account client = TestFactory.createAccount('904611', '98662', 'Client', false);
        client.Price_Approval__c = 'Approved';
        client.Branch__c = branch.Id;
        client.Business_Unit__c = bu.Id;
        insert client;
        
        TestFactoryRenewals.createPricingScenarioComplete();
    }

    @isTest static void PricingXmodTest()
    {
        Decimal xmod = 1.2;
        Decimal updateXmod = 1.3;
        ClientPricingScenario__c cps =
        [
                SELECT Id, BDM__c, BDM_Basis__c, BDM_Rate__c, BDM_Rate_Renewal__c, ClientId__c, ClientName__c,
                        commRate__c, commRateRenewal__c, PricingScenario__c, Name, projectionFactor__c,
                        ysumBilling__c, ysumComms__c, ysumErTaxes__c, ysumExpenses__c, ysumMargin__c,
                        ysumMaxSI__c, ysumPayroll__c, ysumWcPrem__c
                FROM ClientPricingScenario__c LIMIT 1];

        System.assertEquals(0, PrcXmodController.getPublishedXmods(cps.Id, '5').size());

        System.assertEquals(2, PrcXmodController.getXmodHistory(cps.Id, '5').size());

        System.assertEquals(1, PrcXmodController.getXmodHistory(cps.Id, '1').size());

        PricingXmod__c[] xmods = PrcXmodController.getRenewalYearXmods(cps.Id);
        System.assertEquals(1, xmods.size());
        System.assertEquals(xmod, xmods[0].Xmod__c);

        xmods[0].Xmod__c = updateXmod;
        PrcXmodController.saveRenewalXmods(xmods);
        PricingXmod__c[] xmodsUpdate = PrcXmodController.getRenewalYearXmods(cps.Id);
        System.assertEquals(1, xmodsUpdate.size());
        System.assertEquals(updateXmod, xmodsUpdate[0].Xmod__c);

        XmodRecommended__c[] recommended = PrcXmodController.getXmodRecommended(cps.Id);
        System.assertEquals(5, recommended.size());
        System.assertEquals('MD', recommended[0].State_Code__c);
        System.assertEquals(0.2, recommended[0].Xmod__c);
        System.assertEquals(1.2, recommended[1].Xmod__c);
        System.assertEquals(2.2, recommended[2].Xmod__c);
        System.assertEquals(3.2, recommended[3].Xmod__c);
        System.assertEquals(4.2, recommended[4].Xmod__c);
    }
}