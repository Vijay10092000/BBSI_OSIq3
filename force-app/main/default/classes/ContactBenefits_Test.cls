@IsTest
@SuppressWarnings('PMD.ApexAssertionsShouldIncludeMessage')
public with sharing class ContactBenefits_Test {
	private static Account client1;
	private static Account client2;
	private static Account client3;
	private static Account client4;
	private static Benefits__c benefits1;
	private static Benefits__c benefits2;
	private static Benefits__c benefits3;
	private static Benefits__c benefits4;
	private static Contact contact1A;
	private static Contact contact1B;
	private static Contact contact2A;
	private static Contact contact2B;
	private static Contact contact3A;
	private static Contact contact4A;

	@TestSetup
	static void makeData() {
        client1 = TestFactoryAccount.makeClient('!!TEST_CLIENT_1', null,null);
        client2 = TestFactoryAccount.makeClient('!!TEST_CLIENT_2', null,null);
        client3 = TestFactoryAccount.makeClient('!!TEST_CLIENT_3', null,null);
		client4 = TestFactoryAccount.makeClient('!!TEST_CLIENT_4', null,null);
        insert new List<Account>{ client1, client2, client3, client4 };
		
        contact1A = TestFactoryContact.makeClient(null, 'TESTCONTACT_1A', client1.id);
		contact1A.Benefits_Contact__c = true;
        contact1B = TestFactoryContact.makeClient(null, 'TESTCONTACT_1B', client1.id);
		contact1B.Benefits_Contact__c = false;
        contact2A = TestFactoryContact.makeClient(null, 'TESTCONTACT_2A', client2.id);
		contact2A.Benefits_Contact__c = true;
		contact2B = TestFactoryContact.makeClient(null, 'TESTCONTACT_2B', client2.id);
		contact2B.Benefits_Contact__c = true;
		contact3A = TestFactoryContact.makeClient(null, 'TESTCONTACT_3A', client3.id);
        contact3A.Benefits_Contact__c = false;
        contact4A = TestFactoryContact.makeClient(null, 'TESTCONTACT_4A', client4.id);
		contact4A.Benefits_Contact__c = true;
		insert new List<Contact>{ contact1A, contact1B, contact2A, contact2B, contact3A, contact4A };
	
        Benefits__c benefits1 = TestFactoryBenefits.makeBenefits('!!TEST_BENEFITS_1',client1.id,contact1A.Id,null,'');
        Benefits__c benefits2 = TestFactoryBenefits.makeBenefits('!!TEST_BENEFITS_2',client2.id, contact2A.Id,null,'');
        Benefits__c benefits3 = TestFactoryBenefits.makeBenefits('!!TEST_BENEFITS_3',client3.id,contact3A.Id,null,'');
        Benefits__c benefits4 = TestFactoryBenefits.makeBenefits('!!TEST_BENEFITS_4',client4.id,contact4A.Id,null,'');		
		insert new List<Benefits__c>{ benefits1, benefits2, benefits3, benefits4 };	
	}

	static void loadData() {
		client1 = [SELECT Id, Name FROM Account WHERE Name = '!!TEST_CLIENT_1' LIMIT 1];
		client2 = [SELECT Id, Name FROM Account WHERE Name = '!!TEST_CLIENT_2' LIMIT 1];
		client3 = [SELECT Id, Name FROM Account WHERE Name = '!!TEST_CLIENT_3' LIMIT 1];
		client4 = [SELECT Id, Name FROM Account WHERE Name = '!!TEST_CLIENT_3' LIMIT 1];
		benefits1 = [SELECT Id, Name, Opportunity__c FROM Benefits__c WHERE Name = '!!TEST_BENEFITS_1' LIMIT 1];
		benefits2 = [SELECT Id, Name, Opportunity__c FROM Benefits__c WHERE Name = '!!TEST_BENEFITS_2' LIMIT 1];
		benefits3 = [SELECT Id, Name, Opportunity__c FROM Benefits__c WHERE Name = '!!TEST_BENEFITS_3' LIMIT 1];
		benefits4 = [SELECT Id, Name, Opportunity__c FROM Benefits__c WHERE Name = '!!TEST_BENEFITS_4' LIMIT 1];

		List<Contact> contacts = [
			SELECT Id, Name, Benefits_Contact__c
			FROM Contact
			WHERE Name LIKE 'TESTCONTACT_%'
			ORDER BY Name ASC
		];
		contact1A = contacts.get(0);
		contact1B = contacts.get(1);
		contact2A = contacts.get(2);
		contact2B = contacts.get(3);
		contact3A = contacts.get(4);
		contact4A = contacts.get(5);

		Assert.areEqual(true, contact1A.Benefits_Contact__c);
		Assert.areEqual(true, contact2A.Benefits_Contact__c);
		Assert.areEqual(false, contact3A.Benefits_Contact__c);
		Assert.areEqual(true, contact4A.Benefits_Contact__c);
	}

	@IsTest
    static void test_updateBenefitsContact() {
		loadData();

		Test.startTest();
		contact1A.Benefits_Contact__c = false;
		contact2A.Benefits_Contact__c = false;
		contact3A.Benefits_Contact__c = true;
		contact4A.Benefits_Contact__c = false;
		update new List<Contact>{ contact1A, Contact2A, contact3A, contact4A };
		Test.stopTest();

		benefits1 = [SELECT Id, Name, LH_Contact_Name__c, Opportunity__c FROM Benefits__c WHERE Name = '!!TEST_BENEFITS_1' LIMIT 1];
		benefits2 = [SELECT Id, Name, LH_Contact_Name__c, Opportunity__c FROM Benefits__c WHERE Name = '!!TEST_BENEFITS_2' LIMIT 1];
		benefits3 = [SELECT Id, Name, LH_Contact_Name__c, Opportunity__c FROM Benefits__c WHERE Name = '!!TEST_BENEFITS_3' LIMIT 1];
		benefits4 = [SELECT Id, Name, LH_Contact_Name__c, Opportunity__c FROM Benefits__c WHERE Name = '!!TEST_BENEFITS_4' LIMIT 1];

		Assert.areEqual(null, benefits1.LH_Contact_Name__c);
		Assert.areEqual(contact2B.id, benefits2.LH_Contact_Name__c);
		Assert.areEqual(contact3A.id, benefits3.LH_Contact_Name__c);
		Assert.areEqual(null, benefits4.LH_Contact_Name__c);
    }
}