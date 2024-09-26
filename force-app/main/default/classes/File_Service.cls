/**
 * @description File_Service contains methods to handle files.
 *
 * See:
 *   https://developer.salesforce.com/docs/atlas.en-us.object_reference.meta/object_reference/sforce_api_objects_contentdocument.htm
 *   https://developer.salesforce.com/docs/atlas.en-us.object_reference.meta/object_reference/sforce_api_objects_contentdocumentlink.htm#!
 *   https://developer.salesforce.com/docs/atlas.en-us.object_reference.meta/object_reference/sforce_api_objects_contentdocumenthistory.htm
 */
public without sharing class File_Service {
	/**
	 * @description createFile description
	 * @param  idLink Id of object to relate file to
	 * @param  path   File name
	 * @param  title  General title of the file
	 * @param  body   The file's data
	 * @return File identifier
	 */
	public static Id createFile(Id idLink, String path, String title, Blob body) {
		ContentVersion version = new ContentVersion(
			ContentLocation = 'S',
			Origin = 'C',
			OwnerId = UserInfo.getUserId(),
			PathOnClient = path,
			Title = title,
			VersionData = body
		);
		insert version;

		Id idDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:version.Id].ContentDocumentId;

		if (idLink != null) {
			attachFile(idLink, idDocument, 'V');
		}

		return idDocument;
	}

	/**
	 * @description deleteFile removes a file related to an object.  This will delete
	 * the file for all objects related to it.
	 * @param  idFile  Id of ContentDocument to delete
	 */
	public static void deleteFile(Id idFile) {
		if (idFile != null) {
			delete new ContentDocument(Id = idfile);
		}
	}

	/**
	 * @description deleteFile removes a file related to an object.  This will delete
	 * the file for all objects related to it.
	 * @param  idEntity Entity file is linked to
	 * @param  title    Title of the file
	 */
	public static void deleteFile(Id idEntity, String title) {
		List<ContentDocumentLink> links = [
			SELECT Id, ContentDocumentId
			FROM ContentDocumentLink
			WHERE LinkedEntityId = :idEntity
		];

		Set<Id> idFiles = new Set<Id>();

		for (ContentDocumentLink link : links) {
			idFiles.add(link.ContentDocumentId);
		}

		if (!idFiles.isEmpty()) {
			delete [SELECT Id FROM ContentDocument WHERE Id IN :idFiles AND Title = :title];
		}
	}

	/**
	 * @description read
	 * @param  idDocument Content Document identifier
	 * @return String of contents
	 */
	public static String read(Id idDocument) {
		List<ContentVersion> versions = [
			SELECT Id, VersionData, ContentModifiedById, ContentModifiedDate, Description, FileExtension, FileType, IsLatest, Title, VersionNumber
			FROM ContentVersion
			WHERE ContentDocumentId = :idDocument
			AND IsLatest = TRUE
			LIMIT 1
		];

		if (!versions.isEmpty()) {
			return versions.get(0).VersionData.toString();
		}

		return null;
	}

	/**
	 * @description readFile
	 * @param  idDocument Content Document identifier
	 * @return ContentVersion
	 */
	public static ContentVersion readFile(Id idDocument) {
		return [
			SELECT Id, VersionData, ContentModifiedById, ContentModifiedDate, Description, FileExtension, FileType, IsLatest, Title, VersionNumber
			FROM ContentVersion
			WHERE ContentDocumentId = :idDocument
			AND IsLatest = TRUE
			LIMIT 1
		];
	}

	/**
	 * @description attachFile attaches the initial input CSV file to the history record.
	 * @param  idObject   Identifier file is being attached to
	 * @param  idFile     File identifier
	 * @param  typeShare  Type of file sharing
	 */
	public static void attachFile(Id idObject, Id idFile, String typeShare) {
		attachFile(idObject, idFile, typeShare, 'AllUsers');
	}

	/**
	 * @description attachFile attaches the initial input CSV file to the history record.
	 * @param  idObject    Identifier file is being attached to
	 * @param  idFile      File identifier
	 * @param  typeShare   Type of file sharing
	 * @param  visibility  Visibility of the file
	 * @return true if successfully attached the file, false on error
	 */
	public static Boolean attachFile(Id idObject, Id idFile, String typeShare, String visibility) {
		try {
			insert new ContentDocumentLink(
				LinkedEntityId = idObject,
				ContentDocumentId = idFile,
				ShareType = typeShare,
				Visibility = visibility
			);
		} catch (Exception e) {
			System.debug(LoggingLevel.ERROR, 'EXCEPTION: ' + e + '\nFailed to attach file (' + idFile + ') to object (' + idObject + ') with Visibiltiy ' + visibility);
			return false;
		}

		return true;
	}

	/**
	 * @description getRelatedFiles retrieves the documents related to the given
	 * record identifiers.
	 * @param  ids  Record identifiers
	 * @return Map<Id, List<Id>>
	 */
	public static Map<Id, List<Id>> getRelatedFiles(Set<Id> ids) {
		Map<Id, List<Id>> result = new Map<Id, List<Id>>();

		for (Id id : ids) {
			result.put(id, new List<Id>());
		}

		List<ContentDocumentLink> links = [SELECT LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN :ids];

		for(ContentDocumentLink link : links) {
			result.get(link.LinkedEntityId).add(link.ContentDocumentId);
		}

		return result;
	}
}