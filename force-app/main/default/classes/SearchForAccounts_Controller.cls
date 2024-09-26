public without sharing class SearchForAccounts_Controller {
	public Account[] foundAccounts {get;set;}
  public String searchText {get;set;}
 
  public SearchForAccounts_Controller() {
		foundAccounts = new Account[]{};
 	}

  public string getsearchHelpText(){
    String HelpText = 'To find Accounts, begin typing. Results will appear after the 2nd letter. Only the first 50 matches are returned.';
    return HelpText;
  }

  public void searchRecords(){
    searchText = ApexPages.CurrentPage().getParameters().get('searchText');
    System.Debug('SearchText');
    if(validSearchText()){
      String interanlSearchText = '%' + this.SearchText + '%';
      String sQuery = 'Select Id,Name,Business_Unit__r.Name, Business_Development_Manager__r.Name, BillingCity,BillingState,DBA_Name__c,Prospect_Branch__r.Name,RecordType.Name FROM Account where';
      sQuery += ' DBA_Name__c like : interanlSearchText OR Name like : interanlSearchText Order by Name limit 50';
      System.Debug(sQuery);
      FoundAccounts = (Account[])Database.Query(sQuery);
    }else{
      foundAccounts = new Account[]{};
    }
  }

  private boolean validSearchText(){
    boolean returnVal = true;
    if(searchText == null || this.SearchText == ''){
      returnVal = false;
    }else{
      if(this.searchText.length() < 2){
        returnVal = false;
      }
    }

    return returnVal;
  }

}