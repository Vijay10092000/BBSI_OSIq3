/**
 * @description BusinessBlueprintTest
 */
@IsTest
public class BusinessBlueprintTest {
	@IsTest
	static void ProducerBlueprintNew() {
		Account client = TestFactoryAccount.createClient('TestAccount', null, null);
		Contact contact = TestFactoryContact.createProducer(null, 'Test_Contact', client.Id);

		List<String> f = new List<String>();
		Producer_Business_Blueprint__c blueprint = new Producer_Business_Blueprint__c();

		PageReference pageRef = Page.BusinessBlueprintpage;
		pageRef.getParameters().put('CF00N50000008Ez7o_lkid', contact.Id);
		Test.setCurrentPage(pageRef);

		ApexPages.StandardController Extension = new ApexPages.StandardController(blueprint);
		BusinessBlueprintProducerExtension controller = new BusinessBlueprintProducerExtension(Extension);
		controller.save();
        
        Assert.isTrue(controller.pb.Id != null);
	}

	@IsTest
	static void ProducerBlueprintExisting() {
		Account client = TestFactoryAccount.createClient('TestAccount', null, null);
		Contact contact = TestFactoryContact.createProducer(null, 'Test_Contact', client.Id);

		List<String> f = new List<String>();
		Producer_Business_Blueprint__c blueprint = new Producer_Business_Blueprint__c();

		PageReference pageRef = Page.BusinessBlueprintProducerpage;
		pageRef.getParameters().put('CF00N50000008Ez7o_lkid', contact.Id);
		Test.setCurrentPage(pageRef);

		ApexPages.StandardController Extension = new ApexPages.StandardController(blueprint);
		BusinessBlueprintProducerExtension controller = new BusinessBlueprintProducerExtension(Extension);
		controller.save();

        Assert.isTrue(controller.pb.Id != null);
    }

	@IsTest
	static void ProducerArchive() {
		Account client = TestFactoryAccount.createClient('TestAccount', null, null);
		Contact contact = TestFactoryContact.createProducer(null, 'Test_Contact', client.Id);

		List<String> f = new List<String>();
		Producer_Business_Blueprint__c blueprint = new Producer_Business_Blueprint__c();

		PageReference pageRef = Page.BusinessBlueprintProducerPage;
		pageRef.getParameters().put('CF00N50000008Ez7o_lkid', contact.Id);
		pageRef.getParameters().put('id', contact.Id);
		Test.setCurrentPage(pageRef);

		ApexPages.StandardController Extension = new ApexPages.StandardController(blueprint);
		BusinessBlueprintProducerExtension controller = new BusinessBlueprintProducerExtension(Extension);
		PageReference pr = controller.clickCancel();
        Assert.isTrue(controller.pb.Id == null);
        Assert.isTrue(pr.getURL() == '/null');

        controller.archivePDF();
        
        List<Attachment> a = [SELECT Id, ParentID FROM Attachment];
        Assert.isTrue(a.size() == 0);
	}

	@IsTest
	static void ProducerPDFExtension() {
        Account branch = TestFactoryAccount.createBranch('TEST BRANCH');
        Business_Unit__c businessUnit = TestFactoryBusinessUnit.createBusinessUnit('TEST BUSINESS UNIT', branch.Id);
		Account client = TestFactoryAccount.createClient('TestAccount', null, null);
		Contact contact = TestFactoryContact.createProducer(null, 'Test_Contact', client.Id);

		Producer_Business_Blueprint__c blueprint = TestFactoryProducerBusinessBlueprint.createProducerBusinessBlueprint('TestPlan', contact, businessUnit, null);

		PageReference pageRef = Page.BusinessBlueprintProducerPDF;
		pageRef.getParameters().put('id', blueprint.Id);
		Test.setCurrentPage(pageRef);

		ApexPages.StandardController Extension = new ApexPages.StandardController(blueprint);
		BusinessBlueprintProducerPDFExtension controller = new BusinessBlueprintProducerPDFExtension(Extension);

		Assert.isTrue(controller.c.Id == contact.Id);
    }

	@IsTest
	static void ProducerExtension() {
		Account branch = TestFactoryAccount.createBranch('TEST BRANCH');
        Business_Unit__c businessUnit = TestFactoryBusinessUnit.createBusinessUnit('TEST BUSINESS UNIT', branch.Id);
		Account client = TestFactoryAccount.createClient('TestAccount', null, null);
		Contact contact = TestFactoryContact.createProducer(null, 'Test_Contact', client.Id);

		Producer_Business_Blueprint__c blueprint = TestFactoryProducerBusinessBlueprint.createProducerBusinessBlueprint('TestPlan', contact, businessUnit, null);
		PageReference pageRef = Page.BusinessBlueprintProducerPage;
		pageRef.getParameters().put('id', blueprint.Id);
		Test.setCurrentPage(pageRef);

		ApexPages.StandardController Extension = new ApexPages.StandardController(blueprint);
		BusinessBlueprintProducerExtension controller = new BusinessBlueprintProducerExtension(Extension);

        Assert.isTrue(controller.pb.Id == blueprint.Id);
	}
    
    @IsTest
	static void ProducerArchiveAfterSave() {
        Account branch = TestFactoryAccount.createBranch('TEST BRANCH');
        Business_Unit__c businessUnit = TestFactoryBusinessUnit.createBusinessUnit('TEST BUSINESS UNIT', branch.Id);
		Account client = TestFactoryAccount.createClient('TestAccount', null, null);
		Contact contact = TestFactoryContact.createProducer(null, 'Test_Contact', client.Id);

		Producer_Business_Blueprint__c blueprint = TestFactoryProducerBusinessBlueprint.createProducerBusinessBlueprint('TestPlan', contact, businessUnit, null);

		PageReference pageRef = Page.BusinessBlueprintProducerPage;
		pageRef.getParameters().put('id', blueprint.Id);
		Test.setCurrentPage(pageRef);

		ApexPages.StandardController Extension = new ApexPages.StandardController(blueprint);
		BusinessBlueprintProducerExtension controller = new BusinessBlueprintProducerExtension(Extension);
		controller.archivePDF();
        
        Attachment a = [SELECT Id, ParentID FROM Attachment LIMIT 1];
        Assert.isTrue(a.ParentID == blueprint.Id);
	}
}