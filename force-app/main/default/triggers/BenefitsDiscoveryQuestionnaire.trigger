/**
 * BenefitsDiscoveryQuestionnaire is the trigger for the Benefits_Discovery_Questionnaire__c SObject.
 */
trigger BenefitsDiscoveryQuestionnaire on Benefits_Discovery_Questionnaire__c(
	before insert,
	after insert,
	before update,
	after update,
	before delete,
	after delete,
	after undelete
) {
	TriggerHandlerInvoker.execute(new BenefitsDiscovery_TriggerHandler()); // Updated For US-69176
}