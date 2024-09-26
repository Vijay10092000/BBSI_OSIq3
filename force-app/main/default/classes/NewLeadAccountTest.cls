/**
 * @description NewLeadAccountTest contains tests for the NewLeadAccountExtension class.
 */
@IsTest
public class NewLeadAccountTest {
	private static final String NAME_CLIENT_ACCOUNT = 'TEST CLIENT';

	private static User bdm;
	private static Contact areaManager;
	private static Contact primaryContact;
	private static Contact producer;
	private static Account branch;
	private static Account referralPartner;
	private static Account client;

	/**
	 * @description setup sets up intial data for all the tests.
	 */
	@TestSetup
	static void setup() {
		List<NAICS_Code__c> listNAICSCodes;

		listNAICSCodes = new List<NAICS_Code__c>();
        NAICS_Code__c n1 = TestFactoryNAICSCode.makeCode('111','Crop Production');
		listNAICSCodes.add(n1);

        NAICS_Code__c n2 = TestFactoryNAICSCode.makeCode('111140','Wheat Farming');
		listNAICSCodes.add(n2);
		insert listNAICSCodes;

		branch = TestFactoryAccount.createBranch('TEST BRANCH', '1000', null, null);
		bdm = TestFactoryUser.createBDM('TEST', 'BDMUser', 'Area Manager', '1000');
		referralPartner = TestFactoryAccount.createReferralPartner('TEST REFERRAL PARTNER', '% of Margin', 12.0, null);
		producer = TestFactoryContact.createProducer('TEST', 'PRODUCER', referralPartner.Id);

		client = TestFactoryAccount.makeClient(NAME_CLIENT_ACCOUNT, null, null);
		client.Business_Development_Manager__c = bdm.Id;
		client.Prospect_Branch__c = branch.Id;
		client.Assigned_Referral_Partner__c = referralPartner.Id;
		client.Producer__c = producer.Id;
		insert client;

		primaryContact = TestFactoryContact.makeContact('TEST', 'PRIMARY', 'Client Contact', client.Id);
		primaryContact.Primary__c = true;
		insert primaryContact;
	}

	/**
	 * @description loadData loads the base test data.
	 */
	static void loadData() {
		bdm = [SELECT Id FROM User WHERE Name = 'TEST BDMUser'];
		branch = [SELECT Id FROM Account WHERE Name = 'TEST BRANCH' AND RecordType.Name = 'BBSI Branch'];
		referralPartner = [
			SELECT Id
			FROM Account
			WHERE Name = 'TEST REFERRAL PARTNER' AND RecordType.Name = 'Referral Partner'
		];
		client = [
			SELECT Id, Assigned_Referral_Partner__c, Producer__c, External_Id__c
			FROM Account
			WHERE Name = 'TEST CLIENT'
		];
		producer = [SELECT Id FROM Contact WHERE Name = 'TEST PRODUCER'];
		primaryContact = [SELECT Id FROM Contact WHERE Name = 'TEST PRIMARY'];
	}

	/**
	 * @description accountCloneWithPrimaryContact tests the creation of a Lead
	 * from the client account and primary contact.
	 */
	@IsTest
	static void test_accountCloneWithPrimaryContact() {
		loadData();

		Test.startTest();

		PageReference pageRef = Page.NewLeadAccountPage;
		pageRef.getParameters().put('id', client.Id);
		test.setCurrentPage(pageRef);

		ApexPages.StandardController controller = new ApexPages.StandardController(client);

		NewLeadAccountExtension newLeadAccountExtension = new NewLeadAccountExtension(controller);
		PageReference ref = newLeadAccountExtension.newLead();

		Test.stopTest();

		Lead newLead = [SELECT Id, LastName FROM Lead WHERE Company = :NAME_CLIENT_ACCOUNT];

		Assert.isTrue(ref.getURL().contains(newLead.Id), 'PageReference should be to the new Lead');
		Assert.areEqual(
			[SELECT LastName FROM Contact WHERE LastName = 'PRIMARY'].LastName,
			newLead.LastName,
			'New Lead should be based on the Primary Contact'
		);
	}
                                  
    @IsTest
	static void test_accountCloneWithoutPrimaryContact() {
		String nameAccount2 = 'TestAccount 2';

		loadData();

		Account client2 = TestFactoryAccount.makeClient(nameAccount2, referralPartner.Id, producer.Id);
		client2.Business_Development_Manager__c = bdm.Id;
        client2.Phone = '360-555-5555';
		insert client2;

		Test.startTest();

		PageReference pageRef = Page.NewLeadAccountPage;
		pageRef.getParameters().put('id',client2.Id);
		test.setCurrentPage(pageRef);

		ApexPages.StandardController controller = new ApexPages.StandardController(client2);

		NewLeadAccountExtension newLeadAccountExtension = new NewLeadAccountExtension(controller);
		PageReference ref = newLeadAccountExtension.newLead();
        
        Assert.isNotNull(ref);

		Test.stopTest();

		Lead newLead = [SELECT Id, LastName, Company, Cloned_From_Client__c FROM Lead WHERE LastName = 'Unknown'];

		Assert.isTrue(ref.getURL().contains(newLead.Id), 'PageReference should be to the new Lead');
		Assert.areEqual(nameAccount2, newLead.Company, 'Because no Primary Contact, Lead should be unknown');
		Assert.areEqual(client2.External_Id__c, newLead.Cloned_From_Client__c, 'Cloned from Client # should be set');
	}
   
