/**
 * @description EventRegistration_AttendedEvent keeps regular and custom events sync'ed.
 */
public without sharing class EventRegistration_AttendedEvent {
    @TestVisible
    private List<Event_Registration__c> listWork;

    private Set<Id> eventIds;
    private Set<Id> contactIds;
    private Map<Id, Id> mapContactAccount = new Map<Id, Id>();
    private Map<Id, Event__c> mapEventBBSI;
    private Map<Id, Event> mapEvents;

    /**
     * @description perform sets up and perform the actions.
     * @param listRegistrations Event_Registration__cs checking
     */
    public void perform(List<Event_Registration__c> listRegistrations) {
        Set<Id> eventBbsiIds = new Set<Id>();
        Set<Id> contactIds = new Set<Id>();

        // Get the related Event__c.Id's
        for (Event_Registration__c er : listRegistrations) {
            if (er.Contact_Type__c == 'Client' || er.Contact_Type__c == 'Referral Partner') {
                if(er.Event__c != null) {
                    eventBbsiIds.add(er.Event__c);
                }

                if(er.Contact__c != null) {
                    contactIds.add(er.Contact__c);
                }
            }
        }

		for (Contact c : [SELECT Id, AccountId FROM Contact WHERE Id IN :contactIds]) {
			mapContactAccount.put(c.Id, c.AccountId);
		}

        // get map of Event_c's
        Map<Id, Event__c> mapEventC = new Map<Id,Event__c>([
            SELECT Id, Name, Event_Start_Date__c, Event_End_Date__c, Region__c, RecordType.Name, toLabel(Event_Type__c)
            FROM Event__c
            WHERE Id IN :eventBbsiIds
        ]);

        // Reduce events to only those that require processing
        eventBbsiIds = new Set<Id>();
        for(Id eventId : mapEventC.keySet()) {
            eventBbsiIds.add(eventId);
        }

        // Retrieve Events related to the BBSI Events
        List<Event> events = [
            SELECT Id, WhoId, WhatId, Type, StartDateTime, EndDateTime
            FROM Event
            WHERE Event__c In :eventBbsiIds
        ];

        // Build maps to set the Event data
        Map<Id,Event> mapEvents = new Map<Id,Event>();
        for (Event ev : events) {
            if (ev.WhatId != null) {
                mapEvents.put(ev.WhatId, ev);
            }

            if (ev.WhoId != null) {
                mapEvents.put(ev.WhoId, ev);
            }
        }

        List<Event> insertEvents = new List<Event>();
        List<EventRelation> insertEventRelations = new List<EventRelation>();

        for (Event_Registration__c er : listRegistrations) {
            Id whatId = er.Company1__c;

            // check the AccountId is set at this stage
            if (er.Company1__c == null && mapContactAccount.containsKey(er.Contact__c)) {
                whatId = mapContactAccount.get(er.Contact__c);
            }

            // check if an event allready exists
            if (mapEvents.containsKey(whatId)) {
                // heck if the WhoId is set and set it. If WhoId is set then do nothing
                Event e = mapEvents.get(whatId);

                if(e != null) {
                    insertEventRelations.add(createEventRelation(e.Id, er.Contact__c));
                }
            } else if (mapEvents.containsKey(er.Contact__c)) {
                // Check that WhatId is set and set it. If WhatId is set then do nothing
                Event e = mapEvents.get(er.Contact__c);

                if (e != null) {
                    insertEventRelations.add(createEventRelation(e.Id, er.Contact__c));
                }
            } else {
                Event__c eC = mapEventC.get(er.Event__c);
                if(eC != null) {
                    insertEvents.add(createEvent(whatId, er.Contact__c, eC));
                }
            }
        }

        insert insertEvents;
        insert insertEventRelations;
    }

    /**
     * @description NewEventData holds data to create the new Event from BBSI event
     */
    public class NewEventData {
        public String customRecordType;
        public String eventRecordType;
        public String subject;
        public String eventtype;

        /**
         * @description NewEventData constructor
         * @param  customRecordType BBSI Event Record Type
         * @param  eventRecordType  Event Record Type
         * @param  subject          Subject for Event
         * @param  eventtype        Event type
         */
        public NewEventData(String customRecordType, String eventRecordType, String subject, String eventtype) {
            this.customRecordType = customRecordType;
            this.eventRecordType = eventRecordType;
            this.subject = subject;
            this.eventtype = eventtype;
        }
    }

    /**
     * @description createEventRelation creates standard event relation record for shared activities
     * @param  idEvent   Event identifier
     * @param  idContact Contact identifier
     * @return An EventRelation
     */
    @TestVisible
    private EventRelation createEventRelation(Id idEvent, Id idContact) {
        // IsParent and IsWhat are needed to ensure shared event is created, not multi-person event
        return new EventRelation(EventId = idEvent, RelationId = idContact, IsParent = true, IsWhat = false);
    }

    /**
     * @description createEvent creates a standard event from the BBSI event.
     * @param  whatId        Account identifer
     * @param  contactId     Contact identifier
     * @param  eventBBSI     Related BBSI Event (Event__c)
     * @return  A new Event
     */
    @TestVisible
    private Event createEvent(Id whatId, Id contactId, Event__c eventBBSI) {
        String subject = eventBBSI.RecordType.Name + ' - ' + eventBBSI.Event_Type__c;

        Id idrtEvent = Schema.SObjectType.Event.getRecordTypeInfosByName()
            .get('Client General')
            .getRecordTypeId();

        return new Event(
            RecordTypeId = idrtEvent,
            Event__c = eventBBSI.Id,
            WhoId = contactId,
            WhatId = whatId,
            StartDateTime = eventBBSI.Event_Start_Date__c,
            ActivityDateTime = eventBBSI.Event_Start_Date__c,
            EndDateTime = eventBBSI.Event_End_Date__c,
            IsAllDayEvent = true,
            Subject = subject,
            Type = eventBBSI.Event_Type__c
        );
    }
}