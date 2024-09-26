@isTest
private class EmployeeAndWcBuilder_Test {
	
	@testSetup static void setup() {
		TestFactoryRenewal.createRenewal('Tester DEF', new Map<String, Object>{
			'FEIN__c' => '99-1234567',
			'Status__c' => 'New'
		});
		
		List<ER_Payroll_Tax_Master__c> taxTableMaster = new List<ER_Payroll_Tax_Master__c>{
			TestFactoryERPayrollTaxMaster.makePayrollmaster(new Map<String, Object>{
				'State_Code__c' => 'FED',
				'Tax_Type__c'	=> 'FICA',
				'Rate__c' => 6.2,
				'Limit__c' => 127200
			}),
			TestFactoryERPayrollTaxMaster.makePayrollmaster(new Map<String, Object>{
				'State_Code__c' => 'FED',
				'Tax_Type__c'	=> 'MEDI',
				'Rate__c' => 1.45,
				'Limit__c' => 0
			}),
			TestFactoryERPayrollTaxMaster.makePayrollmaster(new Map<String, Object>{
				'State_Code__c' => 'FED',
				'Tax_Type__c'	=> 'FUTA',
				'Rate__c' => 2.1,
				'Limit__c' => 7000
			})
		};
		Database.insert(taxTableMaster, false);
	}
	
	@isTest static void createPricingEEs()
	{
		Renewal__c myRenewal = [SELECT Id FROM Renewal__c WHERE FEIN__c = '99-1234567'];

		PricingScenarioBuilder psBuilder = new PricingScenarioBuilder('My Pricing Scenario', myRenewal.Id);
		Assert.isTrue(psBuilder.HasData, 'Pricing Scenario Should not Null');
		PricingScenario__c pScenario = psBuilder.GetResult();

		Test.startTest();

		Integer client = 900022;
		Test.setMock(HttpCalloutMock.class, new GenericMockCallout(200, 'SUCCESS', ClientPricingScenarioBuilder_Test.getpricingDataModelData(), null));

		PricingDataModel pricingModel = new PricingDataModel(client, Date.today().addDays(45));
		pricingModel.GetData();
		Test.setMock(HttpCalloutMock.class, new GenericMockCallout(200, 'SUCCESS', ClientPricingScenarioBuilder_Test.getpricingScenarioData(), null));
		PricingScenarioDataModel pricingScenarioModel = new PricingScenarioDataModel(client, Date.today().addDays(45));

		pricingScenarioModel.GetData();

		Test.stopTest();

		Map<String, PricingScenarioDataModel> PricingScenarioModelMap = new Map<String, PricingScenarioDataModel>();
		PricingScenarioModelMap.put('900022', pricingScenarioModel);

		ClientPricingScenarioBuilder cpsBuilder = new ClientPricingScenarioBuilder(pScenario, myRenewal.Id, PricingScenarioModelMap);
		Map<String, ClientPricingScenario__c> ClientPricingScenarios = cpsBuilder.GetResult();

		Map<String, PricingDataModel> PricingModelMap = new Map<String, PricingDataModel>();
		PricingModelMap.put('900022', pricingModel);
		Assert.isTrue(pricingScenarioModel.BdmInfo != null, 'Pricing Scenario Should not Empty');
	}

