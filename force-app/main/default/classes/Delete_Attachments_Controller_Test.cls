@isTest
private class Delete_Attachments_Controller_Test
{
	@TestSetup
  static void setup(){

    list<User> uList = new list<User>();

    User AreaManager = TestFactory.createUser('Manager', 'AreaManager@bbsihq.com', 'AreaManager@bbsihq.com', 'Area Manager', '100', false);
    AreaManager.FirstName = 'Area';
    AreaManager.title = 'Area Manager';
    AreaManager.IsActive = true;
    AreaManager.Branch_ID__c = '910';
    uList.add(AreaManager);

    User u = TestFactory.createUser('BDMUser', 'TestBBSI_deleteAttachment@bbsihq.com', 'TestBBSI_deleteAttachment@bbsihq.com', 'BBSI Standard', '101', false);
    u.title = 'Business Development Manager';
    u.Isactive = true;
    u.Branch_ID__c = '910';
    uList.add(u);

    insert uList;

    list<Account> testAccts = new list<Account>();

    Account Branch = new Account();
    Branch.Name = 'TestBranch1';
    Branch.Region__c = 'SoCal';
    Branch.Zone__c = '1';
    Branch.External_ID__c = 'AAA';
    Branch.recordTypeID = RecordTypeService.getId('Account','BBSI Branch');
    testAccts.add(Branch);


    Business_Unit__c BU1 = testFactory.createBusinessUnit('Test BU',Branch , true);
    Contact c = TestFactory.createContact(Branch, 'BU Contact', 'BBSI Employee', false);
    c.User_Id__c = u.ID;
    insert c;

    Business_Unit_Contact__c buc = testFactory.createBusinessUnitContact(BU1, true, 'Payroll Specialist', false);
    buc.Active__c = true;
    buc.BU_Member__c = c.ID;
    buc.Active_Date__c = System.Today();
    insert buc;

    Account client = TestFactory.CreateAccount('Test Account Delete Attach', '97219', 'Client', false);
    client.OwnerId = AreaManager.Id;
    client.Business_Unit__c = BU1.ID;
    client.External_ID__c = '123999';
    insert client;

    System.runAs(AreaManager){
    	Contact c1 = testFactory.createContact(branch,'Dave Smith','Client Contact',false);
      c1.AccountId = client.ID;
      insert c1;

      Blob b = Blob.valueOf('Test Data');

      list<Attachment> attachments = new list<Attachment>();
      attachments.add(New Attachment(parentId = Client.ID,
                                     Name = 'Test Attachment for Account',
                                     Body = b));


      list<Note> notes = new list<Note>();
      notes.add(new Note( title='Test Note',
                          ParentId = client.ID));
      Date CloseDate = System.Today().AddDays(30);
      Opportunity opp = testFactory.createOpportunity('Test Opp',client, CloseDate,'Close Won',true);
      notes.add(new Note(Title = 'Test Contact Note', ParentId = c1.id));
      notes.add(new Note(Title = 'Test Opp note',ParentId = opp.id));
      insert notes;
      attachments.add(New Attachment(parentId = Opp.ID,
                                      Name = 'Test Attachment for Opp',
                                      Body = b));
      attachments.add(New Attachment(parentId = c1.ID,
                                      Name = 'Test Attachment for Cont',
                                      Body = b));
      insert attachments;
    }


  }

  @isTest
	static void testDeletingAttachment()
	{
		User u = [Select ID FROM User where UserName = 'TestBBSI_deleteAttachment@bbsihq.com' limit 1];
    PageReference page1 = Page.Delete_Attachments;
    Test.setCurrentPage(page1);
    Account a = [Select ID from Account where External_ID__c = '123999' limit 1];
    test.StartTest();
      System.runAs(U){
        ApexPages.CurrentPage().getParameters().put('id',a.id);
        Delete_Attachments_Controller controller = new Delete_Attachments_Controller();
        for(Delete_Attachments_Controller.ObjectWrapper ow: controller.NotesAndAttachmentsList){
          ow.DeleteRecord = true;
        }
        controller.deleteRecords();
      }
      System.assertEquals([Select Count() from Attachment where ParentId =: a.id],0);
    test.StopTest();
	}
}