public with sharing class DirectExpensesSummary {

	public String CLIENTID;
	public List<DirectExpense> DirectExpenses;

	public class DirectExpense {
		public String STARTDATE;
		public String ENDDATE;
		public Double COMMISSIONAMT;
		public Double PERCENTOFWCBYPAYROLL;
		public Double PERCENTOFPAYROLL;
		public Double PERCENTOFWC;
		public Double CESPRPER;
		public Double MARGINPERCENT;
		public String BEFOREORAFTERSI;
		public String COMMENTS;
	}

	public static DirectExpensesSummary parse(String json) {
		return (DirectExpensesSummary) System.JSON.deserialize(json, DirectExpensesSummary.class);
	}
}