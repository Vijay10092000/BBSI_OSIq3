@isTest
public class TestFactoryContentDocumentLink {
    /**
    * @description createContentDocumentLink creates a ContentDocumentLink record.
    * @param  fldMap  Additional fields to set on ContentDocumentLink
    * @return ContentDocumentLink
    */
    public static ContentDocumentLink createContentDocumentLink( Map<String, Object> fldMap) {
        ContentDocumentLink testContentDocumentLink = makeContentDocumentLink( fldMap);
        insert testContentDocumentLink;
        return testContentDocumentLink;
    }

    /**
    * @description makeContentDocumentLink creates a ContentDocumentLink record.
    * @param  fldMap  Additional fields to set on ContentDocumentLink
    * @return ContentDocumentLink
    */
    public static ContentDocumentLink makeContentDocumentLink( Map<String, Object> fldMap) {        
        ContentDocumentLink testContentDocumentLink = new ContentDocumentLink();
        
        if (fldMap != null) {
            testContentDocumentLink = (ContentDocumentLink) TestFactory.assignFields(fldMap, testContentDocumentLink);
        }
        return testContentDocumentLink;
    }

}