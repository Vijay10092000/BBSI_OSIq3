/**
 * @description UserAreaManager contains standard methods for accessing
 * information about Area Managers.
 */
public without sharing class UserAreaManager {
	@TestVisible
    private static Map<Id, User> mapAreaManagers;
	@TestVisible
    private static Map<Id, User> mapBranchIdToAreaManager;

    /**
     * @description getBranchAreaManager retrieves the Area Manager for the
     * given Branch identifier
     * @param  idBranch Branch account identifier
     * @return User record of the Area Manager
     */
    public static User getBranchAreaManager(Id idBranch) {
        setup();

        if (mapBranchIdToAreaManager.containsKey(idBranch)) {
            return mapBranchIdToAreaManager.get(idBranch);
        }

        return null;
    }

    /**
     * @description isAreaManager determines if the given user identifier belongs
     * has Area Manager as their profile
     * @param  idUser User identifier testing
     * @return true if Area Manager profile
     */
    public static Boolean isAreaManagers(Id idUser) {
        setup();

        return mapAreaManagers.containsKey(idUser);
    }

    /**
     * @description getAreaManagers description
     * @return List of all Users with Area Manager profile
     */
    public static List<User> getAreaManagers() {
        setup();

        return mapAreaManagers.values();
    }

	@TestVisible
    private static void setup() {
        if (mapAreaManagers == null) {
            mapAreaManagers = new Map<Id, User>([
                SELECT Id, Acronym__c, AD_Username__c, Branch_Id__c, CompanyName, ContactId, Department,
                    Deployment_Access__c, Division, Email, FirstName, IsActive, LastName, ManagerId,
                    Name, ProfileId, Title, UserName, UserRoleId, UserType
                FROM User
                WHERE IsActive = TRUE
                AND Profile.Name = 'Area Manager'
            ]);
        }

        if (mapBranchIdToAreaManager == null) {
            mapBranchIdToAreaManager = new Map<Id, User>();

            for (Account branch : AccountBranch.getBranches().values()) {
                for (User am : mapAreaManagers.values()) {
                    if (branch.Branch_Manager__c == am.Name) {
                        mapBranchIdToAreaManager.put(branch.Id, am);
                        break;
                    }
                }
            }
        }
    }
}