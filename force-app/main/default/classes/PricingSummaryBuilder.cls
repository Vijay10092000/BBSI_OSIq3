/*
 * Copyright (c) 2018. Barrett Business Services, Inc. All Rights Reserved
 */

public without sharing class PricingSummaryBuilder
{
    private ClientPricingScenario__c m_clientPricingScenario;
    private PricingSummaryDataModel m_pricingSummaryData;
    private List<PricingSummaryHistory__c> m_pricingSumHistList;
    private Date m_renewalDate;
    private Integer m_RenewalDateYear;
    private Double m_projectionFactor;

    private Date date19800101 = Date.valueOf('1980-01-01');

    public PricingSummaryBuilder(ClientPricingScenario__c ClientPricingScenario, PricingSummaryDataModel PricingSummaryData)
    {
        if(ClientPricingScenario != null && PricingSummaryData != null) {
            try
            {
                m_clientPricingScenario = ClientPricingScenario;
                m_pricingSummaryData = PricingSummaryData;
                m_renewalDate = PricingSummaryData.EndDate.addDays(1);
                m_RenewalDateYear = m_renewalDate.addDays(-1).year();
            }
            catch (System.Exception e) {
                Log.error('Pricing', 'PricingSummaryBuilder constructor', null, e);
                throw new RenewalException('An unexpected error occurred', e);
            }
        }
    }

    public Boolean getResult()
    {
        Boolean result = true;
        try
        {
            PricingSummaryHistory__c dataRow;
            String periodType;
            m_pricingSumHistList = new List<PricingSummaryHistory__c>();
            m_projectionFactor = getProjectionFactor();

            // CONTRACT YEAR PROJECTED
            periodType = getPeriodType(m_RenewalDateYear, true, false);
            dataRow = buildHistoryRow(m_RenewalDateYear, true, false, periodType);
            if(historyRowIsValid(dataRow))
            {
                // Change the end date since we're projecting to end of period
                dataRow.PeriodEndDate__c = m_renewalDate.addDays(-1);
                dataRow.PeriodStartDate__c = m_renewalDate.addYears(-1);
                m_pricingSumHistList.add(dataRow);
            }

            // FUTURE YEAR (RENEWAL YEAR)
            periodType = getPeriodType(m_RenewalDateYear, true, true);
            dataRow = buildHistoryRow(m_RenewalDateYear, true, true, periodType);
            if(historyRowIsValid(dataRow))
            {
                // For future year, bump the start and end dates by 1 year
                dataRow.PeriodEndDate__c = m_renewalDate.addYears(1).addDays(-1);
                dataRow.PeriodStartDate__c = m_renewalDate;
                m_pricingSumHistList.add(dataRow);
            }


            // CONTRACT YEAR TO DATE
            periodType = getPeriodType(m_RenewalDateYear, false, false);
            dataRow = buildHistoryRow(m_RenewalDateYear, false, false, periodType);
            if(historyRowIsValid(dataRow))
            {
                dataRow.PeriodEndDate__c = Date_Service.minDate(Datetime.now().date(), m_renewalDate.addDays(-1));
                dataRow.PeriodStartDate__c = m_renewalDate.addYears(-1);
                m_pricingSumHistList.add(dataRow);
            }

            // CONTRACT YEAR - 1
            periodType = getPeriodType(m_RenewalDateYear-1, false, false);
            dataRow = buildHistoryRowFromSummary(m_RenewalDateYear -1, periodType);
            if(historyRowIsValid(dataRow))
            {
                dataRow.PeriodEndDate__c = m_renewalDate.addYears(-1).addDays(-1);
                dataRow.PeriodStartDate__c = m_renewalDate.addYears(-2);
                m_pricingSumHistList.add(dataRow);
            }

            // LTD (Lifetime to Date)
            periodType = getPeriodType(0, false, false);
            dataRow = buildHistoryRowFromSummary(0, periodType);
            if(historyRowIsValid(dataRow))
            {
                dataRow.PeriodEndDate__c = Datetime.now().date();
                m_pricingSumHistList.add(dataRow);
            }

            // SAVE LIST TO DB
            m_clientPricingScenario.projectionFactor__c = m_projectionFactor;
            Database.upsert(m_clientPricingScenario);

            Database.SaveResult[] srList = Database.insert(m_pricingSumHistList, false);
            result = Log.writeIfError(Log.Severity.ERROR, 'Pricing', 'Insert Sum History List Failed', null, srList);

            // Run Recalculate before exiting
            PricingSummaryService pricingSrvc = new PricingSummaryService(m_clientPricingScenario.Id, true);
            pricingSrvc.Recalculate();
        }
        catch (Exception e) {
            Log.error('Pricing', 'PricingSummaryBuilder.getResult() Failure', null, e);
            throw new RenewalException('Pricing Summary Builder encountered an unexpected error');
        }

        return result;
    }

    // Pass in 0 for Lifetime to Date (LTD)
    public PricingSummaryHistory__c buildHistoryRow(Integer year, Boolean isProjected, Boolean isFuture, String periodType)
    {
        Double annualHours = 0;
        Integer minLTDyear = 0;

        PricingSummaryHistory__c newHistoryRow = new PricingSummaryHistory__c();
        try
        {
            newHistoryRow.ClientPricingScenario__c = m_clientPricingScenario.Id;

            newHistoryRow.Xmod__c = getXmod(year, isFuture);
            newHistoryRow.HeadcountAnnual__c = 0;
            newHistoryRow.Headcount__c = 0;
            newHistoryRow.PeriodEndDate__c = date19800101;    // init with a very OLD date
            newHistoryRow.PeriodStartDate__c = Date.today();  // init with a very NEW date

            newHistoryRow.YendBilling__c = 0;
            newHistoryRow.YendBillingAdjustments__c = 0;
            newHistoryRow.YendPayroll__c = 0;
            newHistoryRow.PremiumBasedPayroll__c = 0;
            newHistoryRow.YendPayrollTaxable__c = 0;
            newHistoryRow.YendPayrollTaxableNoOwner__c = 0;
            newHistoryRow.YendErTaxes__c = 0;
            newHistoryRow.YendErTaxesNoOwner__c = 0;
            newHistoryRow.YendWcPrem__c = 0;

            for(PayrollHistoryData.PayrollItem item : m_pricingSummaryData.PayrollHistory.Payroll){
                if(year == 0 || Integer.valueOf(item.Year) == year)
                {
                    if(item.Active == 'A')
                    {
                        newHistoryRow.Headcount__c += 1;
                    }
                    newHistoryRow.HeadcountAnnual__c += 1;
                    annualHours += (isProjected && item.Active == 'A') ? m_projectionFactor * item.TotalHoursWorked : item.TotalHoursWorked;

                    //TODO need to get min/max date over ALL rows in the loop. not just the last row...
                    newHistoryRow.PeriodEndDate__c = Date_Service.maxDate(Date.valueOf(item.MaxDate), newHistoryRow.PeriodEndDate__c);
                    if(Date.valueOf(item.MinDate) < newHistoryRow.PeriodStartDate__c)
                    {
                        newHistoryRow.PeriodStartDate__c = Date.valueOf(item.MinDate);
                        minLTDyear = newHistoryRow.PeriodStartDate__c.year();
                    }
                    newHistoryRow.PeriodType__c = periodType;

                    newHistoryRow.YendBilling__c += (isProjected && item.Active == 'A') ? m_projectionFactor * item.TotalBillAmt : item.TotalBillAmt;
                    newHistoryRow.YendPayroll__c += (isProjected && item.Active == 'A') ? m_projectionFactor * item.TotalPayAmt : item.TotalPayAmt;
                    newHistoryRow.PremiumBasedPayroll__c += (isProjected && item.Active == 'A') ? m_projectionFactor * item.TotalPremPayAmt : item.TotalPremPayAmt;
                    newHistoryRow.YendPayrollTaxable__c += (isProjected && item.Active == 'A') ? m_projectionFactor * item.TotalTaxablePayAmt : item.TotalTaxablePayAmt;
                    newHistoryRow.YendErTaxes__c += (isProjected && item.Active == 'A') ? m_projectionFactor * item.TotalErTaxes : item.TotalErTaxes;
                    newHistoryRow.YendWcPrem__c += (isProjected && item.Active == 'A') ? m_projectionFactor * item.TotalWcPremiums : item.TotalWcPremiums;
                    newHistoryRow.YendExpenses__c = 0;
                    if(item.IsOwner == 0)
                    {
                        newHistoryRow.YendErTaxesNoOwner__c += (isProjected && item.Active == 'A') ? m_projectionFactor * item.TotalErTaxes : item.TotalErTaxes;
                        newHistoryRow.YendPayrollTaxableNoOwner__c += (isProjected && item.Active == 'A') ? m_projectionFactor * item.TotalTaxablePayAmt : item.TotalTaxablePayAmt;
                    }
                }
            }
            if (newHistoryRow.HeadcountAnnual__c == 0)
            {
                // then no Payroll, so no need to continue
                return newHistoryRow;
            }
            // Add Billing Adjustments
            if (periodType == PricingSummaryService.MARGIN_HIST_CURRENT_YTD || periodType == PricingSummaryService.MARGIN_HIST_CURRENT_PROJ)
            {
                newHistoryRow.YendBillingAdjustments__c = getBillAdjustmentForYear(year);
            }

            // Calculate FTE (Full Time Equivalent employees)
            if (periodType != PricingSummaryService.MARGIN_HIST_LTD)
            {
                newHistoryRow.FTE__c = ((Decimal)annualHours / PricingSummaryService.ANNUAL_FTE_HOURS).setScale(1);
            }
            else
            {
                newHistoryRow.FTE__c = 0;
            }

            setCommonValues(newHistoryRow, year, minLTDyear);

            // Finally, if this is the Future row, apply some special handling...
            if (isProjected && isFuture)
            {
                // push the Margin estimate down to the WC codes
                ApplyMarginToWcCodes(newHistoryRow.YendMargin__c, newHistoryRow.YendPayrollTaxable__c, newHistoryRow.Xmod__c);

                // recalculate the Billing
                newHistoryRow.YendBilling__c =  newHistoryRow.YendPayroll__c + newHistoryRow.YendWcPrem__c +
                                                newHistoryRow.YendComms__c + newHistoryRow.YendCommsBdm__c + newHistoryRow.YendErTaxes__c +
                                                newHistoryRow.YendExpenses__c + newHistoryRow.YendMargin__c;
            }
        }
        catch (Exception e) {
            Log.error('Pricing', 'PricingSummaryBuilder.buildHistoryRow Failure', 'EXCEPTION IGNORED', e);
        }

        return newHistoryRow;
    }

    private void applyMarginToWcCodes(Decimal totMargin, Decimal totTaxablePayroll, Decimal xmod)
    {
        List<PricingWcCode__c> wcCodes = [
                SELECT Id, WC_Code__c, DesiredMarginDollars__c,
                        AnnualPayInCode__c, AnnualPremPayInCode__c, AnnualTaxablePayInCode__c,
                        EstimatedErTaxInCode__c,
                        PercentOfPayroll__c, WcPremiumEquivalent__c, WcPremiumBlended__c, WC_Rate__c
                FROM PricingWcCode__c
                WHERE ClientPricingScenario__c = : m_clientPricingScenario.Id];

        // calculate *Percent* of Payroll and WC Premium Equivalent for each WC Code
        for(PricingWcCode__c item : wcCodes){
            item.PercentOfPayroll__c = (100 * item.AnnualTaxablePayInCode__c / totTaxablePayroll).setScale(2);
            item.WcPremiumEquivalent__c = (item.AnnualTaxablePayInCode__c * xmod * item.WC_Rate__c / 100).setScale(2);
        }

        for(PricingWcCode__c item : wcCodes){
            item.DesiredMarginDollars__c = (item.AnnualTaxablePayInCode__c != 0) ? (totMargin * item.PercentOfPayroll__c / 100).setScale(2) : 0;
        }

        Database.update(wcCodes, false);
    }

    // Pass in 0 for Lifetime to Date (LTD)
    private PricingSummaryHistory__c buildHistoryRowFromSummary(Integer year, String periodType)
    {
        Integer minLTDyear = 0;
        PricingSummaryHistory__c newHistoryRow = new PricingSummaryHistory__c();
        newHistoryRow.ClientPricingScenario__c = m_clientPricingScenario.Id;
        newHistoryRow.Xmod__c = 1;                                      //TODO: REMOVE FIELD FROM THE SOBJECT
        newHistoryRow.HeadcountAnnual__c = 0;
        newHistoryRow.Headcount__c = 0;
        newHistoryRow.PeriodEndDate__c = date19800101;    // init with a very OLD date
        newHistoryRow.PeriodStartDate__c = Date.today();  // init with a very NEW date
        newHistoryRow.YendBilling__c = 0;
        newHistoryRow.YendBillingAdjustments__c = 0;
        newHistoryRow.YendPayroll__c = 0;
        newHistoryRow.PremiumBasedPayroll__c = 0;
        newHistoryRow.YendPayrollTaxable__c = 0;
        newHistoryRow.YendPayrollTaxableNoOwner__c =  0;
        newHistoryRow.YendErTaxes__c = 0;
        newHistoryRow.YendErTaxesNoOwner__c = 0;
        newHistoryRow.YendWcPrem__c = 0;
        newHistoryRow.FTE__c = 0;
        newHistoryRow.YendExpenses__c = 0;
        newHistoryRow.PeriodType__c = periodType;

        for(PayrollHistoryDataSum.DataItem dItem :m_pricingSummaryData.PayrollHistorySum.Data){
            if( (Integer.valueOf(dItem.Year) == year) || (year == 0) )
            {
                newHistoryRow.PeriodEndDate__c = Date_Service.maxDate(Date.valueOf(dItem.MaxDate), newHistoryRow.PeriodEndDate__c);
                newHistoryRow.PeriodStartDate__c = Date_Service.minDate(Date.valueOf(dItem.MinDate), newHistoryRow.PeriodStartDate__c);
                minLTDyear = newHistoryRow.PeriodStartDate__c.year();

                newHistoryRow.YendBilling__c += dItem.BillAmt;
                newHistoryRow.YendBillingAdjustments__c += dItem.BillAdj;
                newHistoryRow.YendPayroll__c += dItem.PayAmt;
                newHistoryRow.PremiumBasedPayroll__c += dItem.PremPayAmt;
                newHistoryRow.YendPayrollTaxable__c += dItem.TaxablePayAmt;
                newHistoryRow.YendErTaxes__c += dItem.ErTaxes;
                newHistoryRow.YendWcPrem__c += dItem.WcPremiums;

                if (Integer.valueOf(year) > 0)
                {
                    newHistoryRow.FTE__c = ((Decimal)dItem.HoursWorked / PricingSummaryService.ANNUAL_FTE_HOURS).setScale(1);
                }
            }
        }

        setCommonValues(newHistoryRow, year, minLTDyear);

        return newHistoryRow;
    }

    private void setCommonValues(PricingSummaryHistory__c historyRow, Integer year, Integer minLTDyear)
    {
        historyRow.YendMaxSI__c = 0.0;
        historyRow.TotalIncurred__c = 0.0;
        historyRow.UltimateExpected__c = 0.0;
        historyRow.TotalClaims__c = 0;
        // Loop through the data list because we may have same-year rows in *multiple states*

        for(RiskClaimsSiData.DataItem item : m_pricingSummaryData.RiskAndClaims.DataList) {
            if((year == 0 && Integer.valueOf(item.Year) >= minLTDyear) || Integer.valueOf(item.Year) == year) {
                historyRow.YendMaxSI__c += item.MaxSI;
                historyRow.TotalIncurred__c += item.TotalIncurred;
                historyRow.UltimateExpected__c += getUltimateExpectedAmount(item.TotalIncurred, Date.valueOf(item.PeriodStartDate), item.StateCode);
                historyRow.TotalClaims__c += item.TotalClaims;
            }
        }

        historyRow.YendComms__c = 0.0;
        historyRow.YendCommsBdm__c = 0.0;
        for(BdmAndCommissionData.DataItem item : m_pricingSummaryData.BdmAndComms.DataList) {
            if((year == 0 && Integer.valueOf(item.Year) >= minLTDyear) || Integer.valueOf(item.Year) == year) {
                historyRow.YendComms__c += item.CommAmt;
            }
        }

  // Estimate BDM commission (if we have a BDM)
        if (m_pricingSummaryData.BdmAndComms.HasBdm == 'TRUE')
        {
            Double bdmRate = GetDefaultBdmRate();
            // Calculate Margin after Commissions but *before* BDM commission (if any)
            historyRow.YendMargin__c = calculateEstimatedMargin(historyRow, bdmRate);

            if (historyRow.YendMargin__c > 0)
            {
                historyRow.YendCommsBdm__c =  bdmRate * historyRow.YendMargin__c;
            }
        }
        else
        {
            Double noBdmRate = 0;
            historyRow.YendMargin__c = calculateEstimatedMargin(historyRow, noBdmRate);
        }
    }

    public Boolean historyRowIsValid(PricingSummaryHistory__c histRow)
    {
        try {
            if (histRow.YendBilling__c > 0 && histRow.YendPayroll__c > 0) {
                return true;
            }
        }
        catch(Exception e)
        {
            System.debug(LoggingLevel.INFO, 'Summary history is not valid: ' + histRow + '\n' + e.getMessage());
        }

        return false;
    }

    private Double getProjectionFactor()
    {
        Integer daysDiff = Datetime.now().date().daysBetween(m_pricingSummaryData.EndDate);
        Decimal projFactor = daysDiff > 0 ? 1 + ((Double)daysDiff / 365.0) : 1;
        return projFactor.setScale(2);
    }

    private Double getBillAdjustmentForYear(Integer year)
    {
        Double billAdjustments = 0;

        for(PayrollHistoryDataSum.DataItem dItem : m_pricingSummaryData.PayrollHistorySum.Data){
            if (year == Integer.valueOf(dItem.Year))
            {
                billAdjustments += dItem.BillAdj;
            }
        }
        return billAdjustments;
    }

    public String getPeriodType(Integer year, Boolean isProjected, Boolean isFuture)
    {
        if (isProjected && !isFuture) { return PricingSummaryService.MARGIN_HIST_CURRENT_PROJ; }
        if (isFuture) { return PricingSummaryService.MARGIN_HIST_FUTURE; }
        if (!isProjected && !isFuture && year == 0){ return PricingSummaryService.MARGIN_HIST_LTD; }
        if (!isProjected && !isFuture && year == m_RenewalDateYear) { return PricingSummaryService.MARGIN_HIST_CURRENT_YTD; }
        if (!isProjected && !isFuture && year - m_RenewalDateYear == -1) { return PricingSummaryService.MARGIN_HIST_MINUS_1; }

        return '';
    }

    private Double calculateEstimatedMargin(PricingSummaryHistory__c dataRow, Double bdmCommissionRate)
    {
        Decimal bdmCommMarginAdjustment = 1 / (1 + bdmCommissionRate);
        Decimal billingAdjustments = 0;

        // The Renewal Year does not have Billing Adjustments, but we need Billing
        // Adjustments to calculate the Margin. So we get it from the current year
        if(dataRow.PeriodType__c == PricingSummaryService.MARGIN_HIST_FUTURE)
        {
            billingAdjustments = getBillAdjustmentForYear(m_RenewalDateYear);
        }
        else
        {
            billingAdjustments = dataRow.YendBillingAdjustments__c;
        }

        Decimal marginBeforeBdm = (dataRow.YendBilling__c + billingAdjustments) - (dataRow.YendWcPrem__c +
                                    dataRow.YendComms__c + dataRow.YendPayroll__c +
                                    dataRow.YendErTaxes__c + dataRow.YendExpenses__c);

        return (bdmCommMarginAdjustment * marginBeforeBdm).setScale(2);
    }

    private Double getXmod(Integer year, Boolean isFuture)
    {
        if (year == 0) { return 0;} // Xmod cannot apply to the LTD (lifetime) row

        Double tempXmod = 0;
        Date tempDate = date19800101;

        for(XmodHistoryData.XmodDetailItem item : m_pricingSummaryData.XmodHistory.XmodDetails){
            // get the latest Xmod for the year that we're processing. Except for 'future'; we just want the latest Xmod
            if(Integer.valueOf(item.Year) <= year || year > m_RenewalDateYear || isFuture)
            {
                if(Date.valueOf(item.ModifiedDate) > tempDate)
                {
                    tempDate = Date.valueOf(item.ModifiedDate);
                    tempXmod = item.Xmod;
                }
            }
        }
        return tempXmod;
    }

    private Double getUltimateExpectedAmount(Double Amount, Date PeriodStartDate, String StateCode)
    {
        // Calculate Ultimate values with LDF
        if(Amount == 0) return 0;

        Integer months = PeriodStartDate.monthsBetween(Date.today());
        Decimal ldfRate = LdfModel.getLdfRate(StateCode, months);
        return ldfRate * Amount;
    }

    public Double GetDefaultBdmRate()
    {
        Double bdmRate = 0;

        CommissionRate__mdt [] commRates = [SELECT BdmRate__c, RefPartnertRateWC__c FROM CommissionRate__mdt
                                            WHERE MasterLabel = 'Default Rates'];
        if(commRates.size() > 0)
        {
            bdmRate = commRates[0].BdmRate__c;
        }
        return bdmRate / 100;
    }
}