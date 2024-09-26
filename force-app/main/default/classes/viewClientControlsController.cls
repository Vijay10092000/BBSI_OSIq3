public with sharing class viewClientControlsController {
	
  public Account currentAccount {get;set;}
  
  public List<Client_Control__c> getControls(){

    ID AccountID = (ID)ApexPages.CurrentPage().getParameters().get('acctID');
    String sQuery = 'SELECT ID,Name';
    for(Schema.FieldSetMember field : getFields()){ 
      sQuery +=','+field.getFieldPath();
    }
    sQuery += ' FROM Client_Control__c where Account__c =: AccountID Order by CreatedDate DESC';
    return (List<Client_Control__c>)Database.Query(sQuery);
  }

  public Account getAccount(){
    
    System.Debug('Getting Account');
    ID AccountID = (ID)ApexPages.CurrentPage().getParameters().get('acctID');
    String sQuery = 'SELECT ID,Name';
    for(Schema.FieldSetMember field : getAcctFields()){ 
      sQuery +=','+field.getFieldPath();
    }
    sQuery += ' FROM Account where ID =: AccountID limit 1';
    Account act = (Account)Database.Query(sQuery)[0]; 
    System.Debug('Act ID: ' + AccountID + ' ' + act);
    return act;
  }

  public List<Schema.FieldSetMember> getAcctFields(){
    return Schema.SObjectType.Account.FieldSets.getMap().get('Price_Approval_To_Unapproved').getfields();
  }
  
  public List<Schema.FieldSetMember> getfields(){
    
    return  Schema.SObjectType.Client_Control__c.fieldSets.getMap().get('RelatedList').getFields();
  }
  
}