/**
 * @description BusinessBlueprintPDFExtension_Test contains tests for the BusinessBlueprintPDFExtension class.
 */
@IsTest
public with sharing class BusinessBlueprintPDFExtension_Test {
    private static Account referralPartner;
    private static Account client;

    @TestSetup
    static void makeData() {
        client = TestFactoryAccount.createClient('TEST CLIENT', null, null);
        referralPartner = TestFactoryAccount.createReferralPartner('TEST REFERRAL PARTNER', '% of Margin', 2.12, null);
    }

    static void loadData() {
        client = [SELECT Id, Name FROM Account WHERE Name = 'TEST CLIENT' LIMIT 1];
        referralPartner = [SELECT Id, Name FROM Account WHERE Name = 'TEST REFERRAL PARTNER' LIMIT 1];
    }

    @IsTest
    static void test_setup() {
        loadData();

        Business_Blueprint__c blueprint = TestFactoryBusinessBlueprint.createBusinessBlueprint('TestPlan', client, 'Open', null);

        ApexPages.StandardController controller = new ApexPages.StandardController(blueprint);
        BusinessBlueprintPDFExtension extension = new BusinessBlueprintPDFExtension(controller);

        Assert.areEqual(false, extension.forReferralPartner, 'Is for a Client');
        Assert.areEqual(blueprint.Id, extension.blueprint.Id, 'Same blueprint');
        Assert.areEqual(client.Id, blueprint.Client__c, 'Account should be the same');
    }
}