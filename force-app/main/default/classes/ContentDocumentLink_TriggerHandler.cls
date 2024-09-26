/**
 * @description ContentDocumentLink_TriggerHandler controls trigger events for ContentDocumentLink objects.
 */
public with sharing class ContentDocumentLink_TriggerHandler extends TriggerHandlerInvoker.TriggerHandler_Abstract {
	/**
	 * @description afterInsert performs actions on related objects to the mapNew sObjects after
	 * the insert.
	 * @param mapNew is the map of sObjects after being saved
	 */
	override public void afterInsert(Map<Id, SObject> mapNew) {
		Map<Id, ContentDocumentLink> newLinks = (Map<Id, ContentDocumentLink>) mapNew;

		ContentDocumentFileAttached.updateByLinks(newLinks.values());
	}

	/**
	 * @description afterUpdate performs actions on related objects to the mapNew sObjects after
	 * the update.
	 * @param mapOld is the map of sObjects before the new changes
	 * @param mapNew is the map of sObjects with the saved changes
	 */
	@SuppressWarnings('PMD.UnusedLocalVariable')
	override public void afterUpdate(Map<Id, SObject> mapOld, Map<Id, SObject> mapNew) {
		Map<Id, ContentDocumentLink> oldLinks = (Map<Id, ContentDocumentLink>) mapOld;
		Map<Id, ContentDocumentLink> newLinks = (Map<Id, ContentDocumentLink>) mapNew;

		ContentDocumentFileAttached.updateByLinks(newLinks.values());
	}

	/**
	 * @description beforeDelete performs actions on the mapOld sObjects before the delete happens.
	 * @param mapOld is the map of sObjects before deletion
	 */
	override public void afterDelete(Map<Id, SObject> mapOld) {
		Map<Id, ContentDocumentLink> oldLinks = (Map<Id, ContentDocumentLink>) mapOld;
        
		ContentDocumentFileAttached.updateByLinks(oldLinks.values());
	}

	/**
	 * @description beforeUpdate performs actions on the mapNew sObjects after the undelete happens.
	 * @param mapNew is the map of sObjects which have been undeleted
	 */
	override public void afterUndelete(Map<Id, SObject> mapNew) {
		Map<Id, ContentDocumentLink> newLinks = (Map<Id, ContentDocumentLink>) mapNew;

		ContentDocumentFileAttached.updateByLinks(newLinks.values());
	}
}