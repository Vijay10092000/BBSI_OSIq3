/**
 * @description BenefitsAffiliates is the trigger for the BenefitsAffiliates__c SObject.
 */
trigger BenefitsAffiliates on Benefits_Affiliates__c(
	before insert,
	after insert,
	before update,
	after update,
	before delete,
	after delete,
	after undelete
) {
	TriggerHandlerInvoker.execute(new BenefitsAffiliates_TriggerHandler());
}