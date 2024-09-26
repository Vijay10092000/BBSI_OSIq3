public with sharing class WCClaims {
	public String CLIENTID;
	public List<DATA> DataList;
	
	public class DATA {
		public String StartDate;
		public String EndDate;
		public List<CLAIMSDATA> ClaimsDataList{get; Private set;}
	}
    
	//added {get;set;} for UI viewmodel to use this class directly
	//normally i have a wrapper class on it but this table is simple without a wrapper class
	public class CLAIMSDATA {
    public String STATE {get; Private set;}
		public Integer LTCLAIMS{get; Private set;}
		public Double LTINCURRED{get; Private set;}
		public Integer MOCLAIMS{get; Private set;}
		public Double MOINCURRED{get; Private set;}
		public Integer FAIDCLAIMS{get; Private set;}
		public Double FAIDINCURRED{get; Private set;}
		public Integer OPENCLAIMS{get; Private set;}
		public Integer TOTALCLAIMS{get; Private set;}
		public Double TOTALINCURRED{get; Private set;}
	}
	
	public static WCClaims parse(String json) {
		return (WCClaims) System.JSON.deserialize(json, WCClaims.class);
	}
}