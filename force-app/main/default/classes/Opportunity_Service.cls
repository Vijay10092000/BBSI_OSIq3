/**
 * @description Opportunity_Service contains methods to aid implementation
 * of Opportunity records.
 */
public without sharing class Opportunity_Service {
    public static final String OPPORTUNITY = 'Opportunity';

    public static final String RECORDTYPE_BENEFITS = 'Benefits';
    public static final String RECORDTYPE_BENEFITS_RENEWAL = 'Benefits Renewal';
    public static final String RECORDTYPE_CLIENT = 'Client';
    public static final String RECORDTYPE_SHELL = 'Creation of Shell';
    public static final String RECORDTYPE_PRODUCTS = 'Additional Products';

    public static final String STAGE_PRE_DISCOVERY = 'Pre-Discovery';               // CLIENT / CREATION OF SHELL
    public static final String STAGE_DISCOVERY_MEETING = 'Discovery Meeting';       // CLIENT / CREATION OF SHELL
    public static final String STAGE_BUSINESS_ANALYSIS = 'Business Analysis';       // CLIENT / CREATION OF SHELL
    public static final String STAGE_PROPOSAL = 'Proposal';                         // CLIENT / CREATION OF SHELL
    public static final String STAGE_CONTRACTING = 'Contracting';                   // CLIENT / CREATION OF SHELL
    public static final String STAGE_CLOSED_WON = 'Closed Won';                     // CLIENT / CREATION OF SHELL
    public static final String STAGE_CLOSED_LOST = 'Closed Lost';                   // CLIENT / CREATION OF SHELL
    public static final String STAGE_PENDING_SUBMISSION = 'Pending Submission';     // BENEFITS
    /*Start US-65534 Changes*/
    public static final String STAGE_SUBMITTED_TO_UNDERWRITING = 'Submitted to Underwriting';     // BENEFITS
    public static final String STAGE_ILLUSTRATIVE_ONLY_QUOTE = 'Illustrative Only Quote';     // BENEFITS
    public static final String STAGE_PENDING_UNDERWRITING = 'Pending Underwriting';     // BENEFITS
    public static final String STAGE_PROPOSAL_READY = 'Proposal Ready';     // BENEFITS
    public static final String STAGE_PROPOSED_PENDING_DECISIONS = 'Proposed-Pending Decisions';     // BENEFITS
    public static final String STAGE_ADDITIONAL_DATA_REQUIRED_FOR_SETUP = 'Additional Data Required for Setup';     // BENEFITS
    public static final String STAGE_FINAL_UNDERWRITING = 'Final Underwriting';     // BENEFITS
    /* End US-65534 Changes*/
    public static final String STAGE_UNDERWRITING = 'Underwriting';                 // BENEFITS
    public static final String STAGE_PENDED_UNDERWRITING = 'Pending Underwriting';  // BENEFITS
    public static final String STAGE_RATES_RELEASED = 'Rates Released';             // BENEFITS
    public static final String STAGE_VERVAL_SOLD = 'Verbal Sold';                   // BENEFITS
    public static final String STAGE_PRE_ENROLLMENT = 'Pre-Enrollment';             // BENEFITS
    public static final String STAGE_ENROLLMENT = 'Enrollment';                     // BENEFITS
    public static final String STAGE_POST_ENROLLMENT = 'Post Enrollment';           // BENEFITS
    public static final String STAGE_BENEFITS_CLOSED_WON = 'Benefits Closed Won';   // BENEFITS
    public static final String STAGE_BENEFITS_CLOSED_LOST = 'Benefits Closed Lost'; // BENEFITS
    public static final String STAGE_PRODUCT_INITIATED = 'Product Initiated';       // PRODUCT
    public static final String STAGE_PRODUCT_EVALUATION = 'Product Evaluation';     // PRODUCT
    public static final String STAGE_PRODUCT_PROPOSAL = 'Product Proposal';         // PRODUCT
    public static final String STAGE_PRODUCT_CONTRACTING = 'Product Contracting';   // PRODUCT
    public static final String STAGE_PRODUCT_CLOSED_WON = 'Product Closed Won';     // PRODUCT
    public static final String STAGE_PRODUCT_LOST = 'Product Closed Lost';          // PRODUCT
    public static final String STAGE_BENEFITS_UW_RELEASED = 'UW Released';  // BENEFITS RENEWAL

    public static final String FIELD_STAGE = 'StageName';
    public static final String FIELD_ACCOUNTID = 'AccountId';

    private static final String DEMO_REQUEST_ERROR = 'Missing Contact for requested demo.';

    private static final String EMAIL_CLOSED_AM = 'Opportunity_Closed_AM_Email';

    /**
     * @description updateFieldsFromLead updates opportunities with fields
     * which cannot be mapped in the Lead Covert process.
     * This his a future method so the lead convert finishes first, then the
     * fields are updated. This reduces cascading triggers.
     * @param  ids Ids releated to new Opportunities
     */
    @future
    public static void updateFieldsFromLead(Set<Id> ids) {
        List<Opportunity> updateOpportunities = performFieldMapping(ids);

        if (!updateOpportunities.isEmpty()) {
            update updateOpportunities;
        }
    }

    /**
     * @description performFieldMapping determines if the Opportunity was
     * created from a Lead and pulls data from that Lead to populate fields.
     * Most populating of Opportunity fields will be done with the mapping.
     * This method is for the fields which cannot be mapped.
     * @param  ids Opportunity identifiers
     * @return List of Opportunities which have changes.
     */
    @TestVisible
    private static List<Opportunity> performFieldMapping(Set<Id> ids) {
        Map<Id, Opportunity> mapOpportunities = new Map<Id, Opportunity>([
            SELECT Id, Amount
            FROM Opportunity
            WHERE Id IN :ids
        ]);

        List<Lead> leads = [
            SELECT Id, ConvertedOpportunityId, Estimated_Annual_Billing__c
            FROM Lead
            WHERE ConvertedOpportunityId IN :ids
        ];

        Set<Opportunity> updateOpportunities = new Set<Opportunity>();

        for (Lead l : leads) {
            if (l.Estimated_Annual_Billing__c != null && l.Estimated_Annual_Billing__c > 0) {
                if (mapOpportunities.containsKey(l.ConvertedOpportunityId)) {
                    Opportunity opp = mapOpportunities.get(l.ConvertedOpportunityId);

                    opp.Amount = l.Estimated_Annual_Billing__c;

                    updateOpportunities.add(opp);
                }
            }
        }

        return new List<Opportunity>(updateOpportunities);
    }

    /**
     * @description setFields sets the Opportunity fields directly related to the Account.
     * @param  mapOld   Previous versions of the opportunities
     * @param  listNew  New versions of the opportunities
     */
    public static void setFields(Map<Id, Opportunity> mapOld, List<Opportunity> listNew) {
        Set<Id> idAccounts = new Set<Id>();

        for (Opportunity opp : listNew) {
            idAccounts.add(opp.AccountId);
        }
        idAccounts.remove(null);

        Map<Id, Account> mapAccounts = new Map<Id, Account>([SELECT Id, Name, Name_Branch__c FROM Account WHERE Id IN :idAccounts]);

        for (Opportunity opp : listNew) {
            if (mapAccounts.containsKey(opp.AccountId)) {
                Account account = mapAccounts.get(opp.AccountId);
                opp.Name_Branch__c = account.Name_Branch__c;
            }
        }
    }

    /**
     * @description sendEmailOpportunityClosed sends emails to the Area Manager if an Opportuninty
     * is closes won or lost.
     * @param  mapOld Previous versions of the opportunities
     * @param  mapNew New versions of the opportunities
     */
    public static void sendEmailOpportunityClosed(Map<Id, Opportunity> mapOld, Map<Id, Opportunity> mapNew) {
        Id idrtClient = RecordTypeService.getId(OPPORTUNITY, RECORDTYPE_CLIENT);
        Id idrtCreationOfShell = RecordTypeService.getId(OPPORTUNITY, RECORDTYPE_SHELL);
        List<Opportunity> opps = new List<Opportunity>();

        for (Opportunity opp : mapNew.values()) {
            if (opp.RecordTypeId == idrtClient || opp.RecordTypeId == idrtCreationOfShell) {
                if (opp.StageName == STAGE_CLOSED_WON || opp.StageName == STAGE_CLOSED_LOST) {
                    if (mapOld == null || opp.StageName != mapOld.get(opp.Id).StageName) {
                        opps.add(opp);
                    }
                }
            }
        }

        if (!opps.isEmpty()) {
            sendOpportunityClosedEmails(opps);
        }
    }

    /**
     * @description sendOpportunityClosedEmails creates and sends emails for the
     * Closed won/lost Opportunities.
     * @param  opps  Opportunities which may need emails
     */
    public static void sendOpportunityClosedEmails(List<Opportunity> opps) {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        Map<String, Account> mapBranches = getBranchData();

        for (Opportunity opp : opps) {
            if (mapBranches.containsKey(opp.Branch__c)) {
                Account branch = mapBranches.get(opp.Branch__c);

                if (branch.Branch_Manager_Email__c != null && branch.Email_on_Closed_Opportunity__c) {
                    emails.add(buildEmailOppClosedForAM(opp.Id, branch.Branch_Manager_Email__c));
                }
            }
        }

        Email_Service.send(emails);
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
     * @description firstStage retrieves the name of the first StageName for an Opportunity of the given RecordType.
     * @param  name  Opportunity Record Type name
     * @return First Stage
     * ANONYMOUS CODE
        String nameRecordType = 'Benefits';
        Id idRt = RecordTypeService.getId('Opportunity', nameRecordType);
        String name = Opportunity_Service.firstStage(idRt);
        System.debug(LoggingLevel.INFO, '\n\nOpportunity ' + nameRecordType + ': ' + name + '\n');
     */
    public static String firstStage(String name) {
        switch on name {
            when 'Benefits' {
                return STAGE_SUBMITTED_TO_UNDERWRITING;  // US-65534                   
            }
            when 'Client' {
                return STAGE_PRE_DISCOVERY;
            } 
            when 'Additional Products' {
                return STAGE_PRODUCT_INITIATED;                 
            } 
            when 'Creation of Shell' {
                return STAGE_PENDING_SUBMISSION;
            }
            when 'Benefits Renewal' {
                return STAGE_BENEFITS_UW_RELEASED;
            }
        }

        return null;
    }

    /**
     * @description getStageChanged find Opportunities which have changed stage.
     * @param  oldOpps  Before changes
     * @param  opps     After changes
     * @return Map of New Stage to Opporunities
     */
   public static Map<String, List<Opportunity>> getStageChanged(Map<Id, Opportunity> oldOpps, List<Opportunity> opps) {
       Map<String, List<Opportunity>> result = new Map<String, List<Opportunity>>();

       for (Opportunity opp : opps) {
           if (oldOpps == null || oldOpps.get(opp.Id).StageName != opp.StageName) {
               if (!result.containsKey(opp.StageName)) {
                   result.put(opp.StageName, new List<Opportunity>());
               }

               result.get(opp.StageName).add(opp);
           }
       }

       return result;
   }

    /**
     * @description selectRelatedOpportunities selects the Opportunities related
     * to the given Account identifiers.  The return is a Map relating Account
     * Ids to a Map of record types to the Opportunity
     * @param  idAccount  Account identifiers
     * @param  fields     Fields to read
     * @return Map<Id, Map<String, List<Opportunity>>>
     */
    public static Map<Id, Map<String, List<Opportunity>>> selectRelatedOpportunities(
        Set<Id> idAccounts,
        Set<String> fields
    ) {
        Map<Id, Map<String, List<Opportunity>>> result = new Map<Id, Map<String, List<Opportunity>>>();

        for (Id idAccount : idAccounts) {
            result.put(idAccount, new Map<String, List<Opportunity>>());
        }

        Set<String> callFields = new Set<String>(fields);

        callFields.add('Id');
        callFields.add('Name');
        callFields.add('RecordType.Name');

        String clarification = 'WHERE AccountId IN (' + SOQL_Services.joinIds(idAccounts) + ')';
        Map<Id, SObject> opps = SOQL_Services.callQuery(
            OPPORTUNITY,
            callFields,
            clarification
        );

        for (SObject obj : opps.values()) {
            Opportunity opp = (Opportunity) obj;

            Map<String, List<Opportunity>> rtNames = result.get(opp.AccountId);

            if (!rtNames.containsKey(opp.RecordType.Name)) {
                rtNames.put(opp.RecordType.Name, new List<Opportunity>());
            }

            rtNames.get(opp.RecordType.Name).add(opp);
        }

        return result;
    }

    /**
     * @description getAccountOpportunities retrieves the Account's Opportunities
     * grouped by the Account, then Record Type.
     * @param  idAccounts  Accounts looking at
     * @return Map<Id, Map<Id, Opportunity>>
     */
    public static Map<Id, Map<Id, List<Opportunity>>> getAccountOpportunities(Set<Id> idAccounts) {
        Map<Id, Map<Id, List<Opportunity>>> result = new Map<Id, Map<Id, List<Opportunity>>>();

        for (Id id : idAccounts) {
            result.put(id, new Map<Id, List<Opportunity>>());
        }

        List<Opportunity> opps = [
            SELECT Id, Name, RecordTypeId, AccountId, StageName
            FROM Opportunity
            WHERE AccountId IN :idAccounts
        ];

        for (Opportunity opp : opps) {
            if (!result.get(opp.AccountId).containsKey(opp.RecordTypeId)) {
                result.get(opp.AccountId).put(opp.RecordTypeId, new List<Opportunity>());
            }

            result.get(opp.AccountId).get(opp.RecordTypeId).add(opp);
        }

        return result;
    }

    /**
     * @description makeClientEvent makes a Client Event Opportunity record.
     * @param  name      Name of the Opportunity
     * @param  idAccount Account identifier
     * @param  idOwner   User identifier
     * @return Opportunity
     */
    public static Opportunity makeClientEvent(String name, Id idAccount, Id idOwner) {
        Opportunity opp = new Opportunity(
            RecordTypeId = RecordTypeService.getId(OPPORTUNITY, RECORDTYPE_CLIENT),
            StageName = STAGE_PRE_DISCOVERY,
            OwnerId = idOwner,
            Name = name,
            AccountId = idAccount,
            CloseDate = OpportunityClient.getCloseDate()
        );

        return opp;
    }

    /**
     * @description onClose set fields when the Opportunity is closed.
     * @param  oldOpps   Previous versions of the Opportunities
     * @param  newOpps   New versions of the Opportunities
     */
    public static void onClose(Map<Id, Opportunity> oldOpps, List<Opportunity> newOpps) {
        Set<Id> idAccounts = new Set<Id>();
        List<Opportunity> closed = new List<Opportunity>();
        Date today = Date.today();

        for (Opportunity opp : newOpps) {
            if (opp.IsClosed) {
                if (oldOpps == null || !oldOpps.get(opp.Id).IsClosed) {
                    if (opp.AccountId != null) {
                        closed.add(opp);
                        idAccounts.add(opp.AccountId);
                }
                
                opp.CloseDate = today;
                }
            }
        }

        if (!idAccounts.isEmpty()) {

            Map<Id, Account> mapAccounts = new Map<Id, Account>([
                SELECT Id, Name, Business_Development_Manager__c
                FROM Account
                WHERE Id IN :idAccounts
            ]);

            for (Opportunity opp : closed) {

                if (mapAccounts.containsKey(opp.AccountId)) {
                    opp.BDM_at_Time_of_Close__c = mapAccounts.get(opp.AccountId).Business_Development_Manager__c;
                }
            }
        }
    }

    /**
     * @description newOpportunity sets values on a new Opportunity.
     * @param  opps  List of new Opportunities
     */
    public static void newOpportunity(List<Opportunity> opps) {
        Id idrtClient = RecordTypeService.getId('Opportunity', 'Client');

        Date closeDate = OpportunityClient.getCloseDate();
        
        for (Opportunity opp : opps) {
            if (opp.RecordTypeId == idrtClient) {
                opp.CloseDate = closeDate;
            }
        }
    }
    
    /**
	 * @description getOwners retrieves a mapping from Opportunity Id to Owner's User.
	 * @param  opp  List of Opportunities
	 * @return Map<Id, User>
	 */
	public static Map<Id, User> getOwners(List<Opportunity> opps) {
		Map<Id, User> result = new Map<Id, User>();

		Set<Id> idUsers = new Set<Id>();

		for (Opportunity opp : opps) {
			idUsers.add(opp.OwnerId);
		}

		Map<Id, User> users = User_Services.getUsers(idUsers);

		for (Opportunity opp : opps) {
			result.put(opp.Id, users.get(opp.OwnerId));
		}

		return result;
	}

	/**
	 * @description getOwners retrieves a mapping from Opportunity Id to related Account Owner's User.
	 * @param  opp  List of Opportunities
	 * @return Map<Id, User>
	 */
	public static Map<Id, User> getAccountOwners(List<Opportunity> opps) {
		Map<Id, User> result = new Map<Id, User>();
		
		Set<Id> idAccounts = new Set<Id>();
		Set<Id> idUsers = new Set<Id>();

		for (Opportunity opp : opps) {
			idAccounts.add(opp.AccountId);
		}

		Map<Id, Account> accounts = new Map<Id, Account>([SELECT Id, OwnerId FROM Account WHERE Id IN :idAccounts]);

		for (Account account : accounts.values()) {
			idUsers.add(account.OwnerId);
		}

		Map<Id, User> users = User_Services.getUsers(idUsers);

		for (Opportunity opp : opps) {
			result.put(opp.Id, users.get(accounts.get(opp.AccountId).OwnerId));
		}

		return result;
	}
    
    /** US-65534
     * Retrieves a map of field names to their display types for a sobject.
     * @param objectApiName  The API name of the object to retrieve the field types for.
     * @return A map where the keys are field names (String) and the values are the field display types (Schema.DisplayType).
     */
    public static Map<String, Schema.DisplayType> getOpportunityFieldTypes(String objectApiName) {
        if(String.isBlank(objectApiName)){
            return null;
        }
        // Get the map of fields for the sobject
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objectApiName).getDescribe().fields.getMap();
        
        // Get the map of field display types using the TaskBenefits class method
        Map<String, Schema.DisplayType> fieldTypeMap = TaskBenefits.getFieldTypeMap(fieldMap);
        
        return fieldTypeMap;
    }
}