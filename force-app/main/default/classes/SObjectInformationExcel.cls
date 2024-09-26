/**
 * 
 * TESTING: USE: Execute Anonymous Apex
	System.debug(LoggingLevel.INFO, '\n' + SObjectInformationExcel.createReport('Event') );
*/
public without sharing class SObjectInformationExcel extends ExcelWorkbook {
	private SObjectInformation info;
	private Sheet sheetObject;
	private Sheet sheetFields;

	private String REPORT_TITLE = 'Object Metadata: {0}';
	private String COMPANY = 'BBSI';

	private String SHEET_OBJECT = 'Object';
	private String SHEET_FIELDS = 'Fields';

	/**
	 * @description create builds the report.
	 * @return A String containing the EXCEL report file
	 */
	public static String createReport(String nameObject) {
		return (new SObjectInformationExcel()).create(nameObject);
	}

	private SObjectInformationExcel() {
	}

	private String create(String nameObject) {	
		info = new SObjectInformation(nameObject);

		fillWorkbookProperties();

		makeObjectSheet();
		makeFieldsSheet();

		return build();
	}

	@TestVisible
	private void fillWorkbookProperties() {
		addDocumentProperty('Title', String.format(REPORT_TITLE, new List<String>{ info.nameObject }));
		addDocumentProperty('Author', UserInfo.getUserName());
		addDocumentProperty('Company', COMPANY);
		addDocumentProperty('Created', Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''));
	}

	/**
	 * @description makeObjectSheet addes the SObject sheet to the workbook.
	 */
	@TestVisible
	private void makeObjectSheet() {
		Sheet sheet = addSheet(SHEET_OBJECT);

		sheet.addColumn(1).width = 100;
		sheet.addColumn(2).width = 100;

		Integer row = 1;

		for (String name : SObjectInformation.DEFAULT_OBJECT_DATA_ORDER) {
			++row;

			sheet.addCell(row, 1, TYPE_STRING, name);
			sheet.addCell(row, 2, TYPE_STRING, info.objectData.get(name));
		}
	}

	/**
	 * @description makeObjectSheet addes the SObject sheet to the workbook.
	 */
	private void makeFieldsSheet() {
		Sheet sheet = addSheet(SHEET_FIELDS);

		for (Integer index = 1; index <= SObjectInformation.DEFAULT_FIELD_DATA_ORDER.size(); ++index) {			
			sheet.addColumn(index).width = 50;
		}

		List<String> fields = new List<String>(info.fieldsData.keySet());
		fields.sort();

		Integer row = 1;
		for (String field : fields) {
			++row;

			Map<String, String>  data = info.fieldsData.get(field);

			Integer column = 0;
			for (String value : SObjectInformation.DEFAULT_FIELD_DATA_ORDER) {
				++column;

				sheet.addCell(row, column, TYPE_STRING, data.get(value));
			}
		}
	}
}