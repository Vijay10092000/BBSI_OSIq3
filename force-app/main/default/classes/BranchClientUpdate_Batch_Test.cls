/**
 * @description BranchClientUpdate_Batch_Test contains tests for the BranchClientUpdate_Batch class.
 */
@IsTest 
public without sharing class BranchClientUpdate_Batch_Test {
  private static Account branch;
  private static Account client1;
  private static Account client2;

  private static User bc1;
  private static User bc2;
  private static User bc3;
  private static Map<Id, User> bcs;

    @TestSetup
  static void makeData() {
    branch = TestFactoryAccount.createBranch('TEST_BRANCH');
    
    bc1 = TestFactoryUser.makeUser('TEST', 'USER_1', 'BBSI Standard', branch.External_Id__c);
    bc2 = TestFactoryUser.makeUser('TEST', 'USER_2', 'BBSI Standard', branch.External_Id__c);
    bc3 = TestFactoryUser.makeUser('TEST', 'USER_3', 'BBSI Standard', branch.External_Id__c);
    insert new List<User>{ bc1, bc2, bc3 };
    
    branch.Benefits_Consultant__c = bc1.Id;
    update branch;
    
    client1 = TestFactoryAccount.makeClient('TEST_CLIENT_1', null, null);
    client1.Prospect_Branch__c = branch.Id;    
    client2 = TestFactoryAccount.makeClient('TEST_CLIENT_2', null, null);
    client2.Prospect_Branch__c = branch.Id;
    insert new List<Account>{ client1, client2 };
  }

  static void loadData() {
    List<Account> accounts = [
      SELECT Id, Name, OwnerId, External_Id__c, Benefits_Consultant__c, Prospect_Branch__c
      FROM Account 
      WHERE Name LIKE 'TEST_%' 
      ORDER BY Name ASC
    ];

    branch = accounts.get(0);
    client1 = accounts.get(1);
    client2 = accounts.get(2);

    List<User> users = [
      SELECT Id, Name
      FROM USER 
      WHERE FirstName = 'TEST' AND LastName LIKE 'USER_%'
      ORDER BY Name ASC
    ];

    bc1 = users.get(0);
    bc2 = users.get(1);
    bc3 = users.get(2);
    bcs = new Map<Id, User>();
    bcs.put(bc1.Id, bc1);
    bcs.put(bc2.Id, bc2);
    bcs.put(bc3.Id, bc3);

    Assert.areEqual(branch.Id, client1.Prospect_Branch__c);
    Assert.areEqual(bc1.Id, client1.Benefits_Consultant__c);
    Assert.areEqual(branch.Id, client2.Prospect_Branch__c);
    Assert.areEqual(bc1.Id, client2.Benefits_Consultant__c);
  }

  @IsTest
  public static void test_getClients() {    
    loadData();

    Map<Id, Account> oldBranches = new Map<Id, Account>();
    oldBranches.put(branch.Id, branch);

    Map<Id, Account> branches = new Map<Id, Account>();
    branches.put(branch.Id, branch);
    
    Test.startTest();
    
    List<Account> clients = BranchClientUpdate_Batch.getClients(branches);
    
    Test.stopTest();

    Assert.areEqual(2, clients.size());
    
    Assert.areEqual('TEST_CLIENT_1', clients.get(0).Name);
    Assert.areEqual('TEST_CLIENT_2', clients.get(1).Name);
  }

  /**
   * @description test_getBenefitsConsultantChanged change 
   * the Benefits Consultant on the branch.
   */
  @IsTest
  public static void test_getBenefitsConsultantChanged() {    
    loadData();

    client2.Benefits_Consultant__c = bc2.Id;
    update client2;

    List<Account> clients = new List<Account>{ client1, client2 };

    Account oldBranch = branch.clone();
    oldBranch.Benefits_Consultant__c = bc1.Id;

    Map<Id, Account> oldBranches = new Map<Id, Account>();
    oldBranches.put(branch.Id, oldBranch);

    Map<Id, Account> branches = new Map<Id, Account>();
    branch.Benefits_Consultant__c = bc3.Id;
    branches.put(branch.Id, branch);
    
    Test.startTest();
    
    clients = BranchClientUpdate_Batch.getBenefitsConsultantChanged(clients, oldBranches, branches);
    
    Test.stopTest();

    Assert.areEqual(1, clients.size());
    
    Assert.areEqual('TEST_CLIENT_1', clients.get(0).Name);
    Assert.areEqual(bc3.Id, clients.get(0).Benefits_Consultant__c);
  }

  /**
   * @description test_CallBatch test the full batch process.
   */
  @IsTest
  public static void test_CallBatch() {    
    loadData();

    client2.Benefits_Consultant__c = bc2.Id;
    update client2;

    Account oldBranch = branch.clone();
    oldBranch.Benefits_Consultant__c = bc1.Id;

    Map<Id, Account> oldBranches = new Map<Id, Account>();
    oldBranches.put(branch.Id, oldBranch);

    List<Account> branches = new List<Account>();
    branch.Benefits_Consultant__c = bc3.Id;
    branches.add(branch);
    
    Test.startTest();
    
    BranchClientUpdate_Batch.perform(oldBranches, branches);
    
    Test.stopTest();

    List<Account> clients = [
      SELECT Id, Name, Benefits_Consultant__c
      FROM Account
      WHERE Name LIKE 'TEST_CLIENT_%'
      ORDER BY Name ASC
    ];

    Assert.areEqual(2, clients.size());
    
    Account client;
    client = clients.get(0);
    Assert.areEqual('TEST_CLIENT_1', client.Name);
    Assert.areEqual(bc3.Id, client.Benefits_Consultant__c, 'Benefits Consultant Expected: ' + bc3.Name + '  Actual:' + bcs.get(client.Benefits_Consultant__c).Name);
    
    client = clients.get(1);
    Assert.areEqual('TEST_CLIENT_2', client.Name);
    Assert.areEqual(bc2.Id, client.Benefits_Consultant__c, 'Benefits Consultants: Expected: ' + bc2.Name + '  Actual:' + bcs.get(client.Benefits_Consultant__c).Name);
  }

  /**
   * @description test_NewClient tests if the new client will have the Benefits Consultant
   * of the branch.
   */
  @IsTest
  public static void test_NewClient() {
    loadData();

    Account clientNew;

    Test.startTest();
    
    clientNew = TestFactoryAccount.makeClient('TEST_CLIENT_1', null, null);
    clientNew.Prospect_Branch__c = branch.Id;
    
    insert clientNew;
    
    Test.stopTest();

    clientNew = [SELECT Id, Name, Benefits_Consultant__c FROM Account WHERE Id = :clientNew.Id LIMIT 1];

    Assert.areEqual(branch.Benefits_Consultant__c, clientNew.Benefits_Consultant__c, 'Benefits Consultants: Expected: ' + bcs.get(branch.Benefits_Consultant__c).Name + '  Actual:' + bcs.get(clientNew.Benefits_Consultant__c).Name);
  }

  /**
   * @description test_UpdateClient checks if a client with the same Benefits Consultant
   * updates if the branch changes.
   */
  @IsTest
  public static void test_UpdateClient() {
    loadData();

    Account clientNew;        
    clientNew = TestFactoryAccount.makeClient('TEST_CLIENT_1', null, null);
    clientNew.Prospect_Branch__c = branch.Id;    
    insert clientNew;

    Test.startTest();

    branch.Benefits_Consultant__c = bc3.Id;
    update branch;
    
    Test.stopTest();

    clientNew = [SELECT Id, Name, Benefits_Consultant__c FROM Account WHERE Id = :clientNew.Id LIMIT 1];

    Assert.areEqual(branch.Benefits_Consultant__c, clientNew.Benefits_Consultant__c, 'Benefits Consultants: Expected: ' + bcs.get(branch.Benefits_Consultant__c).Name + '  Actual:' + bcs.get(clientNew.Benefits_Consultant__c).Name);
  }

  /**
   * @description test_NotUpdateClient checks if a client with a different Benefits Consultant
   * does not update if the branch changes.
   */
  @IsTest
  public static void test_NotUpdateClient() {
    loadData();

    Account clientNew;        
    clientNew = TestFactoryAccount.makeClient('TEST_CLIENT_3', null, null);
    clientNew.Prospect_Branch__c = branch.Id;  
    insert clientNew;

    clientNew.Benefits_Consultant__c = bc2.Id;
    update clientNew;

    Test.startTest();

    branch.Benefits_Consultant__c = bc3.Id;
    update branch;
    
    Test.stopTest();

    clientNew = [SELECT Id, Name, Benefits_Consultant__c FROM Account WHERE Id = :clientNew.Id LIMIT 1];

    Assert.areEqual(bc2.Id, clientNew.Benefits_Consultant__c, 'Benefits Consultants: Expected: ' + bc2.Name + '  Actual:' + bcs.get(clientNew.Benefits_Consultant__c).Name);
  }
}