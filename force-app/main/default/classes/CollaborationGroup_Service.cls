public without sharing class CollaborationGroup_Service {

    /**
     * getGroups retrieves a map of groups for the given identifiers
     * 
     * @param idGroups - Group ids to get data for
     * @return A Map from Group id to the group
     */
    public static Map<Id, CollaborationGroup> getGroups(Set<Id> idGroups) {
        Map<Id, CollaborationGroup> mapGroups = new Map<Id, CollaborationGroup>();

        for (CollaborationGroup g : [SELECT Id, Name, OwnerId
                                     FROM CollaborationGroup 
                                     WHERE Id IN :idGroups]) {
            mapGroups.put(g.Id, g);
        }

        return mapGroups;
    }

    /**
     * makeCollaborationGroup creates a Collaboration Group.
     * 
     * @param name - The name of the BusinessUnitGroup to create
     */
    public static CollaborationGroup makeCollaborationGroup(String name, String description) {
        return new CollaborationGroup(
            Name = name,
            CanHaveGuests = false,
            CollaborationType = 'Private',
            IsBroadcast = true,
            Description = description
        );
    }

    /**
     * getGroupMembers retrieves a set of ColloborationGroupMembers for each
     * ColloborationGroup given.
     * 
     * @param groupIds is the Set of Collaboration Group Ids to get members for
     * @return A Map relatint CollaborationGroups to a set of CollaborationGroupMembers
     */ 
    public static Map<Id, Set<CollaborationGroupMember>> getGroupMembers(Set<Id> groupIds) {
        Map<Id, Set<CollaborationGroupMember>> mapGroupToMember = new Map<Id, Set<CollaborationGroupMember>>();

        if (groupIds != null && !groupIds.isEmpty()) {
            for (Id groupId : groupIds) {
                mapGroupToMember.put(groupId, new Set<CollaborationGroupMember>());
            }

            for (CollaborationGroupMember member : [SELECT Id, MemberId, CollaborationGroupId, CollaborationRole, LastFeedAccessDate, NotificationFrequency, Member.Name
                                                    FROM CollaborationGroupMember
                                                    WHERE CollaborationGroupId IN :groupIds
                                                   ]) {
                mapGroupToMember.get(member.CollaborationGroupId).add(member);
            }
        }
  
        return mapGroupToMember;  
    }
}