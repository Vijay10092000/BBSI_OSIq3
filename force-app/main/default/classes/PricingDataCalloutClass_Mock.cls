@isTest
public class PricingDataCalloutClass_Mock implements HttpCalloutMock {

    protected Integer code;
    protected String status;
    protected String body;
    protected Map<String, String> responseHeaders;

    public PricingDataCalloutClass_Mock()
    {
        this.code = 200;
        this.status = 'OK';
        this.body = '';
        this.responseHeaders = new Map<String, String>();
    }
    
    public PricingDataCalloutClass_Mock(string renewalYrPayResponse, String xmodResponse, string riskanalysisResponse)
    {
        this.responseHeaders = new Map<String, String>();
        if (renewalYrPayResponse == 'ERROR')
        {
            this.code = 400;
            this.status = 'ERROR';    
        }
        else
        {    
             this.code = 200;
             this.status = 'OK';
        }
    }

    public HTTPResponse respond(HTTPRequest req)
    {
        if(req.getEndpoint().contains(payWcEstimateUrl)){
            this.body = payWcEstimateData;
        }

        if(req.getEndpoint().contains(workCompRatesUrl)){
            this.body = workCompRatesData;
        }
        
        if(req.getEndpoint().contains(xmodUrl)){
            this.body = xmodData;
        }

        if(req.getEndpoint().contains(sutaRatesUrl)){
            this.body = sutaRatesData;
        }

        if(req.getEndpoint().contains(xmodsUrl)){
            this.body = xmodsData;
        }

        if(req.getEndpoint().contains(pricingDataModelUrl)){
            this.body = pricingDataModelData;
        }

        if(req.getEndpoint().contains(pricingScenarioDataUrl)){
            this.body = pricingScenarioData;
        }

        if(req.getEndpoint().contains(pricingSummaryDataUrl)){
        //    this.body = String.format(pricingSummaryData, new List<String>{ year.format(), yearM1.format(), yearM2.format() });

            this.body = getPricingSummaryData();
        }

        HttpResponse res = new HttpResponse();
        this.responseHeaders.put('Content-Type', 'application/json');
        for (String key : this.responseHeaders.keySet()) {
            res.setHeader(key, this.responseHeaders.get(key));
        }
        res.setBody(this.body);
        res.setStatusCode(this.code);
        res.setStatus(this.status);
        return res;
    }
    
    // Url strings
    private String pricingSummaryDataUrl = '/getPricingSummaryData';
    private String pricingScenarioDataUrl = '/getPricingScenarioModel';
    private String pricingDataModelUrl = '/getPricingDataModel';
    private String payWcEstimateUrl = '/getPayWcEstimates';
    private String workCompRatesUrl = '/getWorkCompRates';
    private String sutaRatesUrl = '/getSutaRates';
    private String xmodUrl = '/getXmodHistory';
    private String xmodsUrl = '/getExmodReport';

    // test data
    private String xmodsData = '{"ExMods":[{"xmod":1.65,"StateCode":"CA","year":2019,"calc_date":"2019-03-08","exmod":165,"exmod_status":"(N) New Entry"},{"xmod":1.19,"StateCode":"CA","year":2018,"calc_date":"2018-01-18","exmod":119,"exmod_status":"(R) Revised Entry"},{"xmod":0.78,"StateCode":"CA","year":2017,"calc_date":"2017-03-17","exmod":78,"exmod_status":""},{"xmod":1.83,"StateCode":"CA","year":2016,"calc_date":"2016-04-30","exmod":183,"exmod_status":"(R) Revised Entry"}],"BureauReportUrl":"https://exmod.com/Employer?EmployerFilter=3358737"}';

