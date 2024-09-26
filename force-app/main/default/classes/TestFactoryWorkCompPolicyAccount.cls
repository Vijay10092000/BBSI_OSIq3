@isTest
public class TestFactoryWorkCompPolicyAccount {

    
    /**
     * Returns a Work Comp Policy Account Required. Paremeters are the Name, Account, Work Comp Policy
     */
    public static WorkCompPolicyAccount__c makeWorkCompPolicyAccount(
    		String name, 
    		Work_Comp_Policy__c wcp, 
    		Account a, 
    		Map<String,Object> fldMap) {

        WorkCompPolicyAccount__c wcpa = new WorkCompPolicyAccount__c();

        wcpa.Client__c = a.ID;
        wcpa.Work_Comp_Policy__c = wcp.ID;
        wcpa.Name = name;

        if (fldMap != null) {
			wcpa = (WorkCompPolicyAccount__c) TestFactory.assignFields(fldMap, wcpa);
		}

        return wcpa;
    }


    /**
     * Returns a created Work Comp Policy Account. Required Paremeters are the Name, Account, Work Comp Policy
     */
    public static WorkCompPolicyAccount__c createWorkCompPolicyAccount(
    		String name, 
    		Work_Comp_Policy__c wcp, 
    		Account a, 
    		Map<String,Object> fldMap) {

    	WorkCompPolicyAccount__c wcpa = makeWorkCompPolicyAccount(name, wcp, a, fldMap);
    	insert wcpa;
    	return wcpa;
    }
}