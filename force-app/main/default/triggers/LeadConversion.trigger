/**
 * @description LeadConversion handles the Platform Event: Lead Conversion.
 */
trigger LeadConversion on Lead_Conversion__e (after insert) {
    TriggerHandlerInvoker.execute(new LeadConversion_EventHandler());
}