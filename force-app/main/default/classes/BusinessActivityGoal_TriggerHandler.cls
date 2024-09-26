/**
 * @description BusinessActivityGoal_TriggerHandler handles trigger events for the Business Activity Goal object.
 */
public without sharing class BusinessActivityGoal_TriggerHandler extends TriggerHandlerInvoker.TriggerHandler_Abstract {
	override public void beforeInsert(List<SObject> listNew) {
		List<Business_Activity_Goal__c> newGoals = (List<Business_Activity_Goal__c>) listNew;

		BusinessActivityGoal.checkValues(null, newGoals);
		BusinessActivityGoal.fixBranch(null, newGoals);
        BusinessActivityGoal.checkDuplicates(null, newGoals);
    }

	override public void beforeUpdate(Map<Id, SObject> mapOld, Map<Id, SObject> mapNew) {
		Map<Id, Business_Activity_Goal__c> oldGoals = (Map<Id, Business_Activity_Goal__c>) mapOld;
		Map<Id, Business_Activity_Goal__c> newGoals = (Map<Id, Business_Activity_Goal__c>) mapNew;

		BusinessActivityGoal.checkValues(oldGoals, newGoals.values());
		BusinessActivityGoal.fixBranch(oldGoals, newGoals.values());
        BusinessActivityGoal.checkDuplicates(oldGoals, newGoals.values());
    }
}