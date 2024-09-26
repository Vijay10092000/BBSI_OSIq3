/**
 * Created by CElim on 3/28/2019.
 */

public without sharing class PricingClientAddendumPdfExtension
{
    public String ReportDate { get { return System.today().format(); } }

    public Boolean IsSafetyIncentive { get; set; }
    public Boolean IsStandardMarkup { get; set; }
    public Boolean IncludeOt { get; set; }
    public Boolean IncludeDt { get; set; }
    public String RenewalDate { get; set; }
    public Account Client { get; set; }
    public Address ClientAddress { get; set;}
    public String ClientId { get { return ClientPricingScenario.ClientId__c; } }
    public String ClientCity { get { return ClientAddress.getCity(); } }
    public String ClientStreet { get { return ClientAddress.getStreet(); } }
    public String ClientState { get { return ClientAddress.getState(); } }
    public String ClientPostalCode { get { return ClientAddress.getPostalCode(); } }

    public Account Branch { get; set; }
    public Address BranchAddress { get; set; }
    public String BranchCity { get { return BranchAddress.getCity(); } }
    public String BranchStreet { get { return BranchAddress.getStreet(); } }
    public String BranchState { get { return BranchAddress.getState(); } }
    public String BranchPostalCode { get { return BranchAddress.getPostalCode(); } }

    public PricingScenario__c PricingScenario { get; set; }
    public ClientPricingScenario__c ClientPricingScenario { get; set; }

    public PricingSummaryHistory__c Summary { get; set; }
    public PricingWcCode__c[] WorkCompCodes { get; set; }
    public Billing_History__c[] BillingHistories { get; set; }
    public Map<String, String> SafetyIncentives { get; set; }

    public List<Map<String, String>> FeeSchedule { get; set; }

    public String Empty { get { return '-'; } }
    
    public PricingClientAddendumPdfExtension(ApexPages.StandardController controller)
    {
        Id cpsId = controller.getId();
        Map<String,String> parameters = ApexPages.currentPage().getParameters();

        Summary = PrcMarginHistoryController.getPricingSummaryRenewalRow(cpsId);
        RenewalDate = Summary.PeriodStartDate__c.format();

        IsSafetyIncentive = parameters.containsKey('si') ? parameters.get('si') == 'true' : false;
        IsStandardMarkup = parameters.containsKey('includeOtDt') ? parameters.get('includeOtDt').equalsIgnoreCase('true') || parameters.get('includeOtDt').startsWithIgnoreCase('y') : false;
        IncludeOt = IncludeDt = false;
        if (IsStandardMarkup) {
            IncludeOt = true;
            IncludeDt = true;
        }

        ClientPricingScenario = [
                SELECT Id, PricingScenario__c, ClientId__c, IsProspect__c
                FROM ClientPricingScenario__c
                WHERE Id = :cpsId
        ];

        Client = [
                SELECT Name, BillingAddress, Business_Unit__r.BBSI_Branch__c
                FROM Account
                WHERE External_ID__c = :ClientPricingScenario.ClientId__c
        ];

        ClientAddress = Client.BillingAddress;

        Branch = [
                SELECT Name, BillingAddress
                FROM Account
                WHERE Id = :Client.Business_Unit__r.BBSI_Branch__c
        ];

        BranchAddress = Branch.BillingAddress;

        Id PricingScenarioId = ClientPricingScenario.PricingScenario__c;
        PricingScenario = [
                SELECT Id
                FROM PricingScenario__c
                WHERE Id = :PricingScenarioId
        ];

        WorkCompCodes = PrcWorkCompController.getPricingWcCodesWithPayrollAndIncludeFlag(cpsId); 
        SafetyIncentives = PrcMarkupController.getSafetyIncentives(ClientPricingScenario.ClientId__c);
        BillingHistories = PrcMarkupController.getBillingHistories(ClientPricingScenario.ClientId__c);
        Map<String, Decimal> billingMap = PricingReportService.buildBillingHistoryMap(BillingHistories);
        FeeSchedule = new List<Map<String, String>>();

        for(PricingWcCode__c wc : WorkCompCodes) {
            String applicablePayTypes = '';
            String state = wc.State_Code__c;
            String code = wc.WC_Code__c;
            String wcCode = state + '.' + code;
            Boolean IsWc1000 = (code == '1000');

            // Get the Current Markups from the billing history 
            // When current markup line contains REG, blank or SAL, the order of priority is the following:
            // 1. REG
            // 2. blank line
            // 3. SAL
            Decimal currentMarkup = billingMap.containsKey(wcCode + '.REG') ? billingMap.get(wcCode + '.REG') : null;
            if (currentMarkup == null) {
                currentMarkup = billingMap.containsKey(wcCode + '.<blank>') ? billingMap.get(wcCode + '.<blank>') : null;
            }
            if (currentMarkup == null) {
                currentMarkup = billingMap.containsKey(wcCode + '.SAL') ? billingMap.get(wcCode + '.SAL') : null;
            }
            Decimal currentMarkupOt = billingMap.containsKey(wcCode + '.OT') ? billingMap.get(wcCode + '.OT') : null;
            Decimal currentMarkupDt = billingMap.containsKey(wcCode + '.DT') ? billingMap.get(wcCode + '.DT') : null;

            // newSiRate logic: populate only if SI Eligible is ON and SI % of Payroll is positive
            String newSiRate = wc.SIEligible__c && wc.SI_Percent_of_Payroll__c > 0 ? wc.SI_Percent_of_Payroll__c.setScale(2).format() + '%' : Empty;
            // currentSiRate logic: populate only if SI Eligible is ON, newSiRate is not ZERO (empty) and there is a history SI rate 
            String currentSiRate = (SafetyIncentives.containsKey(code) && SafetyIncentives.get(code) != '0.0') ? SafetyIncentives.get(code) + '%' : Empty;

            // Determine whether to include OT or DT based off of Markup values
            // If New Markup OT/DT is null or zero, DO NOT include OT/DT respectively; else Include OT/DT
            Boolean includeOverTime = IncludeOt && wc.Markup_OverTime__c > 0;
            Boolean includeDoubleTime = IncludeDt && wc.Markup_DoubleTime__c > 0;
            if (IsWc1000) {
                applicablePayTypes = 'ALL';
            } else if (includeOverTime && includeDoubleTime) {
                applicablePayTypes = 'ALL EXCEPT OT/DT';
            } else if (includeOverTime) {
                applicablePayTypes = 'ALL EXCEPT OT';
            } else if (includeDoubleTime) {
                applicablePayTypes = 'ALL EXCEPT DT';
            } else {
                applicablePayTypes = 'ALL';
            }

            // Add a line in the Fee Schedule table on Markup %
            Map<String, String> reg = new Map<String, String>();
            reg.put('State', state);
            reg.put('Code', code);
            reg.put('Pay', applicablePayTypes);
            reg.put('CurrentMarkup', currentMarkup == null ? Empty : currentMarkup + '%');
            reg.put('NewMarkup', wc.Markup__c == null ? Empty : wc.Markup__c.setScale(2) + '%');
            reg.put('CurrentSiRate', currentSiRate);
            reg.put('NewSiRate', newSiRate);
            FeeSchedule.add(reg);

            // If WC Code = 1000, skip OT and DT - as they are not applicable
            if (IsWc1000) {
                continue;
            }

            // Add a line in the Fee Schedule table for Markup OT %, if applicable
            if (includeOverTime) {
                Map<String, String> ot = new Map<String, String>();
                ot.put('State', state);
                ot.put('Code', code);
                ot.put('Pay', 'OT');
                ot.put('CurrentMarkup', currentMarkupOt == null ? Empty : currentMarkupOt + '%');
                ot.put('NewMarkup', wc.Markup_OverTime__c == null ? Empty : wc.Markup_OverTime__c.setScale(2) + '%');
                ot.put('CurrentSiRate', Empty);
                ot.put('NewSiRate', Empty);
                FeeSchedule.add(ot);
            }

            // Add a line in the Fee Schedule table for Markup DT %, if applicable
            if (includeDoubleTime) {
                Map<String, String> dt = new Map<String, String>();
                dt.put('State', state);
                dt.put('Code', code);
                dt.put('Pay', 'DT');
                dt.put('CurrentMarkup', currentMarkupDt == null ? Empty : currentMarkupDt + '%');
                dt.put('NewMarkup', wc.Markup_DoubleTime__c == null ? Empty : wc.Markup_DoubleTime__c.setScale(2) + '%');
                dt.put('CurrentSiRate', Empty);
                dt.put('NewSiRate', Empty);
                FeeSchedule.add(dt);
            }
        }
    }
}