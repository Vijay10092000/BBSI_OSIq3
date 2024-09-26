/**
 * Created by CElim on 12/17/2018.
 */

@IsTest
private class PrcExpensesControllerTest
{
    @TestSetup static void setup()
    {
    	Account branch = TestFactory.createAccount('Test Branch 3', '98662', 'BBSI Branch', true);
        Business_Unit__c bu = new Business_Unit__c(Name = 'foo unit');
        bu.BBSI_Branch__c = branch.Id;
        insert(bu);
        
    	Account client = TestFactory.createAccount('904611', '98662', 'Client', false);
        client.Price_Approval__c = 'Approved';
        client.Branch__c = branch.Id;
        client.Business_Unit__c = bu.Id;
        insert client;
        
        TestFactoryRenewals.createPricingScenarioComplete();
    }

    @IsTest static void PrcExpensesTest()
    {
        ClientPricingScenario__c cps =
        [
                SELECT Id, BDM__c, BDM_Basis__c, BDM_Rate__c, BDM_Rate_Renewal__c, ClientId__c, ClientName__c,
                        commRate__c, commRateRenewal__c, PricingScenario__c, Name, projectionFactor__c,
                        ysumBilling__c, ysumComms__c, ysumErTaxes__c, ysumExpenses__c, ysumMargin__c,
                        ysumMaxSI__c, ysumPayroll__c, ysumWcPrem__c
                FROM ClientPricingScenario__c LIMIT 1];

        PricingExpense__c[] expenses = PrcExpensesController.getPricingExpenses(cps.Id);
        System.assertEquals(5, expenses.size());
        System.assertEquals('Employee services', expenses[0].Description__c);
        System.assertEquals('Other', expenses[0].Category__c);
        System.assertEquals(5.95, expenses[0].Cost_Each__c);
        System.assertEquals(1, expenses[0].Quantity__c);

        PricingExpense__c newExpense = new PricingExpense__c();
        newExpense.ClientPricingScenario__c = cps.Id;
        newExpense.Category__c = 'Other';
        newExpense.Cost_Each__c = 1.0;
        newExpense.Description__c = 'Test';
        newExpense.Quantity__c = 1;
        PrcExpensesController.addExpenseItem(newExpense);
        System.assertEquals(6, PrcExpensesController.getPricingExpenses(cps.Id).size());

        PrcExpensesController.deleteExpenseItem(newExpense);
        System.assertEquals(5, PrcExpensesController.getPricingExpenses(cps.Id).size());

        expenses[0].Quantity__c = 7;
        PrcExpensesController.savePricingExpenses(expenses);
        PricingExpense__c[] updateExpenses = PrcExpensesController.getPricingExpenses(cps.Id);
        System.assertEquals(5, updateExpenses.size());
        System.assertEquals(7, updateExpenses[0].Quantity__c);
    }

    @IsTest static void PrcClientInvestmentTest()
    {
        ClientPricingScenario__c cps =
        [
                SELECT Id, BDM__c, BDM_Basis__c, BDM_Rate__c, BDM_Rate_Renewal__c, ClientId__c, ClientName__c,
                        commRate__c, commRateRenewal__c, PricingScenario__c, Name, projectionFactor__c,
                        ysumBilling__c, ysumComms__c, ysumErTaxes__c, ysumExpenses__c, ysumMargin__c,
                        ysumMaxSI__c, ysumPayroll__c, ysumWcPrem__c
                FROM ClientPricingScenario__c LIMIT 1];

        PricingClientInvestment__c[] investments = PrcExpensesController.getPricingClientInvestments(cps.Id);
        System.assertEquals(5, investments.size());
        System.assertEquals('Client Investment 1', investments[0].Description__c);
        System.assertEquals('% of Payroll', investments[0].Method__c);
        System.assertEquals(0.39, investments[0].Rate__c);

        PricingClientInvestment__c newInvestment = new PricingClientInvestment__c();
        newInvestment.ClientPricingScenario__c = cps.Id;
        newInvestment.Description__c = 'Test';
        newInvestment.Rate__c = 0.75;
        PrcExpensesController.addClientInvestmentItem(newInvestment);
        System.assertEquals(6, PrcExpensesController.getPricingClientInvestments(cps.Id).size());

        PrcExpensesController.deleteClientInvestmentItem(newInvestment);
        System.assertEquals(5, PrcExpensesController.getPricingClientInvestments(cps.Id).size());

        investments[1].Method__c = '% of Margin';
        investments[1].Rate__c = 0.52;
        Boolean saveResult = PrcExpensesController.savePricingClientInvestments(new List<PricingClientInvestment__c>{investments[1]});
        PricingClientInvestment__c[] updatedClientInvestments = PrcExpensesController.getPricingClientInvestments(cps.Id);
        System.assertEquals(true, saveResult);
        System.assertEquals(0.52, updatedClientInvestments[1].Rate__c);
        System.assertEquals('% of Margin', updatedClientInvestments[1].Method__c);

        investments[0].Rate__c = 0.44;
        saveResult = PrcExpensesController.savePricingClientInvestments(new List<PricingClientInvestment__c>{investments[0]});
        updatedClientInvestments = PrcExpensesController.getPricingClientInvestments(cps.Id);
        System.assertEquals(false, saveResult);
        System.assertEquals(0.39, updatedClientInvestments[0].Rate__c);

        saveResult = PrcExpensesController.savePricingClientInvestments(investments);
        updatedClientInvestments = PrcExpensesController.getPricingClientInvestments(cps.Id);
        System.assertEquals(false, saveResult);
        System.assertEquals(0.39, updatedClientInvestments[0].Rate__c);
    }
}