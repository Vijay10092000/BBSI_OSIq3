@isTest
public class PopulateBusinessUnitMembers_test {
	
    static testMethod void ContactUpdate(){

        Account testBranch = testFactory.createAccount('Test Branch', '98662', 'BBSI Branch', true);
        Business_Unit__c BU = testFactory.createBusinessUnit('Test BU', testBranch, true);
        Business_Unit_Contact__c buc = testFactory.createBusinessUnitContact(BU, false, 'Payroll Specialist', true);       
        
        Account testClient = testFactory.createAccount('Test Client', '98662', 'Client', false);
        testClient.Business_Unit__c = BU.ID;
        insert testClient;

        User u = testFactory.createUser('Test User', 'test@bbsihq.com', 'test@bbsihq.com', 'BBSI Standard', '910', true);
        Contact c = TestFactory.createContact(testClient, 'BU Contact', 'BBSI Employee', false);
        c.User_Id__c = u.ID;
        insert c;
        
        Business_Unit_Member__c bum = testFactory.createBusinessUnitMember(buc, testClient, true);
		
        buc.BU_Member__c = c.ID;
        buc.Active__c = true;
        buc.Active_Date__c = System.Today();
        buc.Inactive_Date__c = null;
        update buc;
        
        buc.Inactive_Date__c = null;
        buc.Active__c = false;
        buc.Active_Date__c = System.Today().addDays(-1);
        buc.Inactive_Date__c = System.Today();
        update buc;
    }
  
    static testMethod void AccountUpdate(){
        Account testBranch = testFactory.createAccount('Test Branch', '98662', 'BBSI Branch', true);
        Business_Unit__c BU1 = testFactory.createBusinessUnit('Test BU 1', testBranch, true);
		Business_Unit__c BU2 = testFactory.createBusinessUnit('Test BU 2', testBranch, true);
        
        Account testClient = testFactory.createAccount('Test Client', '98662', 'Client', false);
        testClient.Business_Unit__c = BU2.ID;
        insert testClient;        
        
        User u = testFactory.createUser('Test User', 'test@bbsihq.com', 'test@bbsihq.com', 'BBSI Standard', '910', true);
        Contact c = TestFactory.createContact(testClient, 'BU Contact', 'BBSI Employee', false);
        c.User_Id__c = u.ID;
        insert c;
        
        list<Business_Unit_Contact__c> listBUC = new list<Business_Unit_Contact__c>();


        Business_Unit_Contact__c bucA = testFactory.createBusinessUnitContact(BU1, true, 'Payroll Specialist', false);       
        bucA.Active__c = true;
        bucA.BU_Member__c = c.ID;
        bucA.Active_Date__c = System.today();
        listBUC.add(bucA);

        Business_Unit_Contact__c buc1 = testFactory.createBusinessUnitContact(BU2, true, 'Payroll Specialist', false);       
        buc1.Active__c = true;
        buc1.BU_Member__c = c.ID;
        buc1.Active_Date__c = System.today();
        listBUC.add(buc1);

        Business_Unit_Contact__c buc2 = testFactory.createBusinessUnitContact(BU2, true, 'Business Partner', false);       
        buc2.Active__c = true;
        buc2.BU_Member__c = c.ID;
        buc2.Active_Date__c = System.today();
        listBUC.add(buc2);

        Business_Unit_Contact__c buc3 = testFactory.createBusinessUnitContact(BU2, true, 'Risk Consultant', false);       
        buc3.Active__c = true;
        buc3.BU_Member__c = c.ID;
        buc3.Active_Date__c = System.today();
        listBUC.add(buc3);

        insert listBUC;

        
        System.test.startTest();
        testClient.Business_Unit__c = BU1.Id;
        update testClient;

        system.assertEquals(1, [Select ID from Business_Unit_Member__c where Client__c = :testClient.ID].size());
        
        testClient.Business_Unit__c = BU2.ID;
        update testClient;

        system.assertEquals(3, [Select ID from Business_Unit_Member__c where Client__c = :testClient.ID].size());
        
        System.test.stopTest();
 
    }
	
