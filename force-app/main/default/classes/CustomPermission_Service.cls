public without sharing class CustomPermission_Service {

    public static final String CAN_CHANGE_REFERRAL_PARTNER_ON_CLIENT = 'Can_Change_Referral_Partner_on_Client';
    public static final String NEW_PRICING_PILOT = 'New_Pricing_Pilot';
    public static final String SERVICE_CLOUD_PILOT = 'Service_Cloud_Pilot';
    public static final String REFERRAL_PARTNER_GROUP_EDIT = 'Referral_Partner_Group_Edit';

    /**
     * getUserIdsWithCustomPermission retrieves Users with the
     * given Custom Permissions.
     * @param  name DeveloperName of the Custom Permission
     * @return A List of Users with the Custom Permission
     */
    public static Set<Id> getUserIdsWithCustomPermission(String name) {
        Set<Id> idUsers = new Set<Id>();
        Set<Id> permissionSetIds = getRelatedPermissionSets(name);
    
        if (!permissionSetIds.isEmpty()) {
            for (PermissionSetAssignment assignment : [
                SELECT AssigneeId 
                FROM PermissionSetAssignment
                WHERE PermissionSetId IN :permissionSetIds
            ]) {
                idUsers.add( assignment.AssigneeId );
            }
        }
        return idUsers;
    }

    /**
     * checkUserCustomPermission determines if the given user ids
     * have the given Custom Permission.
     * @param  name DeveloperName of the Custom Permission
     * @param  idUsers Set of user Ids to check
     * @return A Map of User ids to has Custom Permission
     */
    public static Map<Id, Boolean> checkUserCustomPermission(String name, Set<Id> idUsers) {
        Map<Id, Boolean> results = new Map<Id, Boolean>();
        for (Id id : idUsers) {
            results.put(id, false);
        } 

        Set<Id> permissionSetIds = getRelatedPermissionSets(name);
    
        if (!permissionSetIds.isEmpty()) {
            List<PermissionSetAssignment> assignments = [  
                SELECT Id, AssigneeId, Assignee.Name
                FROM PermissionSetAssignment
                WHERE AssigneeId IN :idUsers
                AND PermissionSetId IN :permissionSetIds
            ];

            for (PermissionSetAssignment assignment : assignments) {
                results.put(assignment.AssigneeId, true);
            }
        }

        return results;
    }

    /**
     * SetupEntityAccess retrieves SetupEntityAccess with the given
     * Custom Permission active.
     * @param  name DeveloperName of the Custom Permission
     * @return A Set of Permission Sets with Custom Permission 
     */
    private static Set<Id> getRelatedPermissionSets(String name) {
        Set<Id> permissionSetIds = new Set<Id>();

        for (SetupEntityAccess access : [
            SELECT ParentId, Parent.Name 
            FROM SetupEntityAccess 
            WHERE SetupEntityId IN (SELECT Id FROM CustomPermission WHERE DeveloperName = :name)
        ]) {
            permissionSetIds.add(access.ParentId);
        }

        return permissionSetIds;
    }

}