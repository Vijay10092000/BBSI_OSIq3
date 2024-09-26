/**
 * @description FieldSetComponentController_Test contains the tests for the class FieldSetComponentController.
 */
@IsTest
private class FieldSetComponentController_Test {
	private static String CALLOUT_REPONSE_BODY =  
	'{' +
	'  "eTag":"22785e69f361a5d1c6af42e845942634",' +
	'  "picklistFieldValues":{' +
	'     "Test__c":{' +
	'        "controllerValues":{"test":2},' +
	'        "defaultValue":null,' +
	'        "eTag":"f9f8c70be00997cd2474031fd14e0dde",' +
	'        "url":"/services/data/v42.0/ui-api/object-info/Case/picklist-values/01250000000HmUzAAK/Type",' +
	'        "values":[' +
	'          {"attributes":null,"label":"Benefits/PTO","validFor":[],"value":"Benefits/PTO"},' +
	'          {"attributes":null,"label":"Client Branch Transfer","validFor":[],"value":"Client Branch Transfer"},' +
	'          {"attributes":null,"label":"Contracts","validFor":[],"value":"Contracts"},' +
	'          {"attributes":null,"label":"Data Correction","validFor":[],"value":"Data Correction"},' +
	'          {"attributes":null,"label":"Garnishments","validFor":[],"value":"Garnishments"},' +
	'          {"attributes":null,"label":"HR","validFor":[],"value":"HR"},' +
	'          {"attributes":null,"label":"Insurance/Certificates","validFor":[],"value":"Insurance/Certificates"},' +
	'          {"attributes":null,"label":"Onboarding","validFor":[],"value":"Onboarding"},' +
	'          {"attributes":null,"label":"Payroll","validFor":[],"value":"Payroll"},' +
	'          {"attributes":null,"label":"Preferred Payroll","validFor":[],"value":"Preferred Payroll"},' +
	'          {"attributes":null,"label":"Renewal/Pricing","validFor":[],"value":"Renewal/Pricing"},' +
	'          {"attributes":null,"label":"Report/Dashboard","validFor":[],"value":"Report/Dashboard"},' +
	'          {"attributes":null,"label":"Tax","validFor":[],"value":"Tax"},' +
	'          {"attributes":null,"label":"Time &amp; Attendance","validFor":[],"value":"Time &amp; Attendance"}' +
	'        ]' +
	'     }' +
	'  }' +
	'}';

	private static Account client;
	private static Contact contact;
	
	@TestSetup
	static void makeData() {
		Account branch = TestFactoryAccount.createBranch('TEST BRANCH');
		client = TestFactoryAccount.createClient('TEST CLIENT', null, null);
		
		User employee = TestFactoryUser.createUser('TEST', 'USER', 'BBSI Standard', branch.External_Id__c);
		contact = TestFactoryContact.createEmployee(employee.Id, 'TEST', 'USER', branch.Id);
	}

	static void loadData() {
		client = [SELECT Id FROM Account WHERE Name = 'TEST CLIENT' LIMIT 1];
		contact = [SELECT Id FROM Contact WHERE Name = 'TEST USER' LIMIT 1];
	}

	@IsTest
	static void test_DoUpsertObjects() {
		loadData();

		Map<String, Object> caseValues = new Map<String, Object>{
			'Subject' => 'FieldSetComponentController_Test Case',
			'Contact ID' => contact.Id
		};

		Map<String, Object> formValues = new Map<String, Object>{
			'Legal Name' => 'TestLN',
			'Job Title' => 'Administrative Support',
			'Branch' => 'TestBranch',
			'New Employee Start Date' => '2019-07-19',
			'System Access Permissions' => new List<String> {'AtTask Workfront'},
			'Employee Name' => 'TestEN',
			'Last Day of Work' => '2019-07-19',
			'Final Check Date' => '2019-07-19',
			'Employee Email Address' => 'test@test.com',
			'Employee\'s Computer' => 'testEmpComAssTag',
			'Computer and Peripherals Collected' => 'Yes',
			'Computer Asset Status' => 'Computer will be setup for a new employee'
		};

		ContentDocument cd = TestFactory.createDocument('Test File', 'Test Text');

		File_Holder__c holder = new File_Holder__c();
		insert holder;

		insert new ContentDocumentLink(
			ContentDocumentId = cd.Id,
			LinkedEntityId = holder.Id,
			ShareType = 'I',
			Visibility = 'AllUsers'
		);

		Test.startTest();

		FieldSetComponentController.doUpsertObjects(caseValues, formValues, holder.Id, String.valueOf(client.Id), 'Client Branch Transfer');

		Test.stopTest();

		Case c = [SELECT Id, Subject FROM Case WHERE Subject = 'FieldSetComponentController_Test Case'];

		Form__c form = [
			SELECT Id, Branch__c, Employee_Name__c, Employee_Email_Address__c
			FROM Form__c
			WHERE Case__c = :c.Id
		];

		Assert.areEqual('TestEN', form.Employee_Name__c, 'Employee_Name__c should have a value');
		Assert.areEqual('test@test.com', form.Employee_Email_Address__c, 'Employee_Email_Address__c should have a value');

		List<ContentDocumentLink> links = [
			SELECT Id, ContentDocumentId, LinkedEntityId
			FROM ContentDocumentLink 
			WHERE ContentDocumentId = :cd.Id
		];

		Boolean foundCase = false;
		Boolean foundUser = false;
		Boolean foundFileHolder = false;

		for (ContentDocumentLink link : links) {
			if (Schema.Case.SObjectType == link.LinkedEntityId.getSobjectType()) {
				foundCase = true;
			}
			else if (Schema.User.SObjectType == link.LinkedEntityId.getSobjectType()) {
				foundUser = true;
			}
			else if (Schema.File_Holder__c.SObjectType == link.LinkedEntityId.getSobjectType()) {
				foundFileHolder = true;
			}
		}
		
		Assert.areEqual(true, foundCase, 'The document should be connected to a Case');
		Assert.areEqual(true, foundUser, 'The document should be connected to a User');
		Assert.areEqual(false, foundFileHolder, 'The document should NOT be connected to a File_Holder__c');
	}

