/**
 * @description ReferralPartnerChange_Process works through a list of Referral
 * Partner Change Requests updating and inserting Referral Sources.  Referral
 * Partners and Clients may be updated as well.
 */
public without sharing class ReferralPartnerChange_Process {

    // Current Referral_Partner_Change_Request__c processing
    @TestVisible
    private Referral_Partner_Change_Request__c workRpcr;

    // Current Referral Sources related to the Referral_Partner_Change_Request__c processing
    @TestVisible
    private List<Referral_Partner__c> workReferralSources;

    // Current Account working on
    @TestVisible
    private Account workAccount;

    // Today's date
    private Date workDate = Date.today();

    // List of Referral Sources changed or created
    @TestVisible
    private Set<Referral_Partner__c> changedReferralSources = new Set<Referral_Partner__c>();

    // List of Groups needing change or insert
    @TestVisible
    private Set<Referral_Partner_Group__c> changedGroups = new Set<Referral_Partner_Group__c>();

    // List of Accounts needing change or insert
    @TestVisible
    private Set<Account> changedAccounts = new Set<Account>();

    // List of changed Referral_Partner_Change_Request__c
    @TestVisible
    private Set<Referral_Partner_Change_Request__c> changedRpcr = new Set<Referral_Partner_Change_Request__c>();

    // Map of all mapGroups working on
    @TestVisible
    private Map<Id, Referral_Partner_Group__c> mapGroups;

    // Map of all Accounts working on
    @TestVisible
    private Map<Id, Account> mapAccounts;
    
    // Map of all Referral Partner Accounts working on
    @TestVisible
    private Map<Id, Account> mapRPAccounts;

    // Map relating Referral Partner to List of their Clients
    @TestVisible
    private Map<Id, List<Account>> mapRpToClients;
    // Map relating Referral Partner to List of their Clients
    @TestVisible
    private Map<Id, List<Account>> mapBenefitsRpToClients;
    @TestVisible
    private Map<Id, List<Account>> mapAffiliatedClients;
    @TestVisible
    private String exceptionText = '';

    // Map of Referral Partners
    @TestVisible
    private Map<Id, Account> mapRps;

    // Map of Account Id to List of Referral Sources related to them
    @TestVisible
    private Map<Id, List<Referral_Partner__c>> mapAccountToReferralSources;   
    @TestVisible
    private Map<Id, List<Referral_Partner__c>> mapActiveReferralSources;   
    @TestVisible  
	private Map<Id, List<Referral_Partner__c>> mapAllAccountToReferralSources;

    @TestVisible
    private Map<Id, Benefits__c> mapBenefits = new Map<Id,Benefits__c>();

    // BBSI_Commission_Rate__mdt custom metadata for commission rate Calculations
    @TestVisible
    public static List<Referral_Partner_Commissions__mdt> referral_Partner_Commissions = new List<Referral_Partner_Commissions__mdt>();
    @TestVisible
    public static Referral_Partner_Commissions__mdt default_Referral_Partner_Commissions = new Referral_Partner_Commissions__mdt();
    

    /**
     * Added:US-48735: RPCR Request Activation Changes
     * @description execute processes the given requests
     * @param  rpcrs Requests to process
     */
    public void execute(List<Referral_Partner_Change_Request__c> rpcrs) {        
        retrieveRelatedData(rpcrs);

        for (Referral_Partner_Change_Request__c rpcr : rpcrs) {            
            try {
                if (rpcr.Status__c == 'Approved' && rpcr.Effective_Date__c <= workDate) {
                    workRpcr = rpcr;

                    if (workRpcr.Client__c != null) {
                        workAccount = mapAccounts.get(workRpcr.Client__c);
                        process();
                    }
                    else if (workRpcr.Referral_Partner__c != null) {
                        workAccount = mapAccounts.get(workRpcr.Referral_Partner__c);
                        if (workAccount.Referral_Partner_Status__c == 'Active' || (workAccount.Referral_Partner_Status__c != 'Active' && workRpcr.RecordTypeId == ReferralPartnerChange_Const.idrtRPReqActiv )) {
                            process();
                        }
                    }
                    else if (workRpcr.Referral_Partner_Group__c != null) {
                        process();
                    }
                    else {
                        System.debug(LoggingLevel.ERROR, 'Invalid Referrence on Referral Partner Change Request');
                    }
                } 
                if (rpcr.RecordTypeId == ReferralPartnerChange_Const.idrtRPReqActiv && rpcr.Referral_Partner__c != null) {
                    workRpcr = rpcr;
                    if(rpcr.Status__c == 'Pending Approval'){
                        process();
                    }
                    else if(rpcr.Status__c == 'Rejected'){
                        process();
                    }
                }
            }
            catch (Exception e) {
                addExceptionMessage(e, rpcr);
            }
        }
        throwExceptionOnError(exceptionText, rpcrs);        

        String errorText = makeDatabaseChanges();
        throwExceptionOnError(errorText, rpcrs);
    }

    /**
     * @description throwExceptionOnError throws and exception if there is "error" text.
     * @param  exceptionText Error text to throw
     * @param  rpcrs         List of change requests
     */
    @TestVisible
    private void throwExceptionOnError(String exceptionText, List<Referral_Partner_Change_Request__c> rpcrs) {
        if (!String.isBlank(exceptionText)) {
            exceptionText = exceptionText + '\n\n' + textChangeRequests(rpcrs);

            Log.error('RPC', 'Referral Partner Change Requests', exceptionText);
            System.debug(LoggingLevel.ERROR, 'ReferralPartnerChange_Process FAIL');
            System.debug(LoggingLevel.ERROR, exceptionText);

            throw new InvalidValueException(exceptionText);
        }
    }

    /**
     * @description makeDatabaseChanges pushes the combined changes to the database.
     * @return null on success, otherwise failure text
     */
    @TestVisible
    private String makeDatabaseChanges() {
        Savepoint sp = Database.setSavepoint();
        String text = null;

        try {
            if (!changedGroups.isEmpty()) {
                List<Database.UpsertResult> results = Database.upsert(new List<Referral_Partner_Group__c>(changedGroups), true);

                text = makeUpsertError('Referral Partner Groups', results);
            }
            
            if (String.isBlank(text) && !changedReferralSources.isEmpty()) {
                List<Database.UpsertResult> results = Database.upsert(new List<Referral_Partner__c>(changedReferralSources), true);

                text = makeUpsertError('Referral Sources', results);
            }

            if (String.isBlank(text) && !changedRpcr.isEmpty()) {
                List<Database.UpsertResult> results = Database.upsert(new List<Referral_Partner_Change_Request__c>(changedRpcr), true);

                text = makeUpsertError('Referral Partner Change Requests', results);
            }
            if (String.isBlank(text) && !mapBenefits.isEmpty()) {
                List<Database.UpsertResult> results = Database.upsert(mapBenefits.values(), true);
            }            
            if (String.isBlank(text) && !changedAccounts.isEmpty()) {
                List<Database.UpsertResult> results = Database.upsert(new List<Account>(changedAccounts), true);

                text = makeUpsertError('Accounts', results);
            }

        } catch (Exception e) {
            text = 'EXCEPTION: ' + e.getMessage();
        }

        if (!String.isBlank(text)) {
            Database.rollback(sp);
        }

        return text;
    }

    /**
     * Added:US-48735: RPCR Request Activation Changes
     * @description process determines how the change request will be handled.
     */
    private void process() {
        if (workAccount != null) {
            workReferralSources = getActiveReferralSources(workAccount.Id);
        }
        else {
            workReferralSources = null;
        }

        if (workRpcr.RecordTypeId == ReferralPartnerChange_Const.idrtGroupComm) {
            changeGroupCommissions();
        }
        else if (workRpcr.RecordTypeId == ReferralPartnerChange_Const.idrtRPGroupChange) {
            changeRPGroupChange();
        }
        else if (workRpcr.RecordTypeId == ReferralPartnerChange_Const.idrtHoldRP) {
            holdReferralPartner(true);
        }
        else if (workRpcr.RecordTypeId == ReferralPartnerChange_Const.idrtReleaseHoldRP) {
            holdReferralPartner(false);
        }
        else if (workRpcr.RecordTypeId == ReferralPartnerChange_Const.idrtCommissionChangeRP) {
            changeCommissionReferralPartner();
        }
        else if (workRpcr.RecordTypeId == ReferralPartnerChange_Const.idrtHoldClient) {
            holdClient(true);
        }
        else if (workRpcr.RecordTypeId == ReferralPartnerChange_Const.idrtReleaseHoldClient) {
            holdClient(false);
        }
        else if (workRpcr.RecordTypeId == ReferralPartnerChange_Const.idrtOverrideClient) {
            overrideClient();
        }
        else if (workRpcr.RecordTypeId == ReferralPartnerChange_Const.idrtRPOR) {
            changeRporClient();
        }
        else if (workRpcr.RecordTypeId == ReferralPartnerChange_Const.idrtRPReqActiv) {
            rpRequestActivation();
        }        
        else {
            throw new InvalidValueException('Referral Partner Change Request (' + workRpcr.Id + ') has an invalid Record Type id (' + workRpcr.RecordTypeId + ')');
        }

        if (workRpcr.RecordTypeId != ReferralPartnerChange_Const.idrtRPReqActiv || workRpcr.Status__c == 'Approved') {
            workRpcr.Status__c = 'Performed';
        }
        changedRpcr.add(workRpcr);
    }

    /**
     * @description changeRPGroupChange updates the Referral Sources.
     */
    private void changeRPGroupChange() {
        if (mapRps.containsKey(workRpcr.Referral_Partner__c)) {
            Account rp = mapRps.get(workRpcr.Referral_Partner__c);
            Id idRPG = workRpcr.Referral_Partner_Group__c;
            String rpgDescription = '';

            if (idRPG != null) {
                Referral_Partner_Group__c rgroup = mapGroups.get(workRpcr.Referral_Partner_Group__c);
                rpgDescription = ReferralPartnerGroup_Service.truncateGroupDescription(rgroup);
            }

            List<Referral_Partner__c> oldRSs = mapAllAccountToReferralSources.get(rp.Id);

            Referral_Partner__c newRS = null;

            if (oldRSs.isEmpty()) {
				System.debug(LoggingLevel.DEBUG, '~!~!~ ReferralPartnerChange_Process.changeRPGroupChange() Create Referral Source because RP does not have one');
                newRS = new Referral_Partner__c();
                newRS.Referral_Partner_Commission_Type__c = rp.Commission_Type__c;
                newRS.Commission_Rate__c = rp.Commission_Rate__c;
				newRS.Referral_Partner__c = rp.Id;
				newRS.RecordTypeId = ReferralSource_Service.idrtClientRP;
				newRS.Referral_Partner_Group__c = idRPG;
				newRS.Group_Description__c = rpgDescription;
				newRS.Effective_Date__c = workRpcr.Effective_Date__c;
				newRS.Termination_Date__c = null;
				newRS.Comments__c = null;
	
				changedReferralSources.add(newRS);
            } else {
				for (Referral_Partner__c rs : oldRSs) {
					rs.Referral_Partner_Group__c = idRPG;
					rs.Group_Description__c = rpgDescription;

					changedReferralSources.add(rs);
				}
            }

            rp.Referral_Partner_Group__c = idRPG;
            changedAccounts.add(rp);

            updateRPClientsGroup(idRPG, rpgDescription);
        }
    }

    /**
     * @description changeGroupCommissions records changes to the commissions on a
     * Referral Partner Group.
     */
    private void changeGroupCommissions() {
        if (mapGroups.containsKey(workRpcr.Referral_Partner_Group__c)) {
            Referral_Partner_Group__c rpGroup = mapGroups.get(workRpcr.Referral_Partner_Group__c);

            if (workRpcr.Commission_Type__c != null) {
                rpGroup.Group_Commission_Type__c = workRpcr.Commission_Type__c;

            }
            if (workRpcr.Commission_Rate__c != null) {
                rpGroup.Group_Commission_Rate__c = workRpcr.Commission_Rate__c;
            }

            changedGroups.add(rpGroup);

            updateGroupRPCommissions();
        }
    }

    /**BUG-63567: The 'hold' checkbox would just need to be marked when the hold request is approved, and unchecked when the release hold request is approved on existing referral source.  No new referral source is needed.
     * @description holdReferralPartner adds or release a Hold on a Referral Partner and marks RP Hold
     * on Related Clients
     * @param setHold true puts a Hold on the Referral Partner, false releases the Hold
     */
    private void holdReferralPartner(Boolean setHold) {
        /*String holdReason = (setHold) ? workRpcr.Comments__c : null;
        List<Referral_Partner__c> tempOldReferralSources = mapActiveReferralSources.containsKey(workRpcr.Referral_Partner__c) ? mapActiveReferralSources.get(workRpcr.Referral_Partner__c) : new List<Referral_Partner__c>();
        //Terminating Old Referral Source
        for (Referral_Partner__c rs : tempOldReferralSources) {
            if (rs.Termination_Date__c == null) {
                rs.Termination_Date__c = workRpcr.Effective_Date__c.addDays(-1);

                if (rs.Termination_Date__c < rs.Effective_Date__c) {
                    rs.Termination_Date__c = rs.Effective_Date__c;
                }                
            }
        }
        if (!sethold) {
            // If releasing a hold on a Referral Partner, "hide" record
            for (Referral_Partner__c rs : tempOldReferralSources) {
                if (rs.RP_On_Hold__c)  {
                    rs.Ignore_Record__c = true;
                }
            }
        }
        changedReferralSources.addAll(tempOldReferralSources);
        List<Referral_Partner__c> newRSs = generateReferralSourcesFromRP(workAccount);

        for (Referral_Partner__c rs : newRSs) {
            rs.Hold_Reason__c = (setHold && !rs.Hold__c) ? holdReason: null;
            rs.RP_On_Hold__c = setHold;
            rs.Effective_Date__c = workRpcr.Effective_Date__c;
        }
        changedReferralSources.addAll(new set<Referral_Partner__c>(newRSs));  
        */
        workReferralSources = mapActiveReferralSources.containsKey(workRpcr.Referral_Partner__c) ? mapActiveReferralSources.get(workRpcr.Referral_Partner__c) : new List<Referral_Partner__c>();
        for (Referral_Partner__c rs : workReferralSources) {
            if(!sethold && rs.RP_On_Hold__c){
                rs.Ignore_Record__c = true;
            }
            rs.RP_On_Hold__c = setHold;
            rs.Hold_Reason__c = (setHold && !rs.Hold__c)?workRpcr.Comments__c:null;    
        }
        changedReferralSources.addAll(workReferralSources);
        workAccount.Hold__c = setHold;
        workAccount.Hold_Effective_Date__c = (setHold) ? workRpcr.Effective_Date__c : (Date) null;
        changedAccounts.add(workAccount);
    }

    /**
     * @description changeCommissionReferralPartner changes the commission data of a Referral Partner.
     */
    private void changeCommissionReferralPartner() {
        List<Referral_Partner__c> newRSs = generateReferralSourcesFromRP(workAccount);
        for (Referral_Partner__c rs : newRSs) {
            rs.Override__c = false;
            rs.Referral_Partner_Commission_Type__c = workRpcr.Commission_Type__c;
            rs.Commission_Rate__c = workRpcr.Commission_Rate__c;
            rs.Effective_Date__c = workRpcr.Effective_Date__c;
        }
        workAccount.Commission_Type__c = workRpcr.Commission_Type__c;
        workAccount.Commission_Rate__c = workRpcr.Commission_Rate__c;
        changedAccounts.add(workAccount);
        changedReferralSources.addAll(new set<Referral_Partner__c>(newRSs));        
        //updateRPClientsCommission();
    }

    /** BUG-63567: The 'hold' checkbox would just need to be marked when the hold request is approved, and unchecked when the release hold request is approved on existing referral source.  No new referral source is needed. 
     * @description holdClient adds or releases a Hold on a Client.
     * @param setHold true puts a Hold on the Client, false releases the Hold
     */
    private void holdClient(Boolean setHold) {        
        /*
        markTerminated(workReferralSources);
        if (!sethold) {
            // If releasing a hold on a Referral Partner, "hide" record
            for (Referral_Partner__c rs : workReferralSources) {
                if (rs.Hold__c)  {
                    rs.Ignore_Record__c = true;
                }
            }
        }
        workReferralSources = createReferralSources(false,workAccount,workRpcr.Product_Line__c);
        
        if(workRpcr.Product_Line__c == ReferralPartnerChange_Const.PLTYPE_WORKERSCOMP){
            if(workRpcr.Referral_Partner__c != null && mapAccounts.containsKey(workRpcr.Referral_Partner__c)){
                Account rp = mapAccounts.get(workRpcr.Referral_Partner__c);
                for (Referral_Partner__c rs : workReferralSources) {
                rs.Referral_Partner_Commission_Type__c = rp.Commission_Type__c;
                rs.Commission_Rate__c = rp.Commission_Rate__c;
                }
            }            
        }
        else if(workRpcr.Product_Line__c == ReferralPartnerChange_Const.PLTYPE_BENEFITS){
            workReferralSources = setCommissionRates(workReferralSources);
        }
        mapAccountToReferralSources.get(workAccount.Id).addAll(workReferralSources);

        for (Referral_Partner__c rs : workReferralSources) {            
            rs.Hold__c = setHold;
            rs.Hold_Reason__c = (setHold)?workRpcr.Comments__c:null;
            rs.Effective_Date__c = workRpcr.Effective_Date__c;
            changedReferralSources.add(rs);
        }
        */
        for (Referral_Partner__c rs : workReferralSources) {
            if(workRpcr.Product_Line__c == rs.Product_Line__c){
                if(!sethold && rs.Hold__c){
                    rs.Ignore_Record__c = true;
                }
                rs.Hold__c = setHold;
                rs.Hold_Reason__c = (setHold)?workRpcr.Comments__c:null;   
                changedReferralSources.add(rs);
            }                  
        }
        workAccount.Hold__c = setHold;
        workAccount.Hold_Effective_Date__c = (setHold) ? workRpcr.Effective_Date__c : (Date) null;

        changedAccounts.add(workAccount);
    }

    /**
     * @description overrideClient places an override on a Client.  If the override has the same
     * values as the Client's Referral Partner, the override is removed.
     */
    private void overrideClient() {
        List<Referral_Partner__c> newRSs = new List<Referral_Partner__c>();
        newRSs = createReferralSources(false,workAccount, workRpcr.Product_Line__c);
            if(newRSs.size()>0){              
                for (Referral_Partner__c rs : newRSs) {
                    Account rp = mapAccounts.get(rs.Referral_Partner__c);
        
                    if (workRpcr.Override__c) {
                        if (rp != null && rp.RecordType.Name == 'Referral Partner') {
                            if (rp.Commission_Type__c == workRpcr.Commission_Type__c && rp.Commission_Rate__c == workRpcr.Commission_Rate__c) {
                                // Override and client type and Rate are same as Referral Partner - becomes no override
                                rs.Override__c = false;
                                rs.Referral_Partner_Commission_Type__c = rp.Commission_Type__c;
                                rs.Commission_Rate__c = rp.Commission_Rate__c;
                            }
                            else {
                                // Override and Client Type or Rates is not same as Referral Partner
                                rs.Override__c = true;
                                rs.Referral_Partner_Commission_Type__c = workRpcr.Commission_Type__c;
                                rs.Commission_Rate__c = workRpcr.Commission_Rate__c;
                            }
                        }
                        else {
                            if (workRpcr.Commission_Rate__c == 0.0) {
                                // No rate set - becomes no override
                                rs.Override__c = false;
                                rs.Referral_Partner_Commission_Type__c = rp.Commission_Type__c;
                                rs.Commission_Rate__c = rp.Commission_Rate__c;
                            }
                            else {
                                // Override and Referral Partner is not "Referral Partner" and rate != 0
                                rs.Override__c = true;
                                rs.Referral_Partner_Commission_Type__c = workRpcr.Commission_Type__c;
                                rs.Commission_Rate__c = workRpcr.Commission_Rate__c;
                            }
                        }
                    }
                    else {
                        // No override or (Client Type and Rate are both default)
                        rs.Override__c = false;
                        rs.Referral_Partner_Commission_Type__c = rp.Commission_Type__c;
                        rs.Commission_Rate__c = rp.Commission_Rate__c;
                    }
        
                    rs.Effective_Date__c = workRpcr.Effective_Date__c;
                }
            }            
            changedReferralSources.addAll(newRSs);
            workReferralSources = newRSs;
            mapAccountToReferralSources.get(workAccount.Id).addAll(newRSs);
    }

    /**
     * @description changeRporClient changes the Referral Partner and/or Producer
     */
    private void changeRporClient() {
        List<Referral_Partner__c> newRSs = new List<Referral_Partner__c>();
        newRSs = createReferralSources(false,workAccount, workRpcr.Product_Line__c);

            if(newRSs.size()>0){
                /*for (Referral_Partner__c rs : newRSs) {
                    if (workRpcr.Referral_Partner__c != null) {
                        rs.Referral_Partner__c = workRpcr.Referral_Partner__c;               
                    }
                    if (workRpcr.Producer__c != null) {
                        rs.Producer__c = workRpcr.Producer__c;
                    }
                }*/
                if(ReferralPartnerChange_Const.PLTYPE_BENEFITS == workRpcr.Product_Line__c){
                    if(Account_Services.isPrimary(workAccount)){
                        workAccount.Referral_Partner_for_Benefits__c = workRpcr.Referral_Partner__c;
                        workAccount.Producer_for_Benefits__c = workRpcr.Producer__c;
                        workAccount.Is_there_a_benefits_referral_partner__c = (workRpcr.Referral_Partner__c != null) ? 'Yes': 'No';
                        if(mapAffiliatedClients.containsKey(workAccount.Id)){
                            for (Account AffiliatedClient : mapAffiliatedClients.get(workAccount.Id)) {
                                AffiliatedClient.Is_there_a_benefits_referral_partner__c = workAccount.Is_there_a_benefits_referral_partner__c;
                                changedAccounts.add(AffiliatedClient);
                            }
                        }
                        if(workAccount.BenefitsClient__r.size()>0){
                            benefitsFieldMappingOnApprovedPRCR(workAccount.BenefitsClient__r);
                        }
                    } 
                    newRSs = setCommissionRates(newRSs, workAccount, workRpcr.Product_Line__c);
                }
                else{
                    workAccount.Producer__c = workRpcr.Producer__c;
                    workAccount.Assigned_Referral_Partner__c = workRpcr.Referral_Partner__c;
                }
            }            
            changedReferralSources.addAll(newRSs);
            workReferralSources = newRSs;
            mapAccountToReferralSources.get(workAccount.Id).addAll(newRSs);
            changedAccounts.add(workAccount);
    }

    /**
     * @description updateRPClientsGroup changes the to Referral Partner Group need to be pushed
     * down to the Client.
     * @param rpgDescription The description of the Referral Partner Group
     */
    private void updateRPClientsGroup(Id idRpg, String rpgDescription) {
        List<Referral_Partner__c> newCRSs;

        Account rp = mapAccounts.get(workAccount.Id);

        if (rp.RecordTypeId != RecordTypeService.getId('Account', 'Referral Partner')) {
            System.debug(LoggingLevel.ERROR, 'updateRPClientGroup does not have Referral Partner as working Account.');
            return;
        }

        if (!mapRptoClients.containsKey(workAccount.Id)) {
            // Referral Partner has no Clients
            return;
        }

		for (Account client : mapRpToClients.get(workAccount.Id)) {
            if (!mapAllAccountToReferralSources.containsKey(client.Id)) {
				continue;
			}

            List<Referral_Partner__c> rss = mapAllAccountToReferralSources.get(client.Id);

            if (rss.isEmpty()) {
                // There is not a current RS for the client
                newCRSs = createReferralSources(false, null, client);
				rss.addAll(newCRSs);				
				
				// QUESTION: IS THIS NEEDED? mapAccountToReferralSources.get(client.Id).addAll(newCRSs);
            }			

            for (Referral_Partner__c rs : rss) {
				rs.Referral_Partner_Group__c = idRpg;
				rs.Group_Description__c = rpgDescription;
				changedReferralSources.add(rs);
            }
        }
    }

    /**
     * Commented because we are not using after USER STORY 51029 changes
     * @description updateRPClientsHold changes the RP_on_Hold because the Client's Referral Partner is
     * being place on/off HOLD.  Sets all Clienst for the Referral Partner.
     * @param setHold  if true sets the hold, false releases it
     * @param holdReason If hold, this is the reason
     */
    /*private void updateRPClientsHold(Boolean setHold, String holdReason) {
        List<Referral_Partner__c> newCRSs;

        if (mapRptoClients.containsKey(workAccount.Id)) {
            for (Account client : mapRpToClients.get(workAccount.Id)) {
                if (client.Status__c != 'Terminated') {
                    List<Referral_Partner__c> rss = mapAccountToReferralSources.get(client.Id);

                    if (rss.isEmpty() || rss.get(rss.size()-1).Termination_Date__c != null) {
                        // There is not a current RS or last one was terminated
                        newCRSs = createReferralSources(false, null, client);
                    }
                    else {
                        List<Referral_Partner__c> oldCRSs = new List<Referral_Partner__c>{ rss.get(rss.size()-1) };
                        markTerminated(oldCRSs);

                        if (!sethold) {
                            // If releasing a hold on a Referral Partner, "hide" record
                            for (Referral_Partner__c rs : oldCRSs) {
                                if (rs.RP_On_Hold__c)  {
                                    rs.Ignore_Record__c = true;
                                }
                            }
                        }

                        newCRSs = createReferralSources(false, oldCRSs, client);
                    }
                    mapAccountToReferralSources.get(client.Id).addAll(newCRSs);

                    for (Referral_Partner__c rs : newCRSs) {
                        if (rs.Referral_Partner__c == workAccount.Id) {
                            rs.RP_on_Hold__c = setHold;
                            rs.Effective_Date__c = workRpcr.Effective_Date__c;

                            if (setHold) {
                                if (!rs.Hold__c) {
                                    // Client is not on Hold, so update to RP Hold reason
                                    rs.Hold_Reason__c = holdReason;
                                }
                            }
                            else {
                                rs.Hold_Reason__c = null;
                            }
                        }
                    }

                    changedAccounts.add(client);
                    changedReferralSources.addAll(newCRSs);
                }
            }
        }
    }
    */
    /**
     * @description updateRPClientsCommission changes the values on the Clients.  This is called
     * from the override on a Referral Partner.
     */
    private void updateRPClientsCommission() {
		if (mapRpToClients.containsKey(workAccount.Id)) {
            List<Referral_Partner__c> newCRSs;

            for (Account client : mapRpToClients.get(workAccount.Id)) {
                if (client.Status__c != 'Terminated') {
                    if (!isSplitCommission(mapAccountToReferralSources.get(client.Id))) {
                        List<Referral_Partner__c> rss = mapAccountToReferralSources.get(client.Id);

                        if (rss.isEmpty() || rss.get(rss.size()-1).Termination_Date__c != null) {
                            newCRSs = createReferralSources(false, null, client);
                        }
                        else {
                            List<Referral_Partner__c> oldCRSs = new List<Referral_Partner__c>{ rss.get(rss.size()-1) };
                            if (oldCRSs.get(0).Override__c) {
                                // There is a Client override in place
                                continue;
                            }
                            markTerminated(oldCRSs);
                            newCRSs = createReferralSources(false, oldCRSs, client);
                        }

                        for (Referral_Partner__c rs : newCRSs) {
                            mapAccountToReferralSources.get(rs.Account__c).add(rs);

                            rs.Referral_Partner_Commission_Type__c = workRpcr.Commission_Type__c;
                            rs.Commission_Rate__c = workRpcr.Commission_Rate__c;

                            changedReferralSources.add(rs);
                        }
                        changedAccounts.add(client);
                    }
                }
            }
        }
        else {
            System.debug(LoggingLevel.INFO, 'Referral Partner ' + workAccount.Name + ' has no Clients/Prospects');
            return;
        }
    }

    /**
     * @description createReferralSources creates Referral Sources for a Referral Partner or
     * Client.
     * It makes copies of the Referral Sources in previousRSs or creates a new
     * one if not there.  Some initial data is set.
     * Only Split Commission Clients should have more than one Referral Source.
     * @param  isRP        Is this for a Referral Partner? If not then Client
     * @param  previousRSs Previous active Referral Sources
     * @param  acc         Related Client acount
     * @return List of new Referral Sources
     */
    private List<Referral_Partner__c> createReferralSources(Boolean isRP, List<Referral_Partner__c> previousRSs, Account acc) {
        List<Referral_Partner__c> newRSs = new List<Referral_Partner__c>();

        if (previousRSs == null || 0 == previousRSs.size()) {
			System.debug(LoggingLevel.DEBUG, '~!~!~ ReferralPartnerChange_Process.createReferralSources() Create Referral Source because RP does not have one');
            // There are no current Referral Sources for the given Account

            // Create as if Client
            Referral_Partner__c newRS = new Referral_Partner__c(
                RecordTypeId = ReferralSource_Service.idrtClientRP,
                Account__c = acc.Id,
                Referral_Partner__c = workRpcr.Referral_Partner__c,
                Referral_Partner_Commission_Type__c = acc.Commission_Type__c,
                Commission_Rate__c = acc.Commission_Rate__c
            );

            if (isRP) {
                // Update if Referral Partner
                newRS.Account__c = null;
                newRS.Referral_Partner__c = acc.Id;
            }
            newRSs.add( newRS );
        }
        else {
            // Clone current active Referral Sources
            for (Referral_Partner__c rs : previousRSs) {
                newRSs.add( rs.clone(false, false, false, false) );
            }
        }

        // New Referral Sources should be active.
        for (Referral_Partner__c rs : newRSs) {
            rs.Effective_Date__c = workRpcr.Effective_Date__c;
            rs.Termination_Date__c = null;
            rs.Referral_Partner_Change_Request__c = workRpcr.Id;
            rs.Comments__c = workRpcr.Comments__c;
            rs.Ignore_Record__c = false;
        }

        return newRSs;
    }      

    /** BUG-63567: Code related Hold and release hold removed  
     * USER STORY 51029
     * @description createReferralSources creates Referral Sources for a Referral Partner or Client.
     * terminating the Referral Sources in previousRSs and creates a new
     * one.  Some initial data is set.
     * Only Split Commission Clients should have more than one Referral Source.
     * @param  isRP        Is this for a Referral Partner? If not then Client
     * @param  acc         Related Client acount
     * @param  plType      Product Line Type
     * @return List of new Referral Sources
    */
    private List<Referral_Partner__c> createReferralSources(Boolean isRP, Account acc, String plType) {
        //Boolean isHoldRP =  (workRpcr.RecordTypeId == ReferralPartnerChange_Const.idrtHoldRP);    
        //Boolean isReleaseHoldRP =  (workRpcr.RecordTypeId == ReferralPartnerChange_Const.idrtReleaseHoldRP);          
      
        if(workReferralSources.size() > 0){ //&& !isHoldRP && !isReleaseHoldRP
            markTerminated(workReferralSources, plType);       
        }

        List<Referral_Partner__c> newRSs = new List<Referral_Partner__c>();

		System.debug(LoggingLevel.DEBUG, '~!~!~ ReferralPartnerChange_Process.createReferralSources() Create Referral Source for CLIENT');
        // Create as if Client
        Referral_Partner__c newRS = new Referral_Partner__c(
            RecordTypeId = ReferralSource_Service.idrtClientRP,
            Referral_Partner_Commission_Type__c = workRpcr.Commission_Type__c,
            Commission_Rate__c = workRpcr.Commission_Rate__c,
            Effective_Date__c = workRpcr.Effective_Date__c,
            Referral_Partner_Change_Request__c = workRpcr.Id,
            Comments__c = workRpcr.Comments__c,
            Producer__c = workRpcr.Producer__c//,
            //Termination_Date__c = null,
            //Ignore_Record__c = false
        );

        if (isRP) {
            // Update if Referral Partner            
            newRS.Referral_Partner__c = acc.Id;
        }
        else{
            newRS.Account__c = acc.Id;
            if (workRpcr.Referral_Partner__c != null) {
                newRS.Referral_Partner__c = workRpcr.Referral_Partner__c;               
            }
            /*else{
                newRS.Referral_Partner__c = acc.Assigned_Referral_Partner__c;
            }*/
            if((workRpcr.Product_Line__c == ReferralPartnerChange_Const.PLTYPE_BENEFITS) && acc.Benefits_Affiliates__c != null){ //|| ((isHoldRP || isReleaseHoldRP) && plType == ReferralPartnerChange_Const.PLTYPE_BENEFITS)
                newRS.Benefits_Affiliated_Companies__c = acc.Benefits_Affiliated_Companies__c;
            }
        }
        newRSs.add( newRS );
        return newRSs;
    }
    
    /**
     * @description benefitsFieldMappingOnApprovedPRCR is to Map banifits Field Mapping For RPOR Client Request
     * @param  benefitsList List of Benefits records Those need to Update Fields on RPOR Client Request
     */
    private void benefitsFieldMappingOnApprovedPRCR(List<Benefits__c> benefitsList) {
        for (Benefits__c benefits : benefitsList) {
            Benefits__c benefitsTemp = mapBenefits.containsKey(benefits.Id)? mapBenefits.get(benefits.Id) : benefits;
            benefitsTemp.L_H_Referral_Partner__c = workRpcr.Referral_Partner__c;
            benefitsTemp.L_H_Producer__c = workRpcr.Producer__c;
            benefitsTemp.Is_there_a_benefits_referral_partner__c = (workRpcr.Referral_Partner__c != null) ? 'Yes': 'No';
            mapBenefits.put(benefitsTemp.Id, benefitsTemp);
        }        
    }

    /**
     * @description retrieveRelatedData sets up some of the class variables for
     * use in the other
     * @param  rpcrs
     */
    @TestVisible
    private void retrieveRelatedData(List<Referral_Partner_Change_Request__c> rpcrs) {
        Set<Id> ids = getAccountIds(rpcrs);

		mapAllAccountToReferralSources = ReferralSource_Service.getAccountReferralSources(ids);

        mapActiveReferralSources = ReferralSource_Service.getActiveReferralSources(ids);
        Set<Id> rpIds = getRPAccountIds(rpcrs);
        getRPAccountData(rpIds);
        getGroupData(rpcrs);
        getAccountData(ids);
        mapAccountToReferralSources = ReferralSource_Service.getActiveAccountReferralSources(mapAccounts.keySet());
        getGroupReferralData();
        getRPCommissions();
        getAffiliatedAccountsFromPrimary(ids); //BUG-63570
    }    

     /* BUG-63570
     * @description getAffiliatedAccountsFromPrimary retrieves Affiliated Clients From Primary Client Account ids.  
     * @param  ids  Account ids lookin for
     */
    @TestVisible
    private void getAffiliatedAccountsFromPrimary(Set<Id> ids) {
        mapAffiliatedClients = new Map<Id, List<Account>>();
        for(Account acc: [SELECT Id, Name, Benefits_Affiliates_Type__c, Benefits_Affiliates__r.Primary_Account__c, Is_there_a_benefits_referral_partner__c FROM Account where Benefits_Affiliates__r.Primary_Account__c =: ids]){
            if(!mapAffiliatedClients.containsKey(acc.Benefits_Affiliates__r.Primary_Account__c)){
                mapAffiliatedClients.put(acc.Benefits_Affiliates__r.Primary_Account__c, new List<Account>());
            }
            if(acc.Id != acc.Benefits_Affiliates__r.Primary_Account__c){
                mapAffiliatedClients.get(acc.Benefits_Affiliates__r.Primary_Account__c).add(acc);            
            }
        }
    }

    @TestVisible
    private void getGroupData(List<Referral_Partner_Change_Request__c> rpcrs) {
        Set<Id> idGroups = new Set<Id>();

        for (Referral_Partner_Change_Request__c rpcr : rpcrs) {
            if (rpcr.RecordTypeId == ReferralPartnerChange_Const.idrtGroupComm
                || rpcr.RecordTypeId == ReferralPartnerChange_Const.idrtRPGroupChange) {
                idGroups.add(rpcr.Referral_Partner_Group__c);
            }
        }

        mapGroups = new Map<Id, Referral_Partner_Group__c>([
            SELECT Id, Name, Group_Commission_Type__c, Group_Commission_Rate__c, Description__c
            FROM Referral_Partner_Group__c
            WHERE Id IN :idGroups
        ]);
    }
    
    /**
     * @description getAccountData retrieves Account information for the
     * given Account ids.  The data is placed in mapRpToClients and MapRps.
     * @param  ids  Account ids lookin for
     */
    @TestVisible
    private void getAccountData(Set<Id> ids) {
        mapRpToClients = new Map<Id, List<Account>>();
        mapRps = new Map<Id, Account>();
        mapAccounts = new Map<Id, Account>();
        mapBenefitsRpToClients = new Map<Id, List<Account>>();
        List<Account> accounts = new List<Account>();

        if (mapGroups.isEmpty()) {
            accounts = [SELECT Id, Name, CreatedDate, Status__c, Referral_Partner_Status__c, RecordTypeId, RecordType.Name, 
                        Client__c, Producer__c, Assigned_Referral_Partner__c,Commission_Rate__c, Commission_Type__c, Hold__c, Is_there_a_benefits_referral_partner__c, 
                        Hold_Effective_Date__c, Referral_Partner_Group__c, BBSI_Benefits__c, Benefits_Affiliates_Type__c, Benefits_Affiliated_Companies__c, Benefits_Affiliates__c, 
                        Headquarters_State__c, Referral_Partner_for_Benefits__c, Producer_for_Benefits__c, (select Id, Name, AccountId__c, L_H_Referral_Partner__c, L_H_Producer__c, LH_Contact_Name__c, Opportunity__c, Business_Entity_Type__c, Company_Headquarter_State__c, L_H_Commission_Rate__c, L_H_Commission_Type__c, Benefits_Coordinator__c, Benefits_Type__c, BBSI_Benefits_Renewal_Date__c from BenefitsClient__r)  
                        FROM Account WHERE Id IN :ids OR Assigned_Referral_Partner__c IN :ids OR Referral_Partner_for_Benefits__c IN :ids];
        }
        else {
            accounts = [SELECT Id, Name, CreatedDate, Status__c, Referral_Partner_Status__c, RecordTypeId, RecordType.Name, 
                        Client__c, Producer__c, Assigned_Referral_Partner__c,Commission_Rate__c, Commission_Type__c, Hold__c, Is_there_a_benefits_referral_partner__c, 
                        Hold_Effective_Date__c, Referral_Partner_Group__c, BBSI_Benefits__c, Benefits_Affiliates_Type__c, Benefits_Affiliated_Companies__c, Benefits_Affiliates__c,
                        Headquarters_State__c, Referral_Partner_for_Benefits__c, Producer_for_Benefits__c, (select Id, Name, AccountId__c, L_H_Referral_Partner__c, L_H_Producer__c, LH_Contact_Name__c, Opportunity__c, Business_Entity_Type__c, Company_Headquarter_State__c, L_H_Commission_Rate__c, L_H_Commission_Type__c, Benefits_Coordinator__c, Benefits_Type__c, BBSI_Benefits_Renewal_Date__c from BenefitsClient__r)
                     FROM Account WHERE Id IN :ids OR Assigned_Referral_Partner__c IN :ids OR Referral_Partner_Group__c IN :mapGroups.keyset() OR Referral_Partner_for_Benefits__c IN :ids];
        }

        for (Account a : Accounts) {
            if (a.RecordType.Name == 'Client' || a.RecordType.Name == 'Prospect' || a.RecordType.Name == 'Terminated') {
                if (a.Assigned_Referral_Partner__c != null) {
                    if (!mapRpToClients.containsKey(a.Assigned_Referral_Partner__c)){
                        mapRpToClients.put(a.Assigned_Referral_Partner__c, new List<Account>());
                    }
                    mapRpToClients.get(a.Assigned_Referral_Partner__c).add(a);
                    mapAccounts.put(a.Id, a);
                }
                else {
                    System.debug(LoggingLevel.ERROR, 'All Clients should have a Referral Partner, right?');
                    mapAccounts.put(a.Id, a);
                }                
                if (a.Referral_Partner_for_Benefits__c != null) {
                    if (!mapBenefitsRpToClients.containsKey(a.Referral_Partner_for_Benefits__c)){
                        mapBenefitsRpToClients.put(a.Referral_Partner_for_Benefits__c, new List<Account>());
                    }
                    mapBenefitsRpToClients.get(a.Referral_Partner_for_Benefits__c).add(a);
                }
            }
            else if (a.RecordType.Name == 'Referral Partner' || a.RecordType.Name == 'BBSI Branch') {
                mapRPs.put(a.Id, a);
                mapAccounts.put(a.Id, a);
            }
        }
    }

    /**
     * @description getRPAccountData retrieves Account information for the
     * given Account ids.  The data is placed in mapRpToClients and MapRps.
     * @param  ids  Account ids lookin for
     */
    @TestVisible
    private void getRPAccountData(Set<Id> ids) {
        mapRPAccounts = new Map<Id, Account>([
                SELECT Id, Referral_Partner_Status__c, Referral_Partner_Group__c, Commission_Rate__c, Commission_Type__c
			FROM Account
                WHERE Id IN :ids
		]);
    }
    
    /**
     * @description getGroupReferralData retrieves Referral Partners and active Referral Sources related
     * to the current groups.
     */
    private void getGroupReferralData() {
        Map<Id, Account> rps = new Map<Id, Account>([
            SELECT Id, Name, CreatedDate, Status__c, Referral_Partner_Status__c, RecordType.Name,
                Assigned_Referral_Partner__c, Client__c, Producer__c, Commission_Rate__c, Commission_Type__c,
                Hold__c, Hold_Effective_Date__c, Referral_Partner_Group__c
            FROM Account
            WHERE Referral_Partner_Group__c IN :mapGroups.keyset()
        ]);

        if (!rps.isEmpty()) {
            for (Account rp : rps.values()) {
                if (rp.RecordType.Name == 'Referral Partner') {
                    mapRPs.put(rp.Id, rp);
                    mapAccounts.put(rp.Id, rp);
                }
            }

            mapAccountToReferralSources.putAll(ReferralSource_Service.getActiveAccountReferralSources(rps.keySet()));
        }
    }   
    
    /**
     * @description getAccountIds runs through the given rpcrs and finds Client
     * and Referral Partner account ids.
     * @param  rpcrs
     * @return A set of Account ids
     */
    @TestVisible
    private Set<Id> getAccountIds(List<Referral_Partner_Change_Request__c> rpcrs) {
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
     * @description getRPAccountIds runs through the given rpcrs and finds Referral Partner account ids.
     * @param  rpcrs
     * @return A set of Account ids
     */
    @TestVisible
    private Set<Id> getRPAccountIds(List<Referral_Partner_Change_Request__c> rpcrs) {
        Set<Id> ids = new Set<Id>();

        for (Referral_Partner_Change_Request__c rpcr : rpcrs) {
            if (rpcr.Referral_Partner__c != null) {
                ids.add(rpcr.Referral_Partner__c);
            }
        }

        return ids;
    }

    /**
     * @description isSplitCommission determines if there are more than one Referral Sources
     * which are active.  This would indicate a Split Commission.
     * @param  rss List of Referral Sources
     * @return true if Split Commission
     */
    @TestVisible
    private static Boolean isSplitCommission(List<Referral_Partner__c> rss) {
        Integer count = 0;

        Set<Id> idRPs = new Set<Id>();

        for (Referral_Partner__c rs : rss) {
            if (rs.Termination_Date__c == null) {
                count++;
                idRPs.add(rs.Referral_Partner__c);
            }
        }

        return (1 < count && 1 < idRPs.size());
    }

    /**
     * @description updateGroupRPCommissions updates the commissions related to the Referral
     * Partners of the group.
     */
    private void updateGroupRPCommissions() {
        for (Account a : mapRps.values()) {
            if (a.Referral_Partner_Status__c == 'Active' || a.Referral_Partner_Status__c == 'Pending') {
                if (workRpcr.Referral_Partner_Group__c == a.Referral_Partner_Group__c && mapGroups.containsKey(a.Referral_Partner_Group__c)) {
                    List<Referral_Partner__c> oldRSs = mapAccountToReferralSources.get(a.Id);

                    Referral_Partner_Group__c rgroup = mapGroups.get(a.Referral_Partner_Group__c);
                    Referral_Partner__c newRS = null;

                    if (!oldRSs.isEmpty()) {
                        Referral_Partner__c oldRS = oldRSs.get(oldRSs.size()-1);

                        if (!oldRS.Override__c) {
                            if (oldRs.Referral_Partner_Commission_Type__c != rgroup.Group_Commission_Type__c || oldRs.Commission_Rate__c != rgroup.Group_Commission_Rate__c) {
                                newRS = oldRS.clone(false, false, false, false);
                                markTerminated(new List<Referral_Partner__c>{ oldRS });
                                changedReferralSources.add(oldRS);
                            }
                        }
                    }
                    else {
						System.debug(LoggingLevel.DEBUG, '~!~!~ ReferralPartnerChange_Process.createReferralSources() Create Referral Source for Change of Commission');
                        newRS = new Referral_Partner__c(
                            Referral_Partner__c = a.Id,
                            RecordTypeId = ReferralSource_Service.idrtClientRP
                        );
                    }

                    if (newRS != null) {
                        newRS.Referral_Partner__c = a.Id;
                        newRS.Referral_Partner_Commission_Type__c = rgroup.Group_Commission_Type__c;
                        newRS.Commission_Rate__c = rgroup.Group_Commission_Rate__c;
                        newRS.Effective_Date__c = workRpcr.Effective_Date__c;
                        newRS.Termination_Date__c = null;
                        newRS.Comments__c = null;

                        changedReferralSources.add(newRS);
                        mapAccountToReferralSources.get(a.Id).add(newRS);
                    }
                }
            }
        }
    }

    /**
     * @description markTerminated terminates the Referral Source by setting the
     * Termination_Date__c.
     * @param rss Referral Sources to terminate
     */
    private void markTerminated(List<Referral_Partner__c> rss) {
        markTerminated(rss, workRpcr.Product_Line__c);
    }
    /**
     * @description markTerminated terminates the Referral Source by setting the
     * Termination_Date__c.
     * @param rss Referral Sources to terminate
     * @param productLine Product Line Type to terminate
     */
    private void markTerminated(List<Referral_Partner__c> rss, String productLine) {
        for (Referral_Partner__c rs : rss) {
            if (rs.Termination_Date__c == null 
                && productLine == rs.Product_Line__c) {
                rs.Termination_Date__c = workRpcr.Effective_Date__c.addDays(-1);

                if (rs.Termination_Date__c < rs.Effective_Date__c) {
                    rs.Termination_Date__c = rs.Effective_Date__c;
                }                
                changedReferralSources.add(rs);
            }
        }
    }

    /**
     * @description getActiveReferralSources retrives active Referral Sources for an Account.
     * @param  idAccount Id of Account looking at
     * @return List of active Referral Sources for Account
     */
    private List<Referral_Partner__c> getActiveReferralSources(Id idAccount) {
        List<Referral_Partner__c> result = new List<Referral_Partner__c>();

        for (Referral_Partner__c rs : mapAccountToReferralSources.get(idAccount)) {
            if (rs.Termination_Date__c == null) {
                result.add(rs);
            }
        }

        return result;
    }

    /**
     * @description addExceptionMessage adds text of a failure to the current exception message.
     * @param  e    The Exception given
     * @param  rpcr The failing request
     */
    @TestVisible
    private void addExceptionMessage(Exception e, Referral_Partner_Change_Request__c rpcr) {
        String text = 'Exception while processing change request: ' + rpcr.Name + '\n';
        text += e.getMessage() + '\n';
        text += e.getStackTraceString() + '\n\n';

        exceptionText += text;
    }

    /**
     * @description makeUpsertError creates the error message for any errors found in the list of
     * upsert results.
     * @param title   Text to put before the errors
     * @param results A list of upsert results
     * @return  Information about the error
     */
    @TestVisible
    private String makeUpsertError(String title, List<Database.UpsertResult> results) {
        String result = '';

        for (Database.UpsertResult uResult : results) {
            if (!uResult.isSuccess()) {
                result += 'ID: ' + uResult.getId() + '  ERRORS: ';
                for (Database.Error error : uResult.getErrors()) {
                    result += ' * ' + error.getMessage();
                }
            }
        }

        if (!String.isBlank(result)) {
            result = title + '\n' + result;
        }

        return result;
    }

    /**
     * @description textChangeRequests lists information about the current change
     * requests being processed.
     * @param rpcrs  A list of change requests
     * @return A string with the change request data
     */
    @testVisible
    private String textChangeRequests(List<Referral_Partner_Change_Request__c> rpcrs) {
        String message = '';

        if (rpcrs != null) {
            message += 'CHANGE REQUESTS TRYING TO PROCESS';

            Integer count = 1;

            for (Referral_Partner_Change_Request__c rpcr : rpcrs) {
                message += '\n\nRequest ' + count;
                message += '\n  ID: ' + rpcr.Id;
                message += '\n  RECORD TYPE: ' + rpcr.RecordType.Name;
                message += '\n  EFFECTIVE DATE: ' + rpcr.Effective_Date__c;
                if (rpcr.Client__c != null) {
                    message += '\n  CLIENT: (' + rpcr.Client__c + ') ' + mapAccounts.get(rpcr.Client__c).Name;
                }
                if (rpcr.Referral_Partner__c != null) {
                    message += '\n  REFERRAL PARTNER: (' + rpcr.Referral_Partner__c + ') ' + mapAccounts.get(rpcr.Referral_Partner__c).Name;
                }
                if (rpcr.Referral_Partner_Group__c != null) {
                    message += '\n  GROUP: (' + rpcr.Referral_Partner_Group__c + ') ' + mapGroups.get(rpcr.Referral_Partner_Group__c).Name;
                }

                count++;
            }
        }
        else {
            message = 'No Change Requests';
        }

        return message;
    }
  
    /**
    * @description rpRequestActivation updates the RPCR Satus.
    * updates the Referral Partner Account Statues As Submitted if rpcr status is Pending Approval.
    * updates the Referral Partner Account Statues As Not Approved if rpcr status is Rejected.
    * updates the Referral Partner Account Statues As Active if rpcr status is Approved.
    */
    private void rpRequestActivation(){
        try { 
            if (workRpcr.Referral_Partner__c != null && mapAccounts.containsKey(workRpcr.Referral_Partner__c) ) {
                Account rp = mapAccounts.get(workRpcr.Referral_Partner__c);
                if(rp.Referral_Partner_Status__c != 'Active') {   
                    if(workRpcr.Status__c == 'Pending Approval'){
                        rp.Referral_Partner_Status__c = 'Submitted';
                        changedAccounts.add(rp); 
                    }     
                    else if(workRpcr.Status__c == 'Rejected'){
                        rp.Referral_Partner_Status__c = 'Not Approved';
                        changedAccounts.add(rp); 
                    }  
                    else if(workRpcr.Status__c == 'Approved'){
                        workRpcr.Approval_Date__c = DateTime.now();
                        // We are setting the approval date for the RPCR Request Activation record in this statement to prevent RP_is_Active validation error.
                        rp.Referral_Partner_Status__c = 'Active'; 
                        
                        if (workRpcr.Referral_Partner__c != null 
                        && mapAccounts.containsKey(workRpcr.Referral_Partner__c) 
                        && (mapRpToClients.containsKey(workRpcr.Referral_Partner__c) 
                            || mapBenefitsRpToClients.containsKey(workRpcr.Referral_Partner__c)) ) {                            
                            List<Referral_Partner__c> newRSs = generateReferralSourcesFromRP(rp);     
                            changedReferralSources.addAll(newRSs);
                        }                        
                        changedAccounts.add(rp); 
                    }
                    else {
                        System.debug(LoggingLevel.ERROR, 'Invalid Referrence on Referral Partner Request Activation or This referral partner is already active');
                    }                         
                }
                
                else {
                    System.debug(LoggingLevel.ERROR, 'Invalid Referrence on Referral Partner Request Activation');
                }      
            }     
        } 
        catch (Exception e) {
            addExceptionMessage(e, workRpcr);
        }  
    }  
    /**BUG-63567: Commented code related Hold and Release Hold Request
    /**
    * @description generateReferralSourcesFromRP used for Renerating New Referral Sources from Reffreral Partner.
    */
    private List<Referral_Partner__c> generateReferralSourcesFromRP(Account rp){
        List<Referral_Partner__c> newRSs = new List<Referral_Partner__c>();  
        /*Boolean isHoldRP =  (workRpcr.RecordTypeId == ReferralPartnerChange_Const.idrtHoldRP);    
        Boolean isReleaseHoldRP =  (workRpcr.RecordTypeId == ReferralPartnerChange_Const.idrtReleaseHoldRP); */         
        Boolean isCommissionChangeRP =  (workRpcr.RecordTypeId == ReferralPartnerChange_Const.idrtCommissionChangeRP);          
        if(mapRpToClients.containsKey(rp.Id)){
            for (Account client : mapRpToClients.get(rp.Id)) {
                if (client.Status__c != 'Terminated') {
                    workReferralSources = getActiveReferralSources(client.Id);
                    Boolean hasOverrideRS = false;
                    if(isCommissionChangeRP){
                        for(Referral_Partner__c rs: workReferralSources)
                        {
                            if(rs.Override__c){
                                hasOverrideRS = true;
                                break;
                            }
                        }
                    }                    
                    /*if(isReleaseHoldRP){
                        // If releasing a hold on a Referral Partner, "hide" record
                        for (Referral_Partner__c rs : workReferralSources) {
                            if (rs.RP_On_Hold__c && (rs.Product_Line__c == workRpcr.Product_Line__c || ((isHoldRP || isReleaseHoldRP) && rs.Product_Line__c == ReferralPartnerChange_Const.PLTYPE_WORKERSCOMP))) {
                                rs.Ignore_Record__c = true;
                            }
                        }
                    }*/
                    if(!hasOverrideRS){
                        List<Referral_Partner__c> rss = createReferralSources(false, client, ReferralPartnerChange_Const.PLTYPE_WORKERSCOMP);
                        if(!rss.isEmpty()){
                            for (Referral_Partner__c rs : rss) {                             
                                rs.Referral_Partner_Commission_Type__c = rp.Commission_Type__c; //(isHoldRP)? ReferralPartnerChange_Const.DEFAULTWORKCOMPTYPE: rp.Commission_Type__c;
                                rs.Commission_Rate__c = rp.Commission_Rate__c; //(isHoldRP)? default_Referral_Partner_Commissions.Commission_Rate__c:rp.Commission_Rate__c;                      
                                if(String.isBlank(workRpcr.Product_Line__c)){
                                    rs.ProductLine__c = ReferralPartnerChange_Const.PLTYPE_WORKERSCOMP;
                                }
                                if(rs.Producer__c == null){
                                    rs.producer__c = client.Producer__c;
                                }
                            }
                            newRSs.addAll(rss);
                        } 
                    }                    
                }                       
                mapAccountToReferralSources.get(client.Id).addAll(newRSs);
            }                   
        }
        if(!isCommissionChangeRP && mapBenefitsRpToClients.containsKey(rp.Id)){
            for (Account client : mapBenefitsRpToClients.get(rp.Id)) {
                if (client.Status__c != 'Terminated') {
                    workReferralSources = getActiveReferralSources(client.Id);
                    Boolean hasOverrideRS = false;
                    if(isCommissionChangeRP){
                        for(Referral_Partner__c rs: workReferralSources)
                        {
                            if(rs.Override__c){
                                hasOverrideRS = true;
                                break;
                            }
                        }
                    }      
                    /*if(isReleaseHoldRP){
                        // If releasing a hold on a Referral Partner, "hide" record
                        for (Referral_Partner__c rs : workReferralSources) {
                            if (rs.RP_On_Hold__c && (rs.Product_Line__c == workRpcr.Product_Line__c || ((isHoldRP || isReleaseHoldRP) && rs.Product_Line__c == ReferralPartnerChange_Const.PLTYPE_BENEFITS))) {
                                rs.Ignore_Record__c = true;
                            }
                        }
                    }*/
                    if(!hasOverrideRS){
                        List<Referral_Partner__c> rss = createReferralSources(false,client,ReferralPartnerChange_Const.PLTYPE_BENEFITS);
                        if(!rss.isEmpty()){   
                            for (Referral_Partner__c rs : rss) { 
                                if(String.isBlank(workRpcr.Product_Line__c)){
                                    rs.ProductLine__c = ReferralPartnerChange_Const.PLTYPE_BENEFITS;
                                }
                                if(rs.Producer__c == null){
                                    rs.producer__c = client.Producer_for_Benefits__c;
                                }
                            }
                            /*if(isHoldRP){
                                for (Referral_Partner__c rs : rss) {
                                    rs.Referral_Partner_Commission_Type__c = default_Referral_Partner_Commissions.Commission_Type__c;
                                    rs.Commission_Rate__c = default_Referral_Partner_Commissions.Commission_Rate__c;
                                }
                            } 
                            else{
                                rss = setCommissionRates(rss, client, ReferralPartnerChange_Const.PLTYPE_BENEFITS);
                            } */
                            rss = setCommissionRates(rss, client, ReferralPartnerChange_Const.PLTYPE_BENEFITS);               
                            newRSs.addAll(rss);
                        }
                    } 
                }                       
                mapAccountToReferralSources.get(client.Id).addAll(newRSs);
            }
        } 
        return newRSs;
    }

    /**
     * BUG:63365 
     * @description setCommissionRates for based on Custom Metadate table will return Commission Rate and Commission Type
     * @param  rss List of List Referral Partner Records
     * @param  client Client Record
     * @param  prodLine Product Line
     */
    @testVisible
    private List<Referral_Partner__c> setCommissionRates(List<Referral_Partner__c> rss, Account client, String prodLine) {    
        Referral_Partner_Commissions__mdt commissionRate = ReferralPartnerChange_Process.getMatchingCommission(client, prodLine);
        for (Referral_Partner__c record : rss) {
            record.Commission_Rate__c = commissionRate.Commission_Rate__c;
            record.Referral_Partner_Commission_Type__c = commissionRate.Commission_Type__c;
        }
        return rss;
    }

    /**
     * US:51029:
     * @description setCommissionRates for based on Custom Metadate table will return Commission Rate and Commission Type.    
     * @param  listNew List of newly created records
     */
    @testVisible
    private List<Referral_Partner__c> setCommissionRates(List<Referral_Partner__c> rss) {        
        for (Referral_Partner__c record : rss) {
            Account client = (record.Account__c != NULL) ? mapAccounts.get(record.Account__c): new Account();            
            Referral_Partner_Commissions__mdt commissionRate = ReferralPartnerChange_Process.getMatchingCommission(client, workRpcr.Product_Line__c);
            record.Commission_Rate__c = commissionRate.Commission_Rate__c;
            record.Referral_Partner_Commission_Type__c = commissionRate.Commission_Type__c;
        }
        return rss;
    }
    /**  USER STORY 51029
     * @description used for get Referral Partner Commissions table records from custom metadata
    */
    
    public static void getRPCommissions(){
        referral_Partner_Commissions = [select Id, DeveloperName, MasterLabel,  Label, Client_has_Benefits__c, 
            Client_has_BOR_for_Benefits__c, Product_Line__c,  Commission_Rate__c, Commission_Type__c, Headquarters_State__c 
            from Referral_Partner_Commissions__mdt where Is_Active__c = true and DeveloperName != 'default'];
        default_Referral_Partner_Commissions =  [select Id, DeveloperName, MasterLabel,  Label, Client_has_Benefits__c, 
            Client_has_BOR_for_Benefits__c, Product_Line__c,  Commission_Rate__c, Commission_Type__c, Headquarters_State__c 
            from Referral_Partner_Commissions__mdt where Is_Active__c = true and DeveloperName = 'default'];
    }  
    
    /**
     * USER STORY 51029
     * @description getMatchingCommission used to returns the valid Commission Rate for the client and product line
     * @param  client - Related Client account
     * @param  prodLine - Product Line for which Commission to be returned
     * @return Referral_Partner_Commissions__mdt - matching Commission Rate record
    */
    public static Referral_Partner_Commissions__mdt getMatchingCommission(Account client, String prodLine) {
        Referral_Partner_Commissions__mdt stateCommissionRate;
        Referral_Partner_Commissions__mdt otherCommissionRate;
        if(referral_Partner_Commissions.isEmpty()){
            getRPCommissions();
        }        
        for (Referral_Partner_Commissions__mdt commissionRate : referral_Partner_Commissions) {
            if (prodLine == commissionRate.Product_Line__c 
                && (client.BBSI_Benefits__c == commissionRate.Client_has_Benefits__c) 
                && ((client.Is_there_a_benefits_referral_partner__c == 'Yes') == commissionRate.Client_has_BOR_for_Benefits__c)) {
                if ((client.Headquarters_State__c == commissionRate.Headquarters_State__c)) {
                    stateCommissionRate = commissionRate;
                    break;
                }
                else if (commissionRate.Headquarters_State__c == 'non-CA') {
                    stateCommissionRate = commissionRate;
                }
            }
        }
        return stateCommissionRate != null ? stateCommissionRate : default_Referral_Partner_Commissions;
    }
	/**
	* @description makeRPCRReqStatusChanges updates the RPCR Satus.
	* updates the Referral Partner Account Statues As Submitted if rpcr status is Pending Approval.
	* updates the Referral Partner Account Statues As Not Approved if rpcr status is Rejected.
	* updates the Referral Partner Account Statues As Active if rpcr status is Approved.
	* @param rpcr  change request Record
	*/
	private void makeRPCRReqStatusChanges(Referral_Partner_Change_Request__c rpcr){
		try { 
			if (rpcr.RecordTypeId == ReferralPartnerChange_Const.idrtRPReqActiv 
				&& rpcr.Referral_Partner__c != null && mapRPAccounts.containsKey(rpcr.Referral_Partner__c) ) {
				Account rpAccount = mapRPAccounts.get(rpcr.Referral_Partner__c);
				if(rpAccount.Referral_Partner_Status__c != 'Active') {   
					if(rpcr.Status__c == 'Pending Approval'){
						rpAccount.Referral_Partner_Status__c = 'Submitted';
						changedAccounts.add(rpAccount); 
					}     
					else if(rpcr.Status__c == 'Rejected'){
						rpAccount.Referral_Partner_Status__c = 'Not Approved';
						changedAccounts.add(rpAccount); 
					}  
					else if(rpcr.Status__c == 'Approved'){
						rpcr.Approval_Date__c = DateTime.now();
						// We are setting the approval date for the RPCR Request Activation record in this statement to prevent RP_is_Active validation error.
						rpAccount.Referral_Partner_Status__c = 'Active'; 
						changedAccounts.add(rpAccount); 
					}
					else {
						System.debug(LoggingLevel.ERROR, 'Invalid Referrence on Referral Partner Request Activation or This referral partner is already active');
					}                         
				}
				
				else {
					System.debug(LoggingLevel.ERROR, 'Invalid Referrence on Referral Partner Request Activation');
				}
			}
		} 
		catch (Exception e) {
			addExceptionMessage(e, rpcr);
		}
	}
}