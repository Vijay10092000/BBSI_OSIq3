@isTest
public class MarginAnalysisComponentControllerTest {
    
 
 @isTest
    static void MarginAnalysisTest() 
    {
		String marginModelData = getMarginModelData();
        Test.setMock(HttpCalloutMock.class, new GenericMockCallout(200, 'OK', marginModelData, null));
        // Test.setMock(HttpCalloutMock.class, new RenewalCalloutClass_Mock('','','','','',''));
        
        MarginAnalysisComponentController controller=new MarginAnalysisComponentController();
        controller.accountExternalID ='900022'; 
        controller.BDM ='BDM Name';
        controller.BDMStatus ='TRUE';
        controller.ReferralPartner ='ReferralPartner Name';
        controller.contractDate =Date.today().addDays(45);
        controller.contractStartDate =Date.today().addDays(45);
        controller.getCompValues();
        
        Assert.isTrue(controller.MarginAnalysisTable != null);
        // System.debug ('!!!!controller.MarginAnalysisTable!!!' + controller.MarginAnalysisTable.size());
        Assert.areEqual('OR', controller.MarginAnalysisTable[0].State);
        Assert.areEqual('1000', controller.MarginAnalysisTable[0].WCCODE);
        Assert.areEqual(1633.32, controller.MarginAnalysisTable[0].CurrentContractYTDMARGIN);
        Assert.areEqual(-225, controller.BillingAdjustments.get('YTD'));
        Assert.areEqual(-31, controller.SecondaryService.get('YTD'));
        Assert.areEqual(41187.51, controller.TotalGrossMargin.get('YTD'));
        Assert.areEqual(Date.Today().AddDays(45).Year(), controller.currentContractYear);

        String negtestMarginAnalysis = getNegTestMarginAnalysisData();
        Test.setMock(HttpCalloutMock.class, new GenericMockCallout(200, 'OK', marginModelData, null));
        // Test.setMock(HttpCalloutMock.class, new RenewalCalloutClass_Mock(negtestMarginAnalysis,'','','','{"CLIENT":"900005","HASBDM":"FALSE","BDMNAME":"Erik Swanson"}',''));
        controller.accountExternalID ='900022';
        controller.BDM ='BDM Name';
        controller.BDMStatus ='FALSE';
        controller.ReferralPartner ='ReferralPartner Name';
        controller.contractDate =Date.today().addDays(-445);
        controller.getCompValues();
        Assert.areEqual('OR', controller.MarginAnalysisTable[1].State);
        Assert.areEqual('4130', controller.MarginAnalysisTable[1].WCCODE);
        Assert.areEqual(30.79, controller.MarginAnalysisTable[0].PreContractY1MARGIN);
        Assert.areEqual(0, controller.MarginAnalysisTable[0].PreContractY2MARGIN);
        Assert.areEqual('FALSE', controller.BDMStatus);
        
        //Test Error code
        MarginAnalysisComponentController controller1=new MarginAnalysisComponentController();
        Test.setMock(HttpCalloutMock.class, new GenericMockCallout(200, 'ERROR', null, null));
        // Test.setMock(HttpCalloutMock.class, new RenewalCalloutClass_Mock('ERROR','','','','',''));
        controller1.accountExternalID ='900022';
        controller1.BDM ='BDM Name';
        controller1.BDMStatus ='FALSE';
        controller1.ReferralPartner ='ReferralPartner Name';
        controller1.contractDate =Date.today().addDays(-445);
        controller1.getCompValues();
        Assert.areEqual('ERROR', controller1.ErrorStatus);
    }

