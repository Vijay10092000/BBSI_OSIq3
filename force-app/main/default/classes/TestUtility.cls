/**
 * @description TestUtility contains methods to support writing testing.
 */
@SuppressWarnings('PMD.AvoidSystemDebugUsage')
@IsTest
public without sharing class TestUtility {
	private static LeadStatus convertStatus = null;

	/**
	 * @description getStaticResource reads a static resouce for a Test.
	 * @param  filename Name of the static resource
	 * @return text for resource
	 */
	public static String getStaticResource(String filename) {
		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource(filename);
		mock.setStatusCode(200);
		mock.setHeader('Content-Type', 'application/txt');

		// Set the mock callout mode
		Test.setMock(HttpCalloutMock.class, mock);
		HttpRequest req = new HttpRequest();
		req.setEndpoint('https://fake.endpoint');
		req.setMethod('GET');

		HttpResponse res = (new Http()).send(req);
		return res.getBody();
	}

	/**
	 * @description newDatabaseError creates a Database.Error from data given.
	 * @param  errorMesssage  Error messages
	 * @param  statusCode     Error StatusCodes
	 * @param  fields         Related fields
	 * @return A Database.Error
	 */
	public static Database.Error newDatabaseError(
		String errorMesssage,
		StatusCode statusCode,
		List<String> fields
	) {
		JSONGenerator generator = JSON.createGenerator(true);

		buildError(generator, errorMesssage, statusCode, fields);

		String textJson = generator.getAsString();

		return (Database.Error) JSON.deserialize(textJson, Database.Error.class);
	}

	/**
	 * @description newDatabaseDeleteResult creates a Database.DeleteResult from data given.  When succes is false,
	 * errorMessages and statusCodes must have the same number of items.
	 * @param  idObject       Identifier of an SObject
	 * @param  success        true for success, false for error
	 * @param  errorMesssages List of error messages - success equals false
	 * @param  statusCodes    List of error StatusCodes - success equals false
	 * @param  fields         Related fields - success equals false
	 * @return A Database.DeleteResult
	 */
	public static Database.DeleteResult newDatabaseDeleteResult(
		Id idObject,
		Boolean success,
		List<String> errorMesssages,
		List<StatusCode> statusCodes,
		List<String> fields
	) {
		return (Database.DeleteResult) JSON.deserialize(
			toJsonDatabaseResult(idObject, success, errorMesssages, statusCodes, fields),
			Database.DeleteResult.class
		);
	}

	/**
	 * @description newDatabaseLeadConvertResult creates a Database.LeadConvertResult from data given.  When succes is false,
	 * errorMessages and statusCodes must have the same number of items.
	 * @param  idLead         Identifier of the Lead
	 * @param  success        true for success, false for error
	 * @param  idAccount      Identifier of the new Account
	 * @param  idContact      Identifier of the new Contact
	 * @param  idOpportunity  Identifier of the new Opportunity
	 * @param  errorMesssages List of error messages - success equals false
	 * @param  statusCodes    List of error StatusCodes - success equals false
	 * @param  fields         Related fields - success equals false
	 * @return A Database.SaveResult
	 */
	@SuppressWarnings('PMD.ExcessiveParameterList')
	public static Database.LeadConvertResult newDatabaseLeadConvertResult(
		Id idLead,
		Boolean success,
		Id idAccount,
		Id idContact,
		Id idOpportunity,
		List<String> errorMesssages,
		List<StatusCode> statusCodes,
		List<String> fields
	) {
		JSONGenerator generator = JSON.createGenerator(true);

		generator.writeStartObject();

		generator.writeStringField('accountid', String.valueOf(idAccount));
		generator.writeStringField('contactid', String.valueOf(idContact));
		generator.writeStringField('leadid', String.valueOf(idLead));
		generator.writeStringField('opportunityid', String.valueOf(idOpportunity));
		generator.writeBooleanField('success', success);

		buildErrors(generator, errorMesssages, statusCodes, fields);

		generator.writeEndObject();

		return (Database.LeadConvertResult) JSON.deserialize(generator.getAsString(), Database.LeadConvertResult.class);
	}

	/**
	 * @description newDatabaseSaveResult creates a Database.SaveResult from data given.  When succes is false,
	 * errorMessages and statusCodes must have the same number of items.
	 * @param  idObject       Identifier of an SObject
	 * @param  success        true for success, false for error
	 * @param  errorMesssages List of error messages - success equals false
	 * @param  statusCodes    List of error StatusCodes - success equals false
	 * @param  fields         Related fields - success equals false
	 * @return A Database.SaveResult
	 */
	public static Database.SaveResult newDatabaseSaveResult(
		Id idObject,
		Boolean success,
		List<String> errorMesssages,
		List<StatusCode> statusCodes,
		List<String> fields
	) {
		return (Database.SaveResult) JSON.deserialize(
			toJsonDatabaseResult(idObject, success, errorMesssages, statusCodes, fields),
			Database.SaveResult.class
		);
	}

	/**
	 * @description newDatabaseUndeleteResult creates a Database.UndeleteResult from data given.
	 * When succes is false, errorMessages and statusCodes must have the same number of items.
	 * @param  idObject       Identifier of an SObject
	 * @param  success        true for success, false for error
	 * @param  errorMesssages List of error messages - success equals false
	 * @param  statusCodes    List of error StatusCodes - success equals false
	 * @param  fields         Related fields - success equals false
	 * @return A Database.UndeleteResult
	 */
	public static Database.UndeleteResult newDatabaseUndeleteResult(
		Id idObject,
		Boolean success,
		List<String> errorMesssages,
		List<StatusCode> statusCodes,
		List<String> fields
	) {
		return (Database.UndeleteResult) JSON.deserialize(
			toJsonDatabaseResult(idObject, success, errorMesssages, statusCodes, fields),
			Database.UndeleteResult.class
		);
	}

	/**
	 * @description newDatabaseUpsertResult creates a Database.UpsertResult from data given.
	 * When succes is false, errorMessages and statusCodes must have the same number of items.
	 * @param  idObject       Identifier of an SObject
	 * @param  success        true for success, false for error
	 * @param  errorMesssages List of error messages - success equals false
	 * @param  statusCodes    List of error StatusCodes - success equals false
	 * @param  fields         Related fields - success equals false
	 * @return A Database.UndeleteResult
	 */
	public static Database.UpsertResult newDatabaseUpsertResult(
		Id idObject,
		Boolean success,
		List<String> errorMesssages,
		List<StatusCode> statusCodes,
		List<String> fields
	) {
		return (Database.UpsertResult) JSON.deserialize(
			toJsonDatabaseResult(idObject, success, errorMesssages, statusCodes, fields),
			Database.UpsertResult.class
		);
	}

	/**
	 * @description newDatabaseMergeResult creates a Database.MergeResult from data given.  When succes is false,
	 * errorMessages and statusCodes must have the same number of items.
	 * @param  idObject          Identifier of the Master record
	 * @param  success           true for success, false for error
	 * @param  idMergedRecords   Identifier of the new Account - success equals true
	 * @param  idUpdatedRelateds Identifier of the new Opportunity - success equals true
	 * @param  errorMesssages    List of error messages - success equals false
	 * @param  statusCodes       List of error StatusCodes - success equals false
	 * @param  fields         Related fields - success equals false
	 * @return A Database.SaveResult
	 */
	@SuppressWarnings('PMD.ExcessiveParameterList')
	public static Database.MergeResult newDatabaseMergeResult(
		Id idObject,
		Boolean success,
		List<Id> idMergedRecords,
		List<Id> idUpdatedRelateds,
		List<String> errorMesssages,
		List<StatusCode> statusCodes,
		List<String> fields
	) {
		JSONGenerator generator = JSON.createGenerator(true);

		generator.writeStartObject();

		generator.writeStringField('id', String.valueOf(idObject));
		generator.writeStringField('mergedRecordIds', JSON.serialize(idMergedRecords));
		generator.writeStringField('updatedRelatedIds', JSON.serialize(idUpdatedRelateds));
		generator.writeBooleanField('success', success);

		buildErrors(generator, errorMesssages, statusCodes, fields);

		generator.writeEndObject();

		return (Database.MergeResult) JSON.deserialize(generator.getAsString(), Database.MergeResult.class);
	}

	/**
	 * @description toJsonDatabaseResult
	 * @param  idObject       Identifier of an SObject
	 * @param  success        true for success, false for error
	 * @param  errorMesssages List of error messages - success equals false
	 * @param  statusCodes    List of error StatusCodes - success equals false
	 * @param  fields         Related fields - success equals false
	 * @return A Database.SaveResult
	 */
	public static String toJsonDatabaseResult(
		Id idObject,
		Boolean success,
		List<String> errorMesssages,
		List<StatusCode> statusCodes,
		List<String> fields
	) {
		JSONGenerator generator = JSON.createGenerator(true);

		generator.writeStartObject();

		generator.writeStringField('id', String.valueOf(idObject));
		generator.writeBooleanField('success', success);
		buildErrors(generator, errorMesssages, statusCodes, fields);

		generator.writeEndObject();

		return generator.getAsString();
	}

	/**
	 * @description buildErrors creates JSON containing the error messages.
	 * @param  generator      JSON Generator
	 * @param  errorMesssages List of error messages
	 * @param  statusCodes    List of StatusCodes
	 * @param  fields         Related fields
	 */
	private static void buildErrors(
		JSONGenerator generator,
		List<String> errorMesssages,
		List<StatusCode> statusCodes,
		List<String> fields
	) {
		if (errorMesssages.size() != statusCodes.size()) {
			throw new IllegalArgumentException('The size of errorMessages does not match the size of statusCodes');
		}

		if (statusCodes == null || errorMesssages == null || errorMesssages.size() == 0) {
			generator.writeNullField('errors');
		}

		generator.writeFieldName('errors');
		generator.writeStartArray();

		for (Integer index = 0; index < errorMesssages.size(); ++index) {
			buildError(generator, errorMesssages.get(index), statusCodes.get(index), fields);
		}

		generator.writeEndArray();
	}

	/**
	 * @description buildError creates JSON containing an error.
	 * @param  generator      JSON Generator
	 * @param  errorMesssage  Error messages
	 * @param  statusCode     StatusCode
	 * @param  fields         Related fields
	 */
	private static void buildError(
		JSONGenerator generator,
		String errorMesssage,
		StatusCode statusCode,
		List<String> fields
	) {
		generator.writeStartObject();
		generator.writeStringField('message', errorMesssage);
		generator.writeStringField('statusCode', statusCode.name());

		if (fields != null) {
			generator.writeFieldName('fields');
			generator.writeStartArray();
			for (String field : fields) {
				generator.writeString(field);
			}
			generator.writeEndArray();
		}

		generator.writeEndObject();
	}

	/**
	 * @description convertLead converts to Contact/Account/Opportunity the given lead
	 * @param  idLead            Lead to convert
	 * @param  createOpportunity Should an Opportunity be created?
	 * @return Database.LeadConvertResult
	 */
	public static Database.LeadConvertResult convertLead(Id idLead, Boolean createOpportunity) {
		System.debug(LoggingLevel.ERROR, 'DEPRECATED: Use LeadConvert.convert() instead');
		return null;
		/*
		if (convertStatus == null) {
			convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = TRUE LIMIT 1];
		}

		Database.LeadConvert lc = new database.LeadConvert();
		lc.setLeadId(idLead);
		lc.setConvertedStatus(convertStatus.MasterLabel);
		lc.setDoNotCreateOpportunity(createOpportunity);

		Database.LeadConvertResult lcr = Database.convertLead(lc);

		if (!lcr.isSuccess()) {
			String message = 'Lead Convert Error(s)';

			for (Database.Error error : lcr.getErrors()) {
				message = message + '\n + ' + error.getMessage();
			}

			System.debug(LoggingLevel.ERROR, message);
		}

		return lcr;
		*/
	}

	/**
	 * @description buildSendEmailError creates a Messaging.SendEmailError.
	 * @param  message         Error message
	 * @param  statusCode      System.StatusCode
	 * @return Messaging.SendEmailError
	 */
	public static Messaging.SendEmailError buildSendEmailError(String message, StatusCode statusCode) {
		if (message == null || statusCode == null) {
			return null;
		}

		JSONGenerator generator = JSON.createGenerator(true);

		generator.writeStartObject();

		generator.writeStringField('message', message);
		generator.writeStringField('statusCode', statusCode.name());

		generator.writeEndObject();

		return (Messaging.SendEmailError) JSON.deserialize(generator.getAsString(), Messaging.SendEmailError.class);
	}
}