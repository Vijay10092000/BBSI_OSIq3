/**
* @description EventC_Services_Test contains test methods for the EventC_Services class.
*/
@IsTest
@SuppressWarnings('PMD.ApexAssertionsShouldIncludeMessage')
public without sharing class EventC_Services_Test {
    @IsTest
    static void test_correctFields() {
        Date today = Date.today();
        Event__c event1 = TestfactoryEventc.makeEvent( 
            'Client_Event', 
            new Map<String, Object>{            
                'Event_Start_Date__c' => null,
                    'Event_End_Date__c' => null
                    
                    });
        Event__c event2 = TestfactoryEventc.makeEvent( 
            'Client_Event', 
            new Map<String, Object>{            
                'Event_Start_Date__c' => today,
                    'Event_End_Date__c' => null
                    
                    });
        Event__c event3 = TestfactoryEventc.makeEvent( 
            'Client_Event', 
            new Map<String, Object>{            
                'Event_Start_Date__c' => today,
                    'Event_End_Date__c' => today.addDays(1)
                    
                    });
        
        List<Event__c> listEvents = new List<Event__c>{ event1, event2, event3};
            
            EventC_Services.correctFields(null, listEvents);
        
        Assert.areEqual(null, event1.Event_End_Date__c);
        Assert.areEqual(today, event2.Event_End_Date__c);
        Assert.areEqual(today.addDays(1), event3.Event_End_Date__c);
    }
    
    /**
    * @description test_createTasks description
    * @see 35567 Auto-Create Reminder Task on Custom Event: https://bbsi.visualstudio.com/Business%20IT%20Sales%20and%20Marketing%20Solutions/_workitems/edit/35567
    */
    @IsTest
    static void test_createTasks() {
        TestFactoryAccount.createBranch('!!TEST BRANCH',  '1000', null,null);
        User user = TestFactoryUser.createUser(null,'TESTUSER','System Administrator', '1000');
        
        Event__c event1 = TestfactoryEventc.makeEvent( 
            'Client Event', 
            new Map<String, Object>{            
                'Event_Type__c' => 'Education Event',
                    'Event_Start_Date__c' => Date.today(),
                    'Region__c'    =>  'Eastern',
                    'Budget_Overall__c' => 50000,
                    'OwnerId'           =>user.Id
                    });
        insert event1;
        
        List<Task> tasks = [
            SELECT Id, OwnerId, WhatId
            FROM Task
            WHERE OwnerId = :user.Id
        ];
        
        Assert.areEqual(1, tasks.size(), 'Only Client Event task should be created');
        Assert.areEqual(event1.Id, tasks.get(0).WhatId, 'Only Client Event task should be created');
    }
    
    @IsTest
    static void test_getEventsNeedingTasks() {
        TestFactoryAccount.createBranch('!!TEST BRANCH',  '1000', null,null);
        User user = TestFactoryUser.createUser('seconduser','TESTUSER','BBSI Standard', '1000');
        Date today = Date.today();
        
        Event__c event1 = TestfactoryEventc.makeEvent( 
            'Client Event', 
            new Map<String, Object>{            
                'Event_Type__c' => 'Education Event',
                    'Event_Start_Date__c' => today,
                    'Region__c'    =>  'Eastern',
                    'Budget_Overall__c' => 50000,
                    'OwnerId'           =>user.Id
                    
                    });
        
        Event__c event2 = TestfactoryEventc.makeEvent( 
            'Branch Event (Internal)', 
            new Map<String, Object>{            
                'Event_Type__c' => 'Lunch & Learn',
                    'Event_Start_Date__c' => today,
                    'Region__c'    =>  'Eastern',
                    'Budget_Overall__c' => 50000,
                    'OwnerId'           =>user.Id
                    
                    });
        
        Test.startTest();
        
        List<Event__c> events = EventC_Services.getEventsNeedingTasks(null, new List<Event__c>{event1, event2});
        
        Test.stopTest();
        
        Assert.areEqual(1, events.size(), 'Only Client Event task should need a Task');
        Assert.areEqual(RecordTypeService.getId('Event__c', 'Client Event'), events.get(0).RecordTypeId, 'Only Client Event task should need a Task');
    }
    
    @IsTest
    static void test_createEventTask() {
        TestFactoryAccount.createBranch('!!TEST BRANCH',  '1000', null,null);
        User user = TestFactoryUser.createUser('userthree','TESTUSER','BBSI Standard', '1000');
        Date today = Date.today();
        
        
        Event__c event = TestfactoryEventc.createEvent( 
            'Client_Event', 
            new Map<String, Object>{            
                'Event_Type__c' => 'Education Event',
                    'Event_Start_Date__c' => today,
                    'Event_End_Date__c' => today,
                    'Region__c'    =>  'Eastern',
                    'Budget_Overall__c' => 50000,
                    'OwnerId'           =>user.Id
                    
                    });
        
        Test.startTest();
        Task task = EventC_Services.createEventTask(event);
        Test.stopTest();
        
        Assert.arenotEqual(null, task, 'Task should be created');
        Assert.areEqual('Follow Up', task.Type, 'Task of type "Follow Up"');
    }
    /**
    * @description test_createEventTaskForRelationshipDevelopment 
    * @see 40942 Update the task subject related to Relationship Development
    */
    @IsTest
    static void test_createEventTaskForRelationshipDevelopment() {
        TestFactoryAccount.createBranch('!!TEST BRANCH',  '1000', null,null);
        User user = TestFactoryUser.createUser('userfour','TESTUSER','BBSI Standard', '1000');
        Date today = Date.today();
        
        Event__c event = TestfactoryEventc.createEvent( 
            'Referral_Partner_Education', 
            new Map<String, Object>{            
                'Event_Type__c' => 'Relationship Development',
                    'Event_Start_Date__c' => today,
                    'Event_End_Date__c' => today,
                    'Region__c'    =>  'Eastern',
                    'Budget_Overall__c' => 50000,
                    'OwnerId'           =>user.Id
                    
                    });
        
        Test.startTest();
        Task task = EventC_Services.createEventTask(event);
        Test.stopTest();
        
        Assert.areEqual('Add Final Cost and Attendees for: Strategic Relationship Development', task.Subject, 'Subject with label value');
    }
}