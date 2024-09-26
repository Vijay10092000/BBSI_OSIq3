/*
 * Copyright (c) 2018. Barrett Business Services, Inc. All Rights Reserved
 * Created by agoganian on 10/9/2018
 */
public without sharing class PrcMarginHistoryController
{
    @AuraEnabled
    public static PricingSummaryHistory__c[] getPricingSummaryHistoryRows(String recordId)
    {
        String[] periodTypes = new String[] {'Current YTD', 'Current-1', 'LTD'};
        PricingSummaryHistory__c[] results = [
                SELECT
                        BUHours3x__c,
                        BUHours5x__c,
                        ClientPricingScenario__c,
                        CreatedDate,
                        FTE__c,
                        Headcount__c,
                        HeadcountAnnual__c,
                        Id,
                        MarginPercent__c,
                        MarginPercentPayroll__c,
                        MarginPerHead__c,
                        MarkupPercentage__c,
                        Name,
                        PeriodEndDate__c,
                        PeriodStartDate__c,
                        PeriodType__c,
                        PremiumBasedPayroll__c,
                        PremiumBasedPayroll_base__c,
                        SortingFormula__c,
                        TotalClaims__c,
                        TotalIncurred__c,
                        Turnover__c,
                        UltimateExpected__c,
                        Xmod__c,
                        YendBilling__c,
                        YendBilling_base__c,
                        YendBillingAdjustments__c,
                        YendBillingNet__c,
                        YendCommissionPercent__c,
                        YendComms__c,
                        YendCommsBdm__c,
                        YendCommsTotal__c,
                        YendErTaxes__c,
                        YendErTaxes_base__c,
                        YendErTaxesNoOwner__c,
                        YendExpenses__c,
                        YendExpenses_Percent__c,
                        YendMargin__c,
                        YendMaxSI__c,
                        YendPayroll__c,
                        YendPayroll_base__c,
                        YendPayrollTaxable__c,
                        YendPayrollTaxable_base__c,
                        YendPayrollTaxableNoOwner__c,
                        YendTaxBurden_Percent__c,
                        YendTaxBurden_PercentNo1k__c,
                        YendWcPrem__c,
                        YendWcPrem_base__c
                FROM PricingSummaryHistory__c
                WHERE ClientPricingScenario__c = :recordId
                AND PeriodType__c IN :periodTypes
                ORDER BY SortingFormula__c ASC
        ];

        for(PricingSummaryHistory__c x: results) {
            if(x.PeriodType__c == 'Current-1') {
                x.PeriodType__c = 'Prior Year';
                break;
            }
        }

        return results;
    }

    @AuraEnabled
    public static PricingSummaryHistory__c[] getPricingSummaryHistories(String recordId){
        PricingSummaryHistory__c[] results = [
                SELECT
                        BUHours3x__c,
                        BUHours5x__c,
                        ClientPricingScenario__c,
                        CreatedDate,
                        FTE__c,
                        Headcount__c,
                        HeadcountAnnual__c,
                        Id,
                        MarginPercent__c,
                        MarginPercentPayroll__c,
                        MarginPerHead__c,
                        MarkupPercentage__c,
                        Name,
                        PeriodEndDate__c,
                        PeriodStartDate__c,
                        PeriodType__c,
                        PremiumBasedPayroll__c,
                        PremiumBasedPayroll_base__c,
                        SortingFormula__c,
                        TotalClaims__c,
                        TotalIncurred__c,
                        Turnover__c,
                        UltimateExpected__c,
                        Xmod__c,
                        YendBilling__c,
                        YendBilling_base__c,
                        YendBillingAdjustments__c,
                        YendBillingNet__c,
                        YendCommissionPercent__c,
                        YendComms__c,
                        YendCommsBdm__c,
                        YendCommsTotal__c,
                        YendErTaxes__c,
                        YendErTaxes_base__c,
                        YendErTaxesNoOwner__c,
                        YendExpenses__c,
                        YendExpenses_Percent__c,
                        YendMargin__c,
                        YendMaxSI__c,
                        YendPayroll__c,
                        YendPayroll_base__c,
                        YendPayrollTaxable__c,
                        YendPayrollTaxable_base__c,
                        YendPayrollTaxableNoOwner__c,
                        YendTaxBurden_Percent__c,
                        YendTaxBurden_PercentNo1k__c,
                        YendWcPrem__c,
                        YendWcPrem_base__c
                FROM PricingSummaryHistory__c
                WHERE ClientPricingScenario__c = :recordId
                ORDER BY SortingFormula__c ASC
        ];

        for(PricingSummaryHistory__c x: results) {
            if(x.PeriodType__c == 'Current-1') {
                x.PeriodType__c = 'Prior Year';
                break;
            }
        }

        return results;
    }

    @AuraEnabled
    public static PricingSummaryHistory__c[] getPricingSummaryRows(String recordId){
        String[] periodTypes = new String[] {'Renewal Year', 'Current Projected'};
        PricingSummaryHistory__c[] results = [
                SELECT
                        Id,
                        PeriodType__c,
                        Xmod__c,
                        MarginPercent__c,
                        MarginPercentPayroll__c,
                        MarginPerHead__c,
                        MarkupPercentage__c,
                        FTE__c,
                        Turnover__c,
                        PeriodEndDate__c,
                        PeriodStartDate__c,
                        YendMargin__c
                FROM PricingSummaryHistory__c
                WHERE ClientPricingScenario__c = :recordId
                AND PeriodType__c IN :periodTypes
                ORDER BY SortingFormula__c ASC
        ];

        return results;
    }

    @AuraEnabled
    public static PricingSummaryHistory__c getPricingSummaryRenewalRow(String recordId){
        String periodType = 'Renewal Year';
        PricingSummaryHistory__c[] results = [
                SELECT
                        BUHours3x__c,
                        BUHours5x__c,
                        ClientPricingScenario__c,
                        CreatedDate,
                        FTE__c,
                        Headcount__c,
                        HeadcountAnnual__c,
                        Id,
                        MarginPercent__c,
                        MarginPercentPayroll__c,
                        MarginPerHead__c,
                        MarkupPercentage__c,
                        Name,
                        PeriodEndDate__c,
                        PeriodStartDate__c,
                        PeriodType__c,
                        PremiumBasedPayroll__c,
                        PremiumBasedPayroll_base__c,
                        SortingFormula__c,
                        TotalClaims__c,
                        TotalIncurred__c,
                        Turnover__c,
                        UltimateExpected__c,
                        Xmod__c,
                        YendBilling__c,
                        YendBilling_base__c,
                        YendBillingAdjustments__c,
                        YendBillingNet__c,
                        YendCommissionPercent__c,
                        YendComms__c,
                        YendCommsBdm__c,
                        YendCommsTotal__c,
                        YendErTaxes__c,
                        YendErTaxes_base__c,
                        YendErTaxesNoOwner__c,
                        YendExpenses__c,
                        YendExpenses_Percent__c,
                        YendMargin__c,
                        YendMaxSI__c,
                        YendPayroll__c,
                        YendPayroll_base__c,
                        YendPayrollTaxable__c,
                        YendPayrollTaxable_base__c,
                        YendPayrollTaxableNoOwner__c,
                        YendTaxBurden_Percent__c,
                        YendTaxBurden_PercentNo1k__c,
                        YendWcPrem__c,
                        YendWcPrem_base__c
                FROM PricingSummaryHistory__c
                WHERE ClientPricingScenario__c = :recordId
                AND PeriodType__c = :periodType
                ORDER BY SortingFormula__c ASC
        ];

        if(results.size() < 1){
            return null;
        }

        return results[0];
    }

    @AuraEnabled
    public static void savePricingSummaryRenewalRow(PricingSummaryHistory__c pricingSummary)
    {
        Database.SaveResult sr = Database.update(pricingSummary, false);
        if (!sr.isSuccess()){
            System.debug('Save Pricing Summary Errors: ' + sr.getErrors());
        }
    }
}