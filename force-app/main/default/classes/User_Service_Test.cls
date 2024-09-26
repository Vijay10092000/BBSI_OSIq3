@IsTest
public class User_Service_Test {
    private static User user1 = null;
    private static User user2 = null;
    private static User user3 = null;
    private static User user4 = null;
    private static Contact contact1 = null;

    @TestSetup
    static void setupTests() {
        User u1 = TestFactory.createUser('test Name1', 'test.name1@test.zzz', 'test.name1@test.zzz', 'BBSI Standard', '910', false);
        u1.isActive = true;
        User u2 = TestFactory.createUser('test Name2', 'test.name2@test.zzz', 'test.name2@test.zzz', 'BBSI Standard', '910', false);
        u2.isActive = true;
        User u3 = TestFactory.createUser('test Name3', 'test.name3@test.zzz', 'test.name3@test.zzz', 'BBSI Standard', '910', false);
        u3.isActive = false;
        User u4 = TestFactory.createUser('test Name4', 'test.name4@test.zzz', 'test.name4@test.zzz', 'Administrative Support', '910', false);
        u4.isActive = true;
        User testEmployee = TestFactory.createUser('Employee', 'employee@bbsihq.zzz', 'employee@bbsihq.zzz', 'BBSI Standard', '910', false);
        testEmployee.IsActive = true;
        testEmployee.AD_UserName__c = 'ts';
        insert new List<USer> { u1, u2, u3, u4, testEmployee };

        Id bbsiEmployeeRecordTypeId = RecordTypeService.getId('Contact','BBSI_Employee');

        Contact c1 = new Contact( User_ID__c = u1.Id,
                                  RecordTypeId = bbsiEmployeeRecordTypeId,
                                  FirstName = u1.FirstName,
                                  LastName = u1.LastName,
                                  Email = u1.Email,
                                  Phone = u1.Phone,
                                  MobilePhone = u1.MobilePhone,
                                  Branch_Id__c = u1.Branch_Id__c,
                                  Active__c = u1.IsActive
                                 );
        insert c1;
    }

    private static void getData() {
        user1 = [SELECT Id, FirstName, LastName, Name, Email FROM User WHERE Email = 'test.name1@test.zzz'];
        user2 = [SELECT Id, FirstName, LastName, Name, Email FROM User WHERE Email = 'test.name2@test.zzz'];
        user3 = [SELECT Id, FirstName, LastName, Name, Email FROM User WHERE Email = 'test.name3@test.zzz'];
        user4 = [SELECT Id, FirstName, LastName, Name, Email FROM User WHERE Email = 'test.name4@test.zzz'];
        contact1 = [SELECT ID, User_ID__c FROM Contact WHERE User_ID__c = :user1.Id LIMIT 1];
    }

    @IsTest
    public static void test_getUserRecordsMap() {
        getData();

        Map<id, User> mapUsers = User_Services.getUserRecordsMap(new Set<Id>{ user1.Id, user2.Id, user3.Id });

        Assert.areEqual('910', mapUsers.get(user1.Id).Branch_ID__c);
        Assert.areEqual('910', mapUsers.get(user2.Id).Branch_ID__c);
        Assert.areEqual('910', mapUsers.get(user3.Id).Branch_ID__c);
    }

    @IsTest
    public static void test_getUsers() {
        getData();

        Map<Id, User> mapUsers = User_Services.getUsers(new Set<Id>{ user1.Id, user2.Id, user3.Id });

        Assert.areEqual('Standard', mapUsers.get(user1.Id).UserType);
        Assert.areEqual('test.name2@test.zzz', mapUsers.get(user2.Id).Email);
        Assert.areEqual(false, mapUsers.get(user3.Id).IsActive);
    }

    /**
     * @description test_getRelatedContactIds retrieves Contact information related to the given users
     */
    @IsTest
    public static void test_getRelatedContactIds() {
        getData();

        Map<Id, Id> mapUsers = User_Services.getRelatedContactIds(new Set<Id>{ user1.Id, user2.Id, user3.Id });

        Assert.areEqual(contact1.Id, mapUsers.get(user1.Id));
        Assert.areEqual(null, mapUsers.get(user2.Id));
        Assert.areEqual(null, mapUsers.get(user3.Id));
    }

    /**
     * @description test_limitEditOfUsers_ChangeOwnData confirms user is allowed to change some of own data
     */
    @IsTest
    public static void test_limitEditOfUsers_ChangeOwnData() {
        getData();

        Map<Id, User> mapOld = new Map<Id, User>();
        mapOld.put(user1.Id, user1);

        Map<Id, User> mapNew = new Map<Id, User>();
        User newUser1 = user1.clone();
        newUser1.LastName = 'TestName1';
        mapNew.put(newUser1.Id, user1);

        Boolean result = User_Services.limitEditOfUsers(mapNew, mapOld);

        System.runAs(user1) {
            result = true;
        }

        if (!result) {
            Assert.isTrue(false, 'An error should not have occurred.');
        }
    }

