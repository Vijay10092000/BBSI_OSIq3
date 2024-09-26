@isTest
public class UpdateWorkCompPolicyTest {
	
    /*@isTest static void singleWorkCompPolicyDate(){
        Account a1 = TestFactory.createAccount('TestAccount', '98662', 'Client', True);
        
        Work_Comp_Policy__c wcp = TestFactory.createWorkCompPolicy('Test', System.today().addDays(1), System.today(), true);
        
        WorkCompPolicyAccount__c wcpa = TestFactory.createWorkCompPolicyAccount('NeedChange', wcp, a1, true);        
        System.assertEquals(wcp.Term_Date__c, [Select Renewal_Date__c from Account where ID =: a1.ID].Renewal_Date__c);       
        
    }
    
     
    @isTest static void bulkWorkCompPolicyDate(){
        list<Account> updateAccount = new list<Account>();
        
        ID client = recordTypeService.getRecordTypeID('Account','Client');
        
        for(integer x = 0; x < 250; x++){
        	Account a = new Account(name = 'TestAccount' + x, BillingPostalCode='98662', RecordTypeID = client);
            updateAccount.add(a);
        }      
        
        insert updateAccount;
        
        List<workCompPolicyAccount__c> wcpaCollection = new List<workCompPolicyAccount__c>();
        
        //Test.startTest();
        Work_Comp_Policy__c wcp = TestFactory.createWorkCompPolicy('Test', System.today().addDays(4), System.today(), true);
        
        for(integer x = 0; x < 200; x++){
            workCompPolicyAccount__c wcpa = new workCompPolicyAccount__c();
            
            wcpa = TestFactory.createWorkCompPolicyAccount('NeedChange', wcp, updateAccount[x], false);             
            
            wcpaCollection.add(wcpa);
            
        }
        
        insert wcpaCollection;
        //Test.stopTest();
        
        String s = String.valueOf(System.today().addDays(4));
        
        //System.assertEquals(Date.valueOf(s), [Select Renewal_Date__c from Account where ID =: a.ID].Renewal_Date__c);        
    }
    
    @isTest static void noPolicyTest(){
        
        Test.startTest();
        
        Account a1 = TestFactory.createAccount('TestAccount1', '98662', 'Client', True);
		
        Account a2 = TestFactory.createAccount('TestAccount2', '98662', 'Client', false);
        a2.Start_Date__c = system.today();
        insert a2;
        
        Account a3 = TestFactory.createAccount('TestAccount3', '98662', 'Client', false);
        a3.Renewal_Date__c = System.today();
        insert a3;

        Account a4 = TestFactory.createAccount('TestAccount3', '98662', 'Client', false);
        a4.Start_Date__c = System.today();
        insert a4;        
        
        date d = date.newinstance(System.today().year()+1, System.today().month(), System.today().day());
        
        Work_Comp_Policy__c wcp = TestFactory.createWorkCompPolicy('Test', System.today().addDays(4), System.today(), true);
		workCompPolicyAccount__c wcpa = TestFactory.createWorkCompPolicyAccount('NeedChange', wcp, a1, true);
        
        test.stopTest();
        
        //System.assertEquals(d, [Select Renewal_Date__c from Account where ID =: a3.ID].Renewal_Date__c);
        //System.assertEquals(d, [Select Renewal_Date__c from Account where ID =: a4.ID].Renewal_Date__c);
    }
    
    @isTest static void prospectPolicyTest(){
        Account a1 = TestFactory.createAccount('TestAccount1', '98662', 'Prospect', false);      
        date myDate =  System.today();
        myDate = date.newInstance(myDate.year(), myDate.month(), myDate.day()-1);		           
        a1.Renewal_Date__c = myDate;
        myDate = date.newInstance(myDate.year(), myDate.month(), myDate.day()-4);
        a1.Renewal_Date__c = myDate;
        insert a1;
        
        Account a2 = TestFactory.createAccount('TestAccount2', '98662', 'Client', True);
        Work_Comp_Policy__c wcp = TestFactory.createWorkCompPolicy('Test', System.today(), System.today().addDays(4), true);
        workCompPolicyAccount__c wcpa = TestFactory.createWorkCompPolicyAccount('NeedChange', wcp, a1, true);

    }
    */
}