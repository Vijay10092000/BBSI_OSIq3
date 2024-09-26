/**
 * @description Event_Services_Test contains test methods for the Event_Services class.
 */
@IsTest
@SuppressWarnings('PMD.ApexAssertionsShouldIncludeMessage')
public without sharing class Event_Services_Test {
	private static User user;
	private static Account referralPartner;
	private static Account client;
	private static String eventRPGeneralRT = 'Referral Partner General';
	private static Lead lead;
	private static Lead lead1;
	private static Account branch;
	private static User bdm;

	@TestSetup
	static void makeTestData() {
		branch = TestFactoryAccount.makeBranch('!!TEST BRANCH', '1000', null, null);
		referralPartner = TestFactoryAccount.makeReferralPartner('!!REFERRAL PARTNER', '% of Margin', 8.9, null);
		client = TestFactoryAccount.makeClient('!!CLIENT', null, null);
		insert new List<Account>{branch, referralPartner, client};
		user = TestFactoryUser.makeUser(null, 'TESTUSER', 'System Administrator', '1000', 'user@bbsi.zzz', 'user@bbsi.zzz');	
		bdm = TestFactoryUser.makeBDM('Test1', 'TestBDM', 'BBSI Standard', branch.External_Id__c);
		insert new List<User>{user, bdm};

		lead = TestFactoryLead.makeLeadRP('TEST_LEAD', 'ONE', 'ONE BBT.');
		lead.Campaign_List_Name__c = 'A Hsform campaign';
		lead1 = TestFactoryLead.makeLeadRP('TEST_LEAD', 'TWO', 'TWO BBT.');
		lead.Campaign_List_Name__c = 'CAMPAIGN 1';

		insert new List<Lead>{lead, lead1};
	}

	static void loadTestData() {
		for(User item:[SELECT Id, Name, UserName, LastName FROM User Order by CreatedDate DESC limit 2]){
			if(item.LastName == 'TESTUSER'){
				user = item;
			}
			else if(item.LastName == 'TestBDM'){
				bdm = item;
			}
		}
		for(Account item:[SELECT Id, Name FROM Account Order by CreatedDate DESC limit 3]){
			if(item.Name == '!!TEST BRANCH'){
				branch = item;
			}
			else if(item.Name == '!!REFERRAL PARTNER'){
				referralPartner = item;
			}
			else if(item.Name == '!!CLIENT'){
				client = item;
			}
		}
		for(Lead item:[SELECT Id, Name, LastName FROM Lead Order by CreatedDate DESC limit 2]){
			if(item.LastName == 'ONE'){
				lead = item;
			}
			else if(item.LastName == 'TWO'){
				lead1 = item;
			}
		}
	}

	@IsTest
	static void test_createTasks() {
		loadTestData();
		Event event1 = TestFactoryEvent.createReferralPartnerGeneralEvent(user.Id, referralPartner.Id, null, 'Meeting', null);			
		List<Task> tasks = [SELECT OwnerId, WhatId FROM Task WHERE OwnerId = :user.Id];
		Assert.areEqual(1, tasks.size(), 'Only Referral Partner Event task should be created');
		Assert.areEqual(event1.WhatId, tasks.get(0).WhatId, 'Only Referral Partner Event task should be created');
	}

	@IsTest
	static void test_getEventsNeedingTasks() {
		loadTestData();
		Event event1 = TestFactoryEvent.makeEvent(eventRPGeneralRT, user.Id, referralPartner.Id, null, 'Meeting', null);		
		Event event2 = TestFactoryEvent.makeEvent(eventRPGeneralRT, user.Id, referralPartner.Id, null, 'Meeting', null);
		event2.ActivityDateTime = null;
		event2.IsAllDayEvent = true;		
		Test.startTest();
		List<Event> events = Event_Services.getEventsNeedingTasks(null, new List<Event>{ event1, event2 });
		Test.stopTest();

		Assert.areEqual(2, events.size(), 'Retrieve both events');
	}

	@IsTest
	static void test_getRelatedReferralPartners() {
		loadTestData();
		Event event1 = TestFactoryEvent.makeEvent(eventRPGeneralRT, user.Id, referralPartner.Id, null, 'Meeting', null);		
		Event event2 = TestFactoryEvent.makeEvent(eventRPGeneralRT, user.Id, referralPartner.Id, null, 'Meeting', null);
			
		Test.startTest();
		Map<Id, Account> mapAccounts = Event_Services.getRelatedReferralPartners(new List<Event>{ event1, event2 });
		Test.stopTest();

		Assert.areEqual(1, mapAccounts.size(), 'Only on Referral Partner');
	}

	@IsTest
	static void test_createEventTask() {
		loadTestData();
		Date oneWeek = Date.today().addDays(7);
		Event event = TestFactoryEvent.makeEvent(eventRPGeneralRT, user.Id, referralPartner.Id, null, 'Meeting', null); 
		Event event1 = TestFactoryEvent.makeEvent(eventRPGeneralRT, user.Id, referralPartner.Id, null, 'Meeting', null); 
		event1.IsAllDayEvent = true;
		event1.ActivityDate = System.today();
		Event event2 = TestFactoryEvent.makeEvent(eventRPGeneralRT, user.Id, referralPartner.Id, null, 'Meeting', null); 
		event2.IsAllDayEvent = true;
		event2.ActivityDate = System.today()+1;

		Map<Id, Account> mapAccounts = new Map<Id, Account>();
		mapAccounts.put(referralPartner.Id, referralPartner);

		Test.startTest();
		Task task = Event_Services.createEventTask(event, mapAccounts);
		Event_Services.createEventTask(event1, new Map<Id, Account>());
		Event_Services.createEventTask(event2, mapAccounts);
		Test.stopTest();

		Assert.areNotEqual(null, task, 'Task should be created');
		Assert.areEqual('Follow Up', task.Type, 'Task of type "Follow Up"');
		Assert.areEqual(referralPartner.Id, task.WhatId, 'One week out');
		Assert.areEqual(oneWeek, task.ActivityDate, 'One week out');
	}

	@IsTest
	static void test_CreateEventOnLead() {
		loadTestData();
		Event event = new event();

		Test.startTest();
		event = TestFactoryEvent.createReferralPartnerGeneralEvent(user.Id, null, lead.Id, 'Meeting', null);
		Test.stopTest();

		event = [
			SELECT Id, RecordType.Name
			FROM Event
			WHERE Id = :event.Id
		];

		Assert.areEqual('Lead Event', event.RecordType.Name, 'Should change to Record Type "Lead Event"');
	}

	@IsTest
	static void test_SetSalesDevelopmentRepresentative() {
		loadTestData();
		Date oneWeek = Date.today().addDays(7);

		Account prospect = TestFactoryAccount.makeProspect('TEST PROSPECT', null, null);
		prospect.Sales_Development_Representative__c = user.Id;
		insert prospect;

		Opportunity opp = TestFactoryOpportunity.makeClient('PROSPECT 1 OPPORTUNITY', prospect.Id, oneWeek, Opportunity_Service.STAGE_DISCOVERY_MEETING);
		opp.Amount = 1000.00;
		insert opp;

		Test.startTest();

		Event event = TestFactoryEvent.createReferralPartnerGeneralEvent(
						user.Id, 
						prospect.Id, 
						null,
						Event_Services.FIRST_MEETING, 
						new Map<String, Object>{
							'ActivityDate' => Date.today(),
							'Description' => 'TEST PROSPECT First Meeting'
						});
		Test.stopTest();

		opp = [SELECT Id, Name, Sales_Development_Representative__c FROM Opportunity WHERE AccountId = :prospect.Id];
		Assert.areEqual(user.Id, opp.Sales_Development_Representative__c, 'Sales Development Representative should have been set');
	}
	@IsTest
	static void test_BlockInvalidCreation(){
		loadTestData();

		Event event1 = TestFactoryEvent.makeEvent(Event_Services.RECORDTYPE_CLIENT_GENERAL, user.Id, referralPartner.Id, null, Event_Services.FIRST_MEETING, null);		
		Event event2 = TestFactoryEvent.makeEvent(Event_Services.RECORDTYPE_CLIENT_GENERAL, user.Id, referralPartner.Id, null, Event_Services.FIRST_MEETING, null);
		Test.startTest();
		insert new List<Event>{ event1, event2};
		Test.stopTest();
		List<Task> tasks = [SELECT OwnerId, WhatId FROM Task WHERE OwnerId = :user.Id];
		Assert.areEqual(2, tasks.size(), 'Retrieve All events');
	}
	@IsTest
	static void test_validateFields(){
		loadTestData();

		Event event = TestFactoryEvent.makeEvent(
			Event_Services.RECORDTYPE_CLIENT_GENERAL, 
			user.Id, referralPartner.Id, 
			client.Id, 
			Event_Services.FIRST_MEETING, 
			new Map<String, Object>{ 'Meeting_Result__c' => 'Completed - Bad Fit' }
		);

		Event_Services.validateFields(null, new List<Event>{ event });

		Assert.isTrue(event.hasErrors(), 'Event should have an error');
	}

	@IsTest
	static void test_BlockInvalidNagetive(){
		loadTestData();
		Event event1 = TestFactoryEvent.makeEvent(Event_Services.RECORDTYPE_CLIENT_GENERAL, user.Id, referralPartner.Id, null, Event_Services.FIRST_MEETING, null);		
		Event event2 = TestFactoryEvent.makeEvent(Event_Services.RECORDTYPE_CLIENT_GENERAL, user.Id, referralPartner.Id, null, Event_Services.FIRST_MEETING, null);
		event1.whoId = client.Id;
		event2.whoId = client.Id;
		Test.startTest();
		Event_Services.blockInvalidCreation(new List<Event>{ event1, event2 });
		Test.stopTest();
		List<Task> tasks = [SELECT OwnerId, WhatId FROM Task WHERE OwnerId = :user.Id];
		Assert.areEqual(0, tasks.size(), 'Shold be Empty');
	}
	@IsTest
	static void test_updateFirstMeetingLeads(){
		loadTestData();
		Event event1 = TestFactoryEvent.makeEvent(Event_Services.RECORDTYPE_LEAD_EVENT, user.Id, referralPartner.Id, null, Event_Services.FIRST_MEETING, null);		
		Event event2 = TestFactoryEvent.makeEvent(Event_Services.RECORDTYPE_LEAD_EVENT, user.Id, referralPartner.Id, null, Event_Services.FIRST_MEETING, null);
		Event event3 = TestFactoryEvent.makeEvent(Event_Services.RECORDTYPE_LEAD_EVENT, user.Id,referralPartner.Id, null, Event_Services.FIRST_MEETING, null);
		Test.startTest();
		insert new List<Event>{ event1, event2, event3 };
		event1.Meeting_Result__c = 'Completed - Good Fit';
		event2.Meeting_Result__c = 'Completed - Bad Fit';
		event2.Reason_for_Bad_Fit__c = 'Risk';
		event3.Meeting_Result__c = 'Cancelled by BBSI';
		event3.Reason_for_Event_Cancellation__c = 'Risk';
		update new List<Event>{ event1, event2, event3 };
		Test.stopTest();		
		List<Task> tasks = [SELECT Meeting_Result__c, OwnerId, WhatId FROM Task WHERE OwnerId = :user.Id];
		Assert.areEqual(3, tasks.size(), 'Retrieve All events');
	}	
	@IsTest
	static void test_initializeLeadEventFields(){
		loadTestData();
		Lead lead2 = TestFactoryLead.createLeadRP('TEST_LEAD', 'Three', 'ONE BBT.');
		Event event1 = TestFactoryEvent.makeEvent(Event_Services.RECORDTYPE_LEAD_EVENT, user.Id, null, lead2.Id, Event_Services.FIRST_MEETING, null);		
		Event event2 = TestFactoryEvent.makeEvent(Event_Services.RECORDTYPE_LEAD_EVENT, user.Id, null, lead.Id, Event_Services.FIRST_MEETING, null);
		Event event3 = TestFactoryEvent.makeEvent(Event_Services.RECORDTYPE_LEAD_EVENT, user.Id, null, lead.Id, Event_Services.FIRST_MEETING, null);
		Event event4 = TestFactoryEvent.makeEvent(Event_Services.RECORDTYPE_LEAD_EVENT, user.Id, null, lead1.Id, Event_Services.FIRST_MEETING, null);
		Event event5 = TestFactoryEvent.makeEvent(Event_Services.RECORDTYPE_LEAD_EVENT, user.Id, null, lead1.Id, Event_Services.FIRST_MEETING, null);
		event1.Meeting_Result__c = 'Completed - Good Fit';
		event2.Meeting_Result__c = 'Cancelled by BBSI';
		event2.Reason_for_Event_Cancellation__c = 'Risk';
		event3.Meeting_Result__c = 'Completed - Good Fit';
		event4.Meeting_Result__c = 'Completed - Bad Fit';
		event4.Reason_for_Bad_Fit__c = 'Risk';
		event5.Meeting_Result__c = 'Cancelled by BBSI';
		event5.Reason_for_Event_Cancellation__c = 'Risk';
		Test.startTest();
		insert new List<Event>{ event1, event2, event3, event4, event5 };
		Test.stopTest();
		List<Task> tasks = [SELECT Meeting_Result__c, OwnerId, WhatId FROM Task WHERE OwnerId = :user.Id];
		Assert.areEqual(0, tasks.size(), 'Retrieve All events');
	}
	@IsTest
	static void test_initializeClientGeneralFields(){
		loadTestData();
		Lead lead2 = TestFactoryLead.createLeadRP('TEST_LEAD', 'Three', 'ONE BBT.');
		Event event1 = TestFactoryEvent.makeEvent(Event_Services.RECORDTYPE_CLIENT_GENERAL, user.Id, referralPartner.Id, null, Event_Services.FIRST_MEETING, null);		
		Event event2 = TestFactoryEvent.makeEvent(Event_Services.RECORDTYPE_CLIENT_GENERAL, user.Id, referralPartner.Id, null, Event_Services.FIRST_MEETING, null);
		Event event3 = TestFactoryEvent.makeEvent(Event_Services.RECORDTYPE_CLIENT_GENERAL, user.Id, referralPartner.Id, null, Event_Services.FIRST_MEETING, null);
		Event event4 = TestFactoryEvent.makeEvent(Event_Services.RECORDTYPE_CLIENT_GENERAL, user.Id, referralPartner.Id, null, Event_Services.FIRST_MEETING, null);
		Event event5 = TestFactoryEvent.makeEvent(Event_Services.RECORDTYPE_CLIENT_GENERAL, user.Id, referralPartner.Id, null, Event_Services.FIRST_MEETING, null);		
		Test.startTest();
		insert new List<Event>{ event1, event2, event3, event4, event5 };
		event1.Meeting_Result__c = 'Completed - Good Fit';
		event2.Meeting_Result__c = 'Cancelled by BBSI';
		event2.Reason_for_Event_Cancellation__c = 'Risk';
		event3.Meeting_Result__c = 'Completed - Good Fit';
		event4.Meeting_Result__c = 'Completed - Bad Fit';
		event4.Reason_for_Bad_Fit__c = 'Risk';
		event5.Meeting_Result__c = 'Cancelled by BBSI';
		event5.Reason_for_Event_Cancellation__c = 'Risk';
		update new List<Event>{ event1, event2, event3, event4, event5 };
		Test.stopTest();
		List<Task> tasks = [SELECT Meeting_Result__c, OwnerId, WhatId FROM Task WHERE OwnerId = :user.Id];
		Assert.areEqual(5, tasks.size(), 'Retrieve All events');
	}
	@IsTest
	static void test_createClientEventOpportunities(){
		loadTestData();
		Contact producer1 = TestFactoryContact.makeContact( 'Firstname1' , 'Lastname1', 'BBSI Employee',referralPartner.id );
		insert producer1;
        
		Account prospect1 = TestFactoryAccount.makeProspect('Prospect', null, null);
		prospect1.Producer__c = producer1.Id;
		prospect1.Assigned_Referral_Partner__c = referralPartner.Id;
		Account prospect2 = TestFactoryAccount.makeProspect('Prospect', null, null);
		prospect2.Producer__c = producer1.Id;
		prospect2.Assigned_Referral_Partner__c = referralPartner.Id;
		Account prospect3 = TestFactoryAccount.makeProspect('Prospect', null, null);
		prospect3.Producer__c = producer1.Id;
		prospect3.Assigned_Referral_Partner__c = referralPartner.Id;
		Account prospect4 = TestFactoryAccount.makeProspect('Prospect', null, null);
		prospect4.Producer__c = producer1.Id;
		prospect4.Assigned_Referral_Partner__c = referralPartner.Id;
		Account prospect5 = TestFactoryAccount.makeProspect('Prospect', null, null);
		prospect5.Producer__c = producer1.Id;
		prospect5.Assigned_Referral_Partner__c = referralPartner.Id;
		insert new List<Account> {prospect1, prospect2, prospect3, prospect4, prospect5};
		User owner = TestFactoryUser.createUser(null, 'bbsiTESTUSER', 'BBSI Call Center', '910');
		Lead lead2 = TestFactoryLead.createLeadRP('TEST_LEAD', 'Three', 'ONE BBT.');
		Event event1 = TestFactoryEvent.makeEvent(Event_Services.RECORDTYPE_CLIENT_GENERAL, user.Id, prospect1.Id, null, Event_Services.FIRST_MEETING, null);		
		Event event2 = TestFactoryEvent.makeEvent(Event_Services.RECORDTYPE_CLIENT_GENERAL, user.Id, prospect2.Id, null, Event_Services.FIRST_MEETING, null);
		Event event3 = TestFactoryEvent.makeEvent(Event_Services.RECORDTYPE_CLIENT_GENERAL, user.Id, prospect3.Id, null, Event_Services.FIRST_MEETING, null);
		Event event4 = TestFactoryEvent.makeEvent(Event_Services.RECORDTYPE_CLIENT_GENERAL, user.Id, prospect4.Id, null, Event_Services.FIRST_MEETING, null);
		Event event5 = TestFactoryEvent.makeEvent(Event_Services.RECORDTYPE_CLIENT_GENERAL, user.Id, prospect5.Id, null, Event_Services.FIRST_MEETING, null);		
		Test.startTest();		
		System.runAs(owner){
			insert new List<Event>{ event1, event2, event3, event4, event5 };
			event1.Meeting_Result__c = 'Completed - Good Fit';
			event2.Meeting_Result__c = 'Cancelled by BBSI';
			event2.Reason_for_Event_Cancellation__c = 'Risk';
			event3.Meeting_Result__c = 'Completed - Good Fit';
			event4.Meeting_Result__c = 'Completed - Bad Fit';
			event4.Reason_for_Bad_Fit__c = 'Risk';
			event5.Meeting_Result__c = 'Cancelled by BBSI';
			event5.Reason_for_Event_Cancellation__c = 'Risk';
			event5.Event_Source__c = 'Campaign';
			update new List<Event>{ event1, event2, event3, event4, event5 };
		}
		Test.stopTest();
		List<Task> tasks = [SELECT Meeting_Result__c, OwnerId, WhatId FROM Task WHERE OwnerId = :user.Id];
		Assert.areEqual(0, tasks.size(), 'Retrieve All events');
	}	

	@IsTest
	public static void test_determineEventSource() {
		Assert.areEqual('Outbound', Event_Services.determineEventSource(null), 'Not handling null');
		Assert.areEqual('Outbound', Event_Services.determineEventSource(''), 'Not handling empty string');
		Assert.areEqual('Inbound', Event_Services.determineEventSource('A hsForm'), 'Not handling HFORM');
		Assert.areEqual('Campaign', Event_Services.determineEventSource('CAMPAIGN NAME'), 'Not handling a campaign name');
	}
}