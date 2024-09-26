@isTest
private class ERPayrollTax_Test {	
	@isTest static void basicObject() {	
		List<ER_Payroll_Tax_Master__c> taxTableMaster = new List<ER_Payroll_Tax_Master__c>();		
        ER_Payroll_Tax_Master__c taxItem1 = TestFactoryERPayrollTaxMaster.makePayrollmaster(new Map<String, Object>{
			'State_Code__c' => 'FED',
			'Tax_Type__c'   => 'FICA',
			'Rate__c'       => 6.2,
			'Limit__c'      => 127200
        });
        taxTableMaster.add(taxItem1);
         ER_Payroll_Tax_Master__c taxItem2 = TestFactoryERPayrollTaxMaster.makePayrollmaster(new Map<String, Object>{
			'State_Code__c' => 'FED',
			'Tax_Type__c'   => 'MEDI',
			'Rate__c'       => 1.45,
			'Limit__c'      => 0
        });
		taxTableMaster.add(taxItem2);
		ER_Payroll_Tax_Master__c taxItem3 = TestFactoryERPayrollTaxMaster.makePayrollmaster(new Map<String, Object>{
			'State_Code__c' => 'FED',
			'Tax_Type__c'   => 'FUTA',
			'Rate__c'       => 2.1,
			'Limit__c'      => 7000
        });
		taxTableMaster.add(taxItem3);
		Database.insert(taxTableMaster, false);
		List<string> stateCodes = new List<string>{'OR', 'WA', 'ID'};
		ERPayrollTax obj = new ERPayrollTax();
		obj = new ERPayrollTax(900001, stateCodes);
		Assert.isTrue(obj.TaxTable != null);
	}
}