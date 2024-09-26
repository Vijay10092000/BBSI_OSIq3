/**
 * Form is the trigger for the Form__c SObject.
 */
trigger Form on Form__c(
	before insert,
	after insert,
	before update,
	after update,
	before delete,
	after delete,
	after undelete
) {
	TriggerHandlerInvoker.execute(new Form_TriggerHandler()); // Updated For US-69176
}