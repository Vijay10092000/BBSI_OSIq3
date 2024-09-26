/**
 * @description EventC_Services handles Event__c objects.
 */
public without sharing class EventC_Services {
     public static final STRING SUBJECT = 'Add Final Cost and Attendees for: ';
     public static final STRING EVENT_TYPE = 'Relationship Development';
     public static final STRING EVENT_TYPE_VALUE = 'Strategic Relationship Development';
    /**
     * @description correctFields update fields, if can.
     * @param  mapOld   Map with Event__cs before changes
     * @param  listNew  List of Event__cs with changes
     */
    public static void correctFields(Map<Id, Event__c> mapOld, List<Event__c> listNew) {
        for (Event__c e : listNew) {
            if (e.Event_Start_Date__c != null) {
                if (e.Event_End_Date__c == null) {
                    e.Event_End_Date__c = e.Event_Start_Date__c;
                }
            }
        }
    }

    /**
     * @description createTasks creates tasks for the Event__c for the day after the event ends.
     * @param  mapOld   Map with Event__cs before changes
     * @param  listNew  List of Event__cs with changes
     *
     * @see 35567 Auto-Create Reminder Task on Custom Event:
     *     https://bbsi.visualstudio.com/Business%20IT%20Sales%20and%20Marketing%20Solutions/_workitems/edit/35567
     */
    public static void createTasks(Map<Id, Event__c> mapOld, List<Event__c> listNew) {
        List<Task> newTasks = new List<Task>();

        List<Event__c> events = getEventsNeedingTasks(mapOld, listNew);
        for (Event__c event : events) {
            newTasks.add(createEventTask(event));
       }
        insert newTasks;
    }

    /**
     * @description getEventsNeedingTasks determine which of the Event__cs need Tasks created.
     * @param  mapOld   Map with Event__cs before changes
     * @param  listNew  List of Event__cs with changes
     * @return List of Event__c
     */
    @TestVisible
    private static List<Event__c> getEventsNeedingTasks(Map<Id, Event__c> mapOld, List<Event__c> listNew) {
        List<Event__c> result = new List<Event__c>();

        Id idEventClient = RecordTypeService.getId('Event__c', 'Client Event');
        Id idEventRP = RecordTypeService.getId('Event__c', 'Referral Partner Event');

        for (Event__c event : listNew) {
            Event__c eventOld = (mapOld == null) ? null : mapOld.get(event.Id);

            if (event.RecordTypeId == idEventRP || event.RecordTypeId == idEventClient) {
                if (event.Event_Start_Date__c != null) {
                    if (eventOld == null || eventOld.Event_Start_Date__c == null) {
                        result.add(event);
                    }
                }
            }
        }

        return result;
    }

    /**
     * @description createEventTask creates a Task for the given Event__c.
     * @param  event  Event creating Task for
     * @return Task
     */
    @TestVisible
    private static Task createEventTask(Event__c event) {
        Id idRecordType = RecordTypeService.getId('Task', 'Event Task');
        List<Schema.PicklistEntry> values = Event__c.Event_Type__c.getDescribe().getPicklistValues();
        Map<String,String> statusApiToLabelMap = new Map<String,String>();
        for(Schema.PicklistEntry sp : values){
            statusApiToLabelMap.put(sp.getValue(), sp.getLabel());
        }
        Id idEventRP = RecordTypeService.getId('Event__c', 'Referral Partner Event');
        STRING updatedSubject = SUBJECT;
        if(event.Event_Type__c == EVENT_TYPE && event.RecordTypeId == idEventRP ){
            updatedSubject = updatedSubject + EVENT_TYPE_VALUE;
        }
        else{
            updatedSubject = updatedSubject + event.Event_Type__c;
        }
        Date dateDue = event.Event_Start_Date__c;

        if (event.Event_End_Date__c != null) {
            dateDue = event.Event_End_Date__c;
        }
        dateDue = dateDue.addDays(1);
        Task task = Task_Service.createTask(
            'Follow Up',
            null,
            event.Id,
            event.OwnerId,
            updatedSubject,
            null,
            dateDue
        );

        DateTime dtDue = (DateTime) dateDue;

        task.IsReminderSet = true;
        task.ReminderDateTime = dtDue.addHours(3);
        task.RecordTypeId = idRecordType;

        return task;
    }
}