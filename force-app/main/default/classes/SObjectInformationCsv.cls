/**
 * 
 * TESTING: USE: Execute Anonymous Apex
	System.debug(LoggingLevel.INFO, '\n' + SObjectInformationCsv.createReport('Event') );
*/
public without sharing class SObjectInformationCsv {
	private SObjectInformation info;

	/**
	 * @description create builds the report.
	 * @return A String containing the EXCEL report file
	 */
	public static String createReport(String nameObject) {
		return (new SObjectInformationCsv()).create(nameObject);
	}

	private SObjectInformationCsv() {
	}
	
	private  String create(String nameObject) {
		info = new SObjectInformation(nameObject);

		String result = SObjectInformation.EMPTY_STRING;

		result += writeObjectData();
		result += '\n\n';
		result += writeFieldsData();

		return result;
	}

	private String writeObjectData() {
		String result = 'OBJECT INFORMATION';

		for (String name : SObjectInformation.DEFAULT_OBJECT_DATA_ORDER) {		
			result += '\n' + name + ',' + info.objectData.get(name);
		}

		return result;
	}

	private String writeFieldsData() {
		String result = 'FIELD INFORMATION';

		result += '\n'+ String.join(SObjectInformation.DEFAULT_FIELD_DATA_ORDER, ',');

		for (String name : SObjectInformation.DEFAULT_FIELD_DATA_ORDER) {			
			Map<String, String> fieldData = info.FieldsData.get(name);

			for (String key : SObjectInformation.FIELDS_TO_DOUBLE_QUOTE) {
				if (SObjectInformation.FIELDS_TO_DOUBLE_QUOTE.contains(key)) {
					result += ',' + csvDoubleQuote(fieldData.get(key));
				} else {	
					result += ',' + fieldData.get(key);
				}
			}
		}

		return result;
	}

	private static String csvDoubleQuote(String text) {
		if (text == null) {
			return SObjectInformation.EMPTY_STRING;
		}

		return '"' + text.replace('"', '""') + '"';
	}
}