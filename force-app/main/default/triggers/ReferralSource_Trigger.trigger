/**
 * ReferralSource_Trigger is the trigger for the Referral_Partner__c which
 * is labeled Referral Source.
 */
trigger ReferralSource_Trigger on Referral_Partner__c (
		before insert, after insert, 
		before update, after update, 
		before delete, after delete, 
		after undelete ) {
    TriggerHandlerInvoker.execute(new ReferralSource_TriggerHandler()); // Updated For US-69176
}