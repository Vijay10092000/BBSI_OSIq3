@isTest
private class PricingScenarioEditController_Test {
    @TestSetup 
    static void ControllerSetup()
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

    @isTest
    static void InstantiateController()
    {
        // get the pricing scenario from the DB
        PricingScenario__c[] pricingScenarios = [SELECT id, name, fein__c, notes__c, 
                                                 renewal__c, scenarioname__c, status__c
                                                 FROM PricingScenario__c];

        PageReference pr = Page.PricingScenarioEditPage; 
        Test.setCurrentPage(pr);

        ApexPages.currentPage().getParameters().put('id', pricingScenarios[0].Id);
        ApexPages.currentPage().getParameters().put('renewalid', pricingScenarios[0].renewal__c);

        Map<String, String> paramMap = pr.getParameters();


        system.assert(pricingScenarios.size() > 0);
        system.assert(pricingScenarios[0].Id != null);

        ApexPages.StandardController std;
        If(pricingScenarios.size() > 0){
            std=new ApexPages.StandardController(pricingScenarios[0]);
        }

        system.debug('pricingScenarios controller id: ' + std.getId());
        system.debug('pricingScenarios controller Record: ' + std.getRecord().Id);
        

        PricingScenarioEditController controller = new PricingScenarioEditController(std);

        Renewal__c ren = controller.CurrentRenewal;
        String str = controller.CurrentPSClientid;
        str = controller.CurrentPSid;
        Boolean flag = controller.displayPopup;
        Integer num = controller.KeyToRemoveNew;
        str = controller.chosenCurrentId;
        
        Map<String, String> strMap = controller.ResourceHelpStringMap;
        Map<String,List<PricingSummaryHistory__c>> pSumHistMap;
        pSumHistMap = controller.m_clientPricingHistory;
        pSumHistMap = controller.m_mapMarginSummary;
        
        List<ClientPricingScenario__c> cpsList = controller.ClientPricingScenarios;
        // or
        cpsList = controller.GetClientPricingScenarios();
        controller.selectedScenarioChange();
        controller.LoadData();

        flag = controller.PEDisableSave;
        flag = controller.EditExpsenseMode;
        flag = controller.EditCommissionMode;

        flag = controller.CMDisableSave;
        flag = controller.CMAllowAdd;
        flag = controller.EditClPricScenMode;
        
        flag = controller.trDisableSave;
        flag = controller.eeDisableSave;
        flag = controller.EditTaxRateMode;
        
        flag = controller.EditEEMode;
        flag = controller.wcDisableSave;
        flag = controller.wcAllowAdd;
        
        flag = controller.EditWcCodeMode;
        flag = controller.xmDisableSave;
        flag = controller.xmAllowAdd;

        flag = controller.editXmodMode;
        flag = controller.mkDisableSave;
        flag = controller.editMarkupMode;
        
        str =  controller.keyToDeleteExpense;
        str =  controller.keyToDeletePayrollTax;
        str =  controller.keyToDeleteEmployee;
        
        str =  controller.selectedWCCode;
        str =  controller.keyToDeleteXmod;
        str =  controller.keyToDeleteWcCode;
        
        Map<String, Decimal> WCmap = controller.WCTotals;
        controller.addErTaxItem();
        controller.removeErTaxItem();
        
        controller.saveErTaxes();
        controller.DoTaxRateNewRemove();

        controller.DoCancelTaxRate();
        controller.DoDoneTaxRate();
        controller.DoTaxRateEdit();

        controller.addEmployee();
        controller.removeEmployee();
        controller.DoCancelEmployee();
        controller.DoEmployeeEdit();

        controller.DoCancelWcCode();
        controller.DoWcCodeEdit();
        controller.DoMarkupEdit();

        // controller.saveHist();
        controller.saveMarkup();
        controller.saveXmods();
        controller.DoXmodEdit();
        controller.DoCancelXmod();
        controller.saveEmployees();

        controller.DoCancelMarkup();
        controller.DoExpsenseNewRemove();
        controller.DoExpenseEdit();
        controller.addExpenseItems();
        controller.saveExpense();

        controller.DoDoneExpense();
        controller.DoCancelExpense();
        controller.DoCommissionEdit();

        controller.DoDoneCommission();
        controller.DoCancelCommission();
        controller.SaveCommission();

        controller.removeItemExpense();
        controller.showPopup();
        controller.closePopup();
        
        List<SelectOption> clientScenarios = controller.GetClientScenarios();
        Integer qty = clientScenarios.size();
        controller.enabledLogging();
        controller.saveScenario();
        List<SelectOption> opts = controller.getNewTaxOptions();
    }

}