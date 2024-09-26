/**
 * @description ClientCancellation_Service_Test contains test methods for the class ClientCancellation_Service.
 */
@IsTest
@SuppressWarnings('PMD.ApexAssertionsShouldIncludeMessage, PMD.AvoidHardcodingId')
public with sharing class ClientCancellation_Service_Test {
	private static final Id FAKE_ACCOUNT_ID = '0015600000k8xToAAI';

	@IsTest
	static void test_createStartTasks() {
		User userSupport = TestFactoryUser.createUser(null,'Support','BBSI Support','910');
		Account client;
		Client_Cancellation__c cancellation;

		Test.startTest();
		System.runAs(userSupport) {
            client = TestFactoryAccount.createClient('CLIENT',null,null);
			cancellation = createCancellation(client.Id);
			insert cancellation;
		}
		Test.stopTest();

		List<Task> tasks = [SELECT Id, OwnerId, Subject FROM Task WHERE WhatId = :cancellation.Id];
		Assert.areEqual(1, tasks.size(), 'A task should have been created for the Client Cancellation');
		Assert.areEqual(
			String.valueOf(userSupport.Id),
			String.valueOf(tasks.get(0).OwnerId),
			'Task owner should be same as account owner'
		);
	}

	private static Client_Cancellation__c createCancellation(Id idClient) {
		Map<String, Object> fldMap = new Map<String, Object>{
			'Last_Check_Date__c' => Date.newInstance(2022, 1, 1),
			'Where_did_the_business_go__c' => 'Payroll Competitor',
			'Where_Framework_Failed__c' => 'Market'
		};
		return TestFactoryClientCancellation.makeClientCancellation(idClient, Date.newInstance(2022, 1, 1), 'Client', fldMap);
	}

	@IsTest
	public static void test_getPrimaryContacts() {
        Account client1 = TestFactoryAccount.makeClient('Client ONE',null,null);
		client1.Primary_Contact_Name__c = 'CONTACTONEA';
        Account client2 = TestFactoryAccount.makeClient('Client TWO',null,null);
		client2.Primary_Contact_Name__c = 'No Contact';
		Account client3 = TestFactoryAccount.makeClient('Client THREE',null,null);
        client3.Primary_Contact_Name__c = null;
		List<Account> clients = new List<Account>{ client1, client2, client3 };
		insert clients;

		Map<Id, Account> mapClients = new Map<Id, Account>(clients);
        Contact contact1A = TestFactoryContact.makeContact(null, 'CONTACTONEA', 'Client Contact', client1.id);
        Contact contact1B = TestFactoryContact.makeContact(null, 'CONTACTONEB', 'Client Contact', client1.id);
        Contact contact2A = TestFactoryContact.makeContact(null, 'CONTACTONEB', 'Client Contact', client1.id);
		insert new List<Contact>{ contact1A, contact1B, contact2A };

		Test.startTest();
		Map<Id, Contact> contacts = ClientCancellation_Service.getPrimaryContacts(mapClients);
		Test.stopTest();

		Assert.areEqual(3, contacts.size());
		Assert.isTrue(contacts.containsKey(client1.Id));
		Assert.areEqual(contact1A.Id, contacts.get(client1.Id).Id);
		Assert.areEqual(null, contacts.get(client2.Id));
		Assert.areEqual(null, contacts.get(client3.Id));
	}

	@IsTest
	public static void test_updateRevoke() {
		Date today = Date.today();
		Date yesterday = today.addDays(-1);

		Account client1 = TestFactoryAccount.makeClient('Client ONE', null, null);
		client1.Status__c = 'Terminated';
		client1.RecordTypeId = RecordTypeService.getId('Account', 'Terminated');
		client1.Cancellation_Reason__c = 'BUSINESS CLOSED';
		insert client1;
        
        Map<String, Object> fldMap = new Map<String, Object>{
			'AM_Approval_Status__c' => 'Approved',
			'Cancellation_Attachment__c' => true,
			'Cancellation_decision_due_to_COVID_19__c' => 'Yes',
			'AM_Comments__c' => 'Test cancellation',
			'Contracts_Comments__c' => 'Test cancellation',
			'Employees_Notified__c' => yesterday,
			'Last_Check_Date__c' => yesterday,
			'Reason_for_Cancellation__c' => 'BUSINESS CLOSED',
			'Revoke__c' => false,
			'Revoked_Reason__c' => null,
			'Where_did_the_business_go__c' => 'Business Closed',
			'Where_Framework_Failed__c' => 'N/A',
			'Contracts_Reviewed__c' => true
		};
		
		Client_Cancellation__c cc1 = TestFactoryClientCancellation.createClientCancellation(client1.Id,today,'Client', fldMap);
        client1 = [SELECT Id, Name, Cancellation_Reason__c FROM Account WHERE Id = :client1.Id];
		Assert.areEqual('BUSINESS CLOSED', client1.Cancellation_Reason__c);

		Test.startTest();
		cc1.Revoke__c = true;
		cc1.Revoked_Reason__c = 'Test';
		update cc1;
		Test.stopTest();

		client1 = [SELECT Id, Name, Cancellation_Reason__c FROM Account WHERE Id = :client1.Id];
		Assert.isNull(client1.Cancellation_Reason__c);
	}
}