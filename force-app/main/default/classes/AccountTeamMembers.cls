public without sharing class AccountTeamMembers {
    
    public static void addBUMAcct(set<ID> newBUC, map<ID,ID> acctBU){
        list<Business_Unit_Member__c> updatedBUM = new list<Business_Unit_Member__c>();
        list<AccountTeamMember> atm = new list<AccountTeamMember>();
        list<AccountShare> aShareList = new list<AccountShare>();
        map<ID, ID> Users = new map<ID, ID>();
        map<ID,set<Business_Unit_Contact__c>> BUs = new map<ID, set<Business_Unit_Contact__c>>();
        map<ID, ID> accountOwner = new map<ID, ID>();
        
        set<Business_Unit_Contact__c> tempCollection;
        for(Business_Unit__c bu: [Select ID, (Select ID, BU_Member__c, Role__c, Active__c, User_Active__c from Business_Unit_Contacts__r) from Business_Unit__c where ID IN: acctBU.values()]){
            tempCollection = new Set<Business_Unit_Contact__c>();
            for(Business_Unit_Contact__c buc : bu.Business_Unit_Contacts__r){
                if(buc.Active__c == true && buc.User_Active__c == true){
                    tempCollection.add(buc);
                }                
            }
            BUs.put(bu.ID, tempCollection);
        }
        //newBUC == Contact ID not the Bussiness Unit Contact ID
        //Need to modify the SOQL statement below to accomadate 
        //System.debug('New BUC: ' + newBUC);
        for(Business_Unit_Contact__c buc : [Select ID, BU_Member__r.User_ID__c from Business_Unit_Contact__c where ID IN: newBUC]){
            Users.put(buc.ID, buc.BU_Member__r.User_ID__c);
        }
        
        for(Account a : [Select ID, OwnerId from Account where ID IN: acctBU.keySet()]){
            accountOwner.put(a.ID, a.OwnerId);
        }
        //System.debug('Business Units: ' + BUs);
        //System.debug('Account Map: ' + acctBU);
        //map<BUC.ID, BU.ID> => map<BU.ID, Acct.ID>
        Business_Unit_Member__c b;
        AccountTeamMember a;
        AccountShare aShare; 
        for(ID i : acctBU.KeySet()){
         
            b = new Business_Unit_Member__c();
            a = new AccountTeamMember();
            
            //if(BUs.containsKey(acctBU.get(i))){
                for(Business_Unit_Contact__c buc : BUs.get(acctBU.get(i))){
                    if(Users.containsKey(buc.ID)){
                        b = new Business_Unit_Member__c();               
                        b.Client__c = i;
                        b.Business_Unit_Member__c = buc.ID;
                        updatedBUM.add(b);
                        
                        if(Users.get(buc.ID) != accountOwner.get(i)){
                          a = new AccountTeamMember();    
                          a.AccountID = i;
                          a.UserID = Users.get(buc.ID);
                          a.TeamMemberRole = buc.Role__c;
                          atm.add(a);
                        }
                        
                        /*
                        if(accountOwner.get(i) != Users.get(buc.ID)){
                            aShare = new AccountShare();
                            ashare.AccountId = i;
                            aShare.UserOrGroupId = Users.get(buc.ID);
                            aShare.AccountAccessLevel = 'Edit';
                            aShare.OpportunityAccessLevel = 'Edit';
                            aShare.CaseAccessLevel = 'Edit';
                            aShareList.add(aShare);  
                        }*/
                        
                    }                 
                }                 
            //}
            
        }
        System.debug(atm);
        try{
            System.Debug('inserting atm');
            insert atm;
            System.Debug('updating BUM');
            insert updatedBUM;
            //insert aShareList;
            updateShares(Users,acctBU);
        }catch(DMLException e){
            System.debug('Error inserting ATM' + e);
        }         
    }
    
    public static void removeBUMAcct(set<ID> oldBUC, map<ID,ID> acctBU){
        list<Business_Unit_Member__c> removeMembers = new list<Business_Unit_Member__c>();
        list<AccountTeamMember> removeAccountTeam = new list<AccountTeamMember>();
        
        map<ID, ID> Users = new map<ID, ID>();
        set<ID> userID = new set<ID>();
        
        for(Business_Unit_Member__c bum : [Select name,  Client__c, Business_Unit_Member__c 
                                           From Business_Unit_Member__c where Business_Unit_Member__c IN :oldBUC and Client__c IN : acctBU.keySet()]){
                                               removeMembers.add(bum);         
                                           }
        
        for(Business_Unit_Contact__c buc : [Select ID, BU_Member__r.User_ID__c from Business_Unit_Contact__c where ID IN: oldBUC]){
            Users.put(buc.ID, buc.BU_Member__r.User_ID__c);
        }
        
        for(AccountTeamMember atm : [Select ID from AccountTeamMember where AccountID IN :acctBU.keySet() and userID IN :Users.values()]){
            removeAccountTeam.add(atm);
        }
        
        try{
            delete removeAccountTeam;
            delete removeMembers;
        }catch(DMLException e){
            System.debug(e);
        }        
    }
    
    public static void addBUMContact(set<ID> newBUC, map<ID, Business_Unit_Contact__c> bucBU){
        list<Business_Unit_Member__c> updatedBUM = new list<Business_Unit_Member__c>();
        list<AccountTeamMember> atm = new list<AccountTeamMember>();
        list<AccountShare> aShareList = new list<AccountShare>();
        map<ID, ID> acctBU = new map<ID, ID>();
        map<ID, ID> Users = new map<ID, ID>();
        map<ID,set<Business_Unit_Contact__c>> BUCs = new map<ID, set<Business_Unit_Contact__c>>();
        map<ID, ID> accountOwner = new map<ID, ID>();
        
        for(Account a : [Select ID, Business_Unit__c from Account where Business_Unit__c IN :bucBU.keySet()]){
            acctBU.put(a.ID, a.Business_Unit__c);
        }
        
        
        for(Business_Unit_Contact__c b: [SELECT Id, BU_Member__r.User_Id__c FROM Business_Unit_Contact__c where ID IN :newBUC and Active__c = true]){
            users.put(b.ID, b.BU_Member__r.User_Id__c);
        }
        
        for(Account a : [Select ID, OwnerId from Account where ID IN: acctBU.keySet()]){
            accountOwner.put(a.ID, a.OwnerId);
        }        
        
        Business_Unit_Member__c b;
        AccountTeamMember a;
        AccountShare aShare;
        for(ID i : acctBU.keySet()){
            b = new Business_Unit_Member__c();
            b = new Business_Unit_Member__c();               
            b.Client__c = i;
            b.Business_Unit_Member__c = bucBU.get(acctBU.get(i)).ID;
            updatedBUM.add(b);
            
            a = new AccountTeamMember();    
            a.AccountID = i;
            a.UserID = users.get(bucBU.get(acctBU.get(i)).ID);
            a.TeamMemberRole = bucBU.get(acctBU.get(i)).Role__c;
            atm.add(a);
            
           /* if(accountOwner.get(i) != users.get(bucBU.get(acctBU.get(i)).ID)){               
                aShare = new AccountShare();
                ashare.AccountId = i;
                aShare.UserOrGroupId = users.get(bucBU.get(acctBU.get(i)).ID);
                aShare.AccountAccessLevel = 'Edit';
                aShare.OpportunityAccessLevel = 'Edit';
                aShareList.add(aShare);
            }*/
        }    
        
        try{           
            upsert atm;
            upsert updatedBUM;
            //upsert aShareList;
            updateShares(users,acctBu);
        }catch(DMLException e){
            System.debug(e);
        }       
    }
    
    public static void removeBUMContact(set<ID> oldBUC, set<ID> BU){
        list<Business_Unit_Member__c> removeMembers = new list<Business_Unit_Member__c>();
        list<AccountTeamMember> removeAccountTeam = new list<AccountTeamMember>();
        
        set<ID> contactID = new set<ID>();
        set<ID> userID = new set<ID>();
        set<ID> buID = new set<ID>();
        set<ID> acctID = new set<ID>();
        
        for(Business_Unit_Member__c bum : [Select name,  Client__c, Business_Unit_Member__c 
                                           From Business_Unit_Member__c where Business_Unit_Member__c IN :oldBUC]){
                                               removeMembers.add(bum);
                                               acctID.add(bum.Client__c);                                   
                                               buID.add(bum.Business_Unit_Member__c);            
                                           }
        
        for(Business_Unit_Contact__c buc : [Select ID, BU_Member__c From Business_Unit_Contact__c where ID IN :buID]){
            contactID.add(buc.BU_Member__c);
        }
        
        for(Contact c: [Select User_ID__c from Contact where ID IN :contactID]){
            userID.add(c.User_ID__c);
        }
        
        for(AccountTeamMember acct : [Select ID from AccountTeamMember where  UserID IN :userID and AccountID IN: acctID]){
            removeAccountTeam.add(acct);            
        }
        
        try{
            delete removeAccountTeam;
            delete removeMembers;
        }catch(DMLException e){
            System.debug(e);
        }
    }

    private static void updateShares(map<id,id> users, map<id,id> acctBu){
        System.Debug('Updateing Shares Start');
        List<AccountShare> acctShares = new List<AccountShare>();
        set<id> userIds = new set<id>();
        userIds.addAll(users.Values());
        For(AccountShare aShare: [Select Id,UserOrGroupId, RowCause, AccountAccessLevel,CaseAccessLevel,OpportunityAccessLevel
                                  From AccountShare where AccountId in: acctBu.keySet()]){
            if(userIds.Contains(aShare.UserOrGroupId)){
                if(aShare.RowCause != 'Owner'){
                  aShare.AccountAccessLevel = 'Edit';
                }
                aShare.OpportunityAccessLevel = 'Edit';
                aShare.CaseAccessLevel = 'Edit';
                acctShares.add(aShare);
            }

        }
        System.debug('UpdatingShares: ' + acctShares);
        if(!acctShares.isEmpty()){
            update acctShares;
            System.Debug('shares updated');
        }
    }
}