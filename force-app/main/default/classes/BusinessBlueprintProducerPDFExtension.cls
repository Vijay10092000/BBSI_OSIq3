public class BusinessBlueprintProducerPDFExtension {
    
    public Contact c {get; set;}
    
    public BusinessBlueprintProducerPDFExtension(ApexPages.StandardController stdController){
        this.c = [Select Name from Contact where ID =: [Select Producer__c from Producer_Business_Blueprint__c 
                                                        where ID =: ApexPages.currentPage().getParameters().get('Id')].Producer__c limit 1];
    }
    
}