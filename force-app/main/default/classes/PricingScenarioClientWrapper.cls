public without sharing class PricingScenarioClientWrapper 
{
    public ClientPricingScenario__c m_objClientScenario {get;set;}
    public List<Integer> m_lstPricingSummary {get;set;}{m_lstPricingSummary = new List<Integer>{0,1};}
    public List<PricingSummaryHistory__c> m_lstPricingHistory {get;set;}
    public Map<String,Map<String,Decimal>> m_mapTotalsByTableByName{get;set;} {m_mapTotalsByTableByName = new Map<String,Map<String,Decimal>>();}
    
    public List<PricingXmod__c> m_lstPricingXmodHistory {get;set;} {m_lstPricingXmodHistory = new List<PricingXmod__c>();}
    public List<PricingXmod__c> m_lstPricingXmod {get;set;} {m_lstPricingXmod = new List<PricingXmod__c>();}
    public List<PricingXmod__c> m_lstPricingXmodPublished {get;set;} {m_lstPricingXmodPublished = new List<PricingXmod__c>();}
    public Boolean m_hasPublishedXmod {get; private set;} {m_hasPublishedXmod = false;}
    private final Integer MAX_PUB_XMODS = 5;

    public List<PricingWcCode__c> m_lstPricingWcCodes {get;set;}
    public List<PricingEmployee__c> m_lstEmployees {get;set;}
    public List<ERPayrollTax__c> m_lstTaxes {get;set;}
    public List<PricingExpense__c> m_lstServices {get;set;}
    public Map<Id,List<PricingEEtoWcCodeAssoc__c>> m_mapPricingWCCodesByEmployee{get;set;}
                {m_mapPricingWCCodesByEmployee = new Map<Id,List<PricingEEtoWcCodeAssoc__c>>();}

    private Id m_strClientScenarioID;
    private Boolean m_bNewEmployeeExists = false;
    public List<PricingEmployee__c> m_lstEmpsToDelete = new List<PricingEmployee__c>();

    public PricingScenarioClientWrapper(Id scenarioID) {
        this.m_strClientScenarioID = scenarioID;
        getClientPricingScenario();
        getXmodData();
        m_lstPricingHistory = getPricingHistory();
        m_lstPricingWcCodes = getWCCodes();
        m_lstEmployees = getEmployees();
        m_lstTaxes = getTaxes();
        m_lstServices = getServiceAndExpenses();
    }

    public void refreshAndRecalc()
    {
        PricingSummaryService m_clsPricingService = new PricingSummaryService(m_objClientScenario.Id);
        m_clsPricingService.Recalculate();
    }
    public Boolean HasBdm {
        get{
            return !String.isBlank(this.m_objClientScenario.BDM__c);
        }
    }
    
    public Boolean HasRefPartner {
        get{
            return !String.isBlank(this.m_objClientScenario.commAcronym__c);
        }
    }

    public Boolean HasReportUrl {
        get{
            return !String.isBlank(this.m_objClientScenario.BureauReportUrl__c);
        }
    }
    public String BureauReportUrl {
        get{
            return this.m_objClientScenario.BureauReportUrl__c;
        }
    }
	public String BureauNumber{
		get{
			if(BureauReportUrl != null && BureauReportUrl.length() > 0){
				String tempStr = BureauReportUrl.replaceAll('[^0-9]','');
				if(tempStr != null){
					return tempStr;
				}
			}
			return '';
		}
	}
    public Boolean saveClientPricingScenario(){
        Boolean bReturn = true;
        try
        {
            upsert m_objClientScenario;
            refreshAndRecalc();
        }
        catch(Exception e)
        {
            bReturn = false;
            if(!ApexPages.hasMessages()){
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'An error occurred while attempting to save this pricing scenario');
                ApexPages.addMessage(msg);
            }
            System.debug('Error saving client clientPricingScenario: ' + e.getMessage() + ' cause: ' + e.getCause());
        }

        return bReturn;
    }
    private void getClientPricingScenario(){
        m_objClientScenario = [SELECT   Id,
                                        Name,
                                        ClientName__c, 
                                        BDM__c, 
                                        BDM_Basis__c, 
                                        BDM_Rate__c, 
                                        BDM_Rate_Renewal__c,
                                        BureauReportUrl__c,  
                                        ClientId__c, 
                                        commAcronym__c, 
                                        commBasis__c, 
                                        commRate__c, 
                                        commRateRenewal__c,
                                        IsProspect__c,
                                        rsumComms__c, 
                                        rsumCommsBdm__c,
                                        rsumBilling__c, 
                                        rsumErTaxes__c, 
                                        rsumExpenses__c, 
                                        rsumMargin__c, 
                                        rsumMaxSI__c, 
                                        rsumPayroll__c, 
                                        rsumWcPrem__c,
                                        ysumBilling__c,
                                        ysumComms__c,
                                        ysumCommsBdm__c,
                                        ysumErTaxes__c,
                                        ysumExpenses__c,
                                        ysumMargin__c,
                                        ysumMaxSI__c, 
                                        ysumPayroll__c, 
                                        ysumWcPrem__c,
                                        commCompany__c, 
                                        Published_Xmod__c, 
                                        ReferralPartner__c, 
                                        ReferralPartnerRate__c, 
                                        Xmod__c 
                                FROM ClientPricingScenario__c 
                                WHERE Id =: m_strClientScenarioID LIMIT 1];
    }

    /*
      Will return the pricing History for a given clientPricingScenario ID
      This method will be private and loaded via tha constructor instead of
      a standard get set as there are values in this table use in many places.
      We don't want the getter running each time we need to access a value in 
      this list.
    */
    private List<PricingSummaryHistory__c> getPricingHistory(){
     
        List<PricingSummaryHistory__c> pricingHistory = [SELECT Id
                                                                ,PeriodStartDate__c
                                                                ,PeriodType__c
                                                                ,PeriodEndDate__c
                                                                ,YendBilling__c
                                                                ,YendBillingNet__c
                                                                ,YendPayroll__c
                                                                ,YendPayrollTaxable__c
                                                                ,YendWcPrem__c
                                                                ,YendComms__c
                                                                ,YendCommsBdm__c
                                                                ,YendCommsTotal__c
                                                                ,YendExpenses__c
                                                                ,YendMargin__c
                                                                ,YendErTaxes__c
                                                                ,BUHours3x__c
                                                                ,BUHours5x__c
                                                                ,YendMaxSI__c
                                                                ,TotalClaims__c
                                                                ,TotalIncurred__c
                                                                ,UltimateExpected__c
                                                                ,MarginPercent__c
                                                                ,MarginPercentPayroll__c
                                                                ,MarkupPercentage__c
                                                                ,MarginPerHead__c 
                                                                ,Xmod__c
                                                                ,Turnover__c
                                                                ,FTE__c
                                                                ,YendTaxBurden_Percent__c
                                                                ,YendTaxBurden_PercentNo1k__c
                                                                ,YendCommissionPercent__c
                                                                ,YendExpenses_Percent__c
                                                        FROM PricingSummaryHistory__c
                                                        WHERE ClientPricingScenario__c =: m_strClientScenarioID
                                                        ORDER BY SortingFormula__c];
        return pricingHistory;
    }
    
    public Boolean saveXmod()
    {
        Boolean bReturn = true;
        try
        {
            upsert m_lstPricingXmod;
            refreshAndRecalc();
        }
        catch(Exception e)
        {
            bReturn = false;
            if(!ApexPages.hasMessages()){
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'An error occurred while trying to save an Xmod value');
                ApexPages.addMessage(msg);
            }
            System.debug('Error saving Xmod__c: ' + e.getMessage() + ' cause: ' + e.getCause());
        }

        return bReturn;
    }

    private void getXmodData()
    {
       for(PricingXmod__c xMod: [ SELECT Id,
                        ClientPricingScenario__c,
                        Published_Xmod__c,
                        State_Code__c,
                        Xmod__c,
                        XmodDate__c,
                        Year__c,
                        IsPricingXmod__c,
                        IsPublishedXmod__c,
                        XmodStatus__c
                        FROM PricingXmod__c
                        WHERE ClientPricingScenario__c =: m_strClientScenarioID
                        ORDER BY State_Code__c, Year__c DESC, XmodDate__c DESC])
        {
            if(xMod.IsPricingXmod__c){
               m_lstPricingXmod.add(xMod);
            }else if(xMod.IsPublishedXmod__c){
                if(m_lstPricingXmodPublished.size() < MAX_PUB_XMODS){
                    m_lstPricingXmodPublished.add(xMod);
                }
            }else{
               m_lstPricingXmodHistory.add(xMod);
            }
        }
        m_hasPublishedXmod = m_lstPricingXmodPublished.size() > 0;
    }

    public Boolean saveWCCodes()
    {
        Boolean bReturn = true;
        try
        {
            upsert m_lstPricingWcCodes;
            this.refreshAndRecalc();
        }
        catch(Exception e)
        {
            bReturn = false;
            if(!ApexPages.hasMessages()){
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'An error occurred while trying to save Work Comp Code changes');
                ApexPages.addMessage(msg);
            }
            System.debug('Error saving Pricing Codes: ' + e.getMessage() + ' cause: ' + e.getCause());
        }

        return bReturn;
    }

    private List<PricingWcCode__c> getWCCodes()
    {
        List<PricingWcCode__c> codes = [
                SELECT Id,
                        ClientPricingScenario__c,
                        AnnualPayInCode__c,
                        AnnualHoursInCode__c, 
                        DesiredMargin__c,
                        DesiredMarginDollars__c,
                        EstimatedErTaxInCode__c,
                        HrpWcSuffix__c,
                        Markup__c,
                        Markup_Blended__c,
                        MarkupNo1k__c,
                        Modified_WC_Rate__c,
                        Pricing_Group__c,
                        SIEligible__c,
                        AnnualPremPayInCode__c,
                        SI_Percent_of_Payroll__c,
                        SI_Percent_of_Premium__c,
                        PercentOfPayroll__c,
                        State_Code__c,
                        SI_Max__c,
                        SI_Max_Blended__c,
                        WC_Code__c, 
                        WcPremiumEquivalent__c,
                        WCPremPercentOfPayroll__c,
                        WcPremiumBlended__c,
                        WcPremiumBlendedPercentOfPayroll__c,
                        WC_Rate__c,
                        (SELECT Id, 
                                AnnualHoursInCode__c, 
                                AnnualPayInCode__c, 
                                AnnualPremPayInCode__c,
                                EstimatedErTaxInCode__c
                                FROM PricingEEtoWcCodeAssocs__r)
                FROM PricingWcCode__c 
                WHERE ClientPricingScenario__c =: m_objClientScenario.Id];

        Decimal DesiredMarginTotal = 0;
        Decimal PayrollInCode = 0;
        Decimal PremiumInCode = 0;
        Decimal WcPremium = 0;
        Decimal MaxSafety = 0;

        for(PricingWcCode__c code: codes)
        {
            DesiredMarginTotal += code.DesiredMarginDollars__c;
            PayrollInCode += code.AnnualPayInCode__c;
            PremiumInCode += code.AnnualPremPayInCode__c;
            WcPremium += code.WcPremiumEquivalent__c;
            MaxSafety += code.SI_Max__c;
        }
        
        m_mapTotalsByTableByName.put('MARKUP',new Map<String,Decimal>{'DSMD'=>DesiredMarginTotal});
        m_mapTotalsByTableByName.put('WORKCOMP', new Map<String,Decimal>{
                                                      'PAYINCODE'=>PayrollInCode,
                                                      'PREINCODE'=>PremiumInCode,
                                                      'WCPRE'=>WcPremium,
                                                      'MISAFE'=>MaxSafety});
        
        return  codes;
    }

    public Boolean addEmployee()
    {
        Boolean bReturn = true;
        m_bNewEmployeeExists = true;
        PricingEmployee__c emp = new PricingEmployee__c(ClientPricingScenario__c = m_objClientScenario.Id, IsActive__c = true);
        try
        {
            insert emp;
            this.m_mapPricingWCCodesByEmployee.put(emp.Id, new List<PricingEEtoWcCodeAssoc__c> { new PricingEEtoWcCodeAssoc__c(Pricing_Employee__c = emp.Id)});
            m_lstEmployees.add(emp);
        }
        catch (Exception e)
        {
            if(!ApexPages.hasMessages()){
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'An error occurred while trying to save an employee record');
                ApexPages.addMessage(msg);
            }
            System.debug('exception ' + e.getMessage() + ' cause: ' + e.getCause());
            bReturn = false;
        } 
    
        return bReturn;
    }

    public Boolean saveEmployees()
    {
        Boolean bReturn = true;
        try
        {
            if(m_lstEmpsToDelete != null && m_lstEmpsToDelete.size() > 0 )
            {
                deleteEmployees();
            }

            upsert m_lstEmployees;
            if(m_mapPricingWCCodesByEmployee != null && m_mapPricingWCCodesByEmployee.size() > 0)
            {
                List<PricingEEtoWcCodeAssoc__c> values = new List<PricingEEtoWcCodeAssoc__c>();
                for(Id emp: m_mapPricingWCCodesByEmployee.keySet())
                {
                    for(PricingEEtoWcCodeAssoc__c acc: m_mapPricingWCCodesByEmployee.get(emp))
                    {
                        acc.AnnualPremPayInCode_base__c = acc.AnnualPayInCode_base__c;
                        acc.AnnualTaxablePayInCode_base__c = acc.AnnualPayInCode_base__c;
                        acc.AnnualPremPayInCode__c = acc.AnnualPayInCode_base__c;
                        acc.AnnualTaxablePayInCode__c = acc.AnnualPayInCode_base__c;
                        acc.AnnualPayInCode__c = acc.AnnualPayInCode_base__c;
                        acc.AnnualHoursInCode__c = acc.AnnualHoursInCode_base__c;
                        values.add(acc);
                    }
                }

                if(values.size() > 0)
                {
                    upsert values;
                }
            }
            //Deleteing empties before recalc

            this.refreshAndRecalc();

        }
        catch(Exception e)
        {
            bReturn = false;
            if(!ApexPages.hasMessages()){
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'An error occurred while saving employee records');
                ApexPages.addMessage(msg);
            }
            System.debug('Error saving Employees: ' + e.getMessage() + ' cause: ' + e.getCause());
        }

        return bReturn;
    }

    public void deleteEmployees()
    {
        if(m_lstEmpsToDelete != null && m_lstEmpsToDelete.size() > 0)
        {
            try
            {
                delete m_lstEmpsToDelete;
            }
            catch(Exception e)
            {
                if(!ApexPages.hasMessages()){
                    ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'An error occurred while trying to delete an employee record');
                    ApexPages.addMessage(msg);
                }
                System.debug('error deleting employees ' + e.getMessage());
            }
        }
    }
    private List<PricingEmployee__c> getEmployees()
    {
        List<PricingEmployee__c>  Employees = [
                SELECT  Id,
                        Employee_Name__c,
                        Qty__c,
                        Pricing_Group__c,
                        Primary_WC_Code__c,
                        State__c,
                        PrimaryPricingWcCode__c,
                        PrimaryPricingWcCode__r.Name,
                        PrimaryPricingWcCode__r.EstimatedErTaxInCode__c,
                        IsActive__c,
                        IsUpdate__c,
                        IsOwner__c,
                        EstimatedERTax__c,
                        ClientPricingScenario__c,
                        AnnualHours__c,
                        AnnualPay__c,
                        AnnualTaxablePay__c,
                        HourlyRate__c,
                        State_Code__c,
                        (
                                SELECT Id, AnnualPayInCode__c, AnnualHoursInCode__c, AnnualPayUnit__c, AnnualHoursUnit__c, EstimatedErTaxInCode__c
                                FROM PricingEEtoWcCodeAssocs__r)
                FROM PricingEmployee__c
                WHERE ClientPricingScenario__c =: m_objClientScenario.Id
        ];

        Map<String,Decimal> mapTotals = new Map<String,Decimal>();
        Decimal PayTotal = 0; // Totals.get ('ANUPAY');
        Decimal ERTaxTotal =0; // Totals.get ('ERTAX');
        Decimal TotalHours = 0;
        //delete blank rows first
        
        for(PricingEmployee__c emp: Employees)
        {
            if(emp.Employee_Name__c == null || emp.Employee_Name__c == '')
            {
                m_lstEmpsToDelete.add(emp);

            }
            else
            {
                PayTotal = PayTotal + (emp.AnnualPay__c == null ? 0: emp.AnnualPay__c);
                ERTaxTotal = ERTaxTotal + (emp.EstimatedERTax__c == null ? 0 : emp.EstimatedERTax__c);
                TotalHours = TotalHours + (emp.AnnualHours__c == null ? 0 : emp.AnnualHours__c);
            }
        }

        for(PricingEmployee__c emp: m_lstEmpsToDelete)
        {
            for(Integer i=0; i< Employees.size(); i++)
            {
                if(Employees[i] == emp)
                {
                    Employees.remove(i);
                    break;
                }
            }
        }
        mapTotals.put('ANUPAY',PayTotal);
        mapTotals.put('ERTAX',ERTaxTotal);
        mapTotals.put('HRSTOT',TotalHours);
        m_mapTotalsByTableByName.put('EMPLOYEE',mapTotals);
        return Employees;
    }
