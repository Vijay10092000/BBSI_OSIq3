/**
 * @description Log_Test contains tests for the Log class.
 */
@SuppressWarnings('PMD.ApexAssertionsShouldIncludeMessage')
@IsTest
public class Log_Test {
	/**
	 * ID_TEST_ACCOUNT contains an Id for testing
	 */
	@SuppressWarnings('PMD.AvoidHardcodingId')
	private static final Id ID_TEST_ACCOUNT = Id.valueOf('00130000002A291');

	/**
	 * @description LogTestException is used for testing exceptions.
	 */
	public class LogTestException extends Exception {
	}

	/**
	 * @description retrieves the logs written after the given DateTime.
	 * @param  afterDateTime DateTime testing
	 * @return List of Logs written after the given DateTime
	 */
	public static List<Log__c> recentLogs(DateTime afterDateTime) {
		return [
			SELECT Severity__c, Scope__c, Subject__c, Description__c
			FROM Log__c
			WHERE CreatedDate >= :afterDateTime
			ORDER BY CreatedDate ASC
		];
	}

	/**
	 * @description assertLog looks at the given Log__c for the other given values.
	 * @param log        Log__c making assertions against
	 * @param severity   Expected Severity of the Log__c
	 * @param app        Expected App of the Log__c
	 * @param message    Expected Message of the Log__c
	 * @param additional Expected Additional of the Log__c
	 */
	@SuppressWarnings('PMD.ApexUnitTestMethodShouldHaveIsTestAnnotation')
	public static void assertLog(Log__c log, Log.Severity severity, String app, String message, String additional) {
		Assert.areEqual(severity.name().toLowerCase(), log.Severity__c.toLowerCase(), 'Incorrect Severity');
		Assert.areEqual(app, log.Scope__c, 'Incorrect App');
		Assert.areEqual(message, log.Subject__c, 'Incorrect Message');
		Assert.areEqual(additional, log.Description__c, 'Incorrect Additional');
	}

	/**
	 * @description test_setLoggingLevels tests reading the Logging Metadata.
	 */
	@IsTest
	static void test_setLoggingLevels() {
		List<Log_Level_Settings__mdt> levels = new List<Log_Level_Settings__mdt>();

		Log.setLoggingLevels(levels);

		Assert.areEqual(Log.Severity.INFO, Log.logSeverity, 'Severity is INFO by default.');

		Log_Level_Settings__mdt settings = new Log_Level_Settings__mdt(Debug__c = 5);

		levels.add(settings);

		settings.Debug__c = 5;
		Log.setLoggingLevels(levels);
		Assert.areEqual(Log.Severity.INFO, Log.logSeverity, 'Severity is INFO.');

		settings.Debug__c = 4;
		Log.setLoggingLevels(levels);
		Assert.areEqual(Log.Severity.INFO, Log.logSeverity, 'Severity is INFO.');

		settings.Debug__c = 3;
		Log.setLoggingLevels(levels);
		Assert.areEqual(Log.Severity.WARN, Log.logSeverity, 'Severity is WARN.');

		settings.Debug__c = 2;
		Log.setLoggingLevels(levels);
		Assert.areEqual(Log.Severity.ERROR, Log.logSeverity, 'Severity is ERROR.');

		settings.Debug__c = 1;
		Log.setLoggingLevels(levels);
		Assert.areEqual(Log.Severity.ERROR, Log.logSeverity, 'Severity is ERROR.');

		settings.Debug__c = 0;
		Log.setLoggingLevels(levels);
		Assert.areEqual(Log.Severity.ERROR, Log.logSeverity, 'Severity is ERROR.');
	}

	/**
	 * @description test_info tests writing INFO log records.
	 */
	@IsTest
	static void test_info() {
		DateTime now = DateTime.now();

		Log.logSeverity = Log.Severity.INFO;

		Log.info('App 1', 'Info 1', 'Additional 1');
		Log.warn('App 2', 'Info 2', 'Additional 2');
		Log.error('App 3', 'Info 3', 'Additional 3');
		Log.history('HISTORY', 'Info 4', 'Additional 4');

		List<Log__c> logs = recentLogs(now);

		Assert.areEqual(4, logs.size(), 'Number of Log records written');
		assertLog(logs.get(0), Log.Severity.INFO, 'App 1', 'Info 1', 'Additional 1');
		assertLog(logs.get(1), Log.Severity.WARN, 'App 2', 'Info 2', 'Additional 2');
		assertLog(logs.get(2), Log.Severity.ERROR, 'App 3', 'Info 3', 'Additional 3');
		assertLog(logs.get(3), Log.Severity.HISTORY, 'HISTORY', 'Info 4', 'Additional 4');
	}