    private static String getMarginModelData() {
        String retData = '{' 
            + '"BILLINGADJUSTMENTS":{' 
            	+ '"CLIENTID":"905384",' 
            	+ '"DATALIST":[' 
            		+ '{"STARTDATE":"2016-06-08 00:00:00.0","ENDDATE":"2017-06-07 00:00:00.0","BILLINGADJUSTMENTS":-225},' 
            		+ '{"STARTDATE":"2017-06-15 00:00:00.0","ENDDATE":"2017-06-15 00:00:00.0","BILLINGADJUSTMENTS":0},' 
            		+ '{"STARTDATE":"1999-12-31 00:00:00.0","ENDDATE":"2017-06-14 00:00:00.0","BILLINGADJUSTMENTS":-225},' 
            		+ '{"STARTDATE":"2015-06-08 00:00:00.0","ENDDATE":"2016-06-07 00:00:00.0","BILLINGADJUSTMENTS":0},' 
            		+ '{"STARTDATE":"2014-06-08 00:00:00.0","ENDDATE":"2015-06-07 00:00:00.0","BILLINGADJUSTMENTS":0}' 
            	+ ']' 
            + '},' 
            + '"DIRECTEXPENSES":{' 
            	+ '"CLIENTID":"905384",' 
            	+ '"DIRECTEXPENSES":[' 
            		+ '{"STARTDATE":"2016-06-08 00:00:00.0","ENDDATE":"2017-06-07 00:00:00.0","COMMISSIONAMT":5839.91,"PERCENTOFWCBYPAYROLL":0.1,"PERCENTOFPAYROLL":0,"PERCENTOFWC":0,"CESPRPER":0,"MARGINPERCENT":0,"COMMENTS":"added 12/10/2015"},' 
            		+ '{"STARTDATE":"2017-06-15 00:00:00.0","ENDDATE":"2017-06-15 00:00:00.0","COMMISSIONAMT":0,"PERCENTOFWCBYPAYROLL":0,"PERCENTOFPAYROLL":0,"PERCENTOFWC":0,"CESPRPER":0,"MARGINPERCENT":0},' 
            		+ '{"STARTDATE":"1999-12-31 00:00:00.0","ENDDATE":"2017-06-14 00:00:00.0","COMMISSIONAMT":7740.5,"PERCENTOFWCBYPAYROLL":0.1,"PERCENTOFPAYROLL":0,"PERCENTOFWC":0,"CESPRPER":0,"MARGINPERCENT":0,"COMMENTS":"added 12/10/2015"},' 
            		+ '{"STARTDATE":"2015-06-08 00:00:00.0","ENDDATE":"2016-06-07 00:00:00.0","COMMISSIONAMT":1900.59,"PERCENTOFWCBYPAYROLL":0.1,"PERCENTOFPAYROLL":0,"PERCENTOFWC":0,"CESPRPER":0,"MARGINPERCENT":0,"COMMENTS":"added 12/10/2015"},' 
            		+ '{"STARTDATE":"2014-06-08 00:00:00.0","ENDDATE":"2015-06-07 00:00:00.0","COMMISSIONAMT":0,"PERCENTOFWCBYPAYROLL":0,"PERCENTOFPAYROLL":0,"PERCENTOFWC":0,"CESPRPER":0,"MARGINPERCENT":0}' 
            	+ ']' 
            + '},' 
            + '"MARGINDATA":{' 
            	+ '"CLIENTID":"905384",' 
            	+ '"DATALIST":[{' 
            		+ '"StartDate":"2016-06-08 00:00:00.0","EndDate":"2017-06-07 00:00:00.0",' 
            		+ '"MARGINSUMDATALIST":[' 
            			+ '{"STATE":"OR","WCCODE":"1000","MARGIN":1633.32},' 
            			+ '{"STATE":"OR","WCCODE":"4130","MARGIN":6039.01},' 
            			+ '{"STATE":"OR","WCCODE":"5102","MARGIN":5055.82},{"STATE":"OR","WCCODE":"5462","MARGIN":21074.44},{"STATE":"OR","WCCODE":"8380","MARGIN":5980.5},' 
            			+ '{"STATE":"OR","WCCODE":"8742","MARGIN":512.48},{"STATE":"OR","WCCODE":"8810","MARGIN":1147.94}' 
            		+ ']' 
            		+ '},{' 
            			+ '"StartDate":"2017-06-15 00:00:00.0","EndDate":"2017-06-15 00:00:00.0",' 
            			+ '"MARGINSUMDATALIST":[{"STATE":"none","WCCODE":"none","MARGIN":0}]' 
            		+ '},{' 
            			+ '"StartDate":"1999-12-31 00:00:00.0","EndDate":"2017-06-14 00:00:00.0",' 
            			+ '"MARGINSUMDATALIST":[' 
            				+ '{"STATE":"OR","WCCODE":"1000","MARGIN":1664.11},{"STATE":"OR","WCCODE":"4130","MARGIN":8038.65},{"STATE":"OR","WCCODE":"5102","MARGIN":6774.69},' 
            				+ '{"STATE":"OR","WCCODE":"5462","MARGIN":26939.4},{"STATE":"OR","WCCODE":"8380","MARGIN":7878.32},{"STATE":"OR","WCCODE":"8742","MARGIN":673.01},' 
            				+ '{"STATE":"OR","WCCODE":"8810","MARGIN":1538.42}' 
            			+ ']' 
            		+ '},{' 
            			+ '"StartDate":"2015-06-08 00:00:00.0","EndDate":"2016-06-07 00:00:00.0",' 
            			+ '"MARGINSUMDATALIST":[' 
            				+ '{"STATE":"OR","WCCODE":"1000","MARGIN":30.79},{"STATE":"OR","WCCODE":"4130","MARGIN":1999.64},{"STATE":"OR","WCCODE":"5102","MARGIN":1718.87},' 
            				+ '{"STATE":"OR","WCCODE":"5462","MARGIN":5864.96},{"STATE":"OR","WCCODE":"8380","MARGIN":1897.82},{"STATE":"OR","WCCODE":"8742","MARGIN":160.53},' 
            				+ '{"STATE":"OR","WCCODE":"8810","MARGIN":390.48}' 
            			+ ']' 
            		+ '},{' 
            			+ '"StartDate":"2014-06-08 00:00:00.0","EndDate":"2015-06-07 00:00:00.0",' 
            			+ '"MARGINSUMDATALIST":[{"STATE":"none","WCCODE":"none","MARGIN":0}]' 
            		+ '}' 
            	+ ']' 
            + '},' 
            + '"TURNOVER":{' 
            	+ '"CLIENTID":"905384",' 
            	+ '"DATALIST":[' 
            		+ '{"STARTDATE":"2016-06-08 00:00:00.0","ENDDATE":"2017-06-07 00:00:00.0","EEANNUAL":58,"EECURRENT":40},' 
            		+ '{"STARTDATE":"2016-06-16 00:00:00.0","ENDDATE":"2017-06-15 00:00:00.0","EEANNUAL":58,"EECURRENT":40},' 
            		+ '{"STARTDATE":"2016-06-15 00:00:00.0","ENDDATE":"2017-06-14 00:00:00.0","EEANNUAL":58,"EECURRENT":40},' 
            		+ '{"STARTDATE":"2015-06-09 00:00:00.0","ENDDATE":"2016-06-07 00:00:00.0","EEANNUAL":45,"EECURRENT":40},' 
            		+ '{"STARTDATE":"2014-06-08 00:00:00.0","ENDDATE":"2015-06-07 00:00:00.0","EEANNUAL":0,"EECURRENT":10}' 
            	+ ']' 
            + '},' 
            + '"SECONDARYSERVICES":{' 
            	+ '"CLIENTID":"905384",' 
            	+ '"DATALIST":[' 
            		+ '{"STARTDATE":"2016-06-08 00:00:00.0","ENDDATE":"2017-06-07 00:00:00.0","SECONDARYSERVICES":-31},' 
            		+ '{"STARTDATE":"2017-06-15 00:00:00.0","ENDDATE":"2017-06-15 00:00:00.0","SECONDARYSERVICES":0},' 
            		+ '{"STARTDATE":"1999-12-31 00:00:00.0","ENDDATE":"2017-06-14 00:00:00.0","SECONDARYSERVICES":-31},' 
            		+ '{"STARTDATE":"2015-06-08 00:00:00.0","ENDDATE":"2016-06-07 00:00:00.0","SECONDARYSERVICES":0},' 
            		+ '{"STARTDATE":"2014-06-08 00:00:00.0","ENDDATE":"2015-06-07 00:00:00.0","SECONDARYSERVICES":0}' 
            	+ ']' 
            + '},' 
            + '"TAXBURDEN":{' 
            	+ '"CLIENTID":"905384",' 
            	+ '"DATALIST":[' 
            		+ '{"STARTDATE":"2016-06-08 00:00:00.0","ENDDATE":"2017-06-07 00:00:00.0","TotalPayroll":1521838.91,"TotalTaxes":155894.79,"TotalPayrollNo1000":1398931.26,"TotalTaxesNo1000":144254.1},' 
            		+ '{"STARTDATE":"2017-06-15 00:00:00.0","ENDDATE":"2017-06-15 00:00:00.0","TotalPayroll":0,"TotalTaxes":0,"TotalPayrollNo1000":0,"TotalTaxesNo1000":0},' 
            		+ '{"STARTDATE":"1999-12-31 00:00:00.0","ENDDATE":"2017-06-14 00:00:00.0","TotalPayroll":2045806.12,"TotalTaxes":212709.66,"TotalPayrollNo1000":1876211.24,"TotalTaxesNo1000":196057.53},' 
            		+ '{"STARTDATE":"2015-06-08 00:00:00.0","ENDDATE":"2016-06-07 00:00:00.0","TotalPayroll":523967.21,"TotalTaxes":56814.87,"TotalPayrollNo1000":477279.98,"TotalTaxesNo1000":51803.43},' 
            		+ '{"STARTDATE":"2014-06-08 00:00:00.0","ENDDATE":"2015-06-07 00:00:00.0","TotalPayroll":0,"TotalTaxes":0,"TotalPayrollNo1000":0,"TotalTaxesNo1000":0}' 
            	+ ']' 
            + '},' 
            + '"BDM":{"CLIENT":"905384","HASBDM":"TRUE","BDMNAME":" "}' 
        + '}';
        return retData;
    }

