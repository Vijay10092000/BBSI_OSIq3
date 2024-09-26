/**
 *  @description Case_Services contains methods to handle Case changes.
 */
@SuppressWarnings('PMD.CyclomaticComplexity, PMD.StdCyclomaticComplexity')
public without sharing class Case_Services {
	public static final String CASE_NAME = 'Case';

	public static final String RECORDTYPE_MANAGEMENT = 'AM/Management';
	public static final String RECORDTYPE_BRANCH = 'Branch Use';
	public static final String RECORDTYPE_CLIENT_RP = 'Client/Referral Partner';
	public static final String RECORDTYPE_FROM_EMAIL = 'Email to Case';
	public static final String RECORDTYPE_PERSONAL = 'Personal Request';
	public static final String RECORDTYPE_SYSTEM = 'System Generated';
	public static final String RECORDTYPE_OUTAGE = 'System Wide/Outage';
	public static final String RECORDTYPE_VENDOR = 'Vendor';

    public static final String UNVERIFIED_EMAIL = 'Unverified email';
    public static Boolean isUpdatingCaseTeamMembers = false;

    /**
     * @description Before a case is inserted, check if the owner is a queue and assign an entitlement accordingly.
     * @param  newValues List new Case values
     **/
    public static void assignEntitlementInsert(List<Case> newValues){
        Id branchUseRecordTypeId = RecordTypeService.getId('Case','Branch Use');
        Id systemGeneratedRecordTypeId = RecordTypeService.getId('Case','System Generated');
        Map<String,Entitlement> entitlementMap = new Map<String,Entitlement>();
        Map<Id,Id> caseEntitlementMap = new Map<Id,Id>();

        //if any of the cases have had an owner change, then get the Entitlement Map
        caseEntitlementMap = getEntitlement(newValues);

        for(Case c : newValues){
            //check if the current owner is a queue, record type is not Branch Use or System Generated, Origin is not unverified email, and Skip Automation is false
            if(string.valueOf(c.OwnerId).startsWith('00G') && c.RecordTypeId != branchUseRecordTypeId && c.RecordTypeId != systemGeneratedRecordTypeId && c.Origin != UNVERIFIED_EMAIL && !c.Skip_Automation__c){
                //owner is queue
                //need to put null checks in
                if (caseEntitlementMap.get(c.Id) != null) {
                    c.EntitlementId = caseEntitlementMap.get(c.Id);
                }
                else {
                    c.EntitlementId = NULL;
                }
            }
        }
    }

    /**
     * @description Before a case is updated, check if the owner has changed to a queue and assign an entitlement accordingly.
     * @param  newValues Map Ids to  new Case values
     * @param  oldValues Map Ids to previous Case values
     **/
    public static void assignEntitlementUpdate(map<ID,Case> newValues, Map<Id,Case> oldValues){
        Id branchUseRecordTypeId = RecordTypeService.getId('Case','Branch Use');
        Id systemGeneratedRecordTypeId = RecordTypeService.getId('Case','System Generated');
        List<Case> newValuesCases = new List<Case>();
        Map<String,Entitlement> entitlementMap = new Map<String,Entitlement>();
        Map<Id,Id> caseEntitlementMap = new Map<Id,Id>();
        Boolean ownerChange = false;

        //if any of the cases have had an owner change, then get the Entitlement Map
        for(Case c : newValues.values()){
            //check if the owner is the same
            if(c.OwnerId != oldValues.get(c.Id).OwnerId && c.RecordTypeId != branchUseRecordTypeId && c.RecordTypeId != systemGeneratedRecordTypeId && c.Origin != UNVERIFIED_EMAIL && !c.Skip_Automation__c){
                ownerChange = true;
            }
        }

        if(ownerChange){
            for(Case c : newValues.values()){
                newValuesCases.add(c);
            }

            caseEntitlementMap = getEntitlement(newValuesCases);
            for(Case c : newValues.values()){
                //check if the current owner is a queue, record type is not Branch Use or System Generated, Origin is not unverified email, and Skip Automation is false
                if(string.valueOf(c.OwnerId).startsWith('00G') && c.RecordTypeId != branchUseRecordTypeId && c.RecordTypeId != systemGeneratedRecordTypeId && c.Origin != UNVERIFIED_EMAIL && !c.Skip_Automation__c){
                    //owner is queue
                    //need to put null checks in
                    if(caseEntitlementMap.get(c.Id)!=NULL){
                        c.EntitlementId = caseEntitlementMap.get(c.Id);
                    }
                    else {
                        c.EntitlementId = null;
                    }
                }
            }
        }
    }

    /**
     * @description getEntitlement finds the relationship between the Case owner and
     * Entitlements
     * @param  newValues List of Cases to review
     * @return List relateding Case Id to Entitlement Id.  A null Entitlement
     *         Id mean no relationship found.
     */
    private static Map<Id, Id> getEntitlement(List<Case> newValues) {
        List<Id> ownerIds = new List<Id>();
        Map<Id,String> queuesMap = new Map<Id,String>();
        List<String> queueNames = new List<String>();
        Map<String,String> assignmentMap = new Map<String,String>();
        List<String> entitlementCodes = new List<String>();
        Map<String,Id> entitlementMap = new Map<String,Id>();
        Map<Id, Id> caseEntitlementMap = new Map<Id, Id>();

        for (Case c: newValues) {
            ownerIds.add(c.OwnerId);
        }

        for (Group g : [SELECT Id, DeveloperName FROM Group WHERE Type = 'Queue' AND Id IN :ownerIds]) {
            queuesMap.put(g.Id, g.DeveloperName);
            queueNames.add(g.DeveloperName);
        }

        for (Case_Entitlement_Assignment__mdt cea : [SELECT DeveloperName, MasterLabel, Entitlement_Code__c, Queue_Name__c FROM Case_Entitlement_Assignment__mdt WHERE Queue_Name__c IN :queueNames]) {
            assignmentMap.put(cea.Queue_Name__c, cea.Entitlement_Code__c);
            entitlementCodes.add(cea.Entitlement_Code__c);
        }

        for (Entitlement e : [SELECT Id, Entitlement_Code__c FROM Entitlement WHERE Entitlement_Code__c IN :entitlementCodes]) {
            entitlementMap.put(e.Entitlement_Code__c, e.Id);
        }

        for (Case c : newValues) {
            if (entitlementMap.get(assignmentMap.get(queuesMap.get(c.OwnerId))) != null) {
                caseEntitlementMap.put(c.Id, entitlementMap.get(assignmentMap.get(queuesMap.get(c.OwnerId))));
            }
            else {
                caseEntitlementMap.put(c.Id, null);
            }
        }

        return caseEntitlementMap;
    }

    /**
     * @description Updates the case contact to the current running user's contact (if created by a BBSI employee)
     * Updates the case branch to the new contact.accountId
     * @param  newValues List of Cases to review
    **/
    public static void addCreatedByAsContact(List<Case> newValues){
        Id branchUseRecordTypeId = RecordTypeService.getId('Case','Branch Use');
        Id systemGeneratedRecordTypeId = RecordTypeService.getId('Case','System Generated');
        Id BBSIEmployeeRecordTypeId = RecordTypeService.getId('Contact','BBSI Employee');
        Boolean contactNull = false;
        Id currentUser = System.UserInfo.getUserId();
        List<Contact> currentUserContact = new List<Contact>();

        // Check if contact is null on the case. set the account to the branch
        for (Case c : newValues) {
            if (c.ContactId == null && c.RecordTypeId != branchUseRecordTypeId && c.RecordTypeId != systemGeneratedRecordTypeId && c.Origin != UNVERIFIED_EMAIL && !c.Skip_Automation__c) {
                contactNull = true;
            }

            //#TODO: if record type is client/referral partner, then the accountId should remain as the client/referral partner, not the branch

            if (c.AccountId == null) {
                c.AccountId = c.Branch__c;
            }
        }

        if(contactNull){
            currentUserContact = [SELECT Id, User_Id__c, AccountId, RecordTypeId FROM Contact WHERE RecordTypeId = :BBSIEmployeeRecordTypeId AND User_Id__c = :currentUser LIMIT 1];

            for(Case c : newValues){
                if (c.ContactId == null && currentUserContact.size() > 0 && c.RecordTypeId != branchUseRecordTypeId && c.RecordTypeId != systemGeneratedRecordTypeId && c.Origin != UNVERIFIED_EMAIL && !c.Skip_Automation__c) {
                    c.ContactId = currentUserContact[0].Id;
                    if (currentUserContact[0].AccountId != null && c.Branch__c == null) {
                        c.Branch__c = currentUserContact[0].AccountId;
                        //#TODO: if record type is client/referral partner, then the accountId should remain as the client/referral partner, not the branch
                        c.AccountId = currentUserContact[0].AccountId;
                    }
                }
            }
        }
    }

    /**
     * @description addContactsToCaseTeam
     * if contact is changed, has a user ID, and is not already a member of the case team, then add the new contact's user to the case team as viewer & notifications role
     * if contact is changed, has a user ID, is already a member of the case team but is viewer only, then change the new contact's user's role to viewer & notifications role
     * #TODO: add createdbycontact to the case team (if bbsi employee is creating on behalf of someone else). May include a call in the addcreatedbyascontact method
     * @param  newValues Map Ids to  new Case values
     * @param  oldValues Map Ids to previous Case values
    **/
    public static void addContactsToCaseTeam(Map<id,Case> newValues, Map<id,Case> oldValues) {
        Id branchUserRecordTypeId = RecordTypeService.getId('Case', 'Branch Use');
        Id bbsiEmployessContactRecordTypeId = RecordTypeService.getId('Contact', 'BBSI Employee');
        List<CaseTeamMember> listCaseTeamMembersToInsert = new List<CaseTeamMember>();
        List<CaseTeamMember> listCaseTeamMembersToUpdate = new List<CaseTeamMember>();
        List<CaseTeamMember> listCaseTeamMembersToAddOrUpdate = new List<CaseTeamMember>();
        Map<String, Id> mapCaseTeamRole = new Map<String, Id>();
        Map<String, CaseTeamMember> mapExistingCaseTeamMembers = new Map<String, CaseTeamMember>();
        Map<Id, Id> mapContactIdToUserId = new Map<Id, Id>();
        Boolean isInsert = false;

        if (oldValues == null) {
            isInsert = true;
        }

        // Only perform the work done below if needed.
        Boolean doProcess = false;

        if (isInsert) {
            doProcess = true;
        }
        else {
            for (Case newCase : newValues.Values()) {
                Case oldCase = oldValues.get(newCase.Id);
                if (newCase.ContactId != null && oldCase.ContactId != null && newCase.ContactId != oldCase.ContactId) {
                    doProcess = true;
                    break;
                }
            }
        }

        if (!doProcess) {
            return;
        }

        // Get User Ids for the Contacts
        if (isInsert) {
           mapContactIdToUserId =  getUserIdsFromContacts(newValues.values(), true);
        }
        else {
            List<Case> listCases = new List<Case>();
            listCases.addALL(newValues.values());
            listCases.addALL(oldValues.values());
            mapContactIdToUserId =  getUserIdsFromContacts(listCases, true);
        }

        // Get Case Team Members that already exist
        for (CaseTeamMember ctm : [SELECT Id, ParentId, MemberId, TeamRoleId FROM CaseTeamMember WHERE ParentId IN :newValues.keyset()]) {
            String uniqueKey = String.valueOf(ctm.ParentId) + String.valueOf(ctm.MemberId);
            mapExistingCaseTeamMembers.put(uniqueKey, ctm);
        }

        for (Case updatedCase : newValues.Values()) {
            if (isInsert) {
                if (updatedCase.ContactId != null && updatedCase.RecordTypeId != branchUserRecordTypeId) {
                    CaseTeamMember caseTeamMemberToAddOrUpdate = createCaseTeamMember(updatedCase, mapExistingCaseTeamMembers, mapContactIdToUserId);
                    if (caseTeamMemberToAddOrUpdate.MemberId != null) {
                        listCaseTeamMembersToAddOrUpdate.add(caseTeamMemberToAddOrUpdate);
                    }
                }
            }
            else {
                Case oldCase = oldValues.get(updatedCase.Id);

                if (oldCase != null && updatedCase.ContactId != null && oldCase.ContactId != null && updatedCase.ContactId != oldCase.ContactId && updatedCase.RecordTypeId != branchUserRecordTypeId ) {
                    CaseTeamMember caseTeamMemberToAddOrUpdate = createCaseTeamMember(oldCase, mapExistingCaseTeamMembers, mapContactIdToUserId);
                    if (caseTeamMemberToAddOrUpdate.MemberId != null) {
                        listCaseTeamMembersToAddOrUpdate.add(caseTeamMemberToAddOrUpdate);
                    }
                }

                if (updatedCase.ContactId != null && updatedCase.RecordTypeId != branchUserRecordTypeId) {
                    CaseTeamMember caseTeamMemberToAddOrUpdate = createCaseTeamMember(updatedCase, mapExistingCaseTeamMembers, mapContactIdToUserId);
                    if (caseTeamMemberToAddOrUpdate.MemberId != null) {
                        listCaseTeamMembersToAddOrUpdate.add(caseTeamMemberToAddOrUpdate);
                    }
                }
            }
        }

        for (CaseTeamMember ctm : listCaseTeamMembersToAddOrUpdate) {
            if (ctm.Id != null) {
                listCaseTeamMembersToUpdate.add(ctm);
            }
            else if (ctm != null) {
               listCaseTeamMembersToInsert.add(ctm);
            }
        }

        if (listCaseTeamMembersToUpdate.size() > 0) {
            isUpdatingCaseTeamMembers = true;
            update listCaseTeamMembersToUpdate;
            isUpdatingCaseTeamMembers = false;
        }

        if (listCaseTeamMembersToInsert.size() > 0) {
            isUpdatingCaseTeamMembers = true;
            insert listCaseTeamMembersToInsert;
            isUpdatingCaseTeamMembers = false;
        }
    }

    /**
     * @description getUserIdsFromContacts gets User Ids from the Case Contacts.
     * @param  listCases  List of Cases looking at
     * @param  activeOnly Only retrieve active Users?
     * @return Map of Case Id to User Id
     */
    private static Map<Id, Id> getUserIdsFromContacts(List<Case> listCases, Boolean activeOnly) {
        Map<Id, Id> mapContactIdToUserId = new Map<Id, Id>();
        Set<Id> setCaseContactIds = new Set<Id>();
        Id bbsiEmployessContactRecordTypeId = RecordTypeService.getId('Contact', 'BBSI Employee');

        for (Case c : listCases) {
            if (c.ContactId != null) {
                setCaseContactIds.add(c.ContactId);
            }
        }

        if (setCaseContactIds.size() > 0) {
            for (Contact c : [SELECT Id, User_Id__c FROM Contact WHERE Id IN :setCaseContactIds AND RecordTypeId = :bbsiEmployessContactRecordTypeId ]) {
                if (c.User_Id__c != null) {
                    mapContactIdToUserId.put(c.Id, c.User_Id__c);
                }
            }
        }

        if (activeOnly && !mapContactIdToUserId.isEmpty()) {
            Set<Id> idUsers = new Set<Id>();
            for (Id idU : mapContactIdToUserId.values()) {
                idUsers.add(idU);
            }

            Map<Id, User> inactiveUsers = new Map<Id, User>([SELECT Id, Name FROM User WHERE IsActive = false AND Id IN :idUsers]);

            for (Id idContact : mapContactIdToUserId.keySet()) {
                if (inactiveUsers.containsKey(mapContactIdToUserId.get(idContact))) {
                    mapContactIdToUserId.remove(idContact);
                }
            }
        }

        return mapContactIdToUserId;
    }

    /**
     * @description createCaseTeamMember description
     * @param  currentCase                Case looking at
     * @param  mapExistingCaseTeamMembers Current team members
     * @param  mapContactIdToUserId       Contact Ids to User Ids
     * @return A new CaseTeamMember to insert
     */
    @TestVisible
    private static CaseTeamMember createCaseTeamMember(Case currentCase, Map<String, CaseTeamMember> mapExistingCaseTeamMembers, Map<Id, Id> mapContactIdToUserId) {
        CaseTeamMember caseTeamMemberToAdd = new CaseTeamMember();
        Id caseViewerTeamRole = CaseTeamMember_Services.getCaseTeamRoleByName('Viewer');
        Id caseViewerAndNotificationsTeamRole = CaseTeamMember_Services.getCaseTeamRoleByName('Viewer & Notifications');

        if (currentCase != null && mapContactIdToUserId != null && caseViewerTeamRole != null && caseViewerAndNotificationsTeamRole != null) {
            String uniqueKey = String.valueOf(currentCase.Id) + String.valueOf(mapContactIdToUserId.get(currentCase.ContactId));
            if (mapExistingCaseTeamMembers == null || !mapExistingCaseTeamMembers.containsKey(uniqueKey)) {
                Id caseTeamMemberId = mapContactIdToUserId.get(currentCase.ContactId);
                caseTeamMemberToAdd = new CaseTeamMember(ParentId = currentCase.Id, MemberId = caseTeamMemberId, TeamRoleId = caseViewerAndNotificationsTeamRole);
            }
            else if (mapExistingCaseTeamMembers != null && mapExistingCaseTeamMembers.containsKey(uniqueKey)) {
                CaseTeamMember existingCaseTeamMember = mapExistingCaseTeamMembers.get(uniqueKey);
                if (existingCaseTeamMember.TeamRoleId == caseViewerTeamRole) {
                    existingCaseTeamMember.TeamRoleId = caseViewerAndNotificationsTeamRole;
                    caseTeamMemberToAdd = existingCaseTeamMember;
                }
            }
        }

        return caseTeamMemberToAdd;
    }

    /**
     * @description addOwnerToCaseTeam makes sure the owner of a case is in the team for the Case.
     * @param  newValues Map Ids to  new Case values
     * @param  oldValues Map Ids to previous Case values
     */
    public static void addOwnerToCaseTeam(Map<Id, Case> newValues, Map<Id, Case> oldValues) {
        Id caseViewerAndNotificationsTeamRoleId = CaseTeamMember_Services.getCaseTeamRoleByName('Viewer & Notifications');

        Set<CaseTeamMember> members = new Set<CaseTeamMember>();

        for (Case c : newValues.Values()) {
            if (c.OwnerId.getSobjectType() == User.SobjectType) {
                if (oldValues == null || (c.OwnerId != oldValues.get(c.Id).OwnerId)) {
                    members.add(
                        new CaseTeamMember(
                            ParentId = c.Id,
                            MemberId = c.OwnerId,
                            TeamRoleId = caseViewerAndNotificationsTeamRoleId
                        )
                    );
                }
            }
        }

        if (!members.isEmpty()) {
            database.insert(new List<CaseTeamMember>(members), false);
        }
    }

    /**
     * @description addUserCreatorToCaseTeam makes sure the creator of a case is in the team for the Case.
     * @param  newValues New Cases
     */
    public static void addUserCreatorToCaseTeam(Map<Id, Case> newValues) {
        Set<Id> userIds = new Set<Id>();
        for (Case c : newValues.Values()) {
            userIds.add(c.CreatedById);
        }

        Id idBBSIEmployee = RecordTypeService.getId('Contact', 'BBSI Employee');
        Id caseViewerAndNotificationsTeamRoleId = CaseTeamMember_Services.getCaseTeamRoleByName('Viewer & Notifications');

        List<User> users = [SELECT Id FROM User WHERE Id IN :userIds];
        List<CaseTeamMember> members = new List<CaseTeamMember>();

        for (Case c : newValues.Values()) {
            for (User u : users) {
                if (c.CreatedById == u.Id) {
                    members.add(
                        new CaseTeamMember(
                            ParentId = c.Id,
                            MemberId = u.Id,
                            TeamRoleId = caseViewerAndNotificationsTeamRoleId
                        )
                    );
                    break;
                }
            }
        }

        if (!members.isEmpty()) {
            insert members;
        }
    }

    /**
     * @description addCaseTeamAsSubscribers gets the current Case Team and adds the Users as
     * subscribors to the Case.
     * @param  newValues mapping of Case Ids to their Case
     */
    public static void addCaseTeamAsSubscribers(Map<Id, Case> newValues) {
        Map<Id, Set<Id>> newFollowers = new Map<Id, Set<Id>>();

        for (Case c : newValues.values()) {
            if (Id_Service.isType(c.OwnerId, 'User')) {
                newFollowers.put(c.Id, new Set<Id>());
                newFollowers.get(c.Id).add(c.OwnerId);
            }
        }

        for (CaseTeamMember ctm : [SELECT Id, ParentId, MemberId
                                   FROM CaseTeamMember
                                   WHERE ParentId IN :newValues.keySet()]) {
            if (Id_Service.isType(ctm.MemberId, 'User')) {
                if (!newFollowers.containsKey(ctm.ParentId)) {
                    newFollowers.put(ctm.ParentId, new Set<Id>());
                }
                newFollowers.get(ctm.ParentId).add(ctm.MemberId);
            }
        }

        EntitySubscription_Service.addSubscribers(newFollowers);
    }

    /**
     * @description unsubscribeFromClosedCase removes all EntitySubscription from a newly closed Case.
     * @param  newValues Cases after change
     * @param  oldValues Cases before change
     */
    public static void unsubscribeFromClosedCase(Map<Id, Case> newValues, Map<Id, Case> oldValues) {
        Set<Id> unsubscribeCaseIds = new Set<Id>();

        for (Case newCase : newValues.values()) {
            Case oldCase = oldValues.get(newCase.Id);
            if (oldCase.Status != newCase.Status && newCase.Status == 'Closed') {
                unsubscribeCaseIds.add(newCase.Id);
            }
        }

        EntitySubscription_Service.removeAllSubscribers(unsubscribeCaseIds);
    }

    /**
     * @description insertSystemGeneratedCase creates and inserts a new System case.
     * @param  subject   Subject for the Case
     * @param  body      Description for the Case
     * @param  accountId Related Account for the Case
     * @return The Case identifier
     */
    public static Id insertSystemGeneratedCase(String subject, String body, Id accountId) {
        Case c = createSystemGeneratedCase(subject, body, accountId);

        insert c;

        return c.Id;
    }

    /**
     * @description createSystemGeneratedCase creates a new System case.
     * @param  subject   Subject for the Case
     * @param  body      Description for the Case
     * @param  accountId Related Account for the Case
     * @return The Case identifier
     */
    public static Case createSystemGeneratedCase(String subject, String body, Id accountId) {
        Id idCurrentUser = UserInfo.getUserId();
        Map<Id, Id> mapUserContact = User_Services.getRelatedContactIds(new Set<Id>{ idCurrentUser });

        Case c = new Case(
            AccountId = accountId,
            Subject = subject,
            Description = body,
            Status = 'New',
            Priority = 'High',
            Type = 'Issue',
            Origin = 'System Generated',
            ContactId = mapUserContact.get(idCurrentUser),
            RecordTypeId = RecordTypeService.getId('Case', 'System Generated'),
            Skip_Automation__c = Test.isRunningTest()
        );

        return c;
    }

    /**
     * @description blockOwnerAssignment stops cases from being owned by specific users.  At present, only
     * System Administrator may not be re-assigned a Case, unless assigned by a  AdminisSystemtrator.
     * @param  oldValues Map Id to previous Case values
     * @param  newValues List new Case values
     */
    public static void blockOwnerAssignment(Map<Id, Case> oldValues, List<Case> newValues) {
		// FUTURE: Use Custom Permissions: Case Assignment Manager and Case Assignment Manager
        if (!Profile_Service.isSystemAdministrator(UserInfo.getProfileId())) {
            List<Case> changedCases = new List<Case>();
            Set<Id> idOwners = new Set<Id>();

            for (Case c : newValues) {
                if (c.OwnerId != oldValues.get(c.Id).OwnerId) {
                    changedCases.add(c);
                    idOwners.add(c.OwnerId);
                }
            }

            if (!changedCases.isEmpty()) {
                Map<Id, User> mapUsers = new Map<Id, User>([SELECT Id, Name, ProfileId FROM User WHERE Id IN :idOwners]);

                for (Case c : newValues) {
                    if (mapUsers.containsKey(c.OwnerId)) {
                        if (Profile_Service.isSystemAdministrator(mapUsers.get(c.OwnerId).ProfileId)) {
                            c.addError('Cannot assign a case to System Administrator ' + mapUsers.get(c.OwnerId).Name + '.');
                        }
                    }
                }
            }
        }
    }
}