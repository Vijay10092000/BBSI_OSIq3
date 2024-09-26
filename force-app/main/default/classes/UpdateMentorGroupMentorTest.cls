/**
 * @description UpdateMentorGroupMentorTest contains tests for the UpdateMentorGroupMentor class.
 */
@IsTest
public class UpdateMentorGroupMentorTest {
	private static Account branch;
	private static User user;
	private static Contact contact;

	@TestSetup
	static void makeData() {
		branch = TestFactoryAccount.createBranch('TEST BRANCH');
		user = TestFactoryUser.createUser('TEST', 'USER', 'BBSI Standard', branch.External_Id__c);
		contact = TestFactoryContact.createEmployee(user.Id, 'TEST', 'USER', branch.Id);
	}

	static void loadData() {
		branch = [SELECT Id, External_Id__c FROM Account WHERE Name = 'TEST BRANCH'];
		contact = [SELECT Id, Name FROM Contact WHERE Name = 'TEST USER'];
	}

	@IsTest 
	static void addEmployeeToGroup() { 
		loadData();

		Mentor_Group__c mentorGroup = TestFactoryMentorGroup.createMentorGroup('Test Group');
		Mentor_Group_Member__c mentorGroupMember = TestFactory.createMentorGroupMember(mentorGroup.Id, contact.Id, 25.0, 'Mentor', false);
		
		Test.startTest();
		insert mentorGroupMember;
		Test.stopTest();  
		
		Mentor_Group__c updatedMentorGroup = [SELECT Id, Total_Group_Weight_New__c, Mentor_Name_New__c FROM Mentor_Group__c WHERE ID = :mentorGroup.Id]; 
		Assert.areEqual(25.0, updatedMentorGroup.Total_Group_Weight_New__c) ; 
	} 

	@IsTest 
	static void updateEmployeeWithinGroup() { 
		loadData();
				
		Mentor_Group__c mentorGroup = TestFactory.createMentorGroup('Test Group', true);
		Mentor_Group_Member__c mentorGroupMember = TestFactory.createMentorGroupMember(mentorGroup.Id, contact.Id, 5.0, 'Member', true);
		
		Test.startTest();
		mentorGroupMember.Group_Role__c = 'Mentor';
		mentorGroupMember.Group_Weight__c = 25.0;
		update mentorGroupMember;
		Test.stopTest();  
		
		Mentor_Group__c updatedMentorGroup = [SELECT Id, Total_Group_Weight_New__c, Mentor_Name_New__c FROM Mentor_Group__c WHERE ID = :mentorGroup.Id]; 
		Assert.areEqual(25.0, updatedMentorGroup.Total_Group_Weight_New__c) ; 
	} 

	@IsTest 
	static void addEmployeeToMultipleGroups() {
		loadData();
		
		List<Mentor_Group__c> mentorGroups = TestFactory.createMentorGroups('Test Group', 4, true);
		List<Mentor_Group_Member__c> mentorGroupMembers = new List<Mentor_Group_Member__c>();
		Mentor_Group_Member__c mentorGroupMember1 = TestFactory.createMentorGroupMember(mentorGroups[0].Id, contact.Id, 25.0, 'Mentor', false);
		mentorGroupMembers.add(mentorGroupMember1);
		Mentor_Group_Member__c mentorGroupMember2 = TestFactory.createMentorGroupMember(mentorGroups[1].Id, contact.Id, 5.0, 'Member', false);
		mentorGroupMembers.add(mentorGroupMember2);
		Mentor_Group_Member__c mentorGroupMember3 = TestFactory.createMentorGroupMember(mentorGroups[2].Id, contact.Id, 5.0, 'Member', false);
		mentorGroupMembers.add(mentorGroupMember3);
		Mentor_Group_Member__c mentorGroupMember4 = TestFactory.createMentorGroupMember(mentorGroups[3].Id, contact.Id, 5.0, 'Member', false);
		mentorGroupMembers.add(mentorGroupMember4);
		
		Test.startTest();
		insert mentorGroupMembers;
		Test.stopTest();
		
		Contact updatedEmployee = [SELECT Id, (SELECT Id, Employee__c, Mentor_Group__c, Mentor_Group__r.Name, Group_Role__c, Group_Weight__c From Mentor_Group_Members__r Order By Mentor_Group__r.Name)  FROM Contact Where Id = :contact.Id];
		Assert.areEqual(4, updatedEmployee.Mentor_Group_Members__r.size()) ; 
	} 
	
	@IsTest
	static void deleteEmployeeFromGroup() {
		loadData();
		
		Mentor_Group__c mentorGroup = TestFactory.createMentorGroup('Test Group', true);
		Mentor_Group_Member__c mentorGroupMember = TestFactory.createMentorGroupMember(mentorGroup.Id, contact.Id, 25.0, 'Mentor', true);
		
		Test.startTest();
		delete mentorGroupMember;
		Test.stopTest();  
		
		Mentor_Group__c updatedMentorGroup = [SELECT Id, Total_Group_Weight_New__c, Mentor_Name_New__c FROM Mentor_Group__c WHERE ID = :mentorGroup.Id];
		Assert.areEqual(null, updatedMentorGroup.Mentor_Name_New__c) ; 
		Assert.areEqual(0, updatedMentorGroup.Total_Group_Weight_New__c) ;
	} 
}