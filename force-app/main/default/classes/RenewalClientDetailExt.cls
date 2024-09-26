/*******************************************************************
* Extension controller for the RenewalClientDetail visualforce page.
* Manages the lists of contacts and accounts associated with the
* renewals managed by the standard controller.
* first release 5.9.2017
* currently in release 5
*******************************************************************/
public without sharing class RenewalClientDetailExt
{
    public String Sname { get; set; }
    public String Clonename { get; set; }
    public String errorMessage { get; set; }
    public String errorCloneMessage { get; set; }
    public String ErrorStatus { get; set; }
    public Map<String, String>ResourceHelpStringMap { get; set; }
    public MapWrapper aMapWrapper { get; set; }

    public Date contractDate { get; set; }
    public List<Account> accounts;
    public List<PricingScenario__c> PricingScenarios;
    public String SelectedScenarioId { get; set; }

    private Id RenewalId;
    private Renewal__c rn;
    private Map<String, PricingDataModel> m_pricingModel_map;
    private Map<String, WorkCompRenewalsDataModel> m_workCompModel_map;
    private Map<String, PricingScenarioDataModel> m_pricingScenarioDataModel_map;
    private Map<String, PricingSummaryDataModel> m_pricingSummaryDataModel_map;

    public Boolean allowEditOfStatus { get; set; } //class level variable
    public Boolean allowedCreateSN { get; set; } //allow to create a scenario
    public Boolean displayPopup { get; set; }
    public Boolean m_bDisplayTabs { get; set; }

    /*
      New code for the creation of client pricing scenarios
    */
    public Boolean m_bMoreClientsToProcess { get; set; }
    public Integer m_iClientCounter { get; set; } { m_iClientCounter = 0; }
    public PricingScenario__c m_psNewPricingScenario;

    public void closePopup() {
        displayPopup = false;
    }
    public void showPopup() {
        displayPopup = true;
    }

    private void loadresourcestringMap()
    {
        aMapWrapper  = new MapWrapper();
        ResourceHelpStringMap = new Map<String, String>();
        String_Resource__mdt[] strings = [SELECT MasterLabel, StringValue__c FROM String_Resource__mdt WHERE App_Group__c = 'Renewal'];

        for(String_Resource__mdt item : strings){
            ResourceHelpStringMap.put(item.MasterLabel, item.StringValue__c);
            aMapWrapper.put('helpmap',ResourceHelpStringMap);
        }
    }

    // checkRenewalStatus
    // this function will determine whether the creation of pricing scenario - dependent on the renewal status
    // if renewal status is Completed, Terminated, or Incomplete users cannot create a new pricing scenario
    // else user can create a new pricing scenario
    public void checkRenewalStatus()
    {
        if (rn.Status__c == 'Completed' || rn.Status__c == 'Terminated' || rn.Status__c == 'Incomplete')
        {
            allowedCreateSN = false;
        }
        else
        {
            allowedCreateSN = true;
        }
    }

    // setStatusEdit
    // called from constructor of extension controller
    // Function purpose: to determine what profiles/roles that can modify renewal status (i.e.: New, Terminated, Completed)
    // allowEditOfStatus = true - can modify renewal status (drop down list)
    // allowEditOfStatus = false - can NOT modify renewal status (text field)
    public void setStatusEdit()
    {
        List<PermissionSetAssignment> permissionSets = [
            SELECT Id, PermissionSet.Name, AssigneeId, PermissionSetId, PermissionSet.Label
            FROM PermissionSetAssignment
            WHERE PermissionSet.Name = 'Renewals_Status_Edit' and AssigneeId =: UserInfo.getUserId()
            LIMIT 1];

        allowedCreateSN = false;
        allowEditOfStatus = Profile_Service.mayConfigure(UserInfo.getProfileId()) || (permissionSets.size() == 1);
    }

    public RenewalClientDetailExt(ApexPages.StandardController stdCtrl)
    {
        m_bDisplayTabs = false;
        String displayParam = ApexPages.currentPage().getParameters().get('loadTabs');
        if(displayParam != null)
        {
            m_bDisplayTabs = Boolean.valueOf(displayParam);
        }
        RenewalId = stdCtrl.getId();
        rn = (Renewal__c)stdCtrl.getRecord();
        setStatusEdit();
        checkRenewalStatus();
        loadresourcestringMap();
    }

    public void enabledLogging()
    {
        Log.info('Renewals', 'Opened Renewal', rn.Name +' (' + rn.Id + ')' );
    }

    public List<Account> getAccounts(){
        accounts =
        [
                SELECT Id, Name,Business_Unit__r.Name, Business_Unit__r.Id, External_ID__c,Start_Date__c, BillingStreet,BillingCity,
                Collective_Tier__c,Collective_Tier_Change_Reason__c,HR_Tier__c,HR_Tier_Change_Reason__c,PR_Tier__c, PR_Tier_Change_Reason__c,Risk_Tier__c,Risk_Tier_Change_Reason__c,
                BillingState,BillingPostalCode, Renewal__r.Id, Renewal_Date__c, Location_Primary_Contact__c,Assigned_Referral_Partner__r.Name , Business_Development_Manager__r.Name,
                Primary_Contact_Name__c,
                (SELECT Id, Name, Primary__c, Title, MailingAddress, MobilePhone, Phone, OtherPhone, Direct__c, Email FROM Contacts WHERE Active__c = TRUE),
                (SELECT Id, Name, Status__c, CreatedDate, LastModifiedDate FROM Tier_Management__r),
                (SELECT AccountId, Field, OldValue, NewValue FROM Histories),
                (
                        SELECT Name, Term_Date__c, External_ID__c, Work_Comp_Policy__r.Name, Work_Comp_Policy__r.External_ID__c
                        FROM WorkCompPolicyAccounts__r
                        WHERE Term_Date__c <= :rn.Renewal_Date_Add_1__c
                        ORDER BY Term_Date__c DESC
                        LIMIT 1
                )
                FROM Account
                WHERE Renewal__r.Id = :RenewalId ORDER BY Renewal_Date__c];
        return accounts;
    }

    public List<PricingScenario__c> GetPricingScenarios(){
        LoadData();
        return PricingScenarios;
    }

    private void LoadData()
    {
        PricingScenarios = [
                SELECT Id, Name, CreatedDate__c, LastModifiedDate__c, ScenarioName__c, Status__c, Renewal__c
                FROM PricingScenario__c
                WHERE Renewal__r.Id =: RenewalId
                ORDER BY CreatedDate__c
        ];
    }

    private void Wait(Integer delayMs)
    {
        Long startingTime = System.now().getTime();
        while (System.now().getTime() - startingTime < delayMs)  {
            // Do nothing until desired delay has passed
        }
    }

    public PageReference newClientScenario()
    {
        Integer count = 0;
        while(m_psNewPricingScenario == null || m_psNewPricingScenario.Id == null || m_psNewPricingScenario.FEIN__c == null
                || m_psNewPricingScenario.Renewal__r == null || m_psNewPricingScenario.Renewal__r.Renewal_Date__c == null)
        {
            count++;
            if(count > 10)
            {
                String errorMessage = 'An error occurred while creating the Pricing Scenario, please try again';
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,  errorMessage));
                break;
            }
            Wait(1000);
            m_psNewPricingScenario = [
                    SELECT  ScenarioName__c, Status__c, FEIN__c, Renewal__c, Renewal__r.Id,
                            Renewal__r.Renewal_Date__c, Renewal__r.Renewal_Date_Add_1__c
                    FROM    PricingScenario__c
                    WHERE   Renewal__c = :RenewalId AND ScenarioName__c = :Sname
                    LIMIT   1
            ];
        }


        Account client = accounts[m_iClientCounter];
        Date renewalDate = m_psNewPricingScenario.Renewal__r.Renewal_Date__c;
        PricingScenarioDataModel psDataModel = new PricingScenarioDataModel(Integer.valueOf(client.External_ID__c), renewalDate);
        PricingSummaryDataModel psSummaryModel = new PricingSummaryDataModel(Integer.valueOf(client.External_ID__c), renewalDate, m_psNewPricingScenario.FEIN__c);
        PricingDataModel prDataModel = new PricingDataModel(Integer.valueOf(client.External_ID__c), renewalDate);

        psDataModel.GetData();
        psSummaryModel.GetData();
        prDataModel.GetData();

        ClientPricingScenarioBuilder cpsBuilder = new ClientPricingScenarioBuilder();
        cpsBuilder.BuildClientPricingScenario(m_psNewPricingScenario, psDataModel);
        cpsBuilder.BuildAssociatedTables(psSummaryModel, prDataModel);

        m_iClientCounter ++;
        if(m_iClientCounter >= accounts.size())
        {
            m_bMoreClientsToProcess = false;
        }

        return null;
    }

    // action method to build NewPricingScenario
    public PageReference NewPricingScenario()
    {
        errorMessage ='';

        if (Sname == '') {
            errorMessage ='Please enter a Pricing Scenario name';
        } else if (Sname.contains('#')) {
            errorMessage ='Pricing Scenario name may not contain a \'#\'';
        } else if (! PricingScenarioBuilder.IsNameUnique(Sname, RenewalId) ) {
            errorMessage ='This Pricing Scenario name is already in use. Please try again';
        } else {
            m_iClientCounter = 0;
            m_bMoreClientsToProcess = true;
            PricingScenarioBuilder psBuilder = new PricingScenarioBuilder();
            m_psNewPricingScenario = psBuilder.BuildPricingScenario(Sname, RenewalId);
        }

        if (errorMessage !='') {
			// Display the error message next to the input fields
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,  errorMessage));
        }

        return null;
    }

    public void DeleteAPricingScenario()
    {
        PricingScenarioService.DeletePricingScenario(SelectedScenarioId);
        LoadData();
    }

    public PageReference showFinancial(){
        m_bDisplayTabs = true;
        return null;
    }

    // action method to build NewPricingScenario
    public PageReference ClonePricingScenario()
    {
        if (!PricingScenarioCloneDirector.IsNameUnique(Clonename, RenewalId) )
        {
            errorCloneMessage ='Enter a unique Pricing Scenario name for this renewal!';
        }
        else
        {
            errorCloneMessage ='';
            PricingScenarioCloneDirector cloneDirector = new PricingScenarioCloneDirector();
            cloneDirector.CloneScenario(Sname, Clonename, RenewalId);
            closePopup();
        }
        return null;
    }
}