/**
 * @description TestFactoryGroup contains methods to create test Group.
 */
@isTest
public class TestFactoryGroup {
    /**
	 * @description createGroup create a Group in the database.
	 * @param  Name    Name For Group    
	 * @param  Type    Type For Group
	 * @param  DoesSendEmailToMembers  Is Does Send Email To Members?
	 * @param  Email Email
	 * @return Group
	 */
    public static Group createGroup(String Name,String Type, Boolean DoesSendEmailToMembers, String Email){
        Group grp = makeGroup(Name,Type, DoesSendEmailToMembers, Email);
        insert grp;
        return grp;
    }

    /**
	 * @description makeGroup makes a Group in the database.
	 * @param  Name    Name For Group    
	 * @param  Type    Type For Group
	 * @param  DoesSendEmailToMembers  Is Does Send Email To Members?
	 * @param  Email Email
	 * @return Group
	 */
    public static Group makeGroup(String Name,String Type, Boolean DoesSendEmailToMembers, String Email){
        return new Group(Name = Name, Type = Type, DoesSendEmailToMembers = DoesSendEmailToMembers, Email = Email);
    }
}