	/**
	 * @description test_warn tests writing WARN log records.
	 */
	@IsTest
	static void test_warn() {
		DateTime now = DateTime.now();

		Log.logSeverity = Log.Severity.WARN;

		Log.info('App 1', 'Info 1', null);
		Log.warn('App 2', 'Info 2', null);
		Log.warn('App 3', 'Info 3', 'Additional 3');
		Log.error('App 4', 'Info 4', 'Additional 4');
		Log.history('HISTORY', 'Info 5', 'Additional 5');

		List<Log__c> logs = recentLogs(now);

		Assert.areEqual(4, logs.size(), 'Number of Log records written');
		assertLog(logs.get(0), Log.Severity.WARN, 'App 2', 'Info 2', null);
		assertLog(logs.get(1), Log.Severity.WARN, 'App 3', 'Info 3', 'Additional 3');
		assertLog(logs.get(2), Log.Severity.ERROR, 'App 4', 'Info 4', 'Additional 4');
		assertLog(logs.get(3), Log.Severity.HISTORY, 'HISTORY', 'Info 5', 'Additional 5');
	}

	/**
	 * @description test_error tests writing ERROR log records.
	 */
	@IsTest
	static void test_error() {
		DateTime now = DateTime.now();

		Log.logSeverity = Log.Severity.ERROR;

		Log.info('App 1', 'Info 1', null);
		Log.warn('App 2', 'Info 2', 'Additional 2');
		Log.error('App 3', 'Info 3', null);
		Log.error('App 4', 'Info 4', 'Additional 4');
		Log.history('HISTORY', 'Info 5', 'Additional 5');

		List<Log__c> logs = recentLogs(now);

		Assert.areEqual(3, logs.size(), 'Number of Log records written');
		assertLog(logs.get(0), Log.Severity.ERROR, 'App 3', 'Info 3', null);
		assertLog(logs.get(1), Log.Severity.ERROR, 'App 4', 'Info 4', 'Additional 4');
		assertLog(logs.get(2), Log.Severity.HISTORY, 'HISTORY', 'Info 5', 'Additional 5');
	}

	/**
	 * @description test_history tests writing HISTORY log records.
	 */
	@IsTest
	static void test_history() {
		DateTime now = DateTime.now();

		Log.logSeverity = Log.Severity.WARN;

		Log.history('HISTORY', 'Info 1', 'Additional 1');

		List<Log__c> logs = recentLogs(now);

		Assert.areEqual(1, logs.size(), 'Number of Log records written');
		assertLog(logs.get(0), Log.Severity.HISTORY, 'HISTORY', 'Info 1', 'Additional 1');
	}

	/**
	 * @description test_futureWrite tests writing a future log record.
	 */
	@IsTest
	static void test_futureWrite() {
		DateTime now = DateTime.now();

		Test.startTest();

		Log.futureWrite('WARN', 'App', 'Message', 'Additional');

		Test.stopTest();

		List<Log__c> logs = recentLogs(now);

		Assert.areEqual(1, logs.size(), 'Should have 1 new log');

		Log__c testLog = logs.get(0);
		Assert.areEqual('Warn', testLog.Severity__c, 'Incorrect Severity');
		Assert.areEqual('App', testLog.Scope__c, 'Incorrect App');
		Assert.areEqual('Message', testLog.Subject__c, 'Incorrect Message');
		Assert.areEqual('Additional', testLog.Description__c, 'Additional should have a value');
	}

