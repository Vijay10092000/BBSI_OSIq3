/**
 * @description Task_Service_Test contains tests for the Task_Service class.
 */
@IsTest
@SuppressWarnings('PMD.ApexAssertionsShouldIncludeMessage, PMD.AvoidHardcodingId')
public with sharing class Task_Service_Test {
	private static final Id TASK_ID_WHO = Id.valueOf('0032J00003Y51SUQAZ');
	private static final Id TASK_ID_WHAT = Id.valueOf('0012J00002PIMi5QAH');
	private static final Id TASK_ID_OWNER = Id.valueOf('0052J000009G6kD');
	private static final String TASK_SUBJECT = 'Task Subject';
	private static final String TASK_DESCRIPTION = 'Task Description';

	@IsTest
    static void test_createTask() {
		Date dateDue = Date.today().addDays(-30);

		Task task = Task_Service.createTask(
			'Email',
			TASK_ID_WHO,
			TASK_ID_WHAT,
			TASK_ID_OWNER,
			TASK_SUBJECT,
			TASK_DESCRIPTION,
			dateDue
		);

		System.assertEquals(TASK_ID_WHO, task.WhoId);
		System.assertEquals(TASK_ID_WHAT, task.WhatId);
		System.assertEquals(TASK_ID_OWNER, task.OwnerId);
		System.assertEquals(TASK_SUBJECT, task.Subject);
		System.assertEquals(TASK_DESCRIPTION, task.Description);
		System.assertEquals(dateDue, task.ActivityDate);
		System.assertEquals('Normal', task.Priority);
		System.assertEquals('Not Started', task.Status);
    }

	@IsTest
    static void test_createTaskCompleted() {
		Date today = Date.today();

		Task task = Task_Service.createTaskCompleted(
			'Email',
			TASK_ID_WHO,
			TASK_ID_WHAT,
			TASK_ID_OWNER,
			TASK_SUBJECT,
			TASK_DESCRIPTION
		);

		System.assertEquals(TASK_ID_WHO, task.WhoId);
		System.assertEquals(TASK_ID_WHAT, task.WhatId);
		System.assertEquals(TASK_ID_OWNER, task.OwnerId);
		System.assertEquals(TASK_SUBJECT, task.Subject);
		System.assertEquals(TASK_DESCRIPTION, task.Description);
		System.assertEquals(today, task.ActivityDate);
		System.assertEquals('Normal', task.Priority);
		System.assertEquals('Completed', task.Status);
    }

	@IsTest
	static void test_getRelatedTasks() {
		Account branch = TestFactory.createAccountBranch('!!TESTBRANCH', '99999', '1000', true);
		User user = TestFactory.createUser('TESTUSER', 'BBSI Standard', '1000', true);
		Account client = TestFactory.createAccountClient('!!TESTCLIENT', true);
		Date today = Date.today();

		Task task1 = Task_Service.createTask(
			'Email',
			null,
			client.Id,
			user.Id,
			TASK_SUBJECT,
			TASK_DESCRIPTION,
			today
		);
		Task task2 = Task_Service.createTask(
			'Call',
			(Id) null,
			client.Id,
			user.Id,
			TASK_SUBJECT,
			TASK_DESCRIPTION,
			today.addDays(2)
		);
		Task task3 = Task_Service.createTaskCompleted(
			'Follow Up',
			(Id) null,
			client.Id,
			user.Id,
			TASK_SUBJECT,
			TASK_DESCRIPTION
		);

		insert new List<Task>{task1, task2, task3};

		List<Id> idAccounts = new List<Id>{client.Id};

		Map<Id, List<Task>> mapTasks;

		mapTasks = Task_Service.getRelatedTasks(idAccounts, null);
		System.assertEquals(1, mapTasks.size());
		System.assertEquals(3, mapTasks.get(client.Id).size());

		mapTasks = Task_Service.getRelatedTasks(idAccounts, 'Not Started');
		System.assertEquals(1, mapTasks.size());
		System.assertEquals(2, mapTasks.get(client.Id).size());

		mapTasks = Task_Service.getRelatedTasks(idAccounts, 'Completed');
		System.assertEquals(1, mapTasks.size());
		System.assertEquals(1, mapTasks.get(client.Id).size());
	}
}