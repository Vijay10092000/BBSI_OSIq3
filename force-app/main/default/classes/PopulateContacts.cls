public class PopulateContacts {

    /**
     * updateInsertContacts called for new Users with AD_Usernames to create 
     * a related contact or to update a contact related to a current user.
     * @param  userIds is the list of User Ids to review
     * Note: This is a future call and will be run after the current process.
     */
    @future
    public static void updateInsertContacts(List<Id> userIds) {
        Id bbsiEmployeeRecordTypeId = RecordTypeService.getId('Contact', 'BBSI_Employee');
        Id bbsiBranchRecordTypeId = RecordTypeService.getId('Account', 'BBSI_Branch');  
 
        Map<String, Id> branchIdByNumber = new Map<String, Id>();
        Set<String> branchIds = new Set<String>();

        List<User> users = [
            SELECT Id, IsActive, FirstName, LastName, Email, Phone, MobilePhone, Branch_Id__c 
            FROM User 
            WHERE Id IN :userIds
        ];
 
        for (User u : users) { 
            branchIds.add(u.Branch_Id__c);
        }

        List<Account> accounts = [
            SELECT Id, External_Id__c 
            FROM Account 
            WHERE External_Id__c IN :branchIds 
            AND RecordTypeId = :bbsiBranchRecordTypeId
        ];

        for (Account a : accounts) {
            branchIdByNumber.put(a.External_Id__c, a.Id);
        }

        Map<Id, Contact> contactRecords = getContacts(userIds);

        List<Contact> contacts = new List<Contact>();
        for (User u : users) {
            Contact c = new Contact(
                User_Id__c = u.Id,
                RecordTypeId = bbsiEmployeeRecordTypeId,
                FirstName = u.FirstName,
                LastName = u.LastName,
                Email = u.Email,
                Phone = u.Phone,
                MobilePhone = u.MobilePhone,
                Branch_Id__c = u.Branch_Id__c,
                AccountId = branchIdByNumber.get(u.Branch_Id__c),
                Active__c = u.IsActive
            );
            
            if (contactRecords.containsKey(u.Id)) {
                c.Id = contactRecords.get(u.Id).Id;
            }

            contacts.add(c);     
        }
        
        if (!contacts.isEmpty()) {
            upsert contacts;
        }
    }

    /**
     * getContacts retrieves a map of Contacts related to the given User Ids.
     * @param  userIds User Ids to retrieve Contacts for
     * @return Map of Contacts.
     */
    private static map<Id, Contact> getContacts(list<id> userIds) {
        Map<Id, Contact> mapReturn = new Map<Id,Contact>();

        for (Contact c : [SELECT Id, User_Id__c, FirstName, LastName, Email, Phone, MobilePhone, Branch_Id__c, AccountId, Active__c FROM Contact WHERE User_Id__c IN :userIds]){
            mapReturn.put(c.User_Id__c, c);
        }

        return mapReturn;
    }

}