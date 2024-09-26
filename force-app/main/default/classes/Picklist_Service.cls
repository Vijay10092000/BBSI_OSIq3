/**
 * @description Picklist_Service methods to access Picklist values.
 */
public without sharing class Picklist_Service {
	// sPicklistValues stores the picklist values only call
	@TestVisible
	private static Map<String, Map<String, List<String>>> sPicklistValues = null;

	// sIdRecordType is the Record Type used in picklist call
	@TestVisible
	private static Id sIdRecordType = null;

	// countCallouts is used for testing to confirm minimum callouts
	@TestVisible
	private static Integer countCallouts = 0;

	/**
	 * @description getPicklistValuesByRecordType retrieves picklist values for
	 * the given information.
	 * If the picklist is independent, the key values of the returned map are the
	 * values for the picklist.
	 * If the picklise is dependent, the key values are the parent values and the
	 * list is the values for the picklist.
	 * @param nameSobject  Name of SObject to get picklist values
	 * @param idRecordType Identifier of Record Type
	 * @param nameField    Name of picklist field
	 * @return The picklist values
	 */
	public static Map<String, List<String>> getPicklistValuesByRecordType(
		String nameSobject,
		String idRecordType,
		String nameField
	) {
		System.debug(
			LoggingLevel.FINEST,
			'Picklist_Service.getPicklistValuesByRecordType(' +
			nameSobject +
			', ' +
			idRecordType +
			', ' +
			nameField +
			')'
		);

		if (idRecordType != sIdRecordType) {
			readRecordType(nameSobject, idRecordType);
		}

		if (sPicklistValues != null) {
			if (sPicklistValues.containsKey(nameField)) {
				return sPicklistValues.get(nameField);
			}
		}

		return new Map<String, List<String>>();
	}

	/**
	 * @description readCaseRecordType reads the picklist values for the given SObject
	 * and Record Type
	 * @param nameSobject    Name of SObject to get picklist values
	 * @param idRecordType   Record Type identifier
	 */
	@TestVisible
	private static void readRecordType(String nameSobject, Id idRecordType) {
		sPicklistValues = null;
		sIdRecordType = null;
		countCallouts++;
		
		HttpResponse response = HttpCallout.picklistValuesUiApi(nameSobject, idRecordType);

		if (response != null) {
			if (response.getStatusCode() == 200) {
				sPicklistValues = parseJsonPicklistValues(response.getBody());

				if (sPicklistValues != null) {
					sIdRecordType = idRecordType;
				}
			}
		}
	}

	/**
	 * @description parseJsonPicklistValues description
	 * @param  jsonData JSON data to parse
	 * @return Map relating all the picklist names to there values
	 */
	@TestVisible
	private static Map<String, Map<String, List<String>>> parseJsonPicklistValues(String jsonData) {
		Map<String, Map<String, List<String>>> result = new Map<String, Map<String, List<String>>>();

		Map<String, Object> root = (Map<String, Object>) JSON.deserializeUntyped(jsonData);

		if (!root.containsKey('picklistFieldValues')) {
			return null;
		}

		Map<String, Object> picklists = (Map<String, Object>) root.get('picklistFieldValues');

		for (String namePicklist : picklists.keySet()) {
			Map<String, Object> picklist = (Map<String, Object>) picklists.get(namePicklist);
			Map<String, List<String>> parent = new Map<String, List<String>>();

			Map<Integer, String> mapControllerValues = new Map<Integer, String>();

			if (picklist.containsKey('controllerValues')) {
				Map<String, Object> mapControl = (Map<String, Object>) picklist.get('controllerValues');

				for (String key : mapControl.keySet()) {
					mapControllerValues.put(Integer.valueOf(mapControl.get(key)), key);
					parent.put(key, new List<String>());
				}
			}

			if (picklist.containsKey('values')) {
				List<Object> values = (List<Object>) picklist.get('values');

				if (mapControllerValues.isEmpty()) {
					result.put(namePicklist, getIndependentPicklistValues(values));
				} else {
					result.put(namePicklist, getDependentPicklistValues(values, parent, mapControllerValues));
				}
			}
		}

		return result;
	}

	/**
	 * @description getIndependentPicklistValues gets the values for an independent
	 * picklist from the values given.
	 * @param  values JSON data values to convert
	 * @return        return description
	 */
	@TestVisible
	private static Map<String, List<String>> getIndependentPicklistValues(List<Object> values) {
		Map<String, List<String>> result = new Map<String, List<String>>();

		for (Object obj : values) {
			Map<String, Object> valueData = (Map<String, Object>) obj;
			String value = valueData.get('value').toString();
			result.put(value.unescapeHtml4(), new List<String>());
		}

		return result;
	}

	/**
	 * @description getDependentPicklistValues gets the values for a dependent
	 * picklist from the values given.
	 * @param  values              JSON data values to convert
	 * @param  parent              Parent values to add picklist values to
	 * @param  mapControllerValues Relationship of parent and picklist
	 * @return Parent filled out with picklist values
	 */
	@TestVisible
	private static Map<String, List<String>> getDependentPicklistValues(
		List<Object> values,
		Map<String, List<String>> parent,
		Map<Integer, String> mapControllerValues
	) {
		for (Object obj : values) {
			Map<String, Object> valueData = (Map<String, Object>) obj;
			List<Object> validFor = (List<Object>) valueData.get('validFor');

			if (validFor != null) {
				for (Object vFor : validFor) {
					String cntrlrVal = mapControllerValues.get(Integer.valueOf(vFor));
					List<String> depVals = (List<String>) parent.get(cntrlrVal);
					String value = valueData.get('value').toString();
					depVals.add(value.unescapeHtml4());
					parent.put(cntrlrVal, depVals);
				}
			}
		}

		return parent;
	}
}