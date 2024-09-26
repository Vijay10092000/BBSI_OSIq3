/**
 * @description EventRegistration_Trigger_Test contains tests for the EventRegistration_TriggerHandler class.
 */
@IsTest
private class EventRegistration_Trigger_Test {
	@isTest
	private static void test_InsertAndUpdate() {        
        Account a1 = TestFactoryAccount.makeAccount('Client', 
			new Map<String, Object>{            
				'Name' => 'Test Account 1',
				'ShippingState' => 'WA'
				
              });
         Account a2 = TestFactoryAccount.makeAccount('Client', 
			new Map<String, Object>{            
				'Name' => 'Test Account 2',
				'ShippingState' => 'WA'
				
              });
		insert new List<Account>{ a1, a2 };
        Contact c1 = TestFactoryContact.makeClient('Contact','One',a1.id);
        Contact c2 = TestFactoryContact.makeClient('Contact','Two',a2.id);
		insert new List<Contact>{ c1, c2 };
		RecordType rtClientEvent = [
			SELECT Id
			FROM RecordType
			WHERE SobjectType = 'Event__c'
			AND Name = 'Client Event'
			LIMIT 1
		];
        
         Event__c eventC = TestfactoryEventc.createEvent( 
			'Client_Event', 
			new Map<String, Object>{            
				'Event_Start_Date__c' =>  Date.today(),
				'Event_End_Date__c' => Date.today().addDays(2),
				'Event_Type__c'      => 'Client Event',
				'Budget_Overall__c' => 30000
              });
        
         User manager = TestFactoryUser.createUser('Test', 'Manager', 'BBSI Support', '910');
         Date today = Date.today();
		 Event__c eventBBSIOne = TestfactoryEventc.createEvent( 
			'Client_Event', 
			new Map<String, Object>{            
				'Event_Start_Date__c' => today.addMonths(1),
				'Event_End_Date__c' => today.addMonths(1),
				'Event_Type__c'      => 'Meeting',
				'Event_Type_Other__c' => '',
				'Event_Manager__c' => manager.Id,
				'Budget_Overall__c' => 10000,
				'Final_Cost__c'     => 10000,
				'Region__c'        => 'NoCal'
			});
        
        Event_Registration__c eventReg = TestFactoryEventRegistration.createEventReg(new Map<String, Object>{
			'Contact__c'   => c1.Id,
            'Event__c'      => eventBBSIOne.Id,
             'Contact_Type__c'  => 'Client'   
                });

		eventReg = [SELECT Id, Company1__c FROM Event_Registration__c WHERE Id = :eventReg.Id];
		Assert.areEqual(a1.Id, eventReg.Company1__c, 'Company should be set to Contact One\'s Account');

		eventReg.Contact__c = c2.Id;
		update eventReg;

		eventReg = [SELECT Id, Company1__c FROM Event_Registration__c WHERE Id = :eventReg.Id];
		Assert.areEqual(a2.Id, eventReg.Company1__c, 'Company should be set to Contact Two\'s Account');
	}
}