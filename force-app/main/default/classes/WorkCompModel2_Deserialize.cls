public with sharing class WorkCompModel2_Deserialize {

    public SafetyIncentiveSummary SAFETYINCENTIVE;
    public XmodHistory XMODHISTORY;

	public static WorkCompModel2_Deserialize parse(String json) {
		return (WorkCompModel2_Deserialize) System.JSON.deserialize(json, WorkCompModel2_Deserialize.class);
	}
}