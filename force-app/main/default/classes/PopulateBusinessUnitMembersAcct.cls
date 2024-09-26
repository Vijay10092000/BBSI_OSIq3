public class PopulateBusinessUnitMembersAcct{
    
    private static Set<ID> newBUC = new Set<ID>();
    private static Set<ID> oldBUC = new Set<ID>();
    private static Set<Id> newbusinessUnitLookup = new Set<Id>();
    private static Set<Id> oldbusinessUnitlookup = new Set<Id>();
    private static Map<ID, ID> acctBU = new Map<ID, ID>();
    private static Map<Id, List<Id>> bu2buc = new Map<Id, List<Id>>();
    
    public static void populateBusinessUnitMembers(List<Account> listAccounts, Map<id,Account> mapOldAccounts){
        checkAccount(listAccounts, mapOldAccounts);
        
        if(newbusinessUnitlookup.size() > 0 || oldbusinessUnitlookup.size() > 0){
            findBusinessUnitContact(newbusinessUnitLookup, oldbusinessUnitlookup);    
        }
        if(!acctBU.isEmpty() && acctBU != NULL){
            updateBusinessUnits();  
        } 
        
        // Clear the variables
        newBUC.clear();
        oldBUC.clear();
        newbusinessUnitLookup.clear();
        oldbusinessUnitlookup.clear();
        acctBU.clear();
        bu2buc.clear();
        
    }

    private static void checkAccount(List<Account> listAccounts, Map<id,Account> mapOldAccounts){
        if(mapOldAccounts != null){    // Update
            for(Account a: listAccounts){
                //Need to filter out the text field Branch Update.  To avoid a double update to the BU Related List
                //WF Rule: Update Branch Field Update: Update Branch Field
                if(a.Branch__c == mapOldAccounts.get(a.ID).Branch__c){
                    //for an Update to the BU and the new value is != NULL
                    if(a.Business_Unit__c != mapOldAccounts.get(a.ID).Business_Unit__c && a.Business_Unit__c != NULL && mapOldAccounts.get(a.ID).Business_Unit__c == NULL){
                        newbusinessUnitLookup.add(a.Business_Unit__c);
                        acctBU.put(a.ID, a.Business_Unit__c);
                    //Update to the BU and the new value == NULL and the old value != NULL
                    }else if(a.Business_Unit__c == NULL && mapOldAccounts.get(a.ID).Business_Unit__c != NULL){
                        oldbusinessUnitlookup.add(mapOldAccounts.get(a.ID).Business_Unit__c);
                        acctBU.put(a.ID, a.Business_Unit__c);
                    // Update to the BU and both the new and old value != NULL
                    }else if(a.Business_Unit__c != mapOldAccounts.get(a.ID).Business_Unit__c && a.Business_Unit__c != NULL && mapOldAccounts.get(a.ID).Business_Unit__c != NULL){
                        System.Debug(a.Business_Unit__c + ' old: ' + mapOldAccounts.get(a.Id).Business_Unit__c);
                        newbusinessUnitLookup.add(a.Business_Unit__c);
                        oldbusinessUnitlookup.add(mapOldAccounts.get(a.ID).Business_Unit__c);
                        acctBU.put(a.ID, a.Business_Unit__c);                   
                    }                    
                }  
            }           
        }else if(mapOldAccounts == null){  // Insert
            for(Account a : listAccounts){
                if(a.Business_Unit__c != NULL){
                    newbusinessUnitlookup.add(a.Business_Unit__c);
                    acctBU.put(a.ID, a.Business_Unit__c);                    
                }              
            }
        }
    }
    
    private static void findBusinessUnitContact(set<ID> newbusinessUnitLookup, set<ID> oldbusinessUnitlookup){
        if(newbusinessUnitLookup.size() > 0){
            for(Business_Unit__c bu : [Select (Select Id, BU_Member__c From Business_Unit_Contacts__r where Active__c = true) 
                                       From Business_Unit__c where ID IN: newbusinessUnitLookup]){
                for(Business_Unit_Contact__c buc: bu.Business_Unit_Contacts__r){
                    newBUC.add(buc.ID);
                }
            }            
        }
        if(oldbusinessUnitlookup.size() > 0){
            for(Business_Unit__c bu : [Select (Select Id From Business_Unit_Contacts__r) From Business_Unit__c where ID IN: oldbusinessUnitlookup]){
                for(Business_Unit_Contact__c buc: bu.Business_Unit_Contacts__r){
                    oldBuc.add(buc.ID);
                }
            }             
        }       
    }
    
    private static void updateBusinessUnits(){
        if(oldBUC.size() > 0){        
            AccountTeamMembers.removeBUMAcct(oldBUC, acctBU);         
        }    
        if(newBUC.size() > 0){
            AccountTeamMembers.addBUMAcct(newBUC, acctBU);
        }
        
    }
}