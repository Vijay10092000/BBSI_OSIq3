/**
 * ReferralPartnerChange_Service handles actions against the
 * Referral_Partner_Change_Request__c object.
 */
public without sharing class ReferralPartnerChange_Service {

    // BBSI_Commission_Rate__mdt custom metadata for commission rate Calculations
    @TestVisible
    private static List<Referral_Partner_Commissions__mdt> referral_Partner_Commissions = new List<Referral_Partner_Commissions__mdt>();
    @TestVisible
    private static Referral_Partner_Commissions__mdt default_Referral_Partner_Commissions = new Referral_Partner_Commissions__mdt();
    // Map of all mapGroups working on
    @TestVisible
    private static Map<Id, Account> mapAccounts = new Map<Id, Account>();
    /**
     * checkAutoApprove determines if the Referral Partner Change Request should have
     * its Status changed to "Approved".
     * Used in Referral Partner Change Request Trigger Handler Before-Insert
     * @param  mapOld Map of old SObject values being changed (null if insert)
     * @param  listNew List of newly created records
     */
    public static void checkAutoApprove(Map<Id, Referral_Partner_Change_Request__c> mapOld, List<Referral_Partner_Change_Request__c> listNew) {
        Set<Id> idUsers = PermissionSet_Service.getUsersWithCustomPermission('Auto_Approve_Referral_Partner_Change_Request');

        for (Referral_Partner_Change_Request__c rpcr : listNew) {
            if (rpcr.Status__c == 'Pre-Approval' && idUsers.contains(rpcr.OwnerId)) {
                rpcr.Status__c = 'Approved';
            }
        }
    }

    /**
     * US:51029:rpcrPopulateValues for Pre Populate RPCR Field Values.    
     * @param  mapOld Map of old SObject values being changed (null if insert)
     * @param  listNew List of newly created records
     */
    public static void rpcrPopulateValues(List<Referral_Partner_Change_Request__c> listNew) {
        commissionRates(listNew);  
    }
    
    /**
     * US:51029:commissionRates for based on Custom Metadate table will return Commission Rate and Commission Type.    
     * @param  listNew List of newly created records
     */
    private static void commissionRates(List<Referral_Partner_Change_Request__c> listNew) {
        retrieveRelatedData(listNew);
        List<Referral_Partner_Change_Request__c> listToUpdateCommissions =  new List<Referral_Partner_Change_Request__c>();
        for (Referral_Partner_Change_Request__c record : listNew) {
            if (record.RecordTypeId != ReferralPartnerChange_Const.idrtCommissionChangeRP 
            && record.RecordTypeId != ReferralPartnerChange_Const.idrtOverrideClient
            && record.RecordTypeId != ReferralPartnerChange_Const.idrtRPGroupChange) {
                listToUpdateCommissions.add(record);
            }
        }
        for (Referral_Partner_Change_Request__c record : listToUpdateCommissions) {
            if(record.RecordTypeId == ReferralPartnerChange_Const.idrtRPOR || record.RecordTypeId == ReferralPartnerChange_Const.idrtRPReqActiv || record.RecordTypeId == ReferralPartnerChange_Const.idrtReleaseHoldRP || record.RecordTypeId == ReferralPartnerChange_Const.idrtReleaseHoldClient){
                if(record.Product_Line__c == ReferralPartnerChange_Const.PLTYPE_BENEFITS){
                    Account client = (record.Client__c != NULL) ? mapAccounts.get(record.Client__c): new Account();
                    //Boolean isPrimary = ((client.Benefits_Affiliates_Type__c == null || client.Benefits_Affiliates_Type__c == 'Primary') && client.BBSI_Benefits__c);
                    client.Is_there_a_benefits_referral_partner__c = 'Yes';
                    Referral_Partner_Commissions__mdt commissionRate = ReferralPartnerChange_Process.getMatchingCommission(client, record.Product_Line__c);
                    record.Commission_Rate__c = commissionRate.Commission_Rate__c;
                    record.Commission_Type__c = commissionRate.Commission_Type__c;
                }
                else{
                    if(record.Referral_Partner__c != null && mapAccounts.containsKey(record.Referral_Partner__c)){
                        Account rp = mapAccounts.get(record.Referral_Partner__c);
                        record.Commission_Rate__c = rp.Commission_Rate__c;
                        record.Commission_Type__c  = rp.Commission_Type__c;
                    }                    
                }
            }
            else if(record.RecordTypeId == ReferralPartnerChange_Const.idrtHoldRP || record.RecordTypeId == ReferralPartnerChange_Const.idrtHoldClient){
                if(record.Product_Line__c == ReferralPartnerChange_Const.PLTYPE_BENEFITS){
                    record.Commission_Rate__c = default_Referral_Partner_Commissions.Commission_Rate__c;
                    record.Commission_Type__c  = default_Referral_Partner_Commissions.Commission_Type__c;
                }
                else{
                    record.Commission_Rate__c = default_Referral_Partner_Commissions.Commission_Rate__c;
                    record.Commission_Type__c  = ReferralPartnerChange_Const.DEFAULTWORKCOMPTYPE;
                }
            }
        }
    }
    /**
     * US:51029:
     * @description retrieveRelatedData sets up some of the class variables for
     * use in the other
     * @param  rpcrs
     */
    @TestVisible
    private static void retrieveRelatedData(List<Referral_Partner_Change_Request__c> rpcrs) {
        Set<Id> ids = getAccountIds(rpcrs);
        getAccountData(ids);
        ReferralPartnerChange_Process.getRPCommissions();
        referral_Partner_Commissions = ReferralPartnerChange_Process.referral_Partner_Commissions;
        default_Referral_Partner_Commissions = ReferralPartnerChange_Process.default_Referral_Partner_Commissions;        
    }
    /**
     * US:51029:
     * @description getAccountIds runs through the given rpcrs and finds Client
     * and Referral Partner account ids.
     * @param  rpcrs
     * @return A set of Account ids
     */
    @TestVisible
    private static Set<Id> getAccountIds(List<Referral_Partner_Change_Request__c> rpcrs) {
        Set<Id> ids = new Set<Id>();

        for (Referral_Partner_Change_Request__c rpcr : rpcrs) {
            if (rpcr.Client__c != null) {
                ids.add(rpcr.Client__c);
            }
            if (rpcr.Referral_Partner__c != null) {
                ids.add(rpcr.Referral_Partner__c);
            }
        }

        return ids;
    }
    
    /**
     * US:51029:
     * @description getAccountData retrieves Account information for the
     * given Account ids.  The data is placed in mapRpToClients and MapRps.
     * @param  ids  Account ids lookin for
     */
    @TestVisible
    private static void getAccountData(Set<Id> ids) {  
        mapAccounts = Account_Services.getAccountsMap(ids);
    }
    
    /**
     * US:48733:requestActivationRPCRChanges determines on New Request Activation RPCR,
     * Clearing Client Field
     * Used in Referral Partner Change Request Trigger Handler Before-Insert
     * @param  mapOld Map of old SObject values being changed (null if insert)
     * @param  mapNew Map of new SObject values being created
     */
    public static void requestActivationRPCRChanges(Map<Id, Referral_Partner_Change_Request__c> mapOld, List<Referral_Partner_Change_Request__c> listNew) {
        for (Referral_Partner_Change_Request__c rpcr : listNew) {
            if (rpcr.Client__c != null && rpcr.RecordTypeId == ReferralPartnerChange_Const.idrtRPReqActiv) {
                rpcr.Client__c = null;
            }
        }
    }
    

    /**
     * US-48735:checkApproved(oldName:checkApproved) changes Referral Sources as needed for newly
     * approved Referral_Partner_Change_Request__cs.
     * Used in Referral Partner Change Request Trigger Handler After-Insert and After-Update
     * When a RCPR  with record type 'Request Activation' is submitted for approval, 
     * the Referral Partner Status (referral_partner_status__c) should change to 'Submitted'.    
     * If the Approval Request is Approved, Referral Partner Status on Referral Partner Account is set to Active.
	 * If the Approval Request is rejected, Referral Partner Status on Referral Partner Account is set to Not Approved.
     * @param  mapOld Map of old SObject values being changed (null if insert)
     * @param  mapNew Map of new SObject values being created
     */
       
     public static void checkApproved(Map<Id, Referral_Partner_Change_Request__c> mapOld, Map<Id, Referral_Partner_Change_Request__c> mapNew){
        List<Id> rpcrIdList = new List<Id>();
        for (Referral_Partner_Change_Request__c rpcr : mapNew.values()) {
            if (rpcr.Status__c == 'Approved' && rpcr.Effective_Date__c <= System.today()
                && (mapOld == null || mapOld.get(rpcr.Id).Status__c == 'Pending Approval')) {
                rpcrIdList.add(rpcr.id);
            }
            else if(rpcr.RecordTypeId == ReferralPartnerChange_Const.idrtRPReqActiv && rpcr.Referral_Partner__c != null 
                && (mapOld == null || mapOld.get(rpcr.Id).Status__c != rpcr.Status__c)){
                if(rpcr.Status__c == 'Pending Approval' || rpcr.Status__c == 'Rejected'){
                    rpcrIdList.add(rpcr.id);
                }
            }
        }   
        if (!rpcrIdList.isEmpty()) {
            updateReferralSources(rpcrIdList);
        }  
    }

    /**
     * futureUpdateReferralSources updates the Referral Sources based on
     * the change requests given.
     * @param  idRequests List of Referral_Partner_Change_Request__c Ids
     */
    @future
    public static void futureUpdateReferralSources(List<Id> idRequests) {
        updateReferralSources(idRequests);
    }

    /**
     * updateReferralSources looks at the given list of requests
     * and checks if the Referral Source matches them.  If not, the Referral
     * Source is updated.
     * Called from a Scheduled Batch process and futureUpdateReferralSources.
     * @param  requests List of Referral_Partner_Change_Request__cs to work on
     */
    public static void updateReferralSources(List<Id> idRequests) {
        if (idRequests != null && !idRequests.isEmpty()) {
            Map<Id, Referral_Partner_Change_Request__c> requests = getChangeRequests(idRequests);

            ReferralPartnerChange_Process rpcProcess = new ReferralPartnerChange_Process();
            rpcProcess.execute(requests.values());
        }
    } 

    /**
     * getRequests retrieves the Change Requests for the given Referral
     * Partner and Client Account Ids.
     * @param  idAccounts Referral Partner or Client Account Ids
     * @return Map relating RP ids to Change Requests
     */
    public static Map<Id, List<Referral_Partner_Change_Request__c>> getRequests(List<Id> idAccounts) {
        Map<Id, List<Referral_Partner_Change_Request__c>> results = new Map<Id, List<Referral_Partner_Change_Request__c>>();

        for (Id id :idAccounts) {
            results.put(id, new List<Referral_Partner_Change_Request__c>());
        }

        for (Referral_Partner_Change_Request__c rpcr : [
            SELECT Id, Name, Status__c, CreatedById, Override__c, Client__c, Referral_Partner_Group__c,
                Comments__c, Commission_Rate__c, Commission_Type__c, Effective_Date__c, Producer__c,
                Record_Type__c, RecordTypeId, RecordType.Name, Referral_Partner__c, Product_Line__c
            FROM Referral_Partner_Change_Request__c
            WHERE Referral_Partner__c IN :idAccounts OR Client__c IN :idAccounts
        ]) {
            if (rpcr.Client__c == null) {
                results.get(rpcr.Referral_Partner__c).add(rpcr);
            }
            else {
                results.get(rpcr.Client__c).add(rpcr);
            }
        }

        return results;
    }

    /**
     * getChangeRequests retrieve the change requests given their identifiers.
     * @param  idRequests Referral_Partner_Change_Request__c indentifers
     * @return Map relating Ids to objects
     */
    public static Map<Id, Referral_Partner_Change_Request__c> getChangeRequests(List<Id> idRequests) {
        return new Map<Id, Referral_Partner_Change_Request__c>([
            SELECT Id, Name, Status__c, CreatedById, Override__c, Client__c, Referral_Partner_Group__c,
                Comments__c, Commission_Rate__c, Commission_Type__c, Effective_Date__c, Producer__c,
                Record_Type__c, RecordTypeId, RecordType.Name, Referral_Partner__c, Product_Line__c FROM Referral_Partner_Change_Request__c
            WHERE Id IN :idRequests
        ]);
    }

    /**
     * sendNotifications sends notifications to the owner of approved or rejected change requests.
     * @param  mapOld Map of old SObject values being changed (null if insert)
     * @param  mapNew Map of new SObject values being created
     */
    public static void sendNotifications(Map<Id, Referral_Partner_Change_Request__c> mapOld, Map<Id, Referral_Partner_Change_Request__c> mapNew) {
        List<Id> notifyOwners = new List<Id>();
        List<Id> notifyRPAs = new List<Id>();

        for (Referral_Partner_Change_Request__c rpcr : mapNew.values()) {
            if (mapOld == null || mapOld.get(rpcr.Id).Notify_RP_Admins__c == false) {
                if (rpcr.Notify_RP_Admins__c == true) {
                    notifyRPAs.add(rpcr.Id);
                }
            }
//
            if (mapOld != null && mapOld.get(rpcr.Id).Status__c == 'Pending Approval') {
                if (rpcr.Status__c == 'Approved') {
                    notifyOwners.add(rpcr.Id);
                }
                else if (rpcr.Status__c == 'Rejected') {
                    notifyOwners.add(rpcr.Id);
                }
            }
        }

        if (!notifyRPAs.isEmpty()) {
            sendNotificationRPAdmins(notifyRPAs);
        }

        if (!notifyOwners.isEmpty()) {
            sendNotificiationsToOwners(notifyOwners);
        }
    }

    /**
     * sendNotificationRPAdmins sends custom notification to the members of the Referral Partner Group
     * Future call is needed because Notifications cannot be performed during a trigger call.
     * You will receive: System.CalloutException: Callout from triggers are currently not supported.
     * @param  notifyRPAs List of requests
     */
    @future(callout=true)
    public static void sendNotificationRPAdmins(List<Id> idRpcrs) {
        List<Referral_Partner_Change_Request__c> rpcrs = [
            SELECT Id, OwnerId, Name
            FROM Referral_Partner_Change_Request__c
            WHERE Id IN :idRpcrs
        ];

        Id idRpaGroup = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'Referral_Partner_Admin' LIMIT 1].Id;

        Notification_Service service = new Notification_Service();

        for (Referral_Partner_Change_Request__c rpcr : rpcrs) {
            service.addNotify(RPCR_NOTIFICATION, new List<Id>{ idRpaGroup }, 'Requesting an approval for referral partner change request', rpcr.Name, rpcr.Id);
        }

		sendNotifications(service);
    }

    // Name of the Referral Partner Change Request object
    private static final String RPCR_CLASSNAME = 'Referral_Partner_Change_Request__c';

    // Name of the Custom Notification for Referral Partener Change Requests
    private static final String RPCR_NOTIFICATION = 'Referral Partner Change Request';

    /**
     * sendNotificiationsToOwners sends custom notification to the owners of the given requests which
     * have recently been approved or rejected.
     * Future call is needed because Notifications cannot be performed during a trigger call.
     * You will receive: System.CalloutException: Callout from triggers are currently not supported.
     * @param  rpcrs List of requests
     */
    @future(callout=true)
    public static void sendNotificiationsToOwners(List<Id> idRpcrs) {
        List<Referral_Partner_Change_Request__c> rpcrs = [
            SELECT Id, RecordTypeId, OwnerId, Name, Status__c, Client__c, Referral_Partner__c, Referral_Partner_Group__c
            FROM Referral_Partner_Change_Request__c
            WHERE Id IN :idRpcrs
        ];

        Set<Id> ids = new Set<Id>();

        for (Referral_Partner_Change_Request__c rpcr : rpcrs) {
            ids.add(rpcr.Client__c);
            ids.add(rpcr.Referral_Partner__c);
            ids.add(rpcr.Referral_Partner_Group__c);
        }
        ids.remove(null);

        Map<Id, Account> accounts = new Map<Id, Account>([
            SELECT Id, Name FROM Account WHERE Id IN :ids
        ]);

        Map<Id, Referral_Partner_Group__c> groups = new Map<Id, Referral_Partner_Group__c>([
            SELECT Id, Name FROM Referral_Partner_Group__c WHERE Id IN :ids
        ]);

        Notification_Service service = new Notification_Service();

        for (Referral_Partner_Change_Request__c rpcr : rpcrs) {
            String message = createNotificiationMessage(rpcr, accounts, groups);

            service.addNotify(RPCR_NOTIFICATION, new List<Id>{ rpcr.OwnerId }, 'Referral Partner Change Request ' + rpcr.Status__c, message, rpcr.Id);
        }

		sendNotifications(service);
    }

	private static void sendNotifications(Notification_Service service) {
        // When running a test with Notification_Service, a mock response is required.  Instead, the call is blocked.
        if (!Test.isRunningTest()) {
            service.sendNotifications();
        }
	}

    /**
     * Added:US-48980: RPCR Request Activation Changes
     * createNotificiationMessage creates a message for the notification based on the type
     * of request made.
     * @param  rpcr Referral_Partner_Change_Request__c referring to
     * @return The message for the notification
     */
	@TestVisible
    private static String createNotificiationMessage(Referral_Partner_Change_Request__c rpcr, Map<Id, Account> accounts, Map<Id, Referral_Partner_Group__c> groups) {
        String message = null;
        String status = rpcr.Status__c;

        if (status == 'Performed') {
            status = 'Approved';
        }

        if (rpcr.RecordTypeId == RecordTypeService.getId(RPCR_CLASSNAME, 'Commission Change - Referral Partner')) {
            message = 'The commission change request for referral partner ' + accounts.get(rpcr.Referral_Partner__c).Name + ' has been ' + status;
        }
        else if (rpcr.RecordTypeId == RecordTypeService.getId(RPCR_CLASSNAME, 'Group Commission Change')) {
            message = 'The group commission change request for the group ' + groups.get(rpcr.Referral_Partner_Group__c).Name + ' has been ' + status;
        }
        else if (rpcr.RecordTypeId == RecordTypeService.getId(RPCR_CLASSNAME, 'Hold Request - Client')) {
            message = 'The hold request for the client ' + accounts.get(rpcr.Client__c).Name + ' has been ' + status;
        }
        else if (rpcr.RecordTypeId == RecordTypeService.getId(RPCR_CLASSNAME, 'Hold Request - Referral Partner')) {
            message = 'The hold request for the referral partner ' + accounts.get(rpcr.Referral_Partner__c).Name + ' has been ' + status;
        }
        else if (rpcr.RecordTypeId == RecordTypeService.getId(RPCR_CLASSNAME, 'Override Request - Client')) {
            message = 'The override request for the client ' + accounts.get(rpcr.Client__c).Name + ' has been ' + status;
        }
        else if (rpcr.RecordTypeId == RecordTypeService.getId(RPCR_CLASSNAME, 'Release Hold - Client')) {
            message = 'The release hold request for the client ' + accounts.get(rpcr.Client__c).Name + ' has been ' + status;
        }
        else if (rpcr.RecordTypeId == RecordTypeService.getId(RPCR_CLASSNAME, 'Release Hold - Referral Partner')) {
            message = 'The release hold request for the referral partner ' + accounts.get(rpcr.Referral_Partner__c).Name + ' has been ' + status;
        }
        else if (rpcr.RecordTypeId == RecordTypeService.getId(RPCR_CLASSNAME, 'RPOR Change - Client')) {
            message = 'The RPOR change request for the client ' + accounts.get(rpcr.Client__c).Name + ' has been ' + status;
        }
		else if (rpcr.RecordTypeId == ReferralPartnerChange_Const.idrtRPReqActiv) {
            message = 'The Request Activation for the referral partner ' + accounts.get(rpcr.Referral_Partner__c).Name + ' has been ' + status;
        }
        else {
			message = 'Request Status: ' + status;
		}
		
        return message;
    }

}