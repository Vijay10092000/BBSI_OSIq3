/**
 * Created by CElim on 12/17/2018.
 */

@IsTest
private class PrcEmployeesControllerTest
{
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

    @IsTest static void SaveEmployeeTest()
    {
        String currentName = 'John Doe 1';
        String currentState = 'MD';

        String updateName = 'Joe Smith 1';
        String updateState = 'WA';

        ClientPricingScenario__c cps =
        [
                SELECT Id, BDM__c, BDM_Basis__c, BDM_Rate__c, BDM_Rate_Renewal__c, ClientId__c, ClientName__c,
                        commRate__c, commRateRenewal__c, PricingScenario__c, Name, projectionFactor__c,
                        ysumBilling__c, ysumComms__c, ysumErTaxes__c, ysumExpenses__c, ysumMargin__c,
                        ysumMaxSI__c, ysumPayroll__c, ysumWcPrem__c
                FROM ClientPricingScenario__c LIMIT 1];

        PricingEmployee__c[] employees = PrcEmployeesController.getPricingEmployees(cps.Id);
        Decimal initCount = employees.size();
        System.assert(initCount > 0);

        PricingEmployee__c emp = employees[0];
        System.assertEquals(currentName, emp.Employee_Name__c);
        System.assertEquals(currentState, emp.State_Code__c);

        emp.Employee_Name__c = updateName;
        emp.State_Code__c = updateState;
        PrcEmployeesController.saveEmployees(employees);

        PricingEmployee__c[] employeesUpdated = PrcEmployeesController.getPricingEmployees(cps.Id);
        System.assertEquals(initCount, employeesUpdated.size());

        PricingEmployee__c empUpdated = employees[0];
        System.assertEquals(updateName, empUpdated.Employee_Name__c);
        System.assertEquals(updateState, empUpdated.State_Code__c);
    }

    @IsTest static void DeleteEmployeeTest()
    {
        ClientPricingScenario__c cps =
        [
                SELECT Id, BDM__c, BDM_Basis__c, BDM_Rate__c, BDM_Rate_Renewal__c, ClientId__c, ClientName__c,
                        commRate__c, commRateRenewal__c, PricingScenario__c, Name, projectionFactor__c,
                        ysumBilling__c, ysumComms__c, ysumErTaxes__c, ysumExpenses__c, ysumMargin__c,
                        ysumMaxSI__c, ysumPayroll__c, ysumWcPrem__c
                FROM ClientPricingScenario__c LIMIT 1];

        PricingEmployee__c[] employees = PrcEmployeesController.getPricingEmployees(cps.Id);
        Decimal initCount = employees.size();
        System.assert(initCount > 0);

        PricingEmployee__c emp = employees[0];
        PrcEmployeesController.deleteEmployee(emp);
        System.assertEquals(initCount - 1, PrcEmployeesController.getPricingEmployees(cps.Id).size());

        TestFactoryRenewals.createPricingEmployee('John Doe 5', 'MD', false);
        System.assertEquals(3, PrcEmployeesController.getPricingEmployees(cps.Id).size());
    }

    @IsTest static void AddEmployeeTest()
    {
        ClientPricingScenario__c cps =
        [
                SELECT Id, BDM__c, BDM_Basis__c, BDM_Rate__c, BDM_Rate_Renewal__c, ClientId__c, ClientName__c,
                        commRate__c, commRateRenewal__c, PricingScenario__c, Name, projectionFactor__c,
                        ysumBilling__c, ysumComms__c, ysumErTaxes__c, ysumExpenses__c, ysumMargin__c,
                        ysumMaxSI__c, ysumPayroll__c, ysumWcPrem__c
                FROM ClientPricingScenario__c LIMIT 1];

        PricingEmployee__c[] employees = PrcEmployeesController.getPricingEmployees(cps.Id);
        Decimal initCount = employees.size();
        System.assert(initCount > 0);

        PricingWcCode__c[] codes = PrcWorkCompController.getPricingWcCodes(cps.Id);
        System.assert(codes.size() > 0);

        PricingEmployee__c newEmployee = TestFactoryRenewals.createPricingEmployee('John Doe 5', 'MD', false);
        newEmployee.ClientPricingScenario__c = cps.Id;
        newEmployee.PrimaryPricingWcCode__c = codes[0].Id;
        PrcEmployeesController.addEmployee(newEmployee, 5000, 100);
        System.assertEquals(initCount + 1, PrcEmployeesController.getPricingEmployees(cps.Id).size());
    }

