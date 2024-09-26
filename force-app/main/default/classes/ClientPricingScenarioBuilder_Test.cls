@isTest
public class ClientPricingScenarioBuilder_Test
{
	@testSetup static void setup()
	{
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

	@IsTest static void createClientScenarios()
	{
		Integer clientId = 900022;
		String client = '' + clientId;

		// Account account = TestFactory.createAccount(client, '98662', 'Client', true);
        Account account = TestFactoryAccount.makeAccount(client, 'Client');
        account.BillingPostalCode = '98662';
		account.External_ID__c = client;
		insert account;

		Renewal__c myRenewal = TestFactoryRenewals.createRenewal('Tester DEF', '99-1234567', 'New', true);

		String scenarioName = 'My Pricing Scenario';
		PricingScenarioBuilder psBuilder = new PricingScenarioBuilder(scenarioName, myRenewal.Id);
		PricingScenario__c pScenario = psBuilder.GetResult();

		/*
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new PricingDataCalloutClass_Mock('','',''));
		PricingScenarioDataModel pricingScenarioModel = new PricingScenarioDataModel(clientId, Date.today().addDays(45));
		pricingScenarioModel.GetData();
		Test.stopTest();
        */
        
        Test.startTest();
		String pricingScenarioData = getPricingScenarioData();
		Test.setMock(HttpCalloutMock.class, new GenericMockCallout(200, 'SUCCESS', pricingScenarioData, null));
		PricingScenarioDataModel pricingScenarioModel = new PricingScenarioDataModel(clientId, Date.today().addDays(45));
		pricingScenarioModel.GetData();
		Test.stopTest();

		Map<String, PricingScenarioDataModel> PricingScenarioModelMap = new Map<String, PricingScenarioDataModel>();
		PricingScenarioModelMap.put(client, pricingScenarioModel);

		Assert.isTrue(PricingScenarioModelMap.get(client) != null);
		Assert.isTrue(PricingScenarioModelMap.get(client).MarginAnalysSummary != null);
        Assert.areEqual('904611', PricingScenarioModelMap.get(client).MarginAnalysSummary.CLIENTID);
        Assert.areEqual(1, PricingScenarioModelMap.get(client).MarginAnalysSummary.DataList.size());
        
		ClientPricingScenarioBuilder cpsBuilder = new ClientPricingScenarioBuilder(pScenario, myRenewal.Id, PricingScenarioModelMap);
		Map<String, ClientPricingScenario__c> ClientPricingScenarioMap = cpsBuilder.GetResult();

		Assert.areEqual(client, ClientPricingScenarioMap.get(client).ClientId__c);
		Assert.isTrue(ClientPricingScenarioMap.get(client) != null);
		Assert.isTrue(ClientPricingScenarioMap.get(client).Name != '');
	}

    
    @IsTest static void createClientScenariosWithRP()
	{
		Integer clientId = 900022;
		String client = '' + clientId;

		// Account account = TestFactory.createAccount(client, '98662', 'Client', true);
        Account rp = TestFactoryAccount.createReferralPartner('RP Test', '% of Margin', 12.0, null);
        Contact rpProducer = TestFactoryContact.createContact('Producer', 'TestContact', 'Producer', rp.Id);
        
        Account account = TestFactoryAccount.makeClient('' + client, rp.Id, rpProducer.Id);
        account.BillingPostalCode = '98662';
		account.External_ID__c = client;
		insert account;

		Renewal__c myRenewal = TestFactoryRenewals.createRenewal('Tester DEF', '99-1234567', 'New', true);

		String scenarioName = 'My Pricing Scenario';
		PricingScenarioBuilder psBuilder = new PricingScenarioBuilder(scenarioName, myRenewal.Id);
		PricingScenario__c pScenario = psBuilder.GetResult();

		/*
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new PricingDataCalloutClass_Mock('','',''));
		PricingScenarioDataModel pricingScenarioModel = new PricingScenarioDataModel(clientId, Date.today().addDays(45));
		pricingScenarioModel.GetData();
		Test.stopTest();
        */
        
        Test.startTest();
		String pricingScenarioData = getPricingScenarioData();
		Test.setMock(HttpCalloutMock.class, new GenericMockCallout(200, 'SUCCESS', pricingScenarioData, null));
		PricingScenarioDataModel pricingScenarioModel = new PricingScenarioDataModel(clientId, Date.today().addDays(45));
		pricingScenarioModel.GetData();
		Test.stopTest();

		Map<String, PricingScenarioDataModel> PricingScenarioModelMap = new Map<String, PricingScenarioDataModel>();
		PricingScenarioModelMap.put(client, pricingScenarioModel);

		Assert.isTrue(PricingScenarioModelMap.get(client) != null);
		Assert.isTrue(PricingScenarioModelMap.get(client).MarginAnalysSummary != null);
        Assert.areEqual('904611', PricingScenarioModelMap.get(client).MarginAnalysSummary.CLIENTID);
        Assert.areEqual(1, PricingScenarioModelMap.get(client).MarginAnalysSummary.DataList.size());
        
		ClientPricingScenarioBuilder cpsBuilder = new ClientPricingScenarioBuilder(pScenario, myRenewal.Id, PricingScenarioModelMap);
		Map<String, ClientPricingScenario__c> ClientPricingScenarioMap = cpsBuilder.GetResult();

		Assert.areEqual(client, ClientPricingScenarioMap.get(client).ClientId__c);
		Assert.isTrue(ClientPricingScenarioMap.get(client) != null);
		Assert.isTrue(ClientPricingScenarioMap.get(client).Name != '');
        
        // Handle null scenario
        cpsBuilder = new ClientPricingScenarioBuilder(null, myRenewal.Id, null);
		ClientPricingScenarioMap = cpsBuilder.GetResult();
	}
    

	@IsTest static void createClientScenNewMethod()
	{
		Integer client = 904611;
		// Account account = TestFactory.createAccount('' + client, '98662', 'Client', true);
        Account account = TestFactoryAccount.makeAccount('' + client, 'Client');
        account.BillingPostalCode = '98662';
		account.External_ID__c = '' + client;
		insert account;

		Test.startTest();
		// Test.setMock(HttpCalloutMock.class, new PricingDataCalloutClass_Mock('','',''));
        String pricingSummaryData = getPricingSummaryData();
		Test.setMock(HttpCalloutMock.class, new GenericMockCallout(200, 'SUCCESS', pricingSummaryData, null));
		PricingSummaryDataModel pSumDataModel = new PricingSummaryDataModel(client, Date.today().addDays(30), 'fein_here');
        pSumDataModel.GetData();
        
        String pricingScenarioData = getPricingScenarioData(); // '{"MARGINDATA":{"CLIENTID":"904611","DATALIST":[{"StartDate":"2018-04-01 00:00:00.0","EndDate":"2019-03-31 00:00:00.0","MARGINSUMDATALIST":[{"STATE":"MD","WCCODE":"0042","MARGIN":2.1,"BILLAMT":2467.71,"WCPREM":123.06}]}]},"TAXBURDEN":{"CLIENTID":"904611","DATALIST":[{"STARTDATE":"2018-04-01 00:00:00.0","ENDDATE":"2019-03-31 00:00:00.0","TotalPayroll":2100,"TotalTaxes":242.55,"TotalPayrollNo1000":2100,"TotalTaxesNo1000":242.55}]},"SISUMMARY":{"CLIENT":"904611","RUNDATE":"2019-01-31 00:00:00.0","DATALIST":[{"StartDate":"2018-04-01 00:00:00.0","EndDate":"2019-03-31 00:00:00.0","EligiblePR":0,"MaxSI":0,"Losses":0,"ProfServices":0,"ModWork":0,"SIEarned":0,"AmountPaid":0,"Status":" "}]},"COMMRATEDETAIL":{"CLIENTID":"904611","DATALIST":[{"Acronym":" ","Company":" ","TypeBegin":"1900-01-01 00:00:00.0","TypeEnd":"1900-01-01 00:00:00.0","CommissionType":" ","CommissionRate":0,"CommissionAmt":500.42,"Blended":0,"CommBasis":0,"ChksInPeriod":0,"WksInPeriod":0}]},"BDM":{"CLIENT":"904611","HASBDM":"FALSE","BDMNAME":" "}}';
		Test.setMock(HttpCalloutMock.class, new GenericMockCallout(200, 'SUCCESS', pricingScenarioData, null));
		PricingScenarioDataModel psDataModel = new PricingScenarioDataModel(client, Date.today().addDays(30));
        psDataModel.GetData();
        
        String pricingDataModelData = getPricingDataModelData(); // '{"PAYWCESTIMATES":{"CLIENT":"904611","DATALIST":[{"LastName":"SMITH,","FirstName":"ROBERT","Active":" ","IsOwner":0,"State":"MD","WCcodes":[{"WCcode":"0042","PayAmt":2100,"PremPayAmt":2100,"HoursWorked":208,"IsEligibleSI":0,"EligibleRateSI":0}]}]},"XMOD":{"CLIENTID":"904611","DATALIST":[{"STARTDATE":"2018-04-01 00:00:00.0","ENDDATE":"2019-03-31 00:00:00.0","XMODLIST":[{"STATE":"MD","XMOD":1}]}]},"SUTARATES":{"CLIENTID":"904611","DATALIST":[{"State":"AZ","SUTA":3.9,"ETT":-1,"EAF":-1,"Local":-1},{"State":"DC","SUTA":2.3,"ETT":-1,"EAF":-1,"Local":-1},{"State":"GA","SUTA":2.26,"ETT":-1,"EAF":-1,"Local":-1},{"State":"KS","SUTA":5.4,"ETT":-1,"EAF":-1,"Local":-1},{"State":"MD","SUTA":3.3,"ETT":-1,"EAF":-1,"Local":-1},{"State":"MO","SUTA":0.186,"ETT":-1,"EAF":-1,"Local":-1},{"State":"NC","SUTA":0.68,"ETT":-1,"EAF":-1,"Local":-1},{"State":"NE","SUTA":0.91,"ETT":-1,"EAF":-1,"Local":-1},{"State":"NJ","SUTA":6.5475,"ETT":0.1175,"EAF":-1,"Local":-1},{"State":"SC","SUTA":0.06,"ETT":-1,"EAF":-1,"Local":-1},{"State":"TX","SUTA":2.06,"ETT":-1,"EAF":-1,"Local":-1},{"State":"UT","SUTA":0.3,"ETT":-1,"EAF":-1,"Local":-1}]},"WCRATES":{"CLIENTID":"904611","DATALIST":[{"STATE":"MD","WCCODE":"0042","WCRATE":5.86}]}}';
		Test.setMock(HttpCalloutMock.class, new GenericMockCallout(200, 'SUCCESS', pricingDataModelData, null));
		PricingDataModel prDataModel = new PricingDataModel(client, Date.today().addDays(45));
        prDataModel.GetData();
		Test.stopTest();

		/*pSumDataModel.GetData();
		psDataModel.GetData();
		prDataModel.GetData();*/
        
        Assert.areEqual(904611, pSumDataModel.PayrollHistory.Client);
        Assert.areEqual(2, pSumDataModel.PayrollHistory.Payroll.size());
        
        Assert.areEqual('904611', psDataModel.MarginAnalysSummary.CLIENTID);
        Assert.areEqual(1, psDataModel.MarginAnalysSummary.DataList.size());
        
        Assert.areEqual('904611', prDataModel.PayWcEst.CLIENT);
        Assert.areEqual(1, prDataModel.PayWcEst.DATALIST.size());

		Renewal__c myRenewal = TestFactoryRenewals.createRenewal('myRenewal', '99-1234567', 'New', true);
		PricingScenarioBuilder psBuilder = new PricingScenarioBuilder();
		PricingScenario__c ps = psBuilder.BuildPricingScenario('MyPricingScenario', myRenewal.Id);
        Assert.areNotEqual(null, ps);
        
		ClientPricingScenarioBuilder cpsBuilder = new ClientPricingScenarioBuilder();

		try
		{
			ClientPricingScenario__c cps = cpsBuilder.BuildClientPricingScenario(ps, psDataModel);
            Assert.areEqual(psDataModel.ClientId, cps.ClientId__c);
            
			cpsBuilder.BuildAssociatedTables(pSumDataModel, prDataModel);
            
            cps = cpsBuilder.BuildClientPricingScenario(null, null);
		}
		catch (Exception e) {}
		// At this point, all Pricing Scenario data should be built, including History Rows

        ps = psBuilder.BuildPricingScenario('MyPricingScenario', myRenewal.Id);
        Assert.areEqual(null, ps);

    }
    
    
    @IsTest static void createClientScenWithRefPartner()
	{
		Integer client = 904611;
		// Account account = TestFactory.createAccount('' + client, '98662', 'Client', true);
		Account rp = TestFactoryAccount.createReferralPartner('RP Test', '% of Margin', 12.0, null);
        Contact rpProducer = TestFactoryContact.createContact('Producer', 'TestContact', 'Producer', rp.Id);
        
        Account account = TestFactoryAccount.makeClient('' + client, rp.Id, rpProducer.Id);
        account.BillingPostalCode = '98662';
		account.External_ID__c = '' + client;
		insert account;

		Test.startTest();
		// Test.setMock(HttpCalloutMock.class, new PricingDataCalloutClass_Mock('','',''));
        String pricingSummaryData = getPricingSummaryData();
		Test.setMock(HttpCalloutMock.class, new GenericMockCallout(200, 'SUCCESS', pricingSummaryData, null));
		PricingSummaryDataModel pSumDataModel = new PricingSummaryDataModel(client, Date.today().addDays(30), 'fein_here');
		pSumDataModel.GetData();
        
        String pricingScenarioData = getPricingScenarioData(); // '{"MARGINDATA":{"CLIENTID":"904611","DATALIST":[{"StartDate":"2018-04-01 00:00:00.0","EndDate":"2019-03-31 00:00:00.0","MARGINSUMDATALIST":[{"STATE":"MD","WCCODE":"0042","MARGIN":2.1,"BILLAMT":2467.71,"WCPREM":123.06}]}]},"TAXBURDEN":{"CLIENTID":"904611","DATALIST":[{"STARTDATE":"2018-04-01 00:00:00.0","ENDDATE":"2019-03-31 00:00:00.0","TotalPayroll":2100,"TotalTaxes":242.55,"TotalPayrollNo1000":2100,"TotalTaxesNo1000":242.55}]},"SISUMMARY":{"CLIENT":"904611","RUNDATE":"2019-01-31 00:00:00.0","DATALIST":[{"StartDate":"2018-04-01 00:00:00.0","EndDate":"2019-03-31 00:00:00.0","EligiblePR":0,"MaxSI":0,"Losses":0,"ProfServices":0,"ModWork":0,"SIEarned":0,"AmountPaid":0,"Status":" "}]},"COMMRATEDETAIL":{"CLIENTID":"904611","DATALIST":[{"Acronym":" ","Company":" ","TypeBegin":"1900-01-01 00:00:00.0","TypeEnd":"1900-01-01 00:00:00.0","CommissionType":" ","CommissionRate":0,"CommissionAmt":500.42,"Blended":0,"CommBasis":0,"ChksInPeriod":0,"WksInPeriod":0}]},"BDM":{"CLIENT":"904611","HASBDM":"FALSE","BDMNAME":" "}}';
		Test.setMock(HttpCalloutMock.class, new GenericMockCallout(200, 'SUCCESS', pricingScenarioData, null));
		PricingScenarioDataModel psDataModel = new PricingScenarioDataModel(client, Date.today().addDays(30));
		psDataModel.GetData();
        
        String pricingDataModelData = getPricingDataModelData(); // '{"PAYWCESTIMATES":{"CLIENT":"904611","DATALIST":[{"LastName":"SMITH,","FirstName":"ROBERT","Active":" ","IsOwner":0,"State":"MD","WCcodes":[{"WCcode":"0042","PayAmt":2100,"PremPayAmt":2100,"HoursWorked":208,"IsEligibleSI":0,"EligibleRateSI":0}]}]},"XMOD":{"CLIENTID":"904611","DATALIST":[{"STARTDATE":"2018-04-01 00:00:00.0","ENDDATE":"2019-03-31 00:00:00.0","XMODLIST":[{"STATE":"MD","XMOD":1}]}]},"SUTARATES":{"CLIENTID":"904611","DATALIST":[{"State":"AZ","SUTA":3.9,"ETT":-1,"EAF":-1,"Local":-1},{"State":"DC","SUTA":2.3,"ETT":-1,"EAF":-1,"Local":-1},{"State":"GA","SUTA":2.26,"ETT":-1,"EAF":-1,"Local":-1},{"State":"KS","SUTA":5.4,"ETT":-1,"EAF":-1,"Local":-1},{"State":"MD","SUTA":3.3,"ETT":-1,"EAF":-1,"Local":-1},{"State":"MO","SUTA":0.186,"ETT":-1,"EAF":-1,"Local":-1},{"State":"NC","SUTA":0.68,"ETT":-1,"EAF":-1,"Local":-1},{"State":"NE","SUTA":0.91,"ETT":-1,"EAF":-1,"Local":-1},{"State":"NJ","SUTA":6.5475,"ETT":0.1175,"EAF":-1,"Local":-1},{"State":"SC","SUTA":0.06,"ETT":-1,"EAF":-1,"Local":-1},{"State":"TX","SUTA":2.06,"ETT":-1,"EAF":-1,"Local":-1},{"State":"UT","SUTA":0.3,"ETT":-1,"EAF":-1,"Local":-1}]},"WCRATES":{"CLIENTID":"904611","DATALIST":[{"STATE":"MD","WCCODE":"0042","WCRATE":5.86}]}}';
		Test.setMock(HttpCalloutMock.class, new GenericMockCallout(200, 'SUCCESS', pricingDataModelData, null));
		PricingDataModel prDataModel = new PricingDataModel(client, Date.today().addDays(45));
		prDataModel.GetData();
		Test.stopTest();

		/*pSumDataModel.GetData();
		psDataModel.GetData();
		prDataModel.GetData();*/
        
        Assert.areEqual(904611, pSumDataModel.PayrollHistory.Client);
        Assert.areEqual(2, pSumDataModel.PayrollHistory.Payroll.size());
        
        Assert.areEqual('904611', psDataModel.MarginAnalysSummary.CLIENTID);
        Assert.areEqual(1, psDataModel.MarginAnalysSummary.DataList.size());
        
        Assert.areEqual('904611', prDataModel.PayWcEst.CLIENT);
        Assert.areEqual(1, prDataModel.PayWcEst.DATALIST.size());

		Renewal__c myRenewal = TestFactoryRenewals.createRenewal('myRenewal', '99-1234567', 'New', true);
		PricingScenarioBuilder psBuilder = new PricingScenarioBuilder();
		PricingScenario__c ps = psBuilder.BuildPricingScenario('MyPricingScenario', myRenewal.Id);
        Assert.areNotEqual(null, ps);
        
		ClientPricingScenarioBuilder cpsBuilder = new ClientPricingScenarioBuilder();

		try
		{
			ClientPricingScenario__c cps = 	cpsBuilder.BuildClientPricingScenario(ps, psDataModel);
            Assert.areEqual(psDataModel.ClientId, cps.ClientId__c);
            
			cpsBuilder.BuildAssociatedTables(pSumDataModel, prDataModel);
            
            cpsBuilder.BuildAssociatedTables(null, null);
		}
		catch (Exception e) {}
		// At this point, all Pricing Scenario data should be built, including History Rows

        ps = psBuilder.BuildPricingScenario('MyPricingScenario', myRenewal.Id);
        Assert.areEqual(null, ps);

    }
    
    public static String getPricingDataModelData() {
        return '{' 
            + '"PAYWCESTIMATES":{' 
            	+ '"CLIENT":"904611",' 
            	+ '"DATALIST":[{' 
            		+ '"LastName":"SMITH,","FirstName":"ROBERT","Active":" ","IsOwner":0,"State":"MD",' 
            		+ '"WCcodes":[{' 
            			+ '"WCcode":"0042","PayAmt":2100,"PremPayAmt":2100,"HoursWorked":208,' 
            			+ '"IsEligibleSI":0,"EligibleRateSI":0' 
            		+ '}]' 
            	+ '}]' 
            + '},' 
            + '"XMOD":{' 
            	+ '"CLIENTID":"904611",' 
            	+ '"DATALIST":[{' 
            		+ '"STARTDATE":"2018-04-01 00:00:00.0","ENDDATE":"2019-03-31 00:00:00.0",' 
            		+ '"XMODLIST":[{' 
            			+ '"STATE":"MD",' 
            			+ '"XMOD":1' 
            		+ '}]' 
            	+ '}]' 
            + '},' 
            + '"SUTARATES":{' 
            	+ '"CLIENTID":"904611",' 
            	+ '"DATALIST":[' 
		            + '{"State":"AZ","SUTA":3.9,"ETT":-1,"EAF":-1,"Local":-1},' 
            		+ '{"State":"DC","SUTA":2.3,"ETT":-1,"EAF":-1,"Local":-1},' 
            		+ '{"State":"GA","SUTA":2.26,"ETT":-1,"EAF":-1,"Local":-1},' 
            		+ '{"State":"KS","SUTA":5.4,"ETT":-1,"EAF":-1,"Local":-1},' 
            		+ '{"State":"MD","SUTA":3.3,"ETT":-1,"EAF":-1,"Local":-1},' 
            		+ '{"State":"MO","SUTA":0.186,"ETT":-1,"EAF":-1,"Local":-1},' 
            		+ '{"State":"NC","SUTA":0.68,"ETT":-1,"EAF":-1,"Local":-1},' 
            		+ '{"State":"NE","SUTA":0.91,"ETT":-1,"EAF":-1,"Local":-1},' 
            		+ '{"State":"NJ","SUTA":6.5475,"ETT":0.1175,"EAF":-1,"Local":-1},' 
            		+ '{"State":"SC","SUTA":0.06,"ETT":-1,"EAF":-1,"Local":-1},' 
            		+ '{"State":"TX","SUTA":2.06,"ETT":-1,"EAF":-1,"Local":-1},' 
            		+ '{"State":"UT","SUTA":0.3,"ETT":-1,"EAF":-1,"Local":-1}' 
            	+ ']' 
            + '},' 
            + '"WCRATES":{' 
            	+ '"CLIENTID":"904611",' 
            	+ '"DATALIST":[' 
            		+ '{"STATE":"MD","WCCODE":"0042","WCRATE":5.86}' 
            	+ ']' 
            + '}'
        + '}';
    }
    
    
    public static String getPricingScenarioData() {
        return '{' 
	            + '"MARGINDATA":{' 
            		+ '"CLIENTID":"904611",' 
		            + '"DATALIST":[{' 
           				+ '"StartDate":"2018-04-01 00:00:00.0",' 
           				+ '"EndDate":"2019-03-31 00:00:00.0",' 
			            + '"MARGINSUMDATALIST": [{' 
           					+ '"STATE":"MD",' 
            				+ '"WCCODE":"0042",' 
            				+ '"MARGIN":2.1,' 
            				+ '"BILLAMT":2467.71,' 
            				+ '"WCPREM":123.06' 
           				+ '}]' 
		            + '}]' 
            	+ '},' 
	            + '"TAXBURDEN": {' 
            		+ '"CLIENTID":"904611",' 
		            + '"DATALIST":[{' 
            			+ '"STARTDATE":"2018-04-01 00:00:00.0",' 
            			+ '"ENDDATE":"2019-03-31 00:00:00.0",' 
            			+ '"TotalPayroll":2100,"TotalTaxes":242.55,"TotalPayrollNo1000":2100,' 
            			+ '"TotalTaxesNo1000":242.55' 
		            + '}]' 
            	+ '},' 
            	+ '"SISUMMARY":{' 
            		+ '"CLIENT":"904611",' 
            		+ '"RUNDATE":"2019-01-31 00:00:00.0",' 
            		+ '"DATALIST":[{' 
            			+ '"StartDate":"2018-04-01 00:00:00.0",' 
            			+ '"EndDate":"2019-03-31 00:00:00.0","EligiblePR":0,"MaxSI":0,"Losses":0,' 
            			+ '"ProfServices":0,"ModWork":0,"SIEarned":0,"AmountPaid":0,"Status":" "' 
            		+ '}]' 
            	+ '},' 
            	+ '"COMMRATEDETAIL":{' 
            		+ '"CLIENTID":"904611",' 
            		+ '"DATALIST":[{' 
            			+ '"Acronym":" ", "Company":" ", ' 
            			+ '"TypeBegin":"1900-01-01 00:00:00.0", "TypeEnd":"1900-01-01 00:00:00.0",' 
            			+ '"CommissionType":" ","CommissionRate":0,"CommissionAmt":500.42,' 
            			+ '"Blended":0,"CommBasis":0,"ChksInPeriod":0,"WksInPeriod":0' 
            		+ '}]' 
            	+ '},' 
            	+ '"BDM":{' 
            		+ '"CLIENT":"904611","HASBDM":"FALSE","BDMNAME":" "' 
				+ '}' 
            + '}';
    }
    
    /**
     * getPricingSummaryData gets test Pricing Summary Data
     * @return   A JSON String of data
     */
    public static String getPricingSummaryData() {
        Integer year = Date.today().Year();
        Integer yearM1 = year-1;
        Integer yearM2 = year-2;
        Integer yearP1 = year+1;

        return
        '{' +
        ' "PayrollHistoryTable":{' +
        '  "Client":904611,' +
        '  "StartDate":"2018-04-01",' +
        '  "Payroll":[' +
        '   {' +
        '    "Year":"' + year + '",' +
        '    "MinDate":"' + year + '-05-20",' +
        '    "MaxDate":"' + year + '-11-04",' +
        '    "LastName":"BALDERSTON",' +
        '    "FirstName":"ALIK",' +
        '    "SSN":"***-**-1171",' +
        '    "IsOwner":0,' +
        '    "Active":"T",' +
        '    "WcDetails":[' +
        '     {' +
        '      "State":"CA",' +
        '      "WcCode":"0042",' +
        '      "JobCode":"0042",' +
        '      "BillAmt":11055.33,' +
        '      "PayAmt":9408,' +
        '      "PremPayAmt":9408,' +
        '      "TaxablePayAmt":9408,' +
        '      "ErTaxes":1120.54,' +
        '      "WcPremiums":551.35,' +
        '      "HoursWorked":784' +
        '     }' +
        '    ]' +
        '   },' +
        '   {' +
        '    "Year":"' + yearP1 + '",' +
        '    "MinDate":"' + yearP1 + '-04-14",' +
        '    "MaxDate":"' + yearP1 + '-09-01",' +
        '    "LastName":"SMITH,",' +
        '    "FirstName":"ROBERT",' +
        '    "SSN":"***-**-2369",' +
        '    "IsOwner":0,' +
        '    "Active":"T",' +
        '    "WcDetails":[' +
        '     {' +
        '      "State":"MD",' +
        '      "WcCode":"0042",' +
        '      "JobCode":"0042",' +
        '      "BillAmt":2467.71,' +
        '      "PayAmt":2100,' +
        '      "PremPayAmt":2100,' +
        '      "TaxablePayAmt":2100,' +
        '      "ErTaxes":242.55,' +
        '      "WcPremiums":123.06,' +
        '      "HoursWorked":208' +
        '     }' +
        '    ]' +
        '   }' +
        '  ]' +
        ' },' +
        ' "PayrollHistorySumTable":{' +
        '  "Client":904611,' +
        '  "StartDate":"' + year + '-04-01",' +
        '  "Data":[' +
        '   {' +
        '    "Year":"' + yearM2 + '",' +
        '    "MinDate":"2016-05-01",' +
        '    "MaxDate":"2017-03-25",' +
        '    "BillAmt":12968.44,' +
        '    "PayAmt":11036,' +
        '    "PremPayAmt":11036,' +
        '    "TaxablePayAmt":11036,' +
        '    "ErTaxes":1421.14,' +
        '    "WcPremiums":646.74,' +
        '    "BillAdj":0,' +
        '    "HoursWorked":921' +
        '   },' +
        '   {' +
        '    "Year":"' + yearM1 + '",' +
        '    "MinDate":"2017-04-01",' +
        '    "MaxDate":"2017-11-04",' +
        '    "BillAmt":12253.93,' +
        '    "PayAmt":10428,' +
        '    "PremPayAmt":10428,' +
        '    "TaxablePayAmt":10428,' +
        '    "ErTaxes":1262.83,' +
        '    "WcPremiums":611.12,' +
        '    "BillAdj":123,' +
        '    "HoursWorked":843' +
        '   },' +
        '   {' +
        '    "Year":"' + year + '",' +
        '    "MinDate":"2018-04-14",' +
        '    "MaxDate":"2018-09-01",' +
        '    "BillAmt":2467.71,' +
        '    "PayAmt":2100,' +
        '    "PremPayAmt":2100,' +
        '    "TaxablePayAmt":2100,' +
        '    "ErTaxes":242.55,' +
        '    "WcPremiums":123.06,' +
        '    "BillAdj":0,' +
        '    "HoursWorked":208' +
        '   }' +
        '  ]' +
        ' },' +
        ' "RiskClaimsSI":{' +
        '  "CLIENT":904611,' +
        '  "STARTDATE":"2018-04-01",' +
        '  "DATALIST":[' +
        '   {' +
        '    "Year":"' + year + '",' +
        '    "StateCode":"MD",' +
        '    "WCBilled":123.06,' +
        '    "PremBasedPayroll":2100,' +
        '    "PeriodStartDate":"' + yearM1 + '-04-01 00:00:00.0",' +
        '    "TotalIncurred":0,' +
        '    "UltimateExpected":0,' +
        '    "OpenClaims":0,' +
        '    "TotalClaims":0,' +
        '    "Frequency":0,' +
        '    "MaxSI":0' +
        '   },' +
        '   {' +
        '    "Year":"' + yearM1 + '",' +
        '    "StateCode":"MD",' +
        '    "WCBilled":611.12,' +
        '    "PremBasedPayroll":10428,' +
        '    "PeriodStartDate":"' + yearM2 + '-04-01 00:00:00.0",' +
        '    "TotalIncurred":0,' +
        '    "UltimateExpected":0,' +
        '    "OpenClaims":0,' +
        '    "TotalClaims":0,' +
        '    "Frequency":0,' +
        '    "MaxSI":0' +
        '   },' +
        '   {' +
        '    "Year":"' + yearM2 + '",' +
        '    "StateCode":"MD",' +
        '    "WCBilled":646.74,' +
        '    "PremBasedPayroll":11036,' +
        '    "PeriodStartDate":"2016-04-01 00:00:00.0",' +
        '    "TotalIncurred":0,' +
        '    "UltimateExpected":0,' +
        '    "OpenClaims":0,' +
        '    "TotalClaims":0,' +
        '    "Frequency":0,' +
        '    "MaxSI":0' +
        '   },' +
        '   {' +
        '    "Year":"0",' +
        '    "StateCode":" ",' +
        '    "WCBilled":0,' +
        '    "PremBasedPayroll":0,' +
        '    "PeriodStartDate":"2018-04-01 00:00:00.0",' +
        '    "TotalIncurred":0,' +
        '    "UltimateExpected":0,' +
        '    "OpenClaims":0,' +
        '    "TotalClaims":0,' +
        '    "Frequency":0,' +
        '    "MaxSI":0' +
        '   }' +
        '  ]' +
        ' },' +
        ' "BdmAndCommissions":{' +
        '  "CLIENT":904611,' +
        '  "STARTDATE":"2018-04-01",' +
        '  "HasBdm":"FALSE",' +
        '  "BdmName":" ",' +
        '  "DATALIST":[' +
        '   {' +
        '    "Year":"0",' +
        '    "Acronym":" ",' +
        '    "Company":" ",' +
        '    "MinDate":"1900-01-01 00:00:00.0",' +
        '    "MaxDate":"1900-01-01 00:00:00.0",' +
        '    "CommRate":0,' +
        '    "CommAmt":0' +
        '   }' +
        '  ]' +
        ' },' +
        ' "XmodHistory":{' +
        '  "Client":904611,' +
        '  "XmodDetails":[' +
        '   {' +
        '    "Year":"2017",' +
        '    "StateCode":"CA",' +
        '    "ModifiedDate":"2016-05-01 00:00:00.0",' +
        '    "Xmod":1' +
        '   }' +
        '  ]' +
        ' },' +
        ' "WorkCompRates":{' +
        '  "CLIENTID":"904611",' +
        '  "DATALIST":[' +
        '   {' +
        '    "STATE":"CA",' +
        '    "WCCODE":"0042",' +
        '    "WCRATE":5.86' +
        '   }' +
        '  ]' +
        ' },' +
        ' "WcAndSI":{' +
        '  "Client":904611,' +
        '  "WcSiList":[' +
        '   {' +
        '    "StateCode":"CA",' +
        '    "WcCode":"0042",' +
        '    "IsEligible":0,' +
        '    "EligibleRateSI":0' +
        '   }' +
        '  ]' +
        ' },' +
        ' "TemplateWorkCompRates":{' +
        '  "CLIENTID":"904611",' +
        '  "DATALIST":[' +
        '   {' +
        '    "STATE":"MD",' +
        '    "WCCODE":"0005",' +
        '    "WCRATE":1.99,' +
        '    "DESCRIPTION":"0005-FARM- NURSERY EMPLOYEES AND DRIVERS"' +
        '   },' +
        '   {' +
        '    "STATE":"MD",' +
        '    "WCCODE":"9620",' +
        '    "WCRATE":0.78,' +
        '    "DESCRIPTION":"9620-FUNERAL DIRECTOR AND DRIVERS"' +
        '   }' +
        '  ]' +
        ' }' +
        '}';
	}
}