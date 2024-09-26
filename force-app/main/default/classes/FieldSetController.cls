public without sharing class FieldSetController {
    
    @AuraEnabled
    public static Wrapperclass fieldList(String idCase) {
        List<Case> caseList = [SELECT Id, Primary_Form__c, Primary_Form__r.Name FROM Case WHERE Id = :idCase];
        if (caseList.isEmpty() || caseList[0].Primary_Form__c == null) {
            return null;
        }

        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get('Form__c');
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();

        String caseSetName = caseList[0].Primary_Form__r.Name;
        caseSetName = caseSetName.replace(' ', '_');
        
        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(caseSetName);
        List<String> strListApi = new List<String>();

        for (Schema.FieldSetMember f : fieldSetObj.getFields() ) {
            strListApi.add(f.getFieldPath());
        }

        Wrapperclass c = new Wrapperclass();
        c.listApi = strListApi;
        c.formId = caseList[0].Primary_Form__c;
        return c;
    }
    
}