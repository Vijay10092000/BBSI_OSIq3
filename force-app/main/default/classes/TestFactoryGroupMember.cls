/**
 * @description TestFactoryGroupMember contains methods to create test GroupMember.
 */
@isTest
public class TestFactoryGroupMember {
    /**
	 * @description createGroupMember create a GroupMember in the database.
	 * @param  UserOrGroupId    UserOrGroupId GroupMember    
	 * @param  GroupId    GroupId For GroupMember
	 * @return GroupMember
	 */
    public static GroupMember createGroupMember(String UserOrGroupId,String GroupId){
        GroupMember grpmbr = makeGroupMember(UserOrGroupId, GroupId);
        insert grpmbr;
        return grpmbr;
    }

    /**
	 * @description makeGroupMember makes a GroupMember in the database.
	 * @param  UserOrGroupId    UserOrGroupId GroupMember    
	 * @param  GroupId    GroupId For GroupMember
	 * @return GroupMember
	 */
    public static GroupMember makeGroupMember(String UserOrGroupId,String GroupId){
        return new GroupMember(UserOrGroupId = UserOrGroupId, GroupId = GroupId);
    }
}