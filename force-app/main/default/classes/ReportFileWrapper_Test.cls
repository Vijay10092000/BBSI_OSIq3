/**
 * @description ReportFileWrapper_Test contains methods to test the ReportFileWrapper class.
*/
@IsTest
public with sharing class ReportFileWrapper_Test {
    /**
	 * @description test_method
	 */
	@IsTest
	static void test_constructor() {
		ReportFileWrapper wrapper = new ReportFileWrapper('filename', 'text', 'type');

		System.assertEquals('filename', wrapper.filename);
		System.assertEquals('text', wrapper.text);
		System.assertEquals('type', wrapper.type);
	}
}