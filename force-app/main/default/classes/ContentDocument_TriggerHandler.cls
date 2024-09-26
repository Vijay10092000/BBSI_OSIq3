/**
 * @description ContentDocument_TriggerHandler controls trigger events for ContentDocument objects.
 */
public with sharing class ContentDocument_TriggerHandler extends TriggerHandlerInvoker.TriggerHandler_Abstract {
    /**
     * @description beforeDelete performs actions on the mapOld sObjects before the delete happens.
     * @param mapOld is the map of sObjects before deletion
     */
    override public void beforeDelete(Map<Id, SObject> mapOld) {
		Map<Id, ContentDocument> oldDocs = (Map<Id, ContentDocument>) mapOld;
        
		ContentDocumentFileAttached.updateByDeletedDocuments(oldDocs.values());
	}

	/**
	 * @description beforeUpdate performs actions on the mapNew sObjects after the undelete happens.
	 * @param mapNew is the map of sObjects which have been undeleted
	 */
	override public void afterUndelete(Map<Id, SObject> mapNew) {
		Map<Id, ContentDocument> newDocs = (Map<Id, ContentDocument>) mapNew;

		ContentDocumentFileAttached.updateByDocuments(newDocs.values());
	}
}