/**
 * @description SOQL_Services contains methods to help with querying Salesforce data.
 */
public without sharing class SOQL_Services {
	private static final String FORMAT_FULL_QUERY = 'SELECT {0} FROM {1} ';
	private static final String FORMAT_QUERY = 'SELECT {0} FROM {1} {2}';

	private static final String COMMA = ',';

	/**
	 * @description makeQuery retrieves a query String which contains the SELECT and
	 * FROM parts and clarification.
	 * @param  fields         Set of fields to query
	 * @param  nameSobject    SObject querying
	 * @param  clarification  The WHERE, ORDER, LIMIT, etc
	 * @return Query string
	 */
	public static String makeQuery(String nameSObject, Set<String> fields, String clarification) {
		return String.format(FORMAT_QUERY, new List<String>{ fieldList(fields), nameSobject, clarification });
	}

	/**
	 * @description callQuery retrieves the SOBjects for the given query data.
	 * @param  fields         Set of fields to query
	 * @param  nameSobject    SObject querying
	 * @param  clarification  The WHERE, ORDER, LIMIT, etc
	 * @return Map<Id, SObject>
	 */
	public static Map<Id, SObject> callQuery(String nameSObject, Set<String> fields, String clarification) {
		String query = makeQuery(nameSObject, fields, clarification);

		return new Map<Id, SObject>(Database.query(query));
	}

	/**
	 * @description getFullObjectQuery retrieves a query which contains the SELECT and FROM parts.
	 * The SELECT contains all the accessible fields.
	 * @param  nameSobject  SObject querying
	 * @return Query string
	 */
	public static string getFullObjectQuery(String nameSobject) {
		String fields = '';

		for (
			Schema.sObjectField field : Schema.getGlobalDescribe()
				.get(nameSobject)
				.getDescribe()
				.Fields.getMap()
				.values()
		) {
			Schema.DescribeFieldResult dfr = field.getDescribe();

			if (dfr.isAccessible()) {
				fields += field + ',';
			}
		}

		fields = fields.subString(0, fields.length() - 1);

		return String.format(FORMAT_FULL_QUERY, new List<String>{ fields, nameSobject });
	}

	/**
	 * @description joinIds makes a single string by adding single quotes around
	 * the ids and commas between them.
	 * @param  ids  Identifiers to
	 * @return String
	 */
	public static String joinIds(Set<Id> ids) {
		String result = '';

		for (Id id : ids) {
			result += '\'' + id + '\',';
		}

		if (result.endsWith(',')) {
			result = result.left(result.length() - 1);
		}

		return result;
	}

	/**
	 * @description fieldList converts a Set of field names into a single comma deliminated String.
	 * @param  fields  Fields names
	 * @return Comma deliminated String.
	 */
	@TestVisible
	private static String fieldList(Set<String> fields) {
		if (fields == null || fields.isEmpty()) {
			return 'Id';
		}

		return String.join(new List<String>(fields), COMMA);
	}
}