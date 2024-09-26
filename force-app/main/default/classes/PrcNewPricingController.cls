public without sharing class PrcNewPricingController
{
    public class DataTableRow
    {
        @AuraEnabled
        public String State { get; set; }
        @AuraEnabled
        public String Code { get; set; }
        @AuraEnabled
        public Decimal Rate { get; set; }
        @AuraEnabled
        public Decimal FteCount { get; set; }
        @AuraEnabled
        public Decimal PayrollDollars { get; set; }
    }

    public class TemplateWcCode
    {
        @AuraEnabled
        public String State { get; set; }
        @AuraEnabled
        public List<WorkCompRate__c> WorkCompRates { get; set; }
    }

    @AuraEnabled
    public static Map<String, Map<String, List<WorkCompRate__c>>> getWorkCompRateMap()
    {
        return WorkCompController.getWorkCompRateMap();
    }

    @AuraEnabled
    public static List<WorkCompPolicyDisplayName__c> getPolicies()
    {
        return WorkCompController.includedWorkCompPolicyDisplayNames();
    }

    @AuraEnabled
    public static Renewal__c createRenewal(String opportunityId)
    {
        Account prospect = PrcNewPricingController.getProspectClient(opportunityId);
        Renewal__c renewal = PrcNewPricingController.getRenewal(prospect.Name, prospect.FEIN__c);

        if (renewal == null || renewal.Id == null) {
            renewal = new Renewal__c();
            renewal.Name = prospect.Name;
            renewal.FEIN__c = prospect.FEIN__c;
            renewal.Status__c = 'New';
            renewal.Business_Unit__c = prospect.Business_Unit__r.Name;
            if (prospect.Renewal_Date__c != null) {
                renewal.Renewal_Date__c = prospect.Renewal_Date__c;
            }

            User u = [SELECT Name, Id FROM User WHERE Username like 'Integration%' LIMIT 1];
            renewal.OwnerId = u.Id;

            Database.insert(renewal);
            Log.info('Renewal', 'CreateNewPricingRenewals', 'New Pricing Renewal Objects: ' + renewal.Name);
        }

        return renewal;
    }

    @AuraEnabled
    public static Renewal__c getRenewal(String opportunityId)
    {
        Account prospect = PrcNewPricingController.getProspectClient(opportunityId);
        return PrcNewPricingController.getRenewal(prospect.Name, prospect.FEIN__c);
    }

    @AuraEnabled
    public static Renewal__c getRenewal(String name, String fein)
    {
        Renewal__c [] renewals =
        [
            SELECT Id, FEIN__c, Name, Renewal_Date__c
            FROM Renewal__c
            WHERE Name = :name AND FEIN__c = :fein
            LIMIT 1
        ];
        return (renewals.size() > 0) ? renewals[0] : new Renewal__c();
    }

    @AuraEnabled
    public static List<PricingScenario__c> getPricingScenarios(String opportunityId)
    {

        Renewal__c renewal = PrcNewPricingController.getRenewal(opportunityId);
        if (renewal == null || renewal.Id == null) {
            return new List<PricingScenario__c>();
        }

        return
        [
            SELECT Id, CreatedDate__c, ScenarioName__c, Name, Renewal__c
            FROM PricingScenario__c
            WHERE Renewal__c = :renewal.Id
            ORDER BY CreatedDate
        ];
    }

    @AuraEnabled
    public static Account getProspectClient(String opportunityId)
    {
        Opportunity opp =
        [
            SELECT Id, AccountId, FEIN__c, Published_X_Mod__c
            FROM Opportunity
            WHERE Id =: opportunityId
        ];

        Account client =
        [
            SELECT  Id, Branch__c, FEIN__c, Name, Renewal_Date__c, RecordType.Name,
                    Location_Primary_Contact__c, OwnerId, External_ID__c,
                    X_mod__c,
                    Business_Development_Manager__c, Business_Development_Manager__r.Name,
                    Business_Unit__c, Business_Unit__r.Name, Business_Unit__r.BU_No__c,
                    Business_Unit__r.BBSI_Branch__c, Business_Unit__r.Branch_No__c,
                    Assigned_Referral_Partner__c, Assigned_Referral_Partner__r.Name,
                    Assigned_Referral_Partner__r.Commission_Rate__c, Assigned_Referral_Partner__r.Commission_Type__c

            FROM Account
            WHERE Id =: opp.AccountId
        ];

        return client;
    }

    @AuraEnabled
    public static String newClientPricingScenario(String opportunityId, String scenarioName, List<DataTableRow> rows, List<TemplateWcCode> templateWcCodes)
    {
        Account prospect = PrcNewPricingController.getProspectClient(opportunityId);
        if (prospect == null) {
            return 'Error: Prospect Account Not found';
        }

        // create renewal object
        Renewal__c renewal = PrcNewPricingController.getRenewal(opportunityId);
        if (renewal == null || renewal.Id == null) {
            return 'Error: Renewal is empty';
        }

        // create PS
        PricingScenarioBuilder psBuilder = new PricingScenarioBuilder();
        PricingScenario__c ps = psBuilder.BuildPricingScenario(scenarioName, renewal.Id);
        if (ps == null || ps.Id == null) {
            return 'Error: Pricing Scenario is not created.';
        }

        // create CPS
        NewClientPricingScenarioBuilder cpsBuilder = new NewClientPricingScenarioBuilder();
        ClientPricingScenario__c cps = cpsBuilder.BuildNewClientPricingScenario(ps, prospect, opportunityId);
        if (cps == null || cps.Id == null) {
            return 'Error: Client Pricing Scenario is not created.';
        }

        // build CPS's associated children i.e.: employee, work comp, etc.
        cpsBuilder.BuildAssociatedTables(cps, prospect, rows, templateWcCodes);

        return 'OK';
    }

    @AuraEnabled
    public static void deletePricingScenario(String pricingScenarioId)
    {
        PricingScenarioService.DeletePricingScenario(pricingScenarioId);
    }

    @AuraEnabled
    public static String clonePricingScenario(String opportunityId, String scenarioName, String cloneScenarioName)
    {
        String newScenarioName = cloneScenarioName;
        Renewal__c renewal = PrcNewPricingController.getRenewal(opportunityId);

        Integer index = 1;
        for (; index <= 10; index++) {
            if (PricingScenarioCloneDirector.IsNameUnique(newScenarioName, renewal.Id)) {
                break;
            }
            newScenarioName = cloneScenarioName + '-0' + index;
        }

        if (index > 10) {
            return 'Error: Cloning Pricing Scenario fails because the name is not unique';
        }

        PricingScenarioCloneDirector cloneDirector = new PricingScenarioCloneDirector();
        if (cloneDirector.CloneScenario(scenarioName, newScenarioName, renewal.Id)) {
            return 'OK';
        }
        else {
            return 'Error: Cloning Pricing Scenario has issues';
        }
    }

    @AuraEnabled
    public static Map<String, List<WorkCompRate__c>> getWorkCompRateByState(String state)
    {
        Map<String, List<WorkCompRate__c>> result = new Map<String, List<WorkCompRate__c>>();

        List<WorkCompRate__c> rates = WorkCompController.getWorkCompRatesByState(state);
        System.debug('\tCE: rates.size(): ' + rates.size());
        result.put(state, rates);
        return result;
    }
}