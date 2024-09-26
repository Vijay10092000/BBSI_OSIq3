/**
 * Created by CElim on 12/17/2018.
 */

@isTest
private class PrcMarkupControllerTest
{
    @testSetup static void setup()
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
        TestFactory.createAccount('902875', '', 'Client', true);
    }

    @isTest static void PrcMarkupTest()
    {
        String wcCode = '3482';
        String updateWcCode = '5000';

        ClientPricingScenario__c cps =
        [
                SELECT Id, BDM__c, BDM_Basis__c, BDM_Rate__c, BDM_Rate_Renewal__c, ClientId__c, ClientName__c,
                        commRate__c, commRateRenewal__c, PricingScenario__c, Name, projectionFactor__c,
                        ysumBilling__c, ysumComms__c, ysumErTaxes__c, ysumExpenses__c, ysumMargin__c,
                        ysumMaxSI__c, ysumPayroll__c, ysumWcPrem__c
                FROM ClientPricingScenario__c LIMIT 1];

        PricingWcCode__c[] codes = PrcMarkupController.getPricingWcCodes(cps.Id);
        System.assertEquals(2, codes.size());

        PricingWcCode__c code = codes[0];
        System.assertEquals(wcCode, code.WC_Code__c);

        code.WC_Code__c = updateWcCode;
        PrcMarkupController.savePricingWcCodes(codes);

        PricingWcCode__c[] updateCodes = PrcMarkupController.getPricingWcCodes(cps.Id);
        System.assertEquals(2, updateCodes.size());

        System.assertEquals(updateWcCode, updateCodes[0].WC_Code__c);
    }

    @IsTest static void BillingHistoryTest()
    {
    	Account acct = [SELECT Id, External_Id__c FROM Account WHERE Name = '902875'];
        Billing_History__c[] history = PrcMarkupController.getBillingHistories(acct.External_ID__c);
        /*System.assertEquals(10, history.size());
        System.assertEquals(0.2047, history[0].Bundled_Rate__c);
        System.assertEquals('', history[1].Pay_Code__c);
        System.assertEquals('CA.8810', history[3].WC_Code__c);
        System.assert(history[6].Pay_Code__c.length() > 5);*/
    }

    @IsTest static void SafetyIncentiveTest()
    {
    	Account acct = [SELECT Id, External_Id__c FROM Account WHERE Name = '902875'];
        Map<String, String> si = PrcMarkupController.getSafetyIncentives(acct.External_ID__c);
        /*System.assertEquals(5, si.size());
        String si1000 = si.get('1000');
        System.assertEquals('0.0', si1000);
        String si9008 = si.get('9008');
        System.assertEquals('4.0', si9008);
        String si9009 = si.get('9009');
        System.assertEquals('2.51', si9009);*/
    }
}