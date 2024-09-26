/**
 * ReferralPartnerChange_TriggerHandler handles the trigger events
 * for the Referral Partner Change Request object.
 */
public without sharing class ReferralPartnerGroup_TriggerHandler extends TriggerHandlerInvoker.TriggerHandler_Abstract {

    /**
     * beforeInsert performs actions on the mapNew sObjects before the insert happens.
     * NOTE: Before Insert records have no Id, so are not be able to use Map<>.
     * @param listNew is the list of new sObjects
     */
    override public void beforeDelete(Map<Id, SObject> mapOld) {
        ReferralPartnerGroup_Service.confirmNoReferralPartnersBeforeDelete((Map<Id, Referral_Partner_Group__c>) mapOld);
    }

}