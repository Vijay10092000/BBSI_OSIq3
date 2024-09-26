/**
 * @description PricingTemplateWcCodes_Batch deletes old PricingTemplateWcCode__c in batches.
 */
public class PricingTemplateWcCodes_Batch implements Database.Batchable<PricingTemplateWcCode__c> {
    private static final String QUERY =
        'SELECT Id ' +
        'FROM PricingTemplateWcCode__c ' +
        'WHERE CreatedDate < LAST_90_DAYS ' +
        'ORDER BY CreatedDate ASC ' +
        'LIMIT 20000';

    public List<PricingTemplateWcCode__c> start(Database.BatchableContext context) {
        return (List<PricingTemplateWcCode__c>) Database.query(QUERY);
    }

    public void execute(Database.BatchableContext context, List<SObject> scope) {
        List<Database.DeleteResult> results = Database.delete(scope, false);

        Log.writeIfError(
            'PricingTemplateWcCodes_Batch',
            'execute',
            'Delete of PricingTemplateWcCode__c Failed',
            results
        );
    }

    public void finish(Database.BatchableContext context) {
    }
}