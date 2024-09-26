public with sharing class WorkCompComponentController {
    
    public String accountExternalID {get;set;}
    public String ErrorStatus{get;set;}
    public Date contractDate  {get;set;}
    public Date contractStartDate  {get;set;}
    public Integer wcran {get; set;}
    public Integer currentContractYear  {get;set;}
    public String SIRunDate {get;set;}
    public List<Integer> RiskClaimsMapKeys;
    
    public transient List<XmodHistoryWrapper> XmodHistoryTable {get; set;}

    public transient Map<Integer,WorkCompRenewalsDataModel.RiskClaimsListItem> RiskClaimsMap {get; set;}
    public transient Map<String, XmodHistory.XmodData> XmodData {get; set;}
    public transient Map<String, SafetyIncentiveSummary.DATA> SafetyIncentiveData {get; set;}
    
    //years of history NOT including LTD (lifetime to date)
    private final Integer MAXROWS_CLAIMS_HISTORY = 5;
    
    // constructor
    public WorkCompComponentController() {
        wcran = 0;
    }
    
    public PageReference getCompValues(){
        //accountExternalID = '903629'; //'901550'
        System.debug('*** getting marginanalysis Detail getValues with ***>>' + accountExternalID + 'and contractDate -' + contractDate );
        if (contractDate.year() >= System.today().year()){
            currentContractYear = contractDate.year();
        } else {
            currentContractYear = System.today().year();
        }

        Integer client = Integer.valueOf(accountExternalID);
        System.debug('*** currentContractYear' + currentContractYear + ' Client:' + accountExternalID);
        WorkCompRenewalsDataModel obj = new WorkCompRenewalsDataModel(client, contractDate); 
        
        wcran = wcran+1;
        if (wcran == 1)
        {
            obj.GetData();
            System.debug ('obj.StatusMsg returned:' + obj.StatusMsg);
            if (obj.StatusMsg != 'OK')   
            {    
                ErrorStatus =  obj.StatusMsg;
                System.debug ('obj.StatusMsg:' + obj.StatusMsg + ' *** currentContractYear' + currentContractYear + ' Client:' + accountExternalID);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, obj.StatusMsg + ' Client:' + accountExternalID));
            } 
            else
            {   
                XmodHistory XmodHistoryObj = obj.XmodHist;
                SafetyIncentiveSummary SafetyIncentiveObj = obj.SafetyIncentiveSum;
                RiskClaimsMap = obj.RiskClaimsMap;
                System.debug('RiskClaimsMap before Keys: ' + RiskClaimsMap.keySet());
                System.debug('RiskClaimsMap befor Vals: ' + RiskClaimsMap.values());
                RiskClaimsMapKeys = new List<Integer>(RiskClaimsMap.keySet());
                RiskClaimsMapKeys.sort();

                //Don't exceed MAXROWS, remove some rows if necessary
                if(RiskClaimsMap.size() > MAXROWS_CLAIMS_HISTORY + 1){
                    Integer mapSize = RiskClaimsMap.size();
                    for(Integer i = 1; i < mapSize - (MAXROWS_CLAIMS_HISTORY); i++ ){
                        RiskClaimsMap.remove(RiskClaimsMapKeys[i]);
                    }
                }
                System.debug('RiskClaimsMap after Keys: ' + RiskClaimsMap.keySet());
                System.debug('RiskClaimsMap after Vals: ' + RiskClaimsMap.values());
                
                XmodData = new Map<String, XmodHistory.XmodData>();
                XmodHistoryTable = new List<XmodHistoryWrapper>() ;
                processXmodData(XmodHistoryObj);
                
                SafetyIncentiveData = new Map<String, SafetyIncentiveSummary.DATA>();
                processSafetyIncentiveData(SafetyIncentiveObj);
            }
        }
        return null;
    }
    
    //filling process SafetyIncentiveData
    public void processSafetyIncentiveData(SafetyIncentiveSummary SafetyIncentiveObj)
    {
        SafetyIncentiveData.clear();
        SIRunDate = SafetyIncentiveObj.RunDate;

        //YTD adjustment
        SafetyIncentiveData.put('YTD', SafetyIncentiveObj.DataList[0]);
        SafetyIncentiveData.put('PY1', SafetyIncentiveObj.DataList[1]);
        SafetyIncentiveData.put('PY2', SafetyIncentiveObj.DataList[2]);
        SafetyIncentiveData.put('PY3', SafetyIncentiveObj.DataList[3]);
        SafetyIncentiveData.put('PY4', SafetyIncentiveObj.DataList[4]);
    }
    
    //filling process XmodData
    public void processXmodData(XmodHistory XmodHistoryObj)
    {
        XmodData.clear();
        
        //YTD adjustment
        XmodData.put ('YTD', XmodHistoryObj.DATALIST[0]);
        XmodData.put ('PY1',  XmodHistoryObj.DATALIST[1]);
        XmodData.put ('PY2', XmodHistoryObj.DATALIST[2]);
        System.debug('XmodHistoryObj --' + XmodHistoryObj);
        
        //use xmodhistory wrapper
        //build the first fill in xmodhistoryTable with YTD data
        for (XmodHistory.XmodSummary YtdData : XmodHistoryObj.DATALIST[0].XMODLIST)
        {

            System.debug('in Process data YTD xmode --' + YtdData);
            XmodHistoryWrapper TheXmodHistory= new XmodHistoryWrapper();        
            TheXmodHistory.STATE = YtdData.STATE;
            TheXmodHistory.CurrentContractYTDXmode = YtdData.XMOD;
            
            XmodHistoryTable.add(TheXmodHistory);
        }
        //system.debug('XmodHistoryTable --' + XmodHistoryTable); 
        
        
        //PY1
        for (XmodHistory.XmodSummary PY1Data : XmodHistoryObj.DATALIST[1].XMODLIST)
        {
            Boolean match = false;
            for(XmodHistoryWrapper XmodHistory: XmodHistoryTable)
            {
                if ( XmodHistory.STATE == PY1Data.STATE)
                {
                    XmodHistory.PreContractY1Xmode = PY1Data.XMOD;
                    match = true;
                }
                
            }
            if( match == false)
            { 
                XmodHistoryWrapper TheXmodHistoryPY1= new XmodHistoryWrapper();        
                TheXmodHistoryPY1.STATE = PY1Data.STATE.trim();
                TheXmodHistoryPY1.PreContractY1Xmode =PY1Data.XMOD;
                  if (( TheXmodHistoryPY1.STATE != 'none') && (TheXmodHistoryPY1.STATE != '' ))
                {
                    XmodHistoryTable.add(TheXmodHistoryPY1); //add the extra line with its state and wccode for PY1  
                }
            }
        }
        
        //PY2
        for (XmodHistory.XmodSummary PY2Data : XmodHistoryObj.DATALIST[2].XMODLIST)
        {
            Boolean match = false;
            for(XmodHistoryWrapper XmodHistory: XmodHistoryTable)
            {
                if ( XmodHistory.STATE == PY2Data.STATE)
                {
                    XmodHistory.PreContractY2Xmode = PY2Data.XMOD;
                    match = true;
                }
                
            }
            if( match == false)
            { 
                XmodHistoryWrapper TheXmodHistoryPY2= new XmodHistoryWrapper();        
                TheXmodHistoryPY2.STATE = PY2Data.STATE.trim();
                TheXmodHistoryPY2.PreContractY2Xmode =PY2Data.XMOD;
                if (( TheXmodHistoryPY2.STATE != 'none') && (TheXmodHistoryPY2.STATE != '' ))
                {
                    XmodHistoryTable.add(TheXmodHistoryPY2); //add the extra line with its state and wccode for PY1  
                }
            }
        }
    }
}