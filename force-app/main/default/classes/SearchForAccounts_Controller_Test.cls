@isTest
private class SearchForAccounts_Controller_Test
{
  @TestSetup 
  static void setup(){
    List<Account> accounts = new List<Account>();

    accounts.add(TestFactory.createAccount('BDMTest', '98662', 'Client', false));
    accounts.add(TestFactory.createAccount('BDMNewTest ','98661','Client',false));
    accounts.add(TestFactory.createAccount('BDMTest 1', '98662', 'Client', false));
    accounts.add(TestFactory.createAccount('BDMNewTest 1','98661','Client',false));
    accounts.add(TestFactory.createAccount('BDMTest 2', '98662', 'Client', false));
    accounts.add(TestFactory.createAccount('BDMNewTest 2','98661','Client',false));
    accounts.add(TestFactory.createAccount('BDMTest 3', '98662', 'Client', false));

    Account a1 = TestFactory.createAccount('BDMNewTest 3','98661','Client',false);
    a1.DBA_Name__c = 'Strange';
    accounts.add(a1);

    Account a2 = TestFactory.createAccount('BDMNewTest 4','98660','Client',false);
    a2.DBA_Name__c = 'Strange Days';
    accounts.add(a2);

    accounts.add(TestFactory.createAccount('ProspectTest', '98662', 'Prospect', false));

    insert accounts;            
  }

    @isTest
    static void testVariousSearches_1()
    {
    PageReference search = Page.SearchForAccounts;
    test.setCurrentPage(search);
    SearchForAccounts_Controller ctrl = new SearchForAccounts_Controller();
    ApexPages.CurrentPage().getParameters().put('searchtext','Test');
    String sHelp= ctrl.getsearchHelpText();
    ctrl.searchRecords();

    System.assertEquals(ctrl.FoundAccounts.size(),10);
  }
  
    @isTest
    static void testVariousSearches_2()
    {
    PageReference search = Page.SearchForAccounts;
    test.setCurrentPage(search);
    SearchForAccounts_Controller ctrl = new SearchForAccounts_Controller();
    ApexPages.CurrentPage().getParameters().put('searchtext','bdmtest');
    ctrl.searchRecords();
    System.assertEquals(ctrl.FoundAccounts.size(),4);
  }
    @isTest
    static void testVariousSearches_3()
    {
    PageReference search = Page.SearchForAccounts;
    test.setCurrentPage(search);
    SearchForAccounts_Controller ctrl = new SearchForAccounts_Controller();
    ApexPages.CurrentPage().getParameters().put('searchtext','bdmtest');
    ctrl.searchRecords();
    System.assertEquals(ctrl.FoundAccounts.size(),4);
    }
  
    @isTest
    static void testVariousSearches_4()
    {
    PageReference search = Page.SearchForAccounts;
    test.setCurrentPage(search);
    SearchForAccounts_Controller ctrl = new SearchForAccounts_Controller();
    ApexPages.CurrentPage().getParameters().put('searchtext','NEW');
    ctrl.searchRecords();
    System.assertEquals(ctrl.FoundAccounts.size(),5);
  }
    @isTest
    static void testVariousSearches_5()
    {
    PageReference search = Page.SearchForAccounts;
    test.setCurrentPage(search);
    SearchForAccounts_Controller ctrl = new SearchForAccounts_Controller();    
    ApexPages.CurrentPage().getParameters().put('searchtext','BDMTest 2');
    ctrl.searchRecords();
    System.assertEquals(ctrl.FoundAccounts.size(),1);
  }
    @isTest
    static void testVariousSearches_6()
    {
    PageReference search = Page.SearchForAccounts;
    test.setCurrentPage(search);
    SearchForAccounts_Controller ctrl = new SearchForAccounts_Controller();
    ApexPages.CurrentPage().getParameters().put('searchtext','Strange');
    ctrl.searchRecords();
    System.assertEquals(ctrl.FoundAccounts.size(),2);

    }
    @isTest
    static void testVariousSearches_7()
    {
    PageReference search = Page.SearchForAccounts;
    test.setCurrentPage(search);
    SearchForAccounts_Controller ctrl = new SearchForAccounts_Controller();
    ApexPages.CurrentPage().getParameters().put('searchtext','Strange D');
    ctrl.searchRecords();
    System.assertEquals(ctrl.FoundAccounts.size(),1);
    }
    @isTest
    static void testVariousSearches_8()
    {
    PageReference search = Page.SearchForAccounts;
    test.setCurrentPage(search);
    SearchForAccounts_Controller ctrl = new SearchForAccounts_Controller();
    ApexPages.CurrentPage().getParameters().put('searchtext','S');
    ctrl.searchRecords();
    System.assertEquals(ctrl.FoundAccounts.size(),0);
    }
    @isTest
    static void testVariousSearches_9()
    {
    PageReference search = Page.SearchForAccounts;
    test.setCurrentPage(search);
    SearchForAccounts_Controller ctrl = new SearchForAccounts_Controller();
    ApexPages.CurrentPage().getParameters().put('searchtext','');
    ctrl.searchRecords();
    System.assertEquals(ctrl.FoundAccounts.size(),0);
    }
  
}