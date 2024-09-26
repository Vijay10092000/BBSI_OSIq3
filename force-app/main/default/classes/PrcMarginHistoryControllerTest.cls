/**
 * Created by CElim on 12/17/2018.
 */

@IsTest
private class PrcMarginHistoryControllerTest
{
    @TestSetup static void setup()
    {
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

    @IsTest static void PricingSummaryHistoryTest()
    {
        ClientPricingScenario__c cps = [
                SELECT Id, BDM__c, BDM_Basis__c, BDM_Rate__c, BDM_Rate_Renewal__c, ClientId__c, ClientName__c,
                        commRate__c, commRateRenewal__c, PricingScenario__c, Name, projectionFactor__c,
                        ysumBilling__c, ysumComms__c, ysumErTaxes__c, ysumExpenses__c, ysumMargin__c,
                        ysumMaxSI__c, ysumPayroll__c, ysumWcPrem__c
                FROM ClientPricingScenario__c
                LIMIT 1
        ];

        PricingSummaryHistory__c[] history = PrcMarginHistoryController.getPricingSummaryHistories(cps.Id);
        System.assertEquals(2, history.size());

        PricingSummaryHistory__c[] rows = PrcMarginHistoryController.getPricingSummaryRows(cps.Id);
        System.assertEquals(2, rows.size());

        PricingSummaryHistory__c summary = PrcMarginHistoryController.getPricingSummaryRenewalRow(cps.Id);
        System.assertEquals(3, summary.HeadcountAnnual__c);
        System.assertEquals(10, summary.YendCommsBdm__c);
        System.assertEquals(2, summary.FTE__c);
        System.assertEquals(2400, summary.YendMargin__c);
        System.assertEquals(65000, summary.PremiumBasedPayroll__c);
        System.assertEquals(400, summary.YendComms__c);
        System.assertEquals(200, summary.YendExpenses__c);
        System.assertEquals(1000, summary.YendWcPrem__c);
        System.assertEquals(1, summary.Xmod__c);

        summary.Xmod__c = 1.5;
        PrcClientScenarioController.savePricingSummaryRenewalRow(summary);
        System.assertEquals(1.5, PrcMarginHistoryController.getPricingSummaryRenewalRow(cps.Id).Xmod__c);

        PricingSummaryHistory__c[] summaryRows = PrcMarginHistoryController.getPricingSummaryHistoryRows(cps.Id);
        System.assert(summaryRows.size() == 0);
    }

}