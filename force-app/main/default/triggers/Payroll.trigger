/**
 * Payroll is the trigger for the Payroll__c SObject.
 */
trigger Payroll on Payroll__c (
	before insert, after insert,
	before update, after update,
	before delete, after delete,
	after undelete
) {
	TriggerHandlerInvoker.execute(new Payroll_TriggerHandler()); // Updated For US-69176
}