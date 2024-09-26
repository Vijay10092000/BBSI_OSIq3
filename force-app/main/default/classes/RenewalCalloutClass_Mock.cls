@IsTest
public class RenewalCalloutClass_Mock implements HttpCalloutMock {

    protected Integer code;
    protected String status;
    protected String body;
    protected Map<String, String> responseHeaders;
    protected Boolean softError = false;
    protected Boolean authError = false;
    protected Boolean emptyBodyError = false;

    public RenewalCalloutClass_Mock(){
        this.code = 200;
        this.status = 'OK';
        this.responseHeaders = new Map<String, String>();
    }

    public RenewalCalloutClass_Mock(string marginResponse, string billingResponse, string expenseResponse,
            string turnoverResponse, string BDMResponse, string SecondaryService)
    {
        this.responseHeaders = new Map<String, String>();
        //negative test response.. when i pass in 'ERROR' in marginResponse
        if (marginResponse =='SOFT ERROR')
        {
            this.softError = true;
            this.code = 200;
            this.status = 'Soft Error';
            this.body = '';
        }
        else if (marginResponse =='ERROR')
        {
            this.code = 400;
            this.status = 'ERROR';
            this.body = '';
        }
        else if (marginResponse =='EMPTY ERROR')
        {
            this.code = 200;
            this.status = 'ERROR';
            this.body = '';
            this.emptyBodyError = true;
        }
        else if (marginResponse == 'AUTH ERROR') {
            this.authError = true;
            this.code = 404;
            this.status = 'Auth Error';
            this.body = '{"Message": "Authorization has been denied for this request."}';
        }
        else
        {
            this.code = 200;
            this.status = 'OK';
            if (marginResponse.length() > 0) {
                marginData = marginResponse;
            }
            if (billingResponse.length() > 0) {
                bilAdjData = billingResponse;
            }
            if (expenseResponse.length() > 0) {
                expensData = expenseResponse;
            }
            if (turnoverResponse.length() > 0) {
                turnvrData = turnoverResponse;
            }
            if (SecondaryService.length() > 0) {
                secdServData = SecondaryService;
            }
            if (BDMResponse.length() > 0) {
                bdmData = BDMResponse;
            }

        }

        system.debug(' this.status:::' +  this.status);

    }

    public HTTPResponse respond(HTTPRequest req) {

        system.debug('Renewal Callout Class Mock request string: ' + req);
        if(req.getEndpoint().contains(marginModelUrl)){
            this.body = marginModelData;
        } else if (req.getEndpoint().contains(marginUrl)){
            this.body = marginData;
        } else if (req.getEndpoint().contains(billingAdjUrl)){
            this.body = bilAdjData;
        } else if (req.getEndpoint().contains(expensesUrl)){
            this.body = expensData;
        } else if (req.getEndpoint().contains(turnoverUrl)){
            this.body = turnvrData;
        } else if (req.getEndpoint().contains(secondServUrl)){
            this.body = secdServData;
        } else if (req.getEndpoint().contains(bdmUrl)){
            this.body = bdmData;
        } else if(req.getEndpoint().contains(taxBurdenUrl)){
            this.body = taxBurdenData;
        } else if(req.getEndpoint().contains(xmodsUrl)){
            if (softError) {
                this.body = xmodsData_Error1;
            } else if (authError) {
                this.body = xmodsData_AuthError;
            } else if (emptyBodyError) {
                this.body = '';
            } else {
                this.body = xmodsData;
            }
        } else{
            this.body = '';
        }

        system.debug('Renewal Callout Class Mock body string: ' + this.body);
        HttpResponse res = new HttpResponse();
        res.setBody(this.body);
        res.setStatusCode(this.code);
        res.setStatus(this.status);
        this.responseHeaders.put('Content-Type', 'application/json');
        return res;
    }

    private string xmodsUrl = '/getExmodReport';
    private string marginModelUrl = '/getMarginAnalysisModel';
    private String marginUrl = '/getMarginData';
    private String billingAdjUrl= '/getBillingAdjustments';
    private String expensesUrl = '/getDirectExpenses';
    private String turnoverUrl = '/getTurnover';
    private String secondServUrl = '/getSecondaryServices';
    private String bdmUrl = '/getBdm';
    private String taxBurdenUrl = '/getTaxBurden';

