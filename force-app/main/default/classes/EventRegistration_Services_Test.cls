/**
 * @description Log_Schedule_Test contains tests for the Log_Schedule class.
 */
@IsTest
public without sharing class EventRegistration_Services_Test {
	@IsTest
	public static void test_setRegistrantCompany() {
        Account a1 = TestFactoryAccount.createClient('Account', null,null);
        Contact c1 = TestFactoryContact.createEmployee(null, 'testcontact1', 'Contact', a1.id);
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
        
        Event_Registration__c er1 = TestFactoryEventRegistration.createEventReg(new Map<String, Object>{
			'Contact__c'   => c1.Id,
            'Event__c'      => eventBBSIOne.Id,
             'Contact_Type__c'  => 'Client'   
                });
		 Event_Registration__c er2 = TestFactoryEventRegistration.createEventReg(new Map<String, Object>{
			'Contact__c'   => null,
             'Event__c'      => eventBBSIOne.Id,
             'Contact_Type__c'  => 'Client',
			 'Attended__c' => true
                });
				
		
		Test.startTest();

		List<Event_Registration__c> registrations = new List<Event_Registration__c>{ er1, er2 };
		EventRegistration_Services.setRegistrantCompany(null, registrations);

		Test.stopTest();

		Assert.areEqual(a1.Id, er1.Company1__c, 'Company should be set');
		Assert.areEqual(null, er2.Company1__c, 'Company should not be set');
	}
}