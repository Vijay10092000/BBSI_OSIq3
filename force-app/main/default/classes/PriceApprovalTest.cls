@isTest
private class PriceApprovalTest {

	@TestSetup static void setup(){
		List<Admin_Branch__c> adminBranch = new List<Admin_Branch__c>();
		
		Admin_Branch__c ab = new Admin_Branch__c();
		ab.Name = 'Test Branch 1';
		ab.Admin_User__c = 'Test User 1';
		adminBranch.add(ab);

		ab = new Admin_Branch__c();
		ab.Name = 'Test Branch 2';
		ab.Admin_User__c = 'Test User 2';
		adminBranch.add(ab);

		insert adminBranch;

		list<User> uList = new list<User>();

    User AreaManager = TestFactory.createUser('Manager', 'AreaManager@bbsihq.com', 'AreaManager@bbsihq.com', 'Area Manager', '910', false);
    AreaManager.FirstName = 'Area';
    AreaManager.title = 'Area Manager';
    AreaManager.Branch_ID__c = '910';
		AreaManager.isActive = true;
    uList.add(AreaManager);
    
    User u = TestFactory.createUser('BDMUser', 'TestBBSI@bbsihq.com', 'TestBBSI@bbsihq.com', 'BBSI Standard', '910', false);
    u.title = 'Business Development Manager';
    u.Branch_ID__c = '910';
		u.isActive = true;
    uList.add(u);
        
    insert uList;

		TestFactory.createAccount('Test Branch 1', '98662', 'BBSI Branch', true);
    TestFactory.createAccount('Test Branch 2', '98662', 'BBSI Branch', true);

	}

	@isTest static void testWhenAllClientControlsSetPriceApprovalIsUnapproved(){

		set<String> fieldSet = new set<String>();
		String query = 'Select ID ';
		Account Client = TestFactory.createAccount('Test Client', '98662', 'Client', false);
		insert Client;
		Id clientID = client.id;
    for(Schema.FieldSetMember fields :Schema.SObjectType.Account.fieldSets.getMap().get('Price_Approval_To_Unapproved').getFields()){
      query += ','+fields.getFieldPath();
      fieldSet.add(fields.getFieldPath());
    }
    
    query +=',Price_Approval__c From Account Where id=:ClientID limit 1';
    client = (Account)Database.Query(query);
    Map<String,Schema.SObjectField> fieldMap;
    fieldMap = Schema.SObjectType.Account.Fields.getMap();
    Schema.SObjectField fieldVal;
		Schema.DisplayType FldType;

    Test.startTest();
    	System.assert(client.Price_Approval__c == null,'Price Approval should be null');
   		Integer cnt = 1;
   		String finalField;
   		System.Debug(fieldset.size());
    	For(String field: fieldSet){
    		System.Debug('cnt: ' + cnt);
    		if(cnt ==fieldSet.size() - 1) {
    		  finalField = field;
    		  System.Debug('cnt: ' + cnt + ' ' + finalField);
    			break; //set all but final field;
    		}
    		fieldVal = fieldMap.get(field);
    		object value = TestFactory.getFieldValueBySoapType(fieldVal.GetDescribe().getSoapType());
    		Client.put(field,value);
    		cnt ++;
    	}
    	update client;
    	client = (Account)Database.Query(query);
    	//System.assertNotEquals(client.Price_Approval__c,'Unapproved');
    	fieldVal = fieldMap.get(finalField);
    	object value = TestFactory.getFieldValueBySoapType(fieldVal.GetDescribe().getSoapType());
    	Client.put(finalField,value);
    	update client;
    	client = (Account)Database.Query(query);
    	System.assertEquals(client.Price_Approval__c,'Unapproved');
    	
    Test.stopTest();

	}

	@isTest static void whenChangingApprovedCheckStatusUpdatedAndClientControlsCreated(){

		set<String> fieldSet = new set<String>();
		String query = 'Select ID ';
		Account Client = TestFactory.createAccount('Test Client', '98662', 'Client', false);
		insert Client;
		Id clientID = client.id;
    for(Schema.FieldSetMember fields :Schema.SObjectType.Account.fieldSets.getMap().get('Price_Approval_To_Unapproved').getFields()){
      query += ','+fields.getFieldPath();
      fieldSet.add(fields.getFieldPath());
    }
    
    query +=',Price_Approval__c From Account Where id=:ClientID limit 1';
    client = (Account)Database.Query(query);
    Map<String,Schema.SObjectField> fieldMap;
    fieldMap = Schema.SObjectType.Account.Fields.getMap();
    Schema.SObjectField fieldVal;
		Schema.DisplayType FldType;

    Test.startTest();
    	System.assert(client.Price_Approval__c == null,'Price Approval should be null');
   		Integer cnt = 1;
   		String finalField;
   		System.Debug(fieldset.size());
    	For(String field: fieldSet){
    		fieldVal = fieldMap.get(field);
    		object value = TestFactory.getFieldValueBySoapType(fieldVal.GetDescribe().getSoapType());
    		Client.put(field,value);
    	}
    	update client;
    	client.price_Approval__c = 'Approved';
        client.Price_Approval_Comments__c = 'Test comment';
    	update client;
    	client = (Account)Database.Query(query);
    	System.assertEquals(client.Price_Approval__c,'Approved');
    	String fieldUpdated;
    	String oldValue;
    	for(String field: fieldSet){
    		fieldVal = fieldMap.get(field);
    		if(FieldVal.getDescribe().getSoapType() == Schema.SoapType.STRING){
    			oldValue = String.Valueof(client.get(field));
    			client.put(field,'Testing 123');
    			fieldUpdated = field;
    			break;
    		}
    	}
    	update Client;
    	client = (Account)Database.Query(query);
    	
    	System.assertEquals(client.Price_Approval__c,'Unapproved');
    	String CCQuery = 'Select ID, ' + fieldUpdated + ' From Client_Control__c where Account__c =: clientID';
    	List<Client_Control__c> clientControls = (List<Client_Control__c>)Database.Query(CCQuery);
    	System.assertEquals(1,clientControls.Size());
    	for(Client_Control__c cc: clientControls){
    		System.assertEquals(oldValue,String.ValueOf(cc.get(fieldUpdated)));
    	}

    Test.stopTest();
	}

