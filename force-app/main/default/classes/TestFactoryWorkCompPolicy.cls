@isTest
public class TestFactoryWorkCompPolicy {
    
    /**
     * Returns a Work Comp Policy Required Paremeters are the Name, TermDate, EffectiveDate
     */
    public static Work_Comp_Policy__c makeWorkCompPolicy(String name, Date termDate, Date effectiveDate, Map<String,Object> fldMap) {
        Work_Comp_Policy__c wcp = new Work_Comp_Policy__c();

        wcp.Name = name;
        wcp.Term_Date__c = termDate;
        wcp.Effective_Date__c = effectiveDate;
        wcp.External_ID__c = name;

        if (fldMap != null) {
			wcp = (Work_Comp_Policy__c) TestFactory.assignFields(fldMap, wcp);
		}

        return wcp;
    }


    /**
     * Returns an inserted Work Comp Policy Required Paremeters are the Name, TermDate, EffectiveDate
     */
    public static Work_Comp_Policy__c createWorkCompPolicy(String name, Date termDate, Date effectiveDate, Map<String,Object> fldMap) {
    	Work_Comp_Policy__c wcp = makeWorkCompPolicy(name, termDate, effectiveDate, fldMap);
    	insert wcp;
    	return wcp;
    }
}