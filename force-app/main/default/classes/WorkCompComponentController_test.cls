@isTest
public class WorkCompComponentController_test {
    
    @isTest
    static void WorkCompComponentTest() 
    {
        String negtestMarginAnalysis = '{"CLIENTID":"900022","DATALIST":[{"StartDate":"2016-08-01 00:00:00.0","EndDate":"2017-06-21 00:00:00.0","MARGINSUMDATALIST":[{"STATE":"DE","WCCODE":"0882","MARGIN":5452.26},{"STATE":"CA","WCCODE":"0953","MARGIN":1780.25},{"STATE":"MD","WCCODE":"0882","MARGIN":13.73}]},{"StartDate":"2017-05-09 00:00:00.0","EndDate":"2017-06-21 00:00:00.0","MARGINSUMDATALIST":[{"STATE":"DE","WCCODE":"0882","MARGIN":95.68},{"STATE":"DE","WCCODE":"0953","MARGIN":10.19}]},{"StartDate":"1999-12-31 00:00:00.0","EndDate":"2017-06-21 00:00:00.0","MARGINSUMDATALIST":[{"STATE":"DE","WCCODE":"0882","MARGIN":38864.72},{"STATE":"DE","WCCODE":"0951","MARGIN":1915.56},{"STATE":"DE","WCCODE":"0953","MARGIN":13366.85},{"STATE":"DE","WCCODE":"1000","MARGIN":-366.68},{"STATE":"MD","WCCODE":"0882","MARGIN":997.05},{"STATE":"MD","WCCODE":"0953","MARGIN":12.2},{"STATE":"MD","WCCODE":"1000","MARGIN":0.47}]},{"StartDate":"2015-08-01 00:00:00.0","EndDate":"2016-07-31 00:00:00.0","MARGINSUMDATALIST":[{"STATE":"DE","WCCODE":"0882","MARGIN":11023.73},{"STATE":"DE","WCCODE":"0953","MARGIN":2949.31},{"STATE":"OR","WCCODE":"1000","MARGIN":0.47}]},{"StartDate":"2014-01-01 00:00:00.0","EndDate":"2015-07-31 00:00:00.0","MARGINSUMDATALIST":[{"STATE":"DE","WCCODE":"0882","MARGIN":14006.28},{"STATE":"DE","WCCODE":"0951","MARGIN":780.42},{"STATE":"DE","WCCODE":"0953","MARGIN":6084.99},{"STATE":"DE","WCCODE":"1000","MARGIN":12.66},{"STATE":"MD","WCCODE":"0882","MARGIN":899.77},{"STATE":"MD","WCCODE":"1000","MARGIN":0.47},{"STATE":"WA","WCCODE":"1200","MARGIN":0.47}]}]}';    
        Test.setMock(HttpCalloutMock.class, new WorkCompCalloutClass_Mock('','',''));
        WorkCompComponentController controller=new WorkCompComponentController();
        controller.accountExternalID ='900022';
        controller.contractDate =Date.today().addDays(45);
        controller.getCompValues();
        // System.assert(controller.XmodHistoryTable != null);
        //System.assert(controller.CLAIMSDATA != null);
        //System.assertEquals(0, controller.CLAIMSDATA.get('YTD').ClaimsDataList[0].LTCLAIMS);
        //System.assertEquals(0, controller.CLAIMSDATA.get('YTD').ClaimsDataList[0].LTINCURRED);
        //System.assertEquals(5, controller.CLAIMSDATA.get('YTD').ClaimsDataList[0].MOCLAIMS);
        //System.assertEquals(6479.17, controller.CLAIMSDATA.get('YTD').ClaimsDataList[0].MOINCURRED);
        //System.assertEquals(0, controller.CLAIMSDATA.get('YTD').ClaimsDataList[0].FAIDCLAIMS);
        //System.assertEquals(0, controller.CLAIMSDATA.get('YTD').ClaimsDataList[0].FAIDINCURRED);
        //System.assertEquals(0, controller.CLAIMSDATA.get('YTD').ClaimsDataList[0].OPENCLAIMS);
        //System.assertEquals(5, controller.CLAIMSDATA.get('YTD').ClaimsDataList[0].TOTALCLAIMS);  
        // System.assert(controller.SafetyIncentiveData != null);
        // System.assertEquals(86078.62, controller.SafetyIncentiveData.get('YTD').EligiblePR);
        // System.assertEquals('2017-01-01 00:00:00.0', controller.SafetyIncentiveData.get('YTD').StartDate);
        // System.assertEquals('2017-12-31 00:00:00.0', controller.SafetyIncentiveData.get('YTD').EndDate);
        // System.assertEquals(895.22, controller.SafetyIncentiveData.get('YTD').MaxSI);
        // System.assertEquals(19390.9, controller.SafetyIncentiveData.get('YTD').Losses);
        // System.assertEquals(925, controller.SafetyIncentiveData.get('YTD').ProfServices);
        // System.assertEquals(0, controller.SafetyIncentiveData.get('YTD').ModWork);
        // System.assertEquals(-19420.68, controller.SafetyIncentiveData.get('YTD').SIEarned);
        // System.assertEquals(0, controller.SafetyIncentiveData.get('YTD').AmountPaid);
        // System.assertEquals('InYear', controller.SafetyIncentiveData.get('YTD').Status);
        
        //System.assert(controller.RiskAnalysisLTDTable != null);
        //System.assert(controller.RiskAnalysisYTDTable != null);
        //System.assert(controller.RiskAnalysisPY1Table != null);
        //System.assert(controller.RiskAnalysisPY2Table != null);

    }
    
}