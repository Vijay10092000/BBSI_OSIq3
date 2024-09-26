@isTest
public class PayrollPricingComponentController_test {
    
    @isTest
    static void PayrollPricingComponentTest() 
    {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new PricingDataCalloutClass_Mock('','',''));
		integer client = 901153;
		PayrollPricingComponentController controller=new PayrollPricingComponentController();
        controller.accountExternalID ='901153';
        Test.stopTest();
        
        controller.contractDate =Date.today().addDays(45);
        controller.getCompValues();
        System.assert(controller.XmodRateTable != null);
        System.assert(controller.PayrollTaxTable != null);
        System.assert(controller.EstimateWCPayTable != null);
        //System.assert(controller.PayWcEstimateData != null);
        System.assert(controller.EstimatePayTaxTable != null);
        System.assert(controller.Totals != null);
        /*
        System.assertEquals('DE', controller.MarginAnalysisTable[0].State);
        System.assertEquals('0882', controller.MarginAnalysisTable[0].WCCODE);
        System.assertEquals(5452.26, controller.MarginAnalysisTable[0].CurrentContractYTDMARGIN);
        System.assertEquals(0, controller.BillingAdjustments.get('YTD'));
        System.assertEquals(-31, controller.SecondaryService.get('YTD'));
        System.assertEquals(7215.24, controller.TotalGrossMargin.get('YTD'));
  
        System.assertEquals(2017, controller.currentContractYear);
        //System.assertEquals(1, controller.ListAccount[0].contacts.size());
        Test.setMock(HttpCalloutMock.class, new RenewalCalloutClass_Mock(negtestMarginAnalysis,'','','','{"CLIENT":"900005","HASBDM":"FALSE","BDMNAME":"Erik Swanson"}',''));
        controller.accountExternalID ='900022';
        controller.BDM ='BDM Name';
        controller.BDMStatus ='FALSE';
        controller.ReferralPartner ='ReferralPartner Name';
        controller.contractDate =Date.today().addDays(-445);
        controller.getCompValues();
        System.assertEquals('DE', controller.MarginAnalysisTable[1].State);
        System.assertEquals('0953', controller.MarginAnalysisTable[1].WCCODE);
        System.assertEquals(11023.73, controller.MarginAnalysisTable[0].PreContractY1MARGIN);
        System.assertEquals(14006.28, controller.MarginAnalysisTable[0].PreContractY2MARGIN);
        System.assertEquals('FALSE', controller.BDMStatus);
        
        //Test Error code
         MarginAnalysisComponentController controller1=new MarginAnalysisComponentController();
        Test.setMock(HttpCalloutMock.class, new RenewalCalloutClass_Mock('ERROR','','','','',''));
        controller1.accountExternalID ='900022';
        controller1.BDM ='BDM Name';
        controller1.BDMStatus ='FALSE';
        controller1.ReferralPartner ='ReferralPartner Name';
        controller1.contractDate =Date.today().addDays(-445);
        controller1.getCompValues();
        system.debug('controller.ErrorStatus:::' + controller1.ErrorStatus);
        System.assertEquals('ERROR', controller1.ErrorStatus);
*/
    }

}