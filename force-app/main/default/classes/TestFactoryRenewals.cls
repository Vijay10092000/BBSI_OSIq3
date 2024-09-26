/*
 * Test Factory for generating test Recods for
 * running test classes.  Each Method returns
 * one test record.  Parameters are the required
 * fields for each sObject.  As well as a boolean value
 * to determine if an insert is required.
 */
@IsTest
public class TestFactoryRenewals
{
	public static ER_Payroll_Tax_Master__c createErPayrollTaxMaster(String StateCode, String TaxType, Decimal Rate, Decimal taxLimit, Boolean ifInsert)
	{
		ER_Payroll_Tax_Master__c t = new ER_Payroll_Tax_Master__c(
				State_Code__c = StateCode,
				Tax_Type__c = TaxType,
				Rate__c = Rate,
				Limit__c = taxLimit);
		if(ifInsert){
			insert t;
		}
		return t;
	}

	public static Renewal__c createRenewal(String rName, String rFEIN, String rStatus, Boolean ifInsert)
	{
		Renewal__c r = new Renewal__c(
				Name = rName,
				FEIN__c = rFEIN,
				Renewal_Date__c = Date.today(),
				Status__c = rStatus);
		if(ifInsert){
			insert r;
		}
		return r;
	}

	public static PricingEmployee__c createPricingEmployee(String Name, String StateCode, Boolean ifInsert)
	{
		PricingEmployee__c e = new PricingEmployee__c(
				Employee_Name__c = Name,
				State_Code__c = StateCode,
				EstimatedERTax__c = 99.95,
				IsActive__c = true,
				IsOwner__c = false,
				Pricing_Group__c = 'Default',
				Qty__c = 1);
		if(ifInsert){
			insert e;
		}
		return e;
	}

	public static PricingWcCode__c createPricingWcCode(String wcCode, String StateCode, Boolean isInsert)
	{
		PricingWcCode__c w = new PricingWcCode__c(
				Name = wcCode + ' ' + StateCode,
				WC_Code__c = wcCode,
				WC_Rate__c = 2.5,
				State_Code__c = StateCode,
				DesiredMargin__c = 3.0,
				DesiredMarginDollars__c = 3.0,
				WcPremiumEquivalent__c = 100,
				WcPremiumBlended__c = 80,
				SIEligible__c = true,
				SI_Percent_of_Payroll__c = .01,
				Pricing_Group__c = 'Default'
		);
		if (isInsert) { insert w; }
		return w;
	}

	public static PricingTemplateWcCode__c createPricingTemplateWcCode(Id cpsId, String wcCode, String StateCode, Boolean isInsert)
	{
		PricingTemplateWcCode__c t = new PricingTemplateWcCode__c(
				ClientPricingScenario__c = cpsId,
				Name = StateCode + '.' + wcCode,
				WC_Code__c = wcCode,
				State_Code__c = StateCode,
				WC_Rate__c = 2.2
		);
		if (isInsert) { insert t; }
		return t;
	}

	public static PricingEEtoWcCodeAssoc__c createPricingEEtoWcAssoc(PricingEmployee__c ee, PricingWcCode__c wc, Boolean ifInsert)
	{
		PricingEEtoWcCodeAssoc__c ew = new PricingEEtoWcCodeAssoc__c(
				Pricing_Employee__c = ee.Id,
				PricingWcCode__c = wc.Id,
				AnnualHoursInCode__c = 1000,
				AnnualHoursInCode_base__c = 1000,
				AnnualHoursUnit__c = 1,
				AnnualPayInCode__c = 15000,
				AnnualPayInCode_base__c  = 15000,
				AnnualPayUnit__c = 1,
				AnnualPremPayInCode__c = 14000,
				AnnualPremPayInCode_base__c = 14000,
				AnnualTaxablePayInCode__c = 14800,
				AnnualTaxablePayInCode_base__c = 14800,
				ActiveEmployeesInCode__c = 1,
				TotalEmployeesInCode__c = 1
		);
		if(ifInsert){
			insert ew;
		}
		return ew;
	}

