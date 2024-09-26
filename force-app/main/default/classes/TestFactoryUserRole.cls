/**
 * @description TestFactoryUserRole contains methods to create test User Roles.
 */
@IsTest
public class TestFactoryUserRole {
	/**
	 * @description createUserRole creates a UserRole in the database.
	 * @param  Name  Name of the UserRole
	 * @return UserRole
	 */
	public static UserRole createUserRole(String Name) {
		return makeUserRole(Name);
	}
	
	/**
	 * @description makeUserRole makes a UserRole in the database.
	 * @param  Name  Name of the UserRole
	 * @return UserRole
	 */
	public static UserRole makeUserRole(String Name) {
		UserRole UserRole = new UserRole(Name = Name);
		return UserRole;
	}

	/**
	 * @description createUserRole creates a UserRole in the database.
	 * @param  Name      Name of the UserRole
	 * @param  devName   Developer Name of the UserRole
	 * @return UserRole
	 */
	public static UserRole createUserRole(String Name, String devName) {
		UserRole usr = makeUserRole(Name, devName);
		insert usr;
		return usr;
	}
	
	/**
	 * @description makeUserRole makes a UserRole in the database.
	 * @param  Name      Name of the UserRole
	 * @param  devName   Developer Name of the UserRole
	 * @return UserRole
	 */
	public static UserRole makeUserRole(String Name, String devName) {
		return new UserRole(Name = Name, DeveloperName = devName);
	}
	
	/**
	 * @description createUserRole makes a UserRole in the database.
	 * @param  Name      Name of the UserRole
	 * @param  idParent  Parent Role Id of the UserRole
	 * @param  devName   Developer Name of the UserRole
	 * @return UserRole
	 */
	public static UserRole createUserRole(String name, Id idParent, String devName) {
		UserRole userRole = makeUserRole(name, idParent, devName);
		insert userRole;
		return userRole;
	}    

	/**
	 * @description makeUserRole makes a UserRole object instance.
	 * @param  Name      Name of the UserRole
	 * @param  idParent  Parent Role Id of the UserRole
	 * @param  devName   Developer Name of the UserRole
	 * @return UserRole
	 */
	public static UserRole makeUserRole(String name, Id idParent, String devName) {
		return new UserRole(Name = name, ParentRoleId = idParent, DeveloperName = devName);
	}
}