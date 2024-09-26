@isTest
private class AD_UsernameTest {
    @TestSetup
	static void makeData() {
		Account branch1 = TestFactoryAccount.makeBranch('TEST BRANCH', '910', null, null);
        Account Branch2 = TestFactoryAccount.makeBranch('TestBranch', '98662', null, null);
        Branch2.Branch_Manager__c = 'TestName';
        List<Account> Branchs = new List<Account>{branch1, branch2};
        insert Branchs;
	}
    @isTest static void singleAccountPEO() {
        
        User u = TestFactoryUser.makeUser(null,'testName','BBSI Standard', '910');        
        u.AD_Username__c = 'bbsi';
        u.isActive = TRUE;
        insert u;
        
        Account a = TestFactoryAccount.makeClient('testAcct', null,null);
        a.AD_Username__c = 'BBSI';
        a.External_ID__c = '999875';        
        insert a;   
        
        Assert.areEqual([Select OwnerID from Account where ID =: a.ID].OwnerID, u.ID);
        
    }
    
    @isTest static void singleAccountStaffing() {
        User u = TestFactoryUser.makeUser(null,'TestName','Area Manager', '910');        
        u.isActive = TRUE;
        u.Title  = 'Area Manager';
        u.AD_Username__c = 'TName';
        insert u; 
        
        Account a = TestFactoryAccount.makeClient('testAcct', null, null);
        a.AD_Username__c = 'test';
        a.External_ID__c = '100000';
        a.Branch__c = 'TestBranch';
        a.ShippingPostalCode = '98662';
        insert a;  
        
        Assert.areEqual([Select OwnerID from Account where ID =: a.ID].OwnerID, u.ID);
		
    }
    
    @isTest static void bulkAccountOwnership() {
        User u1 = TestFactoryUser.makeUser(null,'testPEO','BBSI Standard', '910'); 
        u1.AD_Username__c = 'test';
        insert u1;
        
        User u2 = TestFactoryUser.makeUser(null,'testStaffing','BBSI Standard', '910'); 
        u2.AD_Username__c = 'BBSI';
        insert u2;
        
        list<Account> accList = new list<Account>();
        
        for(Integer x = 0; x <= 10; x++){
            Account a = new Account();
            a = TestFactoryAccount.makeClient('testAcct', null,null);
            a.AD_Username__c = 'test';
            a.External_ID__c = String.valueOf(Integer.valueOf(100000) + Integer.valueOf(x));
            accList.add(a);            
        }      
        
        for(Integer x = 0; x <= 10; x++){
            Account a = new Account();
            a = TestFactoryAccount.makeClient('testAcct', null,null);
            a.AD_Username__c = 'BBSI';
            a.External_ID__c = String.valueOf(Integer.valueOf(900000) + Integer.valueOf(x));
            accList.add(a);            
        }                
        insert accList;        
    }
    
    @isTest static void LocationAccountTest(){
        User u = TestFactoryUser.makeUser(null,'testName','BBSI Standard', '910'); 
        u.isActive = TRUE;
        u.AD_Username__c = 'BBSI';
        insert u;
        
        Account a1 = TestFactoryAccount.makeAccount('testAcct', 'Location');
        a1.AD_Username__c = 'BBSI';
        a1.External_ID__c = '999875.1';
        insert a1;

        Account a2 = TestFactoryAccount.makeAccount('testAcct', 'Location');
        a2.AD_Username__c = 'bbsi';
        a2.External_ID__c = '999875.TEST';
        insert a2;
        
        
        Assert.areEqual([Select OwnerID from Account where ID =: a1.ID].OwnerID, u.ID);
        Assert.areEqual([Select OwnerID from Account where ID =: a2.ID].OwnerID, u.ID);  	
    }
    
}