    /**
     * @description test_limitEditOfUsers_HavePermissions confirms user with correct profile
     * is allowed to change data.
     */
    @IsTest
    public static void test_limitEditOfUsers_HavePermissions() {
        getData();

        Map<Id, User> mapOld = new Map<Id, User>();
        mapOld.put(user1.Id, user1);
        mapOld.put(user2.Id, user2);

        Map<Id, User> mapNew = new Map<Id, User>();
        User newUser1 = user1.clone();
        newUser1.LastName = 'TestName1';
        User newUser2 = user1.clone();
        newUser2.LastName = 'TestName2';
        mapNew.put(newUser1.Id, user1);
        mapNew.put(newUser2.Id, user2);

        Boolean result;

        System.runAs(user4) {
            result = User_Services.limitEditOfUsers(mapNew, mapOld);
        }

        Assert.areEqual(true, result, 'The user changes should not have blocked');
    }

    /**
     * @description test_limitEditOfUsers_NoPermissions fails when user without profile trys
     * to change another user's data.
     */
    @IsTest
    public static void test_limitEditOfUsers_NoPermissions() {
        getData();

        Map<Id, User> mapOld = new Map<Id, User>();
        mapOld.put(user2.Id, user2);

        Map<Id, User> mapNew = new Map<Id, User>();
        User newUser2 = user2.clone();
        newUser2.LastName = 'TestName2';
        mapNew.put(newUser2.Id, user2);

        System.runAs(user4) {
            Assert.areEqual(
                true,
                User_Services.limitEditOfUsers(mapNew, mapOld),
                'User4 has the permissions to edit the Last Name.'
            );
        }

        System.runAs(user2) {
            Assert.areEqual(
                true,
                User_Services.limitEditOfUsers(mapNew, mapOld),
                'User2 is allowed to modify their own Last Name.'
            );
        }

        System.runAs(user1) {
            Assert.areEqual(
                false,
                User_Services.limitEditOfUsers(mapNew, mapOld),
                'User1 does not have the permissions to edit the Last Name.'
            );
        }
    }

    @IsTest
    public static void test_deactivateBusinessUnitMemberOnUserInactive() {
        Account testBranch = TestFactory.createAccount('Test Branch', '98662', 'BBSI Branch', false);
        testBranch.Region__c = 'SoCal';
        testBranch.Zone__c = '1';
        testBranch.External_ID__c = '910';
        insert testBranch;

        User employee = [SELECT Id, LastName, EMail, IsActive FROM User WHERE email = 'employee@bbsihq.zzz'];
        Assert.areEqual(true, employee.IsActive);

        Contact empContact = [SELECT Id, FirstName, LastName, User_Id__c, Active__c FROM Contact WHERE User_Id__c = :employee.Id];
        Assert.areEqual(true, empContact.Active__c);

        Business_Unit__c testBU = TestFactory.createBusinessUnit('Add Case Team Test BU', testBranch, true);
        Business_Unit_Contact__c buMember1 = TestFactory.createBusinessUnitContact(testBU, true, 'Payroll', empContact, true);

        Business_Unit_Contact__c bum1 = [SELECT Id, Active__c, Active_Date__c FROM Business_Unit_Contact__c WHERE Id = :buMember1.Id];
        Assert.areEqual(true, bum1.Active__c);

        test.startTest();

        System.runAs(new User(Id = UserInfo.getUserId())) {
            employee = [SELECT Id, IsActive FROM User WHERE EMail = 'employee@bbsihq.zzz' LIMIT 1];
            employee.IsActive = false;
            update employee;
        }

        test.stopTest();

        empContact = [SELECT Id, Active__c FROM Contact WHERE User_Id__c = :employee.Id];
        Assert.areEqual(false, empContact.Active__c);

        bum1 = [SELECT Id, Active__c, Active_Date__c FROM Business_Unit_Contact__c WHERE Id = :buMember1.Id];
        Assert.areEqual(false, bum1.Active__c);
    }

    @IsTest
    public static void test_deactivateAMWithAccounts() {
        getData();

        User am = TestFactory.createUserAM('Testman', '910', true);

        Account a = TestFactory.createAccount('My Testing Account', '99999', 'Client', false);
        a.OwnerId = am.Id;
        insert a;

        Database.SaveResult results;

        Test.startTest();

        System.runAs(user4) {
            am.IsActive = false;
            results = Database.update(am, false);
        }

        Test.stopTest();

        Assert.areEqual(
            'User is still the owner of some Accounts.  Transfer accounts before deactivating.',
            results.getErrors()[0].getMessage()
        );
    }

