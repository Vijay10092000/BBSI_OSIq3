/**
 * @description TestFactoryRenewal contains methods to create test Renewal.
 */
@IsTest
public without sharing class TestFactoryRenewal {
	/**
	 * @description createRenewal creates a new Renewal record in the database.
	 * @param  recordType       recordType of the Renewal
	 * @param  fldMap 		additional field values for the Renewal
	 * @return Renewal__c
	 */
	public static Renewal__c createRenewal(String Name, Map<String, Object> fldMap) {
		Renewal__c testRenewal = makeRenewal(Name, fldMap);
		insert testRenewal;
		return testRenewal;
	}

	/**
	 * @description makeRenewal makes a new Renewal record in the database.
	 * @param  recordType       recordType of the Renewal
	 * @param  fldMap 		additional field values for the Renewal
	 * @return Renewal__c
	 */
	public static Renewal__c makeRenewal(String Name, Map<String, Object> fldMap) {        
		Renewal__c testRenewal = new Renewal__c(Name=Name);		       
        if (fldMap != null) {
			testRenewal = (Renewal__c) TestFactory.assignFields(fldMap, testRenewal);
		}
		return testRenewal;
	}
}