/*
    Start of Tax Items
*/
    public void addTaxRow()
    {
        m_lstTaxes.add(new ERPayrollTax__c(ClientPricingScenario__c = this.m_objClientScenario.Id));
    }

    public void removeNewTaxRow()
    {
         m_lstTaxes.remove(m_lstTaxes.size() -1);
    }

    public Boolean deleteTaxRow(String IdToDelete)
    {
        Boolean bReturn = true;
        ERPayrollTax__c RecToDelete;
        for(ERPayrollTax__c et: m_lstTaxes)
        {
            if(et.Id == IdToDelete)
            {
                RecToDelete = et;
                break;
            }
        }

        if(RecToDelete != null)
        {
            try
            {
                delete RecToDelete;
                this.refreshAndRecalc();
            }
            catch(Exception e)
            {
                bReturn = false;
                if(!ApexPages.hasMessages()){
                    ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'An error occurred while trying to delete a tax record');
                    ApexPages.addMessage(msg);
                }
                System.debug('Error Deleteing tax row: ' + e.getMessage() + ' ' + e.getCause());
            }
        }

        return bReturn;
    }

    public Boolean saveTaxes()
    {
        Boolean bReturn = true;
        try
        {
            upsert m_lstTaxes;
            this.refreshAndRecalc();
        }
        catch(Exception e)
        {
            bReturn = false;
            if(!ApexPages.hasMessages()){
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'An error occurred while trying to save tax records');
                ApexPages.addMessage(msg);
            }
            System.debug('Error saving Taxes: ' + e.getMessage() + ' cause: ' + e.getCause());
        }

        return bReturn;
    }

    private List<ERPayrollTax__c> getTaxes()
    {
        return [SELECT Limit__c, Rate__c, State_Code__c, Non_Profit__c, Tax_Type__c, ClientPricingScenario__c
                          FROM ERPayrollTax__c 
                          WHERE ClientPricingScenario__c =: m_objClientScenario.Id
                          ORDER BY ClientPricingScenario__c, State_Code__c];
    }

