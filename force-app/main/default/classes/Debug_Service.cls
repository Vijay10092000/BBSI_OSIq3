/**
 * @description Debug_Service holds methods to send SObject data to System.debug.
 */
public without sharing class Debug_Service {
	/**
	 * @description dumpLimits writes Salesforce limits information to debug.
	 * @param  level  Logging level
	 */
	public static void dumpLimits(LoggingLevel level) {
		String ouput = 'SALESFORCE LIMITS';

		ouput +=
			'\r\n. Aggregate Queries: ' +
			Limits.getAggregateQueries() +
			' of ' +
			Limits.getLimitAggregateQueries();
		ouput += '\r\n. Async Calls: ' + Limits.getAsyncCalls() + ' of ' + Limits.getLimitAsyncCalls();
		ouput += '\r\n. Callouts: ' + Limits.getCallouts() + ' of ' + Limits.getLimitCallouts();
		ouput += '\r\n. Cpu Time: ' + Limits.getCpuTime() + ' of ' + Limits.getLimitCpuTime();
		ouput += '\r\n. DML Rows: ' + Limits.getDMLRows() + ' of ' + Limits.getLimitDMLRows();
		ouput +=
			'\r\n. Email Invocations: ' +
			Limits.getEmailInvocations() +
			' of ' +
			Limits.getLimitEmailInvocations();
		ouput +=
			'\r\n. Find Similar Calls: ' +
			Limits.getFindSimilarCalls() +
			' of ' +
			Limits.getLimitFindSimilarCalls();
		ouput += '\r\n. Future Calls: ' + Limits.getFutureCalls() + ' of ' + Limits.getLimitFutureCalls();
		ouput += '\r\n. Heap Size: ' + Limits.getHeapSize() + ' of ' + Limits.getLimitHeapSize();
		ouput +=
			'\r\n. Mobile Push Apex Calls: ' +
			Limits.getMobilePushApexCalls() +
			' of ' +
			Limits.getLimitMobilePushApexCalls();
		ouput +=
			'\r\n. Query LocatorRows: ' +
			Limits.getQueryLocatorRows() +
			' of ' +
			Limits.getLimitQueryLocatorRows();
		ouput += '\r\n. Query Rows: ' + Limits.getQueryRows() + ' of ' + Limits.getLimitQueryRows();
		ouput += '\r\n. Queueable Jobs: ' + Limits.getQueueableJobs() + ' of ' + Limits.getLimitQueueableJobs();
		ouput += '\r\n. Sosl Queries: ' + Limits.getSoslQueries() + ' of ' + Limits.getLimitSoslQueries();

		System.debug(level, ouput);
	}

	/**
	 * @description debug sends Database Save Results to the System debug
	 * @param  level       Logging level
	 * @param  srs         Database Save Results
	 * @param  showSuccess Show success message?
	 * @return true if all successful
	 */
	public static Boolean debug(LoggingLevel level, List<Database.SaveResult> srs, Boolean showSuccess) {
		Boolean success = true;
		List<String> output = new List<String>();

		for (Database.SaveResult sr : srs) {
			if (sr.isSuccess()) {
				if (showSuccess) {
					output.add('Successful database call for ID: ' + sr.getId());
				}
			} else {
				success = false;
				for (Database.Error err : sr.getErrors()) {
					output.add(
						'Failed database call: ' +
						err.getStatusCode() +
						'\r\n. ' +
						err.getMessage() +
						'\r\n. Fields: ' +
						err.getFields()
					);
				}
			}
		}

		for (String s : output) {
			System.debug(level, s);
		}

		return success;
	}

	/**
	 * @description debug sends all the populated fields of the given SObjects to System.debug.
	 * @param level   Logging level
	 * @param objects List of Strings
	 */
	public static void debug(LoggingLevel level, String title, List<String> texts) {
		String output = '';

		if (texts != null) {
			Integer count = 0;

			for (String s : texts) {
				output += '\n[' + count + ']: ' + s;
				++count;
			}
		}

		System.debug(level, output);
	}

	/**
	 * @description debug sends all the populated fields of the given SObjects to System.debug.
	 * @param level   Logging level
	 * @param objects List of SObjects
	 */
	public static void debug(LoggingLevel level, List<SObject> objects) {
		debug(level, null, objects);
	}

	/**
	 * debug sends all the populated fields of the given SObjects to System.debug.
	 * @param level Logging level
	 * @param title Text added before each SObject start
	 * @param obj   List of SObjects
	 */
	public static void debug(LoggingLevel level, String title, SObject obj) {
		debug(level, title, new List<SObject>{ obj });
	}

	/**
	 * @description debug sends all the populated fields of the given SObjects to System.debug.
	 * @param level   Logging level
	 * @param title   Text added before each SObject start
	 * @param objects List of SObjects
	 */
	public static void debug(LoggingLevel level, String title, List<SObject> objects) {
		String output = '';
		Integer count = 1;

		for (SObject o : objects) {
			List<String> fields = new List<String>(o.getPopulatedFieldsAsMap().keySet());
			fields.sort();

			output += '\n\n' + buildOutput(level, count + ' of ' + objects.size() + ': ' + title, o, fields);
			count++;
		}

		System.debug(level, output);
	}

	/**
	 * @description debug sends the outputFields of the given SObjects to System.debug.
	 * @param level   Logging level
	 * @param objects List of SObjects
	 * @param fields  Ordered List of fields to write
	 */
	public static void debug(LoggingLevel level, List<SObject> objects, List<String> fields) {
		debug(level, null, objects, fields);
	}

	/**
	 * debug sends the outputFields of the given SObjects to System.debug.
	 * @param level   Logging level
	 * @param title   Text added before each SObject start
	 * @param objects List of SObjects
	 * @param fields  Ordered List of fields to write
	 */
	@SuppressWarnings('PMD.ExcessiveParameterList')
	public static void debug(LoggingLevel level, String title, List<SObject> objects, List<String> fields) {
		List<String> output = new List<String>();
		Integer count = 1;

		for (SObject o : objects) {
			output.add(buildOutput(level, count + ' of ' + objects.size() + ': ' + title, o, fields));
			count++;
		}

		for (String out : output) {
			System.debug(level, out);
		}
	}

	/**
	 * @description buildOutput creates the text for the debug string
	 * @param level        Logging level
	 * @param title        Text added before each SObject start
	 * @param obj          Object to write
	 * @param outputFields Fields to write
	 * @return Text to display
	 */
	@SuppressWarnings('PMD.ExcessiveParameterList')
	private static String buildOutput(LoggingLevel level, String title, SObject obj, List<String> outputFields) {
		String output = '';
		if (title != null) {
			output += title + ' - ';
		}

		if (obj == null) {
			output += '[NULL]';
		} else {
			Map<String, Object> fieldData = obj.getPopulatedFieldsAsMap();
			Schema.DescribeSObjectResult describe = obj.getSObjectType().getDescribe();
			output += describe.getLabel() + ' (' + describe.getName() + ')';

			for (String field : outputFields) {
				if (fieldData.containsKey(field)) {
					output += '\r\n. ' + field + ' = ' + fieldData.get(field);
				} else {
					output += '\r\n. ' + field + '   [NOT SET]';
				}
			}
		}

		return output;
	}

	/**
	 * @description differences outputs the different fields between the two objects.
	 * @param  level    Logging level
	 * @param  title    Text added before each SObject start
	 * @param  objFrom  "FROM" Object
	 * @param  objTo    "TO" Object
	 */
	public static void differences(LoggingLevel level, String title, SObject objFrom, SObject objTo) {
		System.debug(level, title + differencesText(objFrom, objTo));
	}

	/**
	 * @description differences outputs the different fields between the two objects.
	 * @param  level     Logging level
	 * @param  title     Text added before each SObject start
	 * @param  objFroms  "FROM" Map of Object
	 * @param  objTos    "TO" Map of Object
	 */
	public static void differences(
		LoggingLevel level,
		String title,
		Map<Id, SObject> objFroms,
		Map<Id, SObject> objTos
	) {
		String output = title;
		String fromOnly = '';
		String toOnly = '';

		for (Id idFrom : objFroms.keySet()) {
			if (objTos.containsKey(idFrom)) {
				SObject objFrom = objFroms.get(idFrom);
				SObject objTo = objTos.get(idFrom);

				output += '\nID: ' + idFrom + differencesText(objFrom, objTo);
			} else {
				fromOnly += '\nID: ' + idFrom + ' -- IN "FROM" ONLY';
			}
		}

		for (Id idTo : objTos.keySet()) {
			if (!objFroms.containsKey(idTo)) {
				toOnly += '\nID: ' + idTo + ' -- IN "TO" ONLY';
			}
		}

		System.debug(level, output + fromOnly + toOnly);
	}

	/**
	 * @description differencesText outputs the different fields between the two objects.
	 * @param  objFrom  First Object
	 * @param  objTo    Second Object
	 * @return Text with the differences
	 */
	private static String differencesText(SObject objFrom, SObject objTo) {
		String output = '';

		if (objFrom.getSObjectType() == objTo.getSObjectType()) {
			Set<String> fields = objTo.getPopulatedFieldsAsMap().keySet();

			Boolean hasFieldFrom;
			Object valueFrom;
			Object valueTo;

			for (String field : fields) {
				hasFieldFrom = objFrom.isSet(field);

				if (hasFieldFrom) {
					valueFrom = objFrom.get(field);
					valueTo = objTo.get(field);

					if (valueFrom != valueTo) {
						output += '\n  ' + field + ':  ' + valueFrom + '  !=  ' + valueTo;
					}
				} else {
					valueTo = objTo.get(field);
					output += '\n  ' + field + ':  [null] != ' + valueTo;
				}
			}
		} else {
			System.debug(LoggingLevel.ERROR, 'Debug_Services.differencesText: Comparing different object types.');
			output = ' -- ERROR';
		}

		return output;
	}
}