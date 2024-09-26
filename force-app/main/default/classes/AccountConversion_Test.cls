/**
 * @description AccountConversion_Test contains tests for the AccountConversion class.
 */
@IsTest
public with sharing class AccountConversion_Test {
	private static final String FAKE_LEAD_ID = '00Q000000000t75';
	private static final String FAKE_ACCOUNT_ID = '0015600000k8xT7AAI';

	@IsTest
	public static void test_getConvertedAccounts() {		
		Account converted = new Account( Name = 'CONVERTED', Lead_Converted_Id__c = FAKE_LEAD_ID);
		Account notConverted = new Account( Name = 'NOT CONVERTED');

		Test.startTest();

		List<Account> accounts = AccountConversion.getConvertedAccounts(new List<Account>{ converted, notConverted });

		Test.stopTest();
		
		Assert.areEqual(1, accounts.size(), 'Should have one record');
		Assert.areEqual('CONVERTED', accounts.get(0).Name, 'Record should be the converted one');
	}
	
	@IsTest
	public static void test_checkRecordType() {
		Id idClient = RecordTypeService.getId('Account', 'Prospect');
		Id idRP = RecordTypeService.getId('Account', 'Referral Partner');
		
		Account client = new Account( Name = 'CONVERTED', Lead_Record_Type__c = 'Client_Lead' );
		Account rp = new Account( Name = 'NOT CONVERTED', Lead_Record_Type__c = 'Referral_Partner_Lead' );

		Test.startTest();

		AccountConversion.checkRecordType(new List<Account>{ client, rp });

		Test.stopTest();
		
		Assert.areEqual(idClient, client.RecordTypeId, 'Should have set Client Record Type Id');
		Assert.areEqual(idRP, rp.RecordTypeId, 'Should have set Referral Partner Record Type Id');
	}
	
	@IsTest
	public static void test_getRelatedEvents() {
		Lead lead1 = TestFactoryLead.makeClientLead('Client', 'ONE', 'BBSI TEST COMPANY 1', null, null);
		Lead lead2 = TestFactoryLead.makeClientLead('Client', 'TWO', 'BBSI TEST COMPANY 2', null, null);
		insert new List<Lead>{ lead1, lead2 };

		Event event = TestFactoryEvent.createEvent(
			null,
			UserInfo.getUserId(),
			null,
			lead1.Id,
			Event_Services.FIRST_MEETING,
			null
		);

		Test.startTest();

		Map<Id, List<Event>> events = AccountConversion.getRelatedEvents(new Set<Id>{ lead1.Id, lead2.Id }, 'FIRST MEETING');
	
		Test.stopTest();

		Assert.areEqual(2, events.keySet().size(), 'Should have one for each Lead');
		Assert.areEqual(1, events.get(lead1.Id).size(), 'Should have an Event for Lead 1');
		Assert.areEqual(0, events.get(lead2.Id).size(), 'Should have no Events for Lead 2');
	}
	
	@IsTest
	public static void test_getRelatedLeads() {
		Lead lead = TestFactoryLead.createClientLead('Client', 'TEST', 'BBSI TEST COMPANY', null, null);

		Account client = new Account(Name = 'TEST ACCOUNT', Lead_Converted_Id__c = lead.Id);

		Test.startTest();

		Map<Id, Lead> leads = AccountConversion.getRelatedLeads(new List<Account>{ client });

		Test.stopTest();
		
		Assert.areEqual(1, leads.keySet().size(), 'Should have one for the Lead');
		Assert.isTrue(leads.containsKey(lead.Id), 'Should be for the Lead');
	}
	
	@IsTest
	public static void test_updateFirstMeeting() {	
		Lead lead = TestFactoryLead.createClientLead('Client', 'TEST', 'BBSI TEST COMPANY', null, null);

		Event event = TestFactoryEvent.createEvent(
			null,
			UserInfo.getUserId(),
			null,
			lead.Id,
			Event_Services.FIRST_MEETING,
			null //new Map<String, Object> { 'Event_Source__c' => 'Inbound' }
		);

		Account client = TestFactoryAccount.createClient('BBSI TEST COMPANY');
		client.Lead_Converted_Id__c = lead.Id;
		client.First_Meeting_Event_Id__c = null;
		client.First_Meeting_Event_Source__c = null;
		client.First_Meeting_Event_Date__c = null;
		client.First_Meeting_Event_Creator__c = null;

		Test.startTest();

		AccountConversion.updateFirstMeeting(new List<Account>{ client });

		Test.stopTest();		
		
		Assert.areEqual(event.Id, client.First_Meeting_Event_Id__c);
		Assert.areEqual('Outbound', client.First_Meeting_Event_Source__c);
		Assert.areEqual(Date.today().format(), client.First_Meeting_Event_Date__c);
		Assert.areEqual(UserInfo.getName(), client.First_Meeting_Event_Creator__c);
	}
	
	@IsTest
	public static void test_updateConvertedAccounts() {
		Lead lead = TestFactoryLead.createClientLead('Client', 'TEST', 'BBSI TEST COMPANY', null, null);

		Event event = TestFactoryEvent.createEvent(
			null,
			UserInfo.getUserId(),
			null,
			lead.Id,
			Event_Services.FIRST_MEETING,
			null
		);

		Test.startTest();

		Database.LeadConvertResult lcr = LeadConvert.convert(Lead.Id, true);
		Assert.isTrue(lcr.isSuccess(), 'Lead conversion failed');
	
		Test.stopTest();

		Account client = [
			SELECT Id, First_Meeting_Event_Id__c, First_Meeting_Event_Source__c, First_Meeting_Event_Date__c, First_Meeting_Event_Creator__c
			FROM Account
			WHERE Lead_Converted_Id__c = :lead.Id
			LIMIT 1
		];

		Assert.areEqual(event.Id, client.First_Meeting_Event_Id__c);
		Assert.areEqual('Outbound', client.First_Meeting_Event_Source__c);
		Assert.areEqual(Date.today().format(), client.First_Meeting_Event_Date__c);
		Assert.areEqual(UserInfo.getName(), client.First_Meeting_Event_Creator__c);
	}
}