/**
 * Created by CElim on 12/17/2018.
 */

@isTest
private class PrcTaxRatesControllerTest
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

    @isTest static void PricingTaxesTest() {
        ClientPricingScenario__c cps = [
                SELECT Id, BDM__c, BDM_Basis__c, BDM_Rate__c, BDM_Rate_Renewal__c, ClientId__c, ClientName__c,
                        commRate__c, commRateRenewal__c, PricingScenario__c, Name, projectionFactor__c,
                        ysumBilling__c, ysumComms__c, ysumErTaxes__c, ysumExpenses__c, ysumMargin__c,
                        ysumMaxSI__c, ysumPayroll__c, ysumWcPrem__c
                FROM ClientPricingScenario__c
                LIMIT 1
        ];

        ERPayrollTax__c[] taxes = PrcTaxRatesController.getPricingTaxes(cps.Id);
        System.assertEquals(5, taxes.size());

        ERPayrollTax__c[] fed = PrcTaxRatesController.getPricingFederalTaxes(cps.Id);
        System.assertEquals(3, fed.size());

        ERPayrollTax__c[] others = PrcTaxRatesController.getPricingStateAndOthersTaxes(cps.Id);
        System.assertEquals(2, others.size());

        ERPayrollTax__c paTax = new ERPayrollTax__c(ClientPricingScenario__c = cps.Id,Limit__c = 7000,Rate__c = 5.2,State_Code__c = 'PA',Tax_Type__c = 'SUTA');
        PrcTaxRatesController.addTaxItem(paTax);

        taxes.add(paTax);
        PrcTaxRatesController.savePricingTaxes(taxes);
        ERPayrollTax__c[] taxesAfterAdd = PrcTaxRatesController.getPricingTaxes(cps.Id);
        System.assertEquals(6, taxesAfterAdd.size());

        PrcTaxRatesController.deleteTaxItem(paTax);
        ERPayrollTax__c[] taxesAfterDelete = PrcTaxRatesController.getPricingTaxes(cps.Id);
        System.assertEquals(5, taxesAfterDelete.size());
    }

}