	@isTest static void positiveAreaManagerUpdate() {
		Account Branch = [Select ID from Account where name = 'Test Branch 2'];

		Account Client = TestFactory.createAccount('Test Client', '98662', 'Client', false);

		User u = [Select ID, Name from User where Name = 'Area Manager' and isActive = true limit 1];

		system.runAs(u){
			insert Client;

			Client.Price_Approval__c = 'Approved';
            Client.Price_Approval_Comments__c = 'Test comment';
			update Client;
		}

		System.assert([Select Price_Approval__c from Account where ID =: Client.ID].Price_Approval__c == 'Approved');
	}

	@isTest static void positiveUnapproveRequest(){
		Account Branch = [Select ID from Account where name = 'Test Branch 2'];

		Account Client = TestFactory.createAccount('Test Client', '98662', 'Client', false);

		User u = [Select ID, Name from User where Name = 'Area Manager' and isActive = true limit 1];

		system.runAs(u){
			insert Client;

			Client.Price_Approval__c = 'Approved';
            Client.Price_Approval_Comments__c = 'Test comment';
			update Client;
		}

		System.assert([Select Price_Approval__c from Account where ID =: Client.ID].Price_Approval__c == 'Approved');
		
		system.runAs(u){
			Client.Safety_Incentive__c = 'Change';
			Client.Price_Info__c = 'Change';
			update Client;
            
      //System.assert([Select Price_Approval__c from Account where ID =: Client.ID].Price_Approval__c == 'Unapprove');
		}
		
					
	}
	/*
	@isTest static void positiveDelegateUpdate() {
		User u = TestFactory.createUser('User 1', 'TestBBSIDelegate@bbsihq.com', 'TestBBSIDelegate@bbsihq.com', 'BBSI Standard', '910', false);
		u.FirstName = 'Test ';
		u.Title = 'BDM';
		insert u;

		system.runAs(u){
			Account Branch = TestFactory.createAccount('Test Branch 2', '98662', 'BBSI Branch', true);

			Account Client = TestFactory.createAccount('Test Client', '98662', 'Client', false);

			Client.Prospect_Branch__c = Branch.ID;
			insert Client;

			Client.Price_Approval__c = 'Approved';
			update Client;

			System.assert([Select Price_Approval__c from Account where ID =: Client.ID].Price_Approval__c == 'Approved');
		}
		
	}
	*/
	@isTest static void negativeAreaManagerUpdate() {
		Account Branch = [Select ID from Account where name = 'Test Branch 1'];

		Account Client = TestFactory.createAccount('Test Client', '98662', 'Client', false);

		User u = [Select ID, Name from User where LastName = 'BDMUser' and isActive = true limit 1];

		system.runAs(u){
			insert Client;

			Client.Price_Approval__c = 'Approved';
            
			try{
				update Client;
			}catch(DmlException e){
				System.assertEquals('You must be an Area Manager or Delegated Admin to approve records.', e.getDmlMessage(0));
			}

		}

		System.assert([Select Price_Approval__c from Account where ID =: Client.ID].Price_Approval__c != 'Approved');
	}

	@isTest static void positiveAreaManagerInsert(){
		Account Branch = [Select ID from Account where name = 'Test Branch 1'];

		User u = [Select ID, Name from User where Name = 'Area Manager' and isActive = true limit 1];

		system.runAs(u){
			Account Client = TestFactory.createAccount('Test Client', '98662', 'Client', false);
			Client.Price_Approval__c = 'Approved';

			insert Client;

			System.assert([Select Price_Approval__c from Account where ID =: Client.ID].Price_Approval__c == 'Approved');
		}				
	}

	@isTest static void negativeAreaManagerInsert() {
		Account Branch = [Select ID from Account where name = 'Test Branch 1'];

		User u = [Select ID, Name from User where LastName = 'BDMUser' and isActive = true limit 1];

		system.runAs(u){
			try{
        Account b3 = TestFactory.createAccount('Test Branch 3', '98662', 'BBSI Branch', true);
				Account Client = TestFactory.createAccount('Test Client', '98662', 'Client', false);
				Client.Price_Approval__c = 'Approved';
				Client.Prospect_Branch__c = b3.ID;
				insert Client;
			}catch(DmlException e){
				System.assertEquals('You must be an Area Manager or Delegated Admin to approve records.', e.getDmlMessage(0));
			}				
		}
	}
}