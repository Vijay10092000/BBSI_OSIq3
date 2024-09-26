public with sharing class TurnoverSummary {
	public String CLIENTID;
	public List<DATA> DataList;

	public class DATA {
		public String STARTDATE;
		public String ENDDATE;
		public Integer EEANNUAL;
		public Integer EECURRENT;
	}

	public static TurnoverSummary parse(String json) {
		//if(json == null || json == ' '){
		//	json = '{'+
		//'    \"CLIENTID\": \"900021\",'+
		//'    \"DataList\": ['+
		//'      {'+
		//'        \"STARTDATE\": \"2016-05-12\",'+
		//'        \"ENDDATE\": \"2017-05-11\",'+
		//'        \"EEANNUAL\": 12,'+
		//'        \"EECURRENT\": 8'+
		//'      },'+
		//'      {'+
		//'        \"STARTDATE\": \"2015-05-12\",'+
		//'        \"ENDDATE\": \"2016-05-11\",'+
		//'        \"EEANNUAL\": 14,'+
		//'        \"EECURRENT\": 7'+
		//'      }'+
		//'    ]'+
		//'  }';
		//}
		return (TurnoverSummary) System.JSON.deserialize(json, TurnoverSummary.class);
	}
}