public class BusinessBlueprintProducerExtension {
    
    public Producer_Business_Blueprint__c pb{
        get;
        set;
    }
    
    private Attachment a = new Attachment();
    private final ID BlueprintID = ApexPages.currentPage().getParameters().get('id');
    private final ID contactID =  ApexPages.currentPage().getParameters().get('CF00N50000008Ez7o_lkid');

    public BusinessBlueprintProducerExtension(ApexPages.StandardController stdController) {
        if (contactID != NULL) {
            this.pb = new Producer_Business_Blueprint__c();
            this.pb.Producer__c = [Select ID, Name from Contact where ID =: contactID].ID;
        }else{
            this.pb = [Select Name, Producer__c, Company_Purpose__c, Business_Analysis__c, Identification__c, Plan_Development__c
                from Producer_Business_Blueprint__c where ID =: BlueprintID];
        }
    }
    
    public pageReference Save() {
        getBusinessBlueprintProducer();
        try {
            if(this.pb.name == NULL){
                this.pb.name = [Select Name from Contact where ID =: this.pb.Producer__c].Name + ' Blueprint';
            }
            upsert this.pb;
        }
        catch (DMLException e) {
            System.debug(e);
        }
        PageReference pageRef = new PageReference('/'+ pb.ID);
        return pageRef;
    }
    public void archivePDF() {
        PageReference pagePdf = new PageReference('/apex/BusinessBlueprintProducerPDF');
        pagePdf.getParameters().put('id', this.pb.id);
        Blob pdfPageBlob;
        try{
            if(Test.isRunningTest()) { 
  				pdfPageBlob = blob.valueOf('Unit.Test');
            } else {
	            pdfPageBlob = pagePdf.getContentAsPDF();
            }
            this.a.Body = pdfPageBlob;
            this.a.ParentID = this.pb.ID;
            if(this.pb.name != NULL){
                this.a.Name = String.valueOf(this.pb.Name);    
            }else{
                this.a.Name = [Select Name from Contact where ID =: this.pb.Producer__c].Name + ' Blueprint';
            }           
            this.a.contentType = '.pdf';
            insert a;            
        }catch(exception e){
           System.debug(e); 
        }

    }
    public PageReference clickCancel(){
        PageReference pageDetail = new PageReference('/'+this.pb.ID);
        pageDetail.setRedirect(true);
        return pageDetail;
    }
    public Producer_Business_Blueprint__c getBusinessBlueprintProducer() {
        return this.pb;
    }
    
}