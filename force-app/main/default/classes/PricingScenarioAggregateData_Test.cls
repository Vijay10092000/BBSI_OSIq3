@isTest
private class PricingScenarioAggregateData_Test {
	
	@isTest static void test_method_one() {

		String json =  '{"MARGINDATA":{"CLIENTID":"905384","DATALIST":[{"StartDate":"2017-01-01 00:00:00.0","EndDate":"2017-12-31 00:00:00.0","MARGINSUMDATALIST":[{"STATE":"OR","WCCODE":"1000","MARGIN":532.31,"BILLAMT":100407.63,"WCPREM":0},{"STATE":"OR","WCCODE":"4130","MARGIN":3908.28,"BILLAMT":201085.24,"WCPREM":4792.97},{"STATE":"OR","WCCODE":"5102","MARGIN":2930.96,"BILLAMT":127271.84,"WCPREM":3677.53},{"STATE":"OR","WCCODE":"5462","MARGIN":10663.56,"BILLAMT":443813.42,"WCPREM":22483.59},{"STATE":"OR","WCCODE":"8380","MARGIN":4235.76,"BILLAMT":214457.19,"WCPREM":4699.34},{"STATE":"OR","WCCODE":"8742","MARGIN":406.13,"BILLAMT":32319.67,"WCPREM":62.25},{"STATE":"OR","WCCODE":"8810","MARGIN":813.28,"BILLAMT":56129.47,"WCPREM":68.49}]}]},"TAXBURDEN":{"CLIENTID":"905384","DATALIST":[{"STARTDATE":"2017-01-01 00:00:00.0","ENDDATE":"2017-12-31 00:00:00.0","TotalPayroll":1009806.36,"TotalTaxes":106707.15,"TotalPayrollNo1000":919185.76,"TotalTaxesNo1000":97452.43}]},"SISUMMARY":{"CLIENT":"905384","RUNDATE":"2017-07-31 00:00:00.0","DATALIST":[{"StartDate":"2017-01-01 00:00:00.0","EndDate":"2017-12-31 00:00:00.0","EligiblePR":325995.8,"MaxSI":4684.76,"Losses":4845.01,"ProfServices":555,"ModWork":0,"SIEarned":-715.25,"AmountPaid":0,"Status":"InYear"}]},"COMMRATEDETAIL":{"CLIENTID":907115,"DATALIST":[{"Acronym":"9252","Company":"T/A Allen Insurance Group (DBA of Allen Ins Assoc)","TypeBegin":"2017-02-17 00:00:00.0","TypeEnd":"2017-11-30 00:00:00.0","CommissionType":"PERCHK","CommissionRate":2,"CommissionAmt":326,"Blended":1,"CommBasis":0,"ChksInPeriod":163,"WksInPeriod":41}]},"BDM":{"CLIENT":"905384","HASBDM":"FALSE","BDMNAME":" "}}';
		String json2 = '{"MARGINDATA":{"CLIENTID":"904171","DATALIST":[{"StartDate":"2017-01-01 00:00:00.0","EndDate":"2017-12-31 00:00:00.0","MARGINSUMDATALIST":[{"STATE":"CA","WCCODE":"1000","MARGIN":-556.14,"BILLAMT":290865.37,"WCPREM":0},{"STATE":"CA","WCCODE":"6504","MARGIN":26328.22,"BILLAMT":845009.4,"WCPREM":119679.12},{"STATE":"CA","WCCODE":"8742","MARGIN":1231.94,"BILLAMT":115261.32,"WCPREM":1436.91},{"STATE":"CA","WCCODE":"8810","MARGIN":13496.8,"BILLAMT":346576.8,"WCPREM":3648.36}]}]},"TAXBURDEN":{"CLIENTID":"904171","DATALIST":[{"STARTDATE":"2017-01-01 00:00:00.0","ENDDATE":"2017-12-31 00:00:00.0","TotalPayroll":1314942.73,"TotalTaxes":117504.95,"TotalPayrollNo1000":1040225.64,"TotalTaxesNo1000":100800.53}]},"SISUMMARY":{"CLIENT":"904171","RUNDATE":"2017-07-31 00:00:00.0","DATALIST":[{"StartDate":"2017-01-01 00:00:00.0","EndDate":"2017-12-31 00:00:00.0","EligiblePR":0,"MaxSI":0,"Losses":0,"ProfServices":0,"ModWork":0,"SIEarned":0,"AmountPaid":0,"Status":" "}]},"COMMRATEDETAIL":{"CLIENTID":"904171","DATALIST":[{"Acronym":"9012","Company":"ALL SPECTRUM INSURANCE BROKERS INC.","TypeBegin":"2017-01-01 00:00:00.0","TypeEnd":"2017-11-30 00:00:00.0","CommissionType":"PRBOWC","CommissionRate":0.1,"CommissionAmt":12115.22,"Blended":0.976,"CommBasis":977586.85,"ChksInPeriod":0,"WksInPeriod":47}]},"BDM":{"CLIENT":"904171","HASBDM":"TRUE","BDMNAME":"Michael Burkitt"}}';

		//PricingScenarioAggregateData obj = PricingScenarioAggregateData.parse(json);

		//System.assert(obj != null);

		//System.assert(obj.MARGINDATA != null);
		//System.assert(obj.MARGINDATA.CLIENTID == '905384');
		//System.assert(obj.MARGINDATA.DataList.size() == 1);
		//System.assert(obj.MARGINDATA.DataList[0].MarginSumDataList.size() == 7);
		//System.assert(obj.MARGINDATA.DataList[0].MarginSumDataList[0].STATE == 'OR');
		//System.assert(obj.MARGINDATA.DataList[0].MarginSumDataList[0].WCCODE == '1000');
		//System.assert(obj.MARGINDATA.DataList[0].MarginSumDataList[0].MARGIN == 532.31);
		//System.assert(obj.MARGINDATA.DataList[0].MarginSumDataList[0].BILLAMT == 100407.63);


		//System.assert(obj.TAXBURDEN != null);
		//System.assert(obj.TAXBURDEN.DataList.size() == 1);
		//System.assert(obj.TAXBURDEN.DataList[0].STARTDATE == '2017-01-01 00:00:00.0');
		//System.assert(obj.TAXBURDEN.DataList[0].TotalPayroll == 1009806.36);
		//System.assert(obj.TAXBURDEN.DataList[0].TotalTaxes == 106707.15);
		//System.assert(obj.TAXBURDEN.DataList[0].TotalPayrollNo1000 == 919185.76);
		//System.assert(obj.TAXBURDEN.DataList[0].TotalTaxesNo1000 == 97452.43);


		//System.assert(obj.SISUMMARY != null);
		//System.assert(obj.COMMRATEDETAIL != null);
		//System.assert(obj.BDM != null);
		PricingScenarioAggregateData obj = PricingScenarioAggregateData.parse(json2);

		System.assert(obj != null);

		System.assert(obj.MARGINDATA != null);
		System.assert(obj.MARGINDATA.CLIENTID == '904171');
		System.assert(obj.MARGINDATA.DataList.size() == 1);
		System.assert(obj.MARGINDATA.DataList[0].MarginSumDataList.size() == 4);
		System.assert(obj.MARGINDATA.DataList[0].MarginSumDataList[0].STATE == 'CA');
		System.assert(obj.MARGINDATA.DataList[0].MarginSumDataList[0].WCCODE == '1000');
		System.assert(obj.MARGINDATA.DataList[0].MarginSumDataList[0].MARGIN == -556.14);
		System.assert(obj.MARGINDATA.DataList[0].MarginSumDataList[0].BILLAMT == 290865.37);


		System.assert(obj.TAXBURDEN != null);
		System.assert(obj.TAXBURDEN.CLIENTID == '904171');
		System.assert(obj.TAXBURDEN.DataList.size() == 1);
		System.assert(obj.TAXBURDEN.DataList[0].STARTDATE == '2017-01-01 00:00:00.0');
		System.assert(obj.TAXBURDEN.DataList[0].TotalPayroll == 1314942.73);
		System.assert(obj.TAXBURDEN.DataList[0].TotalTaxes == 117504.95);
		System.assert(obj.TAXBURDEN.DataList[0].TotalPayrollNo1000 == 1040225.64);
		System.assert(obj.TAXBURDEN.DataList[0].TotalTaxesNo1000 == 100800.53);


		System.assert(obj.SISUMMARY != null);
		System.assert(obj.SISUMMARY.CLIENT == '904171');
		System.assert(obj.SISUMMARY.RUNDATE == '2017-07-31 00:00:00.0');
		System.assert(obj.SISUMMARY.DataList.size() == 1);
		System.assert(obj.SISUMMARY.DataList[0].StartDate == '2017-01-01 00:00:00.0');
		System.assert(obj.SISUMMARY.DataList[0].EligiblePR == 0);
		System.assert(obj.SISUMMARY.DataList[0].MaxSI == 0);
		System.assert(obj.SISUMMARY.DataList[0].Losses == 0);
		System.assert(obj.SISUMMARY.DataList[0].ProfServices == 0);
		System.assert(obj.SISUMMARY.DataList[0].ModWork == 0);
		System.assert(obj.SISUMMARY.DataList[0].SIEarned == 0);
		System.assert(obj.SISUMMARY.DataList[0].AmountPaid == 0);
		System.assert(obj.SISUMMARY.DataList[0].Status == ' ');
		

		System.assert(obj.COMMRATEDETAIL != null);
		System.assert(obj.COMMRATEDETAIL.CLIENTID == '904171'); 
        System.assert(obj.COMMRATEDETAIL.DATALIST.size() == 1);
        System.assert(obj.COMMRATEDETAIL.DATALIST[0].Acronym == '9012');
        System.assert(obj.COMMRATEDETAIL.DATALIST[0].Company == 'ALL SPECTRUM INSURANCE BROKERS INC.');
        System.assert(obj.COMMRATEDETAIL.DATALIST[0].TypeBegin == '2017-01-01 00:00:00.0');
        System.assert(obj.COMMRATEDETAIL.DATALIST[0].TypeEnd == '2017-11-30 00:00:00.0');
        System.assert(obj.COMMRATEDETAIL.DATALIST[0].CommissionType == 'PRBOWC');
        System.assert(obj.COMMRATEDETAIL.DATALIST[0].CommissionRate == 0.1);
        System.assert(obj.COMMRATEDETAIL.DATALIST[0].CommissionAmt == 12115.22);
        System.assert(obj.COMMRATEDETAIL.DATALIST[0].Blended == 0.976);
        System.assert(obj.COMMRATEDETAIL.DATALIST[0].CommBasis == 977586.85);
        System.assert(obj.COMMRATEDETAIL.DATALIST[0].ChksInPeriod == 0);
        System.assert(obj.COMMRATEDETAIL.DATALIST[0].WksInPeriod == 47);

		System.assert(obj.BDM != null);
		System.assert(obj.BDM.CLIENT == '904171');
		System.assert(obj.BDM.HASBDM == 'TRUE');
		System.assert(obj.BDM.BDMNAME == 'Michael Burkitt');


	}
	
}