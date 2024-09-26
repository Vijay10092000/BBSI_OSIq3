/**
 * @description Log adds records to the Log__c table as a permanent log in Salesforce.
 * This class is to be a utility class for all the code to use.
 * There are methods to write a Log__c record directly or you can create a Log object to
 * build a Log__c record.
 *
 * The main information for a Log is:
 *     Severity    Level of message writing
 *     App         App, Package, main area where message origninate
 *     Method      Method where message origninate
 *     Message     Brief description
 *     Additional  Additional information to help sovle the issue
 * The CreatedById value indicates who had the issue.
 *
 * FUTURE TODO: Change the metadata (Log_Level_Settings__mdt) to match the enum Severity.
 */
@SuppressWarnings('PMD.ExcessivePublicCount')
public without sharing class Log {
	/**
	 * Severity is the level at which to write a Log__c record.  New values
	 * added here must be reflected in the Log.Severity__ picklist.
	 */
	public enum Severity {
		INFO,
		WARN,
		ERROR,
		HISTORY
	}

	private static final String FORMAT_LOG_EXCEPTION = 'EXCEPTION: {0}\n{1}\n{2}';
	private static final String FORMAT_LOG_EXCEPTION_CAUSE = 'EXCEPTION CAUSE: {0}\n{1}\n{2}';

	private static final String FORMAT_LOG_RECORD = '{0} {1}: {2}';

	private static final String FORMAT_LOG_EMAIL_TITLE = 'Salesforce {0}: Internal Error';
	private static final String FORMAT_LOG_EMAIL_BODY =
		'An ERROR has been written to the log data:\n' +
		'User:      {0}' +
		'Created:   {1}' +
		'Severity:  {2} \n' +
		'Bundle:    {3} \n' +
		'Subject:   {4} \n' +
		'Message: \n{5}';

	@TestVisible
	private static Severity logSeverity = null;

	/**
	 * @description write is an invokable method to write a Log record.
	 * @param  params  4 Strings: Severity, Bundle, Subject, Description
	 */
	@InvocableMethod(label='Log Record' description='Creates a Log record from the given parameters')
    public static void logRecord(List<String> params) {
		try {
			Boolean failed = true;

			if (params != null) {
				if (params.size() == 4) {
					write(parseSeverity(params[0]), params[1], params[2], params[3]);
				}

				if (failed) {
					String paramsAll = '';
					for (String param : params) {
						if (0 < paramsAll.length()) {
							paramsAll += ', ';
						}

						paramsAll += param;
					}

					System.debug(LoggingLevel.ERROR, 'FAILED: Log.logRecord( ' + params + ' )');
				}
			}
		} catch (Exception e) {
			System.debug(LoggingLevel.ERROR, 'Log.logRecord() Exception:\n' + e);
		}
	}

	/**
	 * @description futureWrite waits before writing a Log__c record.
	 * @param  severity     Text Level of log writing. Defaults to INFO.
	 * @param  bundle       Package where error lies
	 * @param  subject      Title of the log
	 * @param  description  Text about the log
	 */
	@future
	public static void futureWrite(String severity, String bundle, String subject, String description) {
		write(parseSeverity(severity), bundle, subject, description);
	}

	/**
	 * @description write writes a Log__c record to its table if the severity is high enough.
	 * ALL WRITE LOG METHODS SHOULD FUNNEL THROUGH THIS ONE.
	 * @param  severity     Text Level of log writing. Defaults to INFO.
	 * @param  bundle       Package where error lies
	 * @param  subject      Title of the log
	 * @param  description  Text about the log
	 */
	public static void write(Severity severity, String bundle, String subject, String description) {
		if (allowLog(severity)) {
			bundle = bundle?.left(100);
			subject = subject?.left(100);
			description = description?.left(2048);

			try {
                System.debug(
                    LoggingLevel.INFO, 
                    'Logging Record: ' + 
                    '\n  Bundle: ' + bundle +
                    '\n  Subject: ' + subject +
                    '\n  Description: \n' + description
                );
                
				Log__c newLog = new Log__c(
					Severity__c = severity.name(),
					Scope__c = bundle,
					Subject__c = subject,
					Description__c = description
				);

				insert newLog;             
			} catch (Exception e) {
				String logRecord = String.format(
					FORMAT_LOG_RECORD,
					new List<String>{ severity.name(), subject, description }
				);
			
                System.debug(LoggingLevel.ERROR, 'An unexpected error has prevented logging: ' + e.getMessage());
                System.debug(LoggingLevel.ERROR, logRecord);
			}
		}
	}

	/**
	 * @description write writes a Log__c record to its table for an Exception.
	 * @param  severity     Text Level of log writing. Defaults to INFO.
	 * @param  bundle       Package where error lies
	 * @param  subject      Title of the log
	 * @param  description  Text about the log
	 * @param  e            Exception
	 */
	public static void write(Severity severity, String bundle, String subject, String description, Exception e) {
		String newDescription = toStringException(e) + '\n\nDESCRIPTION: ' + description;

		write(severity, bundle, subject, newDescription);
	}

	/**
	 * @description info writes a INFO Log__c record to its table.
	 * @param  bundle       Package or main area where message origninate
	 * @param  subject      Title of the log
	 * @param  description  Fuller description
	 */
	public static void info(String bundle, String subject, String description) {
		write(Severity.INFO, bundle, subject, description);
	}

	/**
	 * @description warn writes a WARN Log__c record to its table.
	 * @param  bundle       Package or main area where message origninate
	 * @param  subject      Title of the log
	 * @param  description  Fuller description
	 */
	public static void warn(String bundle, String subject, String description) {
		write(Severity.WARN, bundle, subject, description);
	}

	/**
	 * @description error writes a ERROR Log__c record to its table.
	 * @param  bundle       Package or main area where message origninate
	 * @param  subject      Title of the log
	 * @param  description  Fuller description
	 */
	public static void error(String bundle, String subject, String description) {
		write(Severity.ERROR, bundle, subject, description);
	}

	/**
	 * @description error writes a ERROR Log__c record to its table.
	 * @param  bundle       Package or main area where message origninate
	 * @param  subject      Brief description
	 * @param  description  Fuller description
	 * @param  e            Exception
	 */
	public static void error(String bundle, String subject, String description, Exception e) {
		write(Severity.ERROR, bundle, subject, description, e);
	}

	/**
	 * @description history writes an HISTORY Log__c record to its table.  HISTORY records
	 * are for logging changes to object which need to be recorded outside of the Salesforce
	 * History.
	 * @param  bundle       Package or main area where message origninate
	 * @param  subject      Title of the log
	 * @param  description  Fuller description
	 */
	public static void history(String bundle, String subject, String description) {
		write(Severity.HISTORY, bundle, subject, description);
	}

	/**
	 * @description write writes a list of Database Errors to a single Log__c record.
	 * NOTE: It is better to use the other Database method before resorting to this one.
	 * @param  severity     Text Level of log writing. Defaults to INFO.
	 * @param  bundle       Package where error lies
	 * @param  subject      Title of the log
	 * @param  description  Text about the log
	 * @param  listErrors   List of Database.Error
	 */
	public static void write(
		Severity severity,
		String bundle,
		String subject,
		String description,
		List<Database.Error> listErrors
	) {
		if (listErrors != null && listErrors.size() > 0) {
			String fullText = description + '\n\nDATABASE ERRORS';

			fullText += formatDatabaseErrors(null, listErrors);

			write(severity, bundle, subject, fullText);
		}
	}

	/**
	 * @description writeIfError writes a list of Database Errors from Database.SaveResults
	 * to a single Log__c record.
	 * @param  bundle       Package where error lies
	 * @param  subject      Title of the log
	 * @param  description  Text about the log
	 * @param  listSaves    List of Database.SaveResults
	 * @return true if there were errors and log was written.
	 */
	public static Boolean writeIfError(
		String bundle,
		String subject,
		String description,
		List<Database.SaveResult> listSaves
	) {
		return writeIfError(
			Log.Severity.ERROR,
			bundle,
			subject,
			description,
			listSaves
		);
	}

	/**
	 * @description writeIfError writes a list of Database Errors from Database.SaveResults
	 * to a single Log__c record.
	 * @param  severity     Text Level of log writing. Defaults to INFO.
	 * @param  bundle       Package where error lies
	 * @param  subject      Title of the log
	 * @param  description  Text about the log
	 * @param  listSaves    List of Database.SaveResults
	 * @return true if there were errors and log was written.
	 */
	public static Boolean writeIfError(
		Severity severity,
		String bundle,
		String subject,
		String description,
		List<Database.SaveResult> listSaves
	) {
		Boolean haveError = false;

		if (listSaves != null && listSaves.size() > 0) {
			String fullText = description + '\n\nDatabase.SaveResult Errors';

			for (Database.SaveResult sr : listSaves) {
				if (!sr.isSuccess()) {
					fullText += formatDatabaseErrors(sr.getId(), sr.getErrors());
					haveError = true;
				}
			}

			if (haveError) {
				write(severity, bundle, subject, fullText);
			}
		}

		return haveError;
	}

	/**
	 * @description writeIfError writes a list of Database Errors from Database.SaveResults
	 * to a single Log__c record.
	 * @param  bundle       Package where error lies
	 * @param  subject      Title of the log
	 * @param  description  Text about the log
	 * @param  listDeletes  List of Database.DeleteResult
	 * @return true if there were errors and log was written.
	 */
	public static Boolean writeIfError(
		String bundle,
		String subject,
		String description,
		List<Database.DeleteResult> listDeletes
	) {
		return writeIfError(
			Log.Severity.ERROR,
			bundle,
			subject,
			description,
			listDeletes
		);
	}

	/**
	 * @description writeIfError writes a list of Database Errors from Database.SaveResults
	 * to a single Log__c record.
	 * @param  severity     Text Level of log writing. Defaults to INFO.
	 * @param  bundle       Package where error lies
	 * @param  subject      Title of the log
	 * @param  description  Text about the log
	 * @param  listDeletes  List of Database.DeleteResult
	 * @return true if there were errors and log was written.
	 */
	public static Boolean writeIfError(
		Severity severity,
		String bundle,
		String subject,
		String description,
		List<Database.DeleteResult> listDeletes
	) {
		Boolean haveError = false;

		if (listDeletes != null && listDeletes.size() > 0) {
			String fullText = description + '\n\nDatabase.DeleteResult Errors';

			for (Database.DeleteResult dr : listDeletes) {
				if (!dr.isSuccess()) {
					fullText += formatDatabaseErrors(dr.getId(), dr.getErrors());
					haveError = true;
				}
			}

			if (haveError) {
				write(severity, bundle, subject, fullText);
			}
		}

		return haveError;
	}

	/**
	 * @description writeIfError writes a list of Database Errors from Database.UpsertResults
	 * to a single Log__c record.
	 * @param  bundle       Package where error lies
	 * @param  subject      Title of the log
	 * @param  description  Text about the log
	 * @param  listUpserts  List of Database.UpsertResults
	 * @return true if there were errors and log was written.
	 */
	public static Boolean writeIfError(
		String bundle,
		String subject,
		String description,
		List<Database.UpsertResult> listUpserts
	) {
		return writeIfError(
			Log.Severity.ERROR,
			bundle,
			subject,
			description,
			listUpserts
		);
	}

	/**
	 * @description writeIfError writes a list of Database Errors from Database.UpsertResults
	 * to a single Log__c record.
	 * @param  severity     Text Level of log writing. Defaults to INFO.
	 * @param  bundle       Package where error lies
	 * @param  subject      Title of the log
	 * @param  description  Text about the log
	 * @param  listUpserts  List of Database.UpsertResults
	 * @return true if there were errors and log was written.
	 */
	public static Boolean writeIfError(
		Severity severity,
		String bundle,
		String subject,
		String description,
		List<Database.UpsertResult> listUpserts
	) {
		Boolean haveError = false;

		if (listUpserts != null && listUpserts.size() > 0) {
			String fullText = description + '\n\nDatabase.UpsertResult Errors';

			for (Database.UpsertResult ur : listUpserts) {
				if (!ur.isSuccess()) {
					fullText += formatDatabaseErrors(ur.getId(), ur.getErrors());
					haveError = true;
				}
			}

			if (haveError) {
				write(severity, bundle, subject, fullText);
			}
		}

		return haveError;
	}

	/**
	 * @description writeIfError writes a Database.LeadConvertResult to a single Log__c record.
	 * @param  bundle       Package where error lies
	 * @param  subject      Title of the log
	 * @param  description  Text about the log
	 * @param  result       A Database.LeadConvertResult
	 * @return true if there were errors and log was written.
	 */
	public static Boolean writeIfError(
		String bundle,
		String subject,
		String description,
		Database.LeadConvertResult result
	) {
		Boolean haveError = false;

		if (result != null) {
			if (!result.isSuccess()) {
				String fullText = description + '\n\nDatabase.LeadConvertResult Errors';

				fullText += '\nLead Id: ' + result.getLeadId();

				for (Database.Error err : result.getErrors()) {
					fullText += '\nError: ' + err.getMessage();
					fullText += '\nStatus Code: ' + err.getStatusCode();
					fullText += '\nFields: ' + String.join(err.getFields(), ', ');
					fullText += '\n';
				}

				write(Log.Severity.ERROR, bundle, subject, fullText);
				haveError = true;
			}
		}

		return haveError;
	}

	/**
	 * @description allowLog reads the desired severity level of logging from the metadata.
	 * @param  level Severity level checking
	 * @return true if the level allows logging.
	 */
	@TestVisible
	private static Boolean allowLog(Severity level) {
		if (logSeverity == null) {
			setLoggingLevels(
				(List<Log_Level_Settings__mdt>) [SELECT Debug__c FROM Log_Level_Settings__mdt]
			);
		}

		return logSeverity.ordinal() <= level.ordinal();
	}

	/**
	 * @description setLoggingLevels sets the global variables for logging based on the
	 * given metadata.
	 * NOTE: HISTORY and ERROR records should always be written.
	 * @param  logLevels List of Log_Level_Settings, only first is used
	 */
	@TestVisible
	private static void setLoggingLevels(List<Log_Level_Settings__mdt> logLevels) {
		if (logLevels != null && logLevels.size() > 0) {
			Integer debugLevel = logLevels.get(0).Debug__c.intValue();

			if (debugLevel < 3) {
				logSeverity = Severity.ERROR;
			} else if (debugLevel == 3) {
				logSeverity = Severity.WARN;
			} else {
				logSeverity = Severity.INFO;
			}
		} else {
			logSeverity = Severity.INFO;
		}
	}

	/**
	 * @description toStringException Converts an Exception into a String.
	 * @param  e  Exception
	 * @return Text with Exception information
	 */
	private static String toStringException(Exception e) {
		String result = '';

		if (e != null) {
			if (e.getCause() != null) {
				result += String.format(
					FORMAT_LOG_EXCEPTION_CAUSE,
					new List<String>{
						e.getCause().getTypeName(),
						e.getCause().getMessage(),
						e.getCause().getStackTraceString()
					}
				);

				result += '\n\n';
			}

			result += String.format(
				FORMAT_LOG_EXCEPTION,
				new List<String>{ e.getTypeName(), e.getMessage(), e.getStackTraceString() }
			);
		}

		return result;
	}

	/**
	 * @description formatDatabaseErrors description
	 * @param  idObject   Identifier of SObject with error
	 * @param  listErrors List of Database.Errors
	 * @return String with formatted errors
	 */
	public static String formatDatabaseErrors(Id idObject, List<Database.Error> listErrors) {
		String text = '\n';

		if (idObject != null) {
			text += '\nId: ' + idObject;
		}

		if (listErrors != null) {
			for (Database.Error e : listErrors) {
				text += '\nStatus Code: ' + e.getStatusCode();
				text += '\nMessage: ' + e.getMessage();

				List<String> fields = e.getFields();

				if (!fields.isEmpty()) {
					text += '\nFields: ' + e.getFields();
				}
			}
		}

		return text;
	}

	/**
	 * @description parseSeverity convert String with Severity value into an emum.
	 * INFO is returned if the given string is invalid.
	 * @param  severity String converting.
	 * @return Log.Severity
	 */
	public static Log.Severity parseSeverity(String severity) {
		if (!String.isBlank(severity)) {
			for (Log.Severity enumValue : Log.Severity.values()) {
				if (String.valueOf(enumValue).toUpperCase() == severity.toUpperCase()) {
					return enumValue;
				}
			}
		}

		return Log.Severity.INFO;
	}

	/**
	 * @description severity holds the Log__c Severity of the record.
	 */
	public Severity severity { get; set; }

	/**
	 * @description bundle holds the Log__c bundle of the record.
	 */
	public String bundle { get; set; }

	/**
	 * @description subject holds the Log__c subject of the record.
	 */
	public String subject { get; set; }

	/**
	 * @description description holds the Log__c description of the record.
	 */
	public String description { get; set; }

	/**
	 * @description Log constructor creates a Log object for building a Log__c record.
	 */
	public Log() {
		this.severity = Log.Severity.INFO;
		this.bundle = '';
		this.subject = '';
		this.description = '';
	}

	/**
	 * @description Log constructor creates a Log object for building a Log__c record.
	 * @param  severity  Text Level of log writing. Defaults to INFO.
	 * @param  bundle    Package where error lies
	 * @param  subject   Title of the log
	 */
	public Log(Severity severity, String bundle, String subject) {
		this.severity = severity;
		this.bundle = bundle;
		this.subject = subject;
		this.description = '';
	}

	/**
	 * @description Log constructor creates a Log object for building a Log__c record.
	 * @param  severity      Text Level of log writing. Defaults to INFO.
	 * @param  bundle        Package where error lies
	 * @param  subject       Title of the log
	 * @param  description   Initial description for the Log__c record
	 */
	public Log(Severity severity, String bundle, String subject, String description) {
		this.severity = severity;
		this.bundle = bundle;
		this.subject = subject;
		this.description = description;
	}

	/**
	 * @description clear empties the current description.
	 */
	public void clear() {
		description = '';
	}

	/**
	 * @description add adds the text to the description.
	 * @param text  Text to add to log description
	 */
	public void add(String text) {
		description += text;
	}

	/**
	 * @description addLine adds a carriage return.
	 */
	public void addLine() {
		description += '\n';
	}

	/**
	 * @description addLine adds a carriage return then the text to the description.
	 * @param text  Text to add to log description
	 */
	public void addLine(String text) {
		description += '\n' + text;
	}

	/**
	 * @description hasDescription determines if the Log object has a description.
	 * @return Boolean
	 */
	public Boolean hasDescription() {
		return !String.isBlank(description);
	}

	/**
	 * @description write creates the Log__c record.
	 */
	public void write() {
		write(severity, bundle, subject, description);
	}

	/**
	 * @description write creates the Log__c record.  This overrides the severity, bundle
	 * and subject of the created Log object.
	 * @param  severity  Text Level of log writing. Defaults to INFO.
	 * @param  bundle    Package where error lies
	 * @param  subject   Title of the log
	 */
	public void write(Severity severity, String bundle, String subject) {
		write(severity, bundle, subject, description);
	}
}