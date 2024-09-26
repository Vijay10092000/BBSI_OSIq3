@IsTest
public with sharing class PricingTemplateWcCodes_Batch_Test {
    @TestSetup
    static void makeData() {
		TestFactoryRenewals.createPricingScenarioComplete();

        ClientPricingScenario__c cps = [SELECT Id FROM ClientPricingScenario__c WHERE ClientId__c = '904611'];

        DateTime now = DateTime.now();

        List<PricingTemplateWcCode__c> wcCodes = new List<PricingTemplateWcCode__c>();

        wcCodes.add(new PricingTemplateWcCode__c(
            ClientPricingScenario__c = cps.Id,
            Name = 'CA 0005 1.11',
            State_Code__c = 'CA',
            WC_Code__c = '0005',
            WC_Rate__c = 2.2
        ));
        wcCodes.add(new PricingTemplateWcCode__c(
            ClientPricingScenario__c = cps.Id,
            Name = 'CA 5805 2.22',
            State_Code__c = 'CA',
            WC_Code__c = '0005',
            WC_Rate__c = 2.22
        ));
        wcCodes.add(new PricingTemplateWcCode__c(
            ClientPricingScenario__c = cps.Id,
            Name = 'CA 1234 3.33',
            State_Code__c = 'CA',
            WC_Code__c = '3333',
            WC_Rate__c = 3.33
        ));
        wcCodes.add(new PricingTemplateWcCode__c(
            ClientPricingScenario__c = cps.Id,
            Name = 'CA 1234 4.33',
            State_Code__c = 'CA',
            WC_Code__c = '0004',
            WC_Rate__c = 4.33
        ));

        insert wcCodes;

        Test.setCreatedDate(wcCodes[0].Id, now.addDays(-95));
        Test.setCreatedDate(wcCodes[1].Id, now.addDays(-85));
        Test.setCreatedDate(wcCodes[2].Id, now.addDays(-150));
        Test.setCreatedDate(wcCodes[3].Id, now.addDays(-10));
    }

    @IsTest
    public static void test_batch() {
        PricingTemplateWcCodes_Batch batch = new PricingTemplateWcCodes_Batch();
        List<PricingTemplateWcCode__c> wcCodesBefore = [SELECT Id, Name FROM PricingTemplateWcCode__c];
        Integer beforeCount = wcCodesBefore.size();

        List<PricingTemplateWcCode__c> wcCodes = batch.start(null);
        System.assertEquals(2, wcCodes.size());
        
        Test.startTest();

        batch.execute(null, wcCodes);

        Test.stopTest();
        
        List<PricingTemplateWcCode__c> wcCodesAfter = [SELECT Id, Name FROM PricingTemplateWcCode__c];
        System.assertEquals(beforeCount - 2, wcCodesAfter.size());

        batch.finish(null);
        System.assert(true, 'finish currently has no code');
    }
}