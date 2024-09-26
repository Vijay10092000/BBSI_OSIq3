/**
 * ClientPricingScenario is the trigger for the ClientPricingScenario__c SObject.
 */
trigger ClientPricingScenario on ClientPricingScenario__c(
	before insert,
	after insert,
	before update,
	after update,
	before delete,
	after delete,
	after undelete
) {
	TriggerHandlerInvoker.execute(new ClientPricingScenario_TriggerHandler()); // Updated For US-69176
}