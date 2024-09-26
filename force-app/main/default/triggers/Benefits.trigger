/**
 * Benefits is the trigger for the Benefits__c SObject.
 */
trigger Benefits on Benefits__c(
	before insert,
	after insert,
	before update,
	after update,
	before delete,
	after delete,
	after undelete
) {
	TriggerHandlerInvoker.execute(new Benefits_TriggerHandler());
}