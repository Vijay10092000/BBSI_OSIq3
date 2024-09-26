public without sharing class WorkCompRatesER {

	public String CLIENTID;
	public List<DATA> DATALIST;

	public class DATA {
		public String STATE { get; set; }
		public String WCCODE { get; set; }
		public Decimal WCRATE { get; set; }
		public String DESCRIPTION { get; set; }
	}

	public static WorkCompRatesER parse(String json) {
		return (WorkCompRatesER) System.JSON.deserialize(json, WorkCompRatesER.class);
	}
}