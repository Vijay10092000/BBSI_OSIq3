//
// FEIN_Services contains helper methods for the FEIN object.
//
public class FEIN_Services {
        
    //
    // assignAccountFEINs sets the FEIN_Id__c on the given Accounts.
    // Called: Account Before Insert/Update
    //
    public static void assignAccountFEINs(List<Account> newAccounts, List<Account> oldAccounts){
        Set<String> feinNames = new Set<String>();
        List<FEIN__c> feins = new List<FEIN__c>(); 
        
        for (Integer i = 0; i < newAccounts.size(); i++) { 
            if (oldAccounts != NULL && newAccounts[i].FEIN__c != oldAccounts[i].FEIN__c){
                if (!String.isBlank(newAccounts[i].FEIN__c)) {
                    feinNames.add(newAccounts[i].FEIN__c);
                }
                if (!String.isBlank(oldAccounts[i].FEIN__c)) {
                    feinNames.add(oldAccounts[i].FEIN__c);
                } 
                newAccounts[i].FEIN_Id__c = null;
            }  
            else if (!String.isBlank(newAccounts[i].FEIN__c) && newAccounts[i].FEIN_Id__c == NULL) {
                feinNames.add(newAccounts[i].FEIN__c);
            }
        }  

        if (!feinNames.isEmpty()) {
            feins = getFeinsByName(feinNames);
            
            for (Account a : newAccounts){
                for (FEIN__c f : feins){
                    if (f.Name == a.FEIN__c){
                        a.FEIN_Id__c = f.Id;
                        break;
                    }   
                }  
            }
        } 
    }
    
    //
    // updateAccountFEINs creates new FEIN__c objects if they do not exist for the Account.
    // Called: Account After Insert/Update
    //
    public static void updateAccountFEINs(List<Account> newAccounts, List<Account> oldAccounts){
        Set<String> newFeinNames = new Set<String>();  
        
        for (Integer i = 0; i < newAccounts.size(); i++){    
            if (!String.isBlank(newAccounts[i].FEIN__c)){                     
                if (newAccounts[i].FEIN_Id__c == null){   
                    newFeinNames.add(newAccounts[i].FEIN__c);
                }
            }
        }
       
        createFEINs(newFeinNames);
    }   

    //
    // assignLeadFEINs sets the FEIN_Id__c on the given Leads.
    // Called: Lead Before Insert/Update
    //
    public static void assignLeadFEINs(List<Lead> newLeads, List<Lead> oldLeads){
        Set<String> feinNames = new Set<String>();
        List<FEIN__c> feins = new List<FEIN__c>(); 
        
        for (Integer i = 0; i < newLeads.size(); i++) { 
            if (oldLeads != NULL && newLeads[i].FEIN__c != oldLeads[i].FEIN__c){
                if (!String.isBlank(newLeads[i].FEIN__c)) {
                    feinNames.add(newLeads[i].FEIN__c);
                }
                if (!String.isBlank(oldLeads[i].FEIN__c)) {
                    feinNames.add(oldLeads[i].FEIN__c);
                } 
                newLeads[i].FEIN_Id__c = null;
            } 
            else if (!String.isBlank(newLeads[i].FEIN__c) && newLeads[i].FEIN_Id__c == NULL) {
                feinNames.add(newLeads[i].FEIN__c);
            }
        }  

        if (!feinNames.isEmpty()) {
            feins = getFeinsByName(feinNames);
            
            for (Lead l : newLeads){
                for (FEIN__c f : feins){
                    if (f.Name == l.FEIN__c){
                        l.FEIN_Id__c = f.Id;
                        break;
                    }   
                }  
            }
        } 
    }
    
    //
    // updateLeadFEINs creates new FEIN__c objects if they do not exist for the Lead.
    // Called: Lead After Insert/Update
    // 
    public static void updateLeadFEINs(List<Lead> newLeads, List<Lead> oldLeads){
        Set<String> newFeinNames = new Set<String>();  
        
        for (Integer i = 0; i < newLeads.size(); i++){    
            if (!String.isBlank(newLeads[i].FEIN__c)){          
                if (newLeads[i].FEIN_Id__c == null){   
                    newFeinNames.add(newLeads[i].FEIN__c);
                }
            }
        }
       
        createFEINs(newFeinNames);
    }

    //
    // createFEINs creates FEIN__c objects with the given names.
    //
    public static void createFEINs(Set<String> names) {
        Set<String> newNames = new Set<String>(names); 
        newNames.remove(null);
        newNames.remove('');
        
        if (!newNames.isEmpty()) {
            newNames = removeExistingFeinNames(newNames);
            
            List<FEIN__c> newFeins = new List<FEIN__c>();
            
            for (String name : newNames) {
                newFeins.add(new FEIN__c(Name = name)); 
            }           

            if (!newFeins.isEmpty()) {
                insert newFeins;
            }
        }
    } 
    
