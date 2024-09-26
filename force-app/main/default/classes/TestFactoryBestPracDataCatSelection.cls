@isTest
public class TestFactoryBestPracDataCatSelection {
 /**
	 * @description createPracticecatsel creates a new Best Practice DataCategorySelection record in the database.
     * @param  parentId                 ParentId of the Best Practice DataCategorySelection
     * @param  dataCategoryGroupName    DataCategoryGroupName of the Best Practice DataCategorySelection
     * @param  dataCategoryName         DataCategoryName of the Best Practice DataCategorySelection
	 * @param  fldMap 		            additional field values for the Best Practice DataCategorySelection
	 * @return Best_Practice__DataCategorySelection
	 */
 public static Best_Practice__DataCategorySelection createPracticecatsel(String parentId, String dataCategoryGroupName, String dataCategoryName,  Map<String, Object> fldMap) {
        Best_Practice__DataCategorySelection datacategory = makePracticecatsel(parentId, dataCategoryGroupName, dataCategoryName, fldMap);
        insert datacategory;
        return datacategory;
    }
    /**
	 * @description makePracticecatsel makes a new Best_Practice DataCategorySelection record in the database.
	 * @param  parentId                 ParentId of the Best Practice DataCategorySelection
     * @param  dataCategoryGroupName    DataCategoryGroupName of the Best Practice DataCategorySelection
     * @param  dataCategoryName         DataCategoryName of the Best Practice DataCategorySelection
	 * @param  fldMap 		            additional field values for the Best Practice DataCategorySelection
     * @param  fldMap 		            additional field values for the Best Practice DataCategorySelection
	 * @return Best_Practice__DataCategorySelection
	 */
	 public static Best_Practice__DataCategorySelection makePracticecatsel(String parentId, String dataCategoryGroupName, String dataCategoryName, Map<String, Object> fldMap) {        
        Best_Practice__DataCategorySelection datacategory = new Best_Practice__DataCategorySelection(ParentId = parentId, DataCategoryGroupName = dataCategoryGroupName, DataCategoryName = dataCategoryName);
        if (fldMap != null) {
            datacategory = (Best_Practice__DataCategorySelection) TestFactory.assignFields(fldMap, datacategory);
        }
        return datacategory;
    }

 
}