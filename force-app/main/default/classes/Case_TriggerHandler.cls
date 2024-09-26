/**
 * @description Case_TriggerHandler performs the trigger events
 * for the Case object.
 */
public without sharing class Case_TriggerHandler extends TriggerHandlerInvoker.TriggerHandler_Abstract {
	/**
	 * @description afterInsert performs actions on related objects to the mapNew sObjects after
	 * the insert.
	 * @param mapNew is the map of sObjects after being saved
	 */
	override public void beforeInsert(List<SObject> listNew) {
		List<Case> newCases = (List<Case>) listNew;

        Case_Assignment.assignCases(newCases);
        Case_Services.AssignEntitlementInsert(newCases);
        Case_Services.addCreatedByAsContact(newCases);
	}
    
    /**
     * @description afterInsert performs actions on related objects to the mapNew sObjects after
     * the insert.
     * @param mapNew is the map of sObjects after being saved
     */
    override public void afterInsert(Map<Id, SObject> mapNew) {
		Map<Id, Case> mapNewCases = (Map<Id, Case>) mapNew;

        Case_Services.addUserCreatorToCaseTeam(mapNewCases);  
        Case_Services.addContactsToCaseTeam(mapNewCases, null);
        Case_Services.addCaseTeamAsSubscribers(mapNewCases);
        Case_Services.addOwnerToCaseTeam(mapNewCases, null);
    }

	/**
	 * @description beforeUpdate performs actions on the mapNew sObjects before the update happens.
	 *
	 * @param mapOld is the map of sObjects before the new changes
	 * @param mapNew is the map of sObjects with the changes
	 */
	override public void beforeUpdate(Map<Id, SObject> mapOld, Map<Id, SObject> mapNew) {
		Map<Id, Case> mapOldCases = (Map<Id, Case>) mapOld;
		Map<Id, Case> mapNewCases = (Map<Id, Case>) mapNew;

        Case_Services.blockOwnerAssignment(mapOldCases, mapNewCases.values());  
        Case_Assignment.updateAssignCases(mapNewCases, mapOldCases);  
        Case_Services.AssignEntitlementUpdate(mapNewCases,mapOldCases);
	}

	/**
	 * @description afterUpdate performs actions on related objects to the mapNew sObjects after
	 * the update.
	 *
	 * @param mapOld is the map of sObjects before the new changes
	 * @param mapNew is the map of sObjects with the saved changes
	 */
	override public void afterUpdate(Map<Id, SObject> mapOld, Map<Id, SObject> mapNew) {
		Map<Id, Case> mapOldCases = (Map<Id, Case>) mapOld;
		Map<Id, Case> mapNewCases = (Map<Id, Case>) mapNew;

        Case_Services.addContactsToCaseTeam(mapNewCases, mapOldCases);
        Case_Services.unsubscribeFromClosedCase(mapNewCases, mapOldCases);
        Case_Services.addOwnerToCaseTeam(mapNewCases, mapOldCases);
	}
}