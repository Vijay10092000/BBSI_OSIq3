/**
 * @description Task_TriggerHandler performs the trigger events for the Task SObject.
 */
public with sharing class Task_TriggerHandler extends TriggerHandlerInvoker.TriggerHandler_Abstract {

	override public void beforeInsert(List<SObject> listNew) {
		List<Task> newTasks = (List<Task>) listNew;
	}
		/**
	 * @description afterInsert performs actions on related objects to the mapNew sObjects after
	 * the insert.
	 * @param mapNew is the map of sObjects after being saved
	 */
	override public void afterInsert(Map<Id, SObject> mapNew) {
		Map<Id, Task> newTasks = (Map<Id, Task>) mapNew;

		TaskBenefits.handleBenefitsTasks(null, newTasks.values());
		Lead_Services.updateLeadFields(null, newTasks.values());
	}

	override public void beforeUpdate(Map<Id, SObject> mapOld, Map<Id, SObject> mapNew) {
		Map<Id, Task> newTasks = (Map<Id, Task>) mapNew;
		Map<Id, Task> oldTasks = (Map<Id, Task>) mapOld;
	}

	/**
	 * @description afterUpdate performs actions on related objects to the mapNew sObjects after
	 * the update.
	 * @param mapOld is the map of sObjects before the new changes
	 * @param mapNew is the map of sObjects with the saved changes
	 */
	override public void afterUpdate(Map<Id, SObject> mapOld, Map<Id, SObject> mapNew) {
		Map<Id, Task> newTasks = (Map<Id, Task>) mapNew;
		Map<Id, Task> oldTasks = (Map<Id, Task>) mapOld;

		TaskBenefits.handleBenefitsTasks(oldTasks, newTasks.values());
		Lead_Services.updateLeadFields(null, newTasks.values());
	}
}