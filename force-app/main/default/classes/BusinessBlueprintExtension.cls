/**
 * @description BusinessBlueprintExtension
 */
public without sharing class BusinessBlueprintExtension {

    /**
     * @description blueprint get/set the working Business_Blueprint__c.
     */
    public Business_Blueprint__c blueprint { get; set; }

    /**
     * @description forReferralPartner
     */
    public Boolean forReferralPartner { get; set; }

    /**
     * @description timeOut get/set milliseconds for auto-save.
     */
    public Integer timeOut { get; set; }

    /**
     * @description BusinessBlueprintExtension constructor.
     * @param  stdController Standard Controller
     */
    @SuppressWarnings('PMD.AvoidsystemDebugUsage')
    public BusinessBlueprintExtension(ApexPages.StandardController stdController) {
        System.debug(
            LoggingLevel.DEBUG,
            'BusinessBlueprintExtension' +
            '\n. Client Id: ' + stdController.getId() +
            '\n. Blueprint Id: ' + stdController.getRecord() +
            '\n. Time Out: ' + timeOut +
            '\n. For Referral Partner: ' + forReferralPartner +
            '\n. Blueprint: ' + blueprint
        );

        setup((Business_Blueprint__c) stdController.getRecord());
    }

    /**
     * @description setup load the data for the class.
     * @param  blueprint Business Blueprint record
     */
    @TestVisible
    private void setup(Business_Blueprint__c inBlueprint) {
        timeOut = getActualTimeOut();

        blueprint = inBlueprint;

        if (blueprint.Id != null) {
            blueprint = [
                SELECT Id, Name, Client__c, Business_Unit__c, Business_Analysis__c, Company_Purpose__c,
                    Identification__c, Plan_Development__c, LastModifiedDate
                FROM Business_Blueprint__c
                WHERE Id = :blueprint.Id
                LIMIT 1
            ];
        }

        if (String.isBlank(blueprint.Name)) {
            String nameAccount = [SELECT Name FROM Account WHERE Id = :blueprint.Client__c LIMIT 1].Name;
            blueprint.Name = nameAccount + ' Blueprint';
        }

        forReferralPartner = getForReferralPartner(blueprint.Client__c);
    }

    /**
     * @description submit saves the blueprint and goes to the record.
     * @return PageReference
     */
    public PageReference submit() {
        try {
            saveRecord();
            return new PageReference('/'+ blueprint.Id);
        } catch (DMLException e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }

        return null;
    }

    /**
     * @description saveRecord writes the blueprint record to the database.
     */
    public void saveRecord() {
        upsert blueprint;
    }

    /**
     * @description cancel determines which page a cancel goes to.
     * @return PageReference
     */
    public PageReference cancel() {
        String idReturn = (blueprint.Id == null) ? blueprint.Client__c : blueprint.Id;

        PageReference pageDetail = new PageReference('/' + idReturn);
        pageDetail.setRedirect(true);

        return pageDetail;
    }

    /**
     * @description getActualTimeOut retrieves the auto save timeout.
     * @return Timeout in millseconds
     */
    @TestVisible
    private Integer getActualTimeOut() {
        OrgWide__c orgWide = OrgWide__c.getInstance();
        Integer result = Integer.ValueOf(orgWide.Auto_Save_Blueprint_in_Seconds__c);

        if (result == null) {
            result = 60;
        }

        return result * 1000;
    }

    /**
     * @description getForReferral Partner retrieves whether the Client__c is of type Referral Partner.
     * @param idClient Identifier of the account related to the blueprint
     * @return true if for Referral Partner
     */
    @TestVisible
    private Boolean getForReferralPartner(Id idClient) {
        if (idClient != null) {
            Account client = [SELECT Id, Name, RecordType.Name FROM Account WHERE Id = :idClient];

            if (client.RecordType.Name == 'Referral Partner') {
                return true;
            }
        }

        return false;
    }
}