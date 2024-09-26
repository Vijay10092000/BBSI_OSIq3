@isTest
public class TestFactoryFileHolder {
    /**
    * @description createFileHolder creates a FileHolder record.
    * @param  fldMap  Additional fields to set on FileHolder
    * @return FileHolder
    */
    public static File_Holder__c createFileHolder( Map<String, Object> fldMap) {
        File_Holder__c testFileHolder = makeFileHolder( fldMap);
        insert testFileHolder;
        return testFileHolder;
    }
    
    /**
    * @description makeFileHolder creates a FileHolder record.
    * @param  fldMap  Additional fields to set on FileHolder
    * @return FileHolder
    */
    public static File_Holder__c makeFileHolder( Map<String, Object> fldMap) {        
        File_Holder__c testFileHolder = new File_Holder__c();
        
        if (fldMap != null) {
            testFileHolder = (File_Holder__c) TestFactory.assignFields(fldMap, testFileHolder);
        }
        return testFileHolder;
    }
    
}