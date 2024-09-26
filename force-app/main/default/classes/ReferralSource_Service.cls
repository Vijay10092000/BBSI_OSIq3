/**
 * @description ReferralSource_Service contains helper methods related to the
 * Referral_Partner__c object which is labeled Referral Source.
 */
public without sharing class ReferralSource_Service {

    public static final String NAME = 'Referral_Partner__c';

    // Get each of the RecordTypes
    public static Id idrtClientRP = RecordTypeService.getId(NAME, 'Client_Referral_Partner');
    public static Id idrtLeadRP = RecordTypeService.getId(NAME, 'Lead_Referral_Partner');
    public static Id idrtOpporutunityClient = RecordTypeService.getId(NAME, 'Opportunity_Referral_Partner');

    /**
     * @description updateLeadReferralSources creates or updates a Referral Source (Referral_Partner__c)
     *  for Leads when the Referral Partner and Producer changes.
     * @param  mapOld  Previous version of Leads
     * @param  listNew New versions of Leads
     * @return List of new or updated Referral Sources (Referral_Partner__c)
     */
    public static List<Referral_Partner__c> updateLeadReferralSources(Map<Id, Lead> mapOld, List<Lead> listNew) {
        Map<Id, List<Referral_Partner__c>> activeRSs;

        if (mapOld == null) {
            activeRSs = new Map<Id, List<Referral_Partner__c>>();
        }
        else {
            activeRSs = getActiveLeadReferralSources(mapOld.keySet());
        }

        List<Referral_Partner__c> changedRSs = new List<Referral_Partner__c>();
        Id rtClient = RecordTypeService.getId('Lead', 'Client_Lead');

        for (Lead l : listNew) {
            if (l.RecordTypeID == rtClient && l.Status != 'Unqualified') {
                if (l.Referral_Partner__c != null && l.Producer__c != null) {
                    Boolean rpChanged = true;
                    Boolean producerChanged = true;

                    if (mapOld != null) {
                        rpChanged = (mapOld.get(l.Id).Referral_Partner__c != l.Referral_Partner__c);
                        producerChanged = (mapOld.get(l.Id).Producer__c != l.Producer__c);
                    }

                    if (rpChanged || producerChanged) {
                        if (activeRSs.containsKey(l.Id) && !activeRSs.get(l.Id).isEmpty()) {
                            // Terminate all previous and create new
                            changedRSs.addAll(terminateReferralSources(activeRSs.get(l.Id)));
                            changedRSs.add(createReferralSourceLead(l, 'Referral Partner and/or Producer Change'));
                        }
                        else {
                            // Create the first one
                            changedRSs.add(createReferralSourceLead(l, l.Referral_Comments__c));
                        }
                    }
                }
            }
        }

        return changedRSs;
    }

    /**
     * @description updateReferralPartnerAccountLastReferralDate updates the Last_Referral_Date__c
     * field on Leads and Accounts when Referral Source is changed
     * Called After-Insert and After-Update of Referral Sources.
     * @param  mapOld  mapOld description
     * @param  listNew listNew description
     */
    public static void updateReferralPartnerAccountLastReferralDate(Map<Id, Referral_Partner__c> mapOld, List<Referral_Partner__c> listNew) {
        Set<Id> idAccounts = new Set<Id>();
        Set<Id> idLeads = new Set<Id>();
        Set<Id> idRPs = new Set<Id>();
        Set<Id> updatedRPs = new Set<Id>();

        for (Referral_Partner__c rs : listNew) {
            if (rs.Lead__c == null) {
                if (rs.Account__c != null) {
                    idAccounts.add(rs.Account__c);
                }
            }
            else {
                idLeads.add(rs.Lead__c);
            }

            idRPs.add(rs.Referral_Partner__c);
        }

        Map<Id, Account> accounts = new Map<Id, Account>([
            SELECT Id, CreatedDate
            FROM Account
            WHERE Id IN :idAccounts
        ]);

        Map<Id, Account> referralPartners = new Map<Id, Account>([SELECT Id, Last_Referral_Date__c FROM Account WHERE Id IN :idRPs]);
        Map<Id, Lead> leadsByLeadIdAndAccountID = new Map<Id, Lead>();

        List<Lead> leads = queryRelatedLeads(idLeads, idAccounts);

        for (Lead currentlead : leads) {
            leadsByLeadIdAndAccountId.put(currentLead.id, currentlead);
            leadsByLeadIdAndAccountId.put(currentLead.ConvertedAccountId, currentlead);
        }

        Id lookupId;
        for (Referral_Partner__c rs : listNew) {
            lookupId = (rs.Lead__c != null ? rs.Lead__c : rs.Account__c);

            Lead ld = leadsByLeadIdAndAccountId.get(lookupId);
            if (ld != null && rs.Referral_Partner__c != null) {
                Account rpAccount = referralPartners.get(rs.Referral_Partner__c);
                if (rpAccount.Last_Referral_Date__c == null || ld.CreatedDate > rpAccount.Last_Referral_Date__c) {
                    updatedRPs.add(rs.Referral_Partner__c);
                    rpAccount.Last_Referral_Date__c = Date.valueOf(DateTime.NewInstanceGMT(ld.CreatedDate.Year(),ld.CreatedDate.Month(),ld.CreatedDate.Day(),0,0,0));
                    referralPartners.put(rpAccount.Id, rpAccount);
                }
            }
            else {
                Account rpAccount = referralPartners.get(rs.Referral_Partner__c);
                if (rpAccount != null && accounts.containsKey(rs.Account__c)) {
                    rpAccount.Last_Referral_Date__c = Date.valueOf(accounts.get(rs.Account__c).CreatedDate);
                }
            }
        }

        if (!updatedRPs.isEmpty()) {
            List<Account> accountsToUpdate = new List<Account>();

            for (Id rp : updatedRPs) {
                accountsToUpdate.add(referralPartners.get(rp));
            }

            update accountsToUpdate;
        }
    }

    /**
     * @description updateProspectReferralSources creates or updates a Referral Source (Referral_Partner__c)
     * for Prospects when the Referral Partner and Producer changes.
     * @param  mapOld  Previous version of Leads
     * @param  listNew New versions of Leads
     * @return List of new or updated Referral Sources (Referral_Partner__c)
     */
    public static List<Referral_Partner__c> updateProspectReferralSources(Map<Id, Account> mapOld, List<Account> listNew) {
        List<Referral_Partner__c> changedRSs = new List<Referral_Partner__c>();
        List<Account> prospects = RecordTypeService.getByRecordType(listNew, 'Account', 'Prospect');

        if (!prospects.isEmpty()) {
            Map<Id, List<Referral_Partner__c>> activeRSs;

            if (mapOld == null) {
                activeRSs = new Map<Id, List<Referral_Partner__c>>();
            }
            else {
                activeRSs = getActiveAccountReferralSources(mapOld.keySet());
            }

            Set<Id> idReferralPartners = new Set<Id>();
			Set<Id> idLeadsConverting = new Set<Id>();

            for (Account prospect : prospects) {
                if (prospect.Assigned_Referral_Partner__c != null) {
                    idReferralPartners.add(prospect.Assigned_Referral_Partner__c);
                }

				if (mapOld == null) {
					if (!String.isBlank(prospect.Lead_Converted_Id__c)) {
						idLeadsConverting.add(prospect.Lead_Converted_Id__c);
					}
				}
            }

            Map<Id, Account> referralPartners = new Map<Id, Account>([
				SELECT Id, Name, Commission_Type__c, Commission_Rate__c, Referral_Partner_Group__c
				FROM Account 
				WHERE Id IN :idReferralPartners
			]);

			Set<Id> haveReferralSources = new Set<Id>();
			for (Referral_Partner__c rs : [SELECT Id, Lead__c FROM Referral_Partner__c WHERE Lead__c IN :idLeadsConverting]) {
				haveReferralSources.add(rs.Lead__c);
			}

            for (Account prospect : prospects) {
				if (haveReferralSources.contains(prospect.Lead_Converted_Id__c)) {
					continue;
				}

                if (prospect.Assigned_Referral_Partner__c != null || prospect.Producer__c != null) {
                    Account referralPartner = null;
                    if (referralPartners.containsKey(prospect.Assigned_Referral_Partner__c)){
                        referralPartner = referralPartners.get(prospect.Assigned_Referral_Partner__c);
                    }

                    Boolean rpChanged = true;
                    Boolean producerChanged = true;

                    if (mapOld != null) {
                        Account oldProspect = mapOld.get(prospect.Id);
                        rpChanged = (oldProspect.Assigned_Referral_Partner__c != prospect.Assigned_Referral_Partner__c);
                        producerChanged = (oldProspect.Producer__c != prospect.Producer__c);
                    }

                    if (rpChanged || producerChanged) {
                        if (activeRSs.containsKey(prospect.Id) && !activeRSs.get(prospect.Id).isEmpty()) {
                            changedRSs.addAll(terminateReferralSources(activeRSs.get(prospect.Id)));
                            Referral_Partner__c rsNew = createReferralSourceForProspect(prospect, referralPartner);
                            rsNew.Comments__c = 'Change made to Referral Partner, Producer or both.';
                            changedRSs.add(rsNew);
                        }
                        else {
                            Referral_Partner__c rsNew = createReferralSourceForProspect(prospect, referralPartner);
                            rsNew.Comments__c = 'New active Referral Source';
                            changedRSs.add(rsNew);
                        }
                    }
                }
            }
        }

        return changedRSs;
    }

    /**
     * @description createReferralSourceForReferralPartner creates a Referral Source for the given
     * Referral Partner.
     * @param  rp  Referral Partner
     * @param  rpg Referral Partner Group to which Referral Partner belong
     * @return A Referral Source
     */
    public static Referral_Partner__c createReferralSourceForReferralPartner(Account rp, Referral_Partner_Group__c rpg) {
		System.debug(LoggingLevel.DEBUG, '~!~!~ ReferralSource_Service.createReferralSourceForReferralPartner() New Referral Source for RP: ' + rp.Name);
        return new Referral_Partner__c(
            RecordTypeId = RecordTypeService.getId('Referral_Partner__c', 'Client_Referral_Partner'),
            Account__c = null,
            Commission_Rate__c = rp.Commission_Rate__c,
            Referral_Partner_Commission_Type__c = rp.Commission_Type__c,
            Effective_Date__c = System.today(),
            Referral_Partner_Group__c = rp.Referral_Partner_Group__c,
            Group_Description__c = ReferralPartnerGroup_Service.truncateGroupDescription(rpg),
            Referral_Partner__c = rp.Id,
            Termination_Date__c = null
        );
    }

    /**
     * @description createReferralSourceForClient creates a Referral Source for the given Client.
     * @param  client Client account
     * @param  rp Referral Partner to which the Client/Prospect belongs
     * @return A Referral Source
     */
    public static Referral_Partner__c createReferralSourceForClient(Account client, Account rp) {
		System.debug(LoggingLevel.DEBUG, '~!~!~ ReferralSource_Service.createReferralSourceForClient() New Referral Source for CLIENT: ' + client.Name);
        return new Referral_Partner__c(
            RecordTypeId = RecordTypeService.getId('Referral_Partner__c', 'Client_Referral_Partner'),
            Account__c = client.Id,
            Commission_Rate__c = rp.Commission_Rate__c,
            Referral_Partner_Group__c = rp.Referral_Partner_Group__c,
            Referral_Partner_Commission_Type__c = rp.Commission_Type__c,
            Effective_Date__c = System.today(),
            Producer__c = client.Producer__c,
            Referral_Partner__c = rp.Id,
            Termination_Date__c = null
        );
    }

    /**
     * @description createReferralSourceForProspect creates a Referral Source for the given Prospect.
     * @param  prospect Prospect account
     * @param  rp Referral Partner to which the Prospect belongs
     * @return A Referral Source
     */
    public static Referral_Partner__c createReferralSourceForProspect(Account prospect, Account rp) {
		System.debug(LoggingLevel.DEBUG, '~!~!~ ReferralSource_Service.createReferralSourceForProspect() New Referral Source for PROSPECT: ' + prospect.Name);

        Referral_Partner__c rs = new Referral_Partner__c(
            RecordTypeId = RecordTypeService.getId('Referral_Partner__c', 'Client_Referral_Partner'),
            Account__c = prospect.Id,
            Effective_Date__c = System.today(),
            Producer__c = prospect.Producer__c,
            Termination_Date__c = null
        );

        if (rp != null) {
            rs.Referral_Partner__c = rp.Id;
            rs.Commission_Rate__c = rp.Commission_Rate__c;
            rs.Referral_Partner_Commission_Type__c = rp.Commission_Type__c;
            rs.Referral_Partner_Group__c = rp.Referral_Partner_Group__c;
        }

        return rs;
    }

    /**
     * @description createReferralSourceLead creates a new Referral Source (Referral_Partner__c)
     * for a Lead
     * @param  idLead            Related Lead
     * @param  idProducer        Producer identifer (Contact)
     * @param  idReferralPartner Referral Partner identifier (Account)
     * @param  comments          Additional information
     * @return The Referral Source or null if not created
     */
    public static Referral_Partner__c createReferralSourceLead(Id idLead, Id idProducer, Id idReferralPartner, String comments) {
		System.debug(LoggingLevel.DEBUG, '~!~!~ ReferralSource_Service.createReferralSourceLead() New Referral Source for LEAD ID: ' + idLead);
        return new Referral_Partner__c(
            RecordTypeId = RecordTypeService.getId('Referral_Partner__c', 'Lead_Referral_Partner'),
            Account__c = null,
            Lead__c = idLead,
            Producer__c = idProducer,
            Referral_Partner__c = idReferralPartner,
            Effective_Date__c = System.Today(),
            Termination_Date__c = null,
            Referral_Partner_Commission_Type__c = null,
            Commission_Rate__c = 0.0,
            Comments__c = comments
        );
    }

    /**
     * @description createReferralSourceLead creates a new Referral Source (Referral_Partner__c)
     * for a Lead
     * @param  fromLead Related Lead
     * @param  comments Additional information
     * @return The Referral Source or null if not created
     */
    public static Referral_Partner__c createReferralSourceLead(Lead fromLead, String comments) {
        return createReferralSourceLead(fromLead.Id, fromLead.Producer__c, fromLead.Referral_Partner__c, comments);
    }

    /**
     * @description createReferralSource creates a new Referral Source (Referral_Partner__c) for Client
     * or Referral Partner
     * @param  idClient          Client identifier.  If null, then RS is for Referral Partner. (Account)
     * @param  idProducer        Producer identifer (Contact)
     * @param  idReferralPartner Referral Partner identifier (Account)
     * @param  startDate         When this starts
     * @param  commissionType    Commission Type
     * @param  commissionRate    Commission Rate for the Referral Source
     * @param  comments          Additional information
     * @return The Referral Source
     */
    @SuppressWarnings('PMD.ExcessiveParameterList')
    public static Referral_Partner__c createReferralSource(Id idClient, Id idProducer, Id idReferralPartner, Date startDate,
                                                           String commissionType, Decimal commissionRate, String comments) {
        if (startDate == null) {
            startDate = System.Today();
        }

        return new Referral_Partner__c(
            RecordTypeId = RecordTypeService.getId('Referral_Partner__c', 'Client_Referral_Partner'),
            Account__c = idClient,
            Lead__c = null,
            Producer__c = idProducer,
            Referral_Partner__c = idReferralPartner,
            Effective_Date__c = startDate,
            Referral_Partner_Commission_Type__c = commissionType,
            Commission_Rate__c = commissionRate,
            Comments__c = comments
        );
    }

    /**
     * @description getReferralPartnerSources retrieves a map of Referral Source (Referral_Partner__c)
     * for the given Set of Ids.
     * @param idRSs Set of ReferralSource (Referral_Partner__c) identifiers
     * @return A Map relating Referral_Partner__c id to Referral_Partner__c objects
     */
    public static Map<Id, Referral_Partner__c> getReferralPartnerSources(Set<Id> idRSs) {
        return new Map<Id, Referral_Partner__c>([
            SELECT Id, Name, Account__c, Branch__c, Comments__c, Commission_Rate__c, DBA_Name__c, Effective_Date__c, Hold__c,
            Hold_Formula__c, Hold_Reason__c, Group_Commission_Type__c, Group_Commission_Rate__c, Last_Referral_Date__c,
            Lead__c, Lead_Creation_Date__c, Opportunity__c, Override__c, Referral_Partner_Group__c, Ignore_Record__c,
            OwnerId, Producer__c, RecordTypeId,  Referral_Partner__c, Referral_Partner_Change_Request__c,
            Referral_Partner_ID__c, Referral_Partner_Commission_Type__c, RP_On_Hold__c, Termination_Date__c
            FROM Referral_Partner__c
            WHERE Id IN :idRSs
        ]);
    }

    /**
     * @description getActiveLeadReferralSources retrieves the all Referral Sources (Referral_Partner__c)
     * for the given Lead identifiers.
     * NOTE: If a Lead has more than one active (error), only one is returned.
     * @param  idLeads idLeads description
     * @return Map of Lead Id to all Referral Sources
     */
    @TestVisible
    private static Map<Id, List<Referral_Partner__c>> getActiveLeadReferralSources(Set<Id> idLeads) {
        Map<Id, List<Referral_Partner__c>> results = new Map<Id, List<Referral_Partner__c>>();

        for (Id id : idLeads) {
            results.put(id, new List<Referral_Partner__c>());
        }

        List<Referral_Partner__c> rss = [
            SELECT Id, Name, Account__c, Branch__c, Comments__c, Commission_Rate__c, DBA_Name__c, Effective_Date__c, Hold__c,
                Hold_Formula__c, Hold_Reason__c, Group_Commission_Type__c, Group_Commission_Rate__c, Last_Referral_Date__c,
                Lead__c, Lead_Creation_Date__c, Opportunity__c, Override__c, Referral_Partner_Group__c, Ignore_Record__c,
                OwnerId, Producer__c, RecordTypeId,  Referral_Partner__c, Referral_Partner_Change_Request__c,
                Referral_Partner_ID__c, Referral_Partner_Commission_Type__c, RP_On_Hold__c, Termination_Date__c
            FROM Referral_Partner__c
            WHERE RecordTypeId = :idrtLeadRP AND Termination_Date__c = null AND Lead__c IN :idLeads
            ORDER BY Effective_Date__c
        ];

        for (Referral_Partner__c rs : rss) {
            results.get(rs.Lead__c).add(rs);
        }

        return results;
    }

    /**
     * @description getAccountReferralSources retrieves all the  Referral Sources for the given
     * Account ids.  For Referral Partners, will include all Client Accounts.
     * @param  idAccounts List of Accounts
     * @return Map of Referral_Partner_Change_Request__c ids to list of Referral Sources
     */
    public static Map<Id, List<Referral_Partner__c>> getAccountReferralSources(Set<Id> idAccounts) {
        Map<Id, List<Referral_Partner__c>> results = new Map<Id, List<Referral_Partner__c>>();

        for (Id id : idAccounts) {
            results.put(id, new List<Referral_Partner__c>());	
        }

        List<Referral_Partner__c> rss = [
            SELECT Id, Name, Account__c, Branch__c, Comments__c, Commission_Rate__c, DBA_Name__c, Effective_Date__c, Hold__c,
                Hold_Formula__c, Hold_Reason__c, Group_Commission_Type__c, Group_Commission_Rate__c, Group_Description__c, Last_Referral_Date__c,
                Lead__c, Lead_Creation_Date__c, Opportunity__c, Override__c, Referral_Partner_Group__c, Ignore_Record__c,
                OwnerId, Producer__c, RecordTypeId,  Referral_Partner__c, Referral_Partner_Change_Request__c,
                Referral_Partner_ID__c, Referral_Partner_Commission_Type__c, RP_On_Hold__c, Termination_Date__c
            FROM Referral_Partner__c
            WHERE RecordTypeId = :idrtClientRP AND (Account__c IN :idAccounts OR Referral_Partner__c IN :idAccounts)
        ];

        for (Referral_Partner__c rs : rss) {
            Id idAccount;
            if (rs.Account__c != null) {
                idAccount = rs.Account__c;
            }
            else {
                idAccount = rs.Referral_Partner__c;
            }

            if (!results.containsKey(idAccount)) {
                results.put(idAccount, new List<Referral_Partner__c>());
            }
            results.get(idAccount).add(rs);
        }

        return results;
    }

    /**
     * @description getActiveAccountReferralSources retrieves all the active, non-terminated,
     * Referral Sources for the given Account ids.  For Referral Partners, will include
     * all Client Accounts.
     * @param  idAccounts A List of Client Account ids
     * @return Map relating Client Account id to list of Referral Sources
     */
    public static Map<Id, List<Referral_Partner__c>> getActiveAccountReferralSources(Set<Id> idAccounts) {
        Map<Id, List<Referral_Partner__c>> result = new Map<Id, List<Referral_Partner__c>>();

        for (Id id : idAccounts) {
            result.put(id, new List<Referral_Partner__c>());
        }

        List<Referral_Partner__c> rss = [
            SELECT Id, Name, Account__c, Account__r.Name, Branch__c, Comments__c, Commission_Rate__c, DBA_Name__c, Effective_Date__c, Hold__c,
                Hold_Formula__c, Hold_Reason__c, Group_Commission_Type__c, Group_Commission_Rate__c, Group_Description__c, Last_Referral_Date__c,
                Lead__c, Lead_Creation_Date__c, Opportunity__c, Override__c, Referral_Partner_Group__c, Ignore_Record__c,
                OwnerId, Producer__c, RecordTypeId, Referral_Partner__c, Referral_Partner__r.Name, Referral_Partner_Change_Request__c,
                Referral_Partner_ID__c, Referral_Partner_Commission_Type__c, RP_On_Hold__c, Termination_Date__c, Product_Line__c
            FROM Referral_Partner__c
            WHERE RecordTypeId = :idrtClientRP AND Termination_Date__c = null AND (Account__c IN :idAccounts OR Referral_Partner__c IN :idAccounts)
            ORDER BY Effective_Date__c ASC
        ];

        for (Referral_Partner__c rs : rss) {
            if (rs.Account__c == null) {
                if (rs.Referral_Partner__c != null) {
					if (!result.containsKey(rs.Referral_Partner__c)) {
						result.put(rs.Referral_Partner__c, new List<Referral_Partner__c>());
					}

                    result.get(rs.Referral_Partner__c).add(rs);
                }
            }
            else {
                if (!result.containsKey(rs.Account__c)) {
                    result.put(rs.Account__c, new List<Referral_Partner__c>());
                }
                result.get(rs.Account__c).add(rs);
            }
        }

        return result;
    }

    /**
     * @description getActiveReferralSources retrieves all the active, non-terminated,
     * Referral Sources for the given Account ids.  For Referral Partners, will include
     * all Client Accounts.
     * @param  idAccounts A List of Client Account ids
     * @return Map relating Client Account id to list of Referral Sources
     */
    public static Map<Id, List<Referral_Partner__c>> getActiveReferralSources(Set<Id> idAccounts) {
        Map<Id, List<Referral_Partner__c>> result = new Map<Id, List<Referral_Partner__c>>();

        for (Id id : idAccounts) {
            result.put(id, new List<Referral_Partner__c>());
        }

        List<Referral_Partner__c> rss = [
            SELECT Id, Name, Account__c, Account__r.Name, Branch__c, Comments__c, Commission_Rate__c, DBA_Name__c, Effective_Date__c, Hold__c,
                Hold_Formula__c, Hold_Reason__c, Group_Commission_Type__c, Group_Commission_Rate__c, Group_Description__c, Last_Referral_Date__c,
                Lead__c, Lead_Creation_Date__c, Opportunity__c, Override__c, Referral_Partner_Group__c, Ignore_Record__c,
                OwnerId, Producer__c, RecordTypeId, Referral_Partner__c, Referral_Partner__r.Name, Referral_Partner_Change_Request__c,
                Referral_Partner_ID__c, Referral_Partner_Commission_Type__c, RP_On_Hold__c, Termination_Date__c, Product_Line__c
            FROM Referral_Partner__c
            WHERE RecordTypeId = :idrtClientRP AND Termination_Date__c = null AND (Account__c IN :idAccounts OR Referral_Partner__c IN :idAccounts)
            ORDER BY Effective_Date__c ASC
        ];

        for (Referral_Partner__c rs : rss) {
            if (rs.Account__c != null) {
                if (!result.containsKey(rs.Account__c)) {
                    result.put(rs.Account__c, new List<Referral_Partner__c>());
                }
                result.get(rs.Account__c).add(rs);
            } 
            if (rs.Referral_Partner__c != null) {
                if (!result.containsKey(rs.Referral_Partner__c)) {
                    result.put(rs.Referral_Partner__c, new List<Referral_Partner__c>());
                }

                result.get(rs.Referral_Partner__c).add(rs);
            }                       
        }
        return result;
    }

    /**
     * @description getConvertedAccounts retrieves the Accounts created when the leads
     * were converted.
     * @param  leads List of Leads
     * @return Map of Accounts related to the leads
     */
    @TestVisible
    private static Map<Id, Account> getConvertedAccounts(List<Lead> leads) {
        Map<Id, Account> mapLeadIdToAcccount = new Map<Id, Account>();
        Map<Id, Id> mapAccountIdToLeadIds = new Map<Id, Id>();

        for (Lead l : leads) {
            if (l.convertedAccountId != null) {
                mapAccountIdToLeadIds.put(l.convertedAccountId, l.Id);
            }
        }

        for (Account a : [
            SELECT Id, Name, RecordTypeId, Assigned_Referral_Partner__c, Referral_Partner_Group__c
            FROM Account
            WHERE Id IN :mapAccountIdToLeadIds.keySet()
        ]) {
            mapLeadIdToAcccount.put(mapAccountIdToLeadIds.get(a.Id), a);
        }

        return mapLeadIdToAcccount;
    }

    /**
     * @description getReferralPartners retrieves the Referral Partner account records for the
     * given Client accounts.
     * @param  clients Client Accounts looking at
     * @return A Map relating the Client Account ids to Referral Partner Account objects.
     */
    @TestVisible
    private static Map<Id, Account> getReferralPartners(List<Account> clients) {
        Map<Id, Account> mapClientToRp = new Map<Id, Account>();
        Set<Id> idRPs = new Set<Id>();

        for (Account client : clients) {
            if (client != null && client.Assigned_Referral_Partner__c != null) {
                idRPs.add(client.Assigned_Referral_Partner__c);
            }
        }

        Map<Id, Account> prs = new Map<Id, Account>([
            SELECT Id, Name, RecordTypeId, Assigned_Referral_Partner__c, Producer__c, Referral_Partner_Group__c
            FROM Account
            WHERE Id IN :idRPs
        ]);

        for (Account client : clients) {
            if (client != null) {
                if (prs.containsKey(client.Assigned_Referral_Partner__c)) {
                    mapClientToRp.put(client.Id, prs.get(client.Assigned_Referral_Partner__c));
                }
            }
        }

        return mapClientToRp;
    }

    /**
     * @description terminateReferralSources runs through the list of Referral Sources marking
     * the termination date from today.
     * @param  listRS Referral Sources
     * @return List of changed Referral Sources
     */
    private static List<Referral_Partner__c> terminateReferralSources(List<Referral_Partner__c> listRS) {
        List<Referral_Partner__c> changed = new List<Referral_Partner__c>();

        if (listRS != null && !listRS.isEmpty()) {
            Date today = System.today();

            for (Referral_Partner__c rs : listRS) {
                if (rs.Termination_Date__c == null) {
                    if (rs.Effective_Date__c == today) {
                        rs.Termination_Date__c = rs.Effective_Date__c;
                    }
                    else {
                        rs.Termination_Date__c = today.addDays(-1);
                    }
                    changed.add(rs);
                }
            }
        }

        return changed;
    }

    /**
     * @description sortReferralSources sorts the given list of Referral Sources oldest to newest
     * @param  referralSources List of Referral Sources
     * @return Sorted list of Referral Source
     */
    public static List<Referral_Partner__c> sortReferralSources(List<Referral_Partner__c> referralSources) {
        List<Referral_Partner__c> sorted = new List<Referral_Partner__c>();

        for (Referral_Partner__c rs : referralSources) {
            if (sorted.isEmpty()) {
                sorted.add(rs);
            }
            else {
                Integer index = sorted.size();
                if (rs.Effective_Date__c == null) {
                    index = 0;
                }
                else if (rs.Termination_Date__c == null) {
                    index = sorted.size();
                }
                else {
                    for (index = 0; index < sorted.size(); index++) {
                        if (sorted.get(index).Effective_Date__c != null) {
                            if (rs.Termination_Date__c <= sorted.get(index).Effective_Date__c) {
                                break;
                            }
                        }
                    }
                }

                if (sorted.size() <= index) {
                    sorted.add(rs);
                }
                else {
                    sorted.add(index, rs);
                }
            }
        }

        return sorted;
    }

    /**Updated For User Story 68090
     * @description terminateRelatedReferralSources sets the Termination Data for the
     * active related Referral Sources.
     * @param  terminated Map of Accounts being terminated
     */
    public static void terminateRelatedReferralSources(Map<Id, Account> terminated) {
        if (!terminated.isEmpty()) {
            List<Referral_Partner__c> changedRss = new List<Referral_Partner__c>();
            Map<Id, Client_Cancellation__c> ClientCancellations = new Map<Id, Client_Cancellation__c>();
            for (Client_Cancellation__c cc : [
                SELECT Id, Client__c, Revoke__c, Reason_for_Cancellation__c, Client_Cancellation_Date__c, AM_Approval_Status__c
                FROM Client_Cancellation__c 
                WHERE AM_Approval_Status__c = 'Approved' AND Revoke__c != true AND Client__c IN :terminated.keySet() 
                ORDER BY Client_Cancellation_Date__c ASC
            ]) {
                if(!ClientCancellations.containsKey(cc.Client__c)){
                    ClientCancellations.put(cc.Client__c, cc);
                }
            }
            for (Referral_Partner__c rs : [
                SELECT Id, Effective_Date__c, Termination_Date__c, Account__c, Referral_Partner__c, Referral_Partner_Group__c
                FROM Referral_Partner__c
                WHERE Termination_Date__c = null
                AND (Account__c IN :terminated.keySet() OR Referral_Partner__c IN :terminated.keySet())
            ]) {
                if (rs.Account__c != null) {
                    if (terminated.containsKey(rs.Account__c)) {
                        rs.Termination_Date__c = (ClientCancellations.containsKey(rs.Account__c) && ClientCancellations.get(rs.Account__c).Client_Cancellation_Date__c !=null) ? ClientCancellations.get(rs.Account__c).Client_Cancellation_Date__c : System.today();
                        changedRss.add(rs);
                    }
                }
                else if (rs.Referral_Partner__c != null) {
                    if (terminated.containsKey(rs.Referral_Partner__c)) {
                        rs.Termination_Date__c = (ClientCancellations.containsKey(rs.Referral_Partner__c) && ClientCancellations.get(rs.Referral_Partner__c).Client_Cancellation_Date__c !=null) ? ClientCancellations.get(rs.Account__c).Client_Cancellation_Date__c : System.today();
                        changedRss.add(rs);
                    }
                }
            }
            update changedRss;
        }
    }

    /**
     * @description checkReferralSourcesOnReferralPartners confirms there are Referral Sources
     * for the given Accounts.
     * @param  mapReferralPartners
     */
    public static void checkReferralSourcesOnReferralPartners(Map<Id, Account> mapReferralPartners) {
        Set<Referral_Partner__c> upsertRS = new Set<Referral_Partner__c>();

        // Get all active Clients related to the Referral Partners
        Map<Id, Account> mapClients = new Map<Id, Account>([
            SELECT Id, Name, Assigned_Referral_Partner__c, Producer__c, Commission_Rate__c, Commission_Type__c, Referral_Partner_Group__c
            FROM Account
            WHERE Assigned_Referral_Partner__c IN :mapReferralPartners.keySet()
            AND (RecordType.Name = 'Client' OR RecordType.Name = 'Prospect')
            AND Status__c != 'Terminated'
        ]);

        // Retrieve all Open Referral Sources related to the Accounts
        Map<Id, List<Referral_Partner__c>> mapAccountToRS = new Map<Id, List<Referral_Partner__c>>();

        for (Referral_Partner__c rs : [
            SELECT Id, Name, Account__c, Branch__c, Comments__c, Commission_Rate__c, DBA_Name__c, Effective_Date__c, Hold__c,
                Hold_Formula__c, Hold_Reason__c, Group_Commission_Type__c, Group_Commission_Rate__c, Last_Referral_Date__c,
                Lead__c, Lead_Creation_Date__c, Opportunity__c, Override__c, Split_Commission__c, Referral_Partner_Group__c, Ignore_Record__c,
                OwnerId, Producer__c, RecordTypeId,  Referral_Partner__c, Referral_Partner_Change_Request__c,
                Referral_Partner_ID__c, Referral_Partner_Commission_Type__c, RP_On_Hold__c, Termination_Date__c, Referral_Partner_Group__r.Name
            FROM Referral_Partner__c
            WHERE Termination_Date__c = null
            AND (Account__c IN :mapClients.keySet() OR Referral_Partner__c IN :mapReferralPartners.keySet())
        ]) {
            if (rs.Account__c != null) {
                if (!mapAccountToRS.containsKey(rs.Account__c)) {
                    mapAccountToRS.put(rs.Account__c, new List<Referral_Partner__c>());
                }
                mapAccountToRS.get(rs.Account__c).add(rs);
            }
            else {
                // There should be zero or one for Referral Partners
                if (!mapAccountToRS.containsKey(rs.Referral_Partner__c)) {
                    mapAccountToRS.put(rs.Referral_Partner__c, new List<Referral_Partner__c>());
                }
                mapAccountToRS.get(rs.Referral_Partner__c).add(rs);
            }
        }

        // Get Related Referral Partner Groups
        Set<Id> idGroups = new Set<Id>();
        for (Account rp : mapReferralPartners.values()) {
            if (rp.Referral_Partner_Group__c != null) {
                idGroups.add(rp.Referral_Partner_Group__c);
            }
        }

        Map<Id, Referral_Partner_Group__c> groups = new Map<Id, Referral_Partner_Group__c>();
        if (!idGroups.isEmpty()) {
            groups = new Map<Id, Referral_Partner_Group__c>([
                SELECT Id, Name, Description__c, Group_Commission_Rate__c, Group_Commission_Type__c
                FROM Referral_Partner_Group__c
                WHERE Id IN :idGroups
            ]);
        }

        Referral_Partner__c rs;
        Referral_Partner__c rsNew;

        // Add missing Referral Sources for the Referral Partners
        for (Account rp : mapReferralPartners.values()) {
            Referral_Partner_Group__c rpg = null;
            if (groups.containsKey(rp.Referral_Partner_Group__c)) {
                rpg = groups.get(rp.Referral_Partner_Group__c);
            }

            if (!mapAccountToRS.containsKey(rp.Id)) {
                // Add missing Referral Sources for the Referral Partners
                rsNew = createReferralSourceForReferralPartner(rp, rpg);
                rsNew.Referral_Partner_Commission_Type__c = rp.Commission_Type__c;
                rsNew.Commission_Rate__c = rp.Commission_Rate__c;
                rsNew.Comments__c = 'Referral Partner Activated';
                upsertRS.add( rsNew );
            }
        }

        // Update Clients and add missing Referral Sources
        for (Account client : mapClients.values()) {
            Account rp = mapReferralPartners.get(client.Assigned_Referral_Partner__c);

            if (!mapAccountToRS.containsKey(client.Id)) {
                // Add missing Referral Sources for the Clients
                rsNew = createReferralSourceForClient(client, rp);
                rsNew.Comments__c = 'Referral Partner Activated';
                upsertRS.add( rsNew );
            }
        }

        if (!upsertRS.isEmpty()) {
            upsert (new List<Referral_Partner__c>(upsertRS));
        }
    }

    /**
     * @description checkReferralSourcesOnClients add Referral Sources to given Clients
     * that do not have an active one.
     * @param  mapClients List of Clients checking for Referral Sources
     */
    public static void checkReferralSourcesOnClients(Map<Id, Account> mapClients) {
        Map<Id, Referral_Partner__c> mapRSs = new Map<Id, Referral_Partner__c>();

        for (Referral_Partner__c rs : [
            SELECT Id, Account__c, Referral_Partner__c, Referral_Partner_Group__c
            FROM Referral_Partner__c
            WHERE Account__c IN :mapClients.keySet()
        ]) {
            mapRSs.put(rs.Account__c, rs);
        }

        Set<id> idClientMissing = new Set<Id>();
        Set<Id> idRPs = new Set<Id>();

        for (Id idClient : mapClients.keySet()) {
            if (!mapRSs.containsKey(idClient)) {
                idClientMissing.add(idClient);
                idRPS.add(mapClients.get(idClient).Assigned_Referral_Partner__c);
            }
        }

        if (!idClientMissing.isEmpty()) {
            Map<Id, List<Referral_Partner__c>> mapRpRss = getActiveAccountReferralSources(idRPs);
            List<Referral_Partner__c> newRSs = new List<Referral_Partner__c>();

            for (Id idClient : idClientMissing) {
                Account client = mapClients.get(idClient);

                if (0 < mapRpRss.get(client.Assigned_Referral_Partner__c).size()) {
                    Referral_Partner__c rprs = mapRpRss.get(client.Assigned_Referral_Partner__c).get(0);

					System.debug(LoggingLevel.DEBUG, '~!~!~! ReferralSource_Service.checkReferralSourcesOnClients() New Referral Source for CLIENT: ' + client.Name);
                    Referral_Partner__c newRS = new Referral_Partner__c(
                        RecordTypeId = ReferralSource_Service.idrtClientRP,
                        Account__c = client.Id,
                        Effective_Date__c = System.today(),
                        Referral_Partner_Commission_Type__c = rprs.Referral_Partner_Commission_Type__c,
                        Commission_Rate__c = rprs.Commission_Rate__c,
                        Producer__c = client.Producer__c,
                        Referral_Partner__c = rprs.Referral_Partner__c,
                        RP_on_Hold__c = rprs.RP_on_Hold__c,
                        Split_Commission__c = false,
                        Termination_Date__c = null
                    );

                    newRSs.add(newRs);
                }
            }

            insert newRSs;
        }
    }

    /**
     * @description queryRelatedLeads retrieves Leads with the given Id or Converted Account Id.
     * @param  idLeads    Set of Lead Ids to Retrieve
     * @param  idAccounts Set of Converted Accounts to get Leads from
     * @return A List of Leads
     */
    @TestVisible
    private static List<Lead> queryRelatedLeads(Set<Id> idLeads, Set<Id> idAccounts) {
        Boolean haveLeads = (idLeads != null && !idLeads.isEmpty());
        Boolean haveAccounts = (idAccounts != null && !idAccounts.isEmpty());

        List<Lead> results;

        if (haveLeads) {
            if (haveAccounts) {
                results = [
                    SELECT Id, Name, CreatedDate, ConvertedAccountId
                    FROM Lead
                    WHERE Id IN :idLeads
                    OR ConvertedAccountId IN :idAccounts
                ];
            } else {
                results = [
                    SELECT Id, Name, CreatedDate, ConvertedAccountId
                    FROM Lead
                    WHERE Id IN :idLeads
                ];
            }
        } else {
            if (haveAccounts) {
                results = [
                    SELECT Id, Name, CreatedDate, ConvertedAccountId
                    FROM Lead
                    WHERE ConvertedAccountId IN :idAccounts
                ];
            } else {
                results = new List<Lead>();
            }
        }
        return results;
    }

    /** Added For User Story 68090
     * @description revokeRelatedReferralSources reactive terminated Referral Sources.
     * @param  revokedClients Map of AccountId being revoked and realted Client Cancellation Date
     */
    public static void revokeRelatedReferralSources(Map<Id, Date> revokedClients) {
        if (!revokedClients.isEmpty()) {
            List<Referral_Partner__c> changedRss = new List<Referral_Partner__c>();
            
            for (Referral_Partner__c rs : [
                SELECT Id, Effective_Date__c, Termination_Date__c, Account__c, Referral_Partner__c, Referral_Partner_Group__c
                FROM Referral_Partner__c
                WHERE Termination_Date__c != null
                AND (Account__c IN :revokedClients.keySet() OR Referral_Partner__c IN :revokedClients.keySet())
                AND Termination_Date__c IN :revokedClients.values()
            ]) {
                if ((rs.Account__c != null && revokedClients.containsKey(rs.Account__c) && rs.Termination_Date__c == revokedClients.get(rs.Account__c)) || (rs.Referral_Partner__c != null && revokedClients.containsKey(rs.Referral_Partner__c) && rs.Termination_Date__c == revokedClients.get(rs.Referral_Partner__c))) {
                    rs.Termination_Date__c = null;
                    changedRss.add(rs);
                }
            }
            update changedRss;
        }
    }
}