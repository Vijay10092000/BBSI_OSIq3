public with sharing class AddproductsFromopportunity {

    @AuraEnabled
    public static Map<String, Object> fetchProductData(String opportunityId) {
        Map<String, Object> resultMap = new Map<String, Object>();
        String priceBookId = '';
        String priceBookName = '';

        List<Opportunity> opps = [SELECT Pricebook2Id, Pricebook2.Name FROM Opportunity where Id=:opportunityId WITH SYSTEM_MODE];
        Opportunity opp = new Opportunity();
        if(!opps.isEmpty()){
            opp = opps[0];
        }
        if(String.isBlank(opp.Pricebook2Id)){
            Pricebook2 pb = [select Id, Name from Pricebook2 where IsActive = true and IsStandard = true WITH SYSTEM_MODE];
            priceBookId = pb.Id;
            priceBookName = pb.Name;
        }
        else{
            priceBookId = opp.Pricebook2Id;
            priceBookName = opp.Pricebook2.Name;
        }
        // Fetch active configurations
        List<LWC_DataTable_Config__mdt> configs = [SELECT Id, DeveloperName, Column_Name__c, Is_Sortable__c, Is_Searchable__c, Object_Api_Name__c, Column_Label__c, 
                                                    Column_Order__c, Priority_Column_Name__c, Related_List_API_Name__c, Type__c 
                                                    FROM LWC_DataTable_Config__mdt 
                                                    WHERE Is_Active__c = true AND Component_Name__c = 'AddproductsFromopportunity' WITH SYSTEM_MODE ORDER BY Column_Order__c];
                                                    
        // Initialize sets to store columns for different objects
        Set<String> productColumns = new Set<String>{'Id', 'Pricing_Type__c', 'Name'};
        Set<String> slabPriceColumns = new Set<String>{'Id', 'Min_Quantity__c', 'Max_Quantity__c', 'Unit_Price__c'};
        Set<String> priceBookEntryColumns = new Set<String>{'Id', 'UnitPrice'};
        
        // Populate sets with column names based on configuration
        for (LWC_DataTable_Config__mdt config : configs) {            
            if (config.Object_Api_Name__c == 'Product2') {
                productColumns.add(config.Column_Name__c);
            } else if (config.Object_Api_Name__c == 'Slab_Price__c') {
                slabPriceColumns.add(config.Column_Name__c);
            } else if (config.Object_Api_Name__c == 'PricebookEntry') {
                priceBookEntryColumns.add(config.Column_Name__c);
            }
        }
        
        // Construct SOQL query to fetch product data
        String productQuery = 'SELECT ';
        
        // Add product columns to the query
        for (String columnName : productColumns) {
            productQuery += columnName + ', ';
        }
        
        // Add related list columns to the query
        if (!slabPriceColumns.isEmpty()) {
            productQuery += '(SELECT ' + String.join(slabPriceColumns, ', ') + ' FROM Slab_Prices__r WHERE Is_Active__c = true order by Min_Quantity__c), ';
        }
        
        if (!priceBookEntryColumns.isEmpty()) {
            productQuery += '(SELECT ' + String.join(priceBookEntryColumns, ', ') + ' FROM PricebookEntries WHERE IsActive = true AND Pricebook2Id =: priceBookId) ';
        }
        
        productQuery += ' FROM Product2 WHERE IsActive = true WITH SYSTEM_MODE';
        
        // Execute the SOQL query
        List<Product2> products = Database.query(productQuery);
        system.debug(products);        
        
        // Add configs and products to result map
        resultMap.put('priceBookId', priceBookId);
        resultMap.put('priceBookName', priceBookName);
        resultMap.put('configs', configs);
        resultMap.put('products', products);
        resultMap.put('priceBookId', priceBookId);
        resultMap.put('priceAccess', getPriceModificationPermissionAssignments());
        resultMap.put('userPermissionSetNames', getUserPermissionSetNames());
        resultMap.put('userProfileName', getUserProfileName());
        resultMap.put('productFamilyPicklist', getPicklistValues('Product2','Family'));
        
        return resultMap;
    }

    /**
     * Method to fetch Opportunity Line Items and related Products for a given Opportunity Id.
     * @param opportunityId The Id of the Opportunity.
     * @return A map containing Opportunity Line Items and Products.
     */
    @AuraEnabled
    public static Map<String, Object> fetchOLIData(String opportunityId) {
        // Map to store the result
        Map<String, Object> resultMap = new Map<String, Object>();
        
        // Retrieve Pricebook information and Opportunity Line Items in a single query
        Opportunity opp = [SELECT Id, Pricebook2Id, Pricebook2.Name,
            (SELECT Id, Name, Quantity, ListPrice, UnitPrice, TotalPrice, OpportunityId, Opportunity.Name, Product2Id, 
                PricebookEntryId, PricebookEntry.Name, PricebookEntry.UnitPrice
                FROM OpportunityLineItems)
            FROM Opportunity 
            WHERE Id = :opportunityId WITH SYSTEM_MODE];

        // Retrieve Pricebook Id and Name
        String priceBookId = opp.Pricebook2Id;
        String priceBookName = opp.Pricebook2.Name;

        // Retrieve Opportunity Line Items from the subquery
        List<OpportunityLineItem> opportunityLineItems = opp.OpportunityLineItems;

        // Collect Product Ids
        Set<Id> productIds = new Set<Id>();
        for(OpportunityLineItem oli : opportunityLineItems) {
            productIds.add(oli.Product2Id);
        }

        // Query Products
        Map<Id, Product2> productIdToProduct = new Map<Id, Product2>([
            SELECT Id, Name, ProductCode, Description, Family, Pricing_Type__c,
            (SELECT Id, Name, Is_Active__c, Max_Quantity__c, Min_Quantity__c, Unit_Price__c, Product__c  FROM Slab_Prices__r WHERE Is_Active__c = true order by Min_Quantity__c), 
            (SELECT Id, Name, Pricebook2Id, Product2Id, UnitPrice, IsActive, UseStandardPrice, ProductCode FROM PricebookEntries WHERE IsActive = true AND Pricebook2Id =: priceBookId) 
            FROM Product2
            WHERE Id IN :productIds
            WITH SYSTEM_MODE]);

        // Populate the result map
        resultMap.put('priceBookId', priceBookId);
        resultMap.put('priceBookName', priceBookName);
        resultMap.put('opportunityLineItems', opportunityLineItems);
        resultMap.put('products', productIdToProduct);
        resultMap.put('priceAccess', getPriceModificationPermissionAssignments());
        resultMap.put('userPermissionSetNames', getUserPermissionSetNames());
        resultMap.put('userProfileName', getUserProfileName());
        
        return resultMap;
    } 

    @AuraEnabled
    public static List<OpportunityLineItem> createOpportunityLineItems(List<OpportunityLineItem> lineItems) {
        if(!lineItems.isEmpty()){
            insert lineItems;
        }
        return lineItems;
    }

    @AuraEnabled
    public static void updateOpportunityLineItems(List<OpportunityLineItem> updateItems, List<OpportunityLineItem> deletItems) {
        if(!updateItems.isEmpty()){
            update updateItems;
        }
        if(!deletItems.isEmpty()){
            delete deletItems;
        }
    }

    public static List<PriceModificationPermissionAssignmentWrapper> getPriceModificationPermissionAssignments() {
        List<PriceModificationPermissionAssignmentWrapper> assignmentList = new List<PriceModificationPermissionAssignmentWrapper>();

        // Retrieve records from Custom Metadata Type
        List<Price_Modification_permission_Assignment__mdt> assignments = [SELECT Id, Label, Product_Families__c, Profile_Names__c, Permission_Set_Names__c, Access_Type__c FROM Price_Modification_permission_Assignment__mdt WHERE Is_Active__c = true WITH SYSTEM_MODE];
        for (Price_Modification_permission_Assignment__mdt assignment : assignments) {
            assignmentList.add(new PriceModificationPermissionAssignmentWrapper(assignment));
        }

        return assignmentList;
    }

    public static List<String> getUserPermissionSetNames() {
        List<String> permissionSetNames = new List<String>();
        
        // Query PermissionSetAssignment to get assigned Permission Set Names for the current user
        for (PermissionSetAssignment assignment : [SELECT PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId = :UserInfo.getUserId() WITH SYSTEM_MODE]) {
            permissionSetNames.add(assignment.PermissionSet.Name);
        }
        
        return permissionSetNames;
    }

    public static String getUserProfileName() {
        return [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId() WITH SYSTEM_MODE].Profile.Name;
    }

    public static Map<String, String> getPicklistValues(String objectApiName, String fieldApiName) {
        Map<String, String> picklistValuesMap = new Map<String, String>();
        
        // Describe the object and field to get picklist values
        Schema.DescribeFieldResult fieldResult = Schema.getGlobalDescribe().get(objectApiName).getDescribe().fields.getMap().get(fieldApiName).getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
        
        // Populate picklist values map
        for (Schema.PicklistEntry entry : picklistValues) {
            picklistValuesMap.put(entry.getValue(), entry.getLabel());
        }
        
        return picklistValuesMap;
    }

    // Wrapper class to hold price modification permission assignment details
    public class PriceModificationPermissionAssignmentWrapper {
        @AuraEnabled public Id recordId;
        @AuraEnabled public String label;
        @AuraEnabled public String productFamilys;
        @AuraEnabled public String profileNames;
        @AuraEnabled public String permissionSetNames;
        @AuraEnabled public String accessType;

        public PriceModificationPermissionAssignmentWrapper(Price_Modification_permission_Assignment__mdt assignment) {
            this.recordId = assignment.Id;
            this.label = assignment.Label;
            this.productFamilys = assignment.Product_Families__c;
            this.profileNames = assignment.Profile_Names__c;
            this.permissionSetNames = assignment.Permission_Set_Names__c;
            this.accessType = assignment.Access_Type__c;
        }
    }
}