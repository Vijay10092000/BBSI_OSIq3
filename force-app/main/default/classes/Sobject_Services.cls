/**
 * @description Sobject_Services contains helper methods to access SObjects.
 */
public with sharing class Sobject_Services {
	/**
	 * @description getType retrieves the SObject name related to the given Id.
	 * @param  idObject
	 * @return The name of the SObject
	 */
	public static String getType(Id idObject) {
		return idObject?.getSObjectType().getDescribe().getName();
	}

	/**
	 * @description getIdPrefix retrieves the 3 letter prefix of an Id given SObject.
	 * @param  nameObject Object looking for
	 * @return A 3 character string with the prefix
	 */
	public static String getIdPrefix(String nameObject) {
		SObject instance = (SObject) Type.forName('Schema.' + nameObject).newInstance();
		return instance.getSObjectType().getDescribe().getKeyPrefix();
	}

	/**
	 * @description getFieldNames retrieve field names for the Sobject
	 * @param  nameSobject Name of the Sobject
	 * @return List<String>
	 */
	public static List<String> getFieldNames(String nameSobject) {
		Map<String, Schema.sObjectField> fields = getFieldsMap(nameSobject);

		List<String> result = new List<String>(fields.keySet());

		result.sort();

		return result;
	}
	/**
	 * @description getCustomFieldNames retrieve field names for the Sobject
	 * @param  nameSobject Name of the Sobject
	 * @return List<String>
	 */
	public static List<String> getCustomFieldNames(String nameSobject) {
		List<String> result = new List<String>();

		Map<String, Schema.sObjectField> fields = getFieldsMap(nameSobject);

		for (String key : fields.keySet()) {
			if (fields.get(key).getDescribe().isCustom()) {
				result.add(key);
			}
		}

		result.sort();

		return result;
	}

	/**
	 * @description getFieldsMap retrieves a Map of the object fields.
	 * @param  nameSobject  Name of the Sobject
	 * @return Map<String, Schema.sObjectField> related to the Sobject
	 */
	public static Map<String, Schema.sObjectField> getFieldsMap(String nameSobject) {
		Schema.SObjectType convertType = Schema.getGlobalDescribe().get(nameSobject);
		return convertType.getDescribe().Fields.getMap();
	}

	/**
	 * @description getValue returns the value or if null returns default value
	 * @param  value  Decimal Object
	 * @param  def    Default value
	 * @return Decimal
	 */
	public static Decimal getValue(Decimal value, Decimal def) {
		return (value == null) ? def : value;
	}

	/**
	 * @description debug writes the SObject to System.debug
	 * @param  level  LoggingLevel
	 * @param  title  Initial string defining log message
	 * @param  obj    SObject to write
	 */
	@SuppressWarnings('PMD.AvoidSystemDebugUsage')
	public static void debug(LoggingLevel level, String title, sObject obj) {
		System.debug(level, title + '  ' + toString(obj));
	}

	/**
	 * @description debug writes the SObject to System.debug
	 * @param  level  LoggingLevel
	 * @param  title  Initial string defining log message
	 * @param  objs   List of SObjects to write
	 */
	@SuppressWarnings('PMD.AvoidSystemDebugUsage')
	public static void debug(LoggingLevel level, String title, List<sObject> objs) {
		if (objs == null || 0 == objs.size()) {
			System.debug(level, title + '  No objects found in list.');
		} else {
			for (Integer index = 1; index <= objs.size(); ++index) {
				System.debug(level, title + '  ' + index + ': ' + toString(objs[index - 1]));
			}
		}
	}

	/**
	 * @description toString creates a String with the SObject type and list
	 * of fields set with values.
	 * @param  obj    SObject to write
	 * @return String with object type and fields set
	 */
	public static String toString(sObject obj) {
		String result = obj.getSObjectType().getDescribe().getName();

		for (String field : getFieldsSet(obj)) {
			result += '\n  ' + field + ': ' + obj.get(field);
		}

		return result;
	}

	/**
	 * @description getFieldsSet retrieves the names of fields set on the given SObject.
	 * @param  obj  SObject to looking at
	 * @return Set of field names
	 */
	public static List<String> getFieldsSet(sObject obj) {
		if (obj != null) {
			Map<String, Object> fieldValues = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(obj));

			if (fieldValues.containsKey('attributes')) {
				fieldValues.remove('attributes');
			}

			List<String> fields = new List<String>(fieldValues.keySet());
			fields.sort();
			return fields;
		}

		return new List<String>();
	}

	/**
	 * @description describeObjects reads the Schema.DescribeSObjectResult
	 * data for all objects.
	 * @return Map<String, Schema.DescribeSObjectResult> mapping object
	 * name to DescribeSObjectResult
	 */
	public static Map<String, Schema.DescribeSObjectResult> describeObjects() {
		Map<String, Schema.DescribeSObjectResult> result = new Map<String, Schema.DescribeSObjectResult> ();
		Map<String, Schema.SObjectType> describe = Schema.getGlobalDescribe();

		for (String name : describe.keySet()) {
			result.put(name, describe.get(name).getDescribe());
		}

		return result;
	}

	/**
	 * @description describeObject reads the Schema.DescribeSObjectResult
	 * data for the given object.
	 * @param nameSobject  Name of a SObject
	 * @return Schema.DescribeSObjectResult
	 */
	public static Schema.DescribeSObjectResult describeObject(String nameSobject) {
		Schema.SObjectType sobjType = Schema.getGlobalDescribe().get(nameSobject);
		return sobjType.getDescribe();
	}

	/**
	 * @description describeFields reads the Schema.DescribeFieldResult
	 * data for all the fields of an object.
	 * @param nameSobject  Name of a SObject
	 * @return Map<String, Schema.DescribeFieldResult> mapping field name to DescribeFieldResult
	 */
	public static Map<String, Schema.DescribeFieldResult> describeFields(String nameSobject) {
		Map<String, Schema.DescribeFieldResult> result = new Map<String, Schema.DescribeFieldResult>();

		Schema.DescribeSObjectResult describe = describeObject(nameSobject);

		Map<String, SObjectField> fields = describe.fields.getMap();

		for (String name : fields.keySet()) {
			result.put(name, fields.get(name).getDescribe());
		}

		return result;
	}

	/**
	 * @description describeField reads the Schema.DescribeFieldResult
	 * data for the given fields of an object.
	 * @param nameSobject  Name of a SObject
	 * @param nameField    Name of the field
	 * @return Schema.DescribeFieldResult
	 */
	public static Schema.DescribeFieldResult describeField(String nameSobject, String nameField) {
		Schema.DescribeSObjectResult describe = describeObject(nameSobject);

		Map<String, SObjectField> fields = describe.fields.getMap();

		return fields.get(nameField).getDescribe();
	}

	/**
	 * @description getSearchResult retrieves a list of SObjecrResults for the given query.
	 * @param  nameObject   Name of the SObject querying
	 * @param  field        Field to return in name
	 * @param  whereClause  The search WHERE clause
	 * @param  orderbBy     The ORDER BY valuesclause
	 * @param  maximum      The LIMIT values
	 * @return List<SObjectResult>
	 * 
	 * https://www.youtube.com/watch?v=vdrxb1DcjiE
	 */
	public static List<SObjectResult> getSearchResult(String nameObject, String field, String whereClause, String orderbBy, Integer maximum) {
		List<SObjectResult> result = new List<SObjectResult>();

		String query = 'SELECT Id, ' + field + ' FROM ' + nameObject;

		if (whereClause != null) {
			query +=  ' WHERE ' + whereClause;
		}

		if (orderbBy != null) {
			query += ' ORDER BY ' + orderbBy;
		}

		if (maximum != null && 0 < maximum) {
			query += ' LIMIT ' + maximum;
		}

		for (SObject obj : Database.query(query)) {
			result.add( new SObjectResult(obj.Id, (String) obj.get(field)) );
		}

		return result;
	}

	/**
	 * @description SObjecResult holds the identifier and name of a SObject.
	 */
	public class SObjectResult {
		@AuraEnabled
		public Id id;

		@AuraEnabled
		public String name;

		/**
		 * @description SObjectResult constructor.
		 * @param  id    Identifier
		 * @param  name  Name
		 */
		public SObjectResult(String id, String name) {
			this.id = id;
			this.name = name;
		}
	}

	/**
	 * @description getChangedFields determines the differences between the given SObjects.  SObjects should be of the same type.
	 * @param  record1  First Object to check  
	 * @param  record2  Second Object to check
	 * @param  fieldList  Fields checking
	 * @return List<Schema.sObjectField>
	 */
	public List<Schema.sObjectField> getChangedFields(SObject record1, SObject record2, List<Schema.sObjectField> fieldList) {
		List<Schema.sObjectField> result = new List<Schema.sObjectField>();
	
		for (Schema.sObjectField field : fieldList) {
			if (record1.get(field) != record2.get(field)) {
				result.add(field);
			}
		}

		return result;
	}
}