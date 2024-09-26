/**
 * @description Group_Service contains methods to aid with handling Groups, which include queues.
 */
public without sharing class Group_Service {    
	/**
	 * @description getGroupEmails retrieves the emails for each of the groups given.
	 * 
	 * @param groupIds is the Set of group Ids to get members for
	 * @return A map of group Id to email
	 */
	public static Map<Id, String> getGroupEmails(Set<Id> groupIds) {
		Map<Id, String> result = new Map<Id, String>();
		
		for (Group g : [SELECT Id, Email FROM Group WHERE Id IN :groupIds]) {
			result.put(g.Id, g.Email);
		}
		
		return result;        
	}
	
	/**
	 * @description getUserIdsInGroups returns the User Ids who belong to the given list of
	 * group Ids and potentially sub-groups.
	 * WARNING: This may call multiple SOQL queries when the parameter subgroups
	 * is true.  It makes one call for each group level.
	 * 
	 * @param groupIds is the Set of group Ids to get members for
	 * @param useSubgroups is whether to continue into subgroups of the inital group Ids
	 * @return A Set of the User Ids from the groups found
	 */
	@SuppressWarnings('PMD.OperationWithLimitsInLoop')
	public static Set<Id> getUserIdsInGroups(Set<Id> groupIds, Boolean useSubgroups) {
		Set<Id> userIds = new Set<Id>();
		
		if (groupIds != null && !groupIds.isEmpty()) {  
			Set<Id> workingGroupIds = new Set<Id>(groupIds);
			
			do {
				List<GroupMember> members = 
					[SELECT Id, GroupId, UserOrGroupId
					FROM GroupMember
					WHERE GroupId IN :workingGroupIds
					AND UserOrGroupId != null];
				
				workingGroupIds.clear();
				
				for (GroupMember member : members) {
					if (Schema.Group.SObjectType == member.UserOrGroupId.getSobjectType()) {
						workingGroupIds.add(member.UserOrGroupId);
					}
					else if (Schema.User.SObjectType == member.UserOrGroupId.getSobjectType()) {
						userIds.add(member.UserOrGroupId);
					}
				}
			} while (useSubgroups && 0 < workingGroupIds.size());
		}
		
		return userIds;  
	}

/**** TODO: FUTURE WORK
	/ **
	 * @description getGroupsUserIsAMember returns the Groups a set of Users belongs to.
	 * 
	 * @param userIds is the Set of user Ids to find groups for
	 * @return A Map relating Users to Groups
	 * /
	public static Map<Id, Set<Group>> getGroupsUserIsAMember(Set<Id> userIds) {
		Map<Id, Set<Group>> result = new Map<Id, Set<Group>>();
		
		if (userIds != null && !userIds.isEmpty()) {
			List<GroupMember> members = 
				[SELECT Id, GroupId, UserOrGroupId
					FROM GroupMember
					WHERE UserOrGroupId IN :userIds];

			Set<Id> groupIds = new Set<Id>();

			for (GroupMember m : members) {
				groupIds.add(m.GroupId);
				result.put(m.UserOrGroupId, new Set<Group>());
			}

			Map<Id, Group> groups = new Map<Id, Group>(
				[SELECT Id, Name, Email, Type, RelatedId, DeveloperName, DoesIncludeBosses, DoesSendEmailToMembers 
					FROM Group
					WHERE Id IN :groupIds]);

			for (GroupMember m : members) {
				result.get(m.UserOrGroupId).add(groups.get(m.GroupId));
			}
		}
		
		return result;  
	}

	/ **
	 * @description getGroupMembers builds a map with all the related members for the given
	 * groups and their subgroups.
	 * WARNING: This may call multiple SOQL queries when the parameter subgroups
	 * is true.  It makes one call for each group level.
	 * 
	 * @param groupIds is the Set of group Ids to get member's emails from
	 * @param useSubgroups is whether to continue into subgroups of the inital group Ids
	 * @return A map of groupIds with a list of GroupMember
	 * /
	public static Map<Id, Set<GroupMember>> getGroupMembers(Set<Id> groupIds, Boolean useSubgroups) {
		Map<Id, Set<GroupMember>> groupMembers = new Map<Id, Set<GroupMember>>();

		if (groupIds != null && !groupIds.isEmpty()) {		
			Set<Id> workingGroupIds = new Set<Id>();
			
			for (Id i : groupIds) {
				groupMembers.put(i, new Set<GroupMember>());
				workingGroupIds.add(i);
			}
			
			do {
				List<GroupMember> members = 
					[SELECT Id, GroupId, UserOrGroupId
					FROM GroupMember
					WHERE GroupId IN :workingGroupIds
					AND UserOrGroupId != null];
				
				workingGroupIds.clear();
				
				for (GroupMember member : members) {
					groupMembers.get(member.GroupId).add( member );

					if (Schema.Group.SObjectType == member.UserOrGroupId.getSobjectType()) {
						groupMembers.put(member.UserOrGroupId, new Set<GroupMember>());
						workingGroupIds.add(member.UserOrGroupId);
					}
				}
			} while (useSubgroups && 0 < workingGroupIds.size());
		}
	
		return groupMembers;
	}

	/ **
	 * @description getFullGroupEmails returns the email addresses of the given groupIds.
	 * The method take into account a group's Email and DoesSendEmailToMembers.  
	 * If DoesSendEmailToMembers is false, that group and subgroups are not added,
	 * but the email will be if not blank.
	 * WARNING: This may call multiple SOQL queries when the parameter subgroups
	 * is true.  It makes one call for each group level.
	 * 
	 * @param groupIds is the Set of group Ids to get member's emails from
	 * @param useSubgroups is whether to continue into subgroups of the inital group Ids
	 * @return A map of groupIds with a lisetst of email addresses
	 * /
	public static Map<Id, Set<String>> getFullGroupEmails(Set<Id> groupIds, Boolean useSubgroups) {
		Map<Id, Set<String>> groupEmails = new Map<Id, Set<String>>();

		for (Id i : groupIds){
			groupEmails.put(i, new Set<String>());
		}

		Map<Id, Set<GroupMember>> groupTree = getGroupMembers(groupIds, useSubgroups);

		if (!groupTree.isEmpty()) {
			Set<Id> allGroupIds = new Set<Id>(groupIds);
			Set<Id> allUserIds = new Set<Id>();

			for (Set<GroupMember> setGM : groupTree.values()) {
				for (GroupMember member : setGM) {
					if (Schema.Group.SObjectType == member.UserOrGroupId.getSobjectType()) {
						allGroupIds.add(member.UserOrGroupId);
					}
					else if (Schema.User.SObjectType == member.UserOrGroupId.getSobjectType()) {
						allUserIds.add(member.UserOrGroupId);
					}                    
				}
			}

			Map<Id, Group> mapAllGroups = new Map<Id, Group>([SELECT Id, Name, Email, Type, RelatedId, DeveloperName, DoesIncludeBosses, DoesSendEmailToMembers 
															FROM Group
															WHERE Id IN :allGroupIds]);

			Map<Id, User> mapAllUsers = new Map<Id, User>([SELECT Id, Email 
														FROM User
														WHERE Id IN :allUserIds]);          
			Id workingId;
			for (Id i : groupIds) {
				List<Id> workIds = new List<Id>();
				workIds.add(i);

				while (!workIds.isEmpty()) {
					workingId = workIds.get(0);  
					workIds.remove(0);
					Group g = mapAllGroups.get(workingId);

					if (g.Email != null) {
						groupEmails.get(i).add(g.Email);
					}

					if (g.DoesSendEmailToMembers) {
						for (GroupMember member : groupTree.get(workingId)) {
							if (Schema.Group.SObjectType == member.UserOrGroupId.getSobjectType()) {
								workIds.add(member.UserOrGroupId);
							}
							else if (Schema.User.SObjectType == member.UserOrGroupId.getSobjectType()) {
								groupEmails.get(i).add(mapAllUsers.get(member.UserOrGroupId).Email);
							} 
						}
					}
				}
			}
		}
		return groupEmails;  
	}
****/
}