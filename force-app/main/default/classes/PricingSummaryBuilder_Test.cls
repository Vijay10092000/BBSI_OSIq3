@istest
private class PricingSummaryBuilder_Test
{
    @isTest static void GetMockData() {
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new PricingDataCalloutClass_Mock('','',''));
            Integer client = 904611;
            PricingSummaryDataModel pricingSumDataModel = new PricingSummaryDataModel(client, Date.today().addDays(30), 'FEIN here');
        Test.stopTest();

        pricingSumDataModel.GetData();
        system.assert(pricingSumDataModel != null);
        
    	Account branch = TestFactory.createAccount('Test Branch 3', '98662', 'BBSI Branch', true);
        Business_Unit__c bu = new Business_Unit__c(Name = 'foo unit');
        bu.BBSI_Branch__c = branch.Id;
        insert(bu);
        
    	Account client2 = TestFactory.createAccount('904611', '98662', 'Client', false);
        client2.Price_Approval__c = 'Approved';
        client2.Branch__c = branch.Id;
        client2.Business_Unit__c = bu.Id;
        insert client2;
        
        TestFactoryRenewals.createPricingScenarioComplete();
        ClientPricingScenario__c cps =
        [
                SELECT Id, BDM__c, BDM_Basis__c, BDM_Rate__c, BDM_Rate_Renewal__c, ClientId__c, ClientName__c,
                        commRate__c, commRateRenewal__c, PricingScenario__c, Name, projectionFactor__c,
                        ysumBilling__c, ysumComms__c, ysumErTaxes__c, ysumExpenses__c, ysumMargin__c,
                        ysumMaxSI__c, ysumPayroll__c, ysumWcPrem__c
                FROM ClientPricingScenario__c LIMIT 1];

        PricingSummaryBuilder pricingSummaryBuilder = new PricingSummaryBuilder(cps, pricingSumDataModel);
        pricingSummaryBuilder.GetResult();

        Double bdmRate = pricingSummaryBuilder.GetDefaultBdmRate();
        System.assertEquals(0.05, bdmRate);
    }

    @IsTest static void GetResultExceptionTest() {
        try {
            PricingSummaryBuilder pricingSummaryBuilder = new PricingSummaryBuilder(null, null);
            pricingSummaryBuilder.GetResult();
            System.assert(false, 'Exception should have been thrown');
        } catch(Exception e) {
            System.assert(true, 'Exception should have been thrown');
        }
    }

    @IsTest static void test_buildHistoryRow()
    {
        PricingSummaryBuilder builder = new PricingSummaryBuilder(null, null);

        PricingSummaryHistory__c history = builder.buildHistoryRow(2020, true, false, PricingSummaryService.MARGIN_HIST_CURRENT_PROJ);

        System.assertNotEquals(null, history, 'History should have been made');
    }

    @isTest static void SummaryBuilderExceptionTest()
    {
        try
        {
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new PricingDataCalloutClass_Mock('','',''));
            Integer client = 904611;
            PricingSummaryDataModel pricingSumDataModel = new PricingSummaryDataModel(client, Date.today().addDays(30), 'FEIN here');
            Test.stopTest();

            pricingSumDataModel.GetData();
            system.assert(pricingSumDataModel != null);

            ClientPricingScenario__c cps =
            [
                    SELECT Id, BDM__c, BDM_Basis__c, BDM_Rate__c, BDM_Rate_Renewal__c, ClientId__c, ClientName__c,
                            commRate__c, commRateRenewal__c, PricingScenario__c, Name, projectionFactor__c,
                            ysumBilling__c, ysumComms__c, ysumErTaxes__c, ysumExpenses__c, ysumMargin__c,
                            ysumMaxSI__c, ysumPayroll__c, ysumWcPrem__c
                    FROM ClientPricingScenario__c LIMIT 1];

            pricingSumDataModel.EndDate = null;
            new PricingSummaryBuilder(cps, pricingSumDataModel);
        }
        catch(Exception e) {
        }
    }
}