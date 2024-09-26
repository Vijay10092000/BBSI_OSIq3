public class CandidateSubmitApprovalExtension {

    public Candidate__c c {get; set;}    
    public Boolean checkValues {get; set;}
    public List<String> missingValues {get; set;}
    
    public CandidateSubmitApprovalExtension(ApexPages.StandardController stdController){
        this.c = [Select ID, Start_Date__c, Years_of_Experience__c, Est_Annual_Compensation__c, Interviews__c 
                  from Candidate__c where ID =: apexpages.currentpage().getparameters().get('id')];
        checkValues();
    }
    
    private void CheckValues(){
        this.checkValues = true;
        this.missingValues = new List<String>();
        
        if(this.c.Start_Date__c == NULL){
            missingValues.add('StartDate');
        	this.checkValues = false;    
        }
        if(this.c.Years_of_Experience__c == NULL){
            missingValues.add('Years of Expirience');
        	this.checkValues = false;    
        }
        if(this.c.Est_Annual_Compensation__c == NULL){
            missingValues.add('Estimated Annaul Compensation');
        	this.checkValues = false;    
        }
        if(this.c.Interviews__c < 1){
            missingValues.add('Interviews');
        	this.checkValues = false;    
        }
    }
    
    public void submitRecordForApproval(){
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest(); 
		//ID userId = [Select ID from User where ID ]
        
        req1.setObjectID(this.c.ID);
        req1.setSubmitterId(UserInfo.getUserId());
        req1.setProcessDefinitionNameOrId('New_Hire_Candidate');
        Approval.ProcessResult result = Approval.process(req1);

    }
}