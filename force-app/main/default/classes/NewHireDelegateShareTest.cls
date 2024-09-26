@isTest
public class NewHireDelegateShareTest {
	
	@TestSetup static void Setup(){
       /* Admin_Branch__c admin = new Admin_Branch__c();
        admin.Admin_User__c = 'Not Delegate';
        admin.New_Hire_Delegate__c = 'Delegate';
        admin.Name = 'TEST BRANCH';
        insert admin;  
	*/
		Admin_Branch__c admin = TestFactoryAdminBranch.makeAdminBranch('TEST BRANCH','Not Delegate');
        admin.New_Hire_Delegate__c = 'Delegate';
        insert admin;
    }
	@isTest static void positiveShareInsert() {
		//User Delegate = TestFactory.createUser('Delegate', 'AreaManager@bbsihq.com', 'AreaManager@bbsihq.com', 'Area Manager', '910', true);
		User Delegate = TestFactoryUser.createUser(null,'Delegate','Area Manager', '910', 'AreaManager@bbsihq.com', 'AreaManager@bbsihq.com');
		//Account Branch = TestFactory.createAccount('Test Branch', '98662', 'BBSI Branch', true);
		Account Branch = TestFactoryAccount.makeAccount('Test Branch','BBSI Branch');
        insert Branch;
		System.Test.StartTest();
		
		//Position__c p = new Position__c(Branch__c = Branch.ID, Type__c = 'New', Hours_Per_Week__c = 5, Est_Annual_Salary__c = 45, Reason_For_New_Hire__c = 'Test Reason');
        
        //insert p;
        Position__c p = TestFactoryPosition.createPosition(Branch.ID,null, new Map<String, Object>{
        'Type__c' =>'New',
         'Hours_Per_Week__c' => 5,
         'Est_Annual_Salary__c' => 45,
          'Reason_For_New_Hire__c' => 'Test Reason'  
    });
		System.Test.StopTest();

		Assert.areEqual(1,[Select ID from Position__Share where ParentID =: p.ID and RowCause = 'Delegate__c'].size());
	}
    
    @isTest static void positiveShareUpdate(){
		//User Delegate = TestFactory.createUser('Delegate', 'AreaManager@bbsihq.com', 'AreaManager@bbsihq.com', 'Area Manager', '910', true);
		User Delegate = TestFactoryUser.createUser(null,'Delegate','Area Manager', '910', 'AreaManager@bbsihq.com', 'AreaManager@bbsihq.com');
		//Account Branch = TestFactory.createAccount('Test Branch', '98662', 'BBSI Branch', true);
		Account Branch = TestFactoryAccount.makeAccount('Test Branch','BBSI Branch');
        insert Branch;
		//Account BranchBackUpBranch = TestFactory.createAccount('Test Branch 2', '98662', 'BBSI Branch', true);
		Account BranchBackUpBranch = TestFactoryAccount.makeAccount('Test Branch2','BBSI Branch');
        insert BranchBackUpBranch;
		System.Test.StartTest();

		//Position__c p = new Position__c(Branch__c = Branch.ID, Type__c = 'New', Hours_Per_Week__c = 5, Est_Annual_Salary__c = 45, Reason_For_New_Hire__c = 'Test Reason');
        
        //insert p;
         Position__c p = TestFactoryPosition.createPosition(Branch.ID,null, new Map<String, Object>{
        'Type__c' =>'New',
         'Hours_Per_Week__c' => 5,
         'Est_Annual_Salary__c' => 45,
          'Reason_For_New_Hire__c' => 'Test Reason'  
    });

		Assert.areEqual(1,[Select ID from Position__Share where ParentID =: p.ID and RowCause = 'Delegate__c' and UserOrGroupID =: Delegate.ID].size());  
        
        p.Branch__c = BranchBackUpBranch.ID;
        update p;

      	Assert.areEqual(0, [Select ID from Position__Share where ParentID =: p.ID and RowCause = 'Delegate__c' and UserOrGroupID =: Delegate.ID].size());

        p.Branch__c = Branch.ID;
        update p;

        Assert.areEqual(1, [Select ID from Position__Share where ParentID =: p.ID and RowCause = 'Delegate__c' and UserOrGroupID =: Delegate.ID].size()); 

		System.Test.StopTest();

		      
    }
    
}