	/**
	 * @description test_write_Exception tests writing exceptions.
	 */
	@IsTest
	static void test_write_Exception() {
		DateTime now = DateTime.now();

		Log.logSeverity = Log.Severity.WARN;

		Log.write(Log.Severity.ERROR, 'Bundle 1', 'Subject 1', 'Additional 1');

		Exception ex = new LogTestException('Parameter is invalid');
		Exception e = new LogTestException('Parameter is invalid', ex);
		Log.write(Log.Severity.ERROR, 'Bundle 2', 'Subject 2', null, e);

		Log.error('Bundle 3', 'Subject 3', 'DESCRIPTION', e);

		List<Log__c> logs = recentLogs(now);

		Assert.areEqual(3, logs.size(), 'Number of Log records written');

		Log__c testLog;

		testLog = logs.get(0);
		assertLog(logs.get(0), Log.Severity.ERROR, 'Bundle 1', 'Subject 1', 'Additional 1');

		testLog = logs.get(1);
		Assert.isTrue('ERROR' == testLog.Severity__c, 'Incorrect Severity');
		Assert.areEqual('Bundle 2', testLog.Scope__c, 'Incorrect Bundle');
		Assert.areEqual('Subject 2', testLog.Subject__c, 'Incorrect Message');
		Assert.areNotEqual(null, testLog.Description__c, 'Additional should have a value');
		Assert.isTrue(testLog.Description__c.contains('EXCEPTION CAUSE:'), 'Cause is expected');

		testLog = logs.get(2);
		Assert.isTrue('ERROR' == testLog.Severity__c, 'Incorrect Severity');
		Assert.areEqual('Bundle 3', testLog.Scope__c, 'Incorrect Bundle');
		Assert.areEqual('Subject 3', testLog.Subject__c, 'Incorrect Message');
		Assert.areNotEqual(null, testLog.Description__c, 'Additional should have a value');
		Assert.isTrue(testLog.Description__c.contains('EXCEPTION CAUSE:'), 'Cause is expected');
	}

	/**
	 * @description test_writeIfError_DatabaseError tests writing Database Error log records.
	 */
	@IsTest
	static void test_writeIfError_DatabaseError() {
		DateTime now = DateTime.now();

		List<Database.Error> errs = new List<Database.Error>();
		errs.add(TestUtility.newDatabaseError('Invalid URL', StatusCode.WEBLINK_URL_INVALID, null));
		errs.add(
			TestUtility.newDatabaseError('Invalid URL', StatusCode.WEBLINK_URL_INVALID, new List<String>{ 'FIELD ' })
		);
		Log.write(Log.Severity.ERROR, 'Bundle', 'Subject', 'Description', errs);

		List<Log__c> logs = recentLogs(now);

		Assert.areEqual(1, logs.size(), 'Number of Log records written');

		Log__c testLog;

		testLog = logs.get(0);

		Assert.areEqual('error', testLog.Severity__c.toLowerCase(), 'Incorrect Severity');
		Assert.areEqual('Bundle', testLog.Scope__c, 'Incorrect Bundle');
		Assert.areEqual('Subject', testLog.Subject__c, 'Incorrect Subject');
		Assert.isTrue(testLog.Description__c.startsWith('Description'), 'Incorrect Additional information');
	}

	/**
	 * @description test_writeIfError_DeleteResult tests writing DeleteResult database log records.
	 */
	@IsTest
	static void test_writeIfError_DeleteResult() {
		DateTime now = DateTime.now();

		List<Database.DeleteResult> srs = new List<Database.DeleteResult>();

		srs.add(
			TestUtility.newDatabaseDeleteResult(
				Id.valueOf(ID_TEST_ACCOUNT),
				false,
				new List<String>{ 'Size Exceeded' },
				new List<StatusCode>{ StatusCode.WEBLINK_SIZE_LIMIT_EXCEEDED },
				new List<String>{ 'Field 1', 'Field 2' }
			)
		);
		Log.writeIfError('Bundle', 'Subject', 'Description', srs);

		List<Log__c> logs = recentLogs(now);

		Assert.areEqual(1, logs.size(), 'Number of Log records written');

		Log__c testLog;

		testLog = logs.get(0);

		Assert.areEqual('error', testLog.Severity__c.toLowerCase(), 'Incorrect Severity');
		Assert.areEqual('Bundle', testLog.Scope__c, 'Incorrect Bundle');
		Assert.areEqual('Subject', testLog.Subject__c, 'Incorrect Subject');
		Assert.isTrue(testLog.Description__c.startsWith('Description'), 'Incorrect Additional information');
	}

	/**
	 * @description test_writeIfError_SaveResult tests writing database log records.
	 */
	@IsTest
	static void test_writeIfError_SaveResult() {
		DateTime now = DateTime.now();

		List<Database.SaveResult> srs = new List<Database.SaveResult>();

		srs.add(
			TestUtility.newDatabaseSaveResult(
				Id.valueOf(ID_TEST_ACCOUNT),
				false,
				new List<String>{ 'Size Exceeded' },
				new List<StatusCode>{ StatusCode.WEBLINK_SIZE_LIMIT_EXCEEDED },
				new List<String>{ 'Field 1', 'Field 2' }
			)
		);
		Log.writeIfError('Bundle', 'Subject', 'Description', srs);

		List<Log__c> logs = recentLogs(now);

		Assert.areEqual(1, logs.size(), 'Number of Log records written');

		Log__c testLog;

		testLog = logs.get(0);

		Assert.areEqual('error', testLog.Severity__c.toLowerCase(), 'Incorrect Severity');
		Assert.areEqual('Bundle', testLog.Scope__c, 'Incorrect Bundle');
		Assert.areEqual('Subject', testLog.Subject__c, 'Incorrect Subject');
		Assert.isTrue(testLog.Description__c.startsWith('Description'), 'Incorrect Additional information');
	}

