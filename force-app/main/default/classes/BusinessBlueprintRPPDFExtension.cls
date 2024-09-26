/**
 * @description BusinessBlueprintRPPDFExtension
 */
public without sharing class BusinessBlueprintRPPDFExtension {
    /**
     * @description account get/set related Account.
     */
    public Account account { get; set; }

    /**
     * @description BusinessBlueprintExtension get/set the working Business_Blueprint_RP__c.
     */
    public Business_Blueprint_RP__c blueprint { get; set; }

    /**
     * @description forReferralPartner
     */
    public Boolean forReferralPartner { get; set; }

    /**
     * @description BusinessBlueprintRPPDFExtension constructor
     * @param  controller Standard Controller
     */
    @SuppressWarnings('PMD.AvoidsystemDebugUsage')
    public BusinessBlueprintRPPDFExtension(ApexPages.StandardController controller) {
        blueprint = [
            SELECT Id, Name, Client__c, Business_Unit__c, Business_Analysis__c, Company_Purpose__c,
                Identification__c, Plan_Development__c, LastModifiedDate
            FROM Business_Blueprint_RP__c
            WHERE Id = :controller.getId()
            LIMIT 1
        ];

        account = [
            SELECT Id, Name, RecordType.Name
            FROM Account
            WHERE Id = :blueprint.Client__c
            LIMIT 1
        ];

        forReferralPartner = (account.RecordType.Name == 'Referral Partner');

        System.debug(
            LoggingLevel.DEBUG,
            'BusinessBlueprintPDFExtension' +
            '\n. account: ' + account +
            '\n. forReferralPartner: ' + forReferralPartner +
            '\n. Blueprint: ' + blueprint
        );
    }
}