	@IsTest
	static void test_Values() {
		FieldSetComponentController fsComConObj = new FieldSetComponentController();

		Assert.isNotNull(fsComConObj.getDefaultValue());
		Assert.isNotNull(fsComConObj.getValues());
	} 
	
	@IsTest
	static void test_activeContactAccountId() {
		Assert.areEqual(true, String.isBlank(FieldSetComponentController.activeContactAccountId()), 'Value not yet set');

		FieldSetComponentController.idActiveAccount = Id.valueOf('0035C00000LQFoyQAH');
		
		Assert.areEqual('0035C00000LQFoyQAH', FieldSetComponentController.activeContactAccountId(), 'Value has been set');
	}

	@IsTest
	static void test_DynamicValues() {
		loadData();

		strike_responseData temp = new strike_responseData();
		temp.addError('temp');

		Test.setMock(HttpCalloutMock.class, new GenericMockCallout(200, 'OK', CALLOUT_REPONSE_BODY, null));
		
		Id crpRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Client/Referral Partner').getRecordTypeId();

		FieldSetComponentController.getStaticFields(client.Id, 'Client_Referral_Partner', 'Test__c');
		FieldSetComponentController.getStaticFields(client.Id, '', crpRecTypeId);
		FieldSetComponentController.getDynamicAfter(client.Id, 'Client_Referral_Partner', 'Test__c');
		FieldSetComponentController.getDynamicAfter(client.Id, '', crpRecTypeId);

		List<String> dynamicValues = new List<String>{ 'Client Branch Transfer', '', '' };
		
		List<FieldSetComponentController.SectionLayoutWrapper> wrappers = FieldSetComponentController.getDynamicFields('Form__c', dynamicValues);

		Assert.isNotNull(wrappers);
		Assert.areNotEqual(0, wrappers.size());
	}   

	@IsTest
	static void test_CreateFileHolder() {
		Id holderId = FieldSetComponentController.createFileHolder();

		File_Holder__c holder = [SELECT Id FROM File_Holder__c WHERE Id = :holderId];

		Assert.isNotNull(holder);
	}

	@IsTest
	static void test_UploadedFiles() {
		File_Holder__c holder = new File_Holder__c();
		insert holder;

		ContentDocument cd1 = TestFactory.createDocument('TEST1', 'Test Body');
		ContentDocument cd2 = TestFactory.createDocument('TEST2', 'Test Body');

		ContentDocumentLink cdl1 = new ContentDocumentLink(
			ContentDocumentId = cd1.Id,
			LinkedEntityId = holder.Id,
			ShareType = 'I',
			Visibility = 'AllUsers'
		);
		ContentDocumentLink cdl2 = new ContentDocumentLink(
			ContentDocumentId = cd2.Id,
			LinkedEntityId = holder.Id,
			ShareType = 'I',
			Visibility = 'AllUsers'
		);
		insert new List<ContentDocumentLink>{ cdl1, cdl2 };

		Set<Id> documentIds = new Set<Id>();

		Test.startTest();

		List<ContentDocument> docs = FieldSetComponentController.uploadedFiles(holder.Id);
		
		Test.stopTest();

		Assert.areEqual(2, docs.size());
	} 

	@IsTest
	static void test_DeleteFile() {
		File_Holder__c holder = new File_Holder__c();
		insert holder;

		ContentDocument cd1 = TestFactory.createDocument('TEST1', 'Test Body');
		ContentDocument cd2 = TestFactory.createDocument('TEST2', 'Test Body');

		ContentDocumentLink cdl1 = new ContentDocumentLink(
			ContentDocumentId = cd1.Id,
			LinkedEntityId = holder.Id,
			ShareType = 'I',
			Visibility = 'AllUsers'
		);
		ContentDocumentLink cdl2 = new ContentDocumentLink(
			ContentDocumentId = cd2.Id,
			LinkedEntityId = holder.Id,
			ShareType = 'I',
			Visibility = 'AllUsers'
		);
		insert new List<ContentDocumentLink>{ cdl1, cdl2 };

		Test.startTest();

		List<ContentDocument> docs = FieldSetComponentController.deleteFile(cd1.Id, holder.Id);

		Test.stopTest();

		Assert.areEqual(1, docs.size());
	}	
}