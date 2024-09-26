/*
 * Copyright (c) 2018. Barrett Business Services, Inc. All Rights Reserved
 * Created by agoganian on 10/17/2018.
 */

public without sharing class PrcExpensesController {
    @AuraEnabled
    public static PricingExpense__c[] getPricingExpenses(String recordId)
    {
        PricingExpense__c[] results = [
                SELECT
                        Category__c,
                        ClientPricingScenario__c,
                        Cost_Each__c,
                        Description__c,
                        Id,
                        LastModifiedDate,
                        Name,
                        Quantity__c,
                        Total__c,
                        totalcal__c
                FROM PricingExpense__c
                WHERE ClientPricingScenario__c = :recordId
                ORDER BY CreatedDate];
        return results;
    }

    @AuraEnabled
    public static PricingClientInvestment__c[] getPricingClientInvestments(String recordId)
    {
        PricingSummaryHistory__c summaryHistory = PrcMarginHistoryController.getPricingSummaryRenewalRow(recordId);
        PricingClientInvestment__c[] results = [
                SELECT
                        ClientPricingScenario__c,
                        Description__c,
                        Id,
                        LastModifiedDate,
                        Method__c,
                        Rate__c,
                        Total_Cost__c
                FROM PricingClientInvestment__c
                WHERE ClientPricingScenario__c = :recordId
                ORDER BY CreatedDate];

        for(PricingClientInvestment__c item: results){
            switch on item.Method__c.toLowerCase() {
                when '% of payroll' {
                    item.Total_Cost__c = item.Rate__c * summaryHistory.YendPayrollTaxable__c / 100;
                }
                when '% of wc premium' {
                    item.Total_Cost__c = item.Rate__c * summaryHistory.YendWcPrem__c / 100;
                }
                when '% of margin' {
                    item.Total_Cost__c = item.Rate__c * summaryHistory.YendMargin__c / 100;
                }
                when else {
                    item.Method__c = '% of Payroll';
                    item.Total_Cost__c = item.Rate__c * summaryHistory.YendPayrollTaxable__c / 100;
                }
            }
        }
        return results;
    }

    @AuraEnabled
    public static void savePricingExpenses(PricingExpense__c[] expenses)
    {
        Database.SaveResult[] srList;
        Database.Error[] errList = new List<Database.Error>();
        srList = Database.Update(expenses, false);
        for (Database.SaveResult sr : srList) {
            if (!sr.isSuccess()){
                errList.addAll(sr.getErrors());
            }
        }
        if(errList.size() > 0)
        {
            System.debug('savePricingExpenses Error List: ' + errList);
        }
    }

    @AuraEnabled
    public static Boolean savePricingClientInvestments(PricingClientInvestment__c[] investments)
    {
        Integer size = investments.size();
        if(size > 0)
        {
            PricingClientInvestment__c ci = [
                    SELECT Id, ClientPricingScenario__c
                    FROM PricingClientInvestment__c
                    WHERE Id = :investments[0].Id
            ];
            PricingClientInvestment__c[] existingInvestments = PrcExpensesController.getPricingClientInvestments(ci.ClientPricingScenario__c);
            if(existingInvestments.size() > 0)
            {
                PricingClientInvestment__c notToDeleteInvestment = existingInvestments[0];
                for(Integer i = 0; i < size; ++i){
                    if(notToDeleteInvestment.Id == investments[i].Id)
                    {
                        return false;
                    }
                }
            }
        }
        Database.SaveResult[] srList;
        Database.Error[] errList = new List<Database.Error>();
        srList = Database.update(investments, false);
        for (Database.SaveResult sr : srList) {
            if (!sr.isSuccess()){
                errList.addAll(sr.getErrors());
            }
        }
        if(errList.size() > 0)
        {
            System.debug('savePricingClientInvestments Error List: ' + errList);
            return false;
        }
        return true;
    }

    @AuraEnabled
    public static void addExpenseItem(PricingExpense__c newExpenseItem)
    {
        Database.SaveResult dbResult = Database.insert(newExpenseItem);
        if (!dbResult.isSuccess())
        {
            System.debug('addExpenseItem Errors: ' + dbResult.getErrors());
        }
    }

    @AuraEnabled
    public static void addClientInvestmentItem(PricingClientInvestment__c newInvestmentItem)
    {
        Database.SaveResult dbResult = Database.insert(newInvestmentItem);
        if (!dbResult.isSuccess())
        {
            System.debug('addClientInvestmentItem Errors: ' + dbResult.getErrors());
        }
    }

    @AuraEnabled
    public static void deleteExpenseItem(PricingExpense__c expenseItem)
    {
        Database.DeleteResult dbResult = Database.delete(expenseItem);
        if (!dbResult.isSuccess())
        {
            System.debug('deleteExpenseItem Errors: ' + dbResult.getErrors());
        }
    }

    @AuraEnabled
    public static Boolean deleteClientInvestmentItem(PricingClientInvestment__c investmentItem)
    {
        PricingClientInvestment__c[] investments = PrcExpensesController.getPricingClientInvestments(investmentItem.ClientPricingScenario__c);
        if(investments.size() > 0){
            PricingClientInvestment__c notToDeleteInvestment = investments[0];
            if(notToDeleteInvestment.Id == investmentItem.Id){
                return false;
            }
        }
        Database.DeleteResult dbResult = Database.delete(investmentItem);
        if (!dbResult.isSuccess())
        {
            System.debug('Delete Expense Item Errors: ' + dbResult.getErrors());
            return false;
        }
        return true;
    }
}