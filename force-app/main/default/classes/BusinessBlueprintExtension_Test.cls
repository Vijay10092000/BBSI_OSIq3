/**
 * @description BusinessBlueprintTest
 */
@IsTest
public class BusinessBlueprintExtension_Test {
    private static Account referralPartner;
    private static Account branch;
    private static Account client;
    private static Business_Unit__c businessUnit;
    private static Contact contact;

    @TestSetup
    static void makeData() {
        referralPartner = TestFactoryAccount.createReferralPartner('TEST REFERRAL PARTNER', '% of Margin', 2.12, null);
        branch = TestFactoryAccount.createBranch('TEST BRANCH');
        businessUnit = TestFactoryBusinessUnit.createBusinessUnit('TEST BUSINESS UNIT', branch.Id);
        client = TestFactoryAccount.createClient('TEST CLIENT', null, null);
        contact = TestFactoryContact.createContact(null, 'TEST_CONTACT', 'Client Contact', client.Id);
    }

    static void loadData() {
        referralPartner = [SELECT Id, Name FROM Account WHERE Name = 'TEST REFERRAL PARTNER' LIMIT 1];
        branch = [SELECT Id, Name FROM Account WHERE Name = 'TEST BRANCH' LIMIT 1];
        businessUnit = [SELECT Id, Name FROM Business_Unit__c WHERE Name = 'TEST BUSINESS UNIT' LIMIT 1];
        client = [SELECT Id, Name FROM Account WHERE Name = 'TEST CLIENT' LIMIT 1];
        contact = [SELECT Id, Name FROM Contact WHERE Name = 'TEST_CONTACT' LIMIT 1];
    }

    @IsTest
    public static void test_setup() {
        loadData();

        Business_Blueprint__c blueprintClient = TestFactoryBusinessBlueprint.createBusinessBlueprint('TestPlan', client, 'Open', null);

        ApexPages.StandardController controllerClient = new ApexPages.StandardController(blueprintClient);
        BusinessBlueprintExtension extensionClient = new BusinessBlueprintExtension(controllerClient);

        Assert.areEqual(blueprintClient.Id, extensionClient.blueprint.Id, 'Blueprint was not set correctly');
        Assert.areEqual(false, extensionClient.forReferralPartner, 'Should be for Client');
        Assert.areEqual(60000, extensionClient.timeOut, 'Should use the default value');

        Business_Blueprint__c blueprintReferralPartner = TestFactoryBusinessBlueprint.createBusinessBlueprint('TestPlan', referralPartner, 'Open', null);

        ApexPages.StandardController controllerReferralPartner = new ApexPages.StandardController(blueprintReferralPartner);
        BusinessBlueprintExtension extensionReferralPartner = new BusinessBlueprintExtension(controllerReferralPartner);

        Assert.areEqual(blueprintReferralPartner.Id, extensionReferralPartner.blueprint.Id, 'Blueprint was not set correctly');
        Assert.areEqual(true, extensionReferralPartner.forReferralPartner, 'Should be for Referral Partner');
        Assert.areEqual(60000, extensionReferralPartner.timeOut, 'Should use the default value');
    }

    @IsTest
    public static void test_getForReferralPartner() {
        loadData();

        Business_Blueprint__c blueprint = TestFactoryBusinessBlueprint.createBusinessBlueprint('TestPlan', referralPartner, 'Open', null);
        ApexPages.StandardController controllerReferralPartner = new ApexPages.StandardController(blueprint);
        BusinessBlueprintExtension extension = new BusinessBlueprintExtension(controllerReferralPartner);

        Assert.areEqual(true, extension.getForReferralPartner(referralPartner.Id), 'Is for Referral Partner');
        Assert.areEqual(false, extension.getForReferralPartner(client.Id), 'Is NOT for Referral Partner');
    }

    @IsTest
    static void test_Cancel() {
        Pagereference pageRef;
        BusinessBlueprintExtension extension;

        loadData();

        Business_Blueprint__c blueprint = TestFactoryBusinessBlueprint.createBusinessBlueprint('TestPlan', client, 'Open', null);
        ApexPages.StandardController controllerReferralPartner = new ApexPages.StandardController(blueprint);
        extension = new BusinessBlueprintExtension(controllerReferralPartner);

        pageRef = extension.cancel();
        Assert.isTrue(pageRef.getUrl().endsWith(blueprint.Id), 'Should return to the blueprint');

        Business_Blueprint__c blueprintNew = TestFactoryBusinessBlueprint.makeBusinessBlueprint('TestPlan', referralPartner, 'Open', null);
        ApexPages.StandardController controllerNew = new ApexPages.StandardController(blueprintNew);
        extension = new BusinessBlueprintExtension(controllerNew);

        pageRef = extension.cancel();
        Assert.isTrue(pageRef.getUrl().endsWith(referralPartner.Id), 'Should return to the account');
    }

    @IsTest
    static void test_submit() {
        loadData();

        Business_Blueprint__c blueprint = TestFactoryBusinessBlueprint.makeBusinessBlueprint('TestPlan', client, 'Open', null);
        ApexPages.StandardController controller = new ApexPages.StandardController(blueprint);
        BusinessBlueprintExtension extension = new BusinessBlueprintExtension(controller);

        Date today = Date.today();

        blueprint.Start_Date__c = today;
        blueprint.End_Date__c = today.addDays(30);

        PageReference pageRef = extension.submit();

        blueprint = [
            SELECT Id, Name, Start_Date__c, End_Date__c
            FROM Business_Blueprint__c
            WHERE Id = :blueprint.Id
        ];

        Assert.isTrue(pageRef.getUrl().endsWith(blueprint.Id), 'Should return to the blueprint' );
        Assert.areEqual(today, blueprint.Start_Date__c, 'Blueprint not saved');
        Assert.areEqual(today.addDays(30), blueprint.End_Date__c, 'Blueprint not saved');
    }
    
    @IsTest
    public static void test_setup_blankName() {
        loadData();

        Business_Blueprint__c blueprintClient = TestFactoryBusinessBlueprint.makeBusinessBlueprint(null, client, 'Open', null);
        ApexPages.StandardController controllerClient = new ApexPages.StandardController(blueprintClient);
        BusinessBlueprintExtension extensionClient = new BusinessBlueprintExtension(controllerClient);
        
        extensionClient.blueprint.Client__c = null;
        PageReference pageRef = extensionClient.submit();
        Assert.areEqual(null, pageRef, 'Blank Client__c should return null on Submit');
    }
}