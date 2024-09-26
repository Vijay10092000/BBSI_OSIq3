@isTest
public with sharing class PayrollHistoryDataSum_Test {

	@isTest static void parseJson() {
		String json = '{"Client":905158,"StartDate":"2017-09-01","Data":[{"Year":"2016","MinDate":"2015-10-09","MaxDate":"2016-08-31","BillAmt":6829214,"PayAmt":5879996,"PremPayAmt":5726988,"TaxablePayAmt":5879996,"ErTaxes":556080,"WcPremiums":256455,"BillAdj":0,"HoursWorked":301056},{"Year":"2017","MinDate":"2016-09-01","MaxDate":"2017-08-25","BillAmt":8578647,"PayAmt":7366631,"PremPayAmt":7178879,"TaxablePayAmt":7366631,"ErTaxes":651059,"WcPremiums":348612,"BillAdj":-7847,"HoursWorked":365584},{"Year":"2018","MinDate":"2017-09-01","MaxDate":"2018-04-16","BillAmt":6069255,"PayAmt":5210788,"PremPayAmt":5074648,"TaxablePayAmt":5210788,"ErTaxes":485921,"WcPremiums":245266,"BillAdj":0,"HoursWorked":243728}]}';
		PayrollHistoryDataSum obj = PayrollHistoryDataSum.parse(json);
		String reqBody = PayrollHistoryDataSum.GetRequestBody(905158, '2017-09-01');
		System.assert(obj != null);
		System.assert(obj.Client == 905158);
		System.assert(obj.Data.size() > 2);
		System.assert(obj.Data[1].BillAdj < 0);
		System.assert(obj.Data[0].BillAmt > 1000);

	}
}