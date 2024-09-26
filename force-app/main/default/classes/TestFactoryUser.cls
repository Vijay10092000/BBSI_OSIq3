/**
 * @description TestFactoryUser contains methods to create test Users.
 */
@IsTest
public without sharing class TestFactoryUser {
	/**
	 * @description createUser creates a User in the database.
	 * @param  firstName    First Name of the User
	 * @param  lastName     Last Name of the User
	 * @param  profile      Profile name for User
	 * @param  branchNumber Branch Number
	 * @return User
	 */
	public static User createUser(String firstName, String lastName, String profile, String branchNumber) {
		User user = makeUser(firstName, lastName, profile, branchNumber);
		insert user;
		return user;
	}

	/**
	 * @description makeUser makes a User object.
	 * @param  firstName    First Name of the User
	 * @param  lastName     Last Name of the User
	 * @param  profile      Profile name
	 * @param  branchNumber Branch Number
	 * @param  email
	 * @param  userName  
	 * @return User
	 */
    public static User makeUser(String firstName, String lastName, String profile, String branchNumber, String email, String userName) {
        return new User(
			IsActive = true,
			FirstName = firstName,
			LastName = lastName,
			ProfileId = Profile_Service.getProfileId(profile),
		 	Branch_Id__c = branchNumber,
			Alias = (firstName != null ? firstName.left(1) : '') + lastName.left(5),
			Email = email.toLowerCase(),
			UserName = userName,
			EmailEncodingKey = 'UTF-8',
			LanguageLocaleKey = 'en_US',
			TimeZoneSidKey = 'America/Los_Angeles',
			LocaleSidKey = 'en_US'
		);
    }
    
    /**
	 * @description makeUser makes a User object.
	 * @param  firstName    First Name of the User
	 * @param  lastName     Last Name of the User
	 * @param  profile      Profile name
	 * @param  branchNumber Branch Number
	 * @param  email
	 * @param  userName  
	 * @return User
	 */
    public static User createUser(String firstName, String lastName, String profile, String branchNumber, String email, String userName) {
    	User usr = makeUser(firstName, lastName, profile, branchNumber, email, userName);
    	insert usr;
    	return usr;
    }

	/**
	 * @description makeUser makes a User object.
	 * @param  firstName    First Name of the User
	 * @param  lastName     Last Name of the User
	 * @param  profile      Profile name
	 * @param  branchNumber Branch Number
	 * @return User
	 */
	public static User makeUser(String firstName, String lastName, String profile, String branchNumber) {
		String email = (firstName != null ? firstName + '.' : '') + lastName + TestFactory.EMAIL_DOMAIN;
		email = email.replaceAll('(\\s+)', '').toLowerCase();

		return makeUser(firstName, lastName, profile, branchNumber, email, email);	
	}

	/**
	 * @description createBDM creates a Business Development Manager User in the database.
	 * @param  firstName     First Name of the User
	 * @param  lastName      Last name of the User
	 * @param  profile       Profile name
	 * @param  branchNumber  Branch number
	 * @return User
	 */
	public static User createBDM(String firstName, String lastName, String profile, String branchNumber) {
		User user = makeBDM(firstName, lastName, profile, branchNumber);
		insert user;
		return user;
	}

	/**
	 * @description makeBDM makes a Business Development Manager User object.
	 * @param  firstName     First Name of the User
	 * @param  lastName      Last name of the User
	 * @param  profile       Profile name
	 * @param  branchNumber  Branch number
	 * @return User
	 */
	public static User makeBDM(String firstName, String lastName, String profile, String branchNumber) {
		User user = makeUser(firstName, lastName, profile, branchNumber);

		user.Acronym__c = String.valueOf(TestFactory.getCounter()).leftPad(5, '0');
		user.Business_Activity_Report_BDM__c = true;
		user.Title = 'Business Development Manager';

		return user;
	}

	/**
	 * @description createAreaManager creates an Area Manager User in the database.
	 * @param  firstName     First Name of the User
	 * @param  lastName      Last name of the User
	 * @param  branchNumber  Branch number
	 * @return User
	 */
	public static User createAreaManager(String firstName, String lastName, String branchNumber) {
		User user = makeAreaManager(firstName, lastName, branchNumber);
		insert user;
		return user;
	}

	/**
	 * @description makeAreaManager makes an Area Manager User object.
	 * @param  firstName     First Name of the User
	 * @param  lastName      Last name of the User
	 * @param  branchNumber  Branch number
	 * @return User
	 */
	public static User makeAreaManager(String firstName, String lastName, String branchNumber) {
		User user = makeUser(firstName, lastName, 'Area Manager', branchNumber);

		user.Title = 'Area Manager';

		return user;
	}
		
	/**
	 * @description createPermissionSetAssignments assigns the given users to the PermissionSet.
	 * @param name   Name of the PermissionSet (not Label)
	 * @param users  Users receiving the PermissionSet
	 */
	public static void createPermissionSetAssignments(String name, List<User> users) {
		PermissionSet ps = [
			SELECT Id 
			FROM PermissionSet 
			WHERE Name = :name
		];
		
		List<PermissionSetAssignment> psas = new List<PermissionSetAssignment>();
		
		for (User user : users) {
			psas.add(
				new PermissionSetAssignment(
					AssigneeId = user.Id, 
					PermissionSetId = ps.Id
				)
			);
		}
		
		insert psas;
	}
}