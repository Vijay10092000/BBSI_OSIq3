/**
 * ReferralPartnerGroup_Trigger is the trigger for the Referral_Partner_Group__c object.
 */
trigger ReferralPartnerGroup_Trigger on Referral_Partner_Group__c(
	before insert,
	after insert,
	before update,
	after update,
	before delete,
	after delete,
	after undelete
) {
	TriggerHandlerInvoker.execute(new ReferralPartnerGroup_TriggerHandler()); // Updated For US-69176
}