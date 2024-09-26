/**
 * FEIN is the trigger for the FEIN__c SObject.
 */
trigger FEIN on FEIN__c(
	before insert,
	after insert,
	before update,
	after update,
	before delete,
	after delete,
	after undelete
) {
	TriggerHandlerInvoker.execute(new FEIN_TriggerHandler());
}