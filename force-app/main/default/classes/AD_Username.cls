public class AD_Username {
    
    private static Map<String, ID> ADUsers = new Map<String, ID>();
    private static Map<String, ID> FullNameUsers = new Map<String, ID>();
    private static Map<String, ID> AreaManager = new Map<String, ID>();

    public static void UpdateAccounts(List<Account> listAccounts){
        ID recordTypeLocation = RecordTypeService.getId('Account','Location');
        getUsers(listAccounts);
        
        for(Account a: listAccounts){
            if(a.External_ID__c != null && (a.AD_Username__c != null || a.branch__c != null)){
                // For staffing
                if(a.Record_Type_ID__c != recordTypeLocation){
                    if(Double.valueOf(a.External_ID__c) < 900000 && AreaManager != null && AreaManager.containsKey(a.Branch__c)){                   
                        a.OwnerId = AreaManager.get(String.valueOf(a.Branch__c));
                    }else if(Double.valueOf(a.External_ID__c) >= 900000 && ADUsers != null && a.AD_Username__c != null && ADUsers.containsKey(a.AD_Username__c.toLowerCase())){
                        a.OwnerId = ADUsers.get(a.AD_Username__c.toLowerCase());                   
                    }
                }else if(ADUsers != null && a.AD_Username__c != null && ADUsers.containsKey(a.AD_Username__c.toLowerCase())){
                    // For locations
                    a.OwnerId = ADUsers.get(a.AD_Username__c.toLowerCase());
                }           

            }
        }       
    }

    private static void getUsers(List<Account> listAccounts){
        Set<String> Users = new Set<String>();
        Set<String> Branches = new Set<String>();
        ID recordTypeLocation = RecordTypeService.getId('Account','Location');
        for(Account a: listAccounts){
            if(a.External_ID__c != NULL && (a.AD_Username__c != null || a.branch__c != NULL) && a.Record_Type_ID__c != recordTypeLocation){
                if(Double.valueOf(a.External_ID__c) > 900000){
                    Users.add(a.AD_Username__c);
                }else{
                    Branches.add(a.Branch__c);                    
                }             
            }else if(a.recordTypeID == recordTypeLocation){
                Users.add(a.AD_Username__c);
            }
        }
        
        if((Branches.size() > 0 && Branches != NULL) || (users.size() > 0 && users != NULL)){
            for (User u : [
                SELECT Id, AD_Username__c, Name, Profile.Name 
                FROM User 
                WHERE isActive = TRUE 
                AND AD_Username__c != NULL 
                AND (AD_Username__c IN :users OR Profile.Name = 'Area Manager'
            )]) {
                if(u.Profile.Name == 'Area Manager'){
                    FullNameUsers.put(u.name, u.ID);
                }else{
                    ADUsers.put(u.AD_Username__c.toLowerCase(), u.ID);    
                }           
            }
            getAreaManager(Branches);
        }
        
    } 

    private static void getAreaManager(Set<String> Branches){
        Set<ID> acctID = new Set<ID>();
        ID recordTypeBranch = RecordTypeService.getId('Account','BBSI_Branch');

        for(Account a: [Select Name, Branch_Manager__c from Account where RecordTypeID =: recordTypeBranch and name IN :Branches]){
            AreaManager.put(a.Name, FullNameUsers.get(a.Branch_Manager__c));
        }
        
    }  
}