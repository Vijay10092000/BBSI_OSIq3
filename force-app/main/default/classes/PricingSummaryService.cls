public without sharing class PricingSummaryService {
/*
    Add Refresh and Recalculate method
    Remove auto recalculate on list property set methods
*/
    public static final String MARGIN_HIST_FUTURE = 'Renewal Year';
    public static final String MARGIN_HIST_CURRENT_PROJ = 'Current Projected';
    public static final String MARGIN_HIST_CURRENT_YTD = 'Current YTD';
    public static final String MARGIN_HIST_MINUS_1 = 'Current-1';
    public static final String MARGIN_HIST_LTD = 'LTD';
    public static final Double ANNUAL_FTE_HOURS = 2080;

    private List<PricingEmployee__c> m_Employees;
    private List<PricingWcCode__c> m_WcCodes;
    private List<PricingEEtoWcCodeAssoc__c> m_eeAndWcAssociations;
    private List<PricingExpense__c> m_Expenses;
    private List<PricingClientInvestment__c> m_ClientInvestments;
    private List<ERPayrollTax__c> m_TaxTable;
    private List<PricingXmod__c> m_PricingXmods;
    private ClientPricingScenario__c m_ClientPricingScenario;
    private PricingSummaryHistory__c m_futureRow;
    private Id m_clientPricingScenarioId;
    private Date m_ScenarioCreatedDate;
    private Double m_projectionFactor = 1.0;
    private Double m_totalPayroll = 0;
    private Decimal m_totalTaxablePayrollNo1k = 0;
    private Decimal m_totalTaxablePayroll = 0;
    private Double m_totalCommissions = 0;
    private Double m_totalExpenses = 0;
    private Double m_totalWcPremiums = 0;
    private Double m_totalWcPremiumsBlended = 0;
    private Double m_grossMargin = 0;
    private Double m_erTaxes = 0;
    private Double m_erTaxesNo1k = 0;
    private Boolean m_fromPricingBuilder = false;

    private Map<Id, Double> m_totalTaxInCode = new Map<Id, Decimal>();

    private Boolean m_isDataLoaded
    { get{ return (m_Employees != null && m_WcCodes != null && m_Expenses != null &&
            m_TaxTable != null && m_ClientPricingScenario != null && m_futureRow != null); } }

    public Double ERTaxTotal
    { get{ return CalculateErTaxes(); } }

    public Double GrossMargin{
        get{ return CalculateGrossMargin();}
        set { ApplyGrossMargin(value); }
    }

    public Date RenewalDate
    { get { return m_isDataLoaded ? m_futureRow.PeriodStartDate__c : Date.today(); } }

    public Boolean IsValid
    { get { return m_isDataLoaded; } }

    private Double TotalCommissions
    { get { return m_isDataLoaded ? m_futureRow.YendComms__c + m_futureRow.YendCommsBdm__c : 0; } }

    // constructors
    public PricingSummaryService(ClientPricingScenario__c clientPricingScenario)
    {
        this.m_fromPricingBuilder = false;
        m_clientPricingScenarioId = clientPricingScenario.Id;
        RefreshData();
    }

    public PricingSummaryService(String clientPricingScenarioID)
    {
        this.m_fromPricingBuilder = false;
        this.m_clientPricingScenarioId = clientPricingScenarioID;
        RefreshData();
    }

    public PricingSummaryService(String clientPricingScenarioID, Boolean fromBuilder)
    {
        this.m_fromPricingBuilder = fromBuilder;
        this.m_clientPricingScenarioId = clientPricingScenarioID;
        RefreshData();
    }

    public Boolean RefreshAndRecalculate()
    {
        Boolean result = false;
        result = RefreshData();
        if (result){
            result = Recalculate();
        }
        return result;
    }

    public Boolean RefreshData(){
        Boolean result = true;
        try
        {
            Refresh_ClientPricingScenario();
            Refresh_TaxTable();
            Refresh_WcCodes();
            Refresh_Employees();
            Refresh_Expenses();
            Refresh_PricingXmods();
            Refresh_futureRow();
            m_projectionFactor = GetProjectionFactor(m_ScenarioCreatedDate, this.RenewalDate);
        }
        catch(Exception e)
        {
            System.debug('Refresh Data exception: ' + e);
            result = false;
            throw new RenewalException('An unexpected error occurred while refreshing data');
        }
        return result;
    }

    public void Refresh_ClientPricingScenario()
    {
        m_ClientPricingScenario =
        [
                SELECT  Id, CreatedDate, BDM__c, BDM_Rate__c, BDM_Rate_Renewal__c, ClientId__c, ClientName__c,
                        commAcronym__c, commCompany__c, commRate__c, commRateRenewal__c, IsProspect__c
                FROM ClientPricingScenario__c
                WHERE Id = :m_clientPricingScenarioId
        ];
        m_ScenarioCreatedDate = m_ClientPricingScenario.CreatedDate.date();
    }

    public void Refresh_TaxTable()
    {
        m_TaxTable =
        [
                SELECT Id, Limit__c, Non_Profit__c, Rate__c, State_Code__c, Tax_Type__c
                FROM ERPayrollTax__c
                WHERE ClientPricingScenario__c = :m_clientPricingScenarioId
        ];
    }

    public void Refresh_Employees()
    {
        m_Employees =
        [
                SELECT  Id, Employee_Name__c, Qty__c, Pricing_Group__c, Primary_WC_Code__c, State_Code__c,
                        PrimaryPricingWcCode__c, Name, IsActive__c, IsOwner__c, IsUpdate__c, HourlyRate__c,
                        AnnualHours__c, AnnualTaxablePay__c, AnnualPay__c, AnnualPremPay__c, EstimatedERTax__c, ClientPricingScenario__c,
                (
                        SELECT  Id, AnnualPayInCode__c, AnnualTaxablePayInCode__c, AnnualPayInCode_base__c, AnnualTaxablePayInCode_base__c,
                                AnnualPremPayInCode__c, AnnualPremPayInCode_base__c, AnnualHoursInCode__c, AnnualHoursInCode_base__c,
                                AnnualPayUnit__c, AnnualHoursUnit__c,
                                EstimatedErTaxInCode__c,
                                PricingWcCode__c
                        FROM PricingEEtoWcCodeAssocs__r
                )
                FROM PricingEmployee__c
                WHERE ClientPricingScenario__c = :m_clientPricingScenarioId
        ];
    }

    public void Refresh_WcCodes(){
        m_WcCodes =
        [
                SELECT  Id, AnnualHoursInCode__c, AnnualPayInCode__c, AnnualPremPayInCode__c, AnnualTaxablePayInCode__c,
                        DesiredMargin__c, DesiredMarginDollars__c, EstimatedErTaxInCode__c,
                        Markup__c, Markup_Blended__c, MarkupNo1k__c, PercentOfPayroll__c, SIEligible__c,
                        SI_Max__c, SI_Max_Blended__c, SI_Percent_of_Payroll__c, SI_Percent_of_Premium__c, State_Code__c,
                        WC_Code__c, WcPremiumEquivalent__c, WcPremiumBlended__c, WC_Rate__c, Modified_WC_Rate__c,
                        (
                                SELECT Id, AnnualPayInCode__c, AnnualTaxablePayInCode__c, AnnualPayInCode_base__c, AnnualTaxablePayInCode_base__c,
                                        AnnualPremPayInCode__c, AnnualPremPayInCode_base__c, AnnualHoursInCode__c, AnnualHoursInCode_base__c,
                                        AnnualPayUnit__c, AnnualHoursUnit__c,
                                        EstimatedErTaxInCode__c,
                                        Pricing_Employee__c
                                FROM PricingEEtoWcCodeAssocs__r
                        )
                        FROM PricingWcCode__c
                        WHERE ClientPricingScenario__c = :m_clientPricingScenarioId
        ];
    }

    public void Refresh_Expenses()
    {
        m_Expenses =
        [
                SELECT Id, Category__c, Cost_Each__c, Quantity__c, totalcal__c
                FROM PricingExpense__c
                WHERE ClientPricingScenario__c = :m_clientPricingScenarioId
        ];

        m_ClientInvestments = [
                SELECT Id, Description__c, Method__c, Rate__c, Total_Cost__c
                FROM PricingClientInvestment__c
                WHERE ClientPricingScenario__c = :m_clientPricingScenarioId
        ];
    }

    public void Refresh_PricingXmods()
    {
        m_PricingXmods =
        [
                SELECT Id, IsPricingXmod__c, Published_Xmod__c, State_Code__c, Xmod__c, XmodDate__c, Year__c
                FROM PricingXmod__c
                WHERE ClientPricingScenario__c = :m_clientPricingScenarioId
        ];
    }

    public void Refresh_futureRow()
    {
        PricingSummaryHistory__c [] rows =
        [
                SELECT  Id, IsDeleted, Name, CreatedDate, CreatedById, YendBilling__c,
                        YendComms__c, YendCommsBdm__c, YendCommsTotal__c, YendErTaxes__c,
                        YendExpenses__c, YendMargin__c, YendMaxSI__c, YendPayroll__c, YendWcPrem__c,
                        PeriodStartDate__c, PeriodEndDate__c, BUHours3x__c, BUHours5x__c, PeriodType__c,
                        YendPayrollTaxable__c, SortingFormula__c, Xmod__c, MarginPercent__c,
                        MarkupPercentage__c, Headcount__c, HeadcountAnnual__c, Turnover__c, FTE__c,
                        YendTaxBurden_Percent__c, YendTaxBurden_PercentNo1k__c,
                        YendCommissionPercent__c,YendExpenses_Percent__c
                FROM PricingSummaryHistory__c
                WHERE ClientPricingScenario__c = :m_clientPricingScenarioId
                AND PeriodType__c = :MARGIN_HIST_FUTURE
        ];

        if(rows.size() > 0)
        {
            m_futureRow = rows[0];
        }
    }
    public void SaveSobjects(List<SObject> objList, Boolean allOrNone)
    {
        Database.SaveResult[] srList = Database.update(objList, allOrNone);

        for (Database.SaveResult sr : srList) {
            if (!sr.isSuccess())
            {
                for(Database.Error err : sr.getErrors()) {
                    System.debug('Recalculate SAVE error: ' + err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Account fields that affected this error: ' + err.getFields());
                }
            }
        }
    }

    public Boolean Recalculate()
    {
        if(!m_isDataLoaded)
        {
            return false;
        }

        Boolean result = true;
        Double totalHours = 0;

        try
        {
            if(m_fromPricingBuilder)
            {
                Initialize_SI_Percent();
                CalculateModifiedWcRates();
            }

            m_futureRow.HeadcountAnnual__c = GetAnnualHeadcount();
            m_futureRow.Headcount__c = GetCurrentHeadcount();
            totalHours = CalculateHoursInCode();
            m_futureRow.FTE__c = ((Decimal)totalHours / PricingSummaryService.ANNUAL_FTE_HOURS).setScale(1);

            m_futureRow.YendPayroll__c = CalculatePayroll();
            m_futureRow.YendPayrollTaxable__c = CalcTaxablePayroll();
            m_futureRow.YendPayrollTaxableNoOwner__c = m_totalTaxablePayrollNo1k;
            m_futureRow.YendErTaxes__c = CalculateErTaxes();
            m_futureRow.YendErTaxesNoOwner__c = m_erTaxesNo1k;

            CalculateErTaxesInCode();
            CalcPremBasedPayroll();

            m_futureRow.YendTaxBurden_Percent__c = CalcTaxBurdenPercent();
            m_futureRow.YendTaxBurden_PercentNo1k__c = CalcTaxBurdenPercentNo1k();

            m_futureRow.YendWcPrem__c = CalculateWcPremiums();
            m_futureRow.YendWcPrem_base__c = m_totalWcPremiumsBlended;
            m_futureRow.YendMargin__c = CalculateGrossMargin();
            m_futureRow.YendMaxSI__c = CalculateMaxSi();
            m_futureRow.YendExpenses__c = CalculateExpenses();

            m_futureRow.YendComms__c = CalculateCommissions();
            m_futureRow.YendCommsBdm__c = CalculateCommissionsBdm();
            m_totalCommissions = m_futureRow.YendComms__c + m_futureRow.YendCommsBdm__c;

            m_futureRow.YendExpenses_Percent__c = CalcExpensesPercent();
            m_futureRow.YendCommissionPercent__c = CalcCommissionsPercent();

            ApplyMarkup();

            m_futureRow.YendBilling__c = CalculateBilling();
            m_futureRow.YendBillingAdjustments__c = 0; // future row can't have billing adjustments!

            // for this case, we don't select by state code
            m_futureRow.Xmod__c = GetXmodForPricing('');

            // put junction objects into their own list, so they get saved
            m_eeAndWcAssociations = new List<PricingEEtoWcCodeAssoc__c>();
            for(PricingEmployee__c eeItem : m_Employees){
                for(PricingEEtoWcCodeAssoc__c jItem : eeItem.PricingEEtoWcCodeAssocs__r){
                    m_eeAndWcAssociations.add(jItem);
                }
            }

            Database.SaveResult[] srList = Database.update(m_eeAndWcAssociations, false);
            srList.addAll(Database.update(m_ClientInvestments, false));
            srList.addAll(Database.update(m_WcCodes, false));
            srList.addAll(Database.update(m_Employees, false));
            srList.add(Database.update(m_futureRow, false));
            srList.add(Database.update(m_ClientPricingScenario, false));

            for (Database.SaveResult sr : srList) {
                if (!sr.isSuccess())
                {
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('Recalculate SAVE error: ' + err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Account fields that affected this error: ' + err.getFields());
                    }
                result = false;
                }
            }
        }
        catch(Exception e)
        {
            System.debug('Recalculate exception: ' + e);
            result = false;
            throw new RenewalException('An unexpected error occurred while recalculating pricing data');
        }
        return result;
    }

    public List<PricingEmployee__c>Employees
    {
        get{ return m_Employees; }
        set{ m_Employees = value; }
    }

    public List<PricingWcCode__c> WcCodes
    {
        get{ return m_WcCodes; }
        set{ m_WcCodes = value; }
    }

    public List<PricingEEtoWcCodeAssoc__c> EeAndWcAssociations
    {
        get{ return m_eeAndWcAssociations; }
        set{ m_eeAndWcAssociations = value; }
    }

    public List<PricingExpense__c> Expenses
    {
        get{ return m_Expenses; }
        set{ m_Expenses = value; }
    }

    public List<PricingClientInvestment__c> ClientInvestments
    {
        get{ return m_ClientInvestments; }
        set{ m_ClientInvestments = value; }
    }

    public List<ERPayrollTax__c> TaxTable
    {
        get{ return m_TaxTable; }
        set{ m_TaxTable = value; }
    }

    public static Double GetProjectionFactor(Date startDate, Date endDate)
    {
		Integer daysDiff = startDate.daysBetween(endDate);
		Decimal projFactor = daysDiff > 0 ? 1 + ((Double)daysDiff / 365.0) : 1;
        return projFactor.setScale(2);
    }

    public Double GetXmodForPricing(String stateCode)
    {
        if (stateCode == null) {
			stateCode = '';
		}

        for (PricingXmod__c xmodItem : m_PricingXmods) {
            if (xmodItem.IsPricingXmod__c && (stateCode == '' || xmodItem.State_Code__c == stateCode)) {
                return xmodItem.Xmod__c;
            }
        }

        // Log a Warning then return 1.0 which does not alter pricing
		Log.info(
			'Renewals',
			'Missing Xmod State Code: ' + stateCode + ' - using default of 1.0',
			'PricingSummaryService.GetXmodForPricing()\nScenario Id: \n' +
			m_ClientPricingScenario.Id +
			'\nClient: ' +
			m_ClientPricingScenario.ClientId__c + '  ' +
			m_ClientPricingScenario.ClientName__c);
        return 1.0;
    }

    private void Initialize_SI_Percent()
    {
        Double defaultVal = 25;
        for(PricingWcCode__c wcItem : m_WcCodes){
            if(wcItem.SIEligible__c){
                wcItem.SI_Percent_of_Premium__c = defaultVal;
                wcItem.SI_Percent_of_Payroll__c = defaultVal;
            }
        }
    }

    private Double CalculateHoursInCode()
    {
        Double totalHours = 0;
        Double projectionFactor = 0;

        for(PricingEmployee__c eeItem : m_Employees){
            projectionFactor = eeItem.IsActive__c ? m_projectionFactor : 1;
            for(PricingEEtoWcCodeAssoc__c jItem : eeItem.PricingEEtoWcCodeAssocs__r){
                jItem.AnnualHoursInCode__c = (eeItem.Qty__c * projectionFactor * jItem.AnnualHoursInCode_base__c).setScale(1);
                totalHours += jItem.AnnualHoursInCode__c;
            }
        }
        return totalHours;
    }

    private Double CalculatePayroll()
    {
        Double totalPay = 0;
        Double projFactor = 0;

        for(PricingEmployee__c eeItem : m_Employees){
            projFactor = eeItem.IsActive__c ? m_projectionFactor : 1;
            for(PricingEEtoWcCodeAssoc__c jItem : eeItem.PricingEEtoWcCodeAssocs__r){
                jItem.AnnualPayInCode__c = eeItem.Qty__c * projFactor * jItem.AnnualPayInCode_base__c;
                totalPay += jItem.AnnualPayInCode__c;
            }
        }
        m_totalPayroll = totalPay;
        return m_totalPayroll;
    }

    private Double CalcTaxablePayroll()
    {
        Decimal totalTaxablePay = 0;
        Decimal totalTaxablePayNo1k = 0;
        Decimal projFactor = 0;

        for(PricingEmployee__c eeItem : m_Employees){
            projFactor = eeItem.IsActive__c ? m_projectionFactor : 1;
            for(PricingEEtoWcCodeAssoc__c jItem : eeItem.PricingEEtoWcCodeAssocs__r){
                jItem.AnnualTaxablePayInCode__c = (eeItem.Qty__c * projFactor * jItem.AnnualTaxablePayInCode_base__c).setScale(2);
                totalTaxablePay += jItem.AnnualTaxablePayInCode__c;
                if(!eeItem.IsOwner__c)
                {
                    totalTaxablePayNo1k += jItem.AnnualTaxablePayInCode__c;
                }
            }
        }

        // Recalculate *Percent* of Payroll for each WC Code
        for(PricingWcCode__c wcItem : m_WcCodes) {
            Decimal taxablePayInCode = 0;
            for(PricingEEtoWcCodeAssoc__c jItem : wcItem.PricingEEtoWcCodeAssocs__r) {
                taxablePayInCode += jItem.AnnualTaxablePayInCode__c.setScale(2);
            }
            // DO NOT use PricingWcCode__c Roll-Up Summary fields. They will not be
            // correct until the PricingWcCode__c object has been saved and reloaded
            wcItem.PercentOfPayroll__c = (taxablePayInCode > 0 && totalTaxablePay > 0) ? (100 * taxablePayInCode / totalTaxablePay).setScale(2) : 0;
        }
        m_totalTaxablePayroll = totalTaxablePay;
        m_totalTaxablePayrollNo1k = totalTaxablePayNo1k;
        return totalTaxablePay;
    }

    private Double CalcPremBasedPayroll()
    {
        Double totalPremiumPay = 0;
        Double projectionFactor = 0;
        for(PricingEmployee__c eeItem : m_Employees){
            projectionFactor = eeItem.IsActive__c ? m_projectionFactor : 1;
            for(PricingEEtoWcCodeAssoc__c jItem : eeItem.PricingEEtoWcCodeAssocs__r){
                jItem.AnnualPremPayInCode__c = eeItem.Qty__c * projectionFactor * jItem.AnnualPremPayInCode_base__c;
                totalPremiumPay += jItem.AnnualPremPayInCode__c;
            }
        }
        return totalPremiumPay;
    }

    private void CalculateModifiedWcRates()
    {
        Double xmod = 0;
        String stateCode = '';
        for(PricingWcCode__c wcItem : m_WcCodes){
            if(stateCode != wcItem.State_Code__c){
                xmod = GetXmodForPricing(wcItem.State_Code__c);
            }
            wcItem.Modified_WC_Rate__c = (wcItem.WC_Rate__c * xmod).setScale(4);
        }
    }

    private Double CalculateWcPremiums()
    {
        Double totPremiums = 0;
        Double totPremiumsBlended = 0;
        Double xmod;
        for(PricingWcCode__c wcItem : m_WcCodes){
            Double taxablePayInCode = GetTaxablePayInCode(wcItem);
            Double premiumPayInCode = GetPremiumPayInCode(wcItem);
            xmod = GetXmodForPricing(wcItem.State_Code__c);

            wcItem.Modified_WC_Rate__c = (wcItem.WC_Rate__c * xmod).setScale(4);
            wcItem.WcPremiumEquivalent__c = ((wcItem.Modified_WC_Rate__c / 100) * taxablePayInCode).setScale(2);
            wcItem.WcPremiumBlended__c = ((wcItem.Modified_WC_Rate__c / 100) * premiumPayInCode).setScale(2);
            totPremiums += wcItem.WcPremiumEquivalent__c;
            totPremiumsBlended += wcItem.WcPremiumBlended__c;
        }
        m_totalWcPremiums = totPremiums;
        m_totalWcPremiumsBlended = totPremiumsBlended;
        return totPremiums;
    }

    private Double GetPremiumPayInCode(PricingWcCode__c wcCode)
    {
        Double premiumPayInCode = 0;
        for(PricingEmployee__c eeItem : m_Employees){
            for(PricingEEtoWcCodeAssoc__c jItem : eeItem.PricingEEtoWcCodeAssocs__r){
                if (jItem.PricingWcCode__c == wcCode.Id){
                    premiumPayInCode += jItem.AnnualPremPayInCode__c;
                }
            }
        }
        return premiumPayInCode;
    }

    private Double GetPayInCode(PricingWcCode__c wcCode)
    {
        Double payInCode = 0;
        for(PricingEmployee__c eeItem : m_Employees){
            for(PricingEEtoWcCodeAssoc__c jItem : eeItem.PricingEEtoWcCodeAssocs__r){
                if (jItem.PricingWcCode__c == wcCode.Id){
                    payInCode += jItem.AnnualPayInCode__c;
                }
            }
        }
        return payInCode;
    }

    private Double GetTaxablePayInCode(PricingWcCode__c wcCode)
    {
        Double taxablePayInCode = 0;
        for(PricingEmployee__c eeItem : m_Employees){
            for(PricingEEtoWcCodeAssoc__c jItem : eeItem.PricingEEtoWcCodeAssocs__r){
                if (jItem.PricingWcCode__c == wcCode.Id){
                    taxablePayInCode += jItem.AnnualTaxablePayInCode__c;
                }
            }
        }
        return taxablePayInCode;
    }

    private Double CalculateMaxSi()
    {
        Double maxSI = 0;
        for(PricingWcCode__c wcItem : m_WcCodes){
            maxSI += GetSiMaxInCode(wcItem);
        }
        return maxSI;
    }

    private Double GetSiMaxInCode(PricingWcCode__c wcCode)
    {
        final Double PERCENT_MIN = 0.75;
        final Double PERCENT_MAX = 4;

        Decimal percentOfPayroll = (wcCode.Modified_WC_Rate__c * (wcCode.SI_Percent_of_Payroll__c / 100)).setScale(2);
        Decimal percentOfPremium = 25;

        if(!wcCode.SIEligible__c || percentOfPayroll < PERCENT_MIN) {
            percentOfPayroll = 0;
            percentOfPremium = 0;
        } else if (percentOfPayroll > PERCENT_MAX) {
            percentOfPayroll = PERCENT_MAX;
            percentOfPremium = percentOfPayroll * 100 / wcCode.Modified_WC_Rate__c;
        }

        wcCode.SI_Percent_of_Payroll__c = percentOfPayroll.setScale(2);
        wcCode.SI_Percent_of_Premium__c = percentOfPremium.setScale(2);
        return (wcCode.SI_Percent_of_Payroll__c / 100 ) * GetTaxablePayInCode(wcCode);
    }

    private Double CalculateExpenses()
    {
        Double result = 0;
        for(PricingExpense__c item : m_Expenses){
            result += item.Cost_Each__c * item.Quantity__c;
        }

        Double investments = 0;
        for(PricingClientInvestment__c item: m_ClientInvestments){
            switch on item.Method__c.toLowerCase() {
                when '% of payroll' {
                    item.Total_Cost__c = item.Rate__c * m_totalTaxablePayroll / 100;
                }
                when '% of wc premium' {
                    item.Total_Cost__c = item.Rate__c * m_totalWcPremiums / 100;
                }
                when '% of margin' {
                    item.Total_Cost__c = item.Rate__c * m_grossMargin / 100;
                }
                when else {
                    item.Method__c = '% of Payroll';
                    item.Total_Cost__c = item.Rate__c * m_totalTaxablePayroll / 100;
                }
            }
            investments += item.Total_Cost__c;
        }
        m_totalExpenses = result + investments;
        return m_totalExpenses;
    }

    private Double CalculateGrossMargin()
    {
        Double result = 0;
        for(PricingWcCode__c wcItem : m_WcCodes){
            result += wcItem.DesiredMarginDollars__c != null ? wcItem.DesiredMarginDollars__c : 0;
        }
        m_grossMargin = result;
        return result;
    }

    // dependency on Gross Margin
    private Double CalculateCommissions()
    {
        Double result = 0;
        for(PricingWcCode__c wcItem : m_WcCodes){
            // referral partner commissions
            result += (m_ClientPricingScenario.commRateRenewal__c / 100) * wcItem.WcPremiumEquivalent__c;
        }
        return result;
    }

    private Double CalculateCommissionsBdm()
    {
        return (m_ClientPricingScenario.BDM_Rate_Renewal__c / 100) * m_grossMargin;
    }

    private void ApplyMarkup()
    {
        for(PricingWcCode__c wcItem : m_WcCodes)
        {
            if(wcItem.AnnualTaxablePayInCode__c <= 0)
            {
                continue;
            }

            Double marginOfPayroll = (100 * wcItem.DesiredMarginDollars__c / wcItem.AnnualTaxablePayInCode__c).setScale(2);
            Double expensesPercentOfPayroll = (100 * m_totalExpenses / m_totalTaxablePayroll).setScale(2);
            Double commissionPercentOfPayroll = (100 * TotalCommissions / m_totalTaxablePayroll).setScale(2);

            Double taxPercentOfPayroll = 0;
            if(m_totalTaxInCode.containsKey(wcItem.Id))
            {
                taxPercentOfPayroll = (100 * m_totalTaxInCode.get(wcItem.Id)/ wcItem.AnnualTaxablePayInCode__c).setScale(2);
            }

            wcItem.Markup__c = (marginOfPayroll + taxPercentOfPayroll + expensesPercentOfPayroll + commissionPercentOfPayroll + wcItem.Modified_WC_Rate__c).setScale(3);
            wcItem.Markup_OverTime__c = (wcItem.Markup__c - (wcItem.Modified_WC_Rate__c / 3)).setScale(3);
            wcItem.Markup_DoubleTime__c = (wcItem.Markup__c - (wcItem.Modified_WC_Rate__c / 2)).setScale(3);
            wcItem.MarkupNo1k__c = (wcItem.WC_Code__c == '1000') ? 0 : wcItem.Markup__c;

            Decimal wcPremiumBlendedPercentOfPayroll = (100 * wcItem.WcPremiumBlended__c / m_totalTaxablePayroll).setScale(3);
            wcItem.Markup_Blended__c =  (marginOfPayroll + taxPercentOfPayroll + expensesPercentOfPayroll + commissionPercentOfPayroll + wcPremiumBlendedPercentOfPayroll).setScale(3);
        }
    }

    private Double CalculateBilling()
    {
        Double result = 0;
        result = m_futureRow.YendComms__c + m_futureRow.YendCommsBdm__c + m_futureRow.YendMargin__c +
                 m_futureRow.YendPayroll__c + m_futureRow.YendExpenses__c +
                 m_futureRow.YendErTaxes__c + m_futureRow.YendWcPrem__c;
        return result;
    }

    private Double CalculateErTaxes()
    {
        Double result = 0;
        Double resultNo1k = 0;
        for(PricingEmployee__c eeItem : Employees) {
            eeItem.EstimatedERTax__c = eeItem.Qty__c * CalcErTax(eeItem);
            result += eeItem.EstimatedERTax__c;
            if(!eeItem.IsOwner__c)
            {
                resultNo1k += eeItem.EstimatedERTax__c;
            }
        }

        m_erTaxes = result;
        m_erTaxesNo1k = resultNo1k;
        return result;
    }

    private Double CalcErTax(PricingEmployee__c employee)
    {
        Double result = 0;
        Double qty = Math.max(1, employee.Qty__c);
        Double taxablePay = GetAnnualTaxablePay(employee);
        Boolean isNeg = (taxablePay < 0 && (employee.Qty__c > 0));
        taxablePay = Math.abs(taxablePay);

        for(ERPayrollTax__c txItem : m_TaxTable){
            if(txItem.Non_Profit__c){ continue;}
            if(txItem.State_Code__c != 'FED' && txItem.State_Code__c != employee.State_Code__c){ continue;}
            if(txItem.Limit__c > 0)
            {
                result += (txItem.Rate__c / 100) * Math.min(taxablePay / qty, txItem.Limit__c);
            }
            else
            {
                result += (txItem.Rate__c / 100) * taxablePay / qty;
            }
        }
        if(isNeg && result > 0)
        {
            return (-1) * result;
        }
        return Math.abs(result);
    }

    private void CalculateErTaxesInCode()
    {
        for(PricingEmployee__c eeItem : m_Employees){
            for(PricingEEtoWcCodeAssoc__c jItem : eeItem.PricingEEtoWcCodeAssocs__r){
                Decimal taxInCode = (eeItem.EstimatedERTax__c > 0 && eeItem.AnnualTaxablePay__c > 0 && jItem.AnnualTaxablePayInCode__c > 0)
                        ? ( eeItem.EstimatedERTax__c * jItem.AnnualTaxablePayInCode__c / eeItem.AnnualTaxablePay__c).setScale(2) : 0;
                jItem.EstimatedErTaxInCode__c = taxInCode;
                Id wcCode = jItem.PricingWcCode__c;
                if(m_totalTaxInCode.containsKey(wcCode))
                {
                    m_totalTaxInCode.put(wcCode, (m_totalTaxInCode.get(wcCode) + taxInCode).setScale(2));
                }
                else
                {
                    m_totalTaxInCode.put(wcCode, taxInCode);
                }
            }
        }
    }

    private Double CalcTaxBurdenPercent()
    {
        return (m_erTaxes > 0 || m_totalTaxablePayroll > 0) ? (100 * m_erTaxes / m_totalTaxablePayroll).setScale(2) : 0;
    }

    private Double CalcTaxBurdenPercentNo1k()
    {
        return (m_erTaxesNo1k > 0  && m_totalTaxablePayrollNo1k > 0) ? (100 * m_erTaxesNo1k / m_totalTaxablePayrollNo1k).setScale(2) : 0;
    }

    private Double CalcCommissionsPercent()
    {
        return (m_totalCommissions > 0 || m_totalTaxablePayroll > 0)? (100 * m_totalCommissions / m_totalTaxablePayroll).setScale(2) : 0;
    }

    private Double CalcExpensesPercent()
    {
        return (m_totalExpenses > 0 || m_totalTaxablePayroll > 0) ? (100 * m_totalExpenses / m_totalTaxablePayroll).setScale(2) : 0;
    }

    private Double GetAnnualHours(PricingEmployee__c employee)
    {
        Double hours = 0;
        for(PricingEEtoWcCodeAssoc__c jItem : employee.PricingEEtoWcCodeAssocs__r){
            hours += jItem.AnnualHoursInCode__c;
        }
        return hours;
    }

    private Double GetAnnualTaxablePay(PricingEmployee__c employee)
    {
        Double taxPay = 0;
        for(PricingEEtoWcCodeAssoc__c jItem : employee.PricingEEtoWcCodeAssocs__r){
            taxPay += jItem.AnnualTaxablePayInCode__c;
        }
        return taxPay;
    }

    private Double GetAnnualHeadcount()
    {
        Double result = 0;
        for (PricingEmployee__c eeItem : m_Employees) {
            result += eeItem.Qty__c;
        }
        return result;
    }

    private Double GetCurrentHeadcount()
    {
        Double result = 0;
        for(PricingEmployee__c eeItem : m_Employees){
            if(eeItem.IsActive__c){
                result += eeItem.Qty__c;
            }
        }
        return result;
   }

   private void ApplyGrossMargin(Double totGrossMargin)
   {
       if(totGrossMargin != m_grossMargin)
       {
            Double totalTaxablePayroll = CalcTaxablePayroll();
            if(totalTaxablePayroll != 0){
                for(PricingWcCode__c wcItem : m_WcCodes){
                    wcItem.DesiredMarginDollars__c = (totGrossMargin * (wcItem.PercentOfPayroll__c / 100)).setScale(2);
                }
            }
            Database.SaveResult[] srList = Database.update(m_WcCodes, false);
            for (Database.SaveResult sr : srList) {
                if (!sr.isSuccess()) {
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('Apply Gross Margin error: ' + err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Account fields that affected this error: ' + err.getFields());
                    }
                }
            }
            Recalculate();
       }
   }
}