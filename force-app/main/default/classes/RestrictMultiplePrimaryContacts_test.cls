@isTest
public with sharing class RestrictMultiplePrimaryContacts_test {
	 
	static testMethod void test(){
				
		Account acct = new Account(Name='test account', BillingPostalCode = '98662');
	 	insert acct;
	 		 	
		Contact cont = new Contact(LastName = 'test contact', AccountId = acct.Id, Primary__c = true);
		Contact cont1 = new Contact(LastName = 'test contact', AccountId = acct.Id, Primary__c = false);
		Contact cont2 = new Contact(LastName = 'test contact', AccountId = acct.Id, Primary__c = true);
		
		// Positive Case - Insert
	 	insert cont;         
	 	insert cont1;         	
		 	
	 	// Negative Case - Insert
	 	try {
	 		insert cont2;    
	 	} catch (DmlException e) {
	 		System.debug(e);
	 	}
	 	
	 	// Positive Case - Update
	 	update cont;    
	 	
	 	// Negative Case - Update
	 	try {
	 		cont1.Primary__c = true;
	 		update cont1;    
	 	} catch (DmlException e) {
	 		System.debug(e);
	 	}	 	
	}

	static testMethod void bulkTest(){
				
		Account acct = new Account(Name = 'test account', BillingPostalCode = '98662');
	 	insert acct;
	 	
        Contact[] contactsToCreate = new Contact[]{};

        for(Integer x=0; x<200;x++){
            Contact ct = new Contact(AccountId = acct.Id, lastname = 'testing', Primary__c = true);
            contactsToCreate.add(ct);
        }	 
        
    	Test.startTest();
    	try {
        	insert contactsToCreate;
	 	} catch (DmlException e) {
	 		System.debug(e);
	 	}
        Test.stopTest();   	

	}
}