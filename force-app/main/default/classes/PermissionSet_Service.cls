/**
 * PermissionSet_Service contains methods to simplify access to
 * information about Permission Sets.
 */
public without sharing class PermissionSet_Service {

    /**
     * Use these static values in place of hard-coded strings.
     */
    public static final String REFERRAL_PARTNER_ADMIN = 'Referral_Partner_Admin';
    public static final String REFERRAL_PARTNER_ADMIN_LABEL = 'Referral Partner Admin';
    public static final String RENEWALS_STATUS_EDIT = 'Renewals_Status_Edit';
    public static final String RENEWALS_STATUS_EDIT_LABEL = 'Renewals Status Edit';
    public static final String AREA_MANAGER_APPROVER_LABEL = 'Area_Manager_Approver';

    /**
     * permissionSets holds list of Permission Set data.  It is filled if needed.
     */
    @TestVisible
    private static Map<String, PermissionSet> permissionSets = null;

    /**
     * getPermissionSetInfo retrieves base information about the given
     * Permission Set names.
     * @param  names Names of Permission Sets to get data for
     * @return Map of Permission Set names to PermissionSet objects
     */
    public static Map<String, PermissionSet> getPermissionSetInfo(Set<String> names) {
        readPermissionSetInfo();

        Map<String, PermissionSet> result = new Map<String, PermissionSet>();

        if (names != null) {
            for (String name : names) {
                if (permissionSets.containsKey(name)) {
                    result.put(name, permissionSets.get(name));
                }
            }
        }
        
        return result;
    }

    /**
     * readPermissionSetInfo sets/updates the permissionSets data.
     */
    @TestVisible
    private static void readPermissionSetInfo() {
        if (permissionSets == null) {
            permissionSets = new Map<String, PermissionSet>();
            
            for (PermissionSet ps : [SELECT Id, Name, Label, NamespacePrefix, Description,
                                            IsOwnedByProfile, ProfileId, Profile.Name, 
                                            CreatedDate, CreatedById, CreatedBy.Name,
                                            LastModifiedDate, LastModifiedById, LastModifiedBy.Name,
                                            SystemModstamp
                                     FROM PermissionSet]) {
                permissionSets.put(ps.Name, ps);
            }
        }
    }

    /**
     * resetPermissionSetInfo sets/updates the permissionSets data.
     */
    public static void resetPermissionSetInfo() {
        permissionSets = null;
    }

    /**
     * getPermissionSetUsers retrives a Map relating Permission Set
     * names to List of User Ids.
     * @param  names  A Set of Permission Set names
     * @return A Map relating Permission Set names to List of User Ids
     */
    public static Map<String, List<Id>> getPermissionSetUsers(Set<String> names) {
        Map<String, List<Id>> result = new Map<String, List<Id>>();

        if (names != null) {
            for (String name : names) {
                result.put(name, new List<Id>());
            }

            for (PermissionSetAssignment psa : [SELECT AssigneeId, PermissionSet.Name
                                                FROM PermissionSetAssignment 
                                                WHERE PermissionSet.Name IN :names]) {
                result.get(psa.PermissionSet.Name).add(psa.AssigneeId);
            }
        }

        return result;
    }

    /**
     * getUserPermissionSets retrieves a Map relating User Ids to
     * List of Permission Sets.
     * @param  userIds  A Set of User Ids
     * @return A Map relating User Ids to List of Permission Set Ids
     */
    public static Map<Id, List<PermissionSet>> getUserPermissionSets(Set<Id> userIds) {
        readPermissionSetInfo();

        Map<Id, List<PermissionSet>> result = new Map<Id, List<PermissionSet>>();

        if (userIds != null) {
            for (Id id : userIds) {
                result.put(id, new List<PermissionSet>());
            }

            for (PermissionSetAssignment psa : [SELECT AssigneeId, PermissionSetId
                                                FROM PermissionSetAssignment 
                                                WHERE AssigneeId IN :userIds]) {
                for (PermissionSet ps : permissionSets.values()) {
                    if (ps.Id == psa.PermissionSetId) {
                        result.get(psa.AssigneeId).add(ps);
                        break;
                    }
                }
            }
        }

        return result;
    }

    /**
     * userHasCustomPermission determines if the given User Id has
     * the Custom Permission
     * @param  idUser     Id of the User to test
     * @param  permission Developer name of the Custom Permission
     * @return true if the user has the Custom Permission
     */
    public static Boolean userHasCustomPermission(Id idUser, String permission) {
        Set<Id> idUsersWithCP = getUsersWithCustomPermission(permission);

        return idUsersWithCP.contains(idUser);
    }

    /**
     * getUsersWithCustomPermission retrives a Set of Users Ids with
     * the given Custom Permission.
     * @param  permission Developer name of the Custom Permission
     * @return A Set of User Ids
     */
    public static Set<Id> getUsersWithCustomPermission(String permission) {
        Set<Id> result = new Set<Id>();

        // Get list of Permission Set Ids having the Custom Permission
        Set<Id> permissionSetIds = new Set<Id>();
        for (SetupEntityAccess access : [
            SELECT ParentId 
            FROM SetupEntityAccess 
            WHERE SetupEntityId IN (
                SELECT Id 
                FROM CustomPermission 
                WHERE DeveloperName = :permission
            )
        ]) {
            permissionSetIds.add(access.ParentId);
        }

        if (!permissionSetIds.isEmpty()) {
            // Get all Users with the found Permission Sets
            for (User u : [
                SELECT Id FROM User WHERE Id IN (
                    SELECT AssigneeId FROM PermissionSetAssignment
                    WHERE PermissionSetId IN :permissionSetIds
                )
            ]) {
                result.add(u.Id);
            }
        }
        
        return result;
    }
    
}