/**
 * FileHolder_Service_Test runs tests against the
 * FileHolder_Service object.
 */
 @IsTest
 public without sharing class FileHolder_Service_Test {

    @TestSetup
    static void makeData() {
        List<File_Holder__c> holders = new List<File_Holder__c>();

        File_Holder__c holderNew1 = TestFactoryFileHolder.makeFileHolder(null);
        File_Holder__c holderNew2 = TestFactoryFileHolder.makeFileHolder(null);
        File_Holder__c holderNew3 = TestFactoryFileHolder.makeFileHolder(null);

        insert new List<File_Holder__c>{ holderNew1, holderNew2, holderNew3 };
        
        ContentVersion version1 = TestFactoryContentVersion.makeContentVersion( new Map<String, Object>{
            'Title' => 'Title 1',
            'ContentLocation' => 'S',
            'PathOnClient' => 'Test1.jpg',
            'VersionData' => Blob.valueOf('Test Content Data'),
            'IsMajorVersion' => true
        });
        ContentVersion version2 = TestFactoryContentVersion.makeContentVersion( new Map<String, Object>{
            'Title' => 'Title 2',
            'ContentLocation' => 'S',
            'PathOnClient' => 'Test2.jpg',
            'VersionData' => Blob.valueOf('Test Content Data'),
            'IsMajorVersion' => true
        });
        ContentVersion version3 = TestFactoryContentVersion.makeContentVersion( new Map<String, Object>{
            'Title' => 'Title 3',
            'ContentLocation' => 'S',
            'PathOnClient' => 'Test3.jpg',
            'VersionData' => Blob.valueOf('Test Content Data'),
            'IsMajorVersion' => true
        });
        ContentVersion version4 = TestFactoryContentVersion.makeContentVersion( new Map<String, Object>{
            'Title' => 'Title 4',
            'ContentLocation' => 'S',
            'PathOnClient' => 'Test4.jpg',
            'VersionData' => Blob.valueOf('Test Content Data'),
            'IsMajorVersion' => true
        });

        List<ContentVersion> versions = new List<ContentVersion>{ version1, version2, version3, version4 };
        insert versions;

        List<Id> versionIds = new List<Id>();
        for (ContentVersion v : versions) {
            versionIds.add(v.Id);
        }
        Assert.areEqual(4, versionIds.size());

        List<Id> documentIds = new List<Id>();
        for (ContentVersion v : [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id IN :versionIds]) {
            documentIds.add(v.ContentDocumentId);
        }

        List<ContentDocument> documents = [SELECT Id, Title FROM ContentDocument WHERE Id IN :documentIds];
        Assert.areEqual(4, documents.size());

        List<ContentDocumentLink> ls = [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId = :documents[0].Id];
        Assert.areEqual(1, ls.size());

        List<ContentDocumentLink> links = new List<ContentDocumentLink>();

        ContentDocument document;
        document = [SELECT Id, Title FROM ContentDocument WHERE Title = 'Title 1' LIMIT 1];
        links.add( TestFactoryContentDocumentLink.makeContentDocumentLink(new Map<String, Object>{
            'ContentDocumentId' => document.Id,
            'LinkedEntityId' => holderNew1.Id,
            'ShareType' => 'I',
            'Visibility' => 'AllUsers'
        }));

        document = [SELECT Id, Title FROM ContentDocument WHERE Title = 'Title 2' LIMIT 1];
        links.add( TestFactoryContentDocumentLink.makeContentDocumentLink(new Map<String, Object>{
            'ContentDocumentId' => document.Id,
            'LinkedEntityId' => holderNew2.Id,
            'ShareType' => 'I',
            'Visibility' => 'AllUsers'
        }));
        insert links;
    }

    @IsTest
    public static void test_AddLinksToObject() {
        List<ContentDocumentLink> links;
        Account testAccount = TestFactoryAccount.createBranch('FH Account - Test', '99999', null, null);
        User testUser = TestFactoryUser.makeUser(null, 'FH_LastName', 'BBSI Standard', '910', 'fh@mybbsi.zzz', 'fh@mybbsi.zzz');//
        Contact testContact = TestFactoryContact.createEmployee(testUser.Id, null, 'FH_LastName', testAccount.Id);
        Case testCase = TestFactoryCase.createCase('Test Case', null, testContact.Id, testAccount.Id, null, 'Client/Referral Partner', 
            new Map<String, Object> {
                'Type' => 'Software Request',
                'Type__c' => 'Other'
            });

        ContentDocument document = [
            SELECT Id, Title
            FROM ContentDocument
            WHERE Title = 'Title 1'
            LIMIT 1
        ];
        links = [
            SELECT Id, ContentDocumentId, LinkedEntityId 
            FROM ContentDocumentLink 
            WHERE ContentDocumentId = :document.Id
        ];
        Assert.areEqual(2, links.size(), 'Should start with two links (File Holder and User)');

        Id holderId;
        for (ContentDocumentLink l : links) {
            if (Schema.File_Holder__c.SObjectType == l.LinkedEntityId.getSobjectType()) {
                holderId = l.LinkedEntityId;
                break;
            }
        }

        FileHolder_Service.addLinksToObject(holderId, testCase.Id);

        Boolean found = false;
        links = [
            SELECT Id, ContentDocumentId, LinkedEntityId 
            FROM ContentDocumentLink 
            WHERE ContentDocumentId = :document.Id
        ];
        for (ContentDocumentLink l : links) {
            if (Schema.Case.SObjectType == l.LinkedEntityId.getSobjectType()) {
                found = true;
                break;
            }
        }
        
        Assert.areEqual(true, found, 'Link should have been connected to the Case');
    }
    
    @IsTest
    public static void test_deleteAll() {
        List<ContentDocument> documents = [SELECT Id, Title FROM ContentDocument];
        Assert.areEqual(4, documents.size(), 'Start with 4 Documents');
        List<File_Holder__c> fhs = [SELECT Id FROM File_Holder__c];
        Assert.areEqual(3, fhs.size(), 'Start with 3 File_Holder__cs');

        FileHolder_Service.deleteAll();

        documents = [SELECT Id, Title FROM ContentDocument];
        Assert.areEqual(2, documents.size(), 'End with 2 Documents');
        fhs = [SELECT Id FROM File_Holder__c];
        Assert.areEqual(0, fhs.size(), 'End with 0 File_Holder__cs');
    }
}