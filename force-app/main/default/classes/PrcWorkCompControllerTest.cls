/**
 * Created by CElim on 12/17/2018.
 */

@IsTest
private class PrcWorkCompControllerTest
{
    @TestSetup static void setup() {
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

    @IsTest static void PricingWcCodesTest()
    {
        String wcCode = '3482 MD';
        String state = 'MD';

        String updateWcCode = '3482 WA';
        String updateState = 'WA';

        ClientPricingScenario__c cps =
        [
                SELECT Id, BDM__c, BDM_Basis__c, BDM_Rate__c, BDM_Rate_Renewal__c, ClientId__c, ClientName__c,
                        commRate__c, commRateRenewal__c, PricingScenario__c, Name, projectionFactor__c,
                        ysumBilling__c, ysumComms__c, ysumErTaxes__c, ysumExpenses__c, ysumMargin__c,
                        ysumMaxSI__c, ysumPayroll__c, ysumWcPrem__c
                FROM ClientPricingScenario__c LIMIT 1];

        PricingWcCode__c[] wcs = PrcWorkCompController.getPricingWcCodes(cps.Id);
        System.assertEquals(2, wcs.size());

        PricingTemplateWcCode__c[] templateWcCodes = PrcWorkCompController.getPricingTemplateWcCodes(cps.Id);
        System.assertEquals(3, templateWcCodes.size());

        PricingWcCode__c wc = wcs[0];
        System.assertEquals(wcCode, wc.Name);
        System.assertEquals(state, wc.State_Code__c);

        wc.Name = updateWcCode;
        wc.State_Code__c = updateState;
        PrcWorkCompController.savePricingWcCodes(wcs);

        PricingWcCode__c[] wcsUpdate = PrcWorkCompController.getPricingWcCodes(cps.Id);
        System.assertEquals(2, wcsUpdate.size());

        PricingWcCode__c wcUpdate = wcs[0];
        System.assertEquals(updateWcCode, wcUpdate.Name);
        System.assertEquals(updateState, wcUpdate.State_Code__c);

        wc.Name = wcCode;
        wc.State_Code__c = state;
        PrcWorkCompController.savePricingWcCodes(wcsUpdate);

        PricingWcCode__c source = wcsUpdate[0];
        PricingWcCode__c target = wcsUpdate[1];

        PrcWorkCompController.transferAndDeletePricingWcCode(source, target);
        System.assertEquals(1, PrcWorkCompController.getPricingWcCodes(cps.Id).size());

        PrcWorkCompController.deleteWorkComp(target);
        PricingWcCode__c[] afterDelete = PrcWorkCompController.getPricingWcCodes(cps.Id);
        System.assertEquals(0, afterDelete.size());

        WorkCompPolicyAccount__c[] wcPolicyAccounts = PrcWorkCompController.getWorkCompPolicyAccounts('');
        System.assertEquals(0, wcPolicyAccounts.size());

        PrcWorkCompController.addPricingWcCode(cps.Id, 'MD', '8810', 2.5507, true);
        PricingWcCode__c[] afterAdd = PrcWorkCompController.getPricingWcCodes(cps.Id);
        System.assertEquals(1, afterAdd.size());
    }
}