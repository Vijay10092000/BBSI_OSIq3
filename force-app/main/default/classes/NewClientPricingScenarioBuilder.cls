public without sharing class NewClientPricingScenarioBuilder
{
    private Decimal DEFAULT_XMOD = 1.0;
    private Decimal DEFAULT_MARGIN_PER_FTE = 1100;
    private CommissionRate__mdt Commission { get; set; }

    public NewClientPricingScenarioBuilder()
    {
        InitDefaultCommissionRate();
    }

    private void InitDefaultCommissionRate()
    {
        try
        {
            Commission =
            [
                SELECT BdmRate__c, RefPartnertRateWC__c
                FROM CommissionRate__mdt
                WHERE MasterLabel = 'Default Rates'
                LIMIT 1
            ];
            return;
        }
        catch(System.Exception e)
        {
            System.debug('Default Commission Rate error: (line num ' + e.getLineNumber() + '), ' + e.getMessage());
        }
    }

    public ClientPricingScenario__c BuildNewClientPricingScenario(PricingScenario__c ps, Account prospect, String opportunityId)
    {
        ClientPricingScenario__c cps = new ClientPricingScenario__c();
        try {
            if (ps == null || prospect == null) { return cps; }

            // CommissionRate__mdt defaultComm = GetDefaultCommissionRateVariables();
            cps.PricingScenario__c = ps.Id;
            cps.ClientId__c = prospect.External_ID__c == null || prospect.External_ID__c.length() == 0? '' : prospect.External_ID__c;
            cps.ClientName__c = prospect.Name;
            cps.projectionFactor__c = 1.0;

            cps.YsumBilling__c = 0;
            cps.YsumWcPrem__c = 0;
            cps.YsumPayroll__c = 0; // calculate from payroll data
            cps.YsumErTaxes__c = 0; // calculate from taxes data
            cps.YsumMaxSI__c = 0;
            cps.YsumComms__c = 0;
            cps.YsumCommsBdm__c = 0;
            cps.YsumMargin__c = 0;
            cps.YsumExpenses__c = 0;

            cps.BDM__c = prospect.Business_Development_Manager__r.Name; // BDM from the prospect account
            cps.BDM_Rate__c = Commission.BdmRate__c;
            cps.BDM_Rate_Renewal__c = Commission.BdmRate__c;
            cps.BDM_Basis__c = cps.YsumMargin__c;

            cps.IsProspect__c = (prospect.RecordType.Name == 'Prospect');
            cps.Opportunity__c = opportunityId;

            // Referral Partner Rate comes from:
            // if Account's Assigned RP exists and Commission Type is % of Work Comp, use RP commission rate
            // if Account's Asssigned RP exists but Commission Type is not % of Work Comp, use default RP commission rate (i.e.: 11.5%)
            // if Account's Assigned RP does NOT exist, use 0%
            if (prospect.Assigned_Referral_Partner__c != null) {
                Boolean hasRfValidCommission = prospect.Assigned_Referral_Partner__r.Commission_Type__c != null &&
                        prospect.Assigned_Referral_Partner__r.Commission_Type__c == '% of Work Comp' &&
                        prospect.Assigned_Referral_Partner__r.Commission_Rate__c != null;

                cps.commRate__c = hasRfValidCommission ? prospect.Assigned_Referral_Partner__r.Commission_Rate__c : Commission.RefPartnertRateWC__c;
                cps.commRateRenewal__c = hasRfValidCommission ? prospect.Assigned_Referral_Partner__r.Commission_Rate__c : Commission.RefPartnertRateWC__c;
                cps.commBasis__c = 0;
                cps.commAcronym__c = prospect.Assigned_Referral_Partner__r.Name;
                cps.commCompany__c = prospect.Assigned_Referral_Partner__r.Name;
            }
            else {
                cps.commRate__c = 0;
                cps.commBasis__c = 0;
                cps.commRateRenewal__c = 0;
                cps.commAcronym__c = '';
                cps.commCompany__c = '';
            }

            Database.SaveResult sr = Database.insert(cps, false);
            Log.writeIfError('Renewals - NewClientPricingScenarioBuilder.BuildNewClientPricingScenario()', 'Database Insert New Scenarios Failed', null, new List<Database.SaveResult>{ sr });
        } catch(system.Exception e) {
            System.debug(LoggingLevel.ERROR, 'ClientPricingScenarioBuilder Build CPS Exception: ' + e.getMessage() + ' ' + e.getLineNumber());
            throw new RenewalException('An unexpected error occurred while building a Client Pricing Scenario');
        }
        return cps;
    }

    public List<PricingXmod__c> BuildPricingXmods(ClientPricingScenario__c cps, List<String> states, Decimal xmod)
    {
        if (!(xmod > 0 )) {
            xmod = DEFAULT_XMOD;
        }

        List<PricingXmod__c> pricingXmods = new List<PricingXmod__c>();
        for (String state: states) {
            PricingXmod__c item = new PricingXmod__c(
                ClientPricingScenario__c = cps.Id,
                State_Code__c = state,
                IsPublishedXmod__c = false,
                IsPricingXmod__c = true,
                XmodStatus__c = '',
                Year__c = '',
                Xmod__c = xmod,
                XmodDate__c = Date.today()
            );
            pricingXmods.add(item);
        }

        SaveToDatabase(pricingXmods);
		return pricingXmods;
    }

    public List<ERPayrollTax__c> BuildPricingTaxes(ClientPricingScenario__c cps, List<String> states)
    {
        List<ERPayrollTax__c> taxes = new List<ERPayrollTax__c>();
        for (Er_Payroll_Tax_Master__c item : [ SELECT Limit__c, Rate__c, State_Code__c, Tax_Type__c, Name
                                                FROM ER_Payroll_Tax_Master__c
                                                WHERE State_Code__c = 'FED' OR State_Code__c IN :states]) {
            ERPayrollTax__c tax = new ERPayrollTax__c(
                ClientPricingScenario__c = cps.Id,
                Default_Rate__c = item.Rate__c,
                Limit__c = item.Limit__c,
                Non_Profit__c = false,
                State_Code__c = item.State_Code__c,
                Rate__c = item.Rate__c,
                Tax_Type__c = item.Tax_Type__c
            );
            taxes.add(tax);
        }

        SaveToDatabase(taxes);
        return taxes;
    }

    public void BuildEmployeeAndWorkComp(ClientPricingScenario__c cps, List<PrcNewPricingController.DataTableRow> rows, List<ERPayrollTax__c> taxes, Decimal xmod)
    {
        List<PricingEmployee__c> pricingEmployees = new List<PricingEmployee__c>();
        List<PricingWcCode__c> wcCodes = new List<PricingWcCode__c>();
        List<PricingEEtoWcCodeAssoc__c> associations = new List<PricingEEtoWcCodeAssoc__c>();
        Map<String, PricingEmployee__c> employeeMap = new Map<String, PricingEmployee__c>();
        Map<String, PricingWcCode__c> wcCodeMap = new Map<String, PricingWcCode__c>();

        for (PrcNewPricingController.DataTableRow row : rows) {
            String key = row.State + '.' + row.Code;
            PricingWcCode__c pricingWcCode = new PricingWcCode__c(
                ClientPricingScenario__c = cps.Id,
                Name = row.Code + ' ' + row.State,
                SIEligible__c = false,
                SI_Percent_of_Payroll__c = 0,
                SI_Percent_of_Premium__c = 0,
                WC_Code__c = row.Code,
                WC_Rate__c = row.Rate,
                HrpWcSuffix__c = '',
                State_Code__c = row.State,
                DesiredMargin__c = 3,
                Modified_WC_Rate__c = (row.Rate * xmod).setScale(4),
                Markup__c = 0,
                Markup_OverTime__c = 0,
                Markup_DoubleTime__c = 0,
                Markup_Blended__c = 0,
                Pricing_Group__c = '',
                WcPremiumEquivalent__c = CalculateWcPremium(row.PayrollDollars, row.Rate, xmod)
            );
            wcCodes.add(pricingWcCode);
            wcCodeMap.put(key, pricingWcCode);
        }
        SaveToDatabase(wcCodes);

        for (PrcNewPricingController.DataTableRow row : rows) {
            String key = row.State + '.' + row.Code;
            PricingWcCode__c primaryWcCode = wcCodeMap.get(key);
            PricingEmployee__c pricingEE = new PricingEmployee__c(
                ClientPricingScenario__c = cps.Id,
                State_Code__c = row.State,
                // When FTECount is zero, the row will behave the same as 'Modify By WC Code' - name format is modified to match 'Modify By WC Code' row
                Employee_Name__c = (row.FteCount == 0) ? key + ' Update' : 'WC Code ' + key,
                EstimatedERTax__c = CalculateEstimatedErTax(row.State, row.PayrollDollars, row.FteCount, taxes),
                IsActive__c = true,
                IsUpdate__c = (row.FteCount == 0),
                Pricing_Group__c = '',
                PrimaryPricingWcCode__c = primaryWcCode.Id,
                Primary_WC_Code__c = row.Code,
                Margin_Goal__c = 0,
                Qty__c = row.FteCount
            );
            pricingEmployees.add(pricingEE);
            employeeMap.put(key, pricingEE);
        }
        SaveToDatabase(pricingEmployees);

        for (PrcNewPricingController.DataTableRow row : rows) {
            // When FteCount is zero, payrollPerEmployee equals to the current payroll dollar specified
            // When FteCount is not zero, payrollPerEmployee equals to Payroll Dollars divided by FteCount
            Decimal payrollPerEmployee = row.FteCount > 0 ? (row.PayrollDollars / row.FteCount) : row.PayrollDollars;
            Decimal payroll = row.PayrollDollars;
            String key = row.State + '.' + row.Code;
            PricingEmployee__c emp = employeeMap.get(key);
            PricingWcCode__c wcCode = wcCodeMap.get(key);
            PricingEEtoWcCodeAssoc__c assoc = new PricingEEtoWcCodeAssoc__c(
                AnnualPayInCode_base__c = payrollPerEmployee,
                AnnualPremPayInCode_base__c = payrollPerEmployee,
                AnnualTaxablePayInCode_base__c = payrollPerEmployee,
                AnnualPayInCode__c = payroll,
                AnnualPremPayInCode__c = payroll,
                AnnualTaxablePayInCode__c = payroll,
                AnnualPayUnit__c = payroll,
                AnnualHoursInCode_base__c = PricingSummaryService.ANNUAL_FTE_HOURS,
                AnnualHoursInCode__c = row.FteCount * PricingSummaryService.ANNUAL_FTE_HOURS,
                AnnualHoursUnit__c = row.FteCount * PricingSummaryService.ANNUAL_FTE_HOURS,
                ActiveEmployeesInCode__c = row.FteCount,
                EstimatedErTaxInCode__c = emp.EstimatedERTax__c,
                Pricing_Employee__c = emp.Id,
                PricingWcCode__c = wcCode.Id,
                TotalEmployeesInCode__c = row.FteCount
            );

            associations.add(assoc);
        }
        SaveToDatabase(associations);
    }

    private PrcNewPricingController.TemplateWcCode GetTemplateWcCode(List<PrcNewPricingController.TemplateWcCode> templateWcCodes, String state)
    {
        for (PrcNewPricingController.TemplateWcCode template : templateWcCodes) {
            if (template.State == state) {
                return template;
            }
        }
        return null;
    }

    public void BuildWorkCompTemplates(ClientPricingScenario__c cps, List<String> states, List<PrcNewPricingController.TemplateWcCode> templateWcCodes)
    {
        List<PricingTemplateWcCode__c> templates = new List<PricingTemplateWcCode__c>();
        for (String state: states) {
            PrcNewPricingController.TemplateWcCode template = GetTemplateWcCode(templateWcCodes, state);
            if (template == null || template.WorkCompRates == null || template.WorkCompRates.size() == 0) {
                continue;
            }

            for (WorkCompRate__c wcr : template.WorkCompRates) {
                templates.add(
                    new PricingTemplateWcCode__c(
                        ClientPricingScenario__c = cps.Id,
                        Name = wcr.State__c + ' ' + wcr.Code__c + ' ' + wcr.Rate__c,
                        State_Code__c = wcr.State__c,
                        WC_Code__c = wcr.Code__c,
                        WC_Rate__c = wcr.Rate__c,
                        WC_Description__c = ''
                    )
                );
            }
        }
        Boolean isSuccessful = SaveToDatabase(templates);
    }

    public PricingSummaryHistory__c BuildPricingSummary(ClientPricingScenario__c cps, Decimal xmod, List<PrcNewPricingController.DataTableRow> rows)
    {
        Double annualHours = 0;
        Integer minLTDyear = 0;
        PricingSummaryHistory__c newHistoryRow = new PricingSummaryHistory__c();

        try
        {
            newHistoryRow.PeriodType__c = 'Renewal Year';
            newHistoryRow.ClientPricingScenario__c = cps.Id;
            newHistoryRow.FTE__c = 0;
            newHistoryRow.Headcount__c = 0;
            newHistoryRow.HeadcountAnnual__c = 0;
            newHistoryRow.YendExpenses__c = 0;
            newHistoryRow.YendBilling__c = 0;
            newHistoryRow.YendMargin__c = 0;
            newHistoryRow.Xmod__c = xmod;
            newHistoryRow.HeadcountAnnual__c = 0;
            newHistoryRow.Headcount__c = 0;
            newHistoryRow.PeriodEndDate__c = Date.today();
            newHistoryRow.PeriodStartDate__c = Date.today();
            newHistoryRow.YendBilling__c = 0;
            newHistoryRow.YendBillingAdjustments__c = 0;
            newHistoryRow.YendPayroll__c = 0;
            newHistoryRow.PremiumBasedPayroll__c = 0;
            newHistoryRow.YendPayrollTaxable__c = 0;
            newHistoryRow.YendPayrollTaxableNoOwner__c = 0;
            newHistoryRow.YendErTaxes__c = 0;
            newHistoryRow.YendErTaxesNoOwner__c = 0;
            newHistoryRow.YendWcPrem__c = 0;

            List<ERPayrollTax__c> taxes = [
                SELECT Id, State_Code__c, Limit__c, Rate__c, Tax_Type__c
                FROM ERPayrollTax__c
                WHERE ClientPricingScenario__c = : cps.Id];

            for(PrcNewPricingController.DataTableRow row: rows) {
                newHistoryRow.Headcount__c += row.FteCount;
                newHistoryRow.HeadcountAnnual__c += row.FteCount;
                newHistoryRow.YendBilling__c += row.PayrollDollars;
                newHistoryRow.YendPayroll__c += row.PayrollDollars;
                newHistoryRow.PremiumBasedPayroll__c += row.PayrollDollars;
                newHistoryRow.YendPayrollTaxable__c += row.PayrollDollars;
                newHistoryRow.YendPayrollTaxableNoOwner__c += row.PayrollDollars;
                newHistoryRow.YendErTaxes__c += CalculateEstimatedErTax(row.State, row.PayrollDollars, row.FteCount, taxes);
                newHistoryRow.YendErTaxesNoOwner__c = newHistoryRow.YendErTaxes__c;
                newHistoryRow.YendWcPrem__c += CalculateWcPremium(row.PayrollDollars, row.Rate, xmod);
                newHistoryRow.FTE__c += row.FteCount;
                newHistoryRow.YendBillingAdjustments__c = 0;
                newHistoryRow.YendMaxSI__c = 0.0;
                newHistoryRow.TotalIncurred__c = 0.0;
                newHistoryRow.UltimateExpected__c = 0.0;
                newHistoryRow.TotalClaims__c = 0.0;
            }

            List<PricingWcCode__c> wcCodes = [
                SELECT Id, WC_Code__c, DesiredMarginDollars__c,
                        AnnualPayInCode__c, AnnualPremPayInCode__c, AnnualTaxablePayInCode__c,
                        EstimatedErTaxInCode__c, Modified_WC_Rate__c,
                        Markup__c, Markup_OverTime__c, Markup_DoubleTime__c, MarkupNo1k__c, Markup_Blended__c,
                        PercentOfPayroll__c, WcPremiumEquivalent__c, WcPremiumBlended__c, WC_Rate__c
                FROM PricingWcCode__c
                WHERE ClientPricingScenario__c = : cps.Id];

            newHistoryRow.YendMargin__c = newHistoryRow.FTE__c * DEFAULT_MARGIN_PER_FTE;

            ApplyMarginToWcCodes(wcCodes, newHistoryRow.YendMargin__c, newHistoryRow.YendPayrollTaxable__c, newHistoryRow.Xmod__c);

            newHistoryRow.YendTaxBurden_Percent__c = (100 * newHistoryRow.YendErTaxes__c / newHistoryRow.YendPayrollTaxable__c).setScale(2);
            newHistoryRow.YendTaxBurden_PercentNo1k__c = (100 * newHistoryRow.YendErTaxesNoOwner__c / newHistoryRow.YendPayrollTaxable__c);

            newHistoryRow.YendComms__c = (cps.commRateRenewal__c * newHistoryRow.YendWcPrem__c / 100);
            newHistoryRow.YendCommsBdm__c = (cps.BDM_Rate_Renewal__c * newHistoryRow.YendMargin__c / 100);

            newHistoryRow.YendCommissionPercent__c = (100 * (newHistoryRow.YendComms__c + newHistoryRow.YendCommsBdm__c) / newHistoryRow.YendPayrollTaxable__c).setScale(2);

            List<PricingExpense__c> expenses = [
                SELECT Cost_Each__c, Quantity__c
                FROM PricingExpense__c
                WHERE ClientPricingScenario__c = :cps.Id
            ];

            List<PricingClientInvestment__c> clientInvestments = [
                SELECT Rate__c, Method__c
                FROM PricingClientInvestment__c
                WHERE ClientPricingScenario__c = :cps.Id
            ];

            newHistoryRow.YendExpenses__c = CalculateExpenses(expenses, clientInvestments, newHistoryRow);
            newHistoryRow.YendExpenses_Percent__c = (100 * newHistoryRow.YendExpenses__c / newHistoryRow.YendPayrollTaxable__c);

            ApplyMarkup(wcCodes, newHistoryRow);

            newHistoryRow.YendBilling__c =  newHistoryRow.YendPayroll__c + newHistoryRow.YendWcPrem__c +
                                            newHistoryRow.YendComms__c + newHistoryRow.YendCommsBdm__c + newHistoryRow.YendErTaxes__c +
                                            newHistoryRow.YendExpenses__c + newHistoryRow.YendMargin__c;

            Database.update(wcCodes, false);
            SaveToDatabase(new List<PricingSummaryHistory__c> {newHistoryRow});
        }
        catch(Exception e)
        {
            System.debug('PricingSummaryBuilder Exception: ' + e);
        }

        return newHistoryRow;
    }

    public void BuildAssociatedTables(ClientPricingScenario__c cps, Account prospect, List<PrcNewPricingController.DataTableRow> rows,
                                      List<PrcNewPricingController.TemplateWcCode> templateWcCodes)
    {
        try
        {
            // Pricing Xmod Builder; data = states and xmod
            List<String> states = GetStates(rows);
            Decimal xmod = DEFAULT_XMOD;
            try
            {
                String x_mod = prospect.X_mod__c.replaceAll('[,\n\r]', '-');
                String [] xmodInfo = x_mod.split('[-]');

                if (xmodInfo.size() == 0) {
                    xmod = DEFAULT_XMOD;
                }
                else if (xmodInfo.size() == 1) {
                    xmod = decimal.valueOf(prospect.X_mod__c.trim());
                }
                else {
                    xmod = decimal.valueOf(xmodInfo[1].trim());
                }
            }
            catch (Exception e)
            {
                xmod = DEFAULT_XMOD;
            }

            List<PricingXmod__c> test = BuildPricingXmods(cps, states, xmod);

            // Pricing Expenses Builder: Client Investment by Unit and Client Investment by %
            PricingExpenseBuilder prcExpenseBuilder = new PricingExpenseBuilder(cps);
            prcExpenseBuilder.GetResult();
            List<PricingExpense__c> expenses = prcExpenseBuilder.PricingExpenses;
            List<PricingClientInvestment__c> clientInvestments = prcExpenseBuilder.PricingClientInvestments;

            // Pricing Taxes Builder: ER Payroll Taxes
            List<ERPayrollTax__c> taxes = BuildPricingTaxes(cps, states);

            // Build Pricing Employees and WC Codes (with Association objects)
            BuildEmployeeAndWorkComp(cps, rows, taxes, xmod);

            BuildWorkCompTemplates(cps, states, templateWcCodes);

            // Build Pricing Summary/History Data
            BuildPricingSummary(cps, xmod, rows);
        }
        catch (Exception e) {
            System.debug('NewClientPricingScenarioBuilder - BuildAssociatedTables Exception: ' + e.getMessage());
            throw new RenewalException('An unexpected error occurred while building New Pricing Scenario tables');
        }
    }

    public Boolean SaveToDatabase(List<SObject> items)
    {
        Boolean result = true;
		List<Database.SaveResult> srList = Database.insert(items, false);
		for (Database.SaveResult sr : srList) {
			if (!sr.isSuccess()) {
				for(Database.Error err : sr.getErrors()) {
					System.debug(err.getStatusCode() + ': ' + err.getMessage());
					System.debug('Fields that affected this error: ' + err.getFields());
				}
				result = false;
			}
		}
		return result;
    }

    private List<String> GetStates(List<PrcNewPricingController.DataTableRow> rows)
    {
        Map<String, String> states = new Map<String, String>();
        for(PrcNewPricingController.DataTableRow row : rows) {
            String state = row.State;
            if (!states.containsKey(state)) {
                states.put(state, state);
            }
        }
        return states.values();
    }

    // Qty - min is 0.0
    private Decimal CalculateEstimatedErTax(String state, Decimal taxablePayrollInCode, Decimal qty, List<ERPayrollTax__c> taxes)
    {
        Decimal estimatedTax = 0;
        for(ERPayrollTax__c tax : taxes) {
            if (tax.State_Code__c != 'FED' && state != tax.State_Code__c) {
                continue;
            }

            // If Qty is 0, use the same behavior as Modify By WC Code employee row
            // Tax Calculation on Modify By WC Code employee row:
            // 1. Qty = 0, calculate only MEDI and FICA - NO limit
            //    1.a. MEDI and FICA - NO limit
            //    1.b. Other taxes - NO calculation needed - skip
            if (qty == 0) {
                if (tax.Tax_Type__c == 'MEDI' || tax.Tax_Type__c == 'FICA') {
                    estimatedTax += Math.abs(tax.Rate__c * taxablePayrollInCode / 100);
                    continue;
                }
            }

            // Calculation when Qty is not always a full number (i.e.: 1, 2, 3) - which will includes Qty with one decimal point (i.e.: 1.3, 4.2, 6.4)
            Decimal payrollPerEmployee = (qty > 0) ? (taxablePayrollInCode / qty).setScale(2) : 0;
            Decimal payrollLimit = 0;
            for(Decimal q = qty; q > 0; q--) {
                Decimal payroll = payrollPerEmployee;
                if (q < 1) {
                    payroll = payrollPerEmployee * q;
                }
                payrollLimit += (tax.Limit__c > 0) ? Math.min(tax.Limit__c, payroll) : payroll;
            }
            estimatedTax += (tax.Rate__c * payrollLimit) / 100;
        }
        return estimatedTax;
    }

    private Decimal CalculateWcPremium(Decimal taxablePayrollInCode, Decimal rate, Decimal xmod)
    {
        return ((taxablePayrollInCode * rate * xmod) / 100 ).setScale(2);
    }

    private Decimal CalculateExpenses(List<PricingExpense__c> expenses, List<PricingClientInvestment__c> clientInvestments, PricingSummaryHistory__c summary)
    {
        Decimal ciByUnit = 0;
        for (PricingExpense__c item : expenses) {
            ciByUnit += item.Cost_Each__c * item.Quantity__c;
        }

        Decimal ciByPercentage = 0;
        for(PricingClientInvestment__c item : clientInvestments){
            switch on item.Method__c.toLowerCase() {
                when '% of payroll' {
                    item.Total_Cost__c = item.Rate__c * summary.YendPayrollTaxable__c / 100;
                }
                when '% of wc premium' {
                    item.Total_Cost__c = item.Rate__c * summary.YendWcPrem__c / 100;
                }
                when '% of margin' {
                    item.Total_Cost__c = item.Rate__c * summary.YendMargin__c / 100;
                }
                when else {
                    item.Method__c = '% of Payroll';
                    item.Total_Cost__c = item.Rate__c * summary.YendPayrollTaxable__c / 100;
                }
            }
            ciByPercentage += item.Total_Cost__c;
        }

        return ciByUnit + ciByPercentage;
    }

    private void ApplyMarginToWcCodes(List<PricingWcCode__c> wcCodes, Decimal totMargin, Decimal totTaxablePayroll, Decimal xmod)
    {
        for(PricingWcCode__c item : wcCodes){
            item.PercentOfPayroll__c = (100 * item.AnnualTaxablePayInCode__c / totTaxablePayroll).setScale(2);
            item.DesiredMarginDollars__c = (item.AnnualTaxablePayInCode__c != 0) ? (totMargin * item.PercentOfPayroll__c / 100).setScale(2) : 0;
        }
    }

    private void ApplyMarkup(List<PricingWcCode__c> wcCodes, PricingSummaryHistory__c summary)
    {
        for (PricingWcCode__c item: wcCodes) {
            if (item.AnnualTaxablePayInCode__c <= 0) { continue; }

            Double marginOfPayroll = (100 * item.DesiredMarginDollars__c / item.AnnualTaxablePayInCode__c).setScale(2);
            Double expensesPercentOfPayroll = summary.YendExpenses_Percent__c;
            Double commissionPercentOfPayroll = summary.YendCommissionPercent__c;
            Double taxPercentOfPayroll = (100 * item.EstimatedErTaxInCode__c / item.AnnualTaxablePayInCode__c).setScale(2);

            item.Markup__c = (marginOfPayroll + taxPercentOfPayroll + expensesPercentOfPayroll + commissionPercentOfPayroll + item.Modified_WC_Rate__c).setScale(3);
            item.Markup_OverTime__c = (item.Markup__c - (item.Modified_WC_Rate__c / 3)).setScale(3);
            item.Markup_DoubleTime__c = (item.Markup__c - (item.Modified_WC_Rate__c / 2)).setScale(3);
            item.MarkupNo1k__c = (item.WC_Code__c == '100p0') ? 0 : item.Markup__c;
        }
    }
}