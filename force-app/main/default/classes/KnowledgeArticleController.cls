/*
 #####################################################
 # Created By....................: Deval Shah
 # Created Date................: 04 Apr, 2019
 # Last Modified By..........: Deval Shah
 # Last Modified Date......: 08 Apr, 2019
 # Description...................: This class is used by KnowledgeArticle Lightning Component.
 # Test Class...................: KnowledgeArticleControllerTest
 #####################################################
*/
public with sharing class KnowledgeArticleController {
    /**
     * @author : Deval Shah
     * @date : 04 Apr, 2019
     * @description : This method is called by KnowledgeArticle Lightning Component to fetch all Knowledge Articles.
    */
    @AuraEnabled
    public static KAWrapper getArticles() {
        // query all Best_Practice__kav records
        List<Best_Practice__kav> bpKAObjList = [SELECT 
                                                Id, KnowledgeArticleId, ArticleNumber, Title, Summary, VersionNumber, 
                                                Language, UrlName, PublishStatus, 
                                                CreatedDate, FirstPublishedDate, LastPublishedDate,
                                                Article_Body__c, Business_Case__c, Impacted_Roles__c, 
                                                Last_Reviewed_On__c, Review_By_Date__c, System_Version__c, 
                                                Type__c, Body__c, Access_Required__c
                                                //(SELECT Id, ParentId, DataCategoryGroupName, DataCategoryName, CreatedDate, CreatedById, IsDeleted, SystemModstamp FROM DataCategorySelections WHERE IsDeleted = false)
                                                FROM Best_Practice__kav
                                                ORDER BY LastPublishedDate DESC];
        
        // get all Best_Practice__DataCategorySelection
        Map<Id, List<Best_Practice__DataCategorySelection>> bpDataCatSelMap = KnowledgeArticleControllerHelper.getDataCatSel(bpKAObjList);
        
        // get all ContentVersion
        Map<Id, List<ContentVersion>> articleCVMap = KnowledgeArticleControllerHelper.getConVersions(bpKAObjList);
        
        // get all Data Categories as per current user permission
        List<Map<String, List<String>>> dataCatList = KnowledgeArticleController.getDataCategories();
        KAWrapper kaWrapObj = new KAWrapper(bpKAObjList, bpDataCatSelMap, articleCVMap, dataCatList[0], dataCatList[1]);
        return kaWrapObj;
    }  
    
    /**
     * @author : Deval Shah
     * @date : 16 Apr, 2019
     * @description : This method get all Data Categories as per current user permission.
    */
    public static List<Map<String, List<String>>> getDataCategories() {
        // get the list of category groups
        List<DescribeDataCategoryGroupResult> desDataCatResObjList = Schema.describeDataCategoryGroups(new List<String> {'KnowledgeArticleVersion'});
        
        // get the list of category pairs
        List<DataCategoryGroupSobjectTypePair> dataCatGrpPairObjList = new List<DataCategoryGroupSobjectTypePair>();
        
        for(DescribeDataCategoryGroupResult desDataCatResObj : desDataCatResObjList){
            DataCategoryGroupSobjectTypePair dataCatGrpPairObj = new DataCategoryGroupSobjectTypePair();
            dataCatGrpPairObj.setSobject(desDataCatResObj.getSobject());
            dataCatGrpPairObj.setDataCategoryGroupName(desDataCatResObj.getName());
            dataCatGrpPairObjList.add(dataCatGrpPairObj);
        }
        
        // get the list of category structure
        List<DescribeDataCategoryGroupStructureResult> desDataCatGrpStrResObjList = Schema.describeDataCategoryGroupStructures(dataCatGrpPairObjList, false);
        
        Map<String, List<String>> dataCatLabelMap = new Map<String, List<String>> ();
        Map<String, List<String>> dataCatValueMap = new Map<String, List<String>> ();
        
        // get data from the result
        for(DescribeDataCategoryGroupStructureResult desDataCatGrpStrResObj : desDataCatGrpStrResObjList){
            String dataCatGroupLabel = desDataCatGrpStrResObj.getLabel();
            List<String> dataCatLabelList = new List<String> ();
            List<String> dataCatValueList = new List<String> ();
            
            // get the top level1 categories
            for(DataCategory dataCatLevel1Obj : desDataCatGrpStrResObj.getTopCategories()) {
                String dataCatLevel1Label = dataCatLevel1Obj.getLabel();
                dataCatLabelList.add(dataCatLevel1Label);
                dataCatValueList.add(dataCatLevel1Obj.getLabel() + '>' + dataCatLevel1Obj.getName());
                // get the child level2 categories
                for(DataCategory dataCatLevel2Obj : dataCatLevel1Obj.getChildCategories()) {
                    String dataCatLevel2Label = dataCatLevel1Label + ' > ' + dataCatLevel2Obj.getLabel();
                    dataCatLabelList.add(dataCatLevel2Label);
                    dataCatValueList.add(dataCatLevel2Obj.getLabel() + '>' + dataCatLevel2Obj.getName());
                    // get the child level3 categories
                    for(DataCategory dataCatLevel3Obj : dataCatLevel2Obj.getChildCategories()) {
                        String dataCatLevel3Label = dataCatLevel2Label + ' > ' + dataCatLevel3Obj.getLabel();
                        dataCatLabelList.add(dataCatLevel3Label);
                        dataCatValueList.add(dataCatLevel3Obj.getLabel() + '>' + dataCatLevel3Obj.getName());
                        // get the child level4 categories
                        for(DataCategory dataCatLevel4Obj : dataCatLevel3Obj.getChildCategories()) {
                            String dataCatLevel4Label = dataCatLevel3Label + ' > ' + dataCatLevel4Obj.getLabel();
                            dataCatLabelList.add(dataCatLevel4Label);
                            dataCatValueList.add(dataCatLevel4Obj.getLabel() + '>' + dataCatLevel4Obj.getName());
                            // get the child level5 categories
                            for(DataCategory dataCatLevel5Obj : dataCatLevel4Obj.getChildCategories()) {
                                String dataCatLevel5Label = dataCatLevel4Label + ' > ' + dataCatLevel5Obj.getLabel();
                                dataCatLabelList.add(dataCatLevel5Label);
                                dataCatValueList.add(dataCatLevel5Obj.getLabel() + '>' + dataCatLevel5Obj.getName());
                            }
                        }
                    }
                }
            }
            dataCatLabelMap.put(dataCatGroupLabel, dataCatLabelList);
            dataCatValueMap.put(dataCatGroupLabel, dataCatValueList);
        }
        
        List<Map<String, List<String>>> dataCatList = new List<Map<String, List<String>>> {dataCatLabelMap, dataCatValueMap};
        return dataCatList;
    }
    
    public class KAWrapper {
        @AuraEnabled
        public List<Best_Practice__kav> bpKAObjList;
        
        @AuraEnabled
        public Map<Id, List<Best_Practice__DataCategorySelection>> bpDataCatSelMap;
        
        @AuraEnabled
        public Map<Id, List<ContentVersion>> articleCVMap;
        
        @AuraEnabled
        public Map<String, List<String>> dataCatLabelMap;
        
        @AuraEnabled
        public Map<String, List<String>> dataCatValueMap;
        
        public KAWrapper(List<Best_Practice__kav> bpKAObjList, Map<Id, List<Best_Practice__DataCategorySelection>> bpDataCatSelMap, Map<Id, List<ContentVersion>> articleCVMap, Map<String, List<String>> dataCatLabelMap, Map<String, List<String>> dataCatValueMap) {
            this.bpKAObjList = bpKAObjList;
            this.bpDataCatSelMap = bpDataCatSelMap;
            this.articleCVMap = articleCVMap;
            this.dataCatLabelMap = dataCatLabelMap;
            this.dataCatValueMap = dataCatValueMap;
        }
    }
}