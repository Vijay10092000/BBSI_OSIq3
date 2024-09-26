@isTest
private class PricingDataModel_Test {
    
    @testSetup static void setup() {
        // Create Tax Table data
		List<ER_Payroll_Tax_Master__c> taxTable = new List<ER_Payroll_Tax_Master__c>();
		ER_Payroll_Tax_Master__c taxItem;

		taxItem = new ER_Payroll_Tax_Master__c();
		taxItem.State_Code__c = 'FED';
		taxItem.Tax_Type__c = 'FICA';
		taxItem.Rate__c = 6.2; 
		taxItem.Limit__c = 127200;
		taxTable.add(taxItem);

		taxItem = new ER_Payroll_Tax_Master__c();
		taxItem.State_Code__c = 'FED';
		taxItem.Tax_Type__c = 'MEDI';
		taxItem.Rate__c = 1.45;
		taxItem.Limit__c = 0;
		taxTable.add(taxItem);

		taxItem = new ER_Payroll_Tax_Master__c();
		taxItem.State_Code__c = 'FED';
		taxItem.Tax_Type__c = 'FUTA';
		taxItem.Rate__c = 2.1; 
		taxItem.Limit__c = 7000;
		taxTable.add(taxItem);

		taxItem = new ER_Payroll_Tax_Master__c();
		taxItem.State_Code__c = 'CA';
		taxItem.Tax_Type__c = 'SUTA';
		taxItem.Rate__c = 6.2; 
		taxItem.Limit__c = 7000;
		taxTable.add(taxItem);

		taxItem = new ER_Payroll_Tax_Master__c();
		taxItem.State_Code__c = 'NV';
		taxItem.Tax_Type__c = 'SUTA';
		taxItem.Rate__c = 6.2; 
		taxItem.Limit__c = 7000;
		taxTable.add(taxItem);

		System.debug('Tax Table record count to Insert: ' + taxTable.size());
		Database.SaveResult[] lsr = Database.insert(taxTable, false);
		For(Database.SaveResult sr : lsr){
			if(sr.isSuccess()){
				System.debug('success: ' + sr.getId());
			}
			else{
				for(Database.Error err : sr.getErrors()) {
					System.debug('The following error has occurred.');
					System.debug(err.getStatusCode() + ': ' + err.getMessage());
					System.debug('Account fields that affected this error: ' + err.getFields());
				}
			}
		}
      }
    
	@isTest static void getMockData() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new PricingDataCalloutClass_Mock('','',''));
		integer client = 901153;
		PricingDataModel obj = new PricingDataModel(client, Date.today().addDays(45));
        Test.stopTest();
		obj.GetData();   
        System.assert(obj.XmodHist != null);
        System.assert(obj.PricingGroups != null);
		System.assert(obj.PayWcEst != null);
		System.assert(obj.PayrollTaxTable != null);
		System.assert(obj.WcRatesAndPay != null);

		System.assert(obj != null);
		System.assert(obj.StatusCode == 200);

		System.assert(obj.PayrollTaxTable != null);
		System.assert(obj.PayrollTaxTable.size() > 0);

		System.assert(obj.PayWcEst.CLIENT == '904611');
		System.assert(obj.PayWcEst.DATALIST != null);
		System.assert(obj.PayWcEst.DATALIST.size() == 1);
		System.assert(obj.PayWcEst.DATALIST[0].LastName == 'SMITH,');
		System.assert(obj.PayWcEst.DATALIST[0].FirstName == 'ROBERT');
		System.assert(obj.PayWcEst.DATALIST[0].Active != 'A');
		System.assert(obj.PayWcEst.DATALIST[0].IsOwner == 0);
		System.assert(obj.PayWcEst.DATALIST[0].State == 'MD');
		System.assert(obj.PayWcEst.DATALIST[0].WCcodes.size() == 1);
		System.assert(obj.PayWcEst.DATALIST[0].TotalPay > 0);
	}
}