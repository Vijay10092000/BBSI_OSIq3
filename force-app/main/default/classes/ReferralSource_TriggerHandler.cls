/**
 * ReferralSource_TriggerHandler performs the trigger events for 
 * a Referral Source (Referral_Partner__c) object.
 */
public without sharing class ReferralSource_TriggerHandler extends TriggerHandlerInvoker.TriggerHandler_Abstract {

    /**
     * afterInsert performs actions on related objects to the mapNew sObjects after
     * the insert.
     * @param mapNew is the map of sObjects after being saved
     */
    override public void afterInsert(Map<Id, SObject> mapNew) {
        Map<Id, Referral_Partner__c> newMap = (Map<Id, Referral_Partner__c>) mapNew;

        ReferralSource_Service.updateReferralPartnerAccountLastReferralDate(null, newMap.values());
    }

    /**
     * afterUpdate performs actions on related objects to the mapNew sObjects after
     * the update.
     * 
     * @param mapOld is the map of sObjects before the new changes
     * @param mapNew is the map of sObjects with the saved changes
     */
    override public void afterUpdate(Map<Id, SObject> mapOld, Map<Id, SObject> mapNew) {
        Map<Id, Referral_Partner__c> oldMap = (Map<Id, Referral_Partner__c>) mapOld;
        Map<Id, Referral_Partner__c> newMap = (Map<Id, Referral_Partner__c>) mapNew;

        ReferralSource_Service.updateReferralPartnerAccountLastReferralDate(oldMap, newMap.values());
    }

}