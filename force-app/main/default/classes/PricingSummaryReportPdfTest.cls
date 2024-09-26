/**
 * Created by CElim on 4/8/2019.
 */
@IsTest
public with sharing class PricingSummaryReportPdfTest
{
    @TestSetup static void setup()
    {
        Account branch = TestFactory.createAccount('Test Branch 3', '98662', 'BBSI Branch', true);
        Business_Unit__c bu = new Business_Unit__c(Name = 'foo unit');
        bu.BBSI_Branch__c = branch.Id;
        insert(bu);

        Account client = TestFactory.createAccount('904611', '98662', 'Client', true );
        client.Price_Approval__c = 'Approved';
        client.Price_Approval_Comments__c = 'approved automatically';
        client.Branch__c = branch.Id;
        client.External_ID__c = '904611';
        update client;

        TestFactoryRenewals.createPricingScenarioComplete();
    }

    @IsTest static void SummaryReportPdfTest()
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
        PricingSummaryReportPdfExtension pdf = new PricingSummaryReportPdfExtension(src);

        System.assertEquals('904611', pdf.Client.Name);
        System.assertEquals('904611', pdf.ClientPricingScenario.ClientId__c);

        Account acct = [SELECT Id, External_Id__c FROM Account WHERE Name= :pdf.Client.Name];
        System.assertEquals(acct.External_Id__c, pdf.ClientPricingScenario.ClientId__c);

        System.assertEquals(5.0, pdf.ClientPricingScenario.BDM_Rate__c);
        System.assertEquals(Date.today(), pdf.Renewal.Renewal_Date__c);
        System.assertEquals(Date.today().format(), pdf.ReportDate);
        System.assertEquals(Date.today().addDays(1).format(), pdf.RenewalDate);
        System.assertEquals(Date.today().addDays(1).year(), pdf.RenewalYear);

        System.assertEquals(10.0, pdf.Summary.BUHours3x__c);
        System.assertEquals(2.0, pdf.Summary.FTE__c);
        System.assertEquals(1, pdf.RenewalXmods.size());
        System.assertEquals(1.2, pdf.RenewalXmods[0].Xmod__c);

        System.assertEquals('MD-1.20', pdf.PricingXmods);
        System.assertEquals('MD-0.20', pdf.DefaultXmods);
        System.assertEquals(2, pdf.History.size());
        System.assertEquals(2, pdf.Markups.size());

        System.assertEquals(5, pdf.Taxes.size());
        System.assertEquals(2, pdf.SafetyIncentives.size());
    }
}