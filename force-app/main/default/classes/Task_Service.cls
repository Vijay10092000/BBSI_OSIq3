/**
 * @description Task_Service contains methods to aid with Tasks.
 *
 * See:
 * https://developer.salesforce.com/docs/atlas.en-us.object_reference.meta/object_reference/sforce_api_objects_task.htm
 */
public without sharing class Task_Service {
	private static final String FORMAT_RELATED_TASKS =
		'SELECT RecordTypeId, Type, TaskSubtype, Category__c, WhoId, WhatId, OwnerId, ' +
		'    Subject, Description, ActivityDate, Priority, Status, IsClosed, CompletedDateTime ' +
		'FROM Task ' +
		'{0} ' +
		'ORDER BY CompletedDateTime DESC';

	/**
	 * @description create creates a basic Task.
	 * @param  type         Type of Task
	 * @param  idWho        Identifier of a human such as a lead or a contact
	 * @param  idWhat       Identifier of an object, usually Account or Opportunity
	 * @param  idOwner      Identifier of the User or Group who owns the Task
	 * @param  subject      Brief description of the Task
	 * @param  description  Details of the Task
	 * @param  dateDue      Date when Task should be completed by
	 * @return A Task
	 */
	@SuppressWarnings('PMD.ExcessiveParameterList')
	public static Task createTask(
		String type,
		Id idWho,
		Id idWhat,
		Id idOwner,
		String subject,
		String description,
		Date dateDue
	) {
		Id idRecordType = RecordTypeService.getId('Task', 'Task');

		return createBase(idRecordType, type, idWho, idWhat, idOwner, subject, description, dateDue);
	}

	/**
	 * @description createTaskCompleted creates a basic task which is completed today.
	 * @param  type         Type of Task
	 * @param  idWho        Identifier of a human such as a lead or a contact
	 * @param  idWhat       Identifier of an object, usually Account or Opportunity
	 * @param  idOwner      Identifier of the User or Group who owns the Task
	 * @param  subject      Brief description of the Task
	 * @param  description  Details of the Task
	 * @return A Task
	 */
	@SuppressWarnings('PMD.ExcessiveParameterList')
	public static Task createTaskCompleted(
		String type,
		Id idWho,
		Id idWhat,
		Id idOwner,
		String subject,
		String description
	) {
		Date today = Date.today();

		Task task = createTask(type, idWho, idWhat, idOwner, subject, description, today);

		task.Status = 'Completed';

		return task;
	}

	/**
	 * @description create creates a basic Task.
	 * @param  idRecordType  Identifier of the Task's recordType
	 * @param  type          Type of Task
	 * @param  idWho         Identifier of a human such as a lead or a contact
	 * @param  idWhat        Identifier of an object, usually Account or Opportunity
	 * @param  idOwner       Identifier of the User or Group who owns the Task
	 * @param  subject       Brief description of the Task
	 * @param  description   Details of the Task
	 * @param  dateDue       Date when Task should be completed by
	 * @return A Task
	 */
	@TestVisible
	@SuppressWarnings('PMD.ExcessiveParameterList')
	private static Task createBase(
		Id idRecordType,
		String type,
		Id idWho,
		Id idWhat,
		Id idOwner,
		String subject,
		String description,
		Date dateDue
	) {
		return new Task(
			RecordTypeId = idRecordType,
			Type = type,
			WhoId = idWho,
			WhatId = idWhat,
			OwnerId = idOwner,
			Subject = subject,
			Description = description,
			ActivityDate = dateDue,
			Priority = 'Normal',
			Status = 'Not Started'
		);
	}

	/**
	 * @description getRelatedTasks retrieves completed tasks related to the given objects
	 * based on the What Ids
	 * @param  idWhats  A List of Ids to find tasks for
	 * @param  status   Status of Task
	 * @return Map relating the Id of the What object to a list of completed Tasks
	 */
	public static Map<Id, List<Task>> getRelatedTasks(List<Id> idWhats, String status) {
		Map<Id, List<Task>> result = new Map<Id, List<Task>>();

		String whereClause = 'WHERE WhatId IN (\'' + String.join(idWhats, '\',\'') + '\')';

		if (!String.isBlank(status)) {
			whereClause += ' AND Status = \'' + status +'\'';
		}

		String query = String.format(FORMAT_RELATED_TASKS, new List<String>{ whereClause });

		List<Task> tasks = Database.query(query);

		for (Task task : tasks) {
			if (!result.containsKey(task.WhatId)) {
				result.put(task.WhatId, new List<Task>());
			}

			result.get(task.WhatId).add(task);
		}

		return result;
	}

	/**
	 * @description justCompletedTasks returns a List of Tasks which have just status changed to "Completed"
	 * from the given Tasks.
	 * @param  oldTasks  Map of Tasks before changes
	 * @param  tasks     Tasks checking
	 * @return List of closed Tasks
	 */
	public static List<Task> justCompletedTasks(Map<Id, Task> oldTasks, List<Task> tasks) {
		List<Task> result = new List<Task>();

		for (Task task : tasks) {
			if (task.CompletedDateTime != null && task.Status == 'Completed') {
				if (oldTasks == null || oldTasks.get(task.Id).CompletedDateTime == null) {
					result.add(task);
				}
			}
		}

		return result;
	}
}