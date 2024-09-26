/**
 * @description StaticResource_Service
 *
 * @see https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_system_pagereference.htm
 */
public without sharing class StaticResource_Service {
    @TestVisible
    private static Blob blobTest;

    /**
     * @description getBlob retrieves the Blob from a file within a Zip file resource.
     * NOTE: getContext fails during tests (see https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_System_PageReference_getContent.htm).
     * @param  filename Resource Zip filename
     * @param  filePath Path within the Zip file
     * @return Text of the file
     */
    public static Blob getBlob(String filename, String filePath) {
        PageReference reference;

        if (filePath == null) {
            reference = PageReference.forResource(filename);
        } else {
            reference = PageReference.forResource(filename, filePath);
        }

        if (Test.isRunningTest()) {
            return blobTest;
        }

        return reference.getContent();
    }

    /**
     * @description getBlob retrieves the Blob from a file resource.
     * @param  filePath    Resource path to file
     * @return Text of the file
     */
    public static Blob getBlob(String filePath) {
        return getBlob(filePath, null);
    }

    /**
     * @description getText retrieves the text from a file resource.
     * @param  filePath    Resource path to file
     * @return Text of the file
     */
    public static String getText(String filePath) {
        return getBlob(filePath).toString();
    }

    /**
     * @description getText retrieves the text from a file within a Zip file resource.
     * @param  filename  Resource Zip filename
     * @param  filePath  Path within the Zip file
     * @return Text of the file
     */
    public static String getText(String filename, String filePath) {
        return getBlob(filename, filePath).toString();
    }
}