    private String pricingScenarioData = '{"MARGINDATA":{"CLIENTID":"904611","DATALIST":[{"StartDate":"2018-04-01 00:00:00.0","EndDate":"2019-03-31 00:00:00.0","MARGINSUMDATALIST":[{"STATE":"MD","WCCODE":"0042","MARGIN":2.1,"BILLAMT":2467.71,"WCPREM":123.06}]}]},"TAXBURDEN":{"CLIENTID":"904611","DATALIST":[{"STARTDATE":"2018-04-01 00:00:00.0","ENDDATE":"2019-03-31 00:00:00.0","TotalPayroll":2100,"TotalTaxes":242.55,"TotalPayrollNo1000":2100,"TotalTaxesNo1000":242.55}]},"SISUMMARY":{"CLIENT":"904611","RUNDATE":"2019-01-31 00:00:00.0","DATALIST":[{"StartDate":"2018-04-01 00:00:00.0","EndDate":"2019-03-31 00:00:00.0","EligiblePR":0,"MaxSI":0,"Losses":0,"ProfServices":0,"ModWork":0,"SIEarned":0,"AmountPaid":0,"Status":" "}]},"COMMRATEDETAIL":{"CLIENTID":"904611","DATALIST":[{"Acronym":" ","Company":" ","TypeBegin":"1900-01-01 00:00:00.0","TypeEnd":"1900-01-01 00:00:00.0","CommissionType":" ","CommissionRate":0,"CommissionAmt":500.42,"Blended":0,"CommBasis":0,"ChksInPeriod":0,"WksInPeriod":0}]},"BDM":{"CLIENT":"904611","HASBDM":"FALSE","BDMNAME":" "}}';
    private String pricingDataModelData = '{"PAYWCESTIMATES":{"CLIENT":"904611","DATALIST":[{"LastName":"SMITH,","FirstName":"ROBERT","Active":" ","IsOwner":0,"State":"MD","WCcodes":[{"WCcode":"0042","PayAmt":2100,"PremPayAmt":2100,"HoursWorked":208,"IsEligibleSI":0,"EligibleRateSI":0}]}]},"XMOD":{"CLIENTID":"904611","DATALIST":[{"STARTDATE":"2018-04-01 00:00:00.0","ENDDATE":"2019-03-31 00:00:00.0","XMODLIST":[{"STATE":"MD","XMOD":1}]}]},"SUTARATES":{"CLIENTID":"904611","DATALIST":[{"State":"AZ","SUTA":3.9,"ETT":-1,"EAF":-1,"Local":-1},{"State":"DC","SUTA":2.3,"ETT":-1,"EAF":-1,"Local":-1},{"State":"GA","SUTA":2.26,"ETT":-1,"EAF":-1,"Local":-1},{"State":"KS","SUTA":5.4,"ETT":-1,"EAF":-1,"Local":-1},{"State":"MD","SUTA":3.3,"ETT":-1,"EAF":-1,"Local":-1},{"State":"MO","SUTA":0.186,"ETT":-1,"EAF":-1,"Local":-1},{"State":"NC","SUTA":0.68,"ETT":-1,"EAF":-1,"Local":-1},{"State":"NE","SUTA":0.91,"ETT":-1,"EAF":-1,"Local":-1},{"State":"NJ","SUTA":6.5475,"ETT":0.1175,"EAF":-1,"Local":-1},{"State":"SC","SUTA":0.06,"ETT":-1,"EAF":-1,"Local":-1},{"State":"TX","SUTA":2.06,"ETT":-1,"EAF":-1,"Local":-1},{"State":"UT","SUTA":0.3,"ETT":-1,"EAF":-1,"Local":-1}]},"WCRATES":{"CLIENTID":"904611","DATALIST":[{"STATE":"MD","WCCODE":"0042","WCRATE":5.86}]}}';

