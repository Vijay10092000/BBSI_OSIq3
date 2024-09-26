/*
 * Copyright (c) 2018. Barrett Business Services, Inc. All Rights Reserved
 * Created by agoganian on 10/9/2018
 * Modified by celim - 2019
 */
public without sharing class PrcClientScenarioController
{
    @AuraEnabled
    public static List<String> getSummaryWorksheet(String recordId)
    {
        String comma = ',';
        String newLine = '\n';

        // Get Pricing Scenario data
        ClientPricingScenario__c cps = PrcClientScenarioController.getClientPricingScenario(recordId);
        PricingScenario__c ps = PrcScenarioController.getPricingScenario(cps.PricingScenario__c);
        PricingSummaryHistory__c summary = PrcMarginHistoryController.getPricingSummaryRenewalRow(recordId);
        PricingSummaryHistory__c[] marginDetails = PrcMarginHistoryController.getPricingSummaryHistories(recordId);
        PricingWcCode__c[] wcs = PrcMarkupController.getPricingWcCodes(recordId);
        PricingXmod__c[] xMods = PrcXmodController.getRenewalYearXmods(recordId);
        PricingXmod__c[] publishedXMods = PrcXmodController.getPublishedXmods(recordId, '5');
        XmodRecommended__c[] recommendedXMods = PrcXmodController.getXmodRecommended(recordId);
        PricingXmod__c[] historyXMods = PrcXmodController.getXmodHistory(recordId, '5');
        PricingEmployee__c[] employees = PrcEmployeesController.getPricingEmployees(recordId);
        PricingExpense__c[] expenses = PrcExpensesController.getPricingExpenses(recordId);
        PricingClientInvestment__c[] investments = PrcExpensesController.getPricingClientInvestments(recordId);

        // Build CSV content
        String csvContent = comma + '\"' + cps.ClientName__c + '\"';
        
        if (!cps.IsProspect__c) {
            csvContent += comma + comma + comma + cps.ClientId__c;
        }

        csvContent += newLine;
        csvContent += '\"' + ps.ScenarioName__c + '\"' + newLine;
        csvContent += newLine;

        csvContent += 'Scenario Summary Worksheet' + newLine;
        csvContent += 'Renewal Date, Report Create Date' + newLine;
        csvContent += ((ps.Renewal__r.Renewal_Date_Add_1__c == null) ? '' : ps.Renewal__r.Renewal_Date_Add_1__c.format())
                   + comma + System.today().format() + newLine;
        csvContent += newLine;

        // Summary
        csvContent += 'Summary' + newLine;
        csvContent += 'XMOD' + comma + 'Margin % of Billing' + comma + 'Margin % of Payroll' + comma + 'Margin $ Per Head' + comma + 'FTE' + comma + 'Turnover %' + newLine;
        csvContent += summary.Xmod__c.setScale(3) + comma +
                      summary.MarginPercent__c.setScale(2) + '%' + comma +
                      summary.MarginPercentPayroll__c.setScale(2) + '%' + comma +
                      '\"$' + summary.MarginPerHead__c  + '\"' + comma +
                      summary.FTE__c.setScale(1) + comma +
                      summary.Turnover__c + '%' + newLine;
        csvContent += newLine;

        // Margin Details
        csvContent += 'Margin Details' + newLine;
        if (cps.IsProspect__c) {
            csvContent += 'Create Date' + comma + 'Billing' + comma + 'Payroll' + comma + 'Tax' + comma + 'WC Premium' +
                comma + 'Commission' + comma + 'Client Investment' + comma + 'Net Margin' + comma + 'BU Min 3x' + comma + 'BU Max 5x' + newLine;    
        } else {
            csvContent += 'Start Date' + comma + 'Period' + comma + 'End Date' + comma + 'Billing' + comma + 'Payroll' + comma + 'Tax' + comma + 'WC Premium' +
                comma + 'Commission' + comma + 'Client Investment' + comma + 'Net Margin' + comma + 'BU Min 3x' + comma + 'BU Max 5x' + newLine;    
        }
        for(PricingSummaryHistory__c margin: marginDetails){
            if(margin.PeriodType__c == PricingSummaryService.MARGIN_HIST_FUTURE || margin.PeriodType__c == PricingSummaryService.MARGIN_HIST_CURRENT_PROJ)
            {
                csvContent += margin.PeriodStartDate__c.format() + comma;
                if (!cps.IsProspect__c) {
                    csvContent += margin.PeriodType__c + comma + + margin.PeriodEndDate__c.format() + comma;
                }
                csvContent += '\"$' + margin.YendBillingNet__c + '\"' + comma;
                csvContent += '\"$' + margin.YendPayroll__c + '\"' + comma;
                csvContent += '\"$' + margin.YendErTaxes__c + '\"' + comma;
                csvContent += '\"$' + margin.YendWcPrem__c + '\"' + comma;
                csvContent += '\"$' + margin.YendCommsTotal__c + '\"' + comma;
                csvContent += '\"$' + margin.YendExpenses__c + '\"' + comma;
                csvContent += '\"$' + margin.YendMargin__c + '\"' + comma;
                csvContent += margin.BUHours3x__c.setScale(1) + comma + margin.BUHours5x__c.setScale(1) + newLine;
            }
        }
        csvContent += newLine;

        // Renewal Year Markup
        if (cps.IsProspect__c) {
            csvContent += 'Markup' + newLine;
        } else {
            csvContent += 'Renewal Year Markup' + newLine;
        }
        csvContent += 'State' + comma + 'WC Code' + comma + '% of Payroll' + comma +
                'Net Margin' + comma + 'Tax Burden %' + comma + 'Modified WC Rate' + comma +
                'Markup %' + comma + 'OT %' + comma + 'DT %' + newLine;
        for(PricingWcCode__c x : wcs)
        {
            csvContent += x.State_Code__c + comma +
                    x.WC_Code__c + comma +
                    x.PercentOfPayroll__c.setScale(2) + '%' + comma +
                    '\"$' + x.DesiredMarginDollars__c + '\"' + comma +
                    x.TaxBurdenPercentInCode__c.setScale(2) + '%' + comma +
                    x.Modified_WC_Rate__c.setScale(4) + '%' + comma +
                    x.Markup__c.setScale(3) + '%' + comma +
                    x.Markup_OverTime__c.setScale(3) + '%' + comma +
                    x.Markup_DoubleTime__c.setScale(3) + '%' + newLine;
        }
        csvContent += newLine;

        csvContent += 'Tax Burden %' + comma + 'Commission %' + comma + 'Client Investment %' + newLine;
        csvContent += summary.YendTaxBurden_Percent__c.setScale(2) + '%' + comma +
                summary.YendCommissionPercent__c.setScale(2) + '%' + comma +
                summary.YendExpenses_Percent__c.setScale(2) + '%' + newLine;
        csvContent += newLine;

        // XMOD
        csvContent += 'XMOD' + newLine;

        if (cps.IsProspect__c) {
            csvContent += 'State' + comma + 'XMOD' + newLine;
        } else {
            csvContent += 'State' + comma + 'Renewal Year XMOD' + newLine;
        }
        for(PricingXmod__c x : xMods){
            csvContent += x.State_Code__c + comma +
                    x.Xmod__c.setScale(4) + newLine;
        }
        csvContent += newLine;

        if (!cps.IsProspect__c) {
            // XMOD history and recommendations
            csvContent += 'State' + comma + 'History Effective Date' + comma + 'XMOD History' + comma + 'Published Year' + comma + 'Published XMOD' + comma + 'Effective Date' + comma + 'Recommended XMOD' + newLine;
            for(PricingXmod__c x : xMods){
                String state = x.State_Code__c;
                String historyXmodInState = comma + comma;
                String publishedXmodInState = comma + comma;
                String recommendedXmodInState = comma + comma;
                for(PricingXmod__c history : historyXMods){
                    if(history.State_Code__c == state)
                    {
                        historyXmodInState = history.XmodDate__c.format() + comma + history.Xmod__c + comma;
                        break;
                    }
                }
                for(PricingXmod__c published : publishedXMods){
                    if(published.State_Code__c == state)
                    {
                        publishedXmodInState = published.XmodDate__c.format() + comma + (published.Xmod__c == null ? '' : published.Xmod__c.format()) + comma;
                        break;
                    }
                }
                for(XmodRecommended__c recommended : recommendedXMods){
                    if(recommended.State_Code__c == state)
                    {
                        recommendedXmodInState = recommended.Effective_Date__c.format() + comma + (recommended.Xmod__c == null ? '' : recommended.Xmod__c.format()) + comma;
                        break;
                    }
                }
                csvContent += x.State_Code__c + comma + historyXmodInState + publishedXmodInState + recommendedXmodInState + newLine;
            }
        }
        csvContent += newLine;

        // Workcomp
        csvContent += 'Work Comp' + newLine;
        csvContent += 'State' + comma + 'WC Code' + comma + 'Payroll' + comma + 'WC Rate' + comma + 'Modified WC Rate' + comma + 'WC Premium' + newLine;
        for(PricingWcCode__c x : wcs){
            csvContent += x.State_Code__c + comma + x.WC_Code__c + comma +
                    '\"$' +
                    x.AnnualTaxablePayInCode__c +
                    '\"' +
                    comma +
                    x.WC_Rate__c.setScale(4) + '%' + comma + x.Modified_WC_Rate__c.setScale(4) + '%' + comma +
                    '\"$' + x.WcPremiumEquivalent__c + '\"' + newLine;
        }
        csvContent += newLine;

        // Safety Incentive
        csvContent += 'Safety Incentive' + newLine;
        csvContent += 'State' + comma + 'WC Code' + comma + '% of Payroll' + comma + 'Max Safety Incentive' + newLine;
        for(PricingWcCode__c wc: wcs){
            csvContent += wc.State_Code__c + comma + wc.WC_Code__c + comma + wc.SI_Percent_of_Payroll__c.setScale(2) + '%' + comma + '\"$' +  wc.SI_Max__c + '\"' + newLine;
        }
        csvContent += newLine;

        csvContent += 'Max Safety Incentive' + newLine;
        if (cps.IsProspect__c) {
            csvContent += 'Contract Year';
        } else {
            csvContent += 'Renewal Year' + comma + 'Contract Year';
        }
        csvContent += newLine;
        for(PricingSummaryHistory__c margin: marginDetails){
            if(margin.PeriodType__c == PricingSummaryService.MARGIN_HIST_FUTURE)
            {
                csvContent += '\"$' + margin.YendMaxSI__c.setScale(2) + '\"' + comma;
                break;
            }
        }
        if (cps.IsProspect__c) {
            csvContent += newLine;
        }

        if (!cps.IsProspect__c) {
            for(PricingSummaryHistory__c margin: marginDetails){
                if(margin.PeriodType__c == PricingSummaryService.MARGIN_HIST_CURRENT_YTD)
                {
                    csvContent += '\"$' + margin.YendMaxSI__c.setScale(2) + '\"' + newLine;
                    break;
                }
            }
        }
        csvContent += newLine;

        // Commmission Expenses
        csvContent += 'Commission Expense' + newLine;
        if (cps.IsProspect__c) {
            csvContent += 'Type' + comma + 'Description' + comma + 'Rate' + comma + 'Amount' + newLine;
        } else {
            csvContent += 'Type' + comma + 'Description' + comma + 'Renewal Year Rate' + comma + 'Renewal Year Amount' + newLine;
        }

        csvContent += 'Referral Partner' + comma + '\"'+ (cps.commCompany__c == null ? '' : cps.commCompany__c) + '\"' + comma + cps.commRateRenewal__c.setScale(2) + '%' + + comma + '\"$' + summary.YendComms__c + '\"' + newLine;
        csvContent += 'BDM' + comma + (cps.BDM__c  == null ? '' : cps.BDM__c) + comma + cps.BDM_Rate_Renewal__c.setScale(2) + '%' + + comma + '\"$' + summary.YendCommsBdm__c + '\"' + newLine;
        csvContent += newLine;

        // Payroll and Employer Taxes
        csvContent += 'Payroll and Employer Taxes' + newLine;
        csvContent += 'Total Employees' + comma + 'Active Employees' + comma + 'Annual Hours' + comma + 'Annual Payroll' + comma + 'Est. Employer Taxes' + newLine;
        Decimal totalEmployees = 0;
        Decimal activeEmployees = 0;
        Decimal annualHours = 0;
        Decimal annualPayroll = 0;
        Decimal employerTaxes = 0;
        for(PricingEmployee__c e: employees){
            totalEmployees += e.Qty__c;
            if(e.IsActive__c)
            {
                activeEmployees += e.Qty__c;
            }
            annualHours += e.AnnualHours__c;
            annualPayroll += e.AnnualTaxablePay__c;
            employerTaxes += e.EstimatedERTax__c;
        }
        csvContent += totalEmployees + comma + activeEmployees + comma + annualHours.setScale(1) + comma + '\"$' +annualPayroll + '\"' + comma + '\"$' + employerTaxes + '\"' + newLine;
        csvContent += newLine;

        // Employer Tax Rates
        csvContent += 'Employer Tax Rates' + newLine;
        csvContent += 'State' + comma + 'Tax Type' + comma + 'Tax Rate %' + comma + 'Limit' + newLine;
        ERPayrollTax__c[] taxes = PrcTaxRatesController.getPricingTaxes(recordId);
        for(ERPayrollTax__c x : taxes){
            csvContent += x.State_Code__c + comma + x.Tax_Type__c + comma + x.Rate__c.setScale(3) + '%' + + comma + '\"$' + x.Limit__c + '\"' + newLine;
        }
        csvContent += newLine;

        // Client Investment By Unit
        String expensesContent = '';
        for(PricingExpense__c x : expenses){
            if(x.totalcal__c > 0)
            {
                expensesContent += '\"' + x.Category__c + '\"' + comma + '\"' + x.Description__c + '\"' + comma + x.Quantity__c + comma + '\"$' + x.Cost_Each__c + '\"' + comma + '\"$' + x.totalcal__c + '\"' + newLine;
            }
        }
        if(expensesContent.length() > 0)
        {
            csvContent += 'Client Investment By Unit' + newLine;
            csvContent += 'Category' + comma + 'Description' + comma + 'Units' + comma + 'Cost Per Unit' + comma + 'Total Cost' + newLine;
            csvContent += expensesContent;
        }
        csvContent += newLine;

        // Client Investment By %
        String investmentsContent = '';
        for(PricingClientInvestment__c x: investments){
            if(x.Total_Cost__c > 0)
            {
                investmentsContent += '\"' + x.Description__c + '\"' + comma + '\"' + x.Method__c + '\"' + comma + x.Rate__c.setScale(2) + '%' + comma + '\"$' + x.Total_Cost__c + '\"' + newLine;
            }
        }

        if(investmentsContent.length() > 0)
        {
            csvContent += 'Client Investment By %' + newLine;
            csvContent += 'Description' + comma + 'Method' + comma + 'Rate' + comma + 'Total Cost' + newLine;
            csvContent += investmentsContent;
        }
        csvContent += newLine;

        // format the filename
        String filename = cps.ClientId__c + ' ' + ps.ScenarioName__c + ' Summary.csv';

        List<String> result = new List<String>();
        result.add(filename);
        result.add(csvContent);

        return result;
    }

    @AuraEnabled
    public static ClientPricingScenario__c getClientPricingScenario(String recordId){
        ClientPricingScenario__c[] result = [
                SELECT
                        BDM__c,
                        BDM_Basis__c,
                        BDM_Rate__c,
                        BDM_Rate_Renewal__c,
                        BureauReportUrl__c,
                        ClientId__c,
                        ClientName__c,
                        commAcronym__c,
                        commBasis__c,
                        commCompany__c,
                        commRate__c,
                        commRateRenewal__c,
                        CreatedById,
                        CreatedDate,
                        Id,
                        HasBdm__c,
                        HasReferralPartner__c,
                        IsProspect__c,
                        LastModifiedById,
                        LastModifiedDate,
                        Name,
                        Non_Profit__c,
                        Notes__c,
                        PricingScenario__c,
                        projectionFactor__c,
                        ysumBilling__c,
                        ysumComms__c,
                        ysumCommsBdm__c,
                        ysumErTaxes__c,
                        ysumExpenses__c,
                        ysumMargin__c,
                        ysumMaxSI__c,
                        ysumPayroll__c,
                        ysumWcPrem__c
                FROM ClientPricingScenario__c
                WHERE Id = :recordId];
        if(result.size() > 0){
            System.debug('\tCE: getClientPricingScenario: ' + result[0]);
            return result[0];
        } else {
            return null;
        }
    }

    @AuraEnabled
    public static void SaveClientPricingScenario(ClientPricingScenario__c clientPricingScenario){
        System.debug('\tCE: SaveClientPricingScenario: ' + clientPricingScenario);
        Database.SaveResult sr = Database.update(clientPricingScenario, false);
        if (!sr.isSuccess()){
            System.debug('Save Client Pricing Scenario Errors: ' + sr.getErrors());
        }
    }

    @AuraEnabled
    public static PricingEEtoWcCodeAssoc__c[] getEEtoWcCodeAssocs(String recordId){
        return PrcEmployeesController.getEEtoWcCodeAssocs(recordId);
    }

    @AuraEnabled
    public static PricingEmployee__c[] getPricingEmployees(String recordId) {
        return PrcEmployeesController.getPricingEmployees(recordId);
    }

    @AuraEnabled
    public static PricingSummaryHistory__c getPricingSummaryRenewalRow(String recordId){
        return PrcMarginHistoryController.getPricingSummaryRenewalRow(recordId);
    }

    @AuraEnabled
    public static void savePricingSummaryRenewalRow(PricingSummaryHistory__c pricingSummary){
        PrcMarginHistoryController.savePricingSummaryRenewalRow(pricingSummary);
    }

    @AuraEnabled
    public static PricingWcCode__c[] getPricingWcCodes(String recordId){
        return PrcWorkCompController.getPricingWcCodes(recordId);
    }

    @AuraEnabled
    public static PricingXmod__c[] getRenewalYearXmods(String recordId) {
        return PrcXmodController.getRenewalYearXmods(recordId);
    }

    @AuraEnabled
    public static ERPayrollTax__c[] getPricingTaxes(String recordId) {
        return PrcTaxRatesController.getPricingTaxes(recordId);
    }

    @AuraEnabled
    public static PricingExpense__c[] getPricingExpenses(String recordId){
        return PrcExpensesController.getPricingExpenses(recordId);
    }

    @AuraEnabled
    public static PricingClientInvestment__c[] getPricingClientInvestments(String recordId){
        return PrcExpensesController.getPricingClientInvestments(recordId);
    }

    @AuraEnabled
    public static void saveAssocListAll(PricingEEtoWcCodeAssoc__c[] assocList){
        // We will save the Employees, WC Codes and EEtoWC junction objects
        Set<PricingWcCode__c> wcSet = new Set<PricingWcCode__c>();
        Set<PricingEmployee__c> eeSet = new Set<PricingEmployee__c>();
        PricingWcCode__c wcCode;
        PricingEmployee__c employee;

        for (Integer i = 0; i < assocList.size(); i++) {
            wcCode = new PricingWcCode__c(
                    Id=assocList[i].PricingWcCode__r.Id,
                    ClientPricingScenario__c = assocList[i].PricingWcCode__r.ClientPricingScenario__c,
                    DesiredMargin__c = assocList[i].PricingWcCode__r.DesiredMargin__c,
                    DesiredMarginDollars__c = assocList[i].PricingWcCode__r.DesiredMarginDollars__c,
                    Markup__c = assocList[i].PricingWcCode__r.Markup__c,
                    Markup_OverTime__c = assocList[i].PricingWcCode__r.Markup_OverTime__c,
                    Markup_DoubleTime__c = assocList[i].PricingWcCode__r.Markup_DoubleTime__c,
                    Markup_Blended__c = assocList[i].PricingWcCode__r.Markup_Blended__c,
                    MarkupNo1k__c = assocList[i].PricingWcCode__r.MarkupNo1k__c,
                    Modified_WC_Rate__c = assocList[i].PricingWcCode__r.Modified_WC_Rate__c,
                    Name = assocList[i].PricingWcCode__r.Name,
                    PercentOfPayroll__c = assocList[i].PricingWcCode__r.PercentOfPayroll__c,
                    SI_Percent_of_Payroll__c = assocList[i].PricingWcCode__r.SI_Percent_of_Payroll__c,
                    SI_Percent_of_Premium__c = assocList[i].PricingWcCode__r.SI_Percent_of_Premium__c,
                    SIEligible__c = assocList[i].PricingWcCode__r.SIEligible__c,
                    State_Code__c = assocList[i].PricingWcCode__r.State_Code__c,
                    WC_Code__c = assocList[i].PricingWcCode__r.WC_Code__c,
                    WC_Rate__c = assocList[i].PricingWcCode__r.WC_Rate__c,
                    WcPremiumEquivalent__c = assocList[i].PricingWcCode__r.WcPremiumEquivalent__c,
                    WcPremiumBlended__c = assocList[i].PricingWcCode__r.WcPremiumBlended__c
            );
            wcSet.add(wcCode);

            employee = new PricingEmployee__c(
                    Id=assocList[i].Pricing_Employee__r.Id,
                    ClientPricingScenario__c = assocList[i].Pricing_Employee__r.ClientPricingScenario__c,
                    IsActive__c = assocList[i].Pricing_Employee__r.IsActive__c,
                    IsUpdate__c = assocList[i].Pricing_Employee__r.IsUpdate__c,
                    EstimatedERTax__c = assocList[i].Pricing_Employee__r.EstimatedERTax__c,
                    Margin_Goal__c = assocList[i].Pricing_Employee__r.Margin_Goal__c,
                    Employee_Name__c = assocList[i].Pricing_Employee__r.Employee_Name__c,
                    IsOwner__c = assocList[i].Pricing_Employee__r.IsOwner__c,
                    Primary_WC_Code__c = assocList[i].Pricing_Employee__r.Primary_WC_Code__c,
                    PrimaryPricingWcCode__c = assocList[i].Pricing_Employee__r.PrimaryPricingWcCode__c,
                    Qty__c = assocList[i].Pricing_Employee__r.Qty__c,
                    State_Code__c = assocList[i].Pricing_Employee__r.State_Code__c
            );
            eeSet.add(employee);
        }

        PrcWorkCompController.savePricingWcCodes(new List<PricingWcCode__c>(wcSet));
        PrcEmployeesController.saveEmployees(new List<PricingEmployee__c>(eeSet));
        PrcEmployeesController.saveAssocList(assocList);
    }

    @AuraEnabled
    public static void savePricingWcCodes(PricingWcCode__c[] wcCodes)
    {
        PrcWorkCompController.savePricingWcCodes(wcCodes);
    }

    @AuraEnabled
    public static void saveEmployees(PricingEmployee__c[] eeList)
    {
        PrcEmployeesController.saveEmployees(eeList);
    }

    @AuraEnabled
    public static void saveAssocList(PricingEEtoWcCodeAssoc__c[] assocList)
    {
        PrcEmployeesController.saveAssocList(assocList);
    }

    @AuraEnabled
    public static Billing_History__c[] getBillingHistories(String clientId)
    {
        return PrcMarkupController.getBillingHistories(clientId);
    }

    @AuraEnabled
    public static Map<String, String> getSafetyIncentiveRates(String clientId)
    {
        return PrcMarkupController.getSafetyIncentives(clientId);
    }

    @AuraEnabled
    public static void saveReportSettings(ClientPricingScenario__c clientPricingScenario, PricingWcCode__c[] wcCodes)
     {
        PrcClientScenarioController.SaveClientPricingScenario(clientPricingScenario);
        PrcClientScenarioController.savePricingWcCodes(wcCodes);
    }
}