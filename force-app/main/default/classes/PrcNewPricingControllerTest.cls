@IsTest
private class PrcNewPricingControllerTest 
{
    @TestSetup static void setup()
    {
        Boolean isInclude = true;
        Boolean isInsert = true;
        TestFactoryRenewals.createWorkCompPolicyDisplayName('BBSI', 'Corvell Policy', isInclude, isInsert);

        Business_Unit__c bu = new Business_Unit__c(name = 'TEST');
        insert bu;

        Account a = TestFactory.createAccount('testAcct', '98662', 'Client', false);
        a.Business_Unit__c = bu.ID;
        a.FEIN__c = '99-9999999';
        a.Verified__c = true;
        a.X_Mod__c = '0.85';
        insert a;
  
        Opportunity opp = TestFactory.createOpportunity('TestOpp', a , System.today(), 'First Meeting', isInsert);
    }

    @IsTest static void GetPolicyTest()
    {
        List<WorkCompPolicyDisplayName__c> policies = PrcNewPricingController.getPolicies();
        System.assert(policies.size() > 0);
    }
    
    @IsTest static void GetWorkCompPolicyCodeRateTest()
    {
        // This is not testing anything - refer to WorkCompControllerTest - WorkCompPolicyDataModelTest - test the feature
        Map<String, Map<String, List<WorkCompRate__c>>> rateMap = PrcNewPricingController.getWorkCompRateMap();
        System.assert(rateMap != null);
    }

    @IsTest static void NewPricingTest()
    {
        Opportunity opportunity = [SELECT Id FROM Opportunity LIMIT 1];
        Renewal__c renewal = PrcNewPricingController.createRenewal(opportunity.Id);

        System.assertEquals('99-9999999', renewal.FEIN__c);

        List<PrcNewPricingController.DataTableRow> rows = new List<PrcNewPricingController.DataTableRow>();
        PrcNewPricingController.DataTableRow row = new PrcNewPricingController.DataTableRow();
        row.State = 'CA';
        row.Code = '8810';
        row.Rate = 2.5678;
        row.FteCount = 2.3;
        row.PayrollDollars = 23000;
        rows.add(row);

        row.State = 'CA';
        row.Code = '4583';
        row.Rate = 2.9856;
        row.FteCount = 1.3;
        row.PayrollDollars = 13000;
        rows.add(row);

        List<PrcNewPricingController.TemplateWcCode> templateWcCodes = new List<PrcNewPricingController.TemplateWcCode>();
        PrcNewPricingController.TemplateWcCode t = new PrcNewPricingController.TemplateWcCode();
        t.State = 'CA';
        t.WorkCompRates = new List<WorkCompRate__c>();

        WorkCompRate__c rate = TestFactoryRenewals.createWorkCompRate('BBSI', 'CA', '8810', 2.9850, true);
        t.WorkCompRates.add(rate);

        WorkCompRate__c rate2 = TestFactoryRenewals.createWorkCompRate('BBSI', 'CA', '1000', 0.0000, true);
        t.WorkCompRates.add(rate2);
        templateWcCodes.add(t);

        Decimal psCount = 1;
        PrcNewPricingController.newClientPricingScenario(opportunity.Id, 'Scenario 01', rows, templateWcCodes);
        List<PricingScenario__c> ps = PrcNewPricingController.getPricingScenarios(opportunity.Id);
        System.assertEquals(psCount, ps.size());

        String result = PrcNewPricingController.clonePricingScenario(opportunity.Id, ps[0].Name, 'Cloned PS');
        if (result == 'OK') {
            psCount += 1;
        } 
        ps = PrcNewPricingController.getPricingSCenarios(opportunity.Id);
        System.assertEquals(psCount, ps.size());

        PrcNewPricingController.deletePricingScenario(ps[0].Id);
        ps = PrcNewPricingController.getPricingSCenarios(opportunity.Id);
        System.assertEquals(psCount - 1, ps.size());

        Map<String, List<WorkCompRate__c>> caRatesMap = PrcNewPricingController.getWorkCompRateByState('CA');
        List<WorkCompRate__c> caRates = caRatesMap.get('CA');
        System.assert(caRates.size() > 0);
    }
}