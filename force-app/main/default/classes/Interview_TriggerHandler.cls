/**
 * @description Interview_TriggerHandler
 */
public without sharing class Interview_TriggerHandler  extends TriggerHandlerInvoker.TriggerHandler_Abstract {
	/**
	 * @description beforeInsert performs actions on the mapNew sObjects before the insert happens.
	 * NOTE: Before Insert records have no Id, so are not be able to use Map<>.
	 * @param listNew is the list of new sObjects
	 */
	override public void beforeInsert(List<SObject> listNew) {
		(new InterviewShare()).handle();
	}

	/**
	 * @description beforeUpdate performs actions on the mapNew sObjects before the update happens.
	 * @param mapOld is the map of sObjects before the new changes
	 * @param mapNew is the map of sObjects with the changes
	 */
	override public void beforeUpdate(Map<Id, SObject> mapOld, Map<Id, SObject> mapNew) {
		(new InterviewShare()).handle();
	}
}