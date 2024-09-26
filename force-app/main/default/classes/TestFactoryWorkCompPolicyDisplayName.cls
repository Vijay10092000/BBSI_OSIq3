@isTest
public class TestFactoryWorkCompPolicyDisplayName {
    
    /**
     * Returns an instance of Work Comp Policy Display name
     */
    public static WorkCompPolicyDisplayName__c makeWorkCompPolicyDisplayName(String displayName, String hrpWorkCompPolicy, Boolean isInclude, Map<String,Object> fldMap) {
        
        WorkCompPolicyDisplayName__c newPolicy = new WorkCompPolicyDisplayName__c();
        newPolicy.Include__c = isInclude;
        newPolicy.HRP_Work_Comp_Policy__c = hrpWorkCompPolicy;
        newPolicy.Display_Name__c = displayName;

        if (fldMap != null) {
			newPolicy = (WorkCompPolicyDisplayName__c) TestFactory.assignFields(fldMap, newPolicy);
		}

		return newPolicy;
    }


    /**
     * Returns an inserted record of Work Comp Policy Display name
     */
    public static WorkCompPolicyDisplayName__c createWorkCompPolicyDisplayName(String displayName, String hrpWorkCompPolicy, Boolean isInclude, Map<String,Object> fldMap) {
    	WorkCompPolicyDisplayName__c policy = makeWorkCompPolicyDisplayName(displayName, hrpWorkCompPolicy, isInclude, fldMap);
    	insert policy;
    	return policy;
    }
}