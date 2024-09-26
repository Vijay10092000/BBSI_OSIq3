@isTest
private class PricingSummaryDataModel_Test {
    @isTest static void getMockData(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new PricingDataCalloutClass_Mock('','',''));

        Integer client = 900001;
        PricingSummaryDataModel obj = new PricingSummaryDataModel(client, Date.today().addDays(30), 'fein_here');
        Test.stopTest();

        obj.GetData();

		// http call was successful
		System.assert(obj != null);
		System.assert(obj.StatusCode == 200);
	    
	    // each major object is not null
	    System.assert(obj.PayrollHistory != null);
	    System.assert(obj.PayrollHistorySum != null);
	    System.assert(obj.WcRatesAndPay != null);
        
        Decimal wcRate = obj.getWcRate('nn', '0000');
        List<String> wcCodes = obj.WorkCompCodes;

        System.assert(wcRate == 0);
        System.assert(wcCodes != null);

        List<WorkCompRatesER.DATA> templateWcCodes = obj.TemplateWorkComps;
        System.assert(templateWcCodes != null);
    }

}