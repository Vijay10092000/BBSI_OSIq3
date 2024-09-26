@isTest
private class CreateRenewalLinksTest {
    
    @testSetup static void setup() {
        // Create test data
        string fein = '00-1234567';
        string fein1 = '99-1234567';
        List<Renewal__c> renewals = new List<Renewal__c>();
        renewals.add(TestFactoryRenewal.makeRenewal( 
            'Tester 1', 
            new Map<String, Object>{            
                'FEIN__c' => fein,
                'Status__c' => 'New'
            }));
        renewals.add(TestFactoryRenewal.makeRenewal( 
            'Tester 2', 
            new Map<String, Object>{            
                'FEIN__c' => fein,
                'Status__c' => 'New'
            }));
        renewals.add(TestFactoryRenewal.makeRenewal( 
            'Tester ABC', 
            new Map<String, Object>{            
                'FEIN__c' => fein1,
                'Status__c' => 'New'
            }));
        renewals.add(TestFactoryRenewal.makeRenewal( 
            'Tester DEF', 
            new Map<String, Object>{            
                'FEIN__c' => fein1,
                'Status__c' => 'New'
            }));
        insert(renewals);     
        
        Renewal_Link__c newLink = TestFactoryRenewal_Link.makeRenewalLink(fein1,'test');
        insert newLink;        
    }
    
    
    @isTest static void TriggerCreateLinkObjects() {
        
        Test.startTest();
        
        // Note; AddClientsToRenewalsBatch and CreateRenewalLinksBatch are called 
        //       at the end of the following batch
        Database.executebatch(New CreateRenewalsBatchable(), 20);
        
        Test.stopTest();
        // asserts here
        List<Renewal_Link__c> newRenLinks = [Select Id from Renewal_Link__c];
        
        Assert.areEqual(2, newRenLinks.size());
        
        List<Renewal__c> renewals = [Select Id, Renewal_Link__c from Renewal__c
                                     WHERE Renewal__c.Renewal_Link__c != null];
        Assert.areEqual(4, renewals.size());
        
        newRenLinks = [Select Description__c from Renewal_Link__c where FEIN__c like '99%'];
        Assert.isTrue(newRenLinks[0].Description__c.length() > 5);
    }
}