    static testMethod void AreaManagerUpdate(){
        //list<User> listUser = new list<User>();
        list<Contact> listContact = new list<Contact>();

        Account testClient = testFactory.createAccount('Test Client', '98662', 'Client', false);
        
        User u1 = testFactory.createUser('Test User1', 'test1@bbsihq.com', 'test1@bbsihq.com', 'BBSI Standard', '910', true);
        User u2 = testFactory.createUser('Test User2', 'test2@bbsihq.com', 'test2@bbsihq.com', 'BBSI Standard', '910', true);
        User u3 = testFactory.createUser('Test User3', 'test3@bbsihq.com', 'test3@bbsihq.com', 'BBSI Standard', '910', true);
		User AreaManager = testFactory.createUser('Test AreaManager', 'testAM@bbsihq.com', 'testAM@bbsihq.com', 'Area Manager', '910', true);

        system.runAs(AreaManager){
        
        Contact c1 = TestFactory.createContact(testClient, 'BU Contact', 'BBSI Employee', false);
        c1.User_Id__c = u1.ID;        
        listContact.add(c1);
        Contact c2 = TestFactory.createContact(testClient, 'BU Contact', 'BBSI Employee', false);
        c2.User_Id__c = u2.ID;        
        listContact.add(c2);
        Contact c3 = TestFactory.createContact(testClient, 'BU Contact', 'BBSI Employee', false);
        c3.User_Id__c = u3.ID;        
        listContact.add(c3);
        
        Contact cAM = TestFactory.createContact(testClient, 'BU Contact', 'BBSI Employee', false);
        cAM.User_Id__c = AreaManager.ID;
        //listUser.add(AreaManager);
        listContact.add(cAM);
        
        System.debug('Contacts: ' + listContact);

        Account testBranch = testFactory.createAccount('Test Branch', '98662', 'BBSI Branch', false);
        testBranch.Branch_Manager__c = 'Test AreaManager';        

        insert listContact;
        insert testBranch;
        Business_Unit__c BU1 = testFactory.createBusinessUnit('Test BU1', testBranch, true);
        Business_Unit__c BU2 = testFactory.createBusinessUnit('Test BU2', testBranch, true);            
        insert testClient;
        
        list<Business_Unit_Contact__c> listBUC = new list<Business_Unit_Contact__c>();

        Business_Unit_Contact__c bucA = testFactory.createBusinessUnitContact(BU1, true, 'Payroll Specialist', false);       
        bucA.Active__c = true;
        bucA.BU_Member__c = c1.ID;
        listBUC.add(bucA);

        Business_Unit_Contact__c buc1 = testFactory.createBusinessUnitContact(BU2, true, 'Payroll Specialist', false);       
        buc1.Active__c = true;
        buc1.BU_Member__c = c2.ID;
        buc1.Active_Date__c = System.today();
        listBUC.add(buc1);

        Business_Unit_Contact__c buc2 = testFactory.createBusinessUnitContact(BU2, true, 'Business Partner', false);       
        buc2.Active__c = true;
        buc2.BU_Member__c = c3.ID;
        buc2.Active_Date__c = System.today();
        listBUC.add(buc2);

        Business_Unit_Contact__c buc3 = testFactory.createBusinessUnitContact(BU2, true, 'Risk Consultant', false);       
        buc3.Active__c = true;
        buc3.BU_Member__c = cAM.ID;
        buc3.Active_Date__c = System.today();
        listBUC.add(buc3);

        insert listBUC;
        
        System.test.startTest();
        testClient.Business_Unit__c = BU1.Id;
        update testClient;

        system.assertEquals(1, [Select ID from Business_Unit_Member__c where Client__c = :testClient.ID].size());
        
        testClient.Business_Unit__c = BU2.ID;
        update testClient;

        system.assertEquals(3, [Select ID from Business_Unit_Member__c where Client__c = :testClient.ID].size());
        
        System.test.stopTest(); 
        }
       
    }
    	
    static testMethod void AccountInsert(){
        Account testBranch = testFactory.createAccount('Test Branch', '98662', 'BBSI Branch', true);
        Business_Unit__c BU = testFactory.createBusinessUnit('Test BU', testBranch, true);      
        
        Account bogusClient = testFactory.createAccount('Bogus Client', '98662', 'Client', true);
        
        User u = testFactory.createUser('Test User', 'test@bbsihq.com', 'test@bbsihq.com', 'BBSI Standard', '910', true);
        Contact c = TestFactory.createContact(bogusClient, 'BU Contact', 'BBSI Employee', false);
        c.User_Id__c = u.ID;
        insert c;
        
        Business_Unit_Contact__c buc = testFactory.createBusinessUnitContact(BU, false, 'Payroll Specialist', false);       
        buc.Active__c = true;
        buc.BU_Member__c = c.ID;
        buc.Active_Date__c = System.today();
        buc.Inactive_Date__c = null;
        insert buc;
        
		System.test.startTest();  
        Account testClient = testFactory.createAccount('Test Client', '98662', 'Client', false);
        testClient.Business_Unit__c = BU.ID;
        insert testClient;
        System.Test.stopTest();
        
        system.assertEquals(1, [Select ID from Business_Unit_Member__c where Client__c = :testClient.ID].size());
    } 
	
}