/**
 * @description 
 * US-47438 FirstMeetingEmailFlow_Test contains tests for the First Meeting email notification on Event Flow.
 */
@IsTest
@SuppressWarnings('PMD.AvoidSystemDebugUsage, PMD.AvoidHardcodingId')
public class FirstMeetingEmailFlow_Test {
	private static Account branch;
	private static Account prospect;
	private static User owner;
	private static Contact userContact;
    /**
     * @description testData is Used For Preparing Test Data.
     */
	@TestSetup
	public static void testData(){		
        branch = TestFactoryAccount.createBranch('bbsiTESTBRANCH', '910', null, null);
        profile BBSICallCenterProfile = [Select Id,Name from Profile where Name = 'BBSI Call Center'];
		owner = TestFactoryUser.makeUser(null, 'bbsiTESTUSER', 'BBSI Standard', '910', 'testuser@bbsi.zzz', 'testuser@bbsi.zzz');
        owner.ProfileId=BBSICallCenterProfile.Id;
        Test.startTest();
        	Insert owner;
        Test.stopTest();
		userContact = TestFactoryContact.createEmployee(owner.Id, null, 'bbsiTESTUSER', branch.Id);
        prospect = TestFactoryAccount.makeProspect('bbsiTESTPROSPECT', null, null);
        prospect.AnnualRevenue = 1234567;
        insert prospect;
        Lead lead = TestFactoryLead.createClientLead('TEST', 'LeadOne', 'LeadOne', branch.Id, owner.Id);        
	}
    
    /**
     * @description firstMeetingLeadEventTest Added to Check, Sales Development Representative should be Populates on prospect account.
    */
    @IsTest
    public static void firstMeetingAccountEventTest() {
		prospect = [SELECT Id, Name FROM Account WHERE RecordType.Name = 'Prospect' AND Name = 'bbsiTESTPROSPECT'];
		owner = [SELECT Id, Name FROM User WHERE LastName = 'bbsiTESTUSER'];
        DateTime dtEvent = DateTime.now().addDays(1);
        dtEvent = dtEvent.addMinutes(1);
        
        System.runAs(owner){            
            Event event = TestFactoryEvent.createEvent(null, owner.Id, prospect.Id, null, 'First Meeting', new Map<String, Object>{
                'ActivityDateTime' => dtEvent
            });
        }
        Event updatedEvent = [Select Id,Sales_Development_Representative__c From Event];		
        Assert.areNotEqual(null, updatedEvent.Sales_Development_Representative__c, 'Task Sales Development Representative should Not be null');
	}
    /**
     * @description firstMeetingLeadEventTest Added to Check Negative Testcase, Sales Development Representative should not Populates on event.
    */
    @IsTest
    public static void firstMeetingNegativeTest() {
		owner = [SELECT Id, Name FROM User WHERE LastName = 'bbsiTESTUSER'];
        DateTime dtEvent = DateTime.now().addDays(1);
        dtEvent = dtEvent.addMinutes(1);
        Lead lead = [Select Id from Lead where RecordType.Name = 'Client Lead'];
        Event event = TestFactoryEvent.createEvent(null, owner.Id,  null, lead.Id, 'First Meeting', new Map<String, Object>{
            'ActivityDateTime' => dtEvent
        });
        Event updatedEvent = [Select Id,Sales_Development_Representative__c From Event];
		Assert.areEqual(null, updatedEvent.Sales_Development_Representative__c, 'Task Sales Development Representative should be Empty');
	}
}