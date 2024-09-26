/*
 #####################################################
 # Created By....................: Deval Shah
 # Created Date................: 16 Apr, 2019
 # Last Modified By..........: Deval Shah
 # Last Modified Date......: 16 Apr, 2019
 # Description...................: This class methods will be used by KnowledgeArticleController Apex Class.
 # Test Class...................: KnowledgeArticleControllerTest
 #####################################################
*/
public without sharing class KnowledgeArticleControllerHelper {
    /**
     * @author : Deval Shah
     * @date : 21 Apr, 2019
     * @description : This method get all ContentVersion records.
    */
    public static Map<Id, List<ContentVersion>> getConVersions(List<Best_Practice__kav> bpKAObjList) {
        // KnowledgeArticleVersionId KnowledgeArticleId  Map
        Map<Id, Id> kaVerIdKAIdMap = new Map<Id, Id> ();
        
        // iterate bpKAObjList
        for(Best_Practice__kav bpKAObj : bpKAObjList) {
            kaVerIdKAIdMap.put(bpKAObj.Id, bpKAObj.KnowledgeArticleId);
        }
        
        // query all KnowledgeArticleVersion records
        List<KnowledgeArticleVersion> kaVerObjList = [SELECT 
                                                      Id, KnowledgeArticleId
                                                      FROM KnowledgeArticleVersion
                                                      WHERE PublishStatus='Archived' AND IsLatestVersion=false AND KnowledgeArticleId IN :kaVerIdKAIdMap.values()
                                                      ORDER BY VersionNumber DESC];
        
        // iterate kaVerObjList
        for(KnowledgeArticleVersion kaVerObj : kaVerObjList) {
            kaVerIdKAIdMap.put(kaVerObj.Id, kaVerObj.KnowledgeArticleId);
        }
        
        // KnowledgeArticleVersionId List
        List<Id> kaVerIdList = new List<Id> (kaVerIdKAIdMap.keySet());
        
        // query ContentDocumentLink records
        List<ContentDocumentLink> conDLObjList = [SELECT 
                                                  ContentDocumentId, ShareType, SystemModstamp, Visibility 
                                                  FROM ContentDocumentLink 
                                                  WHERE LinkedEntityId IN :kaVerIdList]; 
        
        Set<Id> conDLIdObjSet = new Set<Id> ();
        // iterate conDLObjList
        for(ContentDocumentLink conDLObj : conDLObjList)
            conDLIdObjSet.add(conDLObj.ContentDocumentId); 
            
        // query all ContentVersion records
        List<ContentVersion> cvObjList = [SELECT 
                                          Id, ContentDocumentId, Title, Description, FirstPublishLocationId, FileType
                                          FROM ContentVersion
                                          WHERE IsDeleted = false AND ContentDocumentId in :conDLIdObjSet
                                          //WHERE IsDeleted = false AND FirstPublishLocationId IN :kaVerIdKAIdMap.keySet()
                                          ORDER BY LastModifiedDate DESC];
        
        Map<Id, List<ContentVersion>> articleCVMap = new Map<Id, List<ContentVersion>> ();
        // iterate cvObjList
        for(ContentVersion cvObj : cvObjList) {
            Id kaId = kaVerIdKAIdMap.get(cvObj.FirstPublishLocationId);
            if(!articleCVMap.containsKey(kaId)) {
                articleCVMap.put(kaId, new List<ContentVersion> {cvObj});
            }
            else {
                articleCVMap.get(kaId).add(cvObj);
            }
        }
        return articleCVMap;
    }
    
    /**
     * @author : Deval Shah
     * @date : 16 Apr, 2019
     * @description : This method get all DataCategorySelections.
    */
    public static Map<Id, List<Best_Practice__DataCategorySelection>> getDataCatSel(List<Best_Practice__kav> bpKAObjList) {
        Map<Id, List<Best_Practice__DataCategorySelection>> bpDataCatSelMap = new Map<Id, List<Best_Practice__DataCategorySelection>> ();
        
        List<Best_Practice__DataCategorySelection> dataCatSelObjList = [SELECT 
                             Id, ParentId, DataCategoryGroupName, DataCategoryName
                             FROM Best_Practice__DataCategorySelection 
                             WHERE IsDeleted = false AND ParentId IN :bpKAObjList];
        
        for(Best_Practice__DataCategorySelection dataCatSelObj : dataCatSelObjList) {
            if(!bpDataCatSelMap.containsKey(dataCatSelObj.ParentId))
                bpDataCatSelMap.put(dataCatSelObj.ParentId, new List<Best_Practice__DataCategorySelection> {dataCatSelObj});
            else
                bpDataCatSelMap.get(dataCatSelObj.ParentId).add(dataCatSelObj);
        }
        return bpDataCatSelMap;
    }
}