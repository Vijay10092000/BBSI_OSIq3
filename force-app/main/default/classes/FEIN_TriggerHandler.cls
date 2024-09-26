/**
 * @description FEIN_TriggerHandler controls trigger events for FEIN__c objects.
 */
public without sharing class FEIN_TriggerHandler extends TriggerHandlerInvoker.TriggerHandler_Abstract {
  override public void beforeInsert(List<SObject> listNew) {
    List<FEIN__c> newFeins = (List<FEIN__c>) listNew;

    FEIN_Services.performCalculations(newFeins, null);
  }

  override public void afterInsert(Map<Id, SObject> mapNew) {
    Map<Id, FEIN__c> newFeins = (Map<Id, FEIN__c>) mapNew;

    FEIN_Services.processLinks(newFeins.values(), null);
  }

  @SuppressWarnings('PMD.UnusedLocalVariable')
  override public void beforeUpdate(
    Map<Id, SObject> mapOld,
    Map<Id, SObject> mapNew
  ) {
    Map<Id, FEIN__c> oldFeins = (Map<Id, FEIN__c>) mapOld;
    Map<Id, FEIN__c> newFeins = (Map<Id, FEIN__c>) mapNew;

    FEIN_Services.performCalculations(newFeins.values(), oldFeins.values());
  }
}