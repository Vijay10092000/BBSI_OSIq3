/**
 * @description BusinessUnit_Service
 */
public without sharing class BusinessUnit_Service {
    private static String formatDescription = 'Chatter Group for the Business Unit: {0}';
    private static Map<String, List<String>> mapBUToEmails;

    /**
     * @description makeBusinessUnitGroup creates a Business Unit Chatter Group.
     * @param name - The name of the BusinessUnitGroup to create
     * @return The new BusinessUnitGroup (CollaborationGroup)
     */
    @testVisible
    public static CollaborationGroup makeBusinessUnitGroup(String name) {
        CollaborationGroup cg = CollaborationGroup_Service.makeCollaborationGroup(
            name,
            makeDescription(name)
        );
        cg.CollaborationType = 'Public';
        return cg;
    }

    /**
     * @description insertChatterGroups creates a related Chatter Group (CollaborationGroup)
     * is for the Business_Unit__c if it does not exist.
     * Called during BEFORE INSERT and BEFORE UPDATE trigger
     * @param newValues - The changed or new values for a Business Unit.
     */
    public static void insertChatterGroups(List<Business_Unit__c> newValues) {
        List<CollaborationGroup> insertGroups = new List<CollaborationGroup>();

        for (Business_Unit__c newBU : newValues) {
            if (String.isBlank(newBU.Chatter_Group_Id__c)) {
                insertGroups.add( makeBusinessUnitGroup(newBU.Name) );
            }
        }

        if (!insertGroups.isEmpty()) {
            insert insertGroups;

            for (Business_Unit__c newBU : newValues) {
                for (CollaborationGroup cg : insertGroups) {
                    if (newBU.Name == cg.Name) {
                        newBU.Chatter_Group_Id__c = cg.Id;
                        break;
                    }
                }
            }
        }
    }

    /**
     * @description insertChatterGroupMembers adds members to the Chatter Group related to the
     * Business Unit.  This will only happen if the members are not already in
     * the group.
     * @param newValues Business_Units to get members from
     */
    public static void insertChatterGroupMembers(Map<Id, Business_Unit__c> newValues) {
        List<Id> idBUs = new List<Id>();
        for (Business_Unit__c bu : newValues.values()) {
            if (bu.Chatter_Group_Id__c != null) {
                idBUs.add(bu.Id);
            }
        }

        Map<Id, Business_Unit_Contact__c> mapBUMs = getBusinessUnitMembersWithoutChatter(idBUs);

        if (!mapBUMs.isEmpty()) {
            Map<Id, CollaborationGroupMember> mapBUtoMembers = createNewMembers(newValues, mapBUMs);

            insert mapBUtoMembers.values();

            for (Business_Unit_Contact__c bum : mapBUMs.values()) {
                if (mapBUtoMembers.containsKey(bum.Id)) {
                    bum.Chatter_Group_Member_Id__c = mapBUtoMembers.get(bum.Id).Id;
                }
            }

            update mapBUMs.values();
        }
    }

    /**
     * @description updateChatterGroups determines if the Business Unit's name changes,
     * the Chatter Group name is changed to match.
     * Called during AFTER UPDATE trigger
     * @param newValues - The changed or new values for a Business Unit.
     * @param oldValues - The old values for a Business Unit.
     */
    public static void updateChatterGroups(Map<Id, Business_Unit__c> newValues, Map<Id, Business_Unit__c> oldValues) {
        Set<Id> cIds = new Set<Id>();

        for (Business_Unit__c newBU : newValues.values()) {
            if (oldValues != null && newBU.Name != oldValues.get(newBU.Id).Name) {
                cIds.add((Id)newBU.Chatter_Group_Id__c);
            }
        }

        if (!cIds.isEmpty()) {
            List<CollaborationGroup> groups = [SELECT Id, Name FROM CollaborationGroup WHERE CollaborationGroup.Id IN :cIds];

            for (CollaborationGroup g : groups) {
                for (Business_Unit__c bu : newValues.values()) {
                    if (g.Id == bu.Chatter_Group_Id__c) {
                        g.Name = bu.Name;
                        g.Description = makeDescription(bu.Name);
                        break;
                    }
                }
            }

            update groups;
        }
    }

    @TestVisible
    private static String makeDescription(String name) {
        return String.format(formatDescription, new List<String>{name});
    }


    @TestVisible
    private static  Map<Id, Business_Unit_Contact__c> getBusinessUnitMembersWithoutChatter(List<Id> idBUs) {
        return new Map<Id, Business_Unit_Contact__c>([
            SELECT Id, BU_User_Id__c, Business_Unit__c, Chatter_Group_Member_Id__c
            FROM Business_Unit_Contact__c
            WHERE Business_Unit__c IN :idBUs
            AND Active__c = true
            AND Chatter_Group_Member_Id__c = NULL
            AND BU_User_Id__c != NULL
        ]);
    }

    @TestVisible
    private static Map<Id, CollaborationGroupMember> createNewMembers(Map<Id, Business_Unit__c> newValues, Map<Id, Business_Unit_Contact__c> mapBUMs) {
        Map<Id, CollaborationGroupMember> mapBUtoMembers = new Map<Id, CollaborationGroupMember>();
        for (Business_Unit_Contact__c bum : mapBUMs.values()) {
            CollaborationGroupMember member = CollaborationGroupMember_Service.makeCollaborationGroupMember(
                newValues.get(bum.Business_Unit__c).Chatter_Group_Id__c,
                bum.BU_User_Id__c
            );
            mapBUtoMembers.put(bum.Id, member);
        }

        return mapBUtoMembers;
    }

    /**
     * @description getBusinessUnitEmails retrieves a list of email addresses of the active
     * members of the given Business Unit.
     * @param idBusinessUnit Identifier of the Business Unit
     * @return List<String> of email addresses, empty List if not found
     */
    public static List<String> getBusinessUnitEmails(Id idBusinessUnit) {
        if (mapBUToEmails == null) {
            mapBUToEmails = new Map<String, List<String>>();

            List<Business_Unit_Contact__c> members = new List<Business_Unit_Contact__c>([
                SELECT Id, Business_Unit__c, BU_User_Id__c, Bu_Member__r.Name
                FROM Business_Unit_Contact__c
                WHERE Active__c = TRUE
                AND User_Active__c = TRUE
                ORDER BY Business_Unit__c
            ]);

            List<Id> idUsers = new List<Id>();
            for (Business_Unit_Contact__c member: members) {
                idUsers.add(member.BU_User_Id__c);
            }

            Map<Id, User> mapUsers = new Map<Id, User>([
                SELECT Id, Name, Email FROM User WHERE Id IN :idUsers
            ]);

            for (Business_Unit_Contact__c member : members) {
                if (!mapBUToEmails.containsKey(member.Business_Unit__c)) {
                    mapBUToEmails.put(member.Business_Unit__c, new List<String>());
                }

                if (mapUsers.containsKey(member.BU_User_Id__c)) {
                    mapBUToEmails.get(member.Business_Unit__c).add(mapUsers.get(member.BU_User_Id__c).Email);
                }
            }
        }

        if (mapBUToEmails.containsKey(idBusinessUnit)) {
            List<String> addresses = mapBUToEmails.get(idBusinessUnit);

            return addresses;
        }

        return new List<String>();
    }
}