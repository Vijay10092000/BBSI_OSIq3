/**
 * Batch class to generate Benefits Renewal Opportunity - 90 days in advance of BBSI Benefits Renewal Date
 *
 * Created By: Srikanth Inagala (OSI)
 * Last Updated By: Harpreet Singh (OSI)
 */
public class BenefitsRenewalBatch implements Database.Batchable<sObject> {
    // Query for accounts that meet the criteria
    private static final String QUERY_TESTING =
    'SELECT Id, Benefits_Affiliates__c,Benefits_Affiliates__r.Benefits_Affiliated_Companies_Count__c, Benefits_Affiliated_Companies__c, Producer__c, Assigned_Referral_Partner__c, BBSI_Benefits__c, RecordType.DeveloperName, Benefits_Affiliates_Type__c, BBSI_Benefits_Renewal_Date__c, ' +
    'Benefits_Representative__c, OwnerId, Name FROM Account ' +
    'WHERE BBSI_Benefits__c = true ' +
    'AND RecordType.DeveloperName = \'Client\' ' +
    'AND (Benefits_Affiliates_Type__c = null OR Benefits_Affiliates_Type__c = \'Primary\') ' +
    'AND BBSI_Benefits_Renewal_Date__c != null';


    private static final String FORMAT_QUERY =
    'SELECT Id, Benefits_Affiliates__c,Benefits_Affiliates__r.Benefits_Affiliated_Companies_Count__c, ' + 
        'Benefits_Affiliated_Companies__c, Producer__c, Assigned_Referral_Partner__c, ' + 
        'BBSI_Benefits__c, RecordType.DeveloperName, Benefits_Affiliates_Type__c, BBSI_Benefits_Renewal_Date__c, ' +
        'Benefits_Representative__c, OwnerId, Name ' + 
    'FROM Account ' +
    'WHERE BBSI_Benefits__c = true ' +
        'AND Is_Benefits_Renewal_Opp_Generated__c = false ' + // Only pick Accounts for which Ben Ren Opp is not yet generated
        'AND RecordType.DeveloperName = \'Client\' ' +
        'AND (Benefits_Affiliates_Type__c = null OR Benefits_Affiliates_Type__c = \'Primary\') ' +
        'AND BBSI_Benefits_Renewal_Date__c != null ' +
        'AND BBSI_Benefits_Renewal_Date__c = NEXT_N_DAYS:{0} ' + 
        // 'AND BBSI_Benefits_Renewal_Date__c > NEXT_N_DAYS:{1}' + // Commenting to let it try to renew for up to 90 days
        '';
    private static final Integer DEFAULT_DAYS_FOR_BENEFITTS_RENEWAL = 90;    
    
    // Method to start the batch process and define the initial query
    public Database.QueryLocator start(Database.BatchableContext BC) {        
        Integer daysForBenefitsRenewal = getDaysForBenefitsRenewal();
        String query = String.format(FORMAT_QUERY, new List<String>{ String.valueOf(daysForBenefitsRenewal), String.valueOf(daysForBenefitsRenewal-1) });
        System.debug(query);
        if (Test.isRunningTest()) {
            query = QUERY_TESTING;
        }
        return Database.getQueryLocator(query);
    }
    // Method to process each batch of records
    public void execute(Database.BatchableContext BC, List<sObject> scope) {
        List<Opportunity> renewalOpportunities = new List<Opportunity>();

        for (Account acc : (List<Account>)scope) {
            // Determine the Opportunity Owner
            Id opportunityOwnerId = acc.Benefits_Representative__c != null ? acc.Benefits_Representative__c : acc.OwnerId;

            // Create Opportunity Name with current year
            String  renewalYear = (acc.BBSI_Benefits_Renewal_Date__c != null) ? String.Valueof(acc.BBSI_Benefits_Renewal_Date__c.year()) : '';
            String opportunityName = 'Benefits Renewal ' + renewalYear + ': ' + acc.Name;
                
            // Calculate Master Plan Renewal Date
            Date masterPlanRenewalDate = acc.BBSI_Benefits_Renewal_Date__c.addYears(1);
            // Fetching Benefits Renewal RecordType Id
            String BenefitsRenewalRT  = OpportunityBenefits_Service.BenefitsRenewalRT;
            Opportunity renewalOpportunity = new Opportunity(
                Name = opportunityName,
                AccountId = acc.Id,
                CloseDate = acc.BBSI_Benefits_Renewal_Date__c,
                StageName = Opportunity_Service.firstStage(Opportunity_Service.RECORDTYPE_BENEFITS_RENEWAL), //Opportunity_Service.STAGE_BENEFITS_UW_RELEASED,
                OwnerId = opportunityOwnerId,
                Insurance_Medical_Renewal__c = masterPlanRenewalDate,                
                RecordTypeId = BenefitsRenewalRT,
                PEO_Referral_Partner__c = acc.Assigned_Referral_Partner__c,   
                PEO_Producer__c = acc.Producer__c,
                Benefits_Affiliates__c = acc.Benefits_Affiliates__c,
                Benefits_Affiliated_Companies__c = acc.Benefits_Affiliated_Companies__c,            
                Number_of_Affiliated_Companies__c = (acc.Benefits_Affiliates__c != null 
                                                     && acc.Benefits_Affiliates__r.Benefits_Affiliated_Companies_Count__c>0)
                                                    ? acc.Benefits_Affiliates__r.Benefits_Affiliated_Companies_Count__c : 0
            );
            renewalOpportunities.add(renewalOpportunity);
        }

        if (!renewalOpportunities.isEmpty()) {
            insert renewalOpportunities;

            // Update the Account so that the Account is not picked again by Schedular in the current renewal cycle.
            List<Account> benRenOppAccount = new List<Account>();
            for (Opportunity benRenOpp : renewalOpportunities) {
                benRenOppAccount.add(new Account(Id = benRenOpp.AccountId, Is_Benefits_Renewal_Opp_Generated__c = True));
            }
            if (!benRenOppAccount.isEmpty()) update benRenOppAccount;
        }        
    }
    
    // Method to perform any post-processing after batch execution
    @SuppressWarnings('PMD.EmptyStatementBlock')
    public void finish(Database.BatchableContext BC) {
        // Any post-processing steps can go here
    }
    private Integer getDaysForBenefitsRenewal() {
        OrgWide__c orgWide = OrgWide__c.getOrgDefaults();

        if (orgWide.Days_Benefits_Renewal_Date__c != null && orgWide.Days_Benefits_Renewal_Date__c >0) {
            return Integer.valueOf(orgWide.Days_Benefits_Renewal_Date__c);
        }

        return DEFAULT_DAYS_FOR_BENEFITTS_RENEWAL;
    }
}