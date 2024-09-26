/**
 * @description BusinessBlueprintActionCreate_Test contains tests for the class BusinessBlueprintActionCreate.
 */
@IsTest
public with sharing class BusinessBlueprintActionCreate_Test {
    private static Account client;
    private static Business_Blueprint__c blueprint;

    @TestSetup
    static void makeData() {
        client = TestFactoryAccount.createClient('TEST CLIENT', null, null);
        blueprint = TestFactoryBusinessBlueprint.createBusinessBlueprint('TEST BLUEPRINT', client, 'Open', null);
    }

    static void loadData() {
        client = [SELECT Id, Name FROM Account WHERE Name = 'TEST CLIENT' LIMIT 1];
        blueprint = [SELECT Id, Name FROM Business_Blueprint__c WHERE Name = 'TEST BLUEPRINT' LIMIT 1];
    }

    @IsTest
    public static void test_setup() {
        loadData();

        ApexPages.StandardController stdController = new ApexPages.StandardController(blueprint);
        BusinessBlueprintActionCreate controller = new BusinessBlueprintActionCreate(stdController);

        Assert.areEqual(blueprint.Id, controller.blueprint.Id, 'Should be same blueprint');
    }

    @IsTest
    public static void test_createPDF() {
        loadData();

        ApexPages.StandardController stdController = new ApexPages.StandardController(blueprint);
        BusinessBlueprintActionCreate controller = new BusinessBlueprintActionCreate(stdController);

        controller.createPDF(blueprint);

        List<ContentDocumentLink> links = [
            SELECT LinkedEntityId, ContentDocumentId, shareType
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :blueprint.Id
        ];
        Assert.areEqual(1, links.size(), ' Document should be created.');
    }

    @IsTest
    public static void test_createBlueprint() {
        loadData();

        ApexPages.StandardController stdController = new ApexPages.StandardController(blueprint);
        BusinessBlueprintActionCreate controller = new BusinessBlueprintActionCreate(stdController);

        PageReference pageRef = controller.createBlueprint();

        Assert.isTrue(pageRef.getUrl().endsWith(blueprint.Id), 'Should have page reference to the blueprint');
    }
}