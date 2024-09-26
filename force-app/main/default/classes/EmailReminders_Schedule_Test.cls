/**
* @description EmailReminders_Schedule_Test contains tests for the EmailReminders_Schedule class.
*/
@IsTest
@SuppressWarnings('PMD.ApexAssertionsShouldIncludeMessage')
public without sharing class EmailReminders_Schedule_Test {
    private static User user;
    private static Task taskDue;
    
    @TestSetup
    static void makeTestData() {
        TestFactoryAccount.createBranch('!!TEST BRANCH',  '1000',null, null);
        user = TestFactoryUser.createUser(null,'TESTUSER', 'BBSI Standard', '1000');
        Date today = Date.today();
        Event__c event1 = TestFactoryEventc.createEvent( 
            'Client_Event', 
            new Map<String, Object>{            
                'Budget_Overall__c' => 1000,
                'Event_Manager__c' =>user.Id,
                'OwnerId' => user.Id,
                'Event_Start_Date__c' => today.addDays(7),
                'Event_End_Date__c' => today.addDays(7),
                'Event_Type__c' => 'Meeting',
                'Event_Type_Other__c' => '',
                'Final_Cost__c' => 10000,
                'Region__c' => 'NoCal'                
        }); 
        
        Task taskdue = TestFactoryTask.createTask('Event_Task',new Map<String, Object>{            
            'Type' => 'Follow Up',
            'Subject' => 'Task On Due',
            'Status' => 'Open',
            'Priority' => 'Normal',
            'OwnerId' => user.Id,
            'WhatId' => event1.Id,
            'ActivityDate' => today
        });
    }
    
    static void loadTestData() {
        user = [SELECT Id, UserName FROM User WHERE lastName = 'TESTUSER'];
        taskDue = [SELECT Id, ActivityDate, OwnerId, WhatId FROM Task WHERE Subject = 'Task On Due'];
    }
    
    @IsTest
    static void test() {
        Test.startTest();
        (new EmailReminders_Schedule()).execute(null);
        Test.stopTest();
        Assert.areEqual(1, Email_Service.testEmails.size());
    }
}