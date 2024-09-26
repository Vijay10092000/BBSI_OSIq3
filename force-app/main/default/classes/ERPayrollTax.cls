public with sharing class ERPayrollTax {
	
	private List<ER_Payroll_Tax_Master__c> taxTableMaster;
	private List<ERPayrollTaxItem> erTaxTable;
	public List<ERPayrollTaxItem> TaxTable {
		get {
			return erTaxTable;
		}
	}

	public ERPayrollTax() {
		erTaxTable = new List<ERPayrollTaxItem>();
	}
	public ERPayrollTax(Integer clientId, List<string> stateCodes) {
		erTaxTable = new List<ERPayrollTaxItem>();
		ERPayrollTaxItem erTaxItem;

		For(ER_Payroll_Tax_Master__c taxItem: [SELECT Limit__c, Rate__c, State_Code__c, Tax_Type__c
											   FROM ER_Payroll_Tax_Master__c
											   WHERE State_Code__c = 'FED' OR State_Code__c in :stateCodes]){
			erTaxItem = new ERPayrollTaxItem();
			erTaxItem.PrLimit = taxItem.Limit__c;
			erTaxItem.Rate = taxItem.Rate__c;
			erTaxItem.StateCode = taxItem.State_Code__c;
			erTaxItem.TaxType = taxItem.Tax_Type__c;

			erTaxTable.add(erTaxItem);
		}
	}

	public class ERPayrollTaxItem {
		public Decimal PrLimit {get; set;}
		public Decimal Rate {get; set;}
		public String StateCode {get; set;}
		public String TaxType {get; set;}		
	}
}