@isTest
private class PricingSummaryService_Test {

    @testSetup static void setup() {
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
    @isTest Static Void ReadSummaryService(){

        ClientPricingScenario__c[] cpsList = [SELECT Id from ClientPricingScenario__c];
        ClientPricingScenario__c cpScenario = cpsList[0];

        PricingSummaryService psService = new PricingSummaryService(cpScenario.Id, true);
        Boolean isReady = psService.IsValid;
        psService.GrossMargin = 10000;
        psService.Recalculate();

        Decimal grossMargin = 0;
        For(PricingWcCode__c wcItem : psService.WcCodes)
        {
            grossMargin += wcItem.DesiredMarginDollars__c;
        }
        system.assertEquals(psService.GrossMargin, grossMargin);

        grossMargin = psService.ERTaxTotal;
        psService.Employees[0].Qty__c = psService.Employees[0].qty__c + 1;
        psService.Recalculate();
        system.assert(grossMargin < psService.ERTaxTotal);

        for(PricingWcCode__c wcItem : psService.WcCodes){
            system.debug('psService wcItem.SI_Percent_of_Payroll__c: ' + wcItem.SI_Percent_of_Payroll__c);
            system.debug('psService wcItem.SI_Percent_of_Premium__c: ' + wcItem.SI_Percent_of_Premium__c);
            system.debug('psService wcItem.WC_Rate__c: ' + wcItem.WC_Rate__c);
            system.debug('psService wcItem.Modified_WC_Rate__c: ' + wcItem.Modified_WC_Rate__c);
        }

        PricingXmod__c myXmod;
        PricingXmod__c[] pricingXmods = [SELECT Id, IsPricingXmod__c, State_Code__c, Xmod__c
                                         FROM PricingXmod__c
                                         WHERE ClientPricingScenario__c = :cpScenario.Id];
        for(PricingXmod__c xmItem : pricingXmods){
            system.debug('psService xmItem: ' + xmItem);
            if(xmItem.IsPricingXmod__c){
                system.debug('psService xmod found: ' + xmItem);
                myXmod = xmItem;
                system.debug('psService xmod copied: ' + myXmod);
            }
        }
        If(myXmod != null){
            myXmod.Xmod__c *= 1.1;
            system.debug('psService updated Xmod: ' + myXmod.Xmod__c);
            upsert myXmod;
            psService.RefreshAndRecalculate();
        }

        for(PricingWcCode__c wcItem : psService.WcCodes){
            system.debug('psService wcItem.SI_Percent_of_Payroll__c: ' + wcItem.SI_Percent_of_Payroll__c);
            system.debug('psService wcItem.SI_Percent_of_Premium__c: ' + wcItem.SI_Percent_of_Premium__c);
            system.debug('psService wcItem.WC_Rate__c: ' + wcItem.WC_Rate__c);
            system.debug('psService wcItem.Modified_WC_Rate__c: ' + wcItem.Modified_WC_Rate__c);
        }

    }

}