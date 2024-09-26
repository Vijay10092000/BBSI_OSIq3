/**
 * FieldSetComponentController
 */
global without sharing class FieldSetComponentController extends VisualEditor.DynamicPickList {
    global override VisualEditor.DataRow getDefaultValue() {
        Map<String, String> recTypeDevNameMap = getRecTypeDevName('Case');
        VisualEditor.DataRow defaultValue;

        for(String recTypeDevName : recTypeDevNameMap.keySet()){
            defaultValue = new VisualEditor.DataRow(recTypeDevName, recTypeDevName);
            break;
        }
        return defaultValue;
    }

    global override VisualEditor.DynamicPickListRows getValues() {
        Map<String, String> recTypeDevNameMap = getRecTypeDevName('Case');
        VisualEditor.DynamicPickListRows myValues = new VisualEditor.DynamicPickListRows();

        for(String recTypeDevName : recTypeDevNameMap.keySet()){
            VisualEditor.DataRow value = new VisualEditor.DataRow(recTypeDevName, recTypeDevName);
            myValues.addRow(value);
        }
        return myValues;
    }

    @TestVisible
    private static Id idActiveAccount = null;

    @AuraEnabled
    public static Boolean isAllowed(String parentRecordId, String recordTypeDevName, String recordTypeId) {
		Id idrtPersonalRequest = RecordTypeService.getId('Case', 'Personal Request');
        return recordTypeId == idrtPersonalRequest;
    }

    @AuraEnabled
    public static String activeContactAccountId() {
        return String.valueOf(idActiveAccount);
    }

    public static Map<String, String> getRecTypeDevName(String objectAPIName) {
        Schema.DescribeSObjectResult descSObjResObj = Schema.getGlobalDescribe().get(objectAPIName).getDescribe();
        Map<String, String> recTypeDevNameMap = new Map<String, String> ();

        for(Schema.RecordTypeInfo recTypeInfoObj : descSObjResObj.getRecordTypeInfos()) {
            if(!recTypeInfoObj.getDeveloperName().equalsIgnoreCase('Master'))
                recTypeDevNameMap.put(recTypeInfoObj.getDeveloperName(), recTypeInfoObj.getName());
        }
        return recTypeDevNameMap;
    }

    @AuraEnabled
    public static Integer getDynamicAfter(String parentRecordId, String recordTypeDevName, String recordTypeId) {
        String recordTypeName = '';
        Map<String, String> recTypeDevNameMap = getRecTypeDevName('Case');

		if (String.isBlank(recordTypeDevName) && String.isBlank(recordTypeId)) {
			List<Schema.RecordTypeInfo> infos = Schema.SObjectType.Case.RecordTypeInfos;

			for (Schema.RecordTypeInfo info : infos) {
				if (info.DefaultRecordTypeMapping) {
					recordTypeId = info.RecordTypeId;
				}
			}
		}

        if (String.isNotBlank(recordTypeDevName)) {
            recordTypeName = recTypeDevNameMap.get(recordTypeDevName);
            recordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
        }
        else if (String.isNotBlank(recordTypeId)) {
            recordTypeName = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosById().get(recordTypeId).getName();
            recordTypeDevName = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get(recordTypeName).getDeveloperName();
        }

		System.debug(LoggingLevel.INFO, 'FieldSetComponentController.getDynamicAfter: recordTypeName: ' + recordTypeName + '  recordTypeDevName:' + recordTypeDevName);

        Integer dynamicAfter = 0;
        Case_Creation_Setting__mdt[] caseCreationSettingList = [
            SELECT Dynamic_Section_After__c
            FROM Case_Creation_Setting__mdt
            WHERE Default_Record_Type__c = :recordTypeName
        ];
        for (Case_Creation_Setting__mdt caseCreationSettingRecord : caseCreationSettingList) {
            if (caseCreationSettingRecord.Dynamic_Section_After__c != null) {
                dynamicAfter = caseCreationSettingRecord.Dynamic_Section_After__c.intValue();
            }
        }
        return dynamicAfter;
    }

    @AuraEnabled
    public static List<SectionLayoutWrapper> getStaticFields(String parentRecordId, String recordTypeDevName, String recordTypeId) {
        String recordTypeName = '';
        Map<String, String> recTypeDevNameMap = getRecTypeDevName('Case');

		if (String.isBlank(recordTypeDevName) && String.isBlank(recordTypeId)) {
			List<Schema.RecordTypeInfo> infos = Schema.SObjectType.Case.RecordTypeInfos;

			for (Schema.RecordTypeInfo info : infos) {
				if (info.DefaultRecordTypeMapping) {
					recordTypeId = info.RecordTypeId;
				}
			}
		}

        if (String.isNotBlank(recordTypeDevName)) {
            recordTypeName = recTypeDevNameMap.get(recordTypeDevName);
            recordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
        }
        else if (String.isNotBlank(recordTypeId)) {
            recordTypeName = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosById().get(recordTypeId).getName();
            recordTypeDevName = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get(recordTypeName).getDeveloperName();
        }

		System.debug(LoggingLevel.INFO, 'FieldSetComponentController.getStaticFields: recordTypeName: ' + recordTypeName + '  recordTypeDevName:' + recordTypeDevName);

        Id userId = UserInfo.getUserId();
        Id accountId;
        Id contactId;
        if (userId != null) {
            List<Contact> cntcts = [SELECT Id, AccountId FROM Contact WHERE User_Id__c = :userId];
            for(Contact cntct : cntcts) {
                idActiveAccount = cntct.AccountId;
                contactId = cntct.Id;
                accountId = cntct.AccountId;
            }
        }

        // Get fields by fieldset
        Map<String,List<FieldSetMember2>> fsetFieldMap = new Map<String,List<FieldSetMember2>>();
        Map<String, Schema.FieldSet> fsMap = SObjectType.Case.fieldSets.getMap();
        for (String key : fsMap.keySet()) {
            Schema.FieldSet fs = fsMap.get(key);
            List<Schema.FieldSetMember> fieldSet = fs.getFields();
            List<FieldSetMember2> fset = new List<FieldSetMember2>();
            for (Schema.FieldSetMember f: fieldSet) {
                fset.add(new FieldSetMember2(f,'Case', recordTypeDevName));
            }
            fsetFieldMap.put(fs.getLabel(),fset);
        }

        // post-process order of layouts, and possible removal of fields based on recordTypes
        String dynamicFields = '';
        String otherDependentPicklists = '';
        String defaultRecordType = '';
        Case_Creation_Setting__mdt[] caseCreationSettingList = [
            SELECT Other_Dependent_Picklists__c, Dynamic_Fields__c, Default_Record_Type__c
            FROM Case_Creation_Setting__mdt
            WHERE Default_Record_Type__c = :recordTypeName
        ];
        for (Case_Creation_Setting__mdt caseCreationSettingRecord : caseCreationSettingList) {
            dynamicFields = caseCreationSettingRecord.Dynamic_Fields__c;
            otherDependentPicklists = caseCreationSettingRecord.Other_Dependent_Picklists__c;
            defaultRecordType = caseCreationSettingRecord.Default_Record_Type__c;
        }

        List<SectionLayoutWrapper> orderedFieldSetList = new List<SectionLayoutWrapper>();
        Case_Creation_Section__mdt[] caseCreationSectionList = [
            SELECT DeveloperName, MasterLabel, Section_Order__c
            FROM Case_Creation_Section__mdt
            WHERE RecordType_Name__c = :recordTypeName
            ORDER BY Section_Order__c
        ];
        for (Case_Creation_Section__mdt caseCreationSectionRecord : caseCreationSectionList) {
            SectionLayoutWrapper sectionLayoutWrapper = new SectionLayoutWrapper();
            sectionLayoutWrapper.sectionName = caseCreationSectionRecord.MasterLabel;
            sectionLayoutWrapper.fieldList = fsetFieldMap.get(caseCreationSectionRecord.MasterLabel);

            for (FieldSetMember2 fieldSetMember : sectionLayoutWrapper.fieldList) {
                if (fieldSetMember.label.contains('Record Type')) {
                    if (defaultRecordType != null && defaultRecordType.trim() != '') {
                        fieldSetMember.value = Schema.SObjectType.Case.getRecordTypeInfosByName().get(defaultRecordType).getRecordTypeId();
                    }
                    fieldSetMember.disabled = true;
                }

                if (fieldSetMember.label.equals('Status')) {
                    fieldSetMember.value = 'New';
                    fieldSetMember.disabled = true;
                }

                if (fieldSetMember.label.equals('Branch')) {
                    fieldSetMember.filter = 'RecordType.Name=\'BBSI Branch\'';
                    if (accountId != null) {
                        fieldSetMember.value = accountId;
                    }
                }

                if (fieldSetMember.label.startsWith('Contact')) {
                    if (contactId != null) {
                        fieldSetMember.value = contactId;
                    }
                }
            }

            if (dynamicFields != null && dynamicFields != '') {
                String[] dynamicFieldArray = dynamicFields.split(',');
                for (FieldSetMember2 fieldSetMember : sectionLayoutWrapper.fieldList) {
                    for (String fieldLabel : dynamicFieldArray) {
                        if (fieldSetMember.label.equals(fieldLabel)) {
                            fieldSetMember.dynamic = true;
                        }
                    }
                }
            }

            if (otherDependentPicklists != null && otherDependentPicklists != '') {
                String[] otherDependentPicklistsArray = otherDependentPicklists.split(',');
                for (FieldSetMember2 fieldSetMember : sectionLayoutWrapper.fieldList) {
                    for (String fieldLabel : otherDependentPicklistsArray) {
                        if (fieldSetMember.label.equals(fieldLabel)) {
                            fieldSetMember.otherDependent = true;
                        }
                    }
                }
            }
            orderedFieldSetList.add(sectionLayoutWrapper);
        }
        return orderedFieldSetList;
    }

    @AuraEnabled
    public static List<SectionLayoutWrapper> getDynamicFields(String typeName, List<String> dynamicValues) {
        List<SectionLayoutWrapper> orderedFieldSetList = new List<SectionLayoutWrapper>();

        if (dynamicValues == null && dynamicValues.isEmpty()) {
            // No values set, yet
            return orderedFieldSetList;
        }

        // Gather all of the labels of dynamic fields from the static sections
        String dynamicFields = '';
        Case_Creation_Setting__mdt[] caseCreationSettingList = [SELECT Dynamic_Fields__c FROM Case_Creation_Setting__mdt];
        for (Case_Creation_Setting__mdt caseCreationSettingRecord : caseCreationSettingList) {
            dynamicFields = caseCreationSettingRecord.Dynamic_Fields__c;
        }

        List<String> dynamicFieldList = new List<String>();
        if (dynamicFields != null && dynamicFields != '') {
            String[] temp = dynamicFields.split(',');
            for (String fieldLabel : temp) {
                dynamicFieldList.add(fieldLabel);
            }
        }

            // Make an ordered map of the dynamic fields from their list above to
            // construct the WHERE clause to retrieve Dynamic Fieldset dynamically
            Map<Integer,String> orderedMapOfFields = new Map<Integer,String>();
            Integer idx = 0;
            for(String dynamicField : dynamicFieldList) {
                orderedMapOfFields.put(idx,dynamicField);
                idx = idx + 1;
            }

        String caseCategory = '';
        if (orderedMapOfFields.containsKey(0)) {
            caseCategory = dynamicValues[0];
        }

        String caseType = '';
        if (orderedMapOfFields.containsKey(1)) {
            caseType = dynamicValues[1];
        }

        String caseSubType = '';
        if (orderedMapOfFields.containsKey(2)) {
            caseSubType = dynamicValues[2];
        }

        Case_Creation_Dynamic_Section__mdt[] caseCreationDynamicSectionList;
        if (caseCategory != null && caseCategory.trim() != '') {
            if (caseType != null && caseType.trim() != '') {
                if (caseSubType != null && caseSubType.trim() != '') {
                    caseCreationDynamicSectionList = [SELECT DeveloperName, MasterLabel FROM Case_Creation_Dynamic_Section__mdt WHERE Category__c = :caseCategory AND Type__c = :caseType AND Sub_Type__c = :caseSubType];
                }
                else {
                    caseCreationDynamicSectionList = [SELECT DeveloperName, MasterLabel FROM Case_Creation_Dynamic_Section__mdt WHERE Category__c = :caseCategory AND Type__c = :caseType AND Sub_Type__c = NULL];
                }
            }
            else {
                caseCreationDynamicSectionList = [SELECT DeveloperName, MasterLabel FROM Case_Creation_Dynamic_Section__mdt WHERE Category__c = :caseCategory AND Type__c = NULL AND Sub_Type__c = NULL];
            }
        }

        if (caseCreationDynamicSectionList == null) {
            // if no dynamic sections found for category/type/subtype combination; return blank data
            return orderedFieldSetList;
        }

        if (caseCreationDynamicSectionList.size() != 1) {
            // Error condition: too many or too few fieldSets returned for search criteria; return blank data
            return orderedFieldSetList;
        }

        Case_Creation_Dynamic_Section__mdt caseCreationDynamicSectionRecord = caseCreationDynamicSectionList.get(0);

        // Get fields by all fieldsets (static or dynamic)
        Map<String, List<FieldSetMember2>> fsetFieldMap = new Map<String, List<FieldSetMember2>>();
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(typeName);
        Schema.DescribeSObjectResult describe = targetType.getDescribe();
        Map<String, Schema.FieldSet> fsMap = describe.fieldSets.getMap();

        String key = caseCreationDynamicSectionRecord.DeveloperName.toLowerCase();
        if (fsMap.containsKey(key)) {
            Schema.FieldSet fs = fsMap.get(key);
            List<Schema.FieldSetMember> fieldSet = fs.getFields();
            List<FieldSetMember2> fset = new List<FieldSetMember2>();
            for (Schema.FieldSetMember f: fieldSet) {
                fset.add(new FieldSetMember2(f, typeName, key));
            }
            fsetFieldMap.put(fs.getLabel(),fset);
       }

        SectionLayoutWrapper sectionLayoutWrapper = new SectionLayoutWrapper();
        sectionLayoutWrapper.sectionName = caseCreationDynamicSectionRecord.MasterLabel;
        sectionLayoutWrapper.fieldList = fsetFieldMap.get(caseCreationDynamicSectionRecord.MasterLabel);
        for (FieldSetMember2 fieldSetMember : sectionLayoutWrapper.fieldList) {
            for (String fieldLabel : dynamicFieldList) {
                if (fieldSetMember.label.equals(fieldLabel)) {
                    fieldSetMember.dynamic = true;
                }
            }
        }
        orderedFieldSetList.add(sectionLayoutWrapper);

        return orderedFieldSetList;
    }

    @AuraEnabled
    public static Id doUpsertObjects(Map<String, Object> caseValues, Map<String, Object> formValues, String fileHolderId, String accountId, String formRecordType){
        try {
            Case newCase = new Case();

            if (Test.isRunningTest()) {
                newCase.Skip_Automation__c = true;
            }

            if (String.isNotBlank(accountId)) {
                newCase.AccountId = Id.valueOf(accountId);
            }

            Map<String, String> caseFields = CaseCreationUtility.getFieldToAPIName('Case');

            for (String key : caseValues.keySet()) {
                if (caseFields.containsKey(key)) {
                    String fieldApiName = caseFields.get(key);

                    if (key == 'System Access Permissions') {
                        List<String> pickListValues = new List<String> ();
                        for (Object obj : (List<Object>)caseValues.get(key)) {
                            pickListValues.add(obj.toString());
                        }
                        if (!pickListValues.isEmpty()) {
                            String value = String.join(pickListValues, ';');
                            newCase.put(fieldApiName, value);
                        }
                        continue;
                    }

                    try {
                        newCase.put(fieldApiName, caseValues.get(key).toString());
                    }
                    catch (Exception e) {
                        try {
                            // Handle checkbox fields
                            newCase.put(fieldApiName, Boolean.valueOf(caseValues.get(key).toString()));
                        }
                        catch (Exception e1) {
                            // Handle date fields
                            newCase.put(fieldApiName, Date.valueOf(caseValues.get(key).toString()));
                        }
                    }
                }
                else {
                    System.debug(LoggingLevel.INFO, 'CASE does not contain the label "' + key + '"');
                }
            }

            insert newCase;

            if (formRecordType != null && formRecordType != '') {
                Id formRecordTypeId = Schema.SObjectType.Form__c.getRecordTypeInfosByName().get(formRecordType).getRecordTypeId();

                Form__c newForm = new Form__c();
                newForm.Name = formRecordType;
                newForm.recordTypeId = formRecordTypeId;
                newForm.Case__c = newCase.Id;

                for (String key : formValues.keySet()) {
                    String fieldApiName = CaseCreationUtility.getFieldAPIName('Form__c',key);
                    if (fieldApiName != null && fieldApiName != '') {
                        if (key == 'System Access Permissions') {
                            List<String> pickListValues = new List<String> ();
                            for (Object obj : (List<Object>)formValues.get(key)) {
                                pickListValues.add(obj.toString());
                            }
                            if (!pickListValues.isEmpty()) {
                                String value = String.join(pickListValues, ';');
                                newForm.put(fieldApiName, value);
                            }
                        }
                        else {
                            // FUTURE: Expand to all DisplayTypes
                            Schema.DisplayType dtype = CaseCreationUtility.getFieldType('Form__c',key);
                            String strValue = formValues.get(key).toString();

                            switch on dtype {
                                when DATE {
                                    newForm.put(fieldApiName, Date.valueOf(strValue));
                                }
                                when DOUBLE {
                                    newForm.put(fieldApiName, Double.valueOf(strValue));
                                }
                                when CURRENCY {

                                    newForm.put(fieldApiName, Decimal.valueOf(strValue));
                                }
                                when else {
                                    newForm.put(fieldApiName, strValue);
                                }
                            }
                        }
                    }
                }

                insert newForm;
            }

            if (!String.isBlank(fileHolderId)) {
                FileHolder_Service.addLinksToObject(Id.valueOf(fileHolderId), newCase.Id);
                Database.delete(fileHolderId);
            }

            return newCase.Id;
        }
        catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'e.getMessage = ' + e.getMessage());
            System.debug(LoggingLevel.ERROR, 'e.getStackTraceString = ' + e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
    }

    // Wrapper class for wrapping section name and fields within
    // that section's fieldset in one collection
    public class SectionLayoutWrapper{

        @AuraEnabled
        public String sectionName  { get; set; }

        @AuraEnabled
        public List<FieldSetMember2> fieldList { get; set; }

    }

    /**
     * createFileHolder create a Case File_Holder__c object.  The uploade files
     * will be linked to this object and when the Case is created, they are
     * moved onto the Case.
     * @return   The Id of the File_Holder__c
     */
    @AuraEnabled
    public static String createFileHolder() {
        File_Holder__c fh = new File_Holder__c();
        insert fh;
        return fh.Id;
    }

    /**
     * uploadedFiles get related ContentDocuments for the given recordId.
     * NOTE: ContentDocumentLink requires a filter by a single Id on ContentDocumentId
     * or LinkedEntityId using the equals operator or multiple Id's using the IN
     * operator.
     * @recordId  Identifier the File_Holder__c documents are related to
     * @return A List of ContentDocuments related to the given recordId
	 **/
    @AuraEnabled
    public static List<ContentDocument> uploadedFiles(String recordId) {
        Set<Id> documentIds = new Set<Id>();

		List<ContentDocumentLink> cdLinks = [
            SELECT Id, ContentDocumentId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :recordId
        ];

        for (ContentDocumentLink cdLink : cdLinks) {
            documentIds.add(cdLink.ContentDocumentId);
        }

        List<ContentDocument> cds = [
            SELECT Id, Title, FileType
            FROM ContentDocument
            WHERE Id IN :documentIds
        ];

        return cds;
    }

    /**
     * deleteFile deletes the given file and return the current uploaded list
     * @documentId  Identifier the ContentDocuments to delete
     * @recordId  Identifier the File_Holder__c documents are related to
     * @return A List of ContentDocuments related to the given recordId
	 **/
    @AuraEnabled
    public static List<ContentDocument> deleteFile(String documentId, String recordId) {
	    Database.delete(Id.valueOf(documentId));
        return uploadedFiles(recordId);
    }

}