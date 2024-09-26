@isTest
public class WorkCompCalloutClass_Mock implements HttpCalloutMock {

    protected Integer code;
    protected String status;
    protected String body;
    protected Map<String, String> responseHeaders;

    public WorkCompCalloutClass_Mock() {
        this.code = 200;
        this.status = 'OK';
        this.body = '';
        this.responseHeaders = new Map<String, String>();
    }

    public WorkCompCalloutClass_Mock(string claimsResponse, String xmodResponse, string riskanalysisResponse) {
         this.responseHeaders = new Map<String, String>();
        //negtive test response.. when i pass in 'ERROR' in marginResponse
        if (claimsResponse =='ERROR')
        {
            this.code = 400;
            this.status = 'ERROR';    
        }
        else
        {    
             this.code = 200;
             this.status = 'OK';
             if (claimsResponse.length() > 0) {
                 riskAndClaimsData = claimsResponse;
             }
             if (xmodResponse.length() > 0) {
                 xmodData = xmodResponse;
             }
             if (riskanalysisResponse.length() > 0) {
                 riskanalysisData = riskanalysisResponse;
             }
        }
         system.debug(' this.status:::' +  this.status);
    }

    public HTTPResponse respond(HTTPRequest req) 
    {
        if (req.getEndpoint().contains(workCompModel2Url)) {
            this.body = workCompModel2Data;
        }

        if (req.getEndpoint().contains(riskAndClaimsUrl)) {
            this.body = riskAndClaimsData;
        }

        if (req.getEndpoint().contains(xmodUrl)) {
            this.body = xmodData;
        }
        
        if (req.getEndpoint().contains(riskanalysisUrl)) {
            this.body = riskanalysisData;
        }

        if (req.getEndpoint().contains(siDataUrl)) {
            this.body = siData;
        }

        if (req.getEndpoint().contains(renewalYrPayUrl)) {
            this.body = renewalYrPayData;
        }

        if (req.getEndpoint().contains(workCompPolicies)) {
            this.body = workCompPoliciesData;
        }

        if (req.getEndpoint().contains(workCompPolicyCodeRate)) {
            this.body = workCompPolicyCodeRateData;
        }

        HttpResponse res = new HttpResponse();
        res.setBody(this.body);
        res.setStatusCode(this.code);
        res.setStatus(this.status);
        this.responseHeaders.put('Content-Type', 'application/json');
        return res;
    }

    // Url strings
    private string workCompModel2Url = '/getWorkCompModel2';
    private String riskAndClaimsUrl = '/getRiskAndClaims';
    private String xmodUrl = '/getXmodHistory';
    private String riskanalysisUrl = '/getRiskAnalysis';
    private String siDataUrl = '/getSafetyIncentiveData';
    private String renewalYrPayUrl = '/getRenewalYrPayEstimate';
    private String workCompPolicies = '/getWorkCompPolicies';
    private String workCompPolicyCodeRate = '/getWorkCompPolicyCodeRate';


