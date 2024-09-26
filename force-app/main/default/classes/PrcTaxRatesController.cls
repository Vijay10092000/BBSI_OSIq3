/*
 * Copyright (c) 2018. Barrett Business Services, Inc. All Rights Reserved
 */
public without sharing class PrcTaxRatesController {
    @AuraEnabled
    public static ERPayrollTax__c[] getPricingTaxes(String recordId){
        ERPayrollTax__c[] results = [
                SELECT  ClientPricingScenario__c,
                        ClientPricingScenario__r.Non_Profit__c,
                        Default_Rate__c,
                        Id,
                        Limit__c,
                        Non_Profit__c,
                        Rate__c,
                        State_Code__c,
                        Tax_Type__c
                FROM ERPayrollTax__c
                WHERE ClientPricingScenario__c = :recordId];
        return results;
    }

    @AuraEnabled
    public static void savePricingTaxes(ERPayrollTax__c[] taxes)
    {
        if(taxes.size() == 0) {
            return;
        }
        Map<Id, ERPayrollTax__c> taxesMap = new Map<Id, ERPayrollTax__c>();
        taxesMap.putAll(taxes);

        ERPayrollTax__c[] updateList = new List<ERPayrollTax__c>();
        ERPayrollTax__c[] erTaxes = [
                SELECT Id, State_Code__c, Tax_Type__c, ClientPricingScenario__r.Non_Profit__c
                FROM ERPayrollTax__c
                WHERE Id IN :taxesMap.keySet()
        ];
        for (ERPayrollTax__c t : erTaxes) {
            Boolean nonProfit = t.ClientPricingScenario__r.Non_Profit__c;
            if(!taxesMap.containsKey(t.Id)) {
                continue;
            }
            ERPayrollTax__c updatedTax = taxesMap.get(t.Id);
            if(t.State_Code__c != 'FED') {
                updateList.add(updatedTax);
            }
            else if(nonProfit && t.Tax_Type__c == 'FUTA') {
                updateList.add(updatedTax);
            }
        }

        if(updateList.size() > 0) {
            Database.SaveResult[] srList = Database.update(updateList, false);
            Database.SaveResult[] errorList = new List<Database.SaveResult>();
            for(Database.SaveResult sr :srList){
                if (!sr.isSuccess()){
                    errorList.add(sr);
                }
            }
            if(errorList.size() > 0){
                System.debug('Save Pricing Taxes Errors: ' + errorList);
            }
        }
    }

    @AuraEnabled
    public static void addTaxItem(ERPayrollTax__c newTaxItem) {
        Database.SaveResult dbResult = Database.insert(newTaxItem);
        if (!dbResult.isSuccess()){
            System.debug('Add Tax Item Errors: ' + dbResult.getErrors());
        }
    }

    @AuraEnabled
    public static void deleteTaxItem(ERPayrollTax__c taxToDelete)  {
        Database.DeleteResult dbResult = Database.delete(taxToDelete);
        if (!dbResult.isSuccess()){
            System.debug('Delete Tax Item Errors: ' + dbResult.getErrors());
        }
    }

    @AuraEnabled
    public static ERPayrollTax__c[] getPricingFederalTaxes(String recordId){
        ERPayrollTax__c[] results = [
                SELECT  ClientPricingScenario__c,
                        ClientPricingScenario__r.Non_Profit__c,
                        Default_Rate__c,
                        Id,
                        Limit__c,
                        Non_Profit__c,
                        Rate__c,
                        State_Code__c,
                        Tax_Type__c
                FROM ERPayrollTax__c
                WHERE ClientPricingScenario__c = :recordId AND State_Code__c = 'FED'];
        return results;
    }

    @AuraEnabled
    public static ERPayrollTax__c[] getPricingStateAndOthersTaxes(String recordId){
        ERPayrollTax__c[] results = [
                SELECT  ClientPricingScenario__c,
                        ClientPricingScenario__r.Non_Profit__c,
                        Default_Rate__c,
                        Id,
                        Limit__c,
                        Non_Profit__c,
                        Rate__c,
                        State_Code__c,
                        Tax_Type__c
                FROM ERPayrollTax__c
                WHERE ClientPricingScenario__c = :recordId AND State_Code__c != 'FED'];
        return results;
    }

    @AuraEnabled
    public static ClientPricingScenario__c getClientPricingScenario(String recordId){
        ClientPricingScenario__c cps = [
                SELECT IsProspect__c, Non_Profit__c
                FROM ClientPricingScenario__c
                WHERE Id = :recordId];
        return cps;
    }

}