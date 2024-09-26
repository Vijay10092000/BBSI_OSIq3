public without sharing class Delete_Attachments_Controller {

  private final ID recordID;
  public Account acct{get;set;}

  public list<ObjectWrapper> NotesAndAttachmentsList {get;set;}

  public Delete_Attachments_Controller() {
    recordID = ApexPages.currentPage().getParameters().get('id');
  
    if(userCanDelete()){
      NotesAndAttachmentsList = new list<ObjectWrapper>();
      setAllParentRecords();
    }else{
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You do not have the proper access to delete notes and attachments.'));  
    }
  }

  private void setAllParentRecords(){
    list<set<ID>> parentIDs = getParentRecords();

    set<id> ContactID = parentIDs[0];
    set<id> OpportunityID = parentIDs[1];
    
    list<sObject> AccountValues = new list<sObject>();
    list<sObject> OpportunityValues = new list<sObject>();
    list<sObject> ContactValues = new list<sObject>();
    NotesAndAttachmentsList = new list<ObjectWrapper>();
    for(Note n: [Select ID, ParentID, Parent.Name, Title, LastModifiedDate,CreatedBy.Name from NOTE 
                 where ParentID =:RecordID Or ParentID in: OpportunityID OR ParentID in: ContactID]){
        if(n.ParentID == recordID){
            AccountValues.add(n);
        }else{
            if(ContactID.Contains(n.ParentID)){
                ContactValues.add(n);
            }else{
                OpportunityValues.add(n);
            }
        }
    }

    for(Attachment n: [Select ID, ParentID, Parent.Name, Name, LastModifiedDate,CreatedBy.Name from Attachment 
                 where ParentID =:RecordID Or ParentID in: OpportunityID OR ParentID in: ContactID]){
        if(n.ParentID == recordID){
            AccountValues.add(n);
        }else{
            if(ContactID.Contains(n.ParentID)){
                ContactValues.add(n);
            }else{
                OpportunityValues.add(n);
            }
        }
    }

    buildWrapper(AccountValues,OpportunityValues,ContactValues);
  }

  private void buildWrapper(list<sObject> AccountVals,list<sObject>oppValues,List<sObject>ContactValues){

    for(integer i=0; i<=2;i++){
        list<sObject> values;
        if(i==0) values = AccountVals;
        if(i==1) values = oppValues;
        if(i==2) values = ContactValues;
        for(sObject o: values){
            NotesAndAttachmentsList.add(new ObjectWrapper(o));
        }
    }
  }

  private list<set<id>> getParentRecords(){
    set<ID> Contacts = new set<ID>();
    set<ID> Opportunities = new set<ID>();

    for(Account a: [Select ID, Name,
                    (Select ID from Contacts),
                    (Select ID from Opportunities)
                    From Account where ID =: recordID]){
        this.acct = a;
        for(Contact c: a.Contacts){
            contacts.add(c.ID);
        }
        for(Opportunity o: a.Opportunities){
            Opportunities.add(o.ID);
        }
    }
    list<set<ID>> returnVal = new list<set<ID>>();
    returnVal.add(Contacts);
    returnVal.add(Opportunities);
    return returnVal;
  }
 
  public void deleteRecords(){

    list<sObject> deleteRecords = new list<sObject>();
    for(ObjectWrapper a: NotesAndAttachmentsList){
        if(a.deleteRecord){
          deleteRecords.add(a.Record);
        }
    }

    if(deleteRecords != null && deleteRecords.size() > 0){
        try{
          delete deleteRecords;
        }catch(exception e){
          ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage());
          ApexPages.addMessage(myMsg);
        }
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Confirm, 'Record Deleted successfully');
        ApexPages.addMessage(myMsg);
    }
    setAllParentRecords();
  } 

  public boolean userCanDelete(){

    System.debug('can delete: ' + this.RecordID + ' : ' + UserInfo.getUserId());
    UserRecordAccess RA = [SELECT RecordID, HasEditAccess 
                           FROM UserRecordAccess where RecordID =: this.RecordID
                           AND UserID =: UserInfo.GetUserID() limit 1];
    return RA.HasEditAccess;
  }

  public class ObjectWrapper{
    public boolean deleteRecord {get;set;}
    public String Title {get;set;}
    public sObject Record {get;set;}
    public String ObjectTypeVal {get;set;}
    public String ObjectName {get;set;}
    public String Type {get;set;}
    public DateTime LastModifiedDate{get;set;}
    public String CreatedBy{get;set;}

    public ObjectWrapper(sObject currentRecord){
      this.deleteRecord = false;
      if(String.ValueOf(currentRecord.getsObjectType()) == 'Note'){
        this.Title = (String)currentRecord.get('Title');
        this.Type = 'Note';
      }else{
        this.Type = 'Attachment';         
        this.Title = (String)currentRecord.get('Name');
      }
      record = currentRecord;
      setObjectValues(record);
      
    }

    public void setObjectValues(sObject obj){
      ID parent = String.ValueOf(obj.get('ParentID'));
      this.ObjectTypeVal = String.ValueOf(parent.getsObjectType());
      System.Debug('objval ' + ObjectTypeVal);
      this.ObjectName = (String)obj.getsObject('Parent').get('Name');
      this.lastModifiedDate = (DateTime)obj.get('LastModifiedDate');
      this.Createdby = (String)obj.getsObject('CreatedBy').get('Name');
    }
  }
}