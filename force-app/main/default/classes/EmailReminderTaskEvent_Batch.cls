/**
 * @description EmailReminderTaskEvent_Batch creates the reminder emails for Event Tasks.
 *
 * User Story 35567 Send email only on Client and Referral Partner events.
 */
public with sharing class EmailReminderTaskEvent_Batch  implements Database.Batchable<Task> {
	private static final String TEMPLATE_DEVELOPER_NAME = 'Event_Task_Due';

	/**
	 * @description start determines which Tasks need emails
	 * @param  context  Contains the Trigger Id
	 * @return List of Tasks to send emails for
	 */
	public List<Task> start(Database.BatchableContext context) {
		List<Task> tasksDue = getTasksDue();
		Map<Id, Event__c> events = getRelatedEventCs(tasksDue);

		List<Task> result = new List<Task>();

		for (Task task : tasksDue) {
			if (events.containsKey(task.WhatId)) {
				result.add(task);
			}
		}

		return result;
	}

	/**
	 * @description execute creates and sends the emails.
	 * @param  context  Contains the Trigger Id
	 * @param  scope    List of Tasks
	 */
	public void execute(Database.BatchableContext context, List<SObject> scope) {
		List<Task> tasks = (List<Task>) scope;

		Map<Id, String> mapOwners = getOwnerEmails(tasks);

		List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

		for (Task task : tasks) {
			emails.add(
				Email_Service.buildTemplateEmail(
					new List<String>{ mapOwners.get(task.ownerId) },
					(List<String>) null,
					TEMPLATE_DEVELOPER_NAME,
					task.Id,
					task.WhatId
				)
			);
		}

		Email_Service.send(emails);
	}

	/**
	 * @description finish performs any clean up work and chains to next Email Reminder (if there is one).
	 * @param  context  Contains the Trigger Id
	 */
	@SuppressWarnings('PMD.EmptyStatementBlock')
    public void finish(Database.BatchableContext context) {
		// TODO: FUTURE: Chain to the next Email Reminder Batch class
    }

	@TestVisible
	private List<Task> getTasksDue() {
		Date dateToday = Date.today();

		List<Task> tasks = [
			SELECT Id, ActivityDate, AccountId, WhatId, OwnerId, Subject, Status
			FROM Task
			WHERE ActivityDate = :dateToday
			AND RecordType.Name = 'Event Task'
			AND Type = 'Follow Up'
			AND Status <> 'Completed'
		];

		return tasks;
	}

	@TestVisible
	private Map<Id, Event__c> getRelatedEventCs(List<Task> tasks) {
		Set<Id> idWhats = new Set<Id>();

		for (Task task : tasks) {
			if (task.WhatId != null) {
				if (Id_service.isType(task.WhatId, 'Event__c')) {
					idWhats.add(task.WhatId);
				}
			}
		}

		return new Map<Id, Event__c>([
			SELECT Id, RecordTypeId
			FROM Event__c
			WHERE Id IN :idWhats
			AND (RecordType.Name = 'Referral Partner Event' OR RecordType.Name = 'Client Event')
		]);
	}

	/**
	 * @description getOwnerEmails retrieves a map containing a link from a user Id
	 * to the user email address.
	 * @param  tasks  Tasks Owners working with
	 * @return Map<Id, String>
	 */
	@TestVisible
	private Map<Id, String> getOwnerEmails(List<Task> tasks) {
		Set<Id> idOwners = new Set<Id>();

		for (Task task : tasks) {
			idOwners.add(task.OwnerId);
		}

		Map<Id, String> result = new Map<Id, String>();

		for (User u : [
			SELECT Id, Email
			FROM User
			WHERE Id IN : idOwners
		]) {
			result.put(u.Id, u.Email);
		}

		return result;
	}
}