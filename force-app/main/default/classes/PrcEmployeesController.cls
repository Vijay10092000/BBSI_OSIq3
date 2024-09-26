/*
 * Copyright (c) 2018. Barrett Business Services, Inc. All Rights Reserved
 */
public without sharing class PrcEmployeesController
{
    @AuraEnabled
    public static PricingEEtoWcCodeAssoc__c[] getEEtoWcCodeAssocs(String recordId)
    {
        PricingEEtoWcCodeAssoc__c[] results =
        [
                SELECT  Id, AnnualHoursInCode__c, AnnualHoursInCode_base__c,
                        AnnualPayInCode__c, AnnualPayInCode_base__c, AnnualPayUnit__c,
                        AnnualPremPayInCode__c, AnnualPremPayInCode_base__c,
                        AnnualTaxablePayInCode__c, AnnualTaxablePayInCode_base__c,
                        PricingWcCode__c, EstimatedErTaxInCode__c,

                        Pricing_Employee__r.AnnualHours__c, Pricing_Employee__r.AnnualPay__c,
                        Pricing_Employee__r.AnnualPremPay__c, Pricing_Employee__r.AnnualTaxablePay__c,
                        Pricing_Employee__r.ClientPricingScenario__c, Pricing_Employee__r.CreatedDate,
                        Pricing_Employee__r.Employee_Name__c, Pricing_Employee__r.EstimatedERTax__c,
                        Pricing_Employee__r.HourlyRate__c, Pricing_Employee__r.Id,
                        Pricing_Employee__r.IsActive__c, Pricing_Employee__r.IsOwner__c, Pricing_Employee__r.IsUpdate__c,
                        Pricing_Employee__r.LastModifiedDate, Pricing_Employee__r.Margin_Goal__c,
                        Pricing_Employee__r.Name, Pricing_Employee__r.Pricing_Group__c,
                        Pricing_Employee__r.Primary_WC_Code__c, Pricing_Employee__r.PrimaryPricingWcCode__c,
                        Pricing_Employee__r.Qty__c, Pricing_Employee__r.State__c,
                        Pricing_Employee__r.State_Code__c, Pricing_Employee__r.WcCodeCount__c,

                        PricingWcCode__r.AnnualHoursInCode__c, PricingWcCode__r.AnnualPayInCode__c,
                        PricingWcCode__r.AnnualPremPayInCode__c, PricingWcCode__r.AnnualTaxablePayInCode__c,
                        PricingWcCode__r.ClientPricingScenario__c, PricingWcCode__r.DesiredMargin__c,
                        PricingWcCode__r.DesiredMarginDollars__c, PricingWcCode__r.EstimatedErTaxInCode__c,
                        PricingWcCode__r.HrpWcSuffix__c, PricingWcCode__r.Id,
                        PricingWcCode__r.Markup__c, PricingWcCode__r.Markup_OverTime__c, PricingWcCode__r.Markup_DoubleTime__c,
                        PricingWcCode__r.Markup_Blended__c, PricingWcCode__r.MarkupNo1k__c, PricingWcCode__r.Modified_WC_Rate__c,
                        PricingWcCode__r.Name, PricingWcCode__r.PercentOfPayroll__c,
                        PricingWcCode__r.Pricing_Group__c, PricingWcCode__r.SI_Max__c, PricingWcCode__r.SI_Max_Blended__c,
                        PricingWcCode__r.SI_Percent_of_Payroll__c, PricingWcCode__r.SI_Percent_of_Premium__c,
                        PricingWcCode__r.SIEligible__c, PricingWcCode__r.State_Code__c,
                        PricingWcCode__r.TaxBurdenPercentInCode__c,
                        PricingWcCode__r.WC_Code__c, PricingWcCode__r.WC_Rate__c,
                        PricingWcCode__r.WcPremiumEquivalent__c, PricingWcCode__r.WCPremPercentOfPayroll__c,
                        PricingWcCode__r.WcPremiumBlended__c, PricingWcCode__r.WcPremiumBlendedPercentOfPayroll__c
                FROM PricingEEtoWcCodeAssoc__c
                WHERE Pricing_Employee__r.ClientPricingScenario__c = :recordId
        ];

        return results;
    }


    @AuraEnabled
    public static PricingEEtoWcCodeAssoc__c[] getEEtoWcCodeAssociationsByCode(PricingWcCode__c wcCode)
    {
        PricingEEtoWcCodeAssoc__c[] results =
        [
                SELECT  Id, AnnualHoursInCode__c, AnnualHoursInCode_base__c,
                        AnnualPayInCode__c, AnnualPayInCode_base__c, AnnualPayUnit__c,
                        AnnualPremPayInCode__c, AnnualPremPayInCode_base__c,
                        AnnualTaxablePayInCode__c, AnnualTaxablePayInCode_base__c,
                        PricingWcCode__c, EstimatedErTaxInCode__c,

                        Pricing_Employee__r.AnnualHours__c, Pricing_Employee__r.AnnualPay__c,
                        Pricing_Employee__r.AnnualPremPay__c, Pricing_Employee__r.AnnualTaxablePay__c,
                        Pricing_Employee__r.ClientPricingScenario__c, Pricing_Employee__r.CreatedDate,
                        Pricing_Employee__r.Employee_Name__c, Pricing_Employee__r.EstimatedERTax__c,
                        Pricing_Employee__r.HourlyRate__c, Pricing_Employee__r.Id,
                        Pricing_Employee__r.IsActive__c, Pricing_Employee__r.IsOwner__c, Pricing_Employee__r.IsUpdate__c,
                        Pricing_Employee__r.LastModifiedDate, Pricing_Employee__r.Margin_Goal__c,
                        Pricing_Employee__r.Name, Pricing_Employee__r.Pricing_Group__c,
                        Pricing_Employee__r.Primary_WC_Code__c, Pricing_Employee__r.PrimaryPricingWcCode__c,
                        Pricing_Employee__r.PrimaryPricingWcCode__r.Id,
                        Pricing_Employee__r.Qty__c, Pricing_Employee__r.State__c,
                        Pricing_Employee__r.State_Code__c, Pricing_Employee__r.WcCodeCount__c,

                        PricingWcCode__r.AnnualHoursInCode__c, PricingWcCode__r.AnnualPayInCode__c,
                        PricingWcCode__r.AnnualPremPayInCode__c, PricingWcCode__r.AnnualTaxablePayInCode__c,
                        PricingWcCode__r.ClientPricingScenario__c, PricingWcCode__r.DesiredMargin__c,
                        PricingWcCode__r.DesiredMarginDollars__c,
                        PricingWcCode__r.EstimatedErTaxInCode__c,
                        PricingWcCode__r.HrpWcSuffix__c, PricingWcCode__r.Id,
                        PricingWcCode__r.Markup__c, PricingWcCode__r.Markup_OverTime__c, PricingWcCode__r.Markup_DoubleTime__c,
                        PricingWcCode__r.Markup_Blended__c, PricingWcCode__r.MarkupNo1k__c, PricingWcCode__r.Modified_WC_Rate__c,
                        PricingWcCode__r.Name, PricingWcCode__r.PercentOfPayroll__c,
                        PricingWcCode__r.Pricing_Group__c, PricingWcCode__r.SI_Max__c, PricingWcCode__r.SI_Max_Blended__c,
                        PricingWcCode__r.SI_Percent_of_Payroll__c, PricingWcCode__r.SI_Percent_of_Premium__c,
                        PricingWcCode__r.SIEligible__c, PricingWcCode__r.State_Code__c,
                        PricingWcCode__r.TaxBurdenPercentInCode__c,
                        PricingWcCode__r.WC_Code__c, PricingWcCode__r.WC_Rate__c,
                        PricingWcCode__r.WcPremiumEquivalent__c, PricingWcCode__r.WCPremPercentOfPayroll__c,
                        PricingWcCode__r.WcPremiumBlended__c, PricingWcCode__r.WcPremiumBlendedPercentOfPayroll__c

                FROM PricingEEtoWcCodeAssoc__c
                WHERE PricingWcCode__c =: wcCode.Id
        ];

        return  results;
    }

    @AuraEnabled
    public static PricingEmployee__c[] getPricingEmployees(String recordId)
    {
        PricingEmployee__c[] results = [
                SELECT
                        AnnualHours__c,
                        AnnualPay__c,
                        AnnualPremPay__c,
                        AnnualTaxablePay__c,
                        ClientPricingScenario__c,
                        ClientPricingScenario__r.projectionFactor__c,
                        CreatedDate,
                        Employee_Name__c,
                        EstimatedERTax__c,
                        HourlyRate__c,
                        Id,
                        IsActive__c,
                        IsDeleted,
                        IsOwner__c,
                        IsUpdate__c,
                        LastModifiedDate,
                        Margin_Goal__c,
                        Name,
                        Pricing_Group__c,
                        Primary_WC_Code__c,
                        PrimaryPricingWcCode__c,
                        Qty__c,
                        State__c,
                        State_Code__c,
                        WcCodeCount__c,
                (SELECT Id, AnnualHoursInCode__c, AnnualHoursInCode_base__c,
                        AnnualPayInCode__c, AnnualPayInCode_base__c,
                        AnnualPremPayInCode__c, AnnualPremPayInCode_base__c,
                        AnnualTaxablePayInCode__c, AnnualTaxablePayInCode_base__c,
                        EstimatedErTaxInCode__c,
                        PricingWcCode__c
                FROM PricingEEtoWcCodeAssocs__r)
                FROM PricingEmployee__c
                WHERE ClientPricingScenario__c = :recordId
                ORDER BY CreatedDate
        ];

        return results;
    }

    @AuraEnabled
    public static void saveEmployees(PricingEmployee__c[] eeList)
    {
        Database.SaveResult[] srList;
        Database.Error[] errList = new List<Database.Error>();

        srList = Database.update(eeList, false);
        for (Database.SaveResult sr : srList) {
            if (!sr.isSuccess()){
                errList.addAll(sr.getErrors());
            }
        }
        if(errList.size() > 0){
            System.debug('EE Error List: ' + errList);
        }
    }

    @AuraEnabled
    public static void saveAssocList(PricingEEtoWcCodeAssoc__c[] assocList)
    {
        Database.SaveResult[] srList;
        Database.Error[] errList = new List<Database.Error>();

        srList = Database.update(assocList, false);
        for (Database.SaveResult sr : srList) {
            if (!sr.isSuccess()){
                errList.addAll(sr.getErrors());
            }
        }
        if(errList.size() > 0){
            System.debug('EE Error List: ' + errList);
        }
    }

    @AuraEnabled
    public static void saveNonUpdateEmployees(PricingEmployee__c[] eeList)
    {
        List<Id> ids = new List<Id>();
        for (PricingEmployee__c e : eeList) {
            ids.add(e.Id);
        }

        List<PricingEmployee__c> employeesInfo = [
                SELECT Id, IsUpdate__c
                FROM PricingEmployee__c
                WHERE Id IN :ids
        ];

        Map<Id, PricingEmployee__c> employeesMap = new Map<Id, PricingEmployee__c>();
        for (PricingEmployee__c e : employeesInfo) {
            employeesMap.put(e.Id, e);
        }

        List<PricingEmployee__c> employees = new List<PricingEmployee__c>();
        for (PricingEmployee__c employee : eeList) {
            if (employeesMap.get(employee.Id).IsUpdate__c) {
                continue;
            }
            employees.add(employee);
            ids.add(employee.Id);
        }

        PrcEmployeesController.saveEmployees(employees);
    }

    @AuraEnabled
    public static void saveEmployeesAndHours(PricingEmployee__c[] eeList)
    {
        if(eeList == null || eeList.size() <= 0)
        {
            return;
        }

        PrcEmployeesController.saveNonUpdateEmployees(eeList);

        PricingEEtoWcCodeAssoc__c[] eeAssociations = new List<PricingEEtoWcCodeAssoc__c>();
        for(PricingEmployee__c employee : eeList)
        {
            if(employee.AnnualHours__c == null)
            {
                continue;
            }

            PricingEEtoWcCodeAssoc__c[] associations = [
                    SELECT  Id, AnnualHoursInCode__c, AnnualHoursInCode_base__c, AnnualPayInCode__c,
                            Pricing_Employee__r.AnnualHours__c,
                            PricingWcCode__r.AnnualHoursInCode__c
                    FROM PricingEEtoWcCodeAssoc__c
                    WHERE Pricing_Employee__c =: employee.Id];

            PricingEmployee__c empTemp = [
                    SELECT ClientPricingScenario__r.projectionFactor__c, Qty__c
                    FROM PricingEmployee__c
                    WHERE Id = :employee.Id];

            Decimal pFactor = empTemp.ClientPricingScenario__r.projectionFactor__c.setScale(2);
            Double qty = empTemp.Qty__c;
            Decimal annualHours = employee.AnnualHours__c / (qty > 0 ? qty : 1);
            PricingEEtoWcCodeAssoc__c primaryAssociation;
            Double maxPayroll = -999999999;

            for(PricingEEtoWcCodeAssoc__c association: associations)
            {
                if(maxPayroll < association.AnnualPayInCode__c)
                {
                    if(primaryAssociation != null)
                    {
                        primaryAssociation.AnnualHoursInCode_base__c = 0;
                    }
                    primaryAssociation = association;
                    maxPayroll = association.AnnualPayInCode__c;
                }
                else
                {
                    association.AnnualHoursInCode_base__c = 0;
                }
            }

            primaryAssociation.AnnualHoursInCode_base__c = annualHours / pFactor;
            eeAssociations.addAll(associations);
        }
        PrcEmployeesController.saveAssocList(eeAssociations);
    }

    @AuraEnabled
    public static void deleteEmployee(PricingEmployee__c eeToDelete)
    {
        Database.DeleteResult dbResult = Database.delete(eeToDelete);
        if (!dbResult.isSuccess()){
            System.debug('Save Renewal Errors: ' + dbResult.getErrors());
        }

        PrcWorkCompController.resetWorkCompPremium(eeToDelete.ClientPricingScenario__c);
    }

    @AuraEnabled
    public static void addEmployee(PricingEmployee__c newEE, Decimal annualPay, Decimal annualHours)
    {
        insert newEE;

        // finally, add an EE to work comp junction object
        PricingEEtoWcCodeAssoc__c newJuncObj = new PricingEEtoWcCodeAssoc__c(
                Pricing_Employee__c = newEE.Id,
                PricingWcCode__c = newEE.PrimaryPricingWcCode__c,
                AnnualHoursInCode__c = annualHours,
                AnnualHoursInCode_base__c = annualHours,
                AnnualPayInCode__c = annualPay,
                AnnualPayInCode_base__c = annualPay,
                AnnualPremPayInCode__c = annualPay,
                AnnualPremPayInCode_base__c = annualPay,
                AnnualTaxablePayInCode__c = annualPay,
                AnnualTaxablePayInCode_base__c = annualPay,
                ActiveEmployeesInCode__c = newEE.IsActive__c ? newEE.Qty__c : 0,
                TotalEmployeesInCode__c = newEE.Qty__c
        );
        insert newJuncObj;
    }

    @AuraEnabled
    public static List <PricingWcCode__c> getPricingWcCodes(String recordId)
    {
        List<PricingWcCode__c>  wcCodes = [
                SELECT  Id, State_Code__c, WC_Code__c,
                        ActiveEmployeesInCode__c,
                        AnnualHoursInCode__c,
                        AnnualTaxablePayInCode__c,
                        EstimatedErTaxInCode__c,
                        TaxBurdenPercentInCode__c,
                        FTEInCode__c,
                        TotalEmployeesInCode__c
                FROM PricingWcCode__c
                WHERE ClientPricingScenario__c =: recordId];
        return wcCodes;
    }

    @AuraEnabled
    public static ERPayrollTax__c[] getPricingTaxes(String recordId)
    {
        return PrcTaxRatesController.getPricingTaxes(recordId);
    }
}