	public static PricingXmod__c createPricingXmod(ClientPricingScenario__c clientPricingScenario, Decimal xmodValue, String StateCode, Boolean ifInsert)
	{
		PricingXmod__c w = new PricingXmod__c(
				ClientPricingScenario__c = clientPricingScenario.Id,
				Xmod__c = xmodValue,
				Published_Xmod__c = xmodValue,
				State_Code__c = StateCode,
				IsPricingXmod__c = false,
				XmodDate__c = Date.Today() );
		if(ifInsert){
			insert w;
		}
		return w;
	}

	public static PricingScenario__c createPricingScenario(String Name, Boolean ifInsert)
	{
		Renewal__c newRenewal = TestFactoryRenewals.createRenewal('Tester DEF', '99-1234567', 'New', true);
		PricingScenario__c p = new PricingScenario__c(
				ScenarioName__c = Name,
				CreatedDate__c = datetime.now(),
				LastModifiedDate__c = datetime.now(),
				Renewal__c = newRenewal.Id,
				FEIN__c = newRenewal.FEIN__c,
				Status__c = 'New');
		if(ifInsert){
			insert p;
		}
		return p;
	}

	public static ClientPricingScenario__c createClientPricingScenario(String ClientId, Boolean ifInsert)
	{
		ClientPricingScenario__c cps = new ClientPricingScenario__c(
				ClientId__c = ClientId,
				BDM__c = 'Mr Bee Dee Em',
				BDM_Rate__c = 5,
				BDM_Rate_Renewal__c = 5,
				Published_Xmod__c = 0,
				Xmod__c = 0,
				ReferralPartner__c = 'Dummy Partner',
				ReferralPartnerRate__c = 3.5,
				projectionFactor__c = 1.0);
		if(ifInsert){
			insert cps;
		}
		return cps;
	}

	public static List<ERPayrollTax__c> createErPayrollTaxes(ClientPricingScenario__c cps, Integer numOfTaxes, Boolean ifInsert)
	{
		List<ERPayrollTax__c> taxes = new List<ERPayrollTax__c>();
		for(Integer i = 0; i < numOfTaxes; i++) {
			ERPayrollTax__c t = new ERPayrollTax__c(
					ClientPricingScenario__c = cps.Id,
					Limit__c = 0,
					Rate__c = 6.2,
					State_Code__c = 'CA',
					Tax_Type__c = 'FICA');
			taxes.add(t);
		}
		if(ifInsert){
			insert taxes;
		}
		return taxes;
	}

	public static List<ERPayrollTax__c> createErPayrollTaxTable(ClientPricingScenario__c cps, String stateCode, Boolean ifInsert)
	{
		List<ERPayrollTax__c> taxes = new List<ERPayrollTax__c>();
		taxes.add(new ERPayrollTax__c(ClientPricingScenario__c = cps.Id,Limit__c = 7000,Rate__c = 2.1,State_Code__c = stateCode,Tax_Type__c = 'FUTA'));
		taxes.add(new ERPayrollTax__c(ClientPricingScenario__c = cps.Id,Limit__c = 7000,Rate__c = 0.6,State_Code__c = 'FED',Tax_Type__c = 'FUTA'));
		taxes.add(new ERPayrollTax__c(ClientPricingScenario__c = cps.Id,Limit__c = 0,Rate__c = 1.45,State_Code__c = 'FED',Tax_Type__c = 'MEDI'));
		taxes.add(new ERPayrollTax__c(ClientPricingScenario__c = cps.Id,Limit__c = 127200,Rate__c = 6.2,State_Code__c = 'FED',Tax_Type__c = 'FICA'));
		taxes.add(new ERPayrollTax__c(ClientPricingScenario__c = cps.Id,Limit__c = 7000,Rate__c = 3.8,State_Code__c = stateCode,Tax_Type__c = 'SUTA'));
		if(ifInsert){
			insert taxes;
		}
		return taxes;
	}

