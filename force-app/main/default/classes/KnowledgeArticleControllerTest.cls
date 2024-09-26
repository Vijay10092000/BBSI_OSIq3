/*
#####################################################
# Created By....................: Deval Shah
# Created Date................: 16 Apr, 2019
# Last Modified By..........: Aman Gupta
# Last Modified Date......: 22 Apr, 2019
# Description...................: This is test class for test trigger/class.
# Test Class....................:
#####################################################
*/
@isTest
private class KnowledgeArticleControllerTest {
    /**
    * @author : Deval Shah
    * @date : 22 Apr, 2019
    * @description : This method create test data.
    */
    @testSetup
    private static void setup() {
        User userObj1 = TestFactoryUser.makeUser('testuser1','TestUser1111','System Administrator','910','testuser1111@test.com','Test.User1111@test.com');
        userObj1.UserPermissionsKnowledgeUser = true;
        insert userObj1;
        System.runAs(userObj1) {
            // create Best_Practice__kav records        
            Best_Practice__kav bpObj1 = TestFactoryBestPracticekav.makePracticeKav('TestKA1', 'TestKA1', 'TestURl1', null);        
            Best_Practice__kav bpObj2 = TestFactoryBestPracticekav.makePracticeKav('TestKA2', 'TestKA2', 'TestURl2', null);
            List<Best_Practice__kav> bpObjList = new List<Best_Practice__kav> {bpObj1, bpObj2};
            insert bpObjList;
            
            // query Best_Practice__kav records
            bpObjList = [SELECT Id, KnowledgeArticleId, ArticleNumber, Title, Summary, VersionNumber FROM Best_Practice__kav WHERE Id IN : bpObjList ORDER BY Title];
            
            // create ContentVersion records
            ContentVersion cvObj1 = TestFactoryContentVersion.makeContentVersion( new Map<String, Object>{
                'Title' => 'TestKA1',
                'Description' => 'TestKA1',
                'PathOnClient' => 'test1.png',
                'VersionData' =>  Blob.valueof('/services/data/v45.0/sobjects/ContentVersion'),
                'FirstPublishLocationId' => bpObjList[0].Id
                });
            ContentVersion cvObj2 = TestFactoryContentVersion.makeContentVersion( new Map<String, Object>{
                'Title' => 'TestKA2',
                'Description' => 'TestKA2',
                'PathOnClient' => 'test2.png',
                'VersionData' =>  Blob.valueof('/services/data/v45.0/sobjects/ContentVersion'),
                'FirstPublishLocationId' => bpObjList[0].Id
                });
            ContentVersion cvObj3 = TestFactoryContentVersion.makeContentVersion( new Map<String, Object>{
                'Title' => 'TestKA3',
                'Description' => 'TestKA3',
                'PathOnClient' => 'test3.png',
                'VersionData' =>  Blob.valueof('/services/data/v45.0/sobjects/ContentVersion'),
                'FirstPublishLocationId' => bpObjList[1].Id
                });
            ContentVersion cvObj4 = TestFactoryContentVersion.makeContentVersion( new Map<String, Object>{
                'Title' => 'TestKA4',
                'Description' => 'TestKA4',
                'PathOnClient' => 'test4.png',
                'VersionData' =>  Blob.valueof('/services/data/v45.0/sobjects/ContentVersion'),
                'FirstPublishLocationId' => bpObjList[1].Id
                });
            insert new List<ContentVersion> {cvObj1, cvObj2, cvObj3, cvObj4};
                
            // create Best_Practice__DataCategorySelection records        
            Best_Practice__DataCategorySelection dataCatSel1 = TestFactoryBestPracDataCatSelection.createPracticecatsel(bpObjList[0].Id, 'Location', 'All', null);
            Best_Practice__DataCategorySelection dataCatSel2 = TestFactoryBestPracDataCatSelection.createPracticecatsel(bpObjList[0].Id, 'Application', 'All', null);
            Best_Practice__DataCategorySelection dataCatSel3 = TestFactoryBestPracDataCatSelection.createPracticecatsel(bpObjList[1].Id, 'Location', 'All', null);
            Best_Practice__DataCategorySelection dataCatSel4 = TestFactoryBestPracDataCatSelection.createPracticecatsel(bpObjList[1].Id, 'Application', 'All', null);
            
            // publish Knowledge Article records
            for(Best_Practice__kav bpObj : bpObjList){
                String articleId = bpObj.KnowledgeArticleId;
                KbManagement.PublishingService.publishArticle(articleId, true);
            }
        }
    }
    
    /**
    * @author : Deval Shah
    * @date : 22 Apr, 2019
    * @description : This method is to test KnowledgeArticleController getArticles method.
    */
    @isTest static void testGetArticles() {        
        User userObj1 = [select Id from user where UserName = 'Test.User1111@test.com' limit 1];
        System.runAs(userObj1) {            
            // query all Best_Practice__kav records
            List<Best_Practice__kav> bpObjList = [SELECT Id, KnowledgeArticleId, ArticleNumber, Title, Summary, VersionNumber FROM Best_Practice__kav ORDER BY Title];
            Assert.areEqual(2, bpObjList.size());
            
            // query all ContentVersion records
            List<ContentVersion> cvObjList = [SELECT Id, Title, FirstPublishLocationId FROM ContentVersion WHERE FirstPublishLocationId IN :bpObjList];
            Assert.areEqual(4, cvObjList.size());
            
            // query all Best_Practice__DataCategorySelection records
            List<Best_Practice__DataCategorySelection> dataCatSelObjList = [SELECT Id, DataCategoryGroupName, DataCategoryName FROM Best_Practice__DataCategorySelection WHERE ParentId IN :bpObjList];
            Assert.areEqual(4, dataCatSelObjList.size());
            
            test.startTest();
            KnowledgeArticleController.getArticles();
            test.stopTest();
        }
    }
}