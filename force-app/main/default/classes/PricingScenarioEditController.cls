public without sharing class PricingScenarioEditController
{
    // current global value for track the Client PS level
    public PricingScenarioClientWrapper m_wrapPricingScenarioClient {get;set;}

    public list<ClientPricingScenario__c> ClientPricingScenarios;
    public Renewal__c CurrentRenewal {get; set;}
    public string CurrentPSClientid {get; set;}
    public string CurrentPSid {get; set;}
    public boolean displayPopup {get; set;}
    private Id pricingScenarioId;
    private Id renewalId;

    public integer KeyToRemoveNew {get; set;}
    public integer m_intCurrentkey {get; set;} {m_intCurrentkey = 0;}
    public String chosenCurrentId {get; set;} {chosenCurrentId = '';}
    public Map<String, String> ResourceHelpStringMap{get; set;}


    private ApexPages.StandardController thestdCtrl;
    private PricingScenario__c m_objScenarioMain;

    public String keyToDeleteExpense {get; set;}
    public Boolean m_bPEAllowAdd {get; set;} {m_bPEAllowAdd=true;}
    public boolean EditExpsenseMode {get; set;}
    public boolean EditCommissionMode {get; set;}
    public Boolean CMDisableSave {get; set;}
    public Boolean CMAllowAdd {get; set;}
    public Boolean EditClPricScenMode {get; set;}

    public String keyToDeletePayrollTax {get; set;}

    public Boolean trDisableSave {get; set;}
    public Boolean trAllowAdd {get; set;} {trAllowAdd = true;}
    public boolean EditTaxRateMode {get; set;}
    // Pricing Employees
    public String keyToDeleteEmployee {get; set;}

    public Boolean eeDisableSave {get; set;}
    public Boolean eeAllowAdd {get; set;} {eeAllowAdd = true;}
    public Boolean m_bEEAddMode {get;set;}{m_bEEAddMode = false;}
    public boolean EditEEMode {get; set;}
    public string selectedWCCode {get; set;}

    // Pricing Work Comp Codes
    public String keyToDeleteWcCode {get; set;}

    public Boolean wcDisableSave {get; set;}
    public Boolean wcAllowAdd {get; set;}
    public boolean EditWcCodeMode {get; set;}
    public Map<String, Decimal> WCTotals {get; set;} //PayPayRoll WCPremium MaxSI
    // Pricing Work Comp Codes END

    public String keyToDeleteXmod {get; set;}

    public Boolean xmDisableSave {get; set;}
    public Boolean xmAllowAdd {get; set;}
    public boolean editXmodMode {get; set;}

    public Boolean mkDisableSave {get; set;}
    public boolean editMarkupMode {get; set;}
    // Pricing Markup END

    public Boolean m_bHasError{get;set;}{m_bHasError = false;}

    public Map<String,List<PricingSummaryHistory__c>> m_clientPricingHistory{get;set;}
    public Map<String,List<PricingSummaryHistory__c>> m_mapMarginSummary{get;set;}

    public static String m_strSelectedClient {get;set;}
    Map <id,ClientPricingScenario__c> m_mapClientPricing = new map<id,ClientPricingScenario__c>();

    // constructor
    public PricingScenarioEditController(ApexPages.StandardController stdCtrl)
    {
        thestdCtrl = stdCtrl;
        m_objScenarioMain = (PricingScenario__c) thestdCtrl.getRecord();
        pricingScenarioId = ApexPages.currentPage().getParameters().get('id');
        renewalId = ApexPages.currentPage().getParameters().get('renewalid');
        CurrentRenewal = [SELECT id,name, FEIN__c, Owner.name, OwnerId, Renewal_Date__c, Renewal_Date_Add_1__c, Status__c FROM Renewal__c WHERE id  =: renewalId ];
        loadresourcestringMap();
        LoadClients();
    }

    public void enabledLogging() {
        Log.info('Renewals', 'Opened Pricing Scenario', CurrentRenewal.Name +' (' + renewalId + ') Pricing Scenario (' + pricingScenarioId + ')');
        m_wrapPricingScenarioClient.deleteEmployees();
    }

    public void saveScenario()
    {
        m_bHasError = false;
        try
        {
            update m_objScenarioMain;
        }
        catch(Exception e)
        {
            System.debug(LoggingLevel.ERROR, e.getMessage());
            m_bHasError = true;
        }
    }

    private void loadresourcestringMap()
    {
        ResourceHelpStringMap = new map<string, string>();
        String_Resource__mdt[] strings = [SELECT MasterLabel, StringValue__c from String_Resource__mdt where app_group__c = 'Renewal'];

        for(String_Resource__mdt item : strings){
        ResourceHelpStringMap.PUT(item.MasterLabel, item.StringValue__c);
         }
    }

    // method to generate the new tax type options
    public List<SelectOption> getNewTaxOptions()
    {
        List<SelectOption> options=new List<SelectOption>();

        options.add(new SelectOption('LOCAL', 'LOCAL'));
        options.add(new SelectOption('OTHER', 'OTHER'));

        return options;
    }


    public void LoadData()
    {
        loadSinglePricingScenrio(m_mapClientPricing.get(m_strSelectedClient));
    }

    public void LoadClients() {

        String sFirstID;
        //ClientPricingScenario__c table is current year pricing xmod per pricing scenario
        For(ClientPricingScenario__c ClientPricingScenrio : [SELECT id,name, ClientName__c, BDM__c, BDM_Basis__c, BDM_Rate__c, BDM_Rate_Renewal__c,
                                 ClientId__c, commAcronym__c, commBasis__c, commRate__c, commRateRenewal__c, IsProspect__c, rsumComms__c, rsumCommsBdm__c,
                                 rsumBilling__c, rsumErTaxes__c, rsumExpenses__c, rsumMargin__c, rsumMaxSI__c, rsumPayroll__c, rsumWcPrem__c,
                                 ysumBilling__c,ysumComms__c,ysumCommsBdm__c,ysumErTaxes__c,ysumExpenses__c,ysumMargin__c,ysumMaxSI__c, ysumPayroll__c, ysumWcPrem__c,
                                 commCompany__c, Published_Xmod__c, ReferralPartner__c, ReferralPartnerRate__c, Xmod__c
                                 FROM ClientPricingScenario__c WHERE  PricingScenario__r.id =: pricingScenarioId ])
        {
            if(sFirstID == null )sFirstID = ClientPricingScenrio.ID;
            m_mapClientPricing.put(ClientPricingScenrio.ID,ClientPricingScenrio);
        }


        m_strSelectedClient = sFirstID;
        loadSinglePricingScenrio(m_mapClientPricing.get(m_strSelectedClient));
    }

    public list<ClientPricingScenario__c> GetClientPricingScenarios(){
        Return ClientPricingScenarios;
    }

    public List<SelectOption> getClientScenarios()
    {
        List<SelectOption> options = new List<SelectOption>();

        for(ClientPricingScenario__c scen: [SELECT id,name, ClientName__c, ClientId__c, IsProspect__c
                                            FROM ClientPricingScenario__c
                                            WHERE  PricingScenario__r.id =: pricingScenarioId ])
        {
            options.add(new SelectOption( scen.ID, + scen.ClientID__c + ' - ' + scen.ClientName__c));
        }

        return options;
    }

    public void selectedScenarioChange()
    {
        loadSinglePricingScenrio(m_mapClientPricing.get(m_strSelectedClient));
    }

    private void loadSinglePricingScenrio(ClientPricingScenario__c OneClientPricingScenrio)
    {
            this.m_wrapPricingScenarioClient = New PricingScenarioClientWrapper(OneClientPricingScenrio.ID);

            ClientPricingScenarios = new list<ClientPricingScenario__c>();
            ClientPricingScenarios.add(OneClientPricingScenrio);

    }
    //ER TAX
    public PageReference addErTaxItem() {
        trAllowAdd = false;
        m_wrapPricingScenarioClient.addTaxRow();
        return null;
    }

    public PageReference removeErTaxItem() {

        if(m_wrapPricingScenarioClient.deleteTaxRow(keyToDeletePayrollTax))
        {
            loadData();
        }

        return null;
    }

    public PageReference saveErTaxes() {
        m_bHasError = false;
        if(!m_wrapPricingScenarioClient.SaveTaxes())
        {
            m_bHasError = true;
        }
        else
        {
            loadData();
        }
        return null;
    }

    public void DoTaxRateNewRemove() {
        m_wrapPricingScenarioClient.removeNewTaxRow();
        trDisableSave = false;
        trAllowAdd = true;
        return;
    }


    public PageReference DoCancelTaxRate() {
        trDisableSave = false;
        chosenCurrentId=null;
        EditTaxRateMode = false;
        trAllowAdd = true;
        return null;
    }

    public PageReference DoDoneTaxRate(){

        trDisableSave = false;
        chosenCurrentId=null;
        EditTaxRateMode = false;
        trAllowAdd = true;

        return null;
    }
    public void DoTaxRateEdit() {

        trDisableSave = false;
        EditTaxRateMode = true;
        trAllowAdd = false;
        return;
    }

    //Employee functions
    public PageReference addEmployee() {
        m_bEEAddMode = true;
        m_bHasError=false;
        if(!m_wrapPricingScenarioClient.AddEmployee())
        {
            m_bHasError = true;
        }
        else
        {
            chosenCurrentId = m_wrapPricingScenarioClient.m_lstEmployees[m_wrapPricingScenarioClient.m_lstEmployees.size() -1].id;
        }
        return null;
    }

    public PageReference removeEmployee() {


        PricingEmployee__c emp = new PricingEmployee__c(Id = keyToDeleteEmployee);
        m_bHasError = false;
        try
        {
            Delete emp;
            m_wrapPricingScenarioClient.RefreshAndReCalc();
            eeDisableSave = false;
            chosenCurrentId=null;
            editEEMode = false;
            m_bEEAddMode = false;
            loadData();
        }
        catch(Exception e)
        {
            m_bHasError = true;
        }

        return null;
    }

    public PageReference saveEmployees() {
        PageReference result = null;
        m_bHasError = false;
        if(!m_wrapPricingScenarioClient.saveEmployees())
        {
            m_bHasError = true;
        }
        else
        {
            loadData();
            m_bEEAddMode = false;
        }

        Log.info('Renewals', 'Save Employees', CurrentRenewal.Name +' (' + renewalId + ') Client Pricing (' + CurrentPSid + ')');
        chosenCurrentId = null;
        return result;
    }

    public PageReference setWCOnPricingWC()
    {
        m_wrapPricingScenarioClient.m_mapPricingWCCodesByEmployee.get(chosenCurrentId)[0].PricingWcCode__c =
        m_wrapPricingScenarioClient.m_lstEmployees[m_wrapPricingScenarioClient.m_lstEmployees.size() -1].PrimaryPricingWcCode__c;

        return null;
    }

    public PageReference DoCancelEmployee() {
        eeDisableSave = false;
        chosenCurrentId=null;
        editEEMode = false;
        m_bEEAddMode = false;
        return null;
    }

    public void DoEmployeeEdit() {
        eeDisableSave = false;
        editEEMode = true;
        m_bEEAddMode = false;
        return;
    }

    public PageReference DoCancelWcCode() {
        wcDisableSave = false;
        chosenCurrentId=null;
        editWcCodeMode = false;
        wcAllowAdd = true;
        return null;
    }
    public void DoWcCodeEdit() {
        wcDisableSave = true;
        editWcCodeMode = true;
        wcAllowAdd = false;
        return;
    }

    //Start MarkUp
    public PageReference DoCancelMarkup() {
        mkDisableSave = false;
        chosenCurrentId=null;
        editMarkupMode = false;
        return null;
    }
    public void DoMarkupEdit() {
        mkDisableSave = false;
        editMarkupMode = true;
        return;
    }

    public void refreshData(){

        loadData();
    }

    public PageReference saveHist()
    {
        List<PricingSummaryHistory__c> histRecords = m_wrapPricingScenarioClient.m_lstPricingHistory;
        PricingSummaryService m_clsPricingService = new PricingSummaryService(m_wrapPricingScenarioClient.m_objClientScenario.Id);
        m_clsPricingService.GrossMargin = histRecords[0].YendMargin__c;
        loadData();
        return null;
    }

    public PageReference saveMarkup() {
        m_bHasError = false;
        if(!m_wrapPricingScenarioClient.saveWCCodes())
        {
            m_bHasError = true;
        }
        else{
            loadData();
        }

        return null;
    }
    //End markup

    //Start XMod
    public void saveXmods() {
       m_bHasError = false;
       if(!m_wrapPricingScenarioClient.saveXmod())
       {
            m_bHasError = true;
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'There was an error saving the XMODs Table. Please contact your Administrator.'));
       }
       else
       {
            loadData();
       }

    }

    public PageReference DoCancelXmod() {
        xmDisableSave = false;
        chosenCurrentId=null;
        editXmodMode = false;
        xmAllowAdd = true;
        return null;
    }
    public void DoXmodEdit() {
        xmDisableSave = false;
        editXmodMode = true;
        //xmAllowAdd = false;
        return;
    }

    /***
* DoExpsenseRemove - remove usaved added rows of the list
***/
    public void DoExpsenseNewRemove() {
        m_wrapPricingScenarioClient.removeUnSavedExpense();
        m_bPEAllowAdd = true;
        return;
    }

    // add a number of items to the list
    public PageReference addExpenseItems()
    {
        //we will only add one line at a time.
        m_wrapPricingScenarioClient.addServiesAndExpenses();
        m_bPEAllowAdd = false;
        return null;
    }

    // remove (delete) an item from the expense list
    public PageReference removeItemExpense()
    {
        m_bHasError = false;
        if(!m_wrapPricingScenarioClient.deleteExpensesRow(keyToDeleteExpense))
        {
            m_bHasError = true;
        }
        else
        {
            loadData();
        }
        return null;
    }

    public void closePopup() {
        displayPopup = false;
    }
    public void showPopup() {
        displayPopup = true;
    }

    /*
      Start Expense work
    */

    public Boolean PEDisableSave {get; set;}

    public void DoExpenseEdit() {
        PEDisableSave = false;
        EditExpsenseMode = true;
        m_bPEAllowAdd = false;
        return;
    }

    // save the Expense table
    public PageReference saveExpense()
    {
        m_bHasError = false;
        if(!m_wrapPricingScenarioClient.saveServicesAndExpenses())
        {
            m_bHasError = true;
        }
        else
        {
            loadData();
            m_bPEAllowAdd = true;
        }
        return null;
    }

    //DoDoneExpense - change lines back to display mode without any input update
    public PageReference DoDoneExpense() {

        //only for recalculate overalltotal - add instant feedback on the line
        PEDisableSave = false;
        chosenCurrentId=null;
        EditExpsenseMode = false;
        m_bPEAllowAdd = true;
        return null;
    }
    //DoCancel - change lines back to display mode without any input update
    public PageReference DoCancelExpense() {
        PEDisableSave = false;
        chosenCurrentId=null;
        EditExpsenseMode = false;
        m_bPEAllowAdd = true;
        return null;
    }
    //**4** BBSI Services and Expense table END

    //commission expense table
     public void DoCommissionEdit() {
        CMDisableSave = false;
        EditCommissionMode = true;
         return;
    }


    public PageReference DoDoneCommission() {

        CMDisableSave = false;
        m_intCurrentkey =null;
        EditCommissionMode = false;
        return Null;
    }

    public PageReference DoCancelCommission() {
        CMDisableSave = false;
        m_intCurrentkey =null; //used currentkey in commission table
        EditCommissionMode = false;
        return null;
    }

    public PageReference saveCommission()
    {
        m_bHasError = false;
        if(!m_wrapPricingScenarioClient.saveClientPricingScenario())
        {
            m_bHasError = true;
        }
        else
        {
            loadData();
        }
        return null;
    }
     //end commission expesne table
}