    // test data
    private String workCompModel2Data = '{"SAFETYINCENTIVE":{"CLIENT":"900001","RUNDATE":"2017-07-31 00:00:00.0","DATALIST":[{"StartDate":"2017-01-01 00:00:00.0","EndDate":"2017-12-31 00:00:00.0","EligiblePR":86078.62,"MaxSI":895.22,"Losses":19390.9,"ProfServices":925,"ModWork":0,"SIEarned":-19420.68,"AmountPaid":0,"Status":"InYear"},{"StartDate":"2016-01-01 00:00:00.0","EndDate":"2016-12-31 00:00:00.0","EligiblePR":151239.61,"MaxSI":1572.89,"Losses":0,"ProfServices":0,"ModWork":0,"SIEarned":1572.89,"PaidDate":"2017-02-27 00:00:00.0","AmountPaid":1572.89,"Status":" "},{"StartDate":"2015-01-01 00:00:00.0","EndDate":"2015-12-31 00:00:00.0","EligiblePR":160434.34,"MaxSI":1668.52,"Losses":52260.79,"ProfServices":1205,"ModWork":0,"SIEarned":-51797.27,"AmountPaid":0,"Status":" "},{"StartDate":"2014-01-01 00:00:00.0","EndDate":"2014-12-31 00:00:00.0","EligiblePR":120434.34,"MaxSI":1468.52,"Losses":50260.79,"ProfServices":1005,"ModWork":0,"SIEarned":-55797.27,"AmountPaid":0,"Status":" "},{"StartDate":"2013-01-01 00:00:00.0","EndDate":"2013-12-31 00:00:00.0","EligiblePR":110434.34,"MaxSI":1368.52,"Losses":49260.79,"ProfServices":805,"ModWork":0,"SIEarned":-61797.27,"AmountPaid":0,"Status":" "}]},"XMODHISTORY":{"CLIENTID":"900001","DATALIST":[{"STARTDATE":"2017-01-01 00:00:00.0","ENDDATE":"2017-12-31 00:00:00.0","XMODLIST":[{"STATE":"DE","XMOD":1}]},{"STARTDATE":"2016-01-01 00:00:00.0","ENDDATE":"2016-12-31 00:00:00.0","XMODLIST":[{"STATE":"DE","XMOD":1}]},{"STARTDATE":"2015-01-01 00:00:00.0","ENDDATE":"2015-12-31 00:00:00.0","XMODLIST":[{"STATE":"DE","XMOD":1}]}]}}';
    private String riskAndClaimsData = '{"CLIENT":900199,"STARTDATE":"2017-01-01","DATALIST":[{"Year":"2018","StateCode":"CA","WCBilled":9943.17,"PremBasedPayroll":147223.75,"PeriodStartDate":"2017-01-01","TotalIncurred":0,"UltimateExpected":0,"OpenClaims":0,"TotalClaims":0,"Frequency":0},{"Year":"2017","StateCode":"CA","WCBilled":19461.16,"PremBasedPayroll":369708.79,"PeriodStartDate":"2016-01-01","TotalIncurred":2463.22,"UltimateExpected":0,"OpenClaims":0,"TotalClaims":4,"Frequency":10.82},{"Year":"2016","StateCode":"CA","WCBilled":10610.61,"PremBasedPayroll":248021.75,"PeriodStartDate":"2015-01-01","TotalIncurred":568.38,"UltimateExpected":0,"OpenClaims":0,"TotalClaims":1,"Frequency":4.03},{"Year":"2015","StateCode":"CA","WCBilled":9741.6,"PremBasedPayroll":236328,"PeriodStartDate":"2014-01-01","TotalIncurred":2748.26,"UltimateExpected":0,"OpenClaims":0,"TotalClaims":1,"Frequency":4.23},{"Year":"2014","StateCode":"CA","WCBilled":4306.29,"PremBasedPayroll":168174,"PeriodStartDate":"2013-01-01","TotalIncurred":0,"UltimateExpected":0,"OpenClaims":0,"TotalClaims":0,"Frequency":0},{"Year":"2013","StateCode":"CA","WCBilled":4289.72,"PremBasedPayroll":233142,"PeriodStartDate":"2012-01-01","TotalIncurred":0,"UltimateExpected":0,"OpenClaims":0,"TotalClaims":0,"Frequency":0},{"Year":"2012","StateCode":"CA","WCBilled":3661.74,"PremBasedPayroll":207391.5,"PeriodStartDate":"2011-01-01","TotalIncurred":0,"UltimateExpected":0,"OpenClaims":0,"TotalClaims":0,"Frequency":0},{"Year":"2011","StateCode":"CA","WCBilled":2946.55,"PremBasedPayroll":164313.5,"PeriodStartDate":"2010-01-01","TotalIncurred":0,"UltimateExpected":0,"OpenClaims":0,"TotalClaims":0,"Frequency":0}]}';
    private String xmodData = '{"CLIENTID":"903961","DATALIST":[{"STARTDATE":"2016-08-11 00:00:00.0","ENDDATE":"2017-08-10 00:00:00.0","XMODLIST":[{"STATE":"OR","XMOD":1}]},{"STARTDATE":"2015-08-11 00:00:00.0","ENDDATE":"2016-08-10 00:00:00.0","XMODLIST":[{"STATE":"OR","XMOD":1}]},{"STARTDATE":"2014-08-11 00:00:00.0","ENDDATE":"2015-08-10 00:00:00.0","XMODLIST":[{"STATE":"CO","XMOD":1},{"STATE":"OR","XMOD":1}]}]}';
    private String riskanalysisData = '{"CLIENTID":"900028","DATALIST":[{"STARTDATE":"2016-06-08 00:00:00.0","ENDDATE":"2017-06-07 00:00:00.0","RISKANALYSISLIST":[{"STATE":"CA","WCBILLED":122207.31,"PREMBASEDPAYROLL":1616524.33},{"STATE":"NV","WCBILLED":16743.48,"PREMBASEDPAYROLL":333912.05}]},{"STARTDATE":"2017-06-15 00:00:00.0","ENDDATE":"2017-06-15 00:00:00.0","RISKANALYSISLIST":[{"STATE":" ","WCBILLED":0,"PREMBASEDPAYROLL":0}]},{"STARTDATE":"1999-12-31 00:00:00.0","ENDDATE":"2017-06-14 00:00:00.0","RISKANALYSISLIST":[{"STATE":"CA","WCBILLED":607291.88,"PREMBASEDPAYROLL":5276700.28},{"STATE":"NV","WCBILLED":17409.38,"PREMBASEDPAYROLL":348820.05}]},{"STARTDATE":"2015-06-08 00:00:00.0","ENDDATE":"2016-06-07 00:00:00.0","RISKANALYSISLIST":[{"STATE":"CA","WCBILLED":109049.73,"PREMBASEDPAYROLL":946350.83}]},{"STARTDATE":"2014-06-08 00:00:00.0","ENDDATE":"2015-06-07 00:00:00.0","RISKANALYSISLIST":[{"STATE":"CA","WCBILLED":157897.84,"PREMBASEDPAYROLL":992924.49}]}]}';
    private String siData = '{"CLIENT":"900001","RUNDATE": "2017-05-31 00:00:00.0","DATALIST":[{"StartDate":"2017-01-01 00:00:00.0","EndDate":"2017-12-31 00:00:00.0","EligiblePR":58819.84,"MaxSI":611.73,"Losses":19390.9,"ProfServices":925,"ModWork":0,"SIEarned":-19704.17,"AmountPaid":0,"Status":"InYear"},{"StartDate":"2016-01-01 00:00:00.0","EndDate":"2016-12-31 00:00:00.0","EligiblePR":151239.61,"MaxSI":1572.89,"Losses":0,"ProfServices":0,"ModWork":0,"SIEarned":1572.89,"PaidDate":"2017-02-27 00:00:00.0","AmountPaid":1572.89,"Status":" "},{"StartDate":"2015-01-01 00:00:00.0","EndDate":"2015-12-31 00:00:00.0","EligiblePR":160434.34,"MaxSI":1668.52,"Losses":52260.79,"ProfServices":1205,"ModWork":0,"SIEarned":-51797.27,"AmountPaid":0,"Status":" "}]}';
    private String renewalYrPayData = '{"CLIENT":"901153","DATALIST":[{"State":"CA","LastName":"Broussard","FirstName":"Lynette","Active":"A","IsOwner":0,"PayAmt":1709.13},{"State":"CA","LastName":"GUHLER","FirstName":"COLTON","Active":"A","IsOwner":0,"PayAmt":554.9},{"State":"MT","LastName":"BARTA","FirstName":"JAMIE","Active":"A","IsOwner":0,"PayAmt":2459.16},{"State":"OR","LastName":"Abraham","FirstName":"Matthew","Active":"A","IsOwner":0,"PayAmt":600.66},{"State":"OR","LastName":"ACKERMANN","FirstName":"JOLEY","Active":"A","IsOwner":0,"PayAmt":4852.37},{"State":"OR","LastName":"AILSTOCK","FirstName":"AUSTIN","Active":"A","IsOwner":0,"PayAmt":352.75}]}';
    private String workCompPoliciesData = '{"DATALIST":["A2","A3","A4","BBSI","BBSIMDMASTER","BBSISTAFFING","BOND-NC","CLIENT","D1","ECOLESTAFFING","I1","IDSTAFFING","N4","N5","N6","N8","STATE","STATESTAFFING","U4","W1","105655WA"]}';
    private String workCompPolicyCodeRateData = '{"DATALIST":[{"WcPolicy":"A2","State":"AZ","Code":"1000","Rate":"0.0000"},{"WcPolicy":"A3","State":"AZ","Code":"0005","Rate":"3.3400"},{"WcPolicy":"A3","State":"AZ","Code":"0006","Rate":"14.9000"},{"WcPolicy":"BBSI","State":"CA","Code":"0005","Rate":"6.8813"},{"WcPolicy":"BBSI","State":"CA","Code":"0016","Rate":"11.0606"},{"WcPolicy":"BBSI","State":"CA","Code":"0034","Rate":"9.8760"},{"WcPolicy":"BBSI","State":"CA","Code":"0035","Rate":"5.5370"},{"WcPolicy":"BBSI","State":"CA","Code":"0036","Rate":"10.6214"},{"WcPolicy":"BBSI","State":"CA","Code":"0038","Rate":"17.1699"},{"WcPolicy":"BBSI","State":"CA","Code":"0040","Rate":"5.9629"},{"WcPolicy":"BBSI","State":"CA","Code":"0041","Rate":"8.9576"},{"WcPolicy":"BBSI","State":"CA","Code":"0042","Rate":"9.7429"},{"WcPolicy":"BBSI","State":"CA","Code":"0044","Rate":"10.8610"},{"WcPolicy":"BBSI","State":"CA","Code":"0045","Rate":"7.1209"},{"WcPolicy":"BBSI","State":"CA","Code":"0050","Rate":"10.1422"},{"WcPolicy":"BBSI","State":"CA","Code":"0079","Rate":"4.7117"},{"WcPolicy":"BBSI","State":"CA","Code":"0096","Rate":"8.8112"},{"WcPolicy":"BBSI","State":"CA","Code":"0106","Rate":"24.1843"},{"WcPolicy":"BBSI","State":"CA","Code":"0171","Rate":"10.9941"},{"WcPolicy":"BBSI","State":"CA","Code":"0172","Rate":"7.7198"},{"WcPolicy":"BBSI","State":"CA","Code":"0251","Rate":"7.8263"},{"WcPolicy":"BBSI","State":"CA","Code":"0400","Rate":"6.4420"}]}';

 }