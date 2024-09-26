public without sharing class Form_Services {
    
    /**
     * if form record created, then update primary form field in parent case with that form record 
     **/
    public static void updateCaseWithForm(Map<id,Form__c> newValues){ 
         List<Case> updatedCases = new List<Case>();
         for (Id formId : newValues.keySet()){
            Form__c temp = newValues.get(formId);
            if(temp.Case__c != null) {
                Case updatedCase = new Case();
                updatedCase.Id = temp.Case__c;
                updatedCase.Primary_Form__c = formId;
                updatedCases.add(updatedCase);
            }
        }
        update updatedCases;
    }
}