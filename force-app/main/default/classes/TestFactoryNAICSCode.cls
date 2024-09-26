@IsTest
public class TestFactoryNAICSCode {
	/**
	 * @description createCode creates a new NAICS_Code__c record in the database.
	 * @param  name   Name of the NAICS_Code__c
	 * @param  title  Title of the NAICS_Code__c
	 * @return NAICS_Code__c
	 */
	public static NAICS_Code__c createCode(String name, String title) {
		NAICS_Code__c testcode = makeCode(name, title);
		insert testcode;
		return testcode;
	}

	/**
	 * @description makeCode makes a new NAICS_Code__c record in the database.
	 * @param  name   Name of the NAICS_Code__c
	 * @param  title  Title of the NAICS_Code__c
	 * @return NAICS_Code__c
	 */
	public static NAICS_Code__c makeCode(String name, String title) {
		return new NAICS_Code__c(Name = name, NAICS_Title__c = title);
	}
}