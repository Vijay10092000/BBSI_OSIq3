/**
 * @description Renewal_TriggerHandler controls trigger events for Renewal objects.
 */
public without sharing class Renewal_TriggerHandler extends TriggerHandlerInvoker.TriggerHandler_Abstract {
	/**
	 * @descripton afterInsert handles AFTER INSERT Trigger events.
	 * @param  mapNew  Contains the new Renewal__cs
	 */
	override public void afterInsert(Map<Id, SObject> mapNew) {
		Map<Id, Renewal__c> newRenewals = (Map<Id, Renewal__c>) mapNew;

		Renewal_Service.setIncompleteRenewals(newRenewals.values());
	}
}