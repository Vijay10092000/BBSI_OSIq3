/**
 * @description Benefits_Service method to handle the Benefits object.
 */
public without sharing class Benefits_Service {
    // Fetching Benefits RecordType Id
    private static final String BenefitsRT  = OpportunityBenefits_Service.BenefitsRT;
    // Fetching Benefits Renewal RecordType Id
    private static final String BenefitsRenewalRT  = OpportunityBenefits_Service.BenefitsRenewalRT;
    private static Map<Id,Account> oppCompaniesMap = new Map<Id,Account>();
    public static Map<Id,Account> companiesNeedtoUpdate = new Map<Id,Account>();
    @TestVisible
    private static Map<Id,Benefits__c> benefitsNeedtoUpdate = new Map<Id,Benefits__c>();
    @TestVisible
    private static Map<Id,Referral_Partner__c> referralSourcesNeedtoInsert = new Map<Id,Referral_Partner__c>();
    private static final String QUERY_OPPORTUNITIES =
        'SELECT Id, Name,' +
        ' AccountId, ' +
        ' Admin_Factor__c, ' +
        ' Affiliated_Companies__c, ' +
        ' Annual_Pay_Period_Deductions__c, ' +
        ' Benefits_Affiliates__c, ' +
        ' Benefits_Effective_Date__c, ' +
        ' Benefits_Eligible_Employee_Count__c, ' +
        ' Booklet_Language__c, ' +
        ' Booklet_Language_Other__c, ' +
        ' Bucket__c, ' +
        ' Budget_For_Renewal_Increase__c, ' +
        ' Census_Type__c, ' +
        ' Default_Enrollment__c, ' +
        ' Delivery_Method__c, ' +
        ' Do_employees_have_access_to_a_computer__c, ' +
        ' Effective_Month__c, ' +
        ' Employees_Enrolled_in_Medical__c, ' +
        ' Employer_Ancillary_Billing_Method__c, ' +
        ' Employer_Medical_Billing_Method__c, ' +
        ' Enrollment_End_Date__c, ' +
        ' Enrollment_Method__c, ' +
        ' Enrollment_Notes__c, ' +
        ' Enrollment_Start_Date__c, ' +
        ' Fifty_FT_Employees__c, ' +
        ' First_Benefits_Deduction_Date__c, ' +
        ' Have_Common_Ownership__c, ' +
        ' HSA_FSA_Carrier__c, ' +
        ' Is_there_a_benefits_referral_partner__c, ' +
        ' L_H_Producer__c, ' +
        ' L_H_Referral_Partner__c, ' +
        ' Meeting_Type__c, ' +
        ' New_Hire_Waiting_Period__c, ' +
        ' Opted_into_BBSI_ACA_filing_services__c, ' +
        ' Plan_Year_End_Date__c, ' +
        ' Plan_Year_Start__c, ' +
        ' Printed_Booklets_Quantity__c, ' +
        ' Printed_Booklets_Requested__c, ' +
        ' Will_waiting_period_be_waived__c ,' +
        ' Total_Benefits_Classes__c, ' +
        ' Benefits_Class_Notes__c, ' +
        ' Benefits_Administration_Notes__c, ' +
        ' ALE_Required_to_File_ACA__c, ' +
        ' ALE_Affordability_Calc_Method__c, ' +
        ' BBSI_Medical_Plan_Carrier__c, ' +
        ' Final_Bucket__c, ' + // User Story 65532
        ' Final_Admin_Factor__c, ' + // User Story 65532
        ' Final_Bucket_KP__c, ' +
        ' Final_Admin_Factor_KP__c, ' +
        ' Renewal_Bucket_KP__c, ' +
        ' Renewal_Admin_Factor_KP__c, ' +
        ' Account.NumberOfEmployees, '+
        ' Account.Full_Time_Employees__c '+
        ' FROM Opportunity ';

    /**
     * @description onCreate update the Benefits data when it is created
     * @param  benefits List of Benefits records to update.
     */
    @SuppressWarnings('PMD.UnusedLocalVariable, PMD.ApexSOQLInjection')
    public static void onCreate(List<Benefits__c> benefits) {
        Map<Id, Id> mapOppsToBenefits = new Map<Id, Id>();
        Set<Id> idClients = new Set<Id>();

        for (Benefits__c b : benefits) {
            mapOppsToBenefits.put(b.Opportunity__c, b.Id);
        }
        Set<Id> idOpps = mapOppsToBenefits.keySet();

        List<Opportunity> opps = Database.query(QUERY_OPPORTUNITIES + ' WHERE Id IN :idOpps');

        Map<Id, Opportunity> mapOpps = new Map<Id, Opportunity>(opps);

        for (Opportunity opp : opps) {
            idClients.add(opp.AccountId);
        }

        Map<Id, Benefits_Discovery_Questionnaire__c> mapQuestionnaires = getQuestionnaires(mapOpps.values());
        Map<Id, Contact> mapBenefitContacts = BenefitsAffiliatesBenefits.getBenefitContacts(idClients);

        for (Benefits__c b : benefits) {
            if (mapOpps.containsKey(b.Opportunity__c)) {
                Opportunity opp = mapOpps.get(b.Opportunity__c);
                b.Admin_Factor__c = opp.Final_Admin_Factor__c; // opp.Admin_Factor__c; // User Story 65532
                b.Annual_Budget_for_Renewal_Increases__c = opp.Budget_For_Renewal_Increase__c;
                b.Annual_Pay_Period_Deductions__c = opp.Annual_Pay_Period_Deductions__c;
                b.Benefits_Affiliates__c = opp.Benefits_Affiliates__c;
                b.Benefits_Effective_Date__c = opp.Benefits_Effective_Date__c;
                b.Benefits_Eligible_Employee_Count__c = opp.Benefits_Eligible_Employee_Count__c;
                b.Booklet_Language__c = opp.Booklet_Language__c;
                b.Booklet_Language_Other__c = opp.Booklet_Language_Other__c;
                b.Bucket__c = opp.Final_Bucket__c; // opp.Bucket__c; // User Story 65532
                b.Census_Type__c = opp.Census_Type__c;
                b.AccountId__c = opp.AccountId;
                b.Default_Enrollment__c = opp.Default_Enrollment__c;
                b.Delivery_Method__c = opp.Delivery_Method__c;
                b.Do_employees_have_access_to_a_computer__c = opp.Do_employees_have_access_to_a_computer__c;
                b.Effective_Month__c = opp.Effective_Month__c;
                b.Employees_Enrolled_in_Medical__c = opp.Employees_Enrolled_in_Medical__c;
                b.Employer_Ancillary_Billing_Method__c = opp.Employer_Ancillary_Billing_Method__c;
                b.Employer_Medical_Billing_Method__c = opp.Employer_Medical_Billing_Method__c;
                b.Enrollment_End_Date__c = opp.Enrollment_End_Date__c;
                b.Enrollment_Method__c = opp.Enrollment_Method__c;
                b.Enrollment_Notes__c = opp.Enrollment_Notes__c;
                b.Enrollment_Start_Date__c = opp.Enrollment_Start_Date__c;
                b.Fifty_FT_Employees__c = opp.Fifty_FT_Employees__c;
                b.First_Benefits_Deduction_Date__c = opp.First_Benefits_Deduction_Date__c;
                b.HSA_FSA_Carrier__c = opp.HSA_FSA_Carrier__c;
                b.Is_there_common_ownership__c = opp.Have_Common_Ownership__c;
                b.L_H_Producer__c = opp.L_H_Producer__c;
                b.L_H_Referral_Partner__c = opp.L_H_Referral_Partner__c;
                b.Meeting_Type__c = opp.Meeting_Type__c;
                b.Name = opp.Name.length() > 77 ? opp.Name.substring(0,77) + '...' : opp.Name;      //66153
                b.New_Hire_Waiting_Period__c = opp.New_Hire_Waiting_Period__c;
                b.Opportunity__c = opp.Id;
                b.Opted_into_BBSI_ACA_filing_services__c = opp.Opted_into_BBSI_ACA_filing_services__c;
                b.Plan_Year_End__c = opp.Plan_Year_End_Date__c;
                b.Plan_Year_Start__c = opp.Plan_Year_Start__c;
                b.Printed_Booklets_Quantity__c = opp.Printed_Booklets_Quantity__c;
                b.Printed_Booklets_Requested__c = opp.Printed_Booklets_Requested__c;
                b.Will_waiting_period_be_waived__c = opp.Will_waiting_period_be_waived__c;
                b.Benefits_Classes__c = opp.Total_Benefits_Classes__c; //  65532
                b.Benefits_Class_Notes__c = opp.Benefits_Class_Notes__c; //  65532
                b.ALE_Required_to_File_ACA__c = opp.ALE_Required_to_File_ACA__c;  // BUG-68414
                b.ALE_Affordability_Calc_Method__c = opp.ALE_Affordability_Calc_Method__c;  // BUG-68414
                b.Benefits_Administration_Notes__c = opp.Benefits_Administration_Notes__c; // 65532
                b.BBSI_Medical_Plan_Carrier__c = opp.BBSI_Medical_Plan_Carrier__c;   // 65532
                b.Bucket_KP__c = opp.Final_Bucket_KP__c; //65532
                b.Admin_Factor_KP__c = opp.Final_Admin_Factor_KP__c; // 65532
                b.BBSI_Benefits_Original_Effective_Date__c = opp.Benefits_Effective_Date__c; //65532

                if (mapBenefitContacts.containsKey(opp.AccountId)) {
                    b.LH_Contact_Name__c = mapBenefitContacts.get(opp.AccountId)?.Id;
                }

                if (mapQuestionnaires.containsKey(opp.Id)) {
                    Benefits_Discovery_Questionnaire__c questionnaire = mapQuestionnaires.get(opp.Id);

                    b.Affiliated_Companies__c = questionnaire.Affiliated_Companies__c;
                    b.Any_Employees_Currently_Ill__c = questionnaire.Any_Employees_Currently_Ill__c;
                }
            }

            createBenefitsPlanJunctions(mapOppsToBenefits);
        }
    }

    /**
     * @description createJunctions creates matching records from Benefits to Benefits Plans
     * as the Opporutnity had.
     * @param  mapOppsToBenefits  Map relating Opportunity Id to Benefits Ids
     */
    @TestVisible
    private static void createBenefitsPlanJunctions(Map<Id, Id> mapOppsToBenefits) {
        List<Benefits_Plan_Benefits_Junction__c> newJunctions = new List<Benefits_Plan_Benefits_Junction__c>();

        for (Benefits_Plan_Opp_Junction__c junction : [
            SELECT Id, Opportunity__c, Benefits_Plan__c
            FROM Benefits_Plan_Opp_Junction__c
            WHERE Opportunity__c IN :mapOppsToBenefits.keySet()
        ]) {
            if (mapOppsToBenefits.containsKey(junction.Opportunity__c)) {
                Id idBenefits = mapOppsToBenefits.get(junction.Opportunity__c);

                if (idBenefits != null) {
                    newJunctions.add(
                        new Benefits_Plan_Benefits_Junction__c(
                            Benefits_Plan__c = junction.Benefits_Plan__c,
                            Benefits__c = idBenefits
                        )
                    );
                }
            }
        }

        insert newJunctions;
    }

    /**
     * @description updateBenefitsOnStageChange handles changes to a Benefits records based
     * on changes to a Benefits Opportunity.
     * on the Benefits object.
     * @param  mapOld   Opportunities before changes
     * @param  listNew lOpportunities after changes
     */
    public static void updateBenefitsOnStageChange(Map<Id, Opportunity> mapOld, List<Opportunity> listNew) {
        List<Account> accountsNeedToUpdate = New List<Account>();
        Map<Id,Account> accountsNeedToUpdateMap = New Map<Id,Account>();
        List<Opportunity> benefitsClosedWonOpps = New List<Opportunity>();
        List<Opportunity> benefitsClosedLostOpps = New List<Opportunity>();
        List<Opportunity> renewalBenefitsClosedWonOpps = New List<Opportunity>();
        List<Opportunity> renewalBenefitsClosedLostOpps = New List<Opportunity>();

        Map<String, List<Opportunity>> mapStageChange = Opportunity_Service.getStageChanged(mapOld, listNew);
        if (!mapStageChange.isEmpty()) {
            TaskBenefits.updateTasksByOpportunity(mapOld, mapStageChange);

            //List<Opportunity> closed = new List<Opportunity>();
            List<Opportunity> closedWon = new List<Opportunity>();
            List<Opportunity> closedLost = new List<Opportunity>();

            if (mapStageChange.containsKey(Opportunity_Service.STAGE_BENEFITS_CLOSED_WON)) {
                closedWon = mapStageChange.get(Opportunity_Service.STAGE_BENEFITS_CLOSED_WON);
                benefitsClosedWonOpps = RecordTypeService.getByRecordType( closedWon,
                                                                            Opportunity_Service.OPPORTUNITY,
                                                                            Opportunity_Service.RECORDTYPE_BENEFITS);
                renewalBenefitsClosedWonOpps = RecordTypeService.getByRecordType( closedWon,
                                                                                    Opportunity_Service.OPPORTUNITY,
                                                                                    Opportunity_Service.RECORDTYPE_BENEFITS_RENEWAL);
                //closed.addAll(closedWon);
                updateAccountsOnBenefitsClosedWon(closedWon);
                onClosedWonCreateBenefits(benefitsClosedWOnOpps);
                onClosedWonUpdateBenefits(mapOld,renewalBenefitsClosedWonOpps);
                onClosedWonCreateReferralSource(closedWon);
            }
            if (mapStageChange.containsKey(Opportunity_Service.STAGE_BENEFITS_CLOSED_LOST)) {
                closedLost = mapStageChange.get(Opportunity_Service.STAGE_BENEFITS_CLOSED_LOST);
                benefitsClosedLostOpps = RecordTypeService.getByRecordType( closedLost,
                                                                            Opportunity_Service.OPPORTUNITY,
                                                                            Opportunity_Service.RECORDTYPE_BENEFITS);
                /*renewalBenefitsClosedLostOpps = RecordTypeService.getByRecordType( closedLost,
                Opportunity_Service.OPPORTUNITY,
                Opportunity_Service.RECORDTYPE_BENEFITS_RENEWAL);*/
                //closed.addAll(closedLost);
                onClosedLostCancelTasks(closedLost);
                updateAccountsOnBenefitsClosedLost(closedLost);
                clearBenefitsOpportunityAccountFields(benefitsClosedLostOpps);
            }
        }
    }

    /**
     * @description getQuestionnaires retrieves the questionnaires related to the Benefits Opportunities.
     * @param  records Opportunity records
     * @return Map relating Opportunity Id to questionaire
     */
    @TestVisible
    private static Map<Id, Benefits_Discovery_Questionnaire__c> getQuestionnaires(List<Opportunity> records) {
        Map<Id, Benefits_Discovery_Questionnaire__c> result = new Map<Id, Benefits_Discovery_Questionnaire__c>();

        List<Id> idOpps = new List<Id>();

        for (Opportunity opp : records) {
            idOpps.add(opp.Id);
        }

        for (Benefits_Discovery_Questionnaire__c questionnaire : [
            SELECT Id, Name, OpportunityId__c, Affiliated_Companies__c, Any_Employees_Currently_Ill__c
            FROM Benefits_Discovery_Questionnaire__c
            WHERE OpportunityId__c IN :idOpps
        ]) {
            result.put(questionnaire.OpportunityId__c, questionnaire);
        }

        return result;
    }

    /**
     * @description getBenefits retrieve a Map relating an Opportunity Id to a Benefits record.
     * @param  opps List of Opportunities to get Benefits records for
     * @return Map<Id, Benefits_Discovery_Questionnaire__c>
     */
    @TestVisible
    @SuppressWarnings('PMD.ApexSOQLInjection')
    private static Map<Id, Benefits__c> getBenefits(List<Opportunity> opps) {
        Map<Id, Benefits__c> result = new Map<Id, Benefits__c>();

        if (opps == null || opps.isEmpty()) {
            return result;
        }

        List<Id> idOpps = new List<Id>();

        for (Opportunity opp : opps) {
            if (opp.RecordTypeId == BenefitsRT) {
                idOpps.add(opp.Id);
            }
        }

        String query = createBenefitsQuery(idOpps);

        List<Benefits__c> queriedBenefits = Database.query(query);

        for (Benefits__c benefits : queriedBenefits) {
            if (benefits.Opportunity__c != null) {
                result.put(benefits.Opportunity__c, benefits);
            }
        }

        return result;
    }

    /**
     * @description createBenefitsQuery creates a query to read all values of the Benefits objects.
     * @param  idOpps Ids of Opportunities related to the Benefits objects.
     * @return Query string
     */
    @TestVisible
    private static String createBenefitsQuery(List<Id> idOpps) {
        return 'SELECT Id,OwnerId,IsDeleted,Name,CreatedDate,CreatedById,LastModifiedDate, ' +
            ' LastModifiedById,SystemModstamp,LastActivityDate,LastViewedDate,LastReferencedDate, ' +
            ' Annual_Pay_Period_Deductions__c,Benefits_Affiliates__c,Benefits_Effective_Date__c, ' +
            ' Benefits_Eligible_Employee_Count__c,Booklet_Language_Other__c,Booklet_Language__c, ' +
            ' Default_Enrollment__c,Delivery_Method__c,Effective_Month__c,Employer_Ancillary_Billing_Method__c, ' +
            ' Employer_Medical_Billing_Method__c,Enrollment_Method__c,Enrollment_Start_Date__c, ' +
            ' First_Benefits_Deduction_Date__c,Meeting_Type__c,New_Hire_Waiting_Period__c,Opportunity__c, ' +
            ' Opted_into_BBSI_ACA_filing_services__c,Over_50_Full_Time_employees__c,Plan_Year_End__c,Plan_Year_Start__c, ' +
            ' Printed_Booklets_Requested__c,Benefits_Class_Description__c,Close_Date__c,Latest_Arrival_Date__c, ' +
            ' Waive_initial_enrollment_waiting_period__c,Is_there_common_ownership__c,Admin_Factor__c, ' +
            ' Annual_Budget_for_Renewal_Increases__c,Any_Employees_Currently_Ill__c,Bucket__c,Census_Type__c, ' +
            ' Client_DBA__c,Do_employees_have_access_to_a_computer__c,Employees_Enrolled_in_Medical__c, ' +
            ' Enrollment_End_Date__c,Fifty_FT_Employees__c,HSA_FSA_Carrier__c,L_H_Producer__c,L_H_Referral_Partner__c, ' +
            ' Printed_Booklets_Quantity__c,Will_waiting_period_be_waived__c,Active_Employees_Full_Time__c, ' +
            ' Active_Employees_Part_Time__c,Business_Entity_Type__c,Client_Id__c, ' + // Active_Employees__c,
            ' Company_Headquarter_State__c,L_H_Commission_Rate__c,L_H_Commission_Type__c,Enrollment_Notes__c, ' +
            ' Affiliated_Companies__c,AccountId__c,LH_Contact_Name__c,LH_Contact_Email__c,LH_Contact_Mobile__c, ' +
            ' LH_Contact_Phone__c, Is_there_a_benefits_referral_partner__c ' +
            ' FROM Benefits__c ' +
            ' WHERE Opportunity__c IN (\'' +
            String.join(idOpps, '\',\'') +
            '\')';
    }

    /**
     ** USER STORY 51029 Functionality changes: When a benefits opportunity or a benefits renewal opportunity is changed to benefits closed won, if 'is there a benefits referral partner' is yes, and there is a referral partner for benefits and producer for benefits selected on the opportunity, those values should populate the referral partner for benefits and producer for benefits on the related client account record and the benefits object.
     * @description onClosedWonCreateBenefits creates Benefits records based
     * on the given Closed Won Benefits Opportunities.
     * @param  opps  Benefits Opportunities
     */
    @TestVisible
    private static void onClosedWonCreateBenefits(List<Opportunity> opps) {
        //Set<Id> idAccounts = new Set<Id>();
        if (!opps.isEmpty()) {
            Map<Id, Benefits__c> mapBenefits = getBenefits(opps);

            for (Opportunity opp : opps) {
                if (!mapBenefits.containsKey(opp.Id)) {
                    mapBenefits.put(opp.Id, new Benefits__c());
                }

                //idAccounts.add(opp.AccountId);
            }

            Id idCurrUser = UserInfo.getUserId();

            for (Opportunity opp : opps) {
                if (mapBenefits.containsKey(opp.Id)) {
                    Id idRepresentative = (opp.Benefits_Specialist__c) == null
                        ? idCurrUser
                        : opp.Benefits_Specialist__c;

                    Benefits__c benefits = mapBenefits.get(opp.Id);
                    benefits.OwnerId = idRepresentative;
                    benefits.AccountId__c = opp.AccountId;
                    benefits.Opportunity__c = opp.Id;
                    benefits.Effective_Month__c = opp.Effective_Month__c;
                    benefits.Benefits_Type__c = opp.Benefits_Type__c;
                    benefits.Benefits_Coordinator__c = opp.Benefits_Coordinator__c;
                    benefits.Benefits_Specialist__c = opp.Benefits_Specialist__c;
                    benefits.Employees_Enrolled_in_Medical__c = opp.Employees_Enrolled_in_Medical__c;
                    benefits.Subscriber_Count__c = opp.Estimated_Subscriber_Count__c;
                    benefits.Annualized_Medical_Premium__c = opp.Quoted_Annualized_Medical_Premium__c;
                    benefits.Benefits_Effective_Date__c = opp.Benefits_Effective_Date__c;
                    benefits.Effective_Month__c = opp.Effective_Month__c;
                    benefits.Is_there_a_benefits_referral_partner__c = opp.Is_there_a_benefits_referral_partner__c;
                    benefits.Benefits_Affiliates__c = opp.Benefits_Affiliates__c;
                    benefits.Benefits_Affiliated_Companies__c = opp.Benefits_Affiliated_Companies__c;
                    benefits.Active_Employees_All_Affiliates__c = opp.Active_Employees_All_Affiliates__c;
                    benefits.Full_Time_Employees_All_Affiliates__c = opp.Full_Time_Employees_All_Affiliates__c;
                    benefits.Part_Time_Employees_All_Affiliates__c = opp.Part_Time_Employees_All_Affiliates__c;
                    benefits.BBSI_Benefits_Renewal_Date__c = opp.Insurance_Medical_Renewal__c;
                    benefits.EE_Enrolled_Count_All_Affiliates__c = opp.EE_Enrolled_Count_All_Affiliates__c;
                    benefits.Benefits_Participation__c = opp.Benefits_Participation__c;
                    benefits.Benefits_Consultant__c = opp.Benefits_Consultant__c;
                    benefits.L_H_Referral_Partner__c = opp.L_H_Referral_Partner__c;
                    benefits.L_H_Producer__c = opp.L_H_Producer__c;
                    System.debug(
                        '**************** onClosedWonCreateBenefits Some new BENEFITS values:' +
                        '\n benefits.OwnerId = ' + benefits.OwnerId +
                        '\n benefits.AccountId__c = ' + benefits.AccountId__c +
                        '\n benefits.Opportunity__c = ' + benefits.Opportunity__c +
                        '\n benefits.Benefits_Coordinator__c = ' + benefits.Benefits_Coordinator__c +
                        '\n benefits.Benefits_Specialist__c = ' + benefits.Benefits_Specialist__c +
                        '\n benefits.Benefits_Affiliates__c = ' + benefits.Benefits_Affiliates__c +
                        '\n benefits.Benefits_Affiliated_Companies__c = ' + benefits.Benefits_Affiliated_Companies__c
                    );
                    benefitsNeedtoUpdate.put(benefits.Id == null ? opp.Id : benefits.Id, benefits);
                }
            }
            /*if(mapBenefits.isEmpty()){
                upsert mapBenefits.values();
            }*/
        }
    }

    /**
     * @description onClosedLostCancelTasks cancells Tasks related to the given Benefits Opportunities.
     * @param  records  Benefits Opportunities
     */
    @TestVisible
    private static void onClosedLostCancelTasks(List<Opportunity> records) {
        Set<Id> idOpps = new Set<Id>();

        for (Opportunity opp : records) {
            if(opp.RecordTypeId == BenefitsRT || opp.RecordTypeId == BenefitsRenewalRT){
                idOpps.add(opp.Id);
            }
        }

        List<Task> tasks = [SELECT Id, Status FROM Task WHERE WhatId IN :idOpps AND IsClosed = FALSE];

        for (Task task : tasks) {
            task.Status = 'Cancelled';
        }

        upsert tasks;
    }
    /**
     * @description clearBenefitsOpportunityAccountFields clears related Account fields
     * when a Benefits Opportunity is closed won or lost.
     * @param  closed  Closed Opportunities
     */
    @TestVisible
    private static void clearBenefitsOpportunityAccountFields(List<Opportunity> closed) {
        if (!oppCompaniesMap.IsEmpty()) {
            for (Opportunity opp : closed) {
                if (oppCompaniesMap.containsKey(opp.AccountId)) {
                    Account client = companiesNeedtoUpdate.containsKey(opp.AccountId) ? companiesNeedtoUpdate.get(opp.AccountId) : oppCompaniesMap.get(opp.AccountId);
                    client.BBSI_Benefits__c = false;
                    client.Client_Benefits__c = false;
                    client.Client_Benefits_Renewal_Month__c = null;
                    companiesNeedtoUpdate.put(client.Id,client);
                }
            }
        }
    }

    /**
     * @description createInitialTasks creates the Tasks for a new Benefits record.
     * @param  benefits  List of new Benefits__c
     */
    public static void createInitialTasks(List<Benefits__c> benefits) {
        Date today = Date.today();
        Id idOwner;

        Set<Id> idOpps = new Set<Id>();

        for (Benefits__c b : benefits) {
            idOpps.add(b.Opportunity__c);
        }

        Map<Id, Opportunity> opps = new Map<Id, Opportunity>([
            SELECT Id, Name, Benefits_Consultant__c
            FROM Opportunity
            WHERE Id IN :idOpps
        ]);

        List<Task> tasks = new List<Task>();

        for (Benefits__c b : benefits) {
            idOwner = null;

            if (opps.containsKey(b.Opportunity__c)) {
                idOwner = opps.get(b.Opportunity__c).Benefits_Consultant__c;
            }
            if (idOwner == null) {
                idOwner = b.OwnerId;
            }

            tasks.add(
                Task_Service.createTask(
                    'Task',
                    null,
                    b.Id,
                    idOwner,
                    'Update benefits page/object in Salesforce on the client account',
                    '',
                    Date_Service.addWeekdays(today, 30)
                )
            );
        }

        insert tasks;
    }

    /**
     * @description getAccountsMap return Account records
     * @param  listNew Opportunities after changes
     */
    public static Map<Id,Account> getAccountsMap(List<Opportunity> listNew) {
        Set<Id> accountIds = new Set<Id>();
        for(Opportunity opp: listNew){
            accountIds.add(opp.AccountId);
        }
        return Account_Services.getAccountsMap(accountIds);
    }

    /**
     * @description handleBenefitsOpportunityChanges handles changes on Opportunity records.
     * @param  mapOld   Opportunities before changes
     * @param  listNew Opportunities after changes
     */
    public static void handleBenefitsOpportunityChanges(Map<Id, Opportunity> mapOld, List<Opportunity> listNew) {
        companiesNeedtoUpdate = new Map<Id,Account>();
        benefitsNeedtoUpdate = new Map<Id,Benefits__c>();
        oppCompaniesMap = getAccountsMap(listNew);
        updateBenefitsOnStageChange(mapOld,listNew);
        if(!benefitsNeedtoUpdate.isEmpty()){
            upsert benefitsNeedtoUpdate.values();
        }
        if(!referralSourcesNeedtoInsert.isEmpty()){
            insert referralSourcesNeedtoInsert.values();
        }
        if(!companiesNeedtoUpdate.isEmpty()){
            update companiesNeedtoUpdate.Values();
        }
    }

    /**
     * @description selectAccountsByAffiliates reads the Account records for the given ids.
     * @param idAffiliates Affiliates getting Accounts for.
     * @return Map<Id, List<Account>>
     */
    public static Map<Id, List<Account>> selectAccountsByAffiliates(Set<Id> idAffiliates) {
        Map<Id, List<Account>> result = new Map<Id, List<Account>>();
        if (!idAffiliates.IsEmpty()) {
            for(Benefits_Affiliates__c ba:[select Id, (Select Id, BBSI_Benefits_Renewal_Date__c From Accounts__r) from Benefits_Affiliates__c where Id IN :idAffiliates]){
                if (ba.Accounts__r != null) {
                    result.put(ba.Id,ba.Accounts__r);
                }
            }
        }
        return result;
    }

    /**
     * @description selectBenefitsByAffiliates reads the Account records for the given ids.
     * @param accIds Id's for Accounts.
     * @return Map<Id, List<Account>>
     */
    public static Map<Id, Benefits__c> selectBenefitsByAffiliates(Set<Id> accIds) {
        Map<Id, Benefits__c> result = new Map<Id, Benefits__c>();
        if (!accIds.IsEmpty()) {
            for (Account acc
                : [SELECT Id,
                        (SELECT Id, Bucket__c, Admin_Factor__c, BBSI_Benefits_Renewal_Date__c,
                                EE_Enrolled_Count_All_Affiliates__c, Benefits_Participation__c
                            FROM BenefitsClient__r
                            WHERE Is_there_common_ownership__c = 'Yes'
                                AND Benefits_Affiliates__c != null
                            ORDER BY LastModifiedDate DESC LIMIT 1)
                    FROM Account
                    WHERE Id IN :accIds])
            {
                if (acc.BenefitsClient__r != null && acc.BenefitsClient__r.size()>0) {
                    result.put(acc.Id, acc.BenefitsClient__r[0]);
                }
            }
        }
        return result;
    }

    /**
     * @description updateAccountsOnBenefitsClosedWon handles changes to a Account records based
     * on changes to a Opportunity.
     * on the Accounts object.
     * @param  listNew Opportunities after changes
     */
    public static void updateAccountsOnBenefitsClosedWon(List<Opportunity> listNew) {
        Set<Id> renewalAffiliatesIds = new Set<Id>();
        Map<Id, Opportunity> renewalAffiliatesIdOppMap = new Map<Id, Opportunity>();

        Set<Id> accountIds =  new Set<Id>();
        for (Opportunity opp:listNew) {
            // 51376 - Removed condition for BenefitsRenewalRT since we want BBSI_Benefits_Renewal_Date__c to set for BenefitsRT too.
            if (opp.Benefits_Affiliates__c != null) {
                renewalAffiliatesIds.add(opp.Benefits_Affiliates__c);
                renewalAffiliatesIdOppMap.put(opp.Benefits_Affiliates__c, opp);
            }
        }
        if (!renewalAffiliatesIds.isEmpty()) {

            // Bug 51432 - BBSI_Benefits_Renewal_Date__c was not set correctly. Also some requirements changes had to be handled
            // Here are the requirements
            /*
             * BBSI Benefits Renewal Date field on primary and affiliated accounts
             * and the Benefits object displays the actual date entered into the
             * Master Plan Renewal Date field of the Benefits opportunity.
             * Then the Benefits Renewal Opportunity is created 90 days prior to
             * the client's BBSI Benefits Renewal Date.  The Master Plan Renewal Date
             * on the benefits renewal opportunity should be the BBSI Benefits Renewal Date +1 year.
             * After the benefits renewal opportunity is changed to benefits closed won,
             * the Master Plan Renewal Date field is populated to the BBSI Benefits Renewal Date field
             * on the Benefits object and any Primary/Affiliated accounts.
             */
            Map<Id, Account> accMap = BenefitsAffiliatesAccount.selectAccountsByAffiliates(renewalAffiliatesIds);
            Map<Id, Id> renewalAffiliatesIdAccIdMap = new Map<Id, Id>();
            for (Account acc : accMap?.values()) {
                renewalAffiliatesIdAccIdMap.put(acc.Id, acc.Benefits_Affiliates__c);
            }
            for (Account acc : accMap?.values()) {
                Account client = companiesNeedtoUpdate.containsKey(acc.Id)? companiesNeedtoUpdate.get(acc.Id) : acc;
                Opportunity opp = renewalAffiliatesIdAccIdMap.get(client.Id) == null ? null : renewalAffiliatesIdOppMap.get(renewalAffiliatesIdAccIdMap.get(client.Id));
                AccountIds.add(acc.Id);
                //added following if condition for USER STORY 51029
                if(Account_Services.isPrimary(client) && opp.Is_there_a_benefits_referral_partner__c == 'Yes') {
                    client.Referral_Partner_for_Benefits__c = opp.L_H_Referral_Partner__c;
                    client.Producer_for_Benefits__c = opp.L_H_Producer__c;
                }
                client.Is_there_a_benefits_referral_partner__c = opp.Is_there_a_benefits_referral_partner__c; // 61594
                client.Benefits_Effective_Date__c = opp.Benefits_Effective_Date__c; // BUG 63075
                client.BBSI_Benefits_Renewal_Date__c = (opp != null) ? opp.Insurance_Medical_Renewal__c : client.BBSI_Benefits_Renewal_Date__c.addYears(1); // Bug 51432
                client.Is_Benefits_Renewal_Opp_Generated__c = FALSE; // Reset flag to be used next year
                companiesNeedtoUpdate.put(acc.Id,client);
            }
        }
        for (Opportunity opp: listNew) {
            Account client = companiesNeedtoUpdate.containsKey(opp.AccountId)? companiesNeedtoUpdate.get(opp.AccountId) : oppCompaniesMap.get(opp.AccountId);
            if (opp.RecordTypeId == BenefitsRenewalRT) {
                // client.BBSI_Benefits_Renewal_Date__c = client.BBSI_Benefits_Renewal_Date__c.addYears(1); // Commented for 51432
                client.Is_Benefits_Renewal_Opp_Generated__c = FALSE; // Reset flag to be used next year
            }
            if(opp.RecordTypeId == BenefitsRT || opp.RecordTypeId == BenefitsRenewalRT)
            {
                //added following if condition for USER STORY 51029
                if( opp.Is_there_a_benefits_referral_partner__c == 'Yes') {
                    client.Referral_Partner_for_Benefits__c = opp.L_H_Referral_Partner__c;
                    client.Producer_for_Benefits__c = opp.L_H_Producer__c;
                }
                client.BBSI_Benefits__c = TRUE; // Bug 62513 - Setting for Commission Rate is calculated correctly.
                client.Is_there_a_benefits_referral_partner__c = opp.Is_there_a_benefits_referral_partner__c; // 61594
                client.Benefits_Effective_Date__c = opp.Benefits_Effective_Date__c;
                client.BBSI_Benefits_Renewal_Date__c = opp.Insurance_Medical_Renewal__c; // 51432
                companiesNeedtoUpdate.put(client.Id,client);
            }
        }
    }

    /**
     * @description updateAccountsOnBenefitsClosedLost handles changes to a Account records based
     * on changes to a Opportunity.
     * on the Accounts object.
     * @param  listNew Opportunities after changes
     */
    public static void updateAccountsOnBenefitsClosedLost(List<Opportunity> listNew) {
        Set<Id> AffiliatesIds = new Set<Id>();
        Set<Id> idAccounts = new Set<Id>();
        for (Opportunity opp:listNew) {
            if (opp.RecordTypeId == BenefitsRenewalRT && opp.Benefits_Affiliates__c != null) {
                AffiliatesIds.add(opp.Benefits_Affiliates__c);
            }
            if (opp.RecordTypeId == BenefitsRenewalRT) {
                idAccounts.add(opp.AccountId);
            }
        }
        Map<Id, Benefits__c> benefitsByAccounts = selectBenefitsByAccounts(idAccounts);

        if (!AffiliatesIds.isEmpty()) {
            for (Account acc:BenefitsAffiliatesAccount.selectAccountsByAffiliates(AffiliatesIds)?.values()) {
                Account client = companiesNeedtoUpdate.containsKey(acc.Id)? companiesNeedtoUpdate.get(acc.Id) : acc;
                client.BBSI_Benefits__c = false;
                client.BBSI_Benefits_Renewal_Date__c = null;
                client.Is_Benefits_Renewal_Opp_Generated__c = FALSE;
                companiesNeedtoUpdate.put(acc.Id,client);

                // 51442 - Block to clear Benefits_Type__c on Benefits
                if (benefitsByAccounts.containsKey(acc.Id)) {
                    Benefits__c benefits = benefitsByAccounts.get(acc.Id);
                    benefits = benefitsNeedtoUpdate.containsKey(benefits.Id) ? benefitsNeedtoUpdate.get(benefits.Id) : benefits;
                    benefits.Benefits_Type__c = null;
                    benefitsNeedtoUpdate.put(benefits.Id, benefits);
                }
            }
        }

        // 51442
        for (Opportunity opp: listNew) {
            if (opp.RecordTypeId == BenefitsRenewalRT) {
                Account client = companiesNeedtoUpdate.containsKey(opp.AccountId)? companiesNeedtoUpdate.get(opp.AccountId) : oppCompaniesMap.get(opp.AccountId);
                client.BBSI_Benefits__c = false;
                client.BBSI_Benefits_Renewal_Date__c = null;
                client.Is_Benefits_Renewal_Opp_Generated__c = FALSE;
                companiesNeedtoUpdate.put(client.Id,client);

                // Block to clear Benefits_Type__c on Benefits
                if (benefitsByAccounts.containsKey(opp.AccountId)) {
                    Benefits__c benefits = benefitsByAccounts.get(opp.AccountId);
                    benefits = benefitsNeedtoUpdate.containsKey(benefits.Id) ? benefitsNeedtoUpdate.get(benefits.Id) : benefits;
                    benefits.Benefits_Type__c = null;
                    benefitsNeedtoUpdate.put(benefits.Id, benefits);
                }
            }
        }
    }

    /**
     ** USER STORY 51029 Functionality changes: When a benefits opportunity or a benefits renewal opportunity is changed to benefits closed won, if 'is there a benefits referral partner' is yes, and there is a referral partner for benefits and producer for benefits selected on the opportunity, those values should populate the referral partner for benefits and producer for benefits on the related client account record and the benefits object. 
     * @description onClosedWonUpdateBenefits Update Benefits records based
     * on the given Closed Won Benefits Opportunities.
     * @param  opps  Benefits Opportunities
     */
    @TestVisible
    private static void onClosedWonUpdateBenefits(Map<Id, Opportunity> mapOld,List<Opportunity> opps) {
        if (!opps.isEmpty()) {
            Set<Id> idAccounts = new Set<Id>();

            for (Opportunity opp : opps) {
                idAccounts.add(opp.AccountId);
            }

            Map<Id, Benefits__c> benefitsByAffiliates = selectBenefitsByAccounts(idAccounts);

            for (Opportunity opp : opps) {
                if (benefitsByAffiliates.containsKey(opp.AccountId)) {
                    Benefits__c benefits = benefitsByAffiliates.get(opp.AccountId);
                    benefits.Admin_Factor__c = Sobject_Services.getValue(opp.Renewal_Admin_Factor__c, 0);
                    benefits.Bucket__c = Sobject_Services.getValue(opp.Renewal_Bucket__c, 0); // 51533

                    if (benefits.BBSI_Benefits_Renewal_Date__c != null) {
                        // benefits.BBSI_Benefits_Renewal_Date__c = benefits.BBSI_Benefits_Renewal_Date__c.addYears(1); // Commented for 51432
                        benefits.BBSI_Benefits_Renewal_Date__c = opp.Insurance_Medical_Renewal__c; // Bug 51432
                    }
                    benefits.EE_Enrolled_Count_All_Affiliates__c = Sobject_Services.getValue(opp.EE_Enrolled_Count_All_Affiliates__c,0);
                    benefits.Benefits_Participation__c = Sobject_Services.getValue(opp.Benefits_Participation__c,0);

                    benefits.Is_there_a_benefits_referral_partner__c = opp.Is_there_a_benefits_referral_partner__c; // 51534
                    benefits.L_H_Referral_Partner__c = opp.L_H_Referral_Partner__c; // 51534
                    benefits.L_H_Producer__c = opp.L_H_Producer__c; // 51534
                    benefits.BBSI_Medical_Plan_Carrier__c = opp.BBSI_Medical_Plan_Carrier__c; // 65532
                    benefits.Bucket_KP__c = opp.Renewal_Bucket_KP__c; // 65532
                    benefits.Admin_Factor_KP__c = opp.Renewal_Admin_Factor_KP__c;  // 65532
                    benefits.ALE_Required_to_File_ACA__c = opp.ALE_Required_to_File_ACA__c;  // BUG-68249
                    benefits.ALE_Affordability_Calc_Method__c = opp.ALE_Affordability_Calc_Method__c;  // BUG-68249
                    benefits.Benefits_Classes__c = opp.Total_Benefits_Classes__c;  // BUG-68249
                    benefits.Benefits_Class_Notes__c = opp.Benefits_Class_Notes__c;  // BUG-68249



                    benefitsNeedtoUpdate.put(benefits.Id, benefits);
                }
            }
        }
    }

    /**
     * @description selectBenefitsByAccounts reads the Account records for the given ids.
     * @param accIds Id's for Accounts.
     * @return Map<Id, List<Account>>
     */
    public static Map<Id, Benefits__c> selectBenefitsByAccounts(Set<Id> accIds) {
        Map<Id, Benefits__c> result = new Map<Id, Benefits__c>();
        if (!accIds.IsEmpty()) {
            for (Account acc
                : [SELECT Id,
                        (SELECT Id, Bucket__c, Admin_Factor__c, BBSI_Benefits_Renewal_Date__c,
                                EE_Enrolled_Count_All_Affiliates__c, Benefits_Participation__c,
                                Benefits_Type__c, Benefits_Specialist__c, Opportunity__c,
                                Benefits_Coordinator__c, ALE_Required_to_File_ACA__c,
                                ALE_Affordability_Calc_Method__c, Benefits_Classes__c,
                                Benefits_Class_Notes__c
                            FROM BenefitsClient__r
                            ORDER BY LastModifiedDate DESC LIMIT 1)
                    FROM Account
                    WHERE Id IN :accIds])
            {
                if (acc.BenefitsClient__r != null && acc.BenefitsClient__r.size()>0) {
                    result.put(acc.Id, acc.BenefitsClient__r[0]);
                }
            }
        }
        return result;
    }
    /**
     * @description setBranch updates the branch field of the Benefits object
     * when the AccountID is set or changed.
     * on the Benefits object.
     * @param  mapOld   Opportunities before changes
     * @param  listNew lOpportunities after changes
     */
    public static void setBranch(Map<Id, Benefits__c> mapOld, List<Benefits__c> listNew) {
        Set<Id> idAccounts = new Set<Id>();

        for (Benefits__c benefits : listNew) {
            if (mapOld == null || (mapOld.get(benefits.Id).AccountId__c != benefits.AccountId__c)) {
                if (benefits.AccountId__c == null) {
                    benefits.Branch_Name__c = null;
                } else {
                    idAccounts.add(benefits.AccountId__c);
                }
            }
        }

        if (!idAccounts.isEmpty()) {
            Map<Id, Account> accounts = new Map<Id, Account>([
                SELECT Id, Name, Prospect_Branch__r.Name FROM Account WHERE Id IN :idAccounts
            ]);

            for (Benefits__c benefits : listNew) {
                if (accounts.containsKey(benefits.AccountId__c)) {
                    benefits.Branch_Name__c = accounts.get(benefits.AccountId__c).Prospect_Branch__r.Name;
                }
            }
        }
    }

    /**  USER STORY 51029
     * When a benefits opportunity or a benefits renewal opportunity is changed to benefits closed won A referral source should be generated for the referral partner for benefits and the client account, and added to their related list quick links. 
     * * @param  oppList List of Closed Won Opportunities
    */
    @TestVisible
    private static void onClosedWonCreateReferralSource(List<opportunity> oppList){
        for (opportunity opp : oppList) {
            Account client = companiesNeedtoUpdate.containsKey(opp.AccountId)? companiesNeedtoUpdate.get(opp.AccountId) : oppCompaniesMap.get(opp.AccountId);
            if(opp.Is_there_a_benefits_referral_partner__c == 'Yes') {
                Boolean isFound = false;
                Referral_Partner__c newRS = new Referral_Partner__c(
                    OwnerId = client.OwnerId,
                    Opportunity__c = opp.Id,
                    RecordTypeId = ReferralSource_Service.idrtClientRP,
                    Account__c = opp.AccountId,
                    Referral_Partner__c = opp.L_H_Referral_Partner__c,
                    Producer__c = opp.L_H_Producer__c,
                    Effective_Date__c = opp.Benefits_Effective_Date__c,
                    Benefits_Affiliated_Companies__c = opp.Benefits_Affiliated_Companies__c //BUG 63071
                );

                // Bug 62513 - Setting below 2 properties so that Commission Rate is calculated correctly.
                //client.BBSI_Benefits__c = TRUE;
                //client.Referral_Partner_for_Benefits__c = newRS.Referral_Partner__c;

                Referral_Partner_Commissions__mdt commissionRate = ReferralPartnerChange_Process.getMatchingCommission(client, ReferralPartnerChange_Const.PLTYPE_BENEFITS);
                newRS.Commission_Rate__c = commissionRate.Commission_Rate__c;
                newRS.Referral_Partner_Commission_Type__c = commissionRate.Commission_Type__c;
                referralSourcesNeedtoInsert.put(opp.Id, newRS);
            }
        }
    }
}