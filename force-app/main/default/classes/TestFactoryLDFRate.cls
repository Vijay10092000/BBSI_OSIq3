@isTest
public class TestFactoryLDFRate {
    /**
	 * @description createLDFRate creates a new LDF Rate record in the database.
	 * @param  month 		Month__c of the LDF Rate
	 * @param  ca 		LDF_CA__c of the LDF Rate
	 * @param  aos 		LDF_AOS__c of the LDF Rate
	 * @param  fldMap 		additional field values for the LDF Rate
	 * @return LDF_Rate__c
	 */
    public static LDF_Rate__c createLDFRate(Decimal month, Decimal ca, Decimal aos, Map<String, Object> fldMap) {
        LDF_Rate__c testldfrate = makeLDFRate(month,ca,aos, fldMap);
        insert testldfrate;
        return testldfrate;
    }
    /**
	 * @description makeLDFRate makes a new LDF Rate record in the database.
	 * @param  month 		Month__c of the LDF Rate
	 * @param  ca 		LDF_CA__c of the LDF Rate
	 * @param  aos 		LDF_AOS__c of the LDF Rate
	 * @param  fldMap 		additional field values for the LDF Rate
	 * @return LDF_Rate__c
	 */
    public static LDF_Rate__c makeLDFRate(Decimal month, Decimal ca, Decimal aos, Map<String, Object> fldMap) {        
        LDF_Rate__c testldfrate = new LDF_Rate__c( Month__c = month,  LDF_CA__c = ca, LDF_AOS__c = aos);
        if (fldMap != null) {
            testldfrate = (LDF_Rate__c) TestFactory.assignFields(fldMap, testldfrate);
        }
        return testldfrate;
    }    
}