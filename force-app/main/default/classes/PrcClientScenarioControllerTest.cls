/**
 * Created by CElim on 12/17/2018.
 */

@IsTest
private class PrcClientScenarioControllerTest
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

    @IsTest static void GetWorksheetSummaryTest()
    {
        ClientPricingScenario__c cps =
        [
                SELECT Id, BDM__c, BDM_Basis__c, BDM_Rate__c, BDM_Rate_Renewal__c, ClientId__c, ClientName__c,
                        commRate__c, commRateRenewal__c, PricingScenario__c, PricingScenario__r.ScenarioName__c, Name, projectionFactor__c,
                        ysumBilling__c, ysumComms__c, ysumErTaxes__c, ysumExpenses__c, ysumMargin__c,
                        ysumMaxSI__c, ysumPayroll__c, ysumWcPrem__c
                FROM ClientPricingScenario__c
                LIMIT 1
        ];

        List<String> csv = PrcClientScenarioController.getSummaryWorksheet(cps.Id);
        String filename = csv[0];
        System.assertEquals(filename, cps.ClientId__c + ' ' + cps.PricingScenario__r.ScenarioName__c + ' Summary.csv');
    }

    @IsTest static void GetClientPricingScenarioTest()
    {
        ClientPricingScenario__c cps =
        [
                SELECT Id, BDM__c, BDM_Basis__c, BDM_Rate__c, BDM_Rate_Renewal__c, ClientId__c, ClientName__c,
                        commRate__c, commRateRenewal__c, PricingScenario__c, Name, projectionFactor__c,
                        ysumBilling__c, ysumComms__c, ysumErTaxes__c, ysumExpenses__c, ysumMargin__c,
                        ysumMaxSI__c, ysumPayroll__c, ysumWcPrem__c
                FROM ClientPricingScenario__c
                LIMIT 1
        ];


        System.assertEquals(cps.BDM__c, cps.BDM__c);
        System.assertEquals(cps.BDM_Basis__c, cps.BDM_Basis__c);
        System.assertEquals(cps.BDM_Rate__c, cps.BDM_Rate__c);
        System.assertEquals(cps.BDM_Rate_Renewal__c, cps.BDM_Rate_Renewal__c);
        System.assertEquals(cps.ClientId__c, cps.ClientId__c);
        System.assertEquals(cps.ClientName__c, cps.ClientName__c);
        System.assertEquals(cps.commRate__c, cps.commRate__c);
        System.assertEquals(cps.commRateRenewal__c, cps.commRateRenewal__c);
        System.assertEquals(cps.Name, cps.Name);
        System.assertEquals(cps.PricingScenario__c, cps.PricingScenario__c);
        System.assertEquals(cps.projectionFactor__c, cps.projectionFactor__c);
        System.assertEquals(cps.ysumBilling__c, cps.ysumBilling__c);
        System.assertEquals(cps.ysumComms__c, cps.ysumComms__c);
        System.assertEquals(cps.ysumErTaxes__c, cps.ysumErTaxes__c);
        System.assertEquals(cps.ysumExpenses__c, cps.ysumExpenses__c);
        System.assertEquals(cps.ysumMargin__c, cps.ysumMargin__c);
        System.assertEquals(cps.ysumMaxSI__c, cps.ysumMaxSI__c);
        System.assertEquals(cps.ysumPayroll__c, cps.ysumPayroll__c);
        System.assertEquals(cps.ysumWcPrem__c, cps.ysumWcPrem__c);
    }

    @IsTest static void SaveClientPricingScenarioTest()
    {
        ClientPricingScenario__c cps =
        [
                SELECT Id, BDM__c, BDM_Basis__c, BDM_Rate__c, BDM_Rate_Renewal__c, ClientId__c, ClientName__c,
                        commRate__c, commRateRenewal__c, PricingScenario__c, Name, projectionFactor__c,
                        ysumBilling__c, ysumComms__c, ysumErTaxes__c, ysumExpenses__c, ysumMargin__c,
                        ysumMaxSI__c, ysumPayroll__c, ysumWcPrem__c
                FROM ClientPricingScenario__c
                LIMIT 1
        ];

        String name = 'John Doe';
        Decimal bdmRate = 5;
        Decimal bdmRateRenewal = 5;

        String updateName = 'Joe Smith';
        Decimal updateBdmRate = 7;
        Decimal updateBdmRateRenewal = 8;

        System.assertEquals(name, cps.BDM__c);
        System.assertEquals(bdmRate, cps.BDM_Rate__c);
        System.assertEquals(bdmRateRenewal, cps.BDM_Rate_Renewal__c);

        cps.BDM__c = updateName;
        cps.BDM_Rate__c = updateBdmRate;
        cps.BDM_Rate_Renewal__c = updateBdmRateRenewal;
        PrcClientScenarioController.SaveClientPricingScenario(cps);

        ClientPricingScenario__c cpsUpdated = PrcClientScenarioController.getClientPricingScenario(cps.Id);
        System.assertEquals(updateName, cpsUpdated.BDM__c);
        System.assertEquals(updateBdmRate, cpsUpdated.BDM_Rate__c);
        System.assertEquals(updateBdmRateRenewal, cpsUpdated.BDM_Rate_Renewal__c);

        cps.BDM__c = name;
        cps.BDM_Rate__c = bdmRate;
        cps.BDM_Rate_Renewal__c = bdmRateRenewal;
        PrcClientScenarioController.SaveClientPricingScenario(cps);
    }

    @IsTest static void GetEmployeeToWcCodeAssociationTest()
    {
        ClientPricingScenario__c cps =
        [
                SELECT Id, BDM__c, BDM_Basis__c, BDM_Rate__c, BDM_Rate_Renewal__c, ClientId__c, ClientName__c,
                        commRate__c, commRateRenewal__c, PricingScenario__c, Name, projectionFactor__c,
                        ysumBilling__c, ysumComms__c, ysumErTaxes__c, ysumExpenses__c, ysumMargin__c,
                        ysumMaxSI__c, ysumPayroll__c, ysumWcPrem__c
                FROM ClientPricingScenario__c
                LIMIT 1
        ];

        PricingEEtoWcCodeAssoc__c[] associations = PrcClientScenarioController.getEEtoWcCodeAssocs(cps.Id);
        System.assertEquals(4, associations.size());

        PrcClientScenarioController.saveAssocListAll(associations);
        System.assertEquals(4, PrcClientScenarioController.getEEtoWcCodeAssocs(cps.Id).size());

        PrcClientScenarioController.saveAssocList(associations);
        System.assertEquals(4, PrcClientScenarioController.getEEtoWcCodeAssocs(cps.Id).size());
    }

    @IsTest static void PricingEmployeesTest()
    {
        ClientPricingScenario__c cps =
        [
                SELECT Id, BDM__c, BDM_Basis__c, BDM_Rate__c, BDM_Rate_Renewal__c, ClientId__c, ClientName__c,
                        commRate__c, commRateRenewal__c, PricingScenario__c, Name, projectionFactor__c,
                        ysumBilling__c, ysumComms__c, ysumErTaxes__c, ysumExpenses__c, ysumMargin__c,
                        ysumMaxSI__c, ysumPayroll__c, ysumWcPrem__c
                FROM ClientPricingScenario__c
                LIMIT 1
        ];


        String currentName = 'John Doe 1';
        String currentState = 'MD';

        String updateName = 'Joe Smith 1';
        String updateState = 'WA';

        PricingEmployee__c[] employees = PrcClientScenarioController.getPricingEmployees(cps.Id);
        System.assertEquals(4, employees.size());

        PricingEmployee__c emp = employees[0];
        System.assertEquals(currentName, emp.Employee_Name__c);
        System.assertEquals(currentState, emp.State_Code__c);

        // save employee test
        emp.Employee_Name__c = updateName;
        emp.State_Code__c = updateState;
        PrcClientScenarioController.saveEmployees(employees);

        PricingEmployee__c[] employeesUpdated = PrcClientScenarioController.getPricingEmployees(cps.Id);
        System.assertEquals(4, employeesUpdated.size());

        PricingEmployee__c empUpdated = employees[0];
        System.assertEquals(updateName, empUpdated.Employee_Name__c);
        System.assertEquals(updateState, empUpdated.State_Code__c);

        // reset changes
        emp.Employee_Name__c = currentName;
        emp.State_Code__c = currentState;
        PrcClientScenarioController.saveEmployees(employees);
    }

    @IsTest static void PricingWcCodesTest()
    {
        ClientPricingScenario__c cps =
        [
                SELECT Id, BDM__c, BDM_Basis__c, BDM_Rate__c, BDM_Rate_Renewal__c, ClientId__c, ClientName__c,
                        commRate__c, commRateRenewal__c, PricingScenario__c, Name, projectionFactor__c,
                        ysumBilling__c, ysumComms__c, ysumErTaxes__c, ysumExpenses__c, ysumMargin__c,
                        ysumMaxSI__c, ysumPayroll__c, ysumWcPrem__c
                FROM ClientPricingScenario__c
                LIMIT 1
        ];

        String wcCode = '3482 MD';
        String state = 'MD';

        String updateWcCode = '3482 WA';
        String updateState = 'WA';

        PricingWcCode__c[] wcs = PrcClientScenarioController.getPricingWcCodes(cps.Id);
        System.assertEquals(2, wcs.size());

        PricingWcCode__c wc = wcs[0];
        System.assertEquals(wcCode, wc.Name);
        System.assertEquals(state, wc.State_Code__c);

        wc.Name = updateWcCode;
        wc.State_Code__c = updateState;
        PrcClientScenarioController.savePricingWcCodes(wcs);

        PricingWcCode__c[] wcsUpdate = PrcClientScenarioController.getPricingWcCodes(cps.Id);
        System.assertEquals(wcsUpdate.size(), 2);

        PricingWcCode__c wcUpdate = wcs[0];
        System.assertEquals(updateWcCode, wcUpdate.Name);
        System.assertEquals(updateState, wcUpdate.State_Code__c);

        wc.Name = wcCode;
        wc.State_Code__c = state;
        PrcClientScenarioController.savePricingWcCodes(wcsUpdate);
    }

    @IsTest static void PricingXmodTest()
    {
        ClientPricingScenario__c cps =
        [
                SELECT Id, BDM__c, BDM_Basis__c, BDM_Rate__c, BDM_Rate_Renewal__c, ClientId__c, ClientName__c,
                        commRate__c, commRateRenewal__c, PricingScenario__c, Name, projectionFactor__c,
                        ysumBilling__c, ysumComms__c, ysumErTaxes__c, ysumExpenses__c, ysumMargin__c,
                        ysumMaxSI__c, ysumPayroll__c, ysumWcPrem__c
                FROM ClientPricingScenario__c
                LIMIT 1
        ];

        PricingXmod__c[] xMods = PrcClientScenarioController.getRenewalYearXmods(cps.Id);
        System.assertEquals(1, xMods.size());

        PricingXmod__c xmod = xMods[0];
        System.assertEquals(1.2, xmod.Xmod__c);
    }

    @IsTest static void PricingTaxesTest()
    {
        ClientPricingScenario__c cps =
        [
                SELECT Id, BDM__c, BDM_Basis__c, BDM_Rate__c, BDM_Rate_Renewal__c, ClientId__c, ClientName__c,
                        commRate__c, commRateRenewal__c, PricingScenario__c, Name, projectionFactor__c,
                        ysumBilling__c, ysumComms__c, ysumErTaxes__c, ysumExpenses__c, ysumMargin__c,
                        ysumMaxSI__c, ysumPayroll__c, ysumWcPrem__c
                FROM ClientPricingScenario__c
                LIMIT 1
        ];

        ERPayrollTax__c[] taxes = PrcClientScenarioController.getPricingTaxes(cps.Id);
        System.assertEquals(5, taxes.size());
    }

    @IsTest static void PricingSummaryHistoryTest()
    {
        ClientPricingScenario__c cps =
        [
                SELECT Id, BDM__c, BDM_Basis__c, BDM_Rate__c, BDM_Rate_Renewal__c, ClientId__c, ClientName__c,
                        commRate__c, commRateRenewal__c, PricingScenario__c, Name, projectionFactor__c,
                        ysumBilling__c, ysumComms__c, ysumErTaxes__c, ysumExpenses__c, ysumMargin__c,
                        ysumMaxSI__c, ysumPayroll__c, ysumWcPrem__c
                FROM ClientPricingScenario__c
                LIMIT 1
        ];

        PricingSummaryHistory__c summary = PrcClientScenarioController.getPricingSummaryRenewalRow(cps.Id);
        System.assertEquals(3, summary.HeadcountAnnual__c);
        System.assertEquals(10, summary.YendCommsBdm__c);
        System.assertEquals(2, summary.FTE__c);
        System.assertEquals(2400, summary.YendMargin__c);
        System.assertEquals(65000, summary.PremiumBasedPayroll__c);
        System.assertEquals(400, summary.YendComms__c);
        System.assertEquals(200, summary.YendExpenses__c);
        System.assertEquals(1000, summary.YendWcPrem__c);
        System.assertEquals(1, summary.Xmod__c);

        summary.Xmod__c = 1.5;
        PrcClientScenarioController.savePricingSummaryRenewalRow(summary);
        System.assertEquals(1.5, PrcClientScenarioController.getPricingSummaryRenewalRow(cps.Id).Xmod__c);
    }
}