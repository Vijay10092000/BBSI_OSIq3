/**
 * @description Lookup_Controller is the controller class for the Lookup component.
 */
public without sharing class SObjectSelector_Controller {
	private static final String FORMAT_QUERY = 'SELECT {0} FROM {1} WHERE {2} ORDER BY {3} ASC LIMIT {4}';
	private static final String FORMAT_WHERE_FIND = ' OR {0} LIKE \'%{1}%\'';

	@TestVisible
	private static final String KIND_BAR_REFERRAL_PARTNER = 'BAR: Referral Partners';

	/**
	 * @description ResultWrapper holds the text and values used for selection in the component.
	 */
	public class ResultWrapper {
		public String text { get; set; }
		public String value { get; set; }

		public ResultWrapper(String text, String value) {
			this.text = text;
			this.value = value;
		}
	}

	/**
	 * @description query searches based on the given data for related records.
	 * @param  fromObject    Name of SObject
	 * @param  fieldLabel    API field name to display
	 * @param  fieldValue    API field name to be returned by Lookup COmponent
	 * @param  searchFields  API field names to be searched
	 * @param  recordTypes   RecordTypes for search
	 * @param  searchText    Text searching for
	 * @param  maximum       Number of records to be returned
	 * @return JSON of List of ResultWrapper
	 * */
	@AuraEnabled(cacheable=true)
	public static String query(
		String fromObject,
		String fieldLabel,
		String fieldValue,
		List<String> searchFields,
		List<String> recordTypes,
		String findText,
		Integer maximum,
		String kind
	) {
		List<ResultWrapper> result = new List<ResultWrapper>();

		String query = buildQuery(
			fromObject,
			fieldLabel,
			fieldValue,
			searchFields,
			recordTypes,
			findText,
			maximum,
			kind
		);

		for (SObject obj : search(query)) {
			result.add(
				new ResultWrapper(
					buildLabel(obj, (String) obj.get(fieldLabel), kind), 
					String.valueOf(obj.get(fieldValue))
				)
			);
		}

		return JSON.serialize(result);
	}

	/**
	 * @description search makes the query to the database.
	 * @return List<SObject>
	 */
	@TestVisible
	private static List<SObject> search(String query) {
		return Database.query(query);
	}

	/**
	 * @description buildQuery creates the query string.
	 * @param  fromObject    Name of SObject
	 * @param  fieldLabel    API field name to display
	 * @param  fieldValue    API field name to be returned by Lookup Component
	 * @param  searchFields  API field names to be searched
	 * @param  recordTypes   RecordTypes for search
	 * @param  searchText    Text searching for
	 * @param  maximum       Number of records to be returned
	 * @return Query string
	 */
	@TestVisible
	private static String buildQuery(
		String fromObject,
		String fieldLabel,
		String fieldValue,
		List<String> searchFields,
		List<String> recordTypes,
		String findText,
		Integer maximum,
		String kind
	) {
		String fields = getFields(fieldLabel, fieldValue, kind);

		String search = String.escapeSingleQuotes(findText.trim());
		String whereClause = '';
		String whereTypes = '';

		for (String field : searchFields) {
			whereClause += String.format(FORMAT_WHERE_FIND, new List<String>{ field, search });
		}
		whereClause = whereClause.substring(4);
		whereClause = '(' + whereClause + ')';

		if (!recordTypes.isEmpty()) {
			for (String rt : recordTypes) {
				whereTypes += ',\'' + rt + '\'';
			}

			whereTypes = whereTypes.substring(1);
			whereTypes = ' AND RecordType.Name IN (' + whereTypes + ')';
		}

		if (maximum <= 0) {
			maximum = 1;
		}

		return String.format(
			FORMAT_QUERY,
			new List<String>{
				fields,
				fromObject,
				whereClause + whereTypes,
				fieldLabel,
				String.ValueOf(maximum)
			}
		);
	}

	/**
	 * @descption getFields determines which fields need to be read and creates
	 * a comma delimited list of the fields.
	 * 
	 */
	private static String getFields(String label, String value, String kind) {
		Set<String> setFields = new Set<String>();

		setFields.add('id');
		setFields.add(label.toLowerCase());
		setFields.add(value.toLowerCase());

		if (kind == KIND_BAR_REFERRAL_PARTNER) {
			setFields.add('external_id__c');
			setFields.add('recordtype.name');
		}

		List<String> fields = new List<String>(setFields);
		fields.sort();
		
		return String.join(fields, ', ');
	}

	private static String buildLabel(SObject obj, String label, String kind) {
		if (kind == KIND_BAR_REFERRAL_PARTNER) {

			SObject objRT = obj.getSObject('RecordType');

			String rtName = (String) objRT.get('name');

			if (rtName == 'Referral Partner') {
				return obj.get('external_id__c') + ' - ' + label;
			}
		}
			
		return label;
	}
}