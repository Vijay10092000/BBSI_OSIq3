public without sharing class BusinessUnitEmail_Controller {
	
  public ID AreaManagerID {get;set;}
  public ID BranchID {get;set;}
  public String tableWidth {get;set;}
  public map<String,ID> branchesIdsByBranch {get;set;}
  public BusinessUnitEmail_Controller() {
     this.tableWidth = '500px';
	}

  public map<String,List<BU_Wrapper>> getBusinessUnits(){
   
    Map<String,List<BU_Wrapper>> BusinessUnits = new Map<String,List<BU_Wrapper>>();
    branchesIdsByBranch = new map<String,ID>();
    User AreaManager = [Select ID, Name,Email from User where id =: AreaManagerID limit 1];
    Map<ID,List<Business_Unit__c>> BUByAccount = new Map<ID,List<Business_Unit__c>>();
    Map<ID,List<Business_Unit_Contact__c>> BUContactsByBU = new Map<id,List<Business_Unit_Contact__c>>();
    Set<ID> BUIDs = new Set<ID>();
    Set<ID> branchIDs = new Set<ID>();
    if(BranchID == null){
      branchIDs = getBranchIDs(AreaManager);
    }else{
      branchIDs.add(branchID);
    }

    map<ID,Account> branches = new map<ID,Account>();
    
    For(Account branch: [Select ID, Name,(Select ID,Name from Business_Units__r) FROM Account where ID IN: branchIDs]){
      BUByAccount.put(Branch.ID,Branch.Business_Units__r);
      branches.put(Branch.ID,Branch);
      branchesIdsByBranch.put(Branch.Name,Branch.ID);
      for(Business_Unit__c BU: Branch.Business_Units__r){
        BUIDs.add(BU.ID);
      }
    }

    for(Business_Unit_Contact__c contact: [Select ID,Business_Unit__c, BU_Member__r.Name,BU_Member__r.User_Id__r.EmployeeNumber, Role__c from Business_Unit_Contact__c where Business_Unit__c in: BUIDs And Active__c = true]){
      if(BUContactsByBu.ContainsKey(contact.Business_Unit__c)){
        BUContactsByBu.get(contact.Business_Unit__c).Add(contact);
      }else{
        BUContactsByBu.put(contact.Business_Unit__c,New List<Business_Unit_Contact__c>{contact});
      }
    }

    for(ID accountID: BUByAccount.keySet()){
        List<BU_Wrapper> tempWrapperList = new list<BU_Wrapper>();
       for(Business_Unit__c BU: BUByAccount.get(accountID)){
           tempWrapperList.Add(New BU_Wrapper(BU.Name,BU.ID,BUContactsByBu.Get(BU.ID)));
       }
       BusinessUnits.put(branches.get(AccountID).Name,tempWrapperList);
    }
   
    return BusinessUnits;
  }

  private set<id> getBranchIDs(User AreaManager){
    set<id> Branches = new Set<id>();
    ID BBSIBranchID = RecordTypeService.getId('Account','BBSI_Branch');
    for(Account a: [SELECT Id from Account where RecordTypeID =: BBSIBranchID AND Branch_Manager__c =: AreaManager.Name]){
      Branches.add(a.id);
    }
    return Branches;
  }

  public class BU_Wrapper{
    public String BUName{get;set;}
    public ID BUID {get;set;}
    public List<Business_Unit_Contact__c> BUContacts{get;set;}
    public BU_Wrapper(String BUName, ID BUID, list<Business_Unit_Contact__c>Contacts){
      this.BUName = BUName;
      this.BUContacts = Contacts;
      this.BUID = BUID;
      setHRPID();
    }
    private void setHRPID(){
      if(BUContacts != null){
        for(Business_Unit_Contact__c buc: BUContacts){
          if(Buc.BU_Member__r.User_Id__r.EmployeeNumber == null || Buc.BU_Member__r.User_Id__r.EmployeeNumber == ''){
            Buc.BU_Member__r.User_Id__r.EmployeeNumber = 'MISSING';
          }
        }
      }
      
    }
  }
}