    private static String getNegTestMarginAnalysisData() {
        String negtestMarginAnalysis = 
            '{' 
                + '"CLIENTID":"900022",'
                + '"DATALIST":[{'
                    + '"StartDate":"2016-08-01 00:00:00.0","EndDate":"2017-06-21 00:00:00.0",'
                    + '"MARGINSUMDATALIST":['
                        + '{"STATE":"DE","WCCODE":"0882","MARGIN":5452.26},'
                        + '{"STATE":"CA","WCCODE":"0953","MARGIN":1780.25},'
                        + '{"STATE":"MD","WCCODE":"0882","MARGIN":13.73}'
                    + ']'
                + '},'
                + '{'
                    + '"StartDate":"2017-05-09 00:00:00.0","EndDate":"2017-06-21 00:00:00.0",'
                    + '"MARGINSUMDATALIST":['
                        + '{"STATE":"DE","WCCODE":"0882","MARGIN":95.68},'
                        + '{"STATE":"DE","WCCODE":"0953","MARGIN":10.19}'
                    + ']'
                + '},'
                + '{'
                    + '"StartDate":"1999-12-31 00:00:00.0","EndDate":"2017-06-21 00:00:00.0",'
                    + '"MARGINSUMDATALIST":['
                        + '{"STATE":"DE","WCCODE":"0882","MARGIN":38864.72},'
                        + '{"STATE":"DE","WCCODE":"0951","MARGIN":1915.56},'
                        + '{"STATE":"DE","WCCODE":"0953","MARGIN":13366.85},'
                        + '{"STATE":"DE","WCCODE":"1000","MARGIN":-366.68},'
                        + '{"STATE":"MD","WCCODE":"0882","MARGIN":997.05},'
                        + '{"STATE":"MD","WCCODE":"0953","MARGIN":12.2},'
                        + '{"STATE":"MD","WCCODE":"1000","MARGIN":0.47}'
                    + ']'
                + '},'
                + '{'
                    + '"StartDate":"2015-08-01 00:00:00.0","EndDate":"2016-07-31 00:00:00.0",'
                    + '"MARGINSUMDATALIST":['
                        + '{"STATE":"DE","WCCODE":"0882","MARGIN":11023.73},'
                        + '{"STATE":"DE","WCCODE":"0953","MARGIN":2949.31},'
                        + '{"STATE":"OR","WCCODE":"1000","MARGIN":0.47}'
                    + ']'
                + '},'
                + '{'
                    + '"StartDate":"2014-01-01 00:00:00.0","EndDate":"2015-07-31 00:00:00.0",'
                    + '"MARGINSUMDATALIST":['
                        + '{"STATE":"DE","WCCODE":"0882","MARGIN":14006.28},'
                        + '{"STATE":"DE","WCCODE":"0951","MARGIN":780.42},'
                        + '{"STATE":"DE","WCCODE":"0953","MARGIN":6084.99},'
                        + '{"STATE":"DE","WCCODE":"1000","MARGIN":12.66},'
                        + '{"STATE":"MD","WCCODE":"0882","MARGIN":899.77},'
                        + '{"STATE":"MD","WCCODE":"1000","MARGIN":0.47},'
                        + '{"STATE":"WA","WCCODE":"1200","MARGIN":0.47}'
                    + ']'
                + '}'
            + ']'
        + '}';
        return negtestMarginAnalysis;
    }
}