    @IsTest static void WcCodeTest()
    {
        ClientPricingScenario__c cps =
        [
                SELECT Id, BDM__c, BDM_Basis__c, BDM_Rate__c, BDM_Rate_Renewal__c, ClientId__c, ClientName__c,
                        commRate__c, commRateRenewal__c, PricingScenario__c, Name, projectionFactor__c,
                        ysumBilling__c, ysumComms__c, ysumErTaxes__c, ysumExpenses__c, ysumMargin__c,
                        ysumMaxSI__c, ysumPayroll__c, ysumWcPrem__c
                FROM ClientPricingScenario__c LIMIT 1];

        PricingWcCode__c[] codes = PrcEmployeesController.getPricingWcCodes(cps.Id);
        System.assertEquals(2, codes.size());

        PricingEEtoWcCodeAssoc__c[] associations = PrcEmployeesController.getEEtoWcCodeAssocs(cps.Id);
        System.assertEquals(4, associations.size());

        associations[0].AnnualHoursInCode__c =  10000;
        PrcEmployeesController.saveAssocList(associations);

        PricingEEtoWcCodeAssoc__c[] updateAssociations = PrcEmployeesController.getEEtoWcCodeAssocs(cps.Id);
        System.assertEquals(4, associations.size());
        System.assertEquals(10000, updateAssociations[0].AnnualHoursInCode__c);

        PricingEEtoWcCodeAssoc__c[] associationsByCode = PrcEmployeesController.getEEtoWcCodeAssociationsByCode(codes[0]);
        System.assert(associationsByCode.size() > 0);
    }

    @IsTest static void EmployeeTaxTest()
    {
        ClientPricingScenario__c cps =
        [
                SELECT Id, BDM__c, BDM_Basis__c, BDM_Rate__c, BDM_Rate_Renewal__c, ClientId__c, ClientName__c,
                        commRate__c, commRateRenewal__c, PricingScenario__c, Name, projectionFactor__c,
                        ysumBilling__c, ysumComms__c, ysumErTaxes__c, ysumExpenses__c, ysumMargin__c,
                        ysumMaxSI__c, ysumPayroll__c, ysumWcPrem__c
                FROM ClientPricingScenario__c LIMIT 1];

        ERPayrollTax__c[] taxes = PrcEmployeesController.getPricingTaxes(cps.Id);
        System.assertEquals(5, taxes.size());
    }

    @IsTest static void SaveEmployeesAndHoursTest()
    {
        ClientPricingScenario__c cps =
        [
                SELECT Id, BDM__c, BDM_Basis__c, BDM_Rate__c, BDM_Rate_Renewal__c, ClientId__c, ClientName__c,
                        commRate__c, commRateRenewal__c, PricingScenario__c, Name, projectionFactor__c,
                        ysumBilling__c, ysumComms__c, ysumErTaxes__c, ysumExpenses__c, ysumMargin__c,
                        ysumMaxSI__c, ysumPayroll__c, ysumWcPrem__c
                FROM ClientPricingScenario__c LIMIT 1];


        PricingEmployee__c[] employees = PrcEmployeesController.getPricingEmployees(cps.Id);
        System.assert(employees.size() > 0);
        PricingEmployee__c emp = employees[0];

        PricingEEtoWcCodeAssoc__c[] associations = PrcEmployeesController.getEEtoWcCodeAssocs(cps.Id);
        System.assertEquals(4, associations.size());

        Decimal currentHours = 0;

        for(PricingEEtoWcCodeAssoc__c assoc : associations)
        {
            if(assoc.Pricing_Employee__r.Id == emp.Id)
            {
                currentHours = assoc.AnnualHoursInCode_base__c;
                assoc.AnnualHoursInCode_base__c = currentHours + 10;
                assoc.AnnualHoursInCode__c = currentHours + 10;
                break;
            }
        }

        PrcEmployeesController.saveEmployeesAndHours(employees);

        for(PricingEEtoWcCodeAssoc__c assoc : associations)
        {
            if(assoc.Pricing_Employee__r.Id == emp.Id)
            {
                System.assertEquals(currentHours + 10, assoc.AnnualHoursInCode_base__c);
                assoc.AnnualHoursInCode_base__c = currentHours;
                assoc.AnnualHoursInCode__c = currentHours;
                break;
            }
        }
        PrcEmployeesController.saveEmployeesAndHours(employees);
    }
}