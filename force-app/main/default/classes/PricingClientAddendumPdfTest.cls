/**
 * Created by CElim on 4/8/2019.
 */
@IsTest
public with sharing class PricingClientAddendumPdfTest
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
        client.External_ID__c = '904611';
        insert client;

        TestFactoryRenewals.createPricingScenarioComplete();
    }

    @IsTest static void ClientAddendumTest()
    {
        ClientPricingScenario__c cps = [
                SELECT Id, BDM__c, BDM_Basis__c, BDM_Rate__c, BDM_Rate_Renewal__c, ClientId__c, ClientName__c,
                        commRate__c, commRateRenewal__c, PricingScenario__c, Name, projectionFactor__c,
                        ysumBilling__c, ysumComms__c, ysumErTaxes__c, ysumExpenses__c, ysumMargin__c,
                        ysumMaxSI__c, ysumPayroll__c, ysumWcPrem__c
                FROM ClientPricingScenario__c
                LIMIT 1
        ];

        ApexPages.StandardController src = new ApexPages.StandardController(cps);
        PricingClientAddendumPdfExtension pdf = new PricingClientAddendumPdfExtension(src);

        System.assertEquals('904611', pdf.Client.Name);
        Account acct = [SELECT Id, External_Id__c FROM Account WHERE Name = '904611'];
        System.assertEquals(acct.External_Id__c, pdf.ClientPricingScenario.ClientId__c);
        System.assertEquals(false, pdf.IsSafetyIncentive);
        System.assertEquals(false, pdf.IsStandardMarkup);
        System.assertEquals('98662', pdf.ClientAddress.getPostalCode());
        System.assertEquals(acct.External_Id__c, pdf.ClientId);

        System.assertEquals('Test Branch 3', pdf.Branch.Name);
        System.assertEquals('98662', pdf.BranchPostalCode);

        System.assert(pdf.WorkCompCodes.size() > 0);
        System.assert(pdf.BillingHistories.size() > 0);
        System.assert(pdf.SafetyIncentives.size() > 0);
        System.assert(pdf.FeeSchedule.size() > 0);

        ApexPages.StandardController blend = new ApexPages.StandardController(cps);
        PageReference pageReference = Page.PricingClientAddendum;
        pageReference.getParameters().put('includeOtDt', 'true');
        pageReference.getParameters().put('si', 'true');

        Test.setCurrentPage(pageReference);
        PricingClientAddendumPdfExtension pdf2 = new PricingClientAddendumPdfExtension(blend);

        System.assertEquals(true, pdf2.IsStandardMarkup);
        System.assertEquals(true, pdf2.IsSafetyIncentive);
        System.assert(pdf2.FeeSchedule.size() > 0);
    }
}