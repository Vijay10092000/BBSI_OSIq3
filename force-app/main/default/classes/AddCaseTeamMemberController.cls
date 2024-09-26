public without sharing class AddCaseTeamMemberController {
    
    @AuraEnabled
    public static List<User> getUsers(Id caseId, String userGroup) {
        Set<User> setUsers = new Set<User>();
        List<User> listUsers = new List<User>();
        Boolean isCurrentUserTheContact = false;
        Case caseRecord = [Select Id, ContactId, Contact.RecordTypeId, Contact.Account.Id From Case Where Id =: caseId];
        Id employeeContactRecordTypeId = RecordTypeService.getId('Contact', 'BBSI Employee');
        Map<Id, CaseTeamMember> mapExistingCaseTeamMembers = new Map<Id, CaseTeamMember>();
        Business_Unit_Contact__c currentUserswBusinessUnitMembership = new Business_Unit_Contact__c();
        Id contactId;
        Id accountId;
        
        if (caseRecord.ContactId != null && caseRecord.Contact.RecordTypeId == employeeContactRecordTypeId) {
            contactId = caseRecord.ContactId;
            accountId = caseRecord.Contact.Account.Id;
        }
        
        // Get Case Team Members that already exist
        for (CaseTeamMember ctm: [Select Id, ParentId, MemberId, TeamRoleId From CaseTeamMember Where ParentId =: caseId]) {
            	mapExistingCaseTeamMembers.put(ctm.MemberId, ctm);
        }
        
        if(contactId != null & accountId != null) {
            Id currentUsersBusinessUnitId;
            Id currentUsersBranch;
            
            // Checking record count in case the Contact is not associated with a BU.
            Integer recordCount = [SELECT Count() FROM Business_Unit_Contact__c Where BU_Member__c =:contactId Limit 1];
            
            if (recordCount > 0) {
                currentUserswBusinessUnitMembership = [SELECT Id, Business_Unit__c, Business_Unit__r.BBSI_Branch__r.Id FROM Business_Unit_Contact__c Where BU_Member__c =:contactId Limit 1];
                currentUsersBusinessUnitId = currentUserswBusinessUnitMembership.Business_Unit__c;
                currentUsersBranch = currentUserswBusinessUnitMembership.Business_Unit__r.BBSI_Branch__r.Id;
            }
            
            if (userGroup == null || userGroup == 'bu') {
                // add members from the BU
                // Filter out existing Case Team Members from the list of options
                for (Business_Unit_Contact__c buc: [Select BU_Member__c, BU_Member__r.User_Id__r.Id, BU_Member__r.User_Id__r.Name, Branch__c, Active__c, Business_Unit__r.BBSI_Branch__r.Id From Business_Unit_Contact__c Where Active__c = true and BU_Member__r.User_Id__r.Id != null and Business_Unit__c =: currentUsersBusinessUnitId]) {
                    if (!mapExistingCaseTeamMembers.containsKey(buc.BU_Member__r.User_Id__r.Id) && buc.BU_Member__c != caseRecord.ContactId) {
                        setUsers.add(buc.BU_Member__r.User_Id__r);
                    }
                }
            } else if (userGroup == 'branch') {
                Id branchAccountRecordTypeId = RecordTypeService.getId('Account','BBSI Branch');
                Account branchAccount = [Select Id, RecordTypeId From Account Where Id =: accountId];
                // add members from the Branch
                // Filter out existing Case Team Members from the list of options
                if (accountId != null && branchAccount != null && branchAccount.RecordTypeId == branchAccountRecordTypeId) {
                    for (Contact c: [Select Id, AccountId, User_Id__r.Id, User_Id__r.Name From Contact Where AccountId =: accountId]) {
                        if (!mapExistingCaseTeamMembers.containsKey(c.User_Id__r.Id) && c.Id != caseRecord.ContactId) {
                            setUsers.add(c.User_Id__r);
                        }
                    }
                }
        	}
        }
        
        if (setUsers.size() > 0) {
            listUsers.addALL(setUsers);
        }
        return listUsers;
    }
    
    @AuraEnabled
    public static String addUsersToCaseTeam(Id caseId, List<Id> listUserIds) {
        List<CaseTeamMember> listCaseTeamMembersToInsert = new List<CaseTeamMember>();
        Id caseViewerAndNotificationsTeamRole = CaseTeamMember_Services.getCaseTeamRoleByName('Viewer & Notifications');
        String resultMessage;
        
        for (Id userId: listUserIds) {
            CaseTeamMember newCaseTeamMember = new CaseTeamMember(ParentId = caseId, MemberId = userId, TeamRoleId = caseViewerAndNotificationsTeamRole); 
            listCaseTeamMembersToInsert.add(newCaseTeamMember);
        }
        
        Database.SaveResult[] result = Database.insert(listCaseTeamMembersToInsert, true);   
        for (Database.SaveResult sr : result) {
            if (sr.isSuccess()) {
                resultMessage = 'User(s) added to Case Team';
            } else {
                resultMessage = 'Unable to add User(s) to Case Team';
            }    
        }    
        
        return resultMessage;
    }    
        

}