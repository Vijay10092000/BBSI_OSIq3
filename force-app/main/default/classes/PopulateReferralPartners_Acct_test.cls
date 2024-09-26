@isTest
public class PopulateReferralPartners_Acct_test {

/*
    HEC 07/31/2017 - commenting out all the code for destructive deploy in the future
      
    @isTest static void test(){
    
        List<Account> accts = new List<Account>();

        Id clientRTId = '01250000000HlwDAAS';

        Id refPartRTId = recordTypeService.GetRecordTypeID('Account','Referral Partner');

        Account a1 = new Account(Name='test account', RecordTypeId = refPartRTId, External_Id__c = '1234', BillingPostalCode='98662');
        Account a2 = new Account(Name='test account', RecordTypeId = refPartRTId, External_Id__c = '2345', BillingPostalCode='98662');
                
        accts.add(a1);
        accts.add(a2);
        insert accts;

        accts.clear();
        
        for(Account a : [Select External_ID__c from Account where name = 'test account']){
            accts.add(a);
        }
        
        Account a3 = new Account(Name='test account', RecordTypeId = clientRTId, Referral_Partner_Id__c = accts.get(0).External_Id__c, BillingPostalCode='98662');
        insert a3;
        
        a3.Referral_Partner_Id__c = accts.get(1).External_Id__c;
        update a3;       

        try {
            a3.Referral_Partner_Id__c = '9999';
            update a3;
            delete a3;
        } catch (DmlException e) {
            System.debug(e);
        }          
    }
    
    @isTest static void test2(){
         List<Account> accts = new List<Account>();

        Id clientRTId = recordTypeService.GetRecordTypeID('Account','Client');

        Id refPartRTId = recordTypeService.GetRecordTypeID('Account','Referral Partner');

        Account a1 = testFactory.createAccount('test account', '98662', 'Referral Partner', false);
        a1.External_ID__c = '1234';
        
        Account a2 = testFactory.createAccount('test account', '98662', 'Referral Partner', false);
        a1.External_ID__c = '2345';
                
        accts.add(a1);
        accts.add(a2);
        insert accts;

        accts.clear();
        
        for(Account a : [Select External_ID__c from Account where name = 'test account']){
            accts.add(a);
        }
        
        Account a3 = new Account(Name='test account', RecordTypeId = clientRTId, Referral_Partner_Id__c = accts.get(0).External_Id__c, BillingPostalCode='98662');
        insert a3;
        try{
        	a3.Referral_Partner_Id__c = '';
        	update a3;             
        }catch(DMLException e){
            System.debug(e);
        }

    }
	*/
    
}