/**
 * @description BusinessBlueprintActionCreate calls a routine to create the Business Blueprint docuemnts.
 */
public without sharing class BusinessBlueprintActionCreate {
    @TestVisible
    private static final String FILE_TYPE = '.pdf';

    @TestVisible
    private static final String PAGE_REPORT = '/apex/BusinessBlueprintPDF';

    @TestVisible
    private static final String PDF_BODY_TEST = 'Test Report Body';

    public Business_Blueprint__c blueprint { get; set; }

    /**
     * @description BusinessBlueprintActionCreate constructo
     * @param  controller Standard controller
     */
    public BusinessBlueprintActionCreate(ApexPages.StandardController controller) {
        blueprint = [
            SELECT Id, Name
            FROM Business_Blueprint__c
            WHERE Id = :controller.getId()
            LIMIT 1
        ];
    }

    /**
     * @description createBlueprint create the blueprint for the record
     * @return Page reference back to the Business_Blueprint__c record
     */
    public PageReference createBlueprint() {
        createPDF(blueprint);

        PageReference pageRef = new PageReference('/' + blueprint.Id);
        pageRef.setRedirect(true);

        return pageRef;
    }

    /**
     * @description createBlueprint creates Blueprint PDF files for the given Ids.
     * @param recordIds Blueprint Identifiers
     */
    @TestVisible
    private void createPDF(Business_Blueprint__c blueprint) {
        PageReference pagePdf = new PageReference(PAGE_REPORT);
        pagePdf.getParameters().put('id', blueprint.Id);

        Blob pdfPageBlob;

        if (Test.isRunningTest()) {
            // getContentAsPDF cannot be called in a test
            pdfPageBlob =  Blob.valueOf(PDF_BODY_TEST);
        } else {
            pdfPageBlob = pagePdf.getContentAsPDF();
        }

        File_Service.createFile(blueprint.Id, blueprint.Name + FILE_TYPE, blueprint.Name, pdfPageBlob);
    }
}