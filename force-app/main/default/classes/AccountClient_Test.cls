/**
 * @description AccountClient_Test contains tests for the AccountClient class.
 */
@IsTest
public with sharing class AccountClient_Test {
    @IsTest
	static void test_updateBusinessUnit() {
		Account branch = TestFactoryAccount.makeBranch('TEST BRANCH', '999', 'TESTAREAMANAGER', null);
         branch.Branch_Manager_Email__c='am@bbsi.zzz';
        insert branch;
        User am = TestFactoryUser.makeAreaManager('AM','TESTAREAMANAGER','910');
		am.Email = 'am@bbsi.zzz';
        am.Username = 'am12@bbsi.zzz';
		insert am;

		//branch.Branch_Manager__c = 'TESTAREAMANAGER';
		branch.Area_Manager_Email__c  = 'am@bbsi.zzz';
		update branch;
		//upsert branch;

		branch = [SELECT Id, Branch_Manager__c, Area_Manager_Email__c FROM Account WHERE Id = :branch.Id];
		Assert.areEqual('TESTAREAMANAGER', branch.Branch_Manager__c, 'AM should be assigned');
		Assert.areEqual('am@bbsi.zzz', branch.Area_Manager_Email__c, 'Email should be assigned');

        Business_Unit__c bu1 = TestFactoryBusinessUnit.makeBusinessUnit('!!! TEST BU 1', branch.Id);
		Business_Unit__c bu2 = TestFactoryBusinessUnit.makeBusinessUnit('!!! TEST BU 2', branch.Id);
        List<Business_Unit__c> buList = new List<Business_Unit__c>{bu1,bu2};
        insert buList;
		Test.startTest();

        Account client = TestFactoryAccount.makeClient('!!! TEST CLIENT',null,null);
		client.branch__c = branch.Id;
		client.Business_Unit__c = bu1.Id;
		client.Area_Manager_Email__c = 'am@bbsi.zzz';
        client.BU_Assignment_Date__c = system.today();

		insert client;

		client = [SELECT Id, Branch__c, BU_Assignment_Date__c, Business_Unit__c FROM Account WHERE Id = :client.Id];
		Assert.isNotNull(client.BU_Assignment_Date__c, 'Date should be set');
		Assert.areEqual(branch.Id, client.Branch__c, 'Branch should be set');
		Assert.areEqual(bu1.Id, client.Business_Unit__c, 'Business Unit should be set');
		Assert.areEqual(1, Email_Service.testEmails.size(), 'Email should be sent to Area Manager');

		client.Business_Unit__c = bu2.Id;

		update client;

		Test.stopTest();

		client = [SELECT Id, BU_Assignment_Date__c, Business_Unit__c FROM Account WHERE Id = :client.Id];
		Assert.isNotNull(client.BU_Assignment_Date__c, 'Date should be clear');
		Assert.areEqual(bu2.Id, client.Business_Unit__c, 'Business Unit should be clear');
		Assert.areEqual(2, Email_Service.testEmails.size(), 'A new email should be sent to Area Manager');
	}
}