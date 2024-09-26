/**
 * @description CaseCreationUtility contains methods to aid in the creation
 * of a new Case.
 */
public without sharing class CaseCreationUtility {
	/**
	 * @description getFieldToAPIName retrieves a map relating field labels to field names.
	 * @param  objectName Name of the SObject looking at
	 * @return A map relating field labels to field names.
	 */
	public static Map<String, String> getFieldToAPIName(String objectName) {
		Map<String, String> result = new Map<String, String>();

		SObjectType soType = Schema.getGlobalDescribe().get(objectName);
		Map<String, Schema.SObjectField> mapFields = soType.getDescribe().fields.getMap();

		for (String strField : mapFields.keySet()) {
			SObjectField field = mapFields.get(strField);
			result.put(field.getDescribe().getlabel(), strField);
		}

		return result;
	}

	/**
	 * @description getFieldType converts the field label (displayed name) to its type.
	 * @param  objectName Name of the SObject looking at
	 * @param  fieldLabel Displayed name of the field
	 * @return The internal field type
	 */
	public static Schema.DisplayType getFieldType(String objectName, String fieldLabel) {
		SObjectType soType = Schema.getGlobalDescribe().get(objectName);
		Map<String,Schema.SObjectField> mapFields = soType.getDescribe().fields.getMap();

		for (String strField : mapFields.keySet()) {
			SObjectField field = mapFields.get(strField);

			if (fieldLabel == field.getDescribe().getlabel()) {
				return field.getDescribe().gettype();
			}
		}

		return null;
	}

	/**
	 * @description getFieldAPIName converts the field label (displayed name) to the internal field name.
	 * @param  objectName Name of the SObject looking at
	 * @param  fieldLabel Displayed name of the field
	 * @return The internal field name
	 */
	public static String getFieldAPIName(String objectName, String fieldLabel) {
		SObjectType soType = Schema.getGlobalDescribe().get(objectName);
		Map<String,Schema.SObjectField> mapFields = soType.getDescribe().fields.getMap();

		for (String strField : mapFields.keySet()) {
			SObjectField field = mapFields.get(strField);

			if (fieldLabel == field.getDescribe().getlabel()) {
				return strField;
			}
		}

		return null;
	}
}