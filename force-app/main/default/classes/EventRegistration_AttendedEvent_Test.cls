/**
 * @description EventRegistration_AttendedEvent_Test contains tests for the EventRegistration_AttendedEvent class
 */
@IsTest
@SuppressWarnings('PMD.AvoidHardcodingId, PMD.ApexAssertionsShouldIncludeMessage')
public with sharing class EventRegistration_AttendedEvent_Test {
	private static final Id FAKE_EVENT_ID = Id.valueOf('00U500000148cYGEAY');
	private static final Id FAKE_CONTACT_ID = Id.valueOf('0032J00003LCg0rQAD');

	private static Event__c eventBBSIOne;
	private static Event__c eventBBSITwo;
	private static Account branch;
	private static Account clientOne;
	private static Account clientTwo;
	private static Contact contactOne;
	private static Contact contactTwo;

	@TestSetup
	static void makeData() {
		branch = TestFactoryAccount.makeBranch('!!!TEST BRANCH', '9001', null, null);
		clientOne = TestFactoryAccount.makeClient('!!!TEST CLIENT ONE', null, null);
		clientTwo = TestFactoryAccount.makeClient('!!!TEST CLIENT TWO', null, null);
		insert new List<Account>{ branch, clientOne, clientTwo };

		User manager = TestFactoryUser.createUser('Test', 'Manager', 'BBSI Support', '9001');

		contactOne = TestFactoryContact.makeClient('Test', 'ContractOne', clientOne.Id);
		contactTwo = TestFactoryContact.makeClient('Test', 'ContractOne', clientTwo.Id);
		insert new List<Contact>{ contactOne, contactTwo };

        Id idrtEventClient = RecordTypeService.getId('Event__c', 'Client Event');

        Date today = Date.today();

        eventBBSIOne = new Event__c(
            RecordTypeId = idrtEventClient,
            Event_Start_Date__c = today.addMonths(1),
            Event_End_Date__c = today.addMonths(1),
            Event_Type__c = 'Meeting',
            Event_Type_Other__c = '',
            Event_Manager__c = manager.Id,
            Budget_Overall__c = 10000,
            Final_Cost__c = 10000,
            Region__c = 'NoCal'
        );

        eventBBSITwo = new Event__c(
            RecordTypeId = idrtEventClient,
            Event_Start_Date__c = today.addMonths(2),
            Event_End_Date__c = today.addMonths(2),
            Event_Type__c = 'Other',
            Event_Type_Other__c = 'Describe Other',
            Event_Manager__c = manager.Id,
            Budget_Overall__c = 10000,
            Final_Cost__c = 10000,
            Region__c = 'SoCal'
        );

        insert new List<Event__c>{ eventBBSIOne, eventBBSITwo };
    }

    static void loadData() {
        List<Event__c> eventBBSIs = [
            SELECT Id, Name, Event_Type__c, Event_Start_Date__c, Event_End_Date__c, Region__c, RecordType.Name
            FROM Event__c
            ORDER BY Event_Start_Date__c
        ];
        eventBBSIOne = eventBBSIs.get(0);
        eventBBSITwo = eventBBSIs.get(1);

        List<Account> accounts = [SELECT Id, Name FROM Account WHERE Name LIKE '!!!TEST%' ORDER BY Name];
		branch = accounts.get(0);
        clientOne = accounts.get(1);
        clientTwo = accounts.get(2);

        List<Contact> contacts = [SELECT Id, Name FROM Contact ORDER BY Name];
        contactOne = contacts.get(0);
        contactTwo = contacts.get(1);
    }

    @IsTest
    public static void test_createEventRelation() {
        EventRegistration_AttendedEvent erae = new EventRegistration_AttendedEvent();

        EventRelation er = erae.createEventRelation(FAKE_EVENT_ID, FAKE_CONTACT_ID);

        Assert.areEqual(FAKE_EVENT_ID, er.EventId);
        Assert.areEqual(FAKE_CONTACT_ID, er.RelationId);
        Assert.areEqual(true, er.IsParent);
        Assert.areEqual(false, er.IsWhat);
    }

    @IsTest
    public static void test_createEvent() {
        loadData();

        EventRegistration_AttendedEvent erae = new EventRegistration_AttendedEvent();

        // erae.createNewEventData();

        Assert.areEqual('Client Event', eventBBSIOne.RecordType.Name);
        // Assert.areEqual(erae.newEventData.keySet().contains(eventBBSIOne.RecordType.Name));

        Event event = erae.createEvent(clientOne.Id, contactOne.Id, eventBBSIOne);

        Assert.areNotEqual(null, event);
        Assert.areEqual(eventBBSIOne.Id, event.Event__c);
        Assert.areEqual(eventBBSIOne.Event_Start_Date__c, event.StartDateTime);
        Assert.areEqual(eventBBSIOne.Event_Start_Date__c, event.ActivityDateTime);
        Assert.areEqual(eventBBSIOne.Event_End_Date__c, event.EndDateTime);
        Assert.areEqual(contactOne.Id, event.WhoId);
        Assert.areEqual(clientOne.Id, event.WhatId);
        Assert.areEqual('Meeting', event.Type);
        Assert.areEqual('Client Event - Meeting', event.Subject);
    }

    @IsTest
    public static void test_CreateEventAndRelationship() {
        loadData();

        Event_Registration__c erOne = new Event_Registration__c(
            Company1__c = clientOne.Id,
            Contact__c = contactOne.Id,
            Contact_Type__c = 'Client',
            Event__c = eventBBSIOne.Id,
            Attended__c = true
        );

        Test.startTest();

        EventRegistration_AttendedEvent erae = new EventRegistration_AttendedEvent();
        erae.perform(new List<Event_Registration__c>{ erOne });

        Test.stopTest();

        List<Event> events = [
            SELECT Id, Subject, WhoId, WhatId, Type, Event__c, StartDateTime, IsAllDayEvent
            FROM Event
            ORDER BY CreatedDate
        ];

        Assert.areEqual(1, events.size());

        Event event = events.get(0);
        Assert.isTrue(event.IsAllDayEvent);
        Assert.areEqual(contactOne.Id, event.WhoId);
        Assert.areEqual(clientOne.Id, event.WhatId);
        Assert.areEqual('Meeting', event.Type);
        Assert.areEqual(eventBBSIOne.Id, event.Event__c);
        Assert.areEqual('Client Event - Meeting', event.Subject);

        List<EventRelation> eventRelations = [
            SELECT Id, EventId, RelationId, IsParent, IsWhat, AccountId, Status
            FROM EventRelation
            ORDER BY RelationId
        ];

        Assert.areEqual(2, eventRelations.size());
        EventRelation er = eventRelations.get(0);

        Assert.areEqual(event.Id, er.EventId);
        Assert.areEqual(clientOne.Id, er.RelationId);
        Assert.areEqual(true, er.IsParent);
        Assert.areEqual(true, er.IsWhat);

        er = eventRelations.get(1);
        Assert.areEqual(event.Id, er.EventId);
        Assert.areEqual(contactOne.Id, er.RelationId);
        Assert.areEqual(true, er.IsParent);
        Assert.areEqual(false, er.IsWhat);
    }
}