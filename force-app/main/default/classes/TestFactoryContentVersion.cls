@isTest
public class TestFactoryContentVersion {
    /**
    * @description createContentVersion creates a ContentVersion record.
    * @param  fldMap  Additional fields to set on ContentVersion
    * @return ContentVersion
    */
    public static ContentVersion createContentVersion( Map<String, Object> fldMap) {
        ContentVersion testContentVersion = makeContentVersion( fldMap);
        insert testContentVersion;
        return testContentVersion;
    }

    /**
    * @description makeContentVersion creates a ContentVersion record.
    * @param  fldMap  Additional fields to set on ContentVersion
    * @return ContentVersion
    */
    public static ContentVersion makeContentVersion( Map<String, Object> fldMap) {        
        ContentVersion testContentVersion = new ContentVersion();
        
        if (fldMap != null) {
            testContentVersion = (ContentVersion) TestFactory.assignFields(fldMap, testContentVersion);
        }
        return testContentVersion;
    }

}