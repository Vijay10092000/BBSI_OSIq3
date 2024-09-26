@isTest
public class TestFactoryERPayrollTaxMaster {
    /**
    * @description createPayrollmaster creates a ERPayrollTaxMaster record.
    * @param  fldMap  Additional fields to set on Payroll
    * @return ERPayrollTaxMaster
    */    
    public static ER_Payroll_Tax_Master__c createPayrollmaster(Map<String,Object> fldMap) {
        ER_Payroll_Tax_Master__c testpayrollmaster = makePayrollMaster(fldMap);
        insert testpayrollmaster;
        return testpayrollmaster;
    }
    /**
    * @description makePayrollmaster makes a ERPayrollTaxMaster record.
    * @param  fldMap  Additional fields to set on Payroll
    * @return ERPayrollTaxMaster
    */
    public static ER_Payroll_Tax_Master__c makePayrollMaster(Map<String,Object> fldMap) {
        ER_Payroll_Tax_Master__c testpayrollmaster = new ER_Payroll_Tax_Master__c();
        if (fldMap != null) {
            testpayrollmaster = (ER_Payroll_Tax_Master__c) TestFactory.assignFields(fldMap, testpayrollmaster);
        }
        return testpayrollmaster;
    }    
}