	@IsTest
	static void test_accountCloneWithoutPrimaryContact_NoPhone() {
		String nameAccount2 = 'TestAccount 2';

		loadData();

		Account a2 = TestFactoryAccount.makeClient(nameAccount2, referralPartner.Id, producer.Id);
		a2.Business_Development_Manager__c = bdm.Id;
		a2.Phone = null;
		insert a2;

		Test.startTest();

		PageReference pageRef = Page.NewLeadAccountPage;
		pageRef.getParameters().put('id', a2.Id);
		test.setCurrentPage(pageRef);

		ApexPages.StandardController controller = new ApexPages.StandardController(a2);

		NewLeadAccountExtension newLeadAccountExtension = new NewLeadAccountExtension(controller);
		PageReference ref = newLeadAccountExtension.newLead();

		Test.stopTest();

		try {
			Lead newLead = [SELECT Id, LastName, Company FROM Lead WHERE Name = 'Unknown'];
			Assert.fail('Exception should have been thrown.');
		} catch (Exception e) {
			Assert.isTrue(true, 'Exception should be thrown - missing phone number');
		}
	}

	/**
	 * @description accountCloneMultipleContact tests the creation of a Lead
	 * from the client account with a primary contact and other contacts on
	 * the client account.
	 */
	@IsTest
	static void test_accountCloneMultipleContact() {
		loadData();

		list<Contact> listContact = new List<Contact>();

		for (integer x = 0; x <= 15; x++) {
			Contact c = testFactory.createContact(client, 'Not Primary Contact ' + x, 'Client Contact', false);
			listContact.add(c);
		}

		insert listContact;

		Test.startTest();

		PageReference pageRef = Page.NewLeadAccountPage;
		pageRef.getParameters().put('id', client.Id);
		test.setCurrentPage(pageRef);

		ApexPages.StandardController controller = new ApexPages.StandardController(client);

		NewLeadAccountExtension newLeadAccountExtension = new NewLeadAccountExtension(controller);
		PageReference ref = newLeadAccountExtension.newLead();

		Test.stopTest();

		Lead newLead = [SELECT Id, LastName FROM Lead WHERE Company = :NAME_CLIENT_ACCOUNT];

		Assert.isTrue(ref.getURL().contains(newLead.Id), 'PageReference should be to the new Lead');

		Assert.areEqual(
			[SELECT LastName FROM Contact WHERE LastName = 'PRIMARY'].LastName,
			newLead.LastName,
			'Lead should have the name of the Primary Contact'
		);
	}

	/**
	 * @description accountCloneNoProducer tests the failure of cloning
	 * an account with no producer.
	 */
	@IsTest
	static void test_accountCloneNoProducer() {
		loadData();

		client.Producer__c = null;
		update client;

		Test.startTest();

		PageReference pageRef = Page.NewLeadAccountPage;
		pageRef.getParameters().put('id', client.Id);
		test.setCurrentPage(pageRef);

		ApexPages.StandardController controller = new ApexPages.StandardController(client);

		NewLeadAccountExtension newLeadAccountExtension = new NewLeadAccountExtension(Controller);
		PageReference ref = newLeadAccountExtension.newLead();

		Test.stopTest();

		Assert.isNull(ref, 'Error should have occurred with PageReference not set');
	}

	/**
	 * @description accountCloneInvalidProducer tests the failure of cloning
	 * an account with an invalid producer.
	 */
	@IsTest
	static void test_accountCloneInvalidProducer() {
		loadData();


        Account referralPartner2 = TestFactoryAccount.createReferralPartner('RP 2','% of Margin',12.0,null);
		//Contact producer = TestFactory.createContact(referralPartner2, 'Producer', 'Producer', true);
        Contact producer = TestFactoryContact.createContact('testcontactone','Producer','Producer',referralPartner2.id);
		client.Producer__c = producer.Id;
		update client;

		Test.startTest();

		PageReference pageRef = Page.NewLeadAccountPage;
		pageRef.getParameters().put('id', client.Id);
		test.setCurrentPage(pageRef);

		ApexPages.StandardController controller = new ApexPages.StandardController(client);

		NewLeadAccountExtension newLeadAccountExtension = new NewLeadAccountExtension(Controller);
		PageReference ref = newLeadAccountExtension.newLead();

		Test.stopTest();

		Assert.isNull(ref, 'Error should have occurred with PageReference not set');
	}
}