	public static List<PricingExpense__c> createPricingExpenses(ClientPricingScenario__c cps, Integer numOfExpenses, Boolean ifInsert)
	{
		List<PricingExpense__c> expenses = new List<PricingExpense__c>();
		for(Integer i = 0; i < numOfExpenses; i++) {
			PricingExpense__c e = new PricingExpense__c(
					ClientPricingScenario__c = cps.Id,
					Category__c = 'Other',
					Cost_Each__c = 5.95,
					Description__c = 'Employee services',
					Quantity__c = 1);
			expenses.add(e);
		}
		if(ifInsert){
			insert expenses;
		}
		return expenses;
	}

	public static List<PricingClientInvestment__c> createPricingClientInvestments(ClientPricingScenario__c cps, Integer numOfInvestments, Boolean ifInsert)
	{
		List<PricingClientInvestment__c> investments = new List<PricingClientInvestment__c>();
		for(Integer i = 0; i < numOfInvestments; i++) {
			PricingClientInvestment__c e = new PricingClientInvestment__c(
					ClientPricingScenario__c = cps.Id,
					Description__c = 'Client Investment ' + (i+1),
					Method__c = '% of Payroll',
					Rate__c = 0.39);
			investments.add(e);
		}
		if(ifInsert){
			insert investments;
		}
		return investments;
	}

	public static List<XmodRecommended__c> createXmodRecommended(ClientPricingScenario__c cps, Integer numOfInvestments, String state, Boolean ifInsert)
	{
		List<XmodRecommended__c> recommended = new List<XmodRecommended__c>();
		for(Integer i = 0; i < numOfInvestments; i++) {
			XmodRecommended__c x = new XmodRecommended__c(
					Client_Info__c = cps.ClientId__c,
					Effective_Date__c = Date.today(),
					State_Code__c = state,
					Xmod__c = i + 0.2);
			recommended.add(x);
		}
		if(ifInsert){
			insert recommended;
		}
		return recommended;
	}

	public static List<PricingXmod__c> createPricingXmods(ClientPricingScenario__c cps, Integer numOfXmods, String stateCode, Boolean ifInsert)
	{
		List<PricingXmod__c> xmods = new List<PricingXmod__c>();
		for(Decimal i = 0; i < numOfXmods; i++) {
			PricingXmod__c xm = TestFactoryRenewals.createPricingXmod(cps, (1.0 + (i/10)), stateCode, false);
			xmods.add(xm);
		}
		xmods[numOfXmods - 1].IsPricingXmod__c = true;
		if(ifInsert)
		{
			insert xmods;
		}
		return xmods;
	}

	public static List<PricingScenario__c> createPricingScenarios(Integer numOfScenarios, Integer numOfClients, Integer eePerClient)
	{
		List<PricingScenario__c> priceScenarios = new List<PricingScenario__c>();
		List<ClientPricingScenario__c> clientScenarios = new List<ClientPricingScenario__c>();
		List<PricingEmployee__c> employees = new List<PricingEmployee__c>();
		List<PricingWcCode__c> wcCodes = new List<PricingWcCode__c>();
		List<PricingEEtoWcCodeAssoc__c> eeTOwcAssocs = new List<PricingEEtoWcCodeAssoc__c>();
		String stateCode = 'CA';
		Integer i;
		Integer j;
		for(i = 0; i<numOfScenarios; i++){
			PricingScenario__c p = TestFactoryRenewals.createPricingScenario('Pricing Scenario ' + (i + 1), false);
			priceScenarios.add(p);
		}
		insert priceScenarios;
		for(i = 0; i<numOfScenarios; i++){
			for (j = 0; j<numOfClients; j++){
				ClientPricingScenario__c cps = TestFactoryRenewals.createClientPricingScenario('90000' + j, false);
				cps.PricingScenario__c = priceScenarios[i].Id;
				clientScenarios.add(cps);
			}
		}
		insert clientScenarios;
		for(ClientPricingScenario__c cps : clientScenarios){
			// create ErPayrollTaxes
			TestFactoryRenewals.createErPayrollTaxes(cps, 5, true);

			// create Expenses
			TestFactoryRenewals.createPricingExpenses(cps, 7, true);

			// create Xmods
			TestFactoryRenewals.createPricingXmods(cps, 3, stateCode, true);
			TestFactoryRenewals.createXmodRecommended(cps, 5, stateCode, true);

			// create EmployeesAndCodes
			for(i = 0; i < eePerClient; i++) {
				PricingEmployee__c ee = TestFactoryRenewals.createPricingEmployee('Joe Barton ' + (i + 1), stateCode, false);
				ee.ClientPricingScenario__c = cps.Id;
				employees.add(ee);

				PricingWcCode__c wc = TestFactoryRenewals.createPricingWcCode('500' + (i + 1), stateCode, false);
				wc.ClientPricingScenario__c = cps.Id;
				wcCodes.add(wc);
			}
		}
		insert employees;
		insert wcCodes;

		Integer numOfassoc = numOfScenarios * numOfClients * eePerClient;
		for(i = 0; i < numOfassoc; i++) {
			PricingEEtoWcCodeAssoc__c assoc = new PricingEEtoWcCodeAssoc__c(
					Pricing_Employee__c = employees[i].Id,
					PricingWcCode__c = wcCodes[i].Id,
					AnnualPayInCode__c = 45000,
					AnnualHoursInCode__c = 3000,
					ActiveEmployeesInCode__c = 1,
					TotalEmployeesInCode__c = 1
			);
			eeTOwcAssocs.add(assoc);
		}
		insert eeTOwcAssocs;

		return priceScenarios;
	}

