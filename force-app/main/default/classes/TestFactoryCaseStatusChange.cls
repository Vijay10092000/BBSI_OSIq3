/**
 * @description TestFactoryCaseStatusChange contains methods to create test casestatuschange.
 */
@isTest
public class TestFactoryCaseStatusChange {
    /**
	 * @description createCaseStatusChange creates a new CaseStatusChange record in the database.
	 * @param  caseId  Id of   case
	 * @param  Name  Name of the CaseStatusChange
	 * @param  StatusName  Status of the CaseStatusChange
	 * @return casestachange
	 */
  
    public static Case_Status_Change__c createCaseStatusChange(Id caseId,String Name,String StatusName){
      Case_Status_Change__c casestachange = makeCaseStatusChange(caseId,Name,StatusName);	
	  insert casestachange;
	  return casestachange;
    }
     /**
	 * @description createCaseStatusChange creates a new CaseStatusChange record in the database.
	 * @param  caseId      Id of   case
	 * @param  Name        Name of the CaseStatusChange
	 * @param  StatusName  Status of the CaseStatusChange
	 * @return casestachange
	 */
	public static Case_Status_Change__c makeCaseStatusChange(Id caseId,String Name,String Status){
        Case_Status_Change__c casestachange = new Case_Status_Change__c();
		casestachange.Name = Name;
        casestachange.Case__c = caseId;
        casestachange.Status_Name__c = Status;
        casestachange.Set_Time__c = Datetime.now();   
        return casestachange;
    }
    

}