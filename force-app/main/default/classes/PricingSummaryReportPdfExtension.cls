/**
 * Created by CElim on 3/21/2019.
 */

public without sharing class PricingSummaryReportPdfExtension
{
    // Section 1
    public Account Client { get; set; }
    public ClientPricingScenario__c ClientPricingScenario { get; set; }
    public Boolean IsProspect { get { return ClientPricingScenario.IsProspect__c; } }
    public Renewal__c Renewal { get; set; }
    public String ReportDate { get { return Date.today().format(); } }
    public String RenewalDate { get { return Renewal.Renewal_Date_Add_1__c.format(); } }
    public Integer RenewalYear { get { return Renewal.Renewal_Date_Add_1__c.year(); } }

    // Section 2
    public PricingSummaryHistory__c Summary { get; set; }
    public PricingXmod__c[] RenewalXmods { get; set; }
    public String PricingXmods { get; set; }
    public String DefaultXmods { get; set; }
    public String WorkCompPolicy { get; set; }

    // Section 3 & 4
    public PricingSummaryHistory__c[] History { get; set; }
    public PricingWcCode__c[] Markups { get; set; }
    public Billing_History__c[] BillingHistories { get; set; }
    public Decimal TotalPayroll { get; set; }
    public Decimal RenewalGrossMargin { get; set; }
    public Decimal CurrentGrossMargin { get; set; }

    // Section 5
    public List<ERPayrollTax__c> Taxes { get; set; }
    public List<PricingWcCode__c> SafetyIncentives { get; set; }
    public String NonProfit { get; set; }

    public PricingSummaryReportPdfExtension(ApexPages.StandardController controller) {
        Id cpsId = controller.getId();
        Map<String, String> parameters = ApexPages.currentPage().getParameters();

        // Section 1
        ClientPricingScenario = [
                SELECT  BDM__c, BDM_Rate__c,
                        ClientId__c, CreatedBy.Name, commCompany__c, IsProspect__c,
                        Name, Non_Profit__c, Notes__c, Opportunity__c,
                        PricingScenario__r.FEIN__c, PricingScenario__r.Renewal__c
                FROM ClientPricingScenario__c
                WHERE Id = :cpsId
                LIMIT 1
        ];

        Renewal = [
                SELECT Renewal_Date__c, Renewal_Date_Add_1__c
                FROM Renewal__c
                WHERE Id = :ClientPricingScenario.PricingScenario__r.Renewal__c
        ];

        if (ClientPricingScenario.IsProspect__c) {
            String opportunityId = ClientPricingScenario.Opportunity__c;
            Client = PrcNewPricingController.getProspectClient(opportunityId);
            Client = [
                    SELECT Id, Name, Business_Unit__r.BBSI_Branch__r.Name, Safety_Incentive_Info__c, Contractors_License__c,
                    (
                            SELECT Name, Term_Date__c, External_ID__c, Work_Comp_Policy__r.Name, Work_Comp_Policy__r.External_ID__c
                            FROM WorkCompPolicyAccounts__r
                            WHERE Term_Date__c <= :Renewal.Renewal_Date_Add_1__c
                            ORDER BY Term_Date__c DESC
                            LIMIT 1
                    )
                    FROM Account
                    WHERE Id = : Client.Id
                    LIMIT 1
            ];
        }
        else 
        {
            Client = [
                    SELECT Id, Name, Business_Unit__r.BBSI_Branch__r.Name, Safety_Incentive_Info__c, Contractors_License__c,
                    (
                            SELECT Name, Term_Date__c, External_ID__c, Work_Comp_Policy__r.Name, Work_Comp_Policy__r.External_ID__c
                            FROM WorkCompPolicyAccounts__r
                            WHERE Term_Date__c <= :Renewal.Renewal_Date_Add_1__c
                            ORDER BY Term_Date__c DESC
                            LIMIT 1
                    )
                    FROM Account
                    WHERE External_ID__c = :ClientPricingScenario.ClientId__c
                    LIMIT 1
            ];
        }
        // end of Section 1

        // Scenario 2
        WorkCompPolicy = '';
        if (Client.WorkCompPolicyAccounts__r.size() >= 1 && Client.WorkCompPolicyAccounts__r[0].Name != null
                && Client.WorkCompPolicyAccounts__r[0].External_ID__c.length() > 7) {
            // External_ID__c = <6-digits client ID> . <policy number> i.e.:902928.C65206808
            WorkCompPolicy = Client.WorkCompPolicyAccounts__r[0].External_ID__c.substring(7);
        }

        Summary = PrcMarginHistoryController.getPricingSummaryRenewalRow(cpsId);
        RenewalXmods = PrcXmodController.getRenewalYearXmods(cpsId);

        for (PricingXmod__c x : RenewalXmods) {
            if (x.Xmod__c == null) {
                continue;
            }
            if (PricingXmods == null) {
                PricingXmods = x.State_Code__c + '-' + x.Xmod__c.setScale(2);
            } else {
                PricingXmods += ',' + x.State_Code__c + '-' + x.Xmod__c.setScale(2);
            }
        }

        PricingXmod__c[] publishedXmods = PrcXmodController.getPublishedXmods(cpsId, '5');
        PricingXmod__c[] historyXmods = PrcXmodController.getXmodHistory(cpsId, '5');
        XmodRecommended__c[] recommendedXmods = PrcXmodController.getXmodRecommended(cpsId);
        String [] states = new List<String>();

        // Create History XMOD Map
        Map<String, PricingXmod__c> historyXmodStateMap = new Map<String, PricingXmod__c>();
        for (PricingXmod__c x : historyXmods){
            if (!historyXmodStateMap.containsKey(x.State_Code__c)) {
                historyXmodStateMap.put(x.State_Code__c, x);
                states.add(x.State_Code__c);
            }
            else if (historyXmodStateMap.get(x.State_Code__c).XmodDate__c.year() < x.XmodDate__c.year()) {
                historyXmodStateMap.put(x.State_Code__c, x);
            }
        }
        
        // Create Published XMOD Map
        Map<String, PricingXmod__c> publishedXmodStateMap = new Map<String, PricingXmod__c>();
        for (PricingXmod__c x : publishedXmods){
            if (x.Xmod__c == null){
                continue;
            }
            else if (!publishedXmodStateMap.containsKey(x.State_Code__c)) {
                publishedXmodStateMap.put(x.State_Code__c, x);
            }
            else if (publishedXmodStateMap.get(x.State_Code__c).XmodDate__c.year() < x.XmodDate__c.year()) {
                publishedXmodStateMap.put(x.State_Code__c, x);
            }
        }

        // Create Recommended XMOD Map
        Map<String, XmodRecommended__c> recommendedXmodStateMap = new Map<String, XmodRecommended__c>();
        for (XmodRecommended__c x : recommendedXmods) {
            if (!recommendedXmodStateMap.containsKey(x.State_Code__c)) {
                recommendedXmodStateMap.put(x.State_Code__c, x);
            }
        }

        // for each state, determine default XMOD (see below for more details) - user story #1946
        // 1. Published XMOD
        // 2. BBSI Recommended XMOD
        // 3. XMOD History
        for (String state : states) {
            // if the state is not in the XMOD history list, default XMOD is not applicable
            if (!historyXmodStateMap.containsKey(state)) {
                continue;
            }

            PricingXmod__c historyXmod = historyXmodStateMap.get(state);
            Boolean hasPublishedXmod = publishedXmodStateMap.containsKey(state);
            Boolean hasRecommendedXmod = recommendedXmodStateMap.containsKey(state);

            Integer year = Date.today().year() + 1; // add +1 year - see bug #18716
            Integer minYear = year - 10 ; // go back to 5 years from today
            Decimal defaultXmod = -1; // 

            while (defaultXmod < 0 && year > minYear) {
                // Case 1: if Published XMOD is present (NOT blank) and Recommended XMOD is NOT present (or blank), use Published XMOD
                // Case 2: if Published XMOD and Recommended XMOD are present:
                // 1. Use XMOD from the latest year (regardless of day or month)
                // 2. When the year is equal, use Published XMOD
                if (hasPublishedXmod && Integer.valueOf(publishedXmodStateMap.get(state).Year__c) == year) {
                    defaultXmod = publishedXmodStateMap.get(state).Xmod__c;
                    break;
                } 
                // Case 3: if Recommended XMOD is present (NOT blank) and Published XMOD is NOT present (or blank), use Recommended XMOD
                else if (hasRecommendedXmod && recommendedXmodStateMap.get(state).Effective_Date__c.year() == year) {
                    defaultXmod = recommendedXmodStateMap.get(state).Xmod__c;
                    break;
                }
                year--;
            }

            // Only prints out XMOD when there is one - see bug #18697
            if (defaultXmod < 0) {
                continue;
            }

            // Concat default XMODs for all states
            if (DefaultXmods == null) {
                DefaultXmods = state + '-' + defaultXmod.setScale(2);
            } else {
                DefaultXmods += ',' + state + '-' + defaultXmod.setScale(2);
            }
        }
        // end of Section 2

        // Section 3 & 4
        Markups = PrcWorkCompController.getPricingWcCodesWithPayrollAndIncludeFlag(cpsId);
        BillingHistories = PrcMarkupController.getBillingHistories(ClientPricingScenario.ClientId__c);
        History = PrcMarginHistoryController.getPricingSummaryRows(cpsId);
        Map<String, Decimal> billingMap = PricingReportService.buildBillingHistoryMap(BillingHistories);

        RenewalGrossMargin = History.size() > 0 ? History[0].YendMargin__c : 0;
        CurrentGrossMargin = History.size() > 1 ? History[1].YendMargin__c : 0;

        Decimal margin = 0;
        Decimal totPayroll = 0;
        for (PricingWcCode__c x : Markups) {
            // Total the Net Margin when WC Code has payroll
            if (x.AnnualTaxablePayInCode__c != 0) {
                margin += x.DesiredMarginDollars__c;
            }
            // Total the Payroll for all WC Codes
            for (PricingEEtoWcCodeAssoc__c y : x.PricingEEtoWcCodeAssocs__r) {
                totPayroll += y.AnnualPayInCode__c;
            }
        }
        TotalPayroll = totPayroll;
        // end of Section 3 & 4

        // Section 5
        NonProfit = ClientPricingScenario.Non_Profit__c ? '(Non-Profit)' : '';
        Taxes = PrcTaxRatesController.getPricingFederalTaxes(cpsId);
        Taxes.addAll(PrcTaxRatesController.getPricingStateAndOthersTaxes(cpsId));
        for (ERPayrollTax__c x : Taxes) {
            if (x.Tax_Type__c != 'SUTA') {
                x.Default_Rate__c = null;
            }
        }

        // Parse Safety Incentive info from the Client's Account
        String[] siInfo = Client.Safety_Incentive_Info__c != null ? Client.Safety_Incentive_Info__c.split('\n') : new List<String>();
        Map<String, String> siMap = new Map<String, String>();
        for (String x : siInfo) {
            String [] xx = x.split('-');
            if (xx.size() == 2) {
                siMap.put(xx[0].trim().leftPad(4, '0'), xx[1].trim());
            }
        }

        // Put Safety Incentive from Account to the Pricing WC Code (under Name) as a temporary holder for this report 
        SafetyIncentives = new List<PricingWcCode__c>();
        for (PricingWcCode__c x : Markups) {
            if (x.SIEligible__c && x.SI_Percent_of_Payroll__c > 0) {
                x.Name = siMap.containsKey(x.WC_Code__c) ? siMap.get(x.WC_Code__c) : '';
                SafetyIncentives.add(x);
            }
        }
        // end of Section 5
    }
}