	/*
		Creates a complete pricing scenario, with client pricing scenarios,
		employees, wc codes, junction objects, taxes and expenses

	*/
	public static PricingScenario__c createPricingScenarioComplete()
	{
		Integer client = 904611;
		PricingScenario__c ps = TestFactoryRenewals.createPricingScenario('myPricingScenario', true);

		ClientPricingScenario__c cps = TestFactoryRenewals.createClientPricingScenario(String.valueOf(client), false);
		cps.PricingScenario__c = ps.Id;
		cps.ysumBilling__c = 100000;
		cps.ysumWcPrem__c = 1000;
		cps.ysumExpenses__c = 0;

		cps.ysumPayroll__c = 80000;
		cps.ysumErTaxes__c = 4800;
		cps.ysumMargin__c = 2400;

		cps.ysumMaxSI__c = 100;
		cps.ysumComms__c = 800;
		cps.ysumCommsBdm__c = 250;

		cps.BDM__c = 'John Doe';
		cps.BDM_Rate__c = 5;
		cps.BDM_Rate_Renewal__c = 5;
		cps.commRate__c = 10.5;
		cps.commRateRenewal__c = 10.5;
		cps.commBasis__c = 0;

		cps.commAcronym__c = 'foo';
		cps.commCompany__c = 'foobar';
		cps.Published_Xmod__c = 1;
		cps.Xmod__c = 1;

		insert cps;

		TestFactoryRenewals.createErPayrollTaxTable(cps, 'MD', true);
		TestFactoryRenewals.createPricingXmods(cps, 3, 'MD', true);
		TestFactoryRenewals.createXmodRecommended(cps, 5, 'MD', true);

		List<PricingEmployee__c> eeItems = new List<PricingEmployee__c>();

		PricingEmployee__c ee1 = TestFactoryRenewals.createPricingEmployee('John Doe 1', 'MD', false);
		ee1.ClientPricingScenario__c = cps.Id;
		eeItems.add(ee1);

		PricingEmployee__c ee2 = TestFactoryRenewals.createPricingEmployee('John Doe 2', 'MD', false);
		ee2.ClientPricingScenario__c = cps.Id;
		eeItems.add(ee2);

		PricingEmployee__c ee3 = TestFactoryRenewals.createPricingEmployee('Jane Doe 1', 'MD', false);
		ee3.ClientPricingScenario__c = cps.Id;
		eeItems.add(ee3);

		PricingEmployee__c ee4 = TestFactoryRenewals.createPricingEmployee('Jane Doe 2', 'MD', false);
		ee4.ClientPricingScenario__c = cps.Id;
		eeItems.add(ee4);

		insert eeItems;

		List<PricingWcCode__c> wcItems = new List<PricingWcCode__c>();

		PricingWcCode__c wc1 = TestFactoryRenewals.createPricingWcCode('3482', 'MD', false);
		wc1.ClientPricingScenario__c = cps.Id;
		wc1.State_Code__c = 'MD';
		wc1.WC_Code__c  = '3482';
		wc1.PercentOfPayroll__c = 40.0;
		wc1.DesiredMarginDollars__c = 400;
		wc1.Modified_WC_Rate__c = 10.4444;
		wc1.Markup_Blended__c = 20.456;
		wc1.Markup__c = 20.123;
		wc1.Markup_OverTime__c = wc1.Markup__c - (wc1.Modified_WC_Rate__c  / 3);
		wc1.Markup_DoubleTime__c = wc1.Markup__c - (wc1.Modified_WC_Rate__c  / 2);
		wcItems.add(wc1);

		PricingWcCode__c wc2 = TestFactoryRenewals.createPricingWcCode('8810', 'MD', false);
		wc2.ClientPricingScenario__c = cps.Id;
		wc2.State_Code__c = 'MD';
		wc2.WC_Code__c  = '3482';
		wc2.PercentOfPayroll__c = 60.0;
		wc2.DesiredMarginDollars__c = 600;
		wc2.Modified_WC_Rate__c = 11.4242;
		wc2.Markup_Blended__c = 25.654;
		wc2.Markup__c = 24.987;
		wc2.Markup_OverTime__c = wc2.Markup__c - (wc2.Modified_WC_Rate__c  / 3);
		wc2.Markup_DoubleTime__c = wc2.Markup__c - (wc2.Modified_WC_Rate__c  / 2);
		wcItems.add(wc2);

		insert wcItems;

		List<PricingTemplateWcCode__c> templateWcCodes = new List<PricingTemplateWcCode__c>();
		templateWcCodes.add(TestFactoryRenewals.createPricingTemplateWcCode(cps.Id, '1000', 'MD', false));
		templateWcCodes.add(TestFactoryRenewals.createPricingTemplateWcCode(cps.Id, '3482', 'MD', false));
		templateWcCodes.add(TestFactoryRenewals.createPricingTemplateWcCode(cps.Id, '8810', 'MD', false));

		insert templateWcCodes;

		List<PricingEEtoWcCodeAssoc__c> associations = new List<PricingEEtoWcCodeAssoc__c>();
		associations.add(TestFactoryRenewals.createPricingEEtoWcAssoc(eeItems[0], wcItems[0], false));
		associations.add(TestFactoryRenewals.createPricingEEtoWcAssoc(eeItems[1], wcItems[0], false));
		associations.add(TestFactoryRenewals.createPricingEEtoWcAssoc(eeItems[2], wcItems[1], false));
		associations.add(TestFactoryRenewals.createPricingEEtoWcAssoc(eeItems[3], wcItems[1], false));
		insert associations;

		TestFactoryRenewals.createPricingExpenses(cps, 5, true);
		TestFactoryRenewals.createPricingClientInvestments(cps, 5, true);

		PricingSummaryHistory__c psHistory = new PricingSummaryHistory__c();
		psHistory.ClientPricingScenario__c = cps.Id;
		psHistory.HeadcountAnnual__c = 3;
		psHistory.YendCommsBdm__c = 10;
		psHistory.YendBilling__c = 100000;
		psHistory.YendBilling_base__c = 100000;
		psHistory.PeriodEndDate__c = date.today().addDays(30);
		psHistory.FTE__c = 2;
		psHistory.YendMargin__c = 2400;
		psHistory.Headcount__c = 2;
		psHistory.YendMaxSI__c = 100;
		psHistory.YendPayroll__c = 80000;
		psHistory.YendPayroll_base__c = 80000;
		psHistory.YendPayrollTaxable__c = 80000;
		psHistory.YendPayrollTaxable_base__c = 80000;
		psHistory.PeriodType__c = 'Renewal Year';
		psHistory.PremiumBasedPayroll__c = 65000;
		psHistory.PremiumBasedPayroll_base__c = 65000;
		psHistory.YendComms__c = 400;
		psHistory.YendExpenses__c = 200;
		psHistory.PeriodStartDate__c = psHistory.PeriodEndDate__c.addYears(-1).addDays(1);
		psHistory.YendErTaxes__c = 4800;
		psHistory.YendErTaxes_base__c = 4800;
		psHistory.TotalClaims__c = 0;
		psHistory.TotalIncurred__c = 0;
		psHistory.YendWcPrem__c = 1000;
		psHistory.YendWcPrem_base__c = 1000;
		psHistory.Xmod__c = 1;
		psHistory.YendTaxBurden_Percent__c = psHistory.YendErTaxes__c * 100/ psHistory.YendPayrollTaxable__c;
		psHistory.YendCommissionPercent__c = psHistory.YendComms__c * 100 / psHistory.YendPayrollTaxable__c;
		psHistory.YendExpenses_Percent__c = psHistory.YendExpenses__c * 100 / psHistory.YendPayrollTaxable__c;

		insert psHistory;

		psHistory = new PricingSummaryHistory__c();
		psHistory.ClientPricingScenario__c = cps.Id;
		psHistory.HeadcountAnnual__c = 3;
		psHistory.YendCommsBdm__c = 10;
		psHistory.YendBilling__c = 100000;
		psHistory.YendBilling_base__c = 100000;
		psHistory.PeriodEndDate__c = date.today().addYears(-1).addDays(30);
		psHistory.FTE__c = 2;
		psHistory.YendMargin__c = 2400;
		psHistory.Headcount__c = 2;
		psHistory.YendMaxSI__c = 100;
		psHistory.YendPayroll__c = 80000;
		psHistory.YendPayroll_base__c = 80000;
		psHistory.YendPayrollTaxable__c = 80000;
		psHistory.YendPayrollTaxable_base__c = 80000;
		psHistory.PeriodType__c = 'Current Projected';
		psHistory.PremiumBasedPayroll__c = 65000;
		psHistory.PremiumBasedPayroll_base__c = 65000;
		psHistory.YendComms__c = 400;
		psHistory.YendExpenses__c = 200;
		psHistory.PeriodStartDate__c = psHistory.PeriodEndDate__c.addYears(-1).addDays(1);
		psHistory.YendErTaxes__c = 4800;
		psHistory.YendErTaxes_base__c = 4800;
		psHistory.TotalClaims__c = 0;
		psHistory.TotalIncurred__c = 0;
		psHistory.YendWcPrem__c = 1000;
		psHistory.YendWcPrem_base__c = 1000;
		psHistory.Xmod__c = 1;
		psHistory.YendTaxBurden_Percent__c = psHistory.YendErTaxes__c * 100/ psHistory.YendPayrollTaxable__c;
		psHistory.YendCommissionPercent__c = psHistory.YendComms__c * 100 / psHistory.YendPayrollTaxable__c;
		psHistory.YendExpenses_Percent__c = psHistory.YendExpenses__c * 100 / psHistory.YendPayrollTaxable__c;
		insert psHistory;

		return ps;
	}

	public static WorkCompPolicyDisplayName__c createWorkCompPolicyDisplayName(String policy, String displayName, Boolean include, Boolean ifInsert)
	{
		WorkCompPolicyDisplayName__c display = new WorkCompPolicyDisplayName__c(
			HRP_Work_Comp_Policy__c = policy, 
            Display_Name__c = displayName, 
            Include__c = include
		);

		if(ifInsert){
			insert display;
		}
		
		return display;
	}

	public static WorkCompRate__c createWorkCompRate(String policy, String state, String code, Decimal rate, Boolean ifInsert)
	{
		WorkCompRate__c wcrate = new WorkCompRate__c(
			Policy__c = policy,
			State__c = state,
			Code__c = code,
			Rate__c = rate
		);

		if(ifInsert){
			insert wcrate;
		}
		
		return wcrate;
	}
}