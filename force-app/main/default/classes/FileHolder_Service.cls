/**
 * FileHolder_Service contains commands which work against File_Holder__c
 * objects.
 *
 * The File_Holder__c object is to be used is with a lightning:fileUpload
 * during the create of another object.  Temporarily link the uploaded
 * files to the File_Holder__c, then after the object is created, attach
 * the files to the new object and delete the File_Holder__c.  Because the
 * creation may be canceled, a scheduled job should be made to delete any
 * outstanding File Holders and their linked documents (see method deleteAll).
 */
public with sharing class FileHolder_Service {

    /**
     * addLinksToObject links the documents linked to the fileHolderId
     * to the given object Id.
     * @param  fileHolderId fileHolderId description
     * @param  objectId     Object to make links to
     */
    public static void addLinksToObject(Id fileHolderId, Id objectId) {
        List<ContentDocumentLink> links = [
			SELECT Id, ContentDocumentId, ShareType, Visibility
			FROM ContentDocumentLink
            WHERE LinkedEntityId = :fileHolderId
        ];

        if (!links.isEmpty()) {
            List<ContentDocumentLink> contentLinks = new List<ContentDocumentLink>();
            for (ContentDocumentLink link : links) {
                contentlinks.add(
                    new ContentDocumentLink(
                        ContentDocumentId = link.ContentDocumentId,
                        LinkedEntityId = objectId,
                        ShareType = link.ShareType,
                        Visibility = link.Visibility
                    )
                );
            }

            List<Database.SaveResult> srList = Database.insert(contentlinks, false);
			Log.writeIfError('FileHolder', 'FileHolder_Services.addLinksToObject', null, srList);
        }
    }

    /**
     * deleteAll deletes all File Holders and related ContentDocuments.
     * The could case an issue if a Case is currently being entered, so call
     * this method from a flow or scheduled job at an appropriate time,
     */
    @InvocableMethod
    public static void deleteAll() {
        List<File_Holder__c> holders = [SELECT Id FROM File_Holder__c];

        if (!holders.isEmpty()) {
            List<Id> holderIds = new List<Id>();
            for (File_Holder__c holder : holders) {
                holderIds.add(holder.Id);
            }

            List<ContentDocumentLink> links = [
				SELECT Id, ContentDocumentId
				FROM ContentDocumentLink
				WHERE LinkedEntityId IN :holderIds
            ];

            if (!links.isEmpty()) {
                List<Id> docIds = new List<Id>();
                for (ContentDocumentLink link : links) {
                    docIds.add(link.ContentDocumentId);
                }

                Database.delete(docIds, false);
            }

            Database.delete(holderIds, false);
        }
    }

}