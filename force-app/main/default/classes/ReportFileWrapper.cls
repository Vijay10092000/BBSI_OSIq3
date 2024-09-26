/**
     * @description ReportFileWrapper is a wrapper class which holds a filename and the file data.
 */
public without sharing class ReportFileWrapper {
    @AuraEnabled
    public String filename { get; private set; }

    @AuraEnabled
    public String text { get; private set; }

    @AuraEnabled
    public String type { get; private set; }

    public ReportFileWrapper(String filename, String text, String type) {
        this.filename = filename;
        this.text = text;
        this.type = type;
    }
}