	/**
	 * @description test_writeIfError_UpsertResult tests writing UpsertResult database log records.
	 */
	@IsTest
	static void test_writeIfError_UpsertResult() {
		DateTime now = DateTime.now();

		List<Database.UpsertResult> urs = new List<Database.UpsertResult>();
		urs.add(
			TestUtility.newDatabaseUpsertResult(
				Id.valueOf(ID_TEST_ACCOUNT),
				false,
				new List<String>{ 'Invalid URL' },
				new List<StatusCode>{ StatusCode.WEBLINK_URL_INVALID },
				null
			)
		);
		Log.writeIfError('Bundle', 'Subject', 'Description', urs);

		List<Log__c> logs = recentLogs(now);

		Assert.areEqual(1, logs.size(), 'Number of Log records written');

		Log__c testLog;

		testLog = logs.get(0);

		Assert.areEqual('error', testLog.Severity__c.toLowerCase(), 'Incorrect Severity');
		Assert.areEqual('Bundle', testLog.Scope__c, 'Incorrect Bundle');
		Assert.areEqual('Subject', testLog.Subject__c, 'Incorrect Subject');
		Assert.isTrue(testLog.Description__c.startsWith('Description'), 'Incorrect Additional information');
	}

	/**
	 * @description test_writeIfError_UpsertResult tests writing UpsertResult database log records.
	 */
	@IsTest
	static void test_parseSeverity() {
		Assert.areEqual(Log.Severity.INFO, Log.parseSeverity('INFO'));
		Assert.areEqual(Log.Severity.WARN, Log.parseSeverity('WaRn'));
		Assert.areEqual(Log.Severity.ERROR, Log.parseSeverity('error'));
		Assert.areEqual(Log.Severity.HISTORY, Log.parseSeverity('HISTORY'));
		Assert.areEqual(Log.Severity.INFO, Log.parseSeverity(null));
		Assert.areEqual(Log.Severity.INFO, Log.parseSeverity('BadValue'));
	}

	/**
	 * @description test_writeIfError_UpsertResult tests writing UpsertResult database log records.
	 */
	@IsTest
	static void test_LogObject() {
		DateTime now = DateTime.now();

		Log logTest;
		logTest = new Log();
		Assert.areEqual(Log.Severity.INFO, logTest.severity);
		Assert.areEqual('', logTest.bundle);
		Assert.areEqual('', logTest.subject);
		Assert.areEqual('', logTest.description);

		logTest = new Log(Log.Severity.ERROR, 'BUNDLE', 'SUBJECT');
		Assert.areEqual(Log.Severity.ERROR, logTest.severity);
		Assert.areEqual('BUNDLE', logTest.bundle);
		Assert.areEqual('SUBJECT', logTest.subject);
		Assert.areEqual('', logTest.description);

		logTest = new Log(Log.Severity.WARN, 'BUNDLE', 'SUBJECT', 'MESSAGE');
		Assert.areEqual(Log.Severity.WARN, logTest.severity);
		Assert.areEqual('BUNDLE', logTest.bundle);
		Assert.areEqual('SUBJECT', logTest.subject);
		Assert.areEqual('MESSAGE', logTest.description);

		logTest.clear();
		Assert.areEqual(Log.Severity.WARN, logTest.severity);
		Assert.areEqual('BUNDLE', logTest.bundle);
		Assert.areEqual('SUBJECT', logTest.subject);
		Assert.areEqual('', logTest.description);

		logTest.add('Initial Line');
		Assert.areEqual('Initial Line', logTest.description);
		logTest.addLine('New Line');
		Assert.areEqual('Initial Line\nNew Line', logTest.description);
        logTest.clear();
        logTest.addline();
        Assert.areEqual('\n', logTest.description);

		logTest.write();
		logTest.write(Log.Severity.HISTORY, 'B', 'S');

		List<Log__c> logs = recentLogs(now);
		Assert.areEqual(2, logs.size());
		Assert.areEqual('Warn', logs[0].Severity__c);
		Assert.areEqual('BUNDLE', logs[0].Scope__c);
		Assert.areEqual('History', logs[1].Severity__c);
		Assert.areEqual('B', logs[1].Scope__c);
	}
}