/*
    Start of Client Investment (Services and Expenses)
*/
    public Boolean saveServicesAndExpenses()
    {
        Boolean bReturn = true;
        try
        {
            upsert m_lstServices;
            this.refreshAndRecalc();
        }
        catch(Exception e)
        {
            bReturn = false;
            if(!ApexPages.hasMessages()){
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'An error occurred while trying to save expense records');
                ApexPages.addMessage(msg);
            }
            System.debug('Error saving Services and Expenses: ' + e.getMessage() + ' cause: ' + e.getCause());
        }

        return bReturn;
    }

    public void addServiesAndExpenses()
    {
        m_lstServices.add(new PricingExpense__c(ClientPricingScenario__c = m_objClientScenario.Id));
    }

    public void removeUnSavedExpense()
    {
        m_lstServices.remove(m_lstServices.size() - 1);
    }

    public Boolean deleteExpensesRow(String IdToDelete)
    {
        Boolean bReturn = true;
        PricingExpense__c removeRec;
        for(PricingExpense__c exp: m_lstServices)
        {
            if(exp.Id == IdToDelete)
            {
                removeRec = exp;
                break;
            }
        }

        if(removeRec != null)
        {
            try
            {
                delete removeRec;
                this.refreshAndRecalc();
            }
            catch(Exception e)
            {
                if(!ApexPages.hasMessages()){
                    ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'An error occurred while trying to delete expense records');
                    ApexPages.addMessage(msg);
                }
                System.debug('Error deleting expense: ' + e.getMessage() + ' cause: ' + e.getCause());
                bReturn = false;
            }
        }

        return bReturn;
    }

    private List<PricingExpense__c> getServiceAndExpenses(){
        List<PricingExpense__c> lstReturn = [SELECT Id,
                                                    Category__c, 
                                                    Cost_Each__c, 
                                                    Description__c, 
                                                    Quantity__c, 
                                                    Total__c,
                                                    totalcal__c,
                                                    ClientPricingScenario__c 
                                            FROM PricingExpense__c 
                                            WHERE  ClientPricingScenario__c =: m_objClientScenario.Id];
        Decimal totalCost = 0;
        for(PricingExpense__c PricingExpenses : lstReturn)
        {
            totalCost += PricingExpenses.totalcal__c;
        }
        Map<String,Decimal> tempMap = new Map<String,Decimal>();
        tempMap.put('COSTTOTAL',totalCost);
        m_mapTotalsByTableByName.put('SERVICES',tempMap);

        return lstReturn;
    }
}