    private String payWcEstimateData = '{"CLIENT":"900028","DATALIST":[{"LastName":"BALESTRERI","FirstName":"DANA","Active":"A","IsOwner":0,"State":"CA","WCcodes":[{"WCcode":"8810","PayAmt":97625,"PremPayAmt":97625,"HoursWorked":1808,"IsEligibleSI":0,"EligibleRateSI":0}]},{"LastName":"BOLANOS","FirstName":"MAYRA","Active":"A","IsOwner":0,"State":"CA","WCcodes":[{"WCcode":"8810","PayAmt":6610,"PremPayAmt":6610,"HoursWorked":217,"IsEligibleSI":0,"EligibleRateSI":0}]},{"LastName":"CLARK","FirstName":"JEFFREY","Active":"A","IsOwner":0,"State":"CA","WCcodes":[{"WCcode":"8742","PayAmt":73985,"PremPayAmt":73670,"HoursWorked":1764.75,"IsEligibleSI":0,"EligibleRateSI":0}]},{"LastName":"CONTRERAS","FirstName":"ULISSES","Active":"A","IsOwner":0,"State":"CA","WCcodes":[{"WCcode":"8227","PayAmt":27889.74,"PremPayAmt":27617.71,"HoursWorked":1614.25,"IsEligibleSI":1,"EligibleRateSI":2.31}]},{"LastName":"MATA HERNANDEZ","FirstName":"SALVADOR","Active":"A","IsOwner":0,"State":"CA","WCcodes":[{"WCcode":"1803","PayAmt":61147.25,"PremPayAmt":58083.5,"HoursWorked":1976.75,"IsEligibleSI":1,"EligibleRateSI":3.02}]},{"LastName":"PARADA","FirstName":"JOSE","Active":"A","IsOwner":0,"State":"CA","WCcodes":[{"WCcode":"5028","PayAmt":53086,"PremPayAmt":51765.5,"HoursWorked":1792.5,"IsEligibleSI":1,"EligibleRateSI":2.3}]},{"LastName":"PETINARAKIS","FirstName":"NIKOS","Active":"A","IsOwner":0,"State":"CA","WCcodes":[{"WCcode":"5028","PayAmt":58309.09,"PremPayAmt":57372.71,"HoursWorked":1634.75,"IsEligibleSI":1,"EligibleRateSI":2.3}]},{"LastName":"RAMIREZ","FirstName":"JOSE","Active":"A","IsOwner":0,"State":"CA","WCcodes":[{"WCcode":"5027","PayAmt":33677.5,"PremPayAmt":32890,"HoursWorked":1590.25,"IsEligibleSI":1,"EligibleRateSI":4},{"WCcode":"5028","PayAmt":600,"PremPayAmt":560,"HoursWorked":28,"IsEligibleSI":1,"EligibleRateSI":2.3}]},{"LastName":"REYNOSO","FirstName":"ROBERTO","Active":"A","IsOwner":0,"State":"CA","WCcodes":[{"WCcode":"5028","PayAmt":60273.75,"PremPayAmt":58719.75,"HoursWorked":1715.75,"IsEligibleSI":1,"EligibleRateSI":2.3}]},{"LastName":"ROBINSON","FirstName":"JOY","Active":"A","IsOwner":0,"State":"CA","WCcodes":[{"WCcode":"8742","PayAmt":23303.13,"PremPayAmt":23290,"HoursWorked":637.25,"IsEligibleSI":0,"EligibleRateSI":0}]},{"LastName":"SANTOYO","FirstName":"JUAN","Active":"A","IsOwner":0,"State":"CA","WCcodes":[{"WCcode":"5028","PayAmt":75956.12,"PremPayAmt":75348.8,"HoursWorked":1819.5,"IsEligibleSI":1,"EligibleRateSI":2.3}]},{"LastName":"SCHUPP","FirstName":"STEPHEN","Active":"A","IsOwner":0,"State":"CA","WCcodes":[{"WCcode":"1803","PayAmt":41233.81,"PremPayAmt":40783.8,"HoursWorked":1553.5,"IsEligibleSI":1,"EligibleRateSI":3.02}]},{"LastName":"SHIRLEY","FirstName":"ALEXANDER","Active":"A","IsOwner":0,"State":"CA","WCcodes":[{"WCcode":"5027","PayAmt":13186,"PremPayAmt":13001.5,"HoursWorked":692.75,"IsEligibleSI":1,"EligibleRateSI":4}]},{"LastName":"TORRES ESCOBAR","FirstName":"FRANCISCO","Active":"A","IsOwner":0,"State":"CA","WCcodes":[{"WCcode":"5027","PayAmt":28890,"PremPayAmt":28653.5,"HoursWorked":1264.75,"IsEligibleSI":1,"EligibleRateSI":4}]},{"LastName":"VALENCIA","FirstName":"JUAN","Active":"A","IsOwner":0,"State":"CA","WCcodes":[{"WCcode":"5028","PayAmt":47543.5,"PremPayAmt":46227,"HoursWorked":1532.5,"IsEligibleSI":1,"EligibleRateSI":2.3}]},{"LastName":"WESTBROOK","FirstName":"CASSANDRA","Active":"A","IsOwner":0,"State":"CA","WCcodes":[{"WCcode":"8742","PayAmt":57356,"PremPayAmt":56997.5,"HoursWorked":1765,"IsEligibleSI":0,"EligibleRateSI":0}]},{"LastName":"WESTBROOK","FirstName":"EDWARD","Active":"A","IsOwner":0,"State":"CA","WCcodes":[{"WCcode":"5028","PayAmt":122997.5,"PremPayAmt":122997.5,"HoursWorked":2082.25,"IsEligibleSI":1,"EligibleRateSI":2.3}]},{"LastName":"WESTBROOK","FirstName":"EDWARD","Active":"A","IsOwner":1,"State":"CA","WCcodes":[{"WCcode":"1000","PayAmt":113076.81,"PremPayAmt":0,"HoursWorked":1960,"IsEligibleSI":0,"EligibleRateSI":0}]}]}';
    private String workCompRatesData = '{"CLIENTID":"900028","DATALIST":[{"STATE":"CA","WCCODE":"1000","WCRATE":0},{"STATE":"CA","WCCODE":"1803","WCRATE":11.7527},{"STATE":"CA","WCCODE":"5027","WCRATE":14.428},{"STATE":"CA","WCCODE":"5028","WCRATE":8.758},{"STATE":"CA","WCCODE":"5348","WCRATE":7.3072},{"STATE":"CA","WCCODE":"8227","WCRATE":8.5317},{"STATE":"CA","WCCODE":"8742","WCRATE":0.7321},{"STATE":"CA","WCCODE":"8810","WCRATE":0.6522},{"STATE":"CA","WCCODE":"8810A","WCRATE":0.6522},{"STATE":"NV","WCCODE":"1000","WCRATE":0},{"STATE":"NV","WCCODE":"1803","WCRATE":7.171},{"STATE":"NV","WCCODE":"5022","WCRATE":5.897},{"STATE":"NV","WCCODE":"5348","WCRATE":4.91},{"STATE":"NV","WCCODE":"8227","WCRATE":9.033},{"STATE":"NV","WCCODE":"8742","WCRATE":0.9},{"STATE":"NV","WCCODE":"8810","WCRATE":0.337}]}';
    private String sutaRatesData = '{"CLIENTID":"900028","DATALIST":[{"State":"CA","SUTA":6.2,"ETT":0},{"State":"NV","SUTA":3}]}';
    private String xmodData = '{"CLIENTID":"903961","DATALIST":[{"STARTDATE":"2017-08-11 00:00:00.0","ENDDATE":"2018-08-10 00:00:00.0","XMODLIST":[{"STATE":"OR","XMOD":1}]},{"STARTDATE":"2016-08-11 00:00:00.0","ENDDATE":"2017-08-10 00:00:00.0","XMODLIST":[{"STATE":"OR","XMOD":1}]},{"STARTDATE":"2015-08-11 00:00:00.0","ENDDATE":"2016-08-10 00:00:00.0","XMODLIST":[{"STATE":"CO","XMOD":1},{"STATE":"OR","XMOD":1}]}]}';

