/**
 * @description BenefitsUpdate_Batch update Benefits__c records using a batch process.
 */
public with sharing class BenefitsUpdate_Batch implements Database.Batchable<sObject> {
    public List <Benefits__c> benefits = new List<Benefits__c>();

    /**
     * @description BenefitsUpdate_Batch constructor.
     * @param  benefits  List of Benefits__cs to update in a batch process
     */
    public BenefitsUpdate_Batch(List<Benefits__c> benefits) {
        this.benefits = benefits;
    }

    /**
     * @description start retrieves the list of records to process
     * @param  context  Information about the Batch job, including Id
     * @return List<Benefits__c>
     */
    public List<Benefits__c> start(Database.BatchableContext context) {
        return benefits;
    }

    /**
     * @description execute performs the operation on a batch of objects.
     * @param  context Information about the Batch job, including Id
     * @param  scope   Contains the Client Benefits__cs to process
     */
    public void execute(Database.BatchableContext context, List<sObject> scope) {
        update ((List<Benefits__c>) scope);
    }

    /**
     * @description finish performs actions after processing has completed.
     * @param  context Information about the Batch job, including Id
     */
    @SuppressWarnings('PMD.EmptyStatementBlock')
    public void finish(Database.BatchableContext context) {
    }
}