/**
 * CollaborationGroupMember_Service
 */
public with sharing class CollaborationGroupMember_Service {

    /**
     * makeCollaborationGroupMember creates a Standard CollaborationGroupMember object.
     * 
     * @param groupId - Identifier of the group member (a CollaborationGroup Id)
     * @param memberId - Identifier of the group member (a User Id)
     * @return A CollaborationGroupMember
     */
    public static CollaborationGroupMember makeCollaborationGroupMember(Id groupId, Id memberId) {
        return new CollaborationGroupMember(
            CollaborationGroupId = groupId,
            MemberId = memberId,
            CollaborationRole = 'Standard'
        );
    }
    
    /**
     * inList determines if the given User Id is part of the given list.AexPage
     *
     * @param members - List of CollaborationGroupMembers to search
     * @param idMember - A User Id checking for
     * @return true if found
     */
    public static Boolean inList(List<CollaborationGroupMember> members, Id idMember) {
        for (CollaborationGroupMember m : members) {
            if (m.MemberId == idMember) {
                return true;
            }
        }
        return false;
    }

}