    @IsTest
    public static void test_deactivateAMWithLeads() {
        getData();

      	Account referralPartner = TestFactory.createAccountReferralPartner('RP Test', 'Active', '% of Margin', 12.0, null, true);
      	Contact producer = TestFactory.CreateContact(referralPartner, 'Producer', 'Producer', true);
        User am = TestFactory.createUserAM('Testman', '910', false);
        am.Acronym__c = '9999';
        insert am;
        am = [SELECT Id, IsActive, Name, Email, Acronym__c FROM User WHERE Id = :am.Id];

        Account branch = TestFactory.createBranchAccount('BRANCH', '333', user1.Name, user1.Email, true);
        Lead l = TestFactoryLead.makeClientLead('TEST', 'MyTestLead', 'TestCompany', branch.Id, am.Id);
        l.Referral_Partner__c = referralPartner.ID;
        l.Producer__c = producer.id;
        l.Duplicate_Check_Status__c = true;
        l.OwnerId = am.Id;
        insert l;
        Database.SaveResult results;

        Test.startTest();

        System.runAs(user4) {
            am.IsActive = false;
            results = Database.update(am, false);
        }

        Test.stopTest();

        Assert.areEqual(
            'User is still the owner of some Leads.  Transfer leads before deactivating.',
            results.getErrors()[0].getMessage()
        );
    }

    @IsTest
    public static void test_deactivateAMWithBranch() {
        getData();

        User am = TestFactory.createUserAM('Testman', '910', true);
        am = [SELECT Id, Name, Email, IsActive FROM User WHERE Id = :am.Id];
        Account branch = TestFactory.createBranchAccount('TESTBRANCH', '911', am.Name, am.Email, true);

        Database.SaveResult results;

        Test.startTest();

        System.runAs(user4) {
            am.IsActive = false;
            results = Database.update(am, false);
        }

        Test.stopTest();

        Assert.areEqual(
            'User is Area Manager of the branch ' + branch.Name + '.  Set new Area Manager before deactivating.',
            results.getErrors()[0].getMessage()
        );
    }

    @IsTest
    static void test_changedOnlyAllowedFields() {
        User userAccess = TestFactory.createUser('UserAccess', 'user.access@bbsi.zzz', 'user.access@bbsi.zzz', 'User Access Admin', '910', false);
        User userSupport = TestFactory.createUser('Support', 'support@bbsi.zzz', 'support@bbsi.zzz', 'BBSI Support', '910', false);

        insert new List<User>{ userAccess, userSupport };

        User newUserA = new User(
            AboutMe = 'I am a user'
        );
        User oldUserA = new User(
            AboutMe = null
        );
        User newUserB = new User(
            Acronym__c = '12345'
        );
        User oldUserB = new User(
            Acronym__c = null
        );

        Assert.areEqual(false, User_Services.changedOnlyAllowedFields(newUserA, null), 'null old should return false');
        Assert.areEqual(true, User_Services.changedOnlyAllowedFields(newUserA, oldUserA), 'Should be able to change this field');
        Assert.areEqual(false, User_Services.changedOnlyAllowedFields(newUserB, oldUserB), 'Should not be able to change this field');
    }

    @IsTest
	public static void test_actsAsAreaManager() {
        User userAM = TestFactory.createUserAM('AreaManager', '910', false);
        User userBDM = TestFactory.createUserBDM('BDM', 'AAA', 'BBSI Standard', '910', false);
        User userSUP = TestFactory.createUser('Standard', 'standard@bbsi.zzz', 'standard@bbsi.zzz', 'BBSI Support', '910', false);
        User userSTDwAM = TestFactory.createUser('StandardAM', 'standardam@bbsi.zzz', 'standardam@bbsi.zzz', 'BBSI Standard', '910', false);

        insert new List<User>{ userAM, userBDM, userSUP, userSTDwAM };

        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = :PermissionSet_Service.AREA_MANAGER_APPROVER_LABEL];
        PermissionSetAssignment psa = new PermissionSetAssignment(
            PermissionSetId = ps.Id,
            AssigneeId = userSTDwAM.Id
        );
        insert psa;

        Assert.areEqual(true, User_Services.actsAsAreaManager(userAM.Id), 'Area Manager profile should act like an Area Manager');
        Assert.areEqual(false, User_Services.actsAsAreaManager(userBDM.Id), 'BBSI Standard profile should not act like an Area Manager');
        Assert.areEqual(false, User_Services.actsAsAreaManager(userSUP.Id), 'BBSI Suppport profile should not act like an Area Manager');
        Assert.areEqual(true, User_Services.actsAsAreaManager(userSTDwAM.Id), 'BBSI Standard profile with Area Manager Approval should act like an Area Manager');
    }

	@IsTest
	public static void test_getUsers_IdFields() {
        getData();

		Set<Id> idUsers = new Set<Id>{ user1.Id, user2.Id, user3.Id, user4.Id };
		List<String> fields = new List<String>{ 'FirstName', 'LastName', 'Name' };

		Test.startTest();

		Map<Id, User> usersActive = User_Services.getUsers(idUsers, true, fields);
		Map<Id, User> usersAll = User_Services.getUsers(idUsers, false, fields);
		Map<Id, User> usersNone = User_Services.getUsers(new Set<Id>(), true, fields);

		Test.stopTest();

		Assert.areEqual(3, usersActive.size(), 'There are 3 active users');
		Assert.areEqual(4, usersAll.size(), 'There are 3 active users and 1 inactive user');
		Assert.areEqual(0, usersNone.size(), 'No users asked for');
	}
}