public with sharing class AreaManagerBuMemberShip_Controller {
	
  Public User AreaManager {get;set;}
  Public ID BranchID {get;set;}
  
  private Profile AreaManagerProfile;
  private map<id,String> BranchManagersByBranch = new Map<ID,String>();
  public AreaManagerBuMemberShip_Controller() {
    AreaManagerProfile = [Select ID FROM Profile where name = 'Area Manager' limit 1];
    BranchID = ApexPages.currentPage().getParameters().get('BR');
    
    getBranchOptions();

    if(BranchID != null){
 	    getAreaManagerUser();
    }
  }

  public pageReference getAreaManagerUser(){
 
      String BranchManager = BranchManagersByBranch.get(BranchID);
      AreaManager = [Select ID, Name, Branch_ID__c FROM User where Name =: BranchManager and ProfileID =:AreaManagerProfile.ID LIMIT 1];
      return null; 
  }

  public List<SelectOption> getBranchOptions() {

   List<SelectOption> branchOptions = new List<SelectOption>();
    
   ID branchRecordTypeID = RecordTypeService.getId('Account','BBSI_Branch');
   For(Account act: [Select ID, Name, Branch_Manager__c FROM Account where RecordTypeID =: branchRecordTypeID and 
                             External_ID__c != null order By Name]){
      BranchManagersByBranch.put(act.id,act.Branch_Manager__c);
      branchOptions.add(new SelectOption(act.ID,
                                         act.Name));
   }

    if(BranchID == null){
       BranchID = (ID) branchOptions[0].getValue();
       getAreaManagerUser();
       System.Debug('AreaManager: ' + AreaManager);
    }



    return branchOptions;
  }
}