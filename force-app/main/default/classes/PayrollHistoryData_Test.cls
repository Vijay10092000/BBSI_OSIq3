@isTest
public with sharing class PayrollHistoryData_Test {

	static testMethod void parseJson() {
		String json = '{"Client":905158,"StartDate":"2017-09-01","Payroll":[{"Year":"2018","MinDate":"2017-09-08","MaxDate":"2018-02-09","LastName":"ABURTO AREVALO","FirstName":"JOSE","SSN":"***-**-6868","IsOwner":0,"Active":"A","WcDetails":[{"State":"CA","WcCode":"0042","JobCode":"0042","BillAmt":19316.3,"PayAmt":16375.25,"PremPayAmt":38496.5,"TaxablePayAmt":16375.25,"ErTaxes":1420.5,"WcPremiums":973.23,"HoursWorked":904.5}]},{"Year":"2018","MinDate":"2017-09-08","MaxDate":"2017-09-25","LastName":"AGUILAR","FirstName":"LUIS","SSN":"***-**-6318","IsOwner":0,"Active":"I","WcDetails":[{"State":"CA","WcCode":"0042","JobCode":"0042","BillAmt":2085.53,"PayAmt":1768,"PremPayAmt":2704,"TaxablePayAmt":1768,"ErTaxes":135.24,"WcPremiums":105.07,"HoursWorked":128}]},{"Year":"2018","MinDate":"2017-10-20","MaxDate":"2017-10-23","LastName":"AGUILAR","FirstName":"RAFAEL","SSN":"***-**-0266","IsOwner":0,"Active":"A","WcDetails":[{"State":"CA","WcCode":"0042","JobCode":"0042","BillAmt":1557.08,"PayAmt":1320,"PremPayAmt":1320,"TaxablePayAmt":1320,"ErTaxes":178.86,"WcPremiums":78.44,"HoursWorked":80}]}]}';

		PayrollHistoryData obj = PayrollHistoryData.parse(json);
		System.assert(obj != null);
		System.assert(obj.Client == 905158);
		System.assert(obj.StartDate == '2017-09-01');
		System.assert(obj.Payroll != null);
		System.assert(obj.Payroll.size() > 1);
		System.assert(obj.Payroll[0].LastName == 'ABURTO AREVALO');
		System.assert(obj.Payroll[0].SSN == '***-**-6868');
		System.assert(obj.Payroll[0].WcDetails != null);
		System.assert(obj.Payroll[0].WcDetails.size() == 1);
        System.assert(obj.Payroll[0].WcDetails[0].State == 'CA');
        System.assert(obj.Payroll[0].WcDetails[0].WcCode == '0042');
        System.assert(obj.Payroll[0].WcDetails[0].JobCode == '0042');

		System.assert(obj.Payroll[0].TotalBillAmt > 0);
		System.assert(obj.Payroll[0].TotalPayAmt > 0);
		System.assert(obj.Payroll[0].TotalPremPayAmt > 0);
		System.assert(obj.Payroll[0].TotalTaxablePayAmt > 0);
		System.assert(obj.Payroll[0].TotalWcPremiums > 0);
		System.assert(obj.Payroll[0].TotalErTaxes > 0);

		System.debug('obj.Payroll[0].TotalBillAmt ' +obj.Payroll[0].TotalBillAmt);
		System.debug('obj.Payroll[0].TotalPayAmt ' + obj.Payroll[0].TotalPayAmt);
		System.debug('obj.Payroll[0].TotalPremPayAmt ' + obj.Payroll[0].TotalPremPayAmt);
		System.debug('obj.Payroll[0].TotalTaxablePayAmt ' + obj.Payroll[0].TotalTaxablePayAmt);
		System.debug('obj.Payroll[0].TotalWcPremiums ' + obj.Payroll[0].TotalWcPremiums);
		System.debug('obj.Payroll[0].TotalErTaxes ' + obj.Payroll[0].TotalWcPremiums);

	}

}