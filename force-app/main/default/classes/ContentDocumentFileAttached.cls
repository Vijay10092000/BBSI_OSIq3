/**
 * @description ContentDocumentFileAttached updates the File Attached flags on records.
 */
public without sharing class ContentDocumentFileAttached {
	// Maps record Id to the number of related documents
	@TestVisible
	private Map<Id, Integer> counts;

	@TestVisible
	private Set<Id> idRecords;

	/**
	 * @description updateByDeletedDocuments updates the File Attached flags based on changes
	 * to the given documents.
	 * @param  documents  Changed documents
	 */
	public static void updateByDeletedDocuments(List<ContentDocument> documents) {
		Set<Id> idDocuments = new Set<Id>();
			
        String text = 'ContentDocumentFileAttached.updateByDeletedDocuments()';
            
		for (ContentDocument doc : documents) {
			idDocuments.add(doc.Id);
            
            text += '\n  ' + doc.Id + '  ' + doc.Title;            
		}

        System.debug(LoggingLevel.FINE, text);

		(new ContentDocumentFileAttached()).processDeletedDocumentIds(idDocuments);
	}

	/**
	 * @description updateByDocuments updates the File Attached flags based on changes
	 * to the given documents.
	 * @param  documents  Changed documents
	 */
	public static void updateByDocuments(List<ContentDocument> documents) {
		Set<Id> idDocuments = new Set<Id>();
        
        String text = 'ContentDocumentFileAttached.updateByDocuments()';
			
		for (ContentDocument doc : documents) {            
			idDocuments.add(doc.Id);
            
            text += '\n  ' + doc.Id + '  ' + doc.Title;
		}

        System.debug(LoggingLevel.FINE, text);
        
		(new ContentDocumentFileAttached()).processDocumentIds(idDocuments);
	}

	/**
	 * @description ContentDocumentLink updates the File Attached flags based on changes
	 * to the given document links.
	 * @param  links  Changed links
	 */
	public static void updateByLinks(List<ContentDocumentLink> links) {
		Set<Id> idRecords = new Set<Id>();
			
		for (ContentDocumentLink link : links) {
			idRecords.add(link.LinkedEntityId);
		}

		(new ContentDocumentFileAttached()).processRecordIds(idRecords);
	}

	/**
	 * @description ContentDocumentFileAttached constructor.
	 */
	@TestVisible
	@SuppressWarnings('PMD.EmptyStatementBlock')
	private ContentDocumentFileAttached() {
	}

	/**
	 * @description processDeletedDocumentIds
	 * @param  idDocuments  ContextDocument identifiers
	 */
	@TestVisible
	private void processDeletedDocumentIds(Set<Id> idDocuments) { 
        idRecords = new Set<Id>();
        Map<Id, Integer> countDeletes = new Map<Id, Integer>();        
        
		for (ContentDocumentLink link : [
			SELECT Id, ContentDocumentId, LinkedEntityId
			FROM ContentDocumentLink
			WHERE ContentDocumentId IN :idDocuments
		]) {
			idRecords.add(link.LinkedEntityId);
            
            if (!countDeletes.containsKey(link.LinkedEntityId)) {
                countDeletes.put(link.LinkedEntityId, 0);
            }
            
            countDeletes.put(link.LinkedEntityId, 1 + countDeletes.get(link.LinkedEntityId));
		}        
        
        getCountAttachedFiles();
        
        for (Id id : countDeletes.keySet()) {
            counts.put(id, counts.get(id) - countDeletes.get(id));
        }

		update updateBbsiEvents();
	}

	/**
	 * @description processDocumentIds retrieves the related records connected to the
	 * documents, then updates those records.
	 * @param  idDocuments  ContextDocument identifiers
	 */
	@TestVisible
	private void processDocumentIds(Set<Id> idDocuments) {        		
		Set<Id> idRecords = getRelatedRecordIds(idDocuments);

		processRecordIds(idRecords);
	}

	/**
	 * @description processRecordIds reviews the current record Ids to see if any
	 * File Attached changes should be performed, then does them.
	 * @param  idRecords  Record identifiers
	 */
	@TestVisible
	private void processRecordIds(Set<Id> idRecords) {
		if (!idRecords.isEmpty()) {            
			this.idRecords = idRecords;

			getCountAttachedFiles();

			update updateBbsiEvents();
		}
	}

	/**
	 * @description getCountAttachedFiles reads the number of File Links related to each of the given record ids.
	 */
	@TestVisible
	private void getCountAttachedFiles() {	
		counts = new Map<Id, Integer>();

		for (Id id : idRecords) {
			counts.put(id, 0);
		}
	
		List<AggregateResult> links = [
			SELECT LinkedEntityId, COUNT(Id) cnt 
			FROM ContentDocumentLink
			WHERE LinkedEntityId IN :idRecords
			AND IsDeleted = FALSE 
			AND ContentDocument.IsDeleted = FALSE
			GROUP BY LinkedEntityId
		];
				
		for (AggregateResult link : links) {
			counts.put(
				String.valueOf(link.get('LinkedEntityId')),
				Integer.valueOf(link.get('cnt'))
			);
		}
	}

	/**
	 * @description updateBbsiEvents reads the BBSI Events in the given list of Ids and updates
	 * the Files Attached checkbox.
	 * @return List of modified BBSI Events.
	 */
	@TestVisible
	private List<Event__c> updateBbsiEvents() {
		List<Event__c> result = new List<Event__c>();

		for (Event__c event : [SELECT Id, Files_Attached__c FROM Event__c WHERE Id IN :idRecords]) {
			Boolean newValue = (0 < counts.get(event.Id));

			if (event.Files_Attached__c == null || event.Files_Attached__c != newValue) {
				event.Files_Attached__c = newValue;

				result.add(event);
			}
		}

		return result;
	}
    
    /**
     * @description asdf retrieves a Set of record Ids related to the given documents.
     * @param  idDocuments	Document identifiers
     * @return Set of record Ids
     */
    private Set<Id> getRelatedRecordIds(Set<Id> idDocuments) {
        Set<Id> result = new Set<Id>();
        
		for (ContentDocumentLink link : [
			SELECT Id, IsDeleted, ContentDocumentId, LinkedEntityId
			FROM ContentDocumentLink
			WHERE ContentDocumentId IN :idDocuments
		]) {
			result.add(link.LinkedEntityId);
		}
        
        return result;
    }
}