    // test data...
    private string xmodsData = '{"ExMods":[{"year":2019,"calc_date":"2019-03-08","exmod":165,"exmod_status":"(N) New Entry"},{"year":2018,"calc_date":"2018-01-18","exmod":119,"exmod_status":"(R) Revised Entry"},{"year":2017,"calc_date":"2017-03-17","exmod":78,"exmod_status":""},{"year":2016,"calc_date":"2016-04-30","exmod":183,"exmod_status":"(R) Revised Entry"}],"BureauReportUrl":"https://exmod.com/Employer?EmployerFilter=3358737"}';
    private string xmodsData_Error1 = '{"FEIN":"ERROR"}';
    private string xmodsData_AuthError = '{"Message": "Authorization has been denied for this request."}';
    private string marginModelData = '{"BILLINGADJUSTMENTS":{"CLIENTID":"905384","DATALIST":[{"STARTDATE":"2016-06-08 00:00:00.0","ENDDATE":"2017-06-07 00:00:00.0","BILLINGADJUSTMENTS":-225},{"STARTDATE":"2017-06-15 00:00:00.0","ENDDATE":"2017-06-15 00:00:00.0","BILLINGADJUSTMENTS":0},{"STARTDATE":"1999-12-31 00:00:00.0","ENDDATE":"2017-06-14 00:00:00.0","BILLINGADJUSTMENTS":-225},{"STARTDATE":"2015-06-08 00:00:00.0","ENDDATE":"2016-06-07 00:00:00.0","BILLINGADJUSTMENTS":0},{"STARTDATE":"2014-06-08 00:00:00.0","ENDDATE":"2015-06-07 00:00:00.0","BILLINGADJUSTMENTS":0}]},"DIRECTEXPENSES":{"CLIENTID":"905384","DIRECTEXPENSES":[{"STARTDATE":"2016-06-08 00:00:00.0","ENDDATE":"2017-06-07 00:00:00.0","COMMISSIONAMT":5839.91,"PERCENTOFWCBYPAYROLL":0.1,"PERCENTOFPAYROLL":0,"PERCENTOFWC":0,"CESPRPER":0,"MARGINPERCENT":0,"COMMENTS":"added 12/10/2015"},{"STARTDATE":"2017-06-15 00:00:00.0","ENDDATE":"2017-06-15 00:00:00.0","COMMISSIONAMT":0,"PERCENTOFWCBYPAYROLL":0,"PERCENTOFPAYROLL":0,"PERCENTOFWC":0,"CESPRPER":0,"MARGINPERCENT":0},{"STARTDATE":"1999-12-31 00:00:00.0","ENDDATE":"2017-06-14 00:00:00.0","COMMISSIONAMT":7740.5,"PERCENTOFWCBYPAYROLL":0.1,"PERCENTOFPAYROLL":0,"PERCENTOFWC":0,"CESPRPER":0,"MARGINPERCENT":0,"COMMENTS":"added 12/10/2015"},{"STARTDATE":"2015-06-08 00:00:00.0","ENDDATE":"2016-06-07 00:00:00.0","COMMISSIONAMT":1900.59,"PERCENTOFWCBYPAYROLL":0.1,"PERCENTOFPAYROLL":0,"PERCENTOFWC":0,"CESPRPER":0,"MARGINPERCENT":0,"COMMENTS":"added 12/10/2015"},{"STARTDATE":"2014-06-08 00:00:00.0","ENDDATE":"2015-06-07 00:00:00.0","COMMISSIONAMT":0,"PERCENTOFWCBYPAYROLL":0,"PERCENTOFPAYROLL":0,"PERCENTOFWC":0,"CESPRPER":0,"MARGINPERCENT":0}]},"MARGINDATA":{"CLIENTID":"905384","DATALIST":[{"StartDate":"2016-06-08 00:00:00.0","EndDate":"2017-06-07 00:00:00.0","MARGINSUMDATALIST":[{"STATE":"OR","WCCODE":"1000","MARGIN":1633.32},{"STATE":"OR","WCCODE":"4130","MARGIN":6039.01},{"STATE":"OR","WCCODE":"5102","MARGIN":5055.82},{"STATE":"OR","WCCODE":"5462","MARGIN":21074.44},{"STATE":"OR","WCCODE":"8380","MARGIN":5980.5},{"STATE":"OR","WCCODE":"8742","MARGIN":512.48},{"STATE":"OR","WCCODE":"8810","MARGIN":1147.94}]},{"StartDate":"2017-06-15 00:00:00.0","EndDate":"2017-06-15 00:00:00.0","MARGINSUMDATALIST":[{"STATE":"none","WCCODE":"none","MARGIN":0}]},{"StartDate":"1999-12-31 00:00:00.0","EndDate":"2017-06-14 00:00:00.0","MARGINSUMDATALIST":[{"STATE":"OR","WCCODE":"1000","MARGIN":1664.11},{"STATE":"OR","WCCODE":"4130","MARGIN":8038.65},{"STATE":"OR","WCCODE":"5102","MARGIN":6774.69},{"STATE":"OR","WCCODE":"5462","MARGIN":26939.4},{"STATE":"OR","WCCODE":"8380","MARGIN":7878.32},{"STATE":"OR","WCCODE":"8742","MARGIN":673.01},{"STATE":"OR","WCCODE":"8810","MARGIN":1538.42}]},{"StartDate":"2015-06-08 00:00:00.0","EndDate":"2016-06-07 00:00:00.0","MARGINSUMDATALIST":[{"STATE":"OR","WCCODE":"1000","MARGIN":30.79},{"STATE":"OR","WCCODE":"4130","MARGIN":1999.64},{"STATE":"OR","WCCODE":"5102","MARGIN":1718.87},{"STATE":"OR","WCCODE":"5462","MARGIN":5864.96},{"STATE":"OR","WCCODE":"8380","MARGIN":1897.82},{"STATE":"OR","WCCODE":"8742","MARGIN":160.53},{"STATE":"OR","WCCODE":"8810","MARGIN":390.48}]},{"StartDate":"2014-06-08 00:00:00.0","EndDate":"2015-06-07 00:00:00.0","MARGINSUMDATALIST":[{"STATE":"none","WCCODE":"none","MARGIN":0}]}]},"TURNOVER":{"CLIENTID":"905384","DATALIST":[{"STARTDATE":"2016-06-08 00:00:00.0","ENDDATE":"2017-06-07 00:00:00.0","EEANNUAL":58,"EECURRENT":40},{"STARTDATE":"2016-06-16 00:00:00.0","ENDDATE":"2017-06-15 00:00:00.0","EEANNUAL":58,"EECURRENT":40},{"STARTDATE":"2016-06-15 00:00:00.0","ENDDATE":"2017-06-14 00:00:00.0","EEANNUAL":58,"EECURRENT":40},{"STARTDATE":"2015-06-09 00:00:00.0","ENDDATE":"2016-06-07 00:00:00.0","EEANNUAL":45,"EECURRENT":40},{"STARTDATE":"2014-06-08 00:00:00.0","ENDDATE":"2015-06-07 00:00:00.0","EEANNUAL":0,"EECURRENT":0}]},"SECONDARYSERVICES":{"CLIENTID":"905384","DATALIST":[{"STARTDATE":"2016-06-08 00:00:00.0","ENDDATE":"2017-06-07 00:00:00.0","SECONDARYSERVICES":-31},{"STARTDATE":"2017-06-15 00:00:00.0","ENDDATE":"2017-06-15 00:00:00.0","SECONDARYSERVICES":0},{"STARTDATE":"1999-12-31 00:00:00.0","ENDDATE":"2017-06-14 00:00:00.0","SECONDARYSERVICES":-31},{"STARTDATE":"2015-06-08 00:00:00.0","ENDDATE":"2016-06-07 00:00:00.0","SECONDARYSERVICES":0},{"STARTDATE":"2014-06-08 00:00:00.0","ENDDATE":"2015-06-07 00:00:00.0","SECONDARYSERVICES":0}]},"TAXBURDEN":{"CLIENTID":"905384","DATALIST":[{"STARTDATE":"2016-06-08 00:00:00.0","ENDDATE":"2017-06-07 00:00:00.0","TotalPayroll":1521838.91,"TotalTaxes":155894.79,"TotalPayrollNo1000":1398931.26,"TotalTaxesNo1000":144254.1},{"STARTDATE":"2017-06-15 00:00:00.0","ENDDATE":"2017-06-15 00:00:00.0","TotalPayroll":0,"TotalTaxes":0,"TotalPayrollNo1000":0,"TotalTaxesNo1000":0},{"STARTDATE":"1999-12-31 00:00:00.0","ENDDATE":"2017-06-14 00:00:00.0","TotalPayroll":2045806.12,"TotalTaxes":212709.66,"TotalPayrollNo1000":1876211.24,"TotalTaxesNo1000":196057.53},{"STARTDATE":"2015-06-08 00:00:00.0","ENDDATE":"2016-06-07 00:00:00.0","TotalPayroll":523967.21,"TotalTaxes":56814.87,"TotalPayrollNo1000":477279.98,"TotalTaxesNo1000":51803.43},{"STARTDATE":"2014-06-08 00:00:00.0","ENDDATE":"2015-06-07 00:00:00.0","TotalPayroll":0,"TotalTaxes":0,"TotalPayrollNo1000":0,"TotalTaxesNo1000":0}]},"BDM":{"CLIENT":"905384","HASBDM":"FALSE","BDMNAME":" "}}';
    private String marginData = '{"CLIENTID":"900022","DATALIST":[{"StartDate":"2016-08-01 00:00:00.0","EndDate":"2017-06-21 00:00:00.0","MARGINSUMDATALIST":[{"STATE":"DE","WCCODE":"0882","MARGIN":5452.26},{"STATE":"DE","WCCODE":"0953","MARGIN":1780.25},{"STATE":"MD","WCCODE":"0882","MARGIN":13.73}]},{"StartDate":"2017-05-09 00:00:00.0","EndDate":"2017-06-21 00:00:00.0","MARGINSUMDATALIST":[{"STATE":"DE","WCCODE":"0882","MARGIN":95.68},{"STATE":"DE","WCCODE":"0953","MARGIN":10.19},{"STATE":"MD","WCCODE":"0882","MARGIN":8.58}]},{"StartDate":"1999-12-31 00:00:00.0","EndDate":"2017-06-21 00:00:00.0","MARGINSUMDATALIST":[{"STATE":"DE","WCCODE":"0882","MARGIN":38864.72},{"STATE":"DE","WCCODE":"0951","MARGIN":1915.56},{"STATE":"DE","WCCODE":"0953","MARGIN":13366.85},{"STATE":"DE","WCCODE":"1000","MARGIN":-366.68},{"STATE":"MD","WCCODE":"0882","MARGIN":997.05},{"STATE":"MD","WCCODE":"0953","MARGIN":12.2},{"STATE":"MD","WCCODE":"1000","MARGIN":0.47}]},{"StartDate":"2015-08-01 00:00:00.0","EndDate":"2016-07-31 00:00:00.0","MARGINSUMDATALIST":[{"STATE":"DE","WCCODE":"0882","MARGIN":11023.73},{"STATE":"DE","WCCODE":"0953","MARGIN":2949.31}]},{"StartDate":"2014-01-01 00:00:00.0","EndDate":"2015-07-31 00:00:00.0","MARGINSUMDATALIST":[{"STATE":"DE","WCCODE":"0882","MARGIN":14006.28},{"STATE":"DE","WCCODE":"0951","MARGIN":780.42},{"STATE":"DE","WCCODE":"0953","MARGIN":6084.99},{"STATE":"DE","WCCODE":"1000","MARGIN":12.66},{"STATE":"MD","WCCODE":"0882","MARGIN":899.77},{"STATE":"MD","WCCODE":"1000","MARGIN":0.47}]}]}';
    private String bilAdjData = '{"CLIENTID":"900022","DATALIST":[{"STARTDATE":"2016-08-01 00:00:00.0","ENDDATE":"2017-06-21 00:00:00.0","BILLINGADJUSTMENTS":0},{"STARTDATE":"2017-05-09 00:00:00.0","ENDDATE":"2017-06-21 00:00:00.0","BILLINGADJUSTMENTS":0},{"STARTDATE":"1999-12-31 00:00:00.0","ENDDATE":"2017-06-21 00:00:00.0","BILLINGADJUSTMENTS":0},{"STARTDATE":"2015-08-01 00:00:00.0","ENDDATE":"2016-07-31 00:00:00.0","BILLINGADJUSTMENTS":0},{"STARTDATE":"2014-01-01 00:00:00.0","ENDDATE":"2015-07-31 00:00:00.0","BILLINGADJUSTMENTS":0}]}';
    private String expensData = '{"CLIENTID":"900022","DIRECTEXPENSES":[{"STARTDATE":"2016-08-01 00:00:00.0","ENDDATE":"2017-06-21 00:00:00.0","COMMISSIONAMT":0},{"STARTDATE":"2017-05-09 00:00:00.0","ENDDATE":"2017-06-21 00:00:00.0","COMMISSIONAMT":0},{"STARTDATE":"1999-12-31 00:00:00.0","ENDDATE":"2017-06-21 00:00:00.0","COMMISSIONAMT":0},{"STARTDATE":"2015-08-01 00:00:00.0","ENDDATE":"2016-07-31 00:00:00.0","COMMISSIONAMT":0},{"STARTDATE":"2014-01-01 00:00:00.0","ENDDATE":"2015-07-31 00:00:00.0","COMMISSIONAMT":0}]}';
    private String turnvrData = '{"CLIENTID":"900022","DATALIST":[{"STARTDATE":"2016-06-22 00:00:00.0","ENDDATE":"2017-06-21 00:00:00.0","EEANNUAL":29,"EECURRENT":15},{"STARTDATE":"2016-06-22 00:00:00.0","ENDDATE":"2017-06-21 00:00:00.0","EEANNUAL":29,"EECURRENT":15},{"STARTDATE":"2016-06-22 00:00:00.0","ENDDATE":"2017-06-21 00:00:00.0","EEANNUAL":29,"EECURRENT":15},{"STARTDATE":"2015-08-02 00:00:00.0","ENDDATE":"2016-07-31 00:00:00.0","EEANNUAL":40,"EECURRENT":18},{"STARTDATE":"2014-08-01 00:00:00.0","ENDDATE":"2015-07-31 00:00:00.0","EEANNUAL":51,"EECURRENT":17}]}';
    private String secdServData = '{"CLIENTID":"905384","DATALIST":[{"STARTDATE":"2016-06-08 00:00:00.0","ENDDATE":"2017-06-07 00:00:00.0","SECONDARYSERVICES":-31},{"STARTDATE":"2017-06-15 00:00:00.0","ENDDATE":"2017-06-15 00:00:00.0","SECONDARYSERVICES":0},{"STARTDATE":"1999-12-31 00:00:00.0","ENDDATE":"2017-06-14 00:00:00.0","SECONDARYSERVICES":-31},{"STARTDATE":"2015-06-08 00:00:00.0","ENDDATE":"2016-06-07 00:00:00.0","SECONDARYSERVICES":0},{"STARTDATE":"2014-06-08 00:00:00.0","ENDDATE":"2015-06-07 00:00:00.0","SECONDARYSERVICES":0}]}';
    private String bdmData = '{"CLIENT":"900005","HASBDM":"TRUE","BDMNAME":"Erik Swanson"}';
    private String taxBurdenData = '{"CLIENTID":"900022","DATALIST":[{"STARTDATE":"2016-05-12 00:00:00.0","ENDDATE":"2017-05-12 00:00:00.0","TotalPayroll":295102.67,"TotalTaxes":27373.86,"TotalPayrollNo1000":295102.67,"TotalTaxesNo1000":27373.86},{"STARTDATE":"2016-05-12 00:00:00.0","ENDDATE":"2017-05-12 00:00:00.0","TotalPayroll":295102.67,"TotalTaxes":27373.86,"TotalPayrollNo1000":295102.67,"TotalTaxesNo1000":27373.86},{"STARTDATE":"2016-05-12 00:00:00.0","ENDDATE":"2017-05-12 00:00:00.0","TotalPayroll":295102.67,"TotalTaxes":27373.86,"TotalPayrollNo1000":295102.67,"TotalTaxesNo1000":27373.86},{"STARTDATE":"2016-05-12 00:00:00.0","ENDDATE":"2017-05-12 00:00:00.0","TotalPayroll":295102.67,"TotalTaxes":27373.86,"TotalPayrollNo1000":295102.67,"TotalTaxesNo1000":27373.86},{"STARTDATE":"2015-05-12 00:00:00.0","ENDDATE":"2016-05-12 00:00:00.0","TotalPayroll":301292.4,"TotalTaxes":26912.87,"TotalPayrollNo1000":296132.24,"TotalTaxesNo1000":26912.87}]}';
}