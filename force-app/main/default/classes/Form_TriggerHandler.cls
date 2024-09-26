/**
 * @description Form_TriggerHandler controls trigger events for Form__c objects.
 */
public with sharing class Form_TriggerHandler extends TriggerHandlerInvoker.TriggerHandler_Abstract {
	override public void afterInsert(Map<Id, SObject> mapNew) {
		Map<Id, Form__c> newForms = (Map<Id, Form__c>) mapNew;

		Form_Services.updateCaseWithForm(newForms);
	}
}