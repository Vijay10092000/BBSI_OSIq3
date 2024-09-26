public with sharing class SafetyIncentiveSummary {
	
	Public String Client {get; private set;}
	Public String RunDate {get; private set;}
	Public List<DATA> DataList {get; Private set;}
	
	public class DATA {
		public String StartDate {get; private set;}
		public String EndDate {get; private set;}
		public Double EligiblePR{get; Private set;}
		public Double MaxSI{get; Private set;}
		public Double Losses{get; Private set;}
		public Double ProfServices{get; Private set;}
		public Double ModWork{get; Private set;}
		public Double SIEarned{get; Private set;}
		public String PaidDate{get; Private set;}
		public Double AmountPaid{get; Private set;}
		public String Status{get; Private set;}
	}
	
	public static SafetyIncentiveSummary parse(String json) {
		return (SafetyIncentiveSummary) System.JSON.deserialize(json, SafetyIncentiveSummary.class);
	}
}