@isTest
public class TestFactoryPayroll {

	/**
	 * @description Returns a Payroll record.
	 * @param  a    Account record
	 * @param  payScheduleId Pay Schedule
	 * @param  fldMap  Additional fields to set on Payroll
	 * @return Payroll__c
	 */
    public static Payroll__c makePayroll(Account a, String payScheduleId, Map<String,Object> fldMap) {
        Payroll__c p = new Payroll__c();

        p.Name = payscheduleId;
        p.Account__c = a.ID;

        if (fldMap != null) {
			p = (Payroll__c) TestFactory.assignFields(fldMap, p);
		}
        
        return p;
    }

	/**
	 * @description Returns a Payroll inserted record.
	 * @param  a    Account record
	 * @param  payScheduleId Pay Schedule
	 * @param  fldMap  Additional fields to set on Payroll
	 * @return Payroll__c
	 */
    public static Payroll__c createPayroll(Account a, String payScheduleId, Map<String,Object> fldMap) {
        Payroll__c p = makePayroll(a, payScheduleId, fldMap);
        insert p;
        return p;
    }
}