    /**
     * getPricingSummaryData gets test Pricing Summary Data
     * @return   A JSON String of data
     */
    private String getPricingSummaryData() {
        Integer year = Date.today().Year();
        Integer yearM1 = year-1;
        Integer yearM2 = year-2;
        Integer yearP1 = year+1;

        return
        '{' +
        ' "PayrollHistoryTable":{' +
        '  "Client":904611,' +
        '  "StartDate":"2018-04-01",' +
        '  "Payroll":[' +
        '   {' +
        '    "Year":"' + year + '",' +
        '    "MinDate":"' + year + '-05-20",' +
        '    "MaxDate":"' + year + '-11-04",' +
        '    "LastName":"BALDERSTON",' +
        '    "FirstName":"ALIK",' +
        '    "SSN":"***-**-1171",' +
        '    "IsOwner":0,' +
        '    "Active":"T",' +
        '    "WcDetails":[' +
        '     {' +
        '      "State":"CA",' +
        '      "WcCode":"0042",' +
        '      "JobCode":"0042",' +
        '      "BillAmt":11055.33,' +
        '      "PayAmt":9408,' +
        '      "PremPayAmt":9408,' +
        '      "TaxablePayAmt":9408,' +
        '      "ErTaxes":1120.54,' +
        '      "WcPremiums":551.35,' +
        '      "HoursWorked":784' +
        '     }' +
        '    ]' +
        '   },' +
        '   {' +
        '    "Year":"' + yearP1 + '",' +
        '    "MinDate":"' + yearP1 + '-04-14",' +
        '    "MaxDate":"' + yearP1 + '-09-01",' +
        '    "LastName":"SMITH,",' +
        '    "FirstName":"ROBERT",' +
        '    "SSN":"***-**-2369",' +
        '    "IsOwner":0,' +
        '    "Active":"T",' +
        '    "WcDetails":[' +
        '     {' +
        '      "State":"MD",' +
        '      "WcCode":"0042",' +
        '      "JobCode":"0042",' +
        '      "BillAmt":2467.71,' +
        '      "PayAmt":2100,' +
        '      "PremPayAmt":2100,' +
        '      "TaxablePayAmt":2100,' +
        '      "ErTaxes":242.55,' +
        '      "WcPremiums":123.06,' +
        '      "HoursWorked":208' +
        '     }' +
        '    ]' +
        '   }' +
        '  ]' +
        ' },' +
        ' "PayrollHistorySumTable":{' +
        '  "Client":904611,' +
        '  "StartDate":"' + year + '-04-01",' +
        '  "Data":[' +
        '   {' +
        '    "Year":"' + yearM2 + '",' +
        '    "MinDate":"2016-05-01",' +
        '    "MaxDate":"2017-03-25",' +
        '    "BillAmt":12968.44,' +
        '    "PayAmt":11036,' +
        '    "PremPayAmt":11036,' +
        '    "TaxablePayAmt":11036,' +
        '    "ErTaxes":1421.14,' +
        '    "WcPremiums":646.74,' +
        '    "BillAdj":0,' +
        '    "HoursWorked":921' +
        '   },' +
        '   {' +
        '    "Year":"' + yearM1 + '",' +
        '    "MinDate":"2017-04-01",' +
        '    "MaxDate":"2017-11-04",' +
        '    "BillAmt":12253.93,' +
        '    "PayAmt":10428,' +
        '    "PremPayAmt":10428,' +
        '    "TaxablePayAmt":10428,' +
        '    "ErTaxes":1262.83,' +
        '    "WcPremiums":611.12,' +
        '    "BillAdj":123,' +
        '    "HoursWorked":843' +
        '   },' +
        '   {' +
        '    "Year":"' + year + '",' +
        '    "MinDate":"2018-04-14",' +
        '    "MaxDate":"2018-09-01",' +
        '    "BillAmt":2467.71,' +
        '    "PayAmt":2100,' +
        '    "PremPayAmt":2100,' +
        '    "TaxablePayAmt":2100,' +
        '    "ErTaxes":242.55,' +
        '    "WcPremiums":123.06,' +
        '    "BillAdj":0,' +
        '    "HoursWorked":208' +
        '   }' +
        '  ]' +
        ' },' +
        ' "RiskClaimsSI":{' +
        '  "CLIENT":904611,' +
        '  "STARTDATE":"2018-04-01",' +
        '  "DATALIST":[' +
        '   {' +
        '    "Year":"' + year + '",' +
        '    "StateCode":"MD",' +
        '    "WCBilled":123.06,' +
        '    "PremBasedPayroll":2100,' +
        '    "PeriodStartDate":"' + yearM1 + '-04-01 00:00:00.0",' +
        '    "TotalIncurred":0,' +
        '    "UltimateExpected":0,' +
        '    "OpenClaims":0,' +
        '    "TotalClaims":0,' +
        '    "Frequency":0,' +
        '    "MaxSI":0' +
        '   },' +
        '   {' +
        '    "Year":"' + yearM1 + '",' +
        '    "StateCode":"MD",' +
        '    "WCBilled":611.12,' +
        '    "PremBasedPayroll":10428,' +
        '    "PeriodStartDate":"' + yearM2 + '-04-01 00:00:00.0",' +
        '    "TotalIncurred":0,' +
        '    "UltimateExpected":0,' +
        '    "OpenClaims":0,' +
        '    "TotalClaims":0,' +
        '    "Frequency":0,' +
        '    "MaxSI":0' +
        '   },' +
        '   {' +
        '    "Year":"' + yearM2 + '",' +
        '    "StateCode":"MD",' +
        '    "WCBilled":646.74,' +
        '    "PremBasedPayroll":11036,' +
        '    "PeriodStartDate":"2016-04-01 00:00:00.0",' +
        '    "TotalIncurred":0,' +
        '    "UltimateExpected":0,' +
        '    "OpenClaims":0,' +
        '    "TotalClaims":0,' +
        '    "Frequency":0,' +
        '    "MaxSI":0' +
        '   },' +
        '   {' +
        '    "Year":"0",' +
        '    "StateCode":" ",' +
        '    "WCBilled":0,' +
        '    "PremBasedPayroll":0,' +
        '    "PeriodStartDate":"2018-04-01 00:00:00.0",' +
        '    "TotalIncurred":0,' +
        '    "UltimateExpected":0,' +
        '    "OpenClaims":0,' +
        '    "TotalClaims":0,' +
        '    "Frequency":0,' +
        '    "MaxSI":0' +
        '   }' +
        '  ]' +
        ' },' +
        ' "BdmAndCommissions":{' +
        '  "CLIENT":904611,' +
        '  "STARTDATE":"2018-04-01",' +
        '  "HasBdm":"FALSE",' +
        '  "BdmName":" ",' +
        '  "DATALIST":[' +
        '   {' +
        '    "Year":"0",' +
        '    "Acronym":" ",' +
        '    "Company":" ",' +
        '    "MinDate":"1900-01-01 00:00:00.0",' +
        '    "MaxDate":"1900-01-01 00:00:00.0",' +
        '    "CommRate":0,' +
        '    "CommAmt":0' +
        '   }' +
        '  ]' +
        ' },' +
        ' "XmodHistory":{' +
        '  "Client":904611,' +
        '  "XmodDetails":[' +
        '   {' +
        '    "Year":"2017",' +
        '    "StateCode":"CA",' +
        '    "ModifiedDate":"2016-05-01 00:00:00.0",' +
        '    "Xmod":1' +
        '   }' +
        '  ]' +
        ' },' +
        ' "WorkCompRates":{' +
        '  "CLIENTID":"904611",' +
        '  "DATALIST":[' +
        '   {' +
        '    "STATE":"CA",' +
        '    "WCCODE":"0042",' +
        '    "WCRATE":5.86' +
        '   }' +
        '  ]' +
        ' },' +
        ' "WcAndSI":{' +
        '  "Client":904611,' +
        '  "WcSiList":[' +
        '   {' +
        '    "StateCode":"CA",' +
        '    "WcCode":"0042",' +
        '    "IsEligible":0,' +
        '    "EligibleRateSI":0' +
        '   }' +
        '  ]' +
        ' },' +
        ' "TemplateWorkCompRates":{' +
        '  "CLIENTID":"904611",' +
        '  "DATALIST":[' +
        '   {' +
        '    "STATE":"MD",' +
        '    "WCCODE":"0005",' +
        '    "WCRATE":1.99,' +
        '    "DESCRIPTION":"0005-FARM- NURSERY EMPLOYEES AND DRIVERS"' +
        '   },' +
        '   {' +
        '    "STATE":"MD",' +
        '    "WCCODE":"9620",' +
        '    "WCRATE":0.78,' +
        '    "DESCRIPTION":"9620-FUNERAL DIRECTOR AND DRIVERS"' +
        '   }' +
        '  ]' +
        ' }' +
        '}';
    }

}