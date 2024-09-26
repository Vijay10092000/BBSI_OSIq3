/**
 * @description TestFactoryAdminBranch contains methods to create test AdminBranchs.
 */
@IsTest
public without sharing class TestFactoryAdminBranch {
	/**
	 * @description createAdminBranch creates a new AdminBranch record in the database.
	 * @param  name     Name of the AdminBranch
	 * @param  adminUser Admin User name for the AdminBranch
	 * @return AdminBranch
	 */
	public static Admin_Branch__c createAdminBranch(String name, String adminUser) {
		Admin_Branch__c AdminBranch = makeAdminBranch(name, adminUser);
		insert AdminBranch;
		return AdminBranch;
	}

	/**
	 * @description makeAdminBranch creates a Admin_Branch__c object.
	 * @param  name name  Name of the List
	 * @param  adminUser Admin User name for the AdminBranch
	 * @return Admin_Branch__c
	 */
	public static Admin_Branch__c makeAdminBranch(String name, String adminUser) {
		return new Admin_Branch__c(
            Name = name,
            Admin_User__c = adminUser
        );
	}
}