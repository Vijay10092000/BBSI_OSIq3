/**
 * @description StaticResource_Service_Test
 */
@IsTest
public without sharing class StaticResource_Service_Test {
    @isTest
    static void test_getText_Plain() {
        StaticResource_Service.blobTest = Blob.valueOf('Get Text Plain');

        String text = StaticResource_Service.getText('TestFile_StaticResource_Plain');

        System.assertEquals('Get Text Plain', text);
    }

    // TODO: Create Static Resources: TestFile_StaticResource_Plain and TestFile_StaticResource_Zip
    @isTest
    static void test_getText_Zip() {
        StaticResource_Service.blobTest = Blob.valueOf('Get Text Zip');

        String text = StaticResource_Service.getText('TestFile_StaticResource_Zip', 'TestFile');

        System.assertEquals('Get Text Zip', text);
    }
}