	@isTest static void GeneralTest()
	{
		Test.startTest();

		Test.setMock(HttpCalloutMock.class, new GenericMockCallout(200, 'SUCCESS', ClientPricingScenarioBuilder_Test.getPricingScenarioData(), null));

		Integer client = 904611;
		Test.setMock(HttpCalloutMock.class, new GenericMockCallout(200, 'SUCCESS', ClientPricingScenarioBuilder_Test.getpricingSummaryData(), null));
		PricingSummaryDataModel pSumDataModel = new PricingSummaryDataModel(client, Date.today().addDays(30), 'fein_here');

		Test.stopTest();

		pSumDataModel.GetData();

		Account branch1 = TestFactoryAccount.createBranch('Test Branch 3', '98662', null, null);
        Business_Unit__c bu = TestFactoryBusinessUnit.createBusinessUnit('foo unit', branch1.Id);		
    	Account client1 = TestFactoryAccount.makeClient('904611', null, null);
        client1.Price_Approval__c = 'Approved';
        client1.Branch__c = branch1.Id;
        client1.Business_Unit__c = bu.Id;
        insert client1;
        
		TestFactoryRenewals.createPricingScenarioComplete();

		ClientPricingScenario__c cps =
		[
				SELECT Id, BDM__c, BDM_Basis__c, BDM_Rate__c, BDM_Rate_Renewal__c, ClientId__c, ClientName__c,
						commRate__c, commRateRenewal__c, PricingScenario__c, Name, projectionFactor__c,
						ysumBilling__c, ysumComms__c, ysumErTaxes__c, ysumExpenses__c, ysumMargin__c,
						ysumMaxSI__c, ysumPayroll__c, ysumWcPrem__c
				FROM ClientPricingScenario__c
				ORDER BY CreatedDate DESC
				LIMIT 1
		];

		EmployeeAndWcBuilder builder = new EmployeeAndWcBuilder(cps, pSumDataModel);
		builder.GetResult();
		Assert.isTrue(builder.HasData, 'Pricing Scenario Should not Null');
		
		Decimal SIrate = builder.GetSIrate('MD', '3482');
		Decimal WcRate = builder.getWcRate('MD', '3482');
		Assert.areEqual(SIrate, 0,'SIrate Should be more than 0');
		Assert.areEqual(WcRate, 0,'WcRate Should be more than 0');
		Boolean IsEligibleForSI = builder.IsEligibleForSI('MD', '3482');
		Assert.isFalse(IsEligibleForSI,'IsEligibleForSI Should be false');
	}
	@isTest static void WorkCompRatesTest()
	{
		Test.startTest();

		Test.setMock(HttpCalloutMock.class, new GenericMockCallout(200, 'SUCCESS', ClientPricingScenarioBuilder_Test.getPricingScenarioData(), null));

		Integer client = 904611;
		Test.setMock(HttpCalloutMock.class, new GenericMockCallout(200, 'SUCCESS', ClientPricingScenarioBuilder_Test.getpricingSummaryData(), null));
		PricingSummaryDataModel pSumDataModel = new PricingSummaryDataModel(client, Date.today().addDays(30), 'fein_here');

		Test.stopTest();

		pSumDataModel.GetData();

		Account branch1 = TestFactoryAccount.createBranch('Test Branch 3', '98662', null, null);
        Business_Unit__c bu = TestFactoryBusinessUnit.createBusinessUnit('foo unit', branch1.Id);		
    	Account client1 = TestFactoryAccount.makeClient('904611', null, null);
        client1.Price_Approval__c = 'Approved';
        client1.Branch__c = branch1.Id;
        client1.Business_Unit__c = bu.Id;
        insert client1;
        
		TestFactoryRenewals.createPricingScenarioComplete();

		ClientPricingScenario__c cps =
		[
				SELECT Id, BDM__c, BDM_Basis__c, BDM_Rate__c, BDM_Rate_Renewal__c, ClientId__c, ClientName__c,
						commRate__c, commRateRenewal__c, PricingScenario__c, Name, projectionFactor__c,
						ysumBilling__c, ysumComms__c, ysumErTaxes__c, ysumExpenses__c, ysumMargin__c,
						ysumMaxSI__c, ysumPayroll__c, ysumWcPrem__c
				FROM ClientPricingScenario__c
				ORDER BY CreatedDate DESC
				LIMIT 1
		];

		WorkCompRatesER.DATA WorkCompRatesERData = new WorkCompRatesER.DATA();
		WorkCompRatesERData.STATE = 'test';
		WorkCompRatesERData.WCCODE='test';
		pSumDataModel.WorkCompRates.DATALIST.add(WorkCompRatesERData);
		EmployeeAndWcBuilder builder = new EmployeeAndWcBuilder(cps, pSumDataModel);
		builder.GetResult();
		Assert.isTrue(builder.HasData, 'Pricing Scenario Should not Null');
	}
	@isTest static void NegativeTest(){
		ClientPricingScenario__c cps = new ClientPricingScenario__c();		
		EmployeeAndWcBuilder builder;
		Boolean isError = false;
		try {
			builder = new EmployeeAndWcBuilder(null, null);
		} catch(Exception e) {
			isError = true;
		}
		Assert.isTrue(isError,'isError Should be True');
		isError = false;
		try {
			Test.setMock(HttpCalloutMock.class, new GenericMockCallout(200, 'SUCCESS', ClientPricingScenarioBuilder_Test.getpricingSummaryData(), null));
			PricingSummaryDataModel pSumDataModelDummy = new PricingSummaryDataModel(1, System.today(), '');
			pSumDataModelDummy.EndDate = null;
			builder = new EmployeeAndWcBuilder(cps, pSumDataModelDummy);
		} catch(Exception e) {
			isError = true;
		}
		Assert.isTrue(isError,'isError Should be True');
		Test.setMock(HttpCalloutMock.class, new GenericMockCallout(200, 'SUCCESS', ClientPricingScenarioBuilder_Test.getpricingSummaryData(), null));
		PricingSummaryDataModel pSumDataModel = new PricingSummaryDataModel(1, System.today(), '');
		builder = new EmployeeAndWcBuilder(cps,pSumDataModel);
		
		Decimal SIrate = builder.GetSIrate('MD', '3482');
		Decimal WcRate = builder.getWcRate('MD', '3482');
		Assert.isTrue(SIrate == 0,'SIrate Should be 0');
		Assert.isTrue(WcRate == 0,'WcRate Should be 0');
		Boolean IsEligibleForSI = builder.IsEligibleForSI('MD', '3482');
		Assert.isFalse(IsEligibleForSI,'IsEligibleForSI Should be false');
	}	
}