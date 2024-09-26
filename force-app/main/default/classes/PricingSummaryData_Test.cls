@isTest
private class PricingSummaryData_Test {

    @isTest static void ParseSummaryData() {
        
        String json = '{"PayrollHistoryTable":{"Client":904611,"StartDate":"2017-04-01","Payroll":[{"Year":"2018","State":"MD","MinDate":"2017-09-01","MaxDate":"2017-09-01","LastName":"SMITH, JR","FirstName":"ROBERT","SSN":"***-**-2369","IsOwner":0,"Active":"T","WcDetails":[{"WcCode":"0042","JobCode":"0042","BillAmt":117.51,"PayAmt":100,"PremPayAmt":100,"TaxablePayAmt":100,"ErTaxes":11.55,"WcPremiums":5.86,"HoursWorked":10}]}]},"RiskClaimsSI":{"CLIENT":904611,"STARTDATE":"2017-04-01","DATALIST":[{"Year":"2018","StateCode":"MD","WCBilled":123.06,"PremBasedPayroll":2100,"PeriodStartDate":"2017-04-01","TotalIncurred":0,"UltimateExpected":0,"OpenClaims":0,"TotalClaims":0,"Frequency":0,"MaxSI":0},{"Year":"2017","StateCode":"MD","WCBilled":611.12,"PremBasedPayroll":10428,"PeriodStartDate":"2016-04-01","TotalIncurred":0,"UltimateExpected":0,"OpenClaims":0,"TotalClaims":0,"Frequency":0,"MaxSI":0},{"Year":"2016","StateCode":"MD","WCBilled":646.74,"PremBasedPayroll":11036,"PeriodStartDate":"2015-04-01","TotalIncurred":0,"UltimateExpected":0,"OpenClaims":0,"TotalClaims":0,"Frequency":0,"MaxSI":0}]},"BdmAndCommissions":{"CLIENT":904611,"STARTDATE":"2017-04-01","HasBdm":"FALSE","BdmName":" ","DATALIST":[{"Year":"0","Acronym":" ","Company":" ","MinDate":"1900-01-01 00:00:00.0","MaxDate":"1900-01-01 00:00:00.0","CommRate":0,"CommAmt":0}]},"XmodHistory":{"Client":904611,"XmodDetails":[{"Year":"2016","StateCode":"MD","ModifiedDate":"2015-05-01 00:00:00.0","Xmod":1}]},"WorkCompRates":{"CLIENTID":"904611","DATALIST":[{"STATE":"MD","WCCODE":"0042","WCRATE":5.86}]},"WcAndSI":{"Client":905158,"WcSiList":[{"StateCode":"CA","WcCode":"0042","IsEligible":1,"EligibleRateSI":1.46},{"StateCode":"CA","WcCode":"0106","IsEligible":1,"EligibleRateSI":4},{"StateCode":"CA","WcCode":"1000","IsEligible":0,"EligibleRateSI":0},{"StateCode":"CA","WcCode":"8810","IsEligible":0,"EligibleRateSI":0}]}}';
        PricingSummaryData obj = PricingSummaryData.parse(json);

        System.assert(obj != null);
        System.debug('PayrollHistory: ');
        System.assert(obj.PayrollHistoryTable != null);
        System.debug('BdmAndCommissions: ');
        System.assert(obj.BdmAndCommissions != null);
        System.debug('RiskClaimsSi: ');
        System.assert(obj.RiskClaimsSi != null);
        System.debug('XmodHistory: ');
        System.assert(obj.XmodHistory != null);
        System.debug('WorkCompRates: ');
        System.assert(obj.WorkCompRates != null);
        System.debug('WcAndSI: ');
        System.assert(obj.WcAndSI != null);

    }
    
    

}