public with sharing class MarginAnalysisComponentController {
    public String accountExternalID {get;set;}
    public String BDM {get;set;}
    public String RealBDM {get;set;}
    public String BDMStatus {get;set;}
    public String ReferralPartner{get;set;}
    public String ErrorStatus{get;set;}
    public Date contractDate  {get;set;}
    public Date contractStartDate  {get;set;} 
    
    public integer ran {get; set;}
    public integer currentContractYear  {get;set;} 
    public Transient List<MarginAnalysisWrapper> MarginAnalysisTable {get; set;}
    public Transient Map<String, Decimal> TotalGrossMargin {get; set;}
    public Transient Map<String, Decimal> BillingAdjustments  {get; set;}
    public Transient Map<String, Decimal> BDMTotal  {get; set;}
    public Transient Map<String, Decimal> ReferralPartners {get; set;}
    public Transient Map<String, Decimal> TotalDirectExpenses {get; set;}
    public Transient Map<String, Decimal> AvgTurnover {get; set;}
    public Transient Map<String, Decimal> grossAfterExpense {get; set;}
    public Transient Map<String, Decimal> NetPerHead {get; set;}
    public Transient Map<String, Decimal> SecondaryService {get; set;}
    public Transient Map<String, Decimal> TotalTaxBurden {get; set;}
    public Transient Map<String, Decimal> TaxBurdenNO1000 {get; set;}

    // constructor
    public MarginAnalysisComponentController() {
        ran = 0;
        System.debug('ran: in construct:' + ran);
        //since there are overdue contractDueDate, we decided always use either current year or the contractdate year which is newer
    }

    public list<MarginAnalysisWrapper> getCompValues(){
        //accountExternalID = '903629'; //'901550'
        System.debug('*** getting marginanalysis Detail getValues with ***>>' + accountExternalID + 'and contractDate -' + contractDate );
        System.debug('*** getting marginanalysis Detail getValues with *** ReferralPartner >>' + ReferralPartner + 'and BDM -' + BDM );
        if (contractDate.year() >= system.today().year())
            currentContractYear = contractDate.year();
        else
            currentContractYear = system.Today().year();

        integer client = integer.valueOf(accountExternalID);
        System.debug('*** currentContractYear' + currentContractYear + ' Client:' + accountExternalID  );
        MarginAnalysisModel obj = new MarginAnalysisModel(client, contractDate);

        ran = ran+1;
        //System.debug('ran: ' + ran +' currentContractYear' + currentContractYear + ' Client:' + accountExternalID  );
        if (ran == 1)
        {
            MarginAnalysisTable = new List<MarginAnalysisWrapper>() ;
            obj.GetData();
            System.debug ('obj.StatusMsg returned:' + obj.StatusMsg);
            if (obj.StatusMsg != 'OK')
            {
                ErrorStatus =  obj.StatusMsg;
                System.debug ('obj.StatusMsg:' + obj.StatusMsg + ' *** currentContractYear' + currentContractYear + ' Client:' + accountExternalID);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, obj.StatusMsg + ' in MarginAnalysisModel with Client:' + accountExternalID));
                System.debug ('MarginAnalysisTable returned:' + MarginAnalysisTable);
            }
            else
            {
                ErrorStatus = obj.StatusMsg;
                //System.debug ('obj.StatusMsg returned -- OK message:' + obj.StatusMsg);
                MarginAnalysisSummary MarginAnalysisObj = obj.MarginAnalysSummary;
                BillingAdjustmentsSummary BillingAdjObj = obj.BillingAdjSummary;
                DirectExpensesSummary DirectExpObj = obj.DirectExpSummary;
                TurnoverSummary TurnoverObj = obj.TurnovrSummary;
                SecondaryServicesSummary SecondaryServiceObj = obj.SecondaryServSummary;
                TaxBurden TaxBurdenSumObj = obj.TaxBurdenSum;

                //accountExternalID = System.currentPageReference().getParameters().get( 'externalID' );
                System.debug('MarginAnalysSummary object -' + MarginAnalysisObj);
                System.debug('obj.TaxBurdenSum' + obj.TaxBurdenSum);
                System.debug('DirectExpensesSummary object -' + DirectExpObj);
                System.debug('TaxBurdenSumObj -' + TaxBurdenSumObj);
                //System.debug('TurnoverSummary object -' + TurnoverObj);
                System.debug('****obj.BdmInfo -' + obj.BdmInfo);
                if (obj.BdmInfo != null)
                {
                	BDMStatus = obj.BdmInfo.HASBDM; //we only use the BDM name from BBSI DataMart 9/7/2017
                }
                else
                    BDMStatus = '';
                if (BDMStatus == 'TRUE')
                    RealBDM = obj.BdmInfo.BDMNAME ;
                else
                    RealBDM = 'N/A';
                System.debug('***BDMStatus --' + BDMStatus);
                TotalGrossMargin = new Map<String, Decimal>();
                BillingAdjustments = new Map<String, Decimal>();
                BDMTotal = new Map<String, Decimal>();
                ReferralPartners = new Map<String, Decimal>();
                TotalDirectExpenses =new Map<String, Decimal>();
                AvgTurnover = new Map<String, Decimal>();
                grossAfterExpense = new Map<String, Decimal>();
                NetPerHead =new Map<String, Decimal>();
                SecondaryService =new Map<String, Decimal>();
                TotalTaxBurden =new Map<String, Decimal>();
                TaxBurdenNO1000 =new Map<String, Decimal>();

                processMarginAnalysis(MarginAnalysisObj);
                processBillingAdjustments(BillingAdjObj);
                processSecondaryService(SecondaryServiceObj);
                processDirectExpenses(DirectExpObj);
                processTurnoverExpenses(TurnoverObj);
                processTaxBurden(TaxBurdenSumObj);
            }
        }

        return MarginAnalysisTable;
    }

    // will putin one json result to process package the viewmodel object
    public void processMarginAnalysis(MarginAnalysisSummary MarginAnalysisObj)
    {
        TotalGrossMargin.clear();
        TotalGrossMargin.put ('YTD', 0);
        TotalGrossMargin.put ('PRJ', 0);
        TotalGrossMargin.put ('LTD', 0);
        TotalGrossMargin.put ('PY1', 0);
        TotalGrossMargin.put ('PY2', 0);

        System.debug(
			LoggingLevel.FINE,
			'MarginAnalysisComponentController.process MarginAnalysisObj' +
			'\nClientid: ' + MarginAnalysisObj.CLIENTID +
			'\nDATES: ' + MarginAnalysisObj.DataList[0].STARTDATE + '-' +  MarginAnalysisObj.DataList[0].ENDDATE +
			'\nMARGIN: ' + MarginAnalysisObj.DataList[0].MarginSumDataList[0].MARGIN +
			'\nData back size: ' + MarginAnalysisObj.DataList.Size() +
			'\nDataList: ' + MarginAnalysisObj.DataList +
			'\nObject: + MarginAnalysisObj'
		);

        //we should have 4 period of Data back at this point

        //build the first MarginAnalysisTable with YTD data
        for (MarginAnalysisSummary.MARGINSUMMARYDATA YTDdata : MarginAnalysisObj.DataList[0].MarginSumDataList)
        {

            System.debug('in Process data YTD data --' + YTDdata);
            MarginAnalysisWrapper theMarginAnalysis = new MarginAnalysisWrapper(YTDdata,  TotalGrossMargin); //with inital MarginAnalysisTable with YTD List and map are passed by reference
            //System.debug('MarginAnalysisWrapper --' + theMarginAnalysis);
            MarginAnalysisTable.add(theMarginAnalysis);
        }
        System.debug('Total Gross Margin:Init ' + TotalGrossMargin);
        System.debug('after YTD init build MarginAnalysisTable --' + MarginAnalysisTable);

        //build the first MarginAnalysisTable with PRJ data
        for (MarginAnalysisSummary.MARGINSUMMARYDATA PRJdata : MarginAnalysisObj.DataList[1].MarginSumDataList)
        {
            //System.debug('in Process PRJ data -- this just addtion:' + PRJdata);
            FillMarginAnalysisTable('PRJ', PRJdata);
        }
        FillEmptyProjectColumn();

        //System.debug('after added PRJ data MarginAnalysisTable --' + MarginAnalysisTable);

        //System.debug ('check on MarginAnalysisObj.DataList[2]' + MarginAnalysisObj.DataList);
        //fill the MarginAnalysisTable with LTD data
        if ( MarginAnalysisObj.DataList.Size() - 2 > 0) //should not need the check as LTD always the thrid period back
        {
            for (MarginAnalysisSummary.MARGINSUMMARYDATA LTDdata : MarginAnalysisObj.DataList[2].MarginSumDataList)
            {
                //System.debug('in Process data LTD--' + LTDdata);
                FillMarginAnalysisTable('LTD', LTDdata);
            }
            //System.debug('after added PY1 data MarginAnalysisTable --' + MarginAnalysisTable);
        }

        //System.debug ('check on MarginAnalysisObj.DataList[2]' + MarginAnalysisObj.DataList);
        //fill the MarginAnalysisTable with PY1 data
        if ( MarginAnalysisObj.DataList.Size() - 3 > 0)
        {
            for (MarginAnalysisSummary.MARGINSUMMARYDATA PY1data : MarginAnalysisObj.DataList[3].MarginSumDataList)
            {
                //System.debug('in Process data --' + PY1data);
                FillMarginAnalysisTable('PY1', PY1data);
            }
            //System.debug('after added PY1 data MarginAnalysisTable --' + MarginAnalysisTable);
        }

        if ( MarginAnalysisObj.DataList.Size() - 4 > 0)
        {
            //fill MarginAnalysisTable with PY2 data
            for (MarginAnalysisSummary.MARGINSUMMARYDATA PY2data : MarginAnalysisObj.DataList[4].MarginSumDataList)
            {
                //System.debug('in Process PY2data data --' + PY2data);
                FillMarginAnalysisTable('PY2', PY2data);

            }
            //System.debug('after added PY2 data MarginAnalysisTable --' + MarginAnalysisTable);
        }

    }

    //fillin BillingAdjustments and update the TotalGrossMargin
    public void processBillingAdjustments(BillingAdjustmentsSummary BillingAdjObj)
    {
        BillingAdjustments.clear();
        BillingAdjustments.put ('YTD', 0);
        BillingAdjustments.put ('PRJ', 0);
        BillingAdjustments.put ('LTD', 0);
        BillingAdjustments.put ('PY1', 0);
        BillingAdjustments.put ('PY2', 0);

        //we should have 5 period of Data back at this point
        //System.debug('BillingAdjObj Data back size:' + BillingAdjObj.DataList.Size());

        //YTD adjustment
        BillingAdjustments.put ('YTD', BillingAdjObj.DataList[0].BILLINGADJUSTMENTS);
        Decimal Total = TotalGrossMargin.get('YTD');
        Total += BillingAdjObj.DataList[0].BILLINGADJUSTMENTS;
        TotalGrossMargin.put('YTD', Total);
        //System.debug('YTD total after Billing Adjustment' + Total +'billadj:' + BillingAdjObj.DataList[0].BILLINGADJUSTMENTS);
        //PRJ adjustment
        BillingAdjustments.put ('PRJ', BillingAdjObj.DataList[0].BILLINGADJUSTMENTS+BillingAdjObj.DataList[1].BILLINGADJUSTMENTS);
        Total = TotalGrossMargin.get('PRJ');
        Total += BillingAdjObj.DataList[0].BILLINGADJUSTMENTS+BillingAdjObj.DataList[1].BILLINGADJUSTMENTS;
        TotalGrossMargin.put('PRJ', Total);
        //System.debug('PRJ total after Billing Adjustment' + Total +'billadj:' + BillingAdjObj.DataList[1].BILLINGADJUSTMENTS);
        //LTD adjustment
        BillingAdjustments.put ('LTD', BillingAdjObj.DataList[2].BILLINGADJUSTMENTS);
        Total = TotalGrossMargin.get('LTD');
        Total += BillingAdjObj.DataList[2].BILLINGADJUSTMENTS;
        TotalGrossMargin.put('LTD', Total);
        //System.debug('LTD total after Billing Adjustment' + Total +'billadj:' + BillingAdjObj.DataList[2].BILLINGADJUSTMENTS);
        //PY1 adjustment
        BillingAdjustments.put ('PY1', BillingAdjObj.DataList[3].BILLINGADJUSTMENTS);
        Total = TotalGrossMargin.get('PY1');
        Total += BillingAdjObj.DataList[3].BILLINGADJUSTMENTS;
        TotalGrossMargin.put('PY1', Total);
        //System.debug('PY1 total after Billing Adjustment' + Total +'billadj:' + BillingAdjObj.DataList[3].BILLINGADJUSTMENTS);
        //PY2 adjustment
        BillingAdjustments.put ('PY2', BillingAdjObj.DataList[4].BILLINGADJUSTMENTS);
        Total = TotalGrossMargin.get('PY2');
        Total += BillingAdjObj.DataList[4].BILLINGADJUSTMENTS;
        TotalGrossMargin.put('PY2', Total);
        //System.debug('PY2 total after Billing Adjustment' + Total +'billadj:' + BillingAdjObj.DataList[4].BILLINGADJUSTMENTS);
        System.debug('Total Gross Margin:BillAdj ' + TotalGrossMargin);

    }

    //fillin processSecondaryService and update the TotalGrossMargin
    public void processSecondaryService(SecondaryServicesSummary SecondaryServiceObj)
    {
        SecondaryService.clear();
        SecondaryService.put ('YTD', 0);
        SecondaryService.put ('PRJ', 0);
        SecondaryService.put ('LTD', 0);
        SecondaryService.put ('PY1', 0);
        SecondaryService.put ('PY2', 0);

        //we should have 5 period of Data back at this point
        //System.debug('BillingAdjObj Data back size:' + BillingAdjObj.DataList.Size());

        //YTD adjustment
        SecondaryService.put ('YTD', SecondaryServiceObj.DataList[0].SECONDARYSERVICES);
        Decimal Total = TotalGrossMargin.get('YTD');
        Total += SecondaryServiceObj.DataList[0].SECONDARYSERVICES;
        TotalGrossMargin.put('YTD', Total);

        //PRJ adjustment
        SecondaryService.put ('PRJ', SecondaryServiceObj.DataList[0].SECONDARYSERVICES+SecondaryServiceObj.DataList[1].SECONDARYSERVICES);
        Total = TotalGrossMargin.get('PRJ');
        Total += SecondaryServiceObj.DataList[0].SECONDARYSERVICES+SecondaryServiceObj.DataList[1].SECONDARYSERVICES;
        TotalGrossMargin.put('PRJ', Total);
        //System.debug('PRJ total after Billing Adjustment' + Total +'billadj:' + BillingAdjObj.DataList[1].BILLINGADJUSTMENTS);
        //LTD adjustment
        SecondaryService.put ('LTD', SecondaryServiceObj.DataList[2].SECONDARYSERVICES);
        Total = TotalGrossMargin.get('LTD');
        Total += SecondaryServiceObj.DataList[2].SECONDARYSERVICES;
        TotalGrossMargin.put('LTD', Total);
        //System.debug('LTD total after Billing Adjustment' + Total +'billadj:' + BillingAdjObj.DataList[2].BILLINGADJUSTMENTS);
        //PY1 adjustment
        SecondaryService.put ('PY1', SecondaryServiceObj.DataList[3].SECONDARYSERVICES);
        Total = TotalGrossMargin.get('PY1');
        Total += SecondaryServiceObj.DataList[3].SECONDARYSERVICES;
        TotalGrossMargin.put('PY1', Total);
        //System.debug('PY1 total after Billing Adjustment' + Total +'billadj:' + BillingAdjObj.DataList[3].BILLINGADJUSTMENTS);
        //PY2 adjustment
        SecondaryService.put ('PY2', SecondaryServiceObj.DataList[4].SECONDARYSERVICES);
        Total = TotalGrossMargin.get('PY2');
        Total += SecondaryServiceObj.DataList[4].SECONDARYSERVICES;
        TotalGrossMargin.put('PY2', Total);
        //System.debug('PY2 total after Billing Adjustment' + Total +'billadj:' + BillingAdjObj.DataList[4].BILLINGADJUSTMENTS);
        System.debug('Total Gross Margin SS: ' + TotalGrossMargin);

    }

    //fillin processTaxBurden
    public void processTaxBurden(TaxBurden TaxBurdenSumObj)
    {
         TotalTaxBurden.clear();
         TotalTaxBurden.put ('YTD', 0);
         TotalTaxBurden.put ('PRJ', 0);
         TotalTaxBurden.put ('LTD', 0);
         TotalTaxBurden.put ('PY1', 0);
         TotalTaxBurden.put ('PY2', 0);

        TaxBurdenNO1000.clear();
        TaxBurdenNO1000.put ('YTD', 0);
        TaxBurdenNO1000.put ('PRJ', 0);
        TaxBurdenNO1000.put ('LTD', 0);
        TaxBurdenNO1000.put ('PY1', 0);
        TaxBurdenNO1000.put ('PY2', 0);

        //we should have 5 period of Data back at this point
        System.debug('TaxBurdenSumObj.DataList:' + TaxBurdenSumObj.DataList);

        //YTD TaxBurden
        if (TaxBurdenSumObj.DataList[0].TotalPayroll <> 0 )
        TotalTaxBurden.put ('YTD', TaxBurdenSumObj.DataList[0].TotalTaxes/TaxBurdenSumObj.DataList[0].TotalPayroll);
        if (TaxBurdenSumObj.DataList[0].TotalPayrollNo1000 <> 0 )
        TaxBurdenNO1000.put ('YTD', TaxBurdenSumObj.DataList[0].TotalTaxesNo1000/TaxBurdenSumObj.DataList[0].TotalPayrollNo1000);

        //PRJ TaxBurden
        if ((TaxBurdenSumObj.DataList[0].TotalPayroll + TaxBurdenSumObj.DataList[1].TotalPayroll) <> 0 )
        TotalTaxBurden.put ('PRJ', (TaxBurdenSumObj.DataList[0].TotalTaxes +TaxBurdenSumObj.DataList[1].TotalTaxes)/(TaxBurdenSumObj.DataList[0].TotalPayroll + TaxBurdenSumObj.DataList[1].TotalPayroll));
        if ((TaxBurdenSumObj.DataList[0].TotalPayrollNo1000 + TaxBurdenSumObj.DataList[0].TotalPayrollNo1000) <> 0 )
        TaxBurdenNO1000.put ('PRJ', (TaxBurdenSumObj.DataList[0].TotalTaxesNo1000 +TaxBurdenSumObj.DataList[1].TotalTaxesNo1000)/(TaxBurdenSumObj.DataList[0].TotalPayrollNo1000 + TaxBurdenSumObj.DataList[1].TotalPayrollNo1000));

        //LTD TaxBurden
        if (TaxBurdenSumObj.DataList[2].TotalPayroll <> 0 )
        TotalTaxBurden.put ('LTD', TaxBurdenSumObj.DataList[2].TotalTaxes/TaxBurdenSumObj.DataList[2].TotalPayroll);
        if (TaxBurdenSumObj.DataList[2].TotalPayrollNo1000 <> 0 )
        TaxBurdenNO1000.put ('LTD', TaxBurdenSumObj.DataList[2].TotalTaxesNo1000/TaxBurdenSumObj.DataList[2].TotalPayrollNo1000);
        //PY1 TaxBurden
        if (TaxBurdenSumObj.DataList[3].TotalPayroll <> 0 )
        TotalTaxBurden.put ('PY1', TaxBurdenSumObj.DataList[3].TotalTaxes/TaxBurdenSumObj.DataList[3].TotalPayroll);
        if (TaxBurdenSumObj.DataList[3].TotalPayrollNo1000 <> 0 )
        TaxBurdenNO1000.put ('PY1', TaxBurdenSumObj.DataList[3].TotalTaxesNo1000/TaxBurdenSumObj.DataList[3].TotalPayrollNo1000);
        //PY2 TaxBurden
        if (TaxBurdenSumObj.DataList[4].TotalPayroll <> 0 )
        TotalTaxBurden.put ('PY2', TaxBurdenSumObj.DataList[4].TotalTaxes/TaxBurdenSumObj.DataList[4].TotalPayroll);
        if (TaxBurdenSumObj.DataList[4].TotalPayrollNo1000 <> 0 )
        TaxBurdenNO1000.put ('PY2', TaxBurdenSumObj.DataList[4].TotalTaxesNo1000/TaxBurdenSumObj.DataList[4].TotalPayrollNo1000);
        System.debug('TotalTaxBurden:' + TotalTaxBurden);
        System.debug('TaxBurdenNO1000:' + TaxBurdenNO1000);
    }

    //fillin processDirectExpenses and update the TotalGrossMargin
    public void processDirectExpenses(DirectExpensesSummary DirectExpObj)
    {
        //fill BDMs
        BDMTotal.clear();
        if (BDMStatus == 'TRUE')
        {
            BDMTotal.put ('YTD', TotalGrossMargin.get('YTD') * 0.05);
            BDMTotal.put ('PRJ', TotalGrossMargin.get('PRJ') * 0.05);
            BDMTotal.put ('LTD', TotalGrossMargin.get('LTD') * 0.05);
            BDMTotal.put ('PY1', TotalGrossMargin.get('PY1') * 0.05);
            BDMTotal.put ('PY2', TotalGrossMargin.get('PY2') * 0.05);
        }
        else
        {
            BDMTotal.put ('YTD', 0.00);
            BDMTotal.put ('PRJ', 0.00);
            BDMTotal.put ('LTD', 0.00);
            BDMTotal.put ('PY1', 0.00);
            BDMTotal.put ('PY2', 0.00);
        }

        //fill ReferralPartners
        ReferralPartners.clear();
        ReferralPartners.put ('YTD', 0);
        ReferralPartners.put ('PRJ', 0);
        ReferralPartners.put ('LTD', 0);
        ReferralPartners.put ('PY1', 0);
        ReferralPartners.put ('PY2', 0);
        //fill TotalDirectExpenses = ReferralPartners + BDMTotal
        TotalDirectExpenses.clear();
        TotalDirectExpenses.put ('YTD', 0);
        TotalDirectExpenses.put ('PRJ', 0);
        TotalDirectExpenses.put ('LTD', 0);
        TotalDirectExpenses.put ('PY1', 0);
        TotalDirectExpenses.put ('PY2', 0);

        //System.debug('in Process ReferralPartners --' + ReferralPartners);

        //YTD TotalDirectExpenses = ReferralPartners + BDMTotal
        ReferralPartners.put ('YTD', DirectExpObj.DirectExpenses[0].COMMISSIONAMT);
        Decimal Total = BDMTotal.get('YTD');
        Total = Total + DirectExpObj.DirectExpenses[0].COMMISSIONAMT;
        TotalDirectExpenses.put('YTD', Total);
        //System.debug('YTD TotalDirectExpenses = ReferralPartners + BDMTotal' + Total +'DirectExpObj:' + DirectExpObj.DirectExpenses[0].COMMISSIONAMT);
        //PRJ TotalDirectExpenses = ReferralPartners + BDMTotal
        ReferralPartners.put ('PRJ', DirectExpObj.DirectExpenses[0].COMMISSIONAMT + DirectExpObj.DirectExpenses[1].COMMISSIONAMT);
        Total = BDMTotal.get('PRJ');
        Total += DirectExpObj.DirectExpenses[0].COMMISSIONAMT + DirectExpObj.DirectExpenses[1].COMMISSIONAMT;
        TotalDirectExpenses.put('PRJ', Total);
        //System.debug('PRJ TotalDirectExpenses = ReferralPartners + BDMTotal' + Total +'DirectExpObj:' + DirectExpObj.DirectExpenses[1].COMMISSIONAMT);
        //LTD TotalDirectExpenses = ReferralPartners + BDMTotal
        ReferralPartners.put ('LTD', DirectExpObj.DirectExpenses[2].COMMISSIONAMT);
        Total = BDMTotal.get('LTD');
        Total = Total + DirectExpObj.DirectExpenses[2].COMMISSIONAMT;
        TotalDirectExpenses.put('LTD', Total);
        //System.debug('LTD TotalDirectExpenses = ReferralPartners + BDMTotal' + Total +'DirectExpObj:' + DirectExpObj.DirectExpenses[2].COMMISSIONAMT);
        //PY1 TotalDirectExpenses = ReferralPartners + BDMTotal
        ReferralPartners.put ('PY1', DirectExpObj.DirectExpenses[3].COMMISSIONAMT);
        Total = BDMTotal.get('PY1');
        Total = Total + DirectExpObj.DirectExpenses[3].COMMISSIONAMT;
        TotalDirectExpenses.put('PY1', Total);
        // System.debug('PY1 TotalDirectExpenses = ReferralPartners + BDMTotal' + Total +'DirectExpObj:' + DirectExpObj.DirectExpenses[3].COMMISSIONAMT);
        //PY2 TotalDirectExpenses = ReferralPartners + BDMTotal
        ReferralPartners.put ('PY2', DirectExpObj.DirectExpenses[4].COMMISSIONAMT);
        Total = BDMTotal.get('PY2');
        Total = Total + DirectExpObj.DirectExpenses[4].COMMISSIONAMT;
        TotalDirectExpenses.put('PY2', Total);
        //System.debug('PY2 TotalDirectExpenses = ReferralPartners + BDMTotal' + Total +'DirectExpObj:' + DirectExpObj.DirectExpenses[4].COMMISSIONAMT);
    }

    //fillin Turnover
    public void processTurnoverExpenses(TurnoverSummary TurnoverObj)
    {
        //AvgTurnover = new Map<String, Decimal>();
        //grossAfterExpense = new Map<String, Decimal>();
        //NetPerHead =new Map<String, Decimal>();
        //fill AvgTurnover
        AvgTurnover.clear();
        AvgTurnover.put ('YTD', 0);
        AvgTurnover.put ('PRJ', 0);
        AvgTurnover.put ('LTD', 0);
        AvgTurnover.put ('PY1', 0);
        AvgTurnover.put ('PY2', 0);

        //fill NetPerHead
        NetPerHead.clear();
        NetPerHead.put ('YTD', 0);
        NetPerHead.put ('PRJ', 0);
        NetPerHead.put ('LTD', 0);
        NetPerHead.put ('PY1', 0);
        NetPerHead.put ('PY2', 0);
        //fill netgross margin after total direct expense = total gross margin - total direct expernses
        grossAfterExpense.clear();
        grossAfterExpense.put ('YTD', 0);
        grossAfterExpense.put ('PRJ', 0);
        grossAfterExpense.put ('LTD', 0);
        grossAfterExpense.put ('PY1', 0);
        grossAfterExpense.put ('PY2', 0);

        System.debug('@@@in Process TurnoverObj --' + TurnoverObj);

        //YTD
        //netgross margin after total direct expense - total gross margin - total direct expernses
        grossAfterExpense.put ('YTD', TotalGrossMargin.get('YTD') - TotalDirectExpenses.get('YTD'));
        //average turnover = (total ssn for a period/ total ees for a period) -1
        //System.debug('in Process TurnoverObj.DataList[0].EEANNUAL --' + TurnoverObj.DataList[0].EEANNUAL + 'TurnoverObj.DataList[0].EECURRENT:'  + TurnoverObj.DataList[0].EECURRENT);

        Decimal total = 0.0;
        if (TurnoverObj.DataList[0].EECURRENT != 0 )
        {
            total =(((TurnoverObj.DataList[0].EEANNUAL * 1.0)/ TurnoverObj.DataList[0].EECURRENT) - 1);
            AvgTurnover.put ('YTD', total);
            System.debug('in Process TurnoverObj --' + 'total ' + total + AvgTurnover);
            //average net per head = net gross after total direct expense/eecurrent
            NetPerHead.put ('YTD', grossAfterExpense.get('YTD') / TurnoverObj.DataList[0].EECURRENT);
        }

        //PRJ
        //netgross margin after total direct expense - total gross margin - total direct expernses
        grossAfterExpense.put ('PRJ', TotalGrossMargin.get('PRJ') - TotalDirectExpenses.get('PRJ'));
        //average turnover = (total ssn for a period/ total ees for a period) -1
        //System.debug('in Process TurnoverObj.DataList[0].EEANNUAL --' + TurnoverObj.DataList[0].EEANNUAL + 'TurnoverObj.DataList[0].EECURRENT:'  + TurnoverObj.DataList[0].EECURRENT);
        total = 0.0;
        if (TurnoverObj.DataList[1].EECURRENT != 0 )
        {
            total =(((TurnoverObj.DataList[1].EEANNUAL * 1.0)/ TurnoverObj.DataList[1].EECURRENT) - 1);
            AvgTurnover.put ('PRJ', total);
            System.debug('in Process TurnoverObj --' + 'total ' + total + AvgTurnover);
            //average net per head = net gross after total direct expense/eecurrent
            NetPerHead.put ('PRJ', grossAfterExpense.get('PRJ') / TurnoverObj.DataList[1].EECURRENT);
        }
        //LTD would be not applied as turnover at this point
        grossAfterExpense.put ('LTD', TotalGrossMargin.get('LTD') - TotalDirectExpenses.get('LTD'));
        //PY1
        //netgross margin after total direct expense - total gross margin - total direct expernses
        grossAfterExpense.put ('PY1', TotalGrossMargin.get('PY1') - TotalDirectExpenses.get('PY1'));
        //average turnover = (total ssn for a period/ total ees for a period) -1
        //System.debug('in Process TurnoverObj.DataList[3].EEANNUAL --' + TurnoverObj.DataList[3].EEANNUAL + 'TurnoverObj.DataList[3].EECURRENT:'  + TurnoverObj.DataList[3].EECURRENT);
        total = 0.0;
        if (TurnoverObj.DataList[3].EECURRENT != 0 )
        {
            total =(((TurnoverObj.DataList[3].EEANNUAL * 1.0)/ TurnoverObj.DataList[3].EECURRENT) - 1);
            AvgTurnover.put ('PY1', total);
            System.debug('in Process TurnoverObj --' + 'total ' + total + AvgTurnover);
            //average net per head = net gross after total direct expense/eecurrent
            NetPerHead.put ('PY1', grossAfterExpense.get('PY1') / TurnoverObj.DataList[3].EECURRENT);
        }

        //PY2
        //netgross margin after total direct expense - total gross margin - total direct expernses
        grossAfterExpense.put ('PY2', TotalGrossMargin.get('PY2') - TotalDirectExpenses.get('PY2'));
        //average turnover = (total ssn for a period/ total ees for a period) -1
        //System.debug('in Process TurnoverObj.DataList[4].EEANNUAL --' + TurnoverObj.DataList[4].EEANNUAL + 'TurnoverObj.DataList[4].EECURRENT:'  + TurnoverObj.DataList[4].EECURRENT);
        total = 0.0;
        if (TurnoverObj.DataList[4].EECURRENT != 0 )
        {
            total =(((TurnoverObj.DataList[4].EEANNUAL * 1.0)/ TurnoverObj.DataList[4].EECURRENT) - 1);
            AvgTurnover.put ('PY2', total);
            //System.debug('in Process TurnoverObj --' + 'total ' + total + AvgTurnover);
            //average net per head = net gross after total direct expense/eecurrent
            NetPerHead.put ('PY2', grossAfterExpense.get('PY2') / TurnoverObj.DataList[4].EECURRENT);
        }

    }

    public void FillEmptyProjectColumn()
    {
        //fill all 0 project column with YTD value and recalculate the PRJ Total
        for(MarginAnalysisWrapper MarginAnalysis: MarginAnalysisTable)
        {
            if (MarginAnalysis.CurrentContractYPrjMARGIN == 0)
            {
                MarginAnalysis.CurrentContractYPrjMARGIN = MarginAnalysis.CurrentContractYTDMARGIN + 0;
                //System.debug('PRJ code found' + MarginAnalysis.STATE +' ' + MarginAnalysis.WCCODE + ' ' + MarginAnalysis.CurrentContractYPrjMARGIN + ' ' +MarginAnalysis.CurrentContractYTDMARGIN );
                Decimal Total = TotalGrossMargin.get('PRJ');
                //add the total for PRJ prjected margin
                Total += MarginAnalysis.CurrentContractYPrjMARGIN;
                TotalGrossMargin.put('PRJ', Total);
                System.debug('Total Gross Margin:FEP ' + TotalGrossMargin);
                //System.debug('PRJ Total - each time' + Total);
            }

        }

    }
    public void FillMarginAnalysisTable(string columntype, MarginAnalysisSummary.MARGINSUMMARYDATA inMarginAnalysis)
    {
        System.debug('FillMarginAnalysisTable for type ' + columntype);

        //projected margin will be add the tyd and pyj value together
        if (columntype == 'PRJ')
        {
            //check the current state and wccode is in MarginAnalysisTable first
            //if it is in them fill in the the column of margin in MarginAnalysisTable
            System.debug('MarginAnalysisWrapper -- inside -PRJ' + inMarginAnalysis);
            Decimal CurrentContractYPrjMARGIN = 0;
            Decimal Total = TotalGrossMargin.get('PRJ');
            if (inMarginAnalysis.MARGIN != null){
                CurrentContractYPrjMARGIN = inMarginAnalysis.MARGIN;
            }

            //List<MarginAnalysisWrapper> MarginAnalysisWrapperList = new List<MarginAnalysisWrapper>();
            for(MarginAnalysisWrapper MarginAnalysis: MarginAnalysisTable)
            {
                if (( MarginAnalysis.STATE == inMarginAnalysis.STATE) && (MarginAnalysis.WCCODE == inMarginAnalysis.WCCODE))
                {
                    MarginAnalysis.CurrentContractYPrjMARGIN = MarginAnalysis.CurrentContractYTDMARGIN + CurrentContractYPrjMARGIN;

                    //add the total for PRJ prjected margin
                    Total += MarginAnalysis.CurrentContractYPrjMARGIN;
                    TotalGrossMargin.put('PRJ', Total);
                    System.debug('Total Gross Margin:FMA ' + TotalGrossMargin);

                    //System.debug('%%%PRJ Total - each time' + Total);
                }

            }

        }

        //file in the data by each columntype
        if (columntype == 'LTD')
        {
            //check the current state and wccode is in MarginAnalysisTable first
            //if it is in them fill in the the column of margin in MarginAnalysisTable
            System.debug('MarginAnalysisWrapper -- inside -LTD' + inMarginAnalysis);
            Decimal ContractLTDMARGIN = 0;
            if (inMarginAnalysis.MARGIN != null)
            {
                ContractLTDMARGIN = inMarginAnalysis.MARGIN;
                Decimal Total = TotalGrossMargin.get('LTD');
                //System.debug('ContractLTDMARGIN' + ContractLTDMARGIN);
                Total += ContractLTDMARGIN;
                TotalGrossMargin.put('LTD', Total);
        System.debug('Total Gross Margin:LTD ' + TotalGrossMargin);
                //System.debug('LTD Total - each time' + Total);
            }

            //List<MarginAnalysisWrapper> MarginAnalysisWrapperList = new List<MarginAnalysisWrapper>();
            boolean match = false;
            for(MarginAnalysisWrapper MarginAnalysis: MarginAnalysisTable)
            {
                if (( MarginAnalysis.STATE == inMarginAnalysis.STATE) && (MarginAnalysis.WCCODE == inMarginAnalysis.WCCODE))
                {
                    MarginAnalysis.ContractLTDMARGIN = ContractLTDMARGIN;
                    System.debug('PY1 code found' + MarginAnalysis.STATE +' ' + MarginAnalysis.WCCODE + ' ' + MarginAnalysis.ContractLTDMARGIN);
                    match = true;
                }

            }
            if( match == false)
            {
                MarginAnalysisWrapper LTDMarginAnalysis = new MarginAnalysisWrapper(inMarginAnalysis.STATE, inMarginAnalysis.WCCODE, 'LTD', ContractLTDMARGIN);
                LTDMarginAnalysis.STATE = inMarginAnalysis.STATE;
                LTDMarginAnalysis.WCCODE = inMarginAnalysis.WCCODE;
                if ( LTDMarginAnalysis.STATE != 'none' )
                {
                    //System.debug('**new marginAnalysis ' + LTDMarginAnalysis.STATE +' ' + LTDMarginAnalysis.WCCODE + ' ' + LTDMarginAnalysis.ContractLTDMARGIN );
                    MarginAnalysisTable.add(LTDMarginAnalysis); //add the extra line with its state and wccode for PY1
                }
            }
            //update  MarginAnalysisTable;      //no need there is no database update
        }


        //file in the data by each columntype
        if (columntype == 'PY1')
        {
            //check the current state and wccode is in MarginAnalysisTable first
            //if it is in them fill in the the column of margin in MarginAnalysisTable
            System.debug('MarginAnalysisWrapper -- inside -PY1' + inMarginAnalysis);
            Decimal PreContractY1MARGIN = 0;
            if (inMarginAnalysis.MARGIN != null)
            {
                PreContractY1MARGIN = inMarginAnalysis.MARGIN;
                Decimal Total = TotalGrossMargin.get('PY1');
                //System.debug('PY1 PreContractY1MARGIN' + PreContractY1MARGIN);
                Total += PreContractY1MARGIN;
                TotalGrossMargin.put('PY1', Total);
        System.debug('Total Gross Margin:PY1 ' + TotalGrossMargin);
                //System.debug('PY1 Total - each time' + Total);
            }

            //List<MarginAnalysisWrapper> MarginAnalysisWrapperList = new List<MarginAnalysisWrapper>();
            boolean match = false;
            for(MarginAnalysisWrapper MarginAnalysis: MarginAnalysisTable)
            {
                if (( MarginAnalysis.STATE == inMarginAnalysis.STATE) && (MarginAnalysis.WCCODE == inMarginAnalysis.WCCODE))
                {
                    MarginAnalysis.PreContractY1MARGIN = PreContractY1MARGIN;
                    //System.debug('PY1 code found' + MarginAnalysis.STATE +' ' + MarginAnalysis.WCCODE + ' ' + MarginAnalysis.PreContractY1MARGIN);
                    match = true;
                }

            }
            if( match == false)
            {
                MarginAnalysisWrapper pY1MarginAnalysis = new MarginAnalysisWrapper(inMarginAnalysis.STATE, inMarginAnalysis.WCCODE, 'PY1', PreContractY1MARGIN);
                pY1MarginAnalysis.STATE = inMarginAnalysis.STATE;
                pY1MarginAnalysis.WCCODE = inMarginAnalysis.WCCODE;
                if ( pY1MarginAnalysis.STATE != 'none' )
                {
                    //System.debug('**new marginAnalysis ' + pY1MarginAnalysis.STATE +' ' + pY1MarginAnalysis.WCCODE + ' ' + pY1MarginAnalysis.PreContractY1MARGIN );
                    MarginAnalysisTable.add(pY1MarginAnalysis); //add the extra line with its state and wccode for PY1
                }
            }

            //update  MarginAnalysisTable;      //no need there is no database update
        }

        // fill PY2 data column
        if (columntype == 'PY2')
        {
            //check the current state and wccode is in MarginAnalysisTable first
            //if it is in them fill in the the column of margin in MarginAnalysisTable
            //System.debug('MarginAnalysisWrapper -- inside -YTD' + inMarginAnalysis);
            Decimal PreContractY2MARGIN = 0;
            if (inMarginAnalysis.MARGIN != null)
            {
                PreContractY2MARGIN = inMarginAnalysis.MARGIN;
                Decimal Total = TotalGrossMargin.get('PY2');
                //System.debug('PY2 PreContractY2MARGIN' + PreContractY2MARGIN);
                Total += PreContractY2MARGIN;
                TotalGrossMargin.put('PY2', Total);
        System.debug('Total Gross Margin:PY2 ' + TotalGrossMargin);
                //System.debug('PY2 Total - each time' + Total);
            }

            //List<MarginAnalysisWrapper> MarginAnalysisWrapperList = new List<MarginAnalysisWrapper>();
            boolean match = false;
            for(MarginAnalysisWrapper MarginAnalysis: MarginAnalysisTable)
            {
                if (( MarginAnalysis.STATE == inMarginAnalysis.STATE) && (MarginAnalysis.WCCODE == inMarginAnalysis.WCCODE))
                {
                    MarginAnalysis.PreContractY2MARGIN = PreContractY2MARGIN;
                    //System.debug('PY2 code found' + MarginAnalysis.STATE +' ' + MarginAnalysis.WCCODE + ' ' + MarginAnalysis.PreContractY2MARGIN);
                    match = true;
                }

            }
            if( match == false)
            {
                MarginAnalysisWrapper pY2MarginAnalysis = new MarginAnalysisWrapper(inMarginAnalysis.STATE, inMarginAnalysis.WCCODE, 'PY2', PreContractY2MARGIN);
                pY2MarginAnalysis.STATE = inMarginAnalysis.STATE;
                pY2MarginAnalysis.WCCODE = inMarginAnalysis.WCCODE;

                if ( pY2MarginAnalysis.STATE != 'none' )
                    MarginAnalysisTable.add(pY2MarginAnalysis); //add the extra line with its state and wccode for PY2

            }

        }

    }

}