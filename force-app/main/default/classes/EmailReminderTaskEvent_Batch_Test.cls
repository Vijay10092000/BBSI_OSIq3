/**
 * @description EmailReminderTaskEvent_Batch_Test contains tests for the EmailReminderTaskEvent_Batch class.
 */
@IsTest
@SuppressWarnings('PMD.ApexAssertionsShouldIncludeMessage')
public without sharing class EmailReminderTaskEvent_Batch_Test {
	private static User user;
	private static Event__c event1;
	private static Task taskComplete;
	private static Task taskBeforeDue;
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

		Task taskComplete = TestFactoryTask.createTask('Event_Task',new Map<String, Object>{            
			'Type' => 'Follow Up',
			'Subject' => 'Task Complete',
			'Status' => 'Completed',
			'Priority' => 'Normal',
			'OwnerId' => user.Id,
			'WhatId' => event1.Id,
			'ActivityDate' => today
		});
         Task taskBeforeDue = TestFactoryTask.createTask('Event_Task',new Map<String, Object>{            
            'Type' => 'Follow Up',
			'Subject' => 'Task Before Due',
			'Status' => 'Open',
			'Priority' => 'Normal',
			'OwnerId' => user.Id,
			'WhatId' => event1.Id,
			'ActivityDate' => today.addDays(5)
		});
        Task taskDue = TestFactoryTask.createTask('Event_Task',new Map<String, Object>{            
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
		user = [SELECT Id, UserName FROM User WHERE LastName = 'TESTUSER'];
		Event__c event1 = [SELECT Id FROM Event__c WHERE OwnerId = :user.Id];
		taskComplete = [SELECT Id, ActivityDate, OwnerId, WhatId FROM Task WHERE Subject = 'Task Complete'];
		taskBeforeDue = [SELECT Id, ActivityDate, OwnerId, WhatId FROM Task WHERE Subject = 'Task Before Due'];
		taskDue = [SELECT Id, ActivityDate, OwnerId, WhatId FROM Task WHERE Subject = 'Task On Due'];

		Assert.areEqual(event1.Id, taskComplete.WhatId);
	}

	@IsTest
	static void test_start() {
		loadTestData();
		EmailReminderTaskEvent_Batch batch = new EmailReminderTaskEvent_Batch();
		Test.startTest();
		List<Task> tasks = batch.start(null);
		Test.stopTest();
		Assert.areEqual(1, tasks.size());
		Assert.areEqual(taskDue.Id, tasks.get(0).Id);
	}

	@IsTest
	static void test_execute() {
		loadTestData();
		List<Task> tasks = new List<Task>{ taskDue };
		EmailReminderTaskEvent_Batch batch = new EmailReminderTaskEvent_Batch();
		Test.startTest();
		batch.execute(null, tasks);
		Test.stopTest();
		Assert.areEqual(1, Email_Service.testEmails.size());
	}

	@IsTest
	static void test_getOwnerEmails() {
		loadTestData();
		List<Task> tasks = new List<Task>{ taskComplete, taskBeforeDue };
		EmailReminderTaskEvent_Batch batch = new EmailReminderTaskEvent_Batch();
		Test.startTest();
		Map<Id, String> mapOwners = batch.getOwnerEmails(tasks);
		Test.stopTest();
		Assert.areEqual(1, mapOwners.keySet().size());
		Assert.isTrue(mapOwners.containsKey(user.Id));
	}
}