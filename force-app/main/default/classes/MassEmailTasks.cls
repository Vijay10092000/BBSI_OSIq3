/**
 * @description MassEmailTasks creates the Tasks after a mass email send.
 */
public with sharing class MassEmailTasks {
	/**
	 * @description create create Tasks for each of the persons given.
	 * @param persons   List of MassEmailPerson
	 * @param typeTask  Type of tasks creating
	 */
    public static void create(List<MassEmailPerson> persons, String typeTask) {
		if (persons != null && !persons.isEmpty()) {
			List<Task> tasks = new List<Task>();

			switch on typeTask {
				when 'CompletedEmailTask' {
					tasks = createCompletedTasks(persons);
				}
			}

			if (!tasks.isEmpty()) {
				insert tasks;
			}
		} else {
			System.debug(LoggingLevel.INFO, 'MassEmailTasks.create() has no persons to add Tasks to.');
		}
    }

	/**
	 * @description createCompletedTasks create the Task objects
	 * @param  persons  List of MassEmailPerson
	 * @return List<Task>
	 */
	private static List<Task> createCompletedTasks(List<MassEmailPerson> persons) {
		List<Task> tasks = new List<Task>();

		for (MassEmailPerson person : persons) {
			Id idAssignee = (person.idBenefitsRep == null) ? UserInfo.getUserId() : person.idBenefitsRep;

			tasks.add(
				Task_service.createTaskCompleted(
					'Email',
					person.idPerson,
					person.idAccount,
					idAssignee,
					person.emailSubject,
					person.emailBody?.stripHtmlTags()
				)
			);
		}

		return tasks;
	}
}