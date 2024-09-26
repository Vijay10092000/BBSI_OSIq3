/**
 * @description TestFactoryPermissionSetAssignment contains methods to create test PermissionSetAssignment.
 */
@IsTest
public without sharing class TestFactoryPermissionSetAssignment {
    /**
     * @description createPermissionSetAssignment creates a new PermissionSetAssignment record in the database.
     * @param  PermissionSetId  PermissionSetId of the PermissionSetAssignment
     * @param  AssigneeId       AssigneeId of the PermissionSetAssignment
     * @return PermissionSetAssignment
     */
    public static PermissionSetAssignment createPermissionSetAssignment(String PermissionSetId, String AssigneeId) {
        PermissionSetAssignment testPermissionSetAssignment = makePermissionSetAssignment(PermissionSetId, AssigneeId);
        insert testPermissionSetAssignment;
        return testPermissionSetAssignment;
    }

    /**
     * @description makePermissionSetAssignment makes a new PermissionSetAssignment record in the database.
     * @param  PermissionSetId  PermissionSetId of the PermissionSetAssignment
     * @param  AssigneeId       AssigneeId of the PermissionSetAssignment
     * @return PermissionSetAssignment
     */
    public static PermissionSetAssignment makePermissionSetAssignment(String PermissionSetId, String AssigneeId) {        
        return new PermissionSetAssignment(PermissionSetId=PermissionSetId, AssigneeId=AssigneeId);            
    }

    /**
     * @description createPermissionSet creates a PerissionSet with the given Custom Permissions
     * @param namePermissionSet  Name to give the test PermissionSet
     * @param customPerissions   DeveloperNames of the Custom Permissions
     */
    public static Id createPermissionSet(String namePermissionSet, List<String> customPermissions) {
        Map<String, Id> mapCustomPermissions = new Map<String, Id>();

        for (CustomPermission custom : [
            SELECT Id, DeveloperName
            FROM CustomPermission
            WHERE DeveloperName in :customPermissions
            LIMIT 1
        ]) {
            mapCustomPermissions.put(custom.DeveloperName, custom.Id);
        }

        PermissionSet ps = new PermissionSet(
            Name = namePermissionSet,
            Label = namePermissionSet
        );
        insert ps;

        List<SetupEntityAccess> sobjects = new List<SetupEntityAccess>();

        for (String permission : customPermissions) {
            if (mapCustomPermissions.containsKey(permission)) { 
                sobjects.add(
                    new SetupEntityAccess(
                        ParentId = ps.Id,
                        SetupEntityId = mapCustomPermissions.get(permission)
                    )
                );
            }
        }
    
        insert sobjects;

        return ps.Id;
    }

    public static void assignPermissionSet(Id idPermissionSet, List<Id> idUsers) {
        List<PermissionSetAssignment> sobjects = new List<PermissionSetAssignment>();
            
        for (Id idUser : idUsers) {
            sobjects.add(
                new PermissionSetAssignment(
                    PermissionSetId = idPermissionSet,
                    AssigneeId = idUser
                )
            );
        }

        insert sobjects;
    }
}