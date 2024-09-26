/**
 * @description Payroll_TriggerHandler controls trigger events for Payroll__c objects.
 */
public without sharing class Payroll_TriggerHandler extends TriggerHandlerInvoker.TriggerHandler_Abstract {
	override public void beforeInsert(List<SObject> listNew) {
		List<Payroll__c> payrolls = (List<Payroll__c>) listNew;

        (new updatePayDay()).findPayDays(payrolls);
	}

	override public void beforeUpdate(Map<Id, SObject> mapOld, Map<Id, SObject> mapNew) {
		List<Payroll__c> payrolls = (List<Payroll__c>) mapNew.values();

        (new updatePayDay()).findPayDays(payrolls);
	}
}