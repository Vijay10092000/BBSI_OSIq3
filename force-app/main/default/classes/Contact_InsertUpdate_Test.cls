@isTest
private class Contact_InsertUpdate_Test
{
  @testSetup
  static void setup(){
    User u = [Select ID,Name from User where isActive = true and Profile.Name ='System Administrator' limit 1];
    System.runAs(u){
      Account Acct = TestFactory.createAccount('Test Account','97219','Client',false);
        //Account Acct = TestFactoryAccount.makeClient('Test Account',null,null);
      insert Acct;
    }

  }
	@isTest
	static void itShouldUpdateTheContactOwnerToMatchAccount()
	{
		Account a = [Select ID, OwnerID from Account where Name = 'Test Account'];
    User u = [Select ID from User where isActive = true and profile.name ='BBSI Standard' limit 1];
    a.OwnerId = u.id;
    update a;
    System.Debug(u);
    System.runAs(U){
      Contact c = testFactory.CreateContact(a,'Dave Smith', 'Client Contact',true);
      c = [Select ID, OwnerID,Primary__c,AccountID from Contact where AccountID = :a.id limit 1];
      System.assertEquals(c.OwnerId,a.OwnerId);
      System.assertEquals(c.Primary__c,true);
      a = [Select ID, Primary_Contact_Name__c from Account where id =: a.id limit 1];
      System.assertEquals('Dave Smith',a.Primary_Contact_Name__c);
    }
	}
}