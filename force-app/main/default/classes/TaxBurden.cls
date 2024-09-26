public with sharing class TaxBurden {
	public String CLIENTID;
	public List<DATA> DATALIST;

	public class DATA {
		public String STARTDATE;
		public String ENDDATE;
		public Decimal TotalPayroll;
		public Decimal TotalTaxes;
		public Decimal TotalPayrollNo1000;
		public Decimal TotalTaxesNo1000;
	}
	public static TaxBurden parse(String json) {
		return (TaxBurden) System.JSON.deserialize(json, TaxBurden.class);
	}
}