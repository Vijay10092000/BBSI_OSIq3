@isTest
public class TestFactoryWorkCompRate {
    
    /**
     *
     */
    public static WorkCompRate__c makeWorkCompRate(String policy, String stateCode, String code, Decimal rate, Map<String,Object> fldMap) {
        WorkCompRate__c rate1 = new WorkCompRate__c(
			Policy__c = policy,
			State__c = stateCode,
			Code__c = code,
			Rate__c = rate
		);
        if (fldMap != null) {
			rate1 = (WorkCompRate__c) TestFactory.assignFields(fldMap, rate1);
		}

		return rate1;
    }


    /**
     *
     */
    public static WorkCompRate__c createWorkCompRate(String policy, String stateCode, String code, Decimal rate, Map<String,Object> fldMap) {
        WorkCompRate__c rate1 = makeWorkCompRate(policy, stateCode, code, rate, fldMap);
        insert rate1;
        return rate1;
    }
}