/**
 * @description Position_TriggerHandler controls trigger events for Position objects.
 */
public without sharing class Position_TriggerHandler extends TriggerHandlerInvoker.TriggerHandler_Abstract {
	override public void beforeInsert(List<SObject> listNew) {
		List<Position__c> newList = (List<Position__c>) listNew;

		NewHireApproval.populateApprover(listNew);
	}

	override public void afterInsert(Map<Id, SObject> mapNew) {
		(new RecruiterHistory()).handle();
		(new NewHireDelegateShare()).handle();
	}

	override public void beforeUpdate(Map<Id, SObject> mapOld, Map<Id, SObject> mapNew) {
		Map<Id, Position__c> oldMap = (Map<Id, Position__c>) mapOld;
		Map<Id, Position__c> newMap = (Map<Id, Position__c>) mapNew;

		NewHireApproval.emailRecruiter(oldMap, newMap);

		(new RecuriterValidation()).handle();
		(new RecruiterHistory()).handle();
		(new RecruiterShare()).handle();
		(new NewHireDelegateShare()).handle();
	}

	override public void afterUpdate(Map<Id, SObject> mapOld, Map<Id, SObject> mapNew) {
		(new RecruiterHistory()).handle();
	}
}