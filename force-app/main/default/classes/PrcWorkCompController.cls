/*
 * Copyright (c) 2018. Barrett Business Services, Inc. All Rights Reserved
 * Created by agoganian on 10/17/2018.
 */
public without sharing class PrcWorkCompController
{
    @AuraEnabled
    public static PricingWcCode__c[] getPricingWcCodes(String recordId)
    {
        PricingWcCode__c[] results = [
            SELECT  AnnualHoursInCode__c, AnnualPayInCode__c, AnnualPremPayInCode__c, AnnualTaxablePayInCode__c,
                    ClientPricingScenario__c, ClientPricingScenario__r.ClientId__c, ClientPricingScenario__r.ClientName__c,
			        DesiredMargin__c, DesiredMarginDollars__c, EstimatedErTaxInCode__c, FTEInCode__c, 
                    HrpWcSuffix__c, Id, Include__c, MarginPerHeadInCode__c,
                    Markup__c, Markup_OverTime__c, Markup_DoubleTime__c, Markup_Blended__c, MarkupNo1k__c,
                    Modified_WC_Rate__c, Name, PercentOfPayroll__c, Pricing_Group__c,
                    SI_Max__c, SI_Max_Blended__c, SI_Percent_of_Payroll__c, SI_Percent_of_Premium__c,
                    SIEligible__c, State_Code__c, TaxBurdenPercentInCode__c, WC_Code__c, WC_Rate__c, 
                    WcPremiumEquivalent__c, WcPremiumBlended__c, WCPremPercentOfPayroll__c, WcPremiumBlendedPercentOfPayroll__c,
                    (
                        SELECT Id, AnnualHoursInCode__c, AnnualHoursInCode_base__c,
                        AnnualPayInCode__c, AnnualPayInCode_base__c,
                        AnnualPremPayInCode__c, AnnualPremPayInCode_base__c,
                        AnnualTaxablePayInCode__c, AnnualTaxablePayInCode_base__c,
                        EstimatedErTaxInCode__c, PricingWcCode__c, Pricing_Employee__c
                        FROM PricingEEtoWcCodeAssocs__r
                    )
            FROM PricingWcCode__c
            WHERE ClientPricingScenario__c = :recordId
            ORDER BY CreatedDate
        ];
        return results;
    }

    @AuraEnabled
    public static PricingWcCode__c[] getPricingWcCodesWithPayroll(String recordId)
    {
        PricingWcCode__c[] results = [
            SELECT  AnnualHoursInCode__c, AnnualPayInCode__c, AnnualPremPayInCode__c, AnnualTaxablePayInCode__c,
                    ClientPricingScenario__c, ClientPricingScenario__r.ClientId__c, ClientPricingScenario__r.ClientName__c,
                    DesiredMargin__c, DesiredMarginDollars__c, EstimatedErTaxInCode__c, FTEInCode__c, 
                    HrpWcSuffix__c, Id, Include__c, MarginPerHeadInCode__c,
                    Markup__c, Markup_OverTime__c, Markup_DoubleTime__c, Markup_Blended__c, MarkupNo1k__c,
                    Modified_WC_Rate__c, Name, PercentOfPayroll__c, Pricing_Group__c,
                    SI_Max__c, SI_Max_Blended__c, SI_Percent_of_Payroll__c, SI_Percent_of_Premium__c,
                    SIEligible__c, State_Code__c, TaxBurdenPercentInCode__c, WC_Code__c, WC_Rate__c, 
                    WcPremiumEquivalent__c, WcPremiumBlended__c, WCPremPercentOfPayroll__c, WcPremiumBlendedPercentOfPayroll__c,
                    (
                        SELECT Id, AnnualHoursInCode__c, AnnualHoursInCode_base__c,
                        AnnualPayInCode__c, AnnualPayInCode_base__c,
                        AnnualPremPayInCode__c, AnnualPremPayInCode_base__c,
                        AnnualTaxablePayInCode__c, AnnualTaxablePayInCode_base__c,
                        EstimatedErTaxInCode__c, PricingWcCode__c, Pricing_Employee__c
                        FROM PricingEEtoWcCodeAssocs__r
                    )
            FROM PricingWcCode__c
            WHERE ClientPricingScenario__c = :recordId AND AnnualTaxablePayInCode__c != 0
		    ORDER BY CreatedDate
		];
        return results;
    }

    @AuraEnabled
    public static PricingWcCode__c[] getPricingWcCodesWithPayrollAndIncludeFlag(String recordId)
    {
        PricingWcCode__c[] results = [
            SELECT  AnnualHoursInCode__c, AnnualPayInCode__c, AnnualPremPayInCode__c, AnnualTaxablePayInCode__c,
                    ClientPricingScenario__c, ClientPricingScenario__r.ClientId__c, ClientPricingScenario__r.ClientName__c,
                    DesiredMargin__c, DesiredMarginDollars__c, EstimatedErTaxInCode__c, FTEInCode__c, 
                    HrpWcSuffix__c, Id, Include__c, MarginPerHeadInCode__c,
                    Markup__c, Markup_OverTime__c, Markup_DoubleTime__c, Markup_Blended__c, MarkupNo1k__c,
                    Modified_WC_Rate__c, Name, PercentOfPayroll__c, Pricing_Group__c,
                    SI_Max__c, SI_Max_Blended__c, SI_Percent_of_Payroll__c, SI_Percent_of_Premium__c,
                    SIEligible__c, State_Code__c, TaxBurdenPercentInCode__c, WC_Code__c, WC_Rate__c, 
                    WcPremiumEquivalent__c, WcPremiumBlended__c, WCPremPercentOfPayroll__c, WcPremiumBlendedPercentOfPayroll__c,
                    (
                        SELECT Id, AnnualHoursInCode__c, AnnualHoursInCode_base__c,
                        AnnualPayInCode__c, AnnualPayInCode_base__c,
                        AnnualPremPayInCode__c, AnnualPremPayInCode_base__c,
                        AnnualTaxablePayInCode__c, AnnualTaxablePayInCode_base__c,
                        EstimatedErTaxInCode__c, PricingWcCode__c, Pricing_Employee__c
                        FROM PricingEEtoWcCodeAssocs__r
                    )
            FROM PricingWcCode__c
            WHERE ClientPricingScenario__c =: recordId AND (AnnualTaxablePayInCode__c != 0 OR Include__c = true)
		    ORDER BY CreatedDate
		];
        return results;
    }

    @AuraEnabled
    public static void resetWorkCompPremium(String recordId)
    {
        PricingWcCode__c[] wcCodes = PrcWorkCompController.getPricingWcCodes(recordId);
        for (PricingWcCode__c wcCode : wcCodes) {
            if (wcCode.AnnualTaxablePayInCode__c == 0) {
                wcCode.WcPremiumEquivalent__c = 0;
            }
        }

        PrcWorkCompController.savePricingWcCodes(wcCodes);
    }

    @AuraEnabled
    public static void savePricingWcCodes(PricingWcCode__c[] wcCodes)
    {
        Database.SaveResult[] srList = Database.update(wcCodes, false);
        Database.SaveResult[] errorList = new List<Database.SaveResult>();

        for(Database.SaveResult sr :srList){
            if (!sr.isSuccess()){
                errorList.add(sr);
            }
        }
        if(errorList.size() > 0){
            System.debug('Save Pricing WC Codes Errors: ' + errorList);
        }
    }

    @AuraEnabled
    public static void deleteWorkComp(PricingWcCode__c wc)
    {
        Database.DeleteResult dbResult = Database.delete(wc);
        if (!dbResult.isSuccess()){
            System.debug('Delete WC Item Errors: ' + dbResult.getErrors());
        }
    }

    @AuraEnabled
    public static WorkCompPolicyAccount__c[] getWorkCompPolicyAccounts(String policyNumber)
    {
        WorkCompPolicyAccount__c[] results = [
                SELECT Client__r.External_ID__c
                FROM WorkCompPolicyAccount__c
                WHERE Work_Comp_Policy__r.External_ID__c = :policyNumber];

        return results;
    }

    @AuraEnabled
    public static void transferAndDeletePricingWcCode(PricingWcCode__c source, PricingWcCode__c target)
    {
        Map<String, PricingEmployee__c> employees = new Map<String, PricingEmployee__c>();
        PricingEEtoWcCodeAssoc__c[] associations = PrcEmployeesController.getEEtoWcCodeAssociationsByCode(source);
        for(PricingEEtoWcCodeAssoc__c assoc : associations) {
            assoc.PricingWcCode__c = target.Id;
            if (assoc.Pricing_Employee__r.PrimaryPricingWcCode__c == source.Id &&
                    !employees.containsKey(assoc.Pricing_Employee__r.Id)) {
                assoc.Pricing_Employee__r.PrimaryPricingWcCode__c = target.Id;
                assoc.Pricing_Employee__r.Primary_WC_Code__c = target.WC_Code__c;
                assoc.Pricing_Employee__r.State_Code__c = target.State_Code__c;
                employees.put(assoc.Pricing_Employee__r.Id, assoc.Pricing_Employee__r);
            }
        }

        PrcEmployeesController.saveAssocList(associations);
        PrcEmployeesController.saveEmployees(employees.values());
        PrcWorkCompController.deleteWorkComp(source);
        PrcWorkCompController.resetWorkCompPremium(source.ClientPricingScenario__c);
    }

    @AuraEnabled
    public static List<PricingTemplateWcCode__c> getPricingTemplateWcCodes(String recordId)
    {
        // Get the list of renewal XMOD states
        List<String> states = new List<String>();
        for (PricingXmod__c xm : PrcXmodController.getRenewalYearXmods(recordId)) {
            states.add(xm.State_Code__c);
        }

        // Get the list of templates filtered by the renewal XMOD states
        List<PricingTemplateWcCode__c> templates = [
                SELECT Name, State_Code__c, WC_Code__c, WC_Rate__c, WC_Description__c
                FROM PricingTemplateWcCode__c
                WHERE ClientPricingScenario__c =: recordId AND State_Code__c IN :states
                ORDER BY State_Code__c, WC_Code__c
        ];
        return templates;
    }

    @AuraEnabled
    public static void addPricingWcCode(String recordId, String state, String code, Decimal rate, Boolean siEligible)
    {
        // Find the renewal XMOD for the state - used to calculate Modified_WC_Rate
        Decimal stateXmod = 0.0;
        for (PricingXmod__c xm : PrcXmodController.getRenewalYearXmods(recordId)) {
            if (xm.State_Code__c == state) {
                stateXmod = xm.Xmod__c;
            }
        }

        // Throw exception when adding an existing Work Comp
        for (PricingWcCode__c pricingWcCode : PrcWorkCompController.getPricingWcCodes(recordId)) {
            if (pricingWcCode.State_Code__c == state && pricingWcCode.WC_Code__c == code) {
                throw new RenewalException('Error: Add an existing work comp');
            }
        }

        // Create new Work Comp per given parameters
        PricingWcCode__c newWc = new PricingWcCode__c(
                ClientPricingScenario__c = recordId,
                DesiredMargin__c = 3,
                DesiredMarginDollars__c = 0,
                HrpWcSuffix__c = '',
                Markup__c = 0,
                Markup_OverTime__c = 0,
                Markup_DoubleTime__c = 0,
                Markup_Blended__c = 0,
                Modified_WC_Rate__c = stateXmod * rate,
                Name = code + ' ' + state,
                Pricing_Group__c = '',
                SIEligible__c = siEligible,
                SI_Percent_of_Premium__c = 0,
                SI_Percent_of_Payroll__c = 0,
                State_Code__c = state,
                WC_Code__c = code,
                WC_Rate__c = rate,
                WcPremiumEquivalent__c = 0 // WC Premium = Modified_WC_Rate * AnnualTaxablePayInCode__c ($0) = $0
        );

        // Calculate default SI rates per latest user story #13059
        Decimal percentMin = 0.75;
        Decimal percentMax = 4;
        Decimal percentOfPremium = 25;
        Decimal percentOfPayroll = newWc.Modified_WC_Rate__c * percentOfPremium / 100;

        if (!siEligible || percentOfPayroll < percentMin) {
            percentOfPayroll = 0;
            percentOfPremium = 0;
        } else if ( percentOfPayroll > percentMax) {
            percentOfPayroll = percentMax;
            percentOfPremium = percentOfPayroll * 100 / newWc.Modified_WC_Rate__c;
        }
        newWc.SI_Percent_of_Payroll__c = percentOfPayroll;
        newWc.SI_Percent_of_Premium__c = percentOfPremium;

        Database.SaveResult saveResult = Database.insert(newWc);
        if(!saveResult.isSuccess()) {
            System.debug('Error: Add new Pricing WC Code error: ' + saveResult);
        }
    }
}