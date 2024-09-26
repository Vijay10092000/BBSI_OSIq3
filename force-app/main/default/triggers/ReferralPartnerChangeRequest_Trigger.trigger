/**
 * ReferralPartnerChangeRequest_Trigger is the trigger for the Referral_Partner_Change_Request__c object.
 */
trigger ReferralPartnerChangeRequest_Trigger on Referral_Partner_Change_Request__c(
	before insert,
	after insert,
	before update,
	after update,
	before delete,
	after delete,
	after undelete
) {
	TriggerHandlerInvoker.execute(new ReferralPartnerChange_TriggerHandler());
}