    //
    // performCalculations updates any fields which are not updated by the DLRS.
    // Called: FEIN__c Before Insert/Update
    // 
    public static void performCalculations(List<FEIN__c> newFeins, List<FEIN__c> oldFeins){
//        setCancellationDate(newFeins, oldFeins);
    }
    
    //
    // processLinks updates related Accounts and Leads if the
    // FEIN__c is new or the name has changed.
    // Called: FEIN__c After Insert/Update
    // 
    public static void processLinks(List<FEIN__c> newFeins, List<FEIN__c> oldFeins){  
        Map<String, FEIN__c> mapFeins = new Map<String, FEIN__c>() ;
        
        for (Integer i = 0; i < newFeins.size(); ++i) {
            if (oldFeins == null) {
                mapFeins.put(newFeins[i].Name, newFeins[i]);
            }
        }       
        
        if (!mapFeins.isEmpty()) {
            processAccountLinks(mapFeins);
            processLeadLinks(mapFeins);
        }
    }

    //
    // processAccountLinks determines changes to related Accounts to the FEIN
    // 
    private static void processAccountLinks(Map<String, FEIN__c> mapFeins) {
        List<Account> accounts = new List<Account>();
        
        for (Account a : [SELECT Id, FEIN__c, FEIN_Id__c FROM Account WHERE FEIN__c IN :mapFeins.keySet()]) {
            if (String.isBlank(a.FEIN_Id__c) || a.FEIN__c != mapFeins.get(a.FEIN__c).Name) {
                a.FEIN_Id__c = NULL;
                accounts.add(a);
            }
        }
        if (!accounts.isEmpty()){
            Database.update(accounts, false); 
        }  
    }
    
    //
    // processLeadLinks determines changes to related Leads to the FEIN
    // 
    private static void processLeadLinks(Map<String, FEIN__c> mapFeins) {
        List<Lead> leads = new List<Lead>();
        
        for (Lead l : [SELECT Id, FEIN__c, FEIN_Id__c FROM Lead WHERE FEIN__c IN :mapFeins.keySet()]) {
            if (String.isBlank(l.FEIN_Id__c) || l.FEIN__c != mapFeins.get(l.FEIN__c).Name ) { 
                l.FEIN_Id__c = NULL;
                leads.add(l);
            }
        }

        if (!leads.isEmpty()){
            Database.update(leads, false);
        }   
    }
    
    //
    // getAccountsByFein retrieves a list of Accounts with the given FEIN values.
    // 
    public static List<Account> getAccountsByFein(Set<String> feins) {   
        return [SELECT Id, FEIN__c, FEIN_Id__c, Cancellation_Date__c FROM Account WHERE FEIN__c IN :feins];
    }
    
    //
    // getFeinsByName retrieves a list of FEIN__c objects based on their names.
    // 
    public static List<FEIN__c> getFeinsById(Set<Id> ids) {
        return [SELECT Id, Name, Client_Runoff_Date__c FROM FEIN__c WHERE Name IN :ids];        
    }
    
    //
    // getFeinsByName retrieves a list of FEIN__c objects based on their names.
    // 
    public static List<FEIN__c> getFeinsByName(Set<String> names) {
        return [SELECT Id, Name, Client_Runoff_Date__c FROM FEIN__c WHERE Name IN :names];        
    }
    
    //
    // removeExistingFeinNames from a list of names remove those which already
    // exists as a FEIN__c object.
    //
    public static Set<String> removeExistingFeinNames(Set<String> names) {

        names.remove(null);
        names.remove('');
        
        Set<String> newNames = new Set<String>(names);
        
        for (FEIN__c f : getFeinsByName(names)) {
            newNames.remove(f.Name);
        }
        
        return newNames;
    }
/******************   
    private static void setCancellationDate(List<FEIN__c> newFeins, List<FEIN__c> oldFeins) {
        Map<String, FEIN__c> mapFeins = new Map<String, FEIN__c>();
        
        for (Integer i = 0; i < newFeins.size(); i++) {
            
            if (newFeins[i].Status__c == 'Terminated') {
                if (oldFeins == null || oldFeins[i].Status__c != newFeins[i].Status__c) {
                    mapFeins.put(newFeins[i].Name, newFeins[i]);
                }
            }
            else {
                newFeins[i].Client_Runoff_Date__c = null;
            }
        }
            
        if (!mapFeins.isEmpty()) {
            FEIN__c fein;
            
            for (Account a : getAccountsByFein(mapFeins.keySet())) {
                if (a.Cancellation_Date__c != null) {
                    fein = mapFeins.get(a.FEIN__c);
                    
                    // Use the most recent date
                    if (fein.Client_Runoff_Date__c == null || fein.Client_Runoff_Date__c < a.Cancellation_Date__c) {
                        fein.Client_Runoff_Date__c = a.Cancellation_Date__c;
                    }
                }
            }                
        }
    } ****************/
}