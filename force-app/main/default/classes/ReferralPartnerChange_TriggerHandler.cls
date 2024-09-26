/**
 * ReferralPartnerChange_TriggerHandler handles the trigger events
 * for the Referral Partner Change Request object.
 */
public without sharing class ReferralPartnerChange_TriggerHandler extends TriggerHandlerInvoker.TriggerHandler_Abstract {

    /**
     * beforeInsert performs actions on the mapNew sObjects before the insert happens.
     * NOTE: Before Insert records have no Id, so are not be able to use Map<>.
     * @param listNew is the list of new sObjects
     */
    override public void beforeInsert(List<SObject> listNew) {
        List<Referral_Partner_Change_Request__c> newList = (List<Referral_Partner_Change_Request__c>) listNew;
        ReferralPartnerChange_Service.rpcrPopulateValues(newList);
		ReferralPartnerChange_Service.requestActivationRPCRChanges(null, listNew);
        ReferralPartnerChange_Service.checkAutoApprove(null, listNew);
    }

    /**
     * afterInsert performs actions on related objects to the mapNew sObjects after
     * the insert.
     * @param mapNew is the map of sObjects after being saved
     */
    override public void afterInsert(Map<Id, SObject> mapNew) {
        Map<Id, Referral_Partner_Change_Request__c> newMap = (Map<Id, Referral_Partner_Change_Request__c>) mapNew;

        ReferralPartnerChange_Service.checkApproved(null, newMap);
        ReferralPartnerChange_Service.sendNotifications(null, newMap);
    }

    /**
     * beforeUpdate performs actions on the mapNew sObjects before the update happens.
     * 
     * @param mapOld is the map of sObjects before the new changes
     * @param mapNew is the map of sObjects with the changes
     */
    @SuppressWarnings('PMD.EmptyStatementBlock')
    override public void beforeUpdate(Map<Id, SObject> mapOld, Map<Id, SObject> mapNew) {
    }

    /**
     * afterUpdate performs actions on related objects to the mapNew sObjects after
     * the update.
     * 
     * @param mapOld is the map of sObjects before the new changes
     * @param mapNew is the map of sObjects with the saved changes
     */
    override public void afterUpdate(Map<Id, SObject> mapOld, Map<Id, SObject> mapNew) {
        Map<Id, Referral_Partner_Change_Request__c> oldMap = (Map<Id, Referral_Partner_Change_Request__c>) mapOld;
        Map<Id, Referral_Partner_Change_Request__c> newMap = (Map<Id, Referral_Partner_Change_Request__c>) mapNew;

        ReferralPartnerChange_Service.checkApproved(oldMap, newMap);
        ReferralPartnerChange_Service.sendNotifications(oldMap, newMap);
    }

}