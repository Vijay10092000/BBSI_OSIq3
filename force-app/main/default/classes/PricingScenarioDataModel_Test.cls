@isTest
private class PricingScenarioDataModel_Test {
	
	@isTest static void getMockData() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new PricingDataCalloutClass_Mock('','',''));
		integer client = 900001;
		PricingScenarioDataModel obj = new PricingScenarioDataModel(client, Date.today().addDays(30));
        Test.stopTest();
		obj.GetData();

		// http call was successful
		System.assert(obj != null);
		System.assert(obj.StatusCode == 200);
	    
	    // each major object is not null
	    System.assert(obj.MarginAnalysSummary != null);
	    System.assert(obj.TaxBurdenSum != null);
	    System.assert(obj.SafetyIncentiveSum != null);
	    System.assert(obj.CommissionRateDetail != null);
	    System.assert(obj.BdmInfo != null);

	    // test public methods
	    System.assert(obj.BillAmtTotal > 0);
	    System.assert(obj.WcPremTotal > 0);
	    System.assert(obj.MarginTotal > 0);
	    System.assert(obj.PayrollTotal > 0);
	    System.assert(obj.TaxesTotal > 0);
	    System.assert(obj.MaxSITotal >= 0);

	    // test both cases, true and false
        if (obj.BdmInfo.HASBDM == 'TRUE'){
        	System.assert(obj.BdmCommissionTotal > 0);
        	obj.BdmInfo.HASBDM = 'FALSE';
        } else{
        	System.assert(obj.BdmCommissionTotal == 0);
        	obj.BdmInfo.HASBDM = 'TRUE';
        }

        if (obj.BdmInfo.HASBDM == 'TRUE'){
        	System.assert(obj.BdmCommissionTotal > 0);
        } else{
        	System.assert(obj.BdmCommissionTotal == 0);
        }

	    System.assert(obj.RefPartCommissionTotal > 0);

	}
	
}