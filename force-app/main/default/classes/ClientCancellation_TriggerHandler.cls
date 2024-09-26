/**
 * @description ClientCancellation_TriggerHandler handles events for changes to
 * the Client Cancellation object.
 */
public without sharing class ClientCancellation_TriggerHandler extends TriggerHandlerInvoker.TriggerHandler_Abstract {
    /**
     * @description beforeInsert performs actions on the mapNew sObjects before the insert happens.
     * NOTE: Before Insert records have no Id, so are not be able to use Map<>.
     * @param listNew is the list of new sObjects
     */
    override public void beforeInsert(List<SObject> listNew) {
        List<Client_Cancellation__c> newList = (List<Client_Cancellation__c>) listNew;

        (new NewCancellationForm()).handle(newList);
		ClientCancellation_Service.updateContactDate(null, newList);
    }

    /**
     * @description afterInsert performs actions on related objects to the mapNew sObjects after
     * the insert.
     * @param mapNew is the map of sObjects after being saved
     */
    override public void afterInsert(Map<Id, SObject> mapNew) {
        Map<Id, Client_Cancellation__c> newMap = (Map<Id, Client_Cancellation__c>) mapNew;

        (new ClientCancellationApproval()).handle(null, newMap, System.TriggerOperation.AFTER_INSERT);

        ClientCancellation_Service.createStartTasks(newMap);
    }

    /**
     * @description beforeUpdate performs actions on the mapNew sObjects before the update happens.
     *
     * @param mapOld is the map of sObjects before the new changes
     * @param mapNew is the map of sObjects with the changes
     */
    override public void beforeUpdate(Map<Id, SObject> mapOld, Map<Id, SObject> mapNew) {
        Map<Id, Client_Cancellation__c> oldMap = (Map<Id, Client_Cancellation__c>) mapOld;
        Map<Id, Client_Cancellation__c> newMap = (Map<Id, Client_Cancellation__c>) mapNew;

        (new ClientCancellationApproval()).handle(oldMap, newMap, System.TriggerOperation.BEFORE_UPDATE);
		ClientCancellation_Service.updateContactDate(oldMap, newMap.values());
    }

    /**
     * @description afterUpdate performs actions on related objects to the mapNew sObjects after
     * the update.
     *
     * @param mapOld is the map of sObjects before the new changes
     * @param mapNew is the map of sObjects with the saved changes
     */
    override public void afterUpdate(Map<Id, SObject> mapOld, Map<Id, SObject> mapNew) {
        Map<Id, Client_Cancellation__c> oldMap = (Map<Id, Client_Cancellation__c>) mapOld;
        Map<Id, Client_Cancellation__c> newMap = (Map<Id, Client_Cancellation__c>) mapNew;

        (new ClientCancellationApproval()).handle(oldMap, newMap, System.TriggerOperation.AFTER_UPDATE);
		ClientCancellation_Service.updateRevoke(oldMap, newMap.values());
    }
}