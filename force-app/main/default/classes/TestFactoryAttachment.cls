/**
 * @description TestFactoryAttachment contains methods to create test Attachment.
 */
@isTest
public class TestFactoryAttachment {
    /**
	 * @description createAttachment create a Attachment in the database.
	 * @param  Name     Name For Attachment    
	 * @param  body     body For Attachment
	 * @param  parent   parent Id For Attachment
	 * @param  fldMap 	additional field values for the Attachment
	 * @return Attachment
	 */
    public static Attachment createAttachment(String name, String body, ID parent, Map<String, Object> fldMap){
        Attachment attach = makeAttachment(Name, body, parent, fldMap);
        insert attach;
        return attach;
    }

    /**
	 * @description makeAttachment makes a Attachment in the database.
	 * @param  Name     Name For Attachment    
	 * @param  body     body For Attachment
	 * @param  parent   parent Id For Attachment
	 * @param  fldMap   additional field values for the Attachment
	 * @return Attachment
	 */
    public static Attachment makeAttachment(String name, String body, ID parent, Map<String, Object> fldMap){
        Attachment attach = new Attachment(
            body = Blob.valueOf(body),
            Name = name,
            parentId = parent
        );
        if(fldMap != null) {
			attach = (Attachment) TestFactory.assignFields(fldMap, attach);
		}
		return attach;
    }
}