/**
 * Renewal is the trigger for the Renewal SObject.
 */
trigger Renewal on Renewal__c(
	before insert,
	after insert,
	before update,
	after update,
	before delete,
	after delete,
	after undelete
) {
	TriggerHandlerInvoker.execute(new Renewal_TriggerHandler());
}