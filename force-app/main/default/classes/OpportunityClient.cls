/**
 * @description OpportunityClient contains routine for handling Opportunies
 * of RecordType "Client".
 */
public without sharing class OpportunityClient {
    private static final String EMAIL_CLOSED_AM = 'Opportunity_Closed_AM_Email';

    private static final String ERROR_SHELL_OPP = 'Not allowed to create a Creation of Shell opportunity.';
    private static final String ERROR_OTHER_ACTIVE_OPPS = 'Unable to craete Client opportunity because of other active opportunities.';
    private static final String ERROR_CLIENT_OPP = 'Client opportunities must be created on a Prospect account.';

    /**
     * @description makeClient makes a Client Opportunity record.
     * @param  name      Name of the Opportunity
     * @param  idAccount Account identifier
     * @param  closeDate Date closes
     * @return Opportunity
     */
    public static Opportunity makeClient(String name, Id idAccount, Id idOwner) {
        Opportunity opp = new Opportunity(
            RecordTypeId = RecordTypeService.getId('Opportunity', 'Client'),
            OwnerId = idOwner,
            Name = name,
            AccountId = idAccount,
            CloseDate = getCloseDate(),
            StageName = Opportunity_Service.STAGE_PRE_DISCOVERY
        );

        return opp;
    }

    /**
     * @description blockCreation blocks the creating of:
     *     "Creation of Shell" Opportunities
     *     "Client" Opportunties not on Prospect accounts
     * They should be allowed for Testing.
     * @param  newOpps  List of Opportunities to check
     */
    public static void blockCreation(List<Opportunity> newOpps) {
        List<Opportunity> shellOpps = RecordTypeService.getByRecordType(newOpps, Opportunity_Service.OPPORTUNITY, Opportunity_Service.RECORDTYPE_SHELL);

        for (Opportunity opp : shellOpps) {
            opp.addError(ERROR_SHELL_OPP);
        }

        List<Opportunity> clientOpps = RecordTypeService.getByRecordType(newOpps, Opportunity_Service.OPPORTUNITY, Opportunity_Service.RECORDTYPE_CLIENT);

        if (!clientOpps.isEmpty()) {
            Set<Id> idAccounts = new Set<Id>();

            for (Opportunity opp : clientOpps) {
                idAccounts.add(opp.AccountId);
            }

            Map<Id, Account> accounts = new Map<Id, Account>([SELECT Id, RecordType.Name FROM Account WHERE Id IN :idAccounts]);
            Map<Id, Boolean> createable = mayCreate(idAccounts);

            for (Opportunity opp : clientOpps) {
                Account account = accounts.get(opp.AccountId);

                if (!createable.get(account.Id)) {
                    opp.addError(ERROR_OTHER_ACTIVE_OPPS);
                }

                if (account.RecordType.Name != 'Prospect') {
                    opp.addError(ERROR_CLIENT_OPP);
                }
            }
        }
    }

    /**
     * @description buildEmailOppClosedForAM builds an email to send to the Area Manager
     * when an Opportunity has been closed won or lost.
     * @param  idOpp    The identifier of the Opportunity
     * @param  emailAM  The email address of the Area Manager
     * @return An email
     */
    @TestVisible
    private static Messaging.SingleEmailMessage buildEmailOppClosedForAM(Id idOpp, String emailAM) {
        return Email_Service.buildTemplateEmail(
            new List<String>{ emailAM },
            null,
            EMAIL_CLOSED_AM,
            UserInfo.getUserId(),
            idOpp
        );
    }

    /**
     * @description getBranchData retrieves all the Branches and their Area Manager Emails
     * @return Map relating Branch Name to Account object.
     */
    private static Map<String, Account> getBranchData() {
        Map<String, Account> mapBranches = new Map<String, Account>();

        List<Account> listAccounts = [
            SELECT Name, Branch_Manager_Email__c, Branch_Manager__c, Email_on_Closed_Opportunity__c
            FROM Account
            WHERE RecordType.Name = 'BBSI Branch'
        ];

        for (Account account : listAccounts) {
            mapBranches.put(account.Name, account);
        }

        return mapBranches;
    }

    /**
     * @description mayCreate determines if a "Client" Opportunity may be created
     * on the given Prospects.
     * @param  idProspects  Prospect account identifiers
     * @return Map relating Account Id to whether it may create the Opportunity.
     */
    public static Map<Id, Boolean> mayCreate(Set<Id> idProspects) {
        Map<Id, Boolean> result = new Map<Id, Boolean>();

        for (Id id : idProspects) {
            result.put(Id, true);
        }

        Map<Id, Map<String, List<Opportunity>>> accountsToOpps = Opportunity_Service.selectRelatedOpportunities(
            idProspects,
            new Set<String>{ Opportunity_Service.FIELD_STAGE, Opportunity_Service.FIELD_ACCOUNTID }
        );

        for (Id id : idProspects) {
            Map<String, List<Opportunity>> types = accountsToOpps.get(id);

            if (types.containsKey(Opportunity_Service.RECORDTYPE_CLIENT)) {
                for (Opportunity opp : types.get(Opportunity_Service.RECORDTYPE_CLIENT)) {
                    if (opp.StageName != Opportunity_Service.STAGE_CLOSED_LOST) {
                        result.put(Id, false);
                    }
                }
            }

            if (types.containsKey(Opportunity_Service.RECORDTYPE_SHELL)) {
                for (Opportunity opp : types.get(Opportunity_Service.RECORDTYPE_SHELL)) {
                    if (opp.StageName != Opportunity_Service.STAGE_CLOSED_LOST) {
                        result.put(Id, false);
                    }
                }
            }
        }

        return result;
    }

    /**
     * @description setToCreationShell determines if a "Client" Opportunity may be changed
     * to a "Creation of Shell" Opportunity and does if can.
     * @param  newOpps  Opportunities to check
     */
    public static void setToCreationShell(List<Opportunity> newOpps) {
        List<Opportunity> oppClients = (List<Opportunity>) RecordTypeService.getByRecordTypes(
            newOpps,
            'Opportunity',
            new List<String>{ Opportunity_Service.RECORDTYPE_CLIENT }
        );

        if (oppClients.isEmpty()) {
            return;
        }

        Set<Id> idAccounts = new Set<Id>();
        List<Opportunity> workOpps = new List<Opportunity>();

        for (Opportunity opp : oppClients) {
            if (allApproved(opp)) {
                workOpps.add(opp);
                idAccounts.add(opp.AccountId);
            }
        }

        if (!workOpps.isEmpty()) {
            Id idrtProspect = RecordTypeService.getId(Account_Services.ACCOUNT, Account_Services.RECORDTYPE_PROSPECT);
            Id idrtShell = RecordTypeService.getId(Opportunity_Service.OPPORTUNITY, Opportunity_Service.RECORDTYPE_SHELL);

            Map<Id, Account> accounts = new Map<Id, Account>([
                SELECT Id, Name, RecordTypeId, Verified__c, External_Id__c
                FROM Account
                WHERE Id IN :idAccounts
            ]);

            for (Opportunity opp : workOpps) {
                Account account = accounts.get(opp.AccountId);

                if (account.RecordTypeId == idrtProspect) {
                    if (account.Verified__c) {
                        if (String.isBlank(account.External_Id__c)) {
                            opp.RecordTypeId = idrtShell;
                        }
                    }
                }
            }
        }
    }

    /**
     * @description allApproved determines if the Opportunity has full approvals.
     * @param  opp  Opportunity testing
     * @return true if all are approved
     */
    @TestVisible
    private static Boolean allApproved(Opportunity opp) {
        return (
            opp.Credit_Approval_Status__c == 'Approved' &&
            opp.AM_Approval_Status__c == 'Approved' &&
            opp.Contract_Approval_Status__c == 'Approved' &&
            opp.OK_For_Risk_Approval_Status__c == 'Approved'
        );
    }
    
    /**
     * @description getCloseDate determines the CloseDate for a Client Opportunity.
     * @return Date
     */
    public static Date getCloseDate() {
        return Date_Service.nearestNonWeekend(Date.today().addMonths(2));
    }
}