@isTest
private class ErPayrollTaxBuilder_Test {	
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
	
	@isTest static void createErPayrollTaxes(){
		Integer client = 900022;
		Account account = TestFactoryAccount.makeClient('' + client, null, null);
		account.External_ID__c = '' + client;
		insert account;

		Renewal__c myRenewal = [SELECT Id FROM Renewal__c WHERE FEIN__c = '99-1234567'];

		String scenarioName = 'My Pricing Scenario';

		PricingScenarioBuilder psBuilder;
		PricingScenario__c pScenario;

		psBuilder = new PricingScenarioBuilder(scenarioName, myRenewal.Id);
		pScenario = psBuilder.GetResult();

		Test.startTest();
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
        Map<String, ClientPricingScenario__c> ClientPricingScenarioMap = cpsBuilder.GetResult();
    	Map<String, PricingDataModel> PricingModelMap = new Map<String, PricingDataModel>();
		PricingModelMap.put('900022', pricingModel);

		List<ERPayrollTax__c> prTaxes;
		
		ErPayrollTaxBuilder prTaxBuilder = new ErPayrollTaxBuilder(ClientPricingScenarioMap.get('900022'), PricingModelMap.get('900022'));
        if(prTaxBuilder.HasData) {
			prTaxes = prTaxBuilder.GetResult();
		} else {
			prTaxes = null;
		}

		Assert.isTrue(prTaxes != null);
		Assert.isTrue(prTaxes.size() > 0);
		Assert.isTrue(prTaxes[0].Limit__c == 127200);
 		Assert.isTrue(prTaxes[0].Rate__c == 6.2);
		Assert.isTrue(prTaxes[0].State_Code__c == 'FED');		
	}
	@isTest static void negativeErPayrollTaxes(){
		ErPayrollTaxBuilder prTaxBuilder = new ErPayrollTaxBuilder(null, null);
		PricingDataModel pricingModel = new PricingDataModel(1, Date.today().addDays(45));
		pricingModel.PayrollTaxTable = new List<ER_Payroll_Tax_Master__c>{new ER_Payroll_Tax_Master__c()}; 
		prTaxBuilder = new ErPayrollTaxBuilder(new ClientPricingScenario__c(), pricingModel);		
		List<ERPayrollTax__c> prTaxes = prTaxBuilder.GetResult();
		Assert.isTrue(prTaxes.size() == 1);
	}
}