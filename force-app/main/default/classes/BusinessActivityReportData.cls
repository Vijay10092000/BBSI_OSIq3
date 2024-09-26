/**
 * @description BusinessActivityReportData holds the data which will be returned
 * to the BusinessActivityReport component.
 */
@SuppressWarnings('PMD.ExcessivePublicCount, PMD.AvoidSystemDebugUsage, PMD.TooManyFields')
public without sharing class BusinessActivityReportData {
    public DateTime dtQuarterFirstDay;
    public DateTime dtQuarterLastDay;
    public Date dQuarterFirstDay;
    public Date dQuarterLastDay;
    public List<DateRange> dateRanges;

    // Creator Information
    public String creatorName;
    public Id creatorId;
    public Id creatorProfileId;
    public Boolean isCreatorReportManager;
    public Boolean isCreatorAreaManager;
    public Boolean forWholeYear;

    // Map of Branches working on, null if no issue
    public Map<Id, Account> workingBranches;

    public Map<Id, Id> idUsersToBranch;
    public Map<Id, User> mapBranchUsers;

    // Map of User Id to Name of users report is for
    public Map<Id, String> reportUsersInfo;

    // Business Quarter of the Report
    public BusinessQuarter bQuarter;

    // Data related to the User reporting on
    public Map<Integer, ActivityData> activityData;

    // Goals for the User reporting on
    public Business_Activity_Goal__c activityGoal;

    // Include those who are not BDMs, but are in the Business Developer Manager field
    public Boolean includeAllRecords = false;
    public Boolean includeAllBDMs = false;
    public Boolean includeAllBranches = false;

    /**
     * @description ActivityData holds the information for a single week
     * of the report.
     */
    @SuppressWarnings('PMD.ApexDoc')
    public class ActivityData {
        public Date dateStart { get; public set; }
        public Date dateEnd { get; public set; }
        public Integer week { get; public set; }

        public Integer newLeads { get; set; }
        public Integer discoveryMeetings { get; set; }
        public Integer newClients { get; set; }
        public Integer rpTouchesInPerson { get; set; }
        public Integer rpTouchesVirtual { get; set; }
        public Integer producerTracks { get; set; }
        public Integer producerTrackAttendees { get; set; }
        public Integer newRPs { get; set; }

        /* -- Manually Entered -- */
        public Integer numberEvents { get; set; }
        public Integer rpPlans { get; set; }
        public Integer numberLostClients { get; set; }
        public Integer numberLostLeads { get; set; }
        public Integer numberAddedWSE { get; set; }

        public ActivityData(Date dateStart, Date dateEnd, Integer week) {
            if (dateEnd < dateStart) {
                Date dateTemp = dateStart;
                dateStart = dateEnd;
                dateEnd = dateTemp;
            }

            this.dateStart = dateStart;
            this.dateEnd = dateEnd;
            this.week = week;
            this.newLeads = 0;
            this.discoveryMeetings = 0;
            this.newClients = 0;
            this.rpTouchesInPerson = 0;
            this.rpTouchesVirtual = 0;
            this.producerTracks = 0;
            this.producerTrackAttendees = 0;
            this.newRPs = 0;
            this.numberEvents = 0;
            this.rpPlans = 0;
            this.numberLostClients = 0;
            this.numberLostLeads = 0;
            this.numberAddedWSE = 0;
        }
    }

    /**
     * @description BusinessActivityReportData constructor
     */
    public BusinessActivityReportData() {
        creatorName = UserInfo.getName();
        creatorId = UserInfo.getUserId();
        creatorProfileId = UserInfo.getProfileId();
    }

    /**
     * @description readData reads all the data required for the report.
     * @param  idBDMs              User Ids for report
     * @param  idBranches          Account Ids for report
     * @param  year                Year of report
     * @param  quarter             Quarter of report (1-4 or 0 for full year)
     * @param  includeAllRecords   Include all records
     * @param  includeAllBDMs      Include all BDM Records
     * @param  includeAllBranches  Include All branches
     */
    @SuppressWarnings('PMD.ExcessiveParameterList')
    public void readData(
        List<String> idBDMs,
        List<String> idBranches,
        Integer year,
        Integer quarter,
        Boolean includeAllRecords,
        Boolean includeAllBDMs,
        Boolean includeAllBranches
    ) {
        setReportBuilderInfo(includeAllRecords, includeAllBDMs, includeAllBranches);
        setRange(year, quarter);
        setBranches(idBranches);
        setBranchUsers();
        setUserInfo(idBDMs);

        createActivityData();

        readGoal();
        readNewLeads();
        readMeetings();
        readNewClients();
        readRpTouches();
        readRpPlans();
        readProducerTracks();
        readLostClients();

        dumpData();
    }

    /**
     * @description setReportBuilderInfo establick some of the base information
     * for the report.  Determines which branches are being used for the report.
     * @param  includeAllRecords    Include all records
     * @param  includeAllBDMs       Include all BDMs
     * @param  includeAllBranches   Include all Branch
     */
    @TestVisible
    private void setReportBuilderInfo(
        Boolean includeAllRecords,
        Boolean includeAllBDMs,
        Boolean includeAllBranches
    ) {
        Map<Id, Boolean> checkManager = CustomPermission_Service.checkUserCustomPermission(
            'Business_Activity_Report_Manager',
            new Set<Id>{ creatorId }
        );

        this.isCreatorReportManager = checkManager.get(creatorId);
        this.isCreatorAreaManager = Profile_Service.isAreaManager(creatorProfileId);

        this.includeAllRecords = includeAllRecords;
        this.includeAllBDMs = includeAllBDMs;
        this.includeAllBranches = includeAllBranches;
    }

    /**
     * @description setRange sets the business quarter working on
     * @param  year    Year of range
     * @param  quarter Quarter of range
     */
    @TestVisible
    private void setRange(Integer year, Integer quarter) {
        Date today = Date.today();

        if (year == null) {
            year = today.year();
        }

        if (quarter == null) {
            quarter = BusinessQuarter.getQuarter(today);
        }

        bQuarter = new BusinessQuarter(year, quarter);
        forWholeYear = (bQuarter.quarter == 0);

        dQuarterFirstDay = bQuarter.getQuarterStart();
        dQuarterLastDay = bQuarter.getQuarterEnd();
        dtQuarterFirstDay = DateTime.newInstance(
            dQuarterFirstDay.year(),
            dQuarterFirstDay.month(),
            dQuarterFirstDay.day(),
            0,
            0,
            0
        );
        dtQuarterLastDay = DateTime.newInstance(
            dQuarterLastDay.year(),
            dQuarterLastDay.month(),
            dQuarterLastDay.day(),
            23,
            59,
            59
        );
    }

    /**
     * @description setUserInfo retrieves information about the users this
     * report is for
     * @param  idBDMs User identifiers
     */
    @TestVisible
    private void setUserInfo(List<String> idBDMs) {
        reportUsersInfo = new Map<Id, String>();
        idUsersToBranch = new Map<Id, Id>();
        Id idBranch;

        if (includeAllBDMs) {
            for (User user : UserBdms.getAllReportBdms(false).values()) {
                reportUsersInfo.put(user.Id, user.Name);

                idBranch = getBranchId(user.Branch_ID__c);
                if (idBranch != null) {
                    idUsersToBranch.put(user.Id, idBranch);
                }
            }
        } else if (includeAllRecords) {
            for (User user : UserBdms.getAllReportBdms(false).values()) {
                reportUsersInfo.put(user.Id, user.Name);

                idBranch = getBranchId(user.Branch_ID__c);
                if (idBranch != null) {
                    idUsersToBranch.put(user.Id, idBranch);
                }
            }
        } else {
            for (User user : [SELECT Id, Name, Branch_ID__c FROM User WHERE Id = :idBDMs]) {
                reportUsersInfo.put(user.Id, user.Name);

                idBranch = getBranchId(user.Branch_ID__c);
                if (idBranch != null) {
                    idUsersToBranch.put(user.Id, idBranch);
                }
            }
        }
    }

    @TestVisible
    private void createActivityData() {
        dateRanges = bQuarter.getWeekRangesForQuarter();

        activityData = new Map<Integer, ActivityData>();

        for (Integer index = 1; index <= dateRanges.size(); ++index) {
            DateRange range = dateRanges.get(index - 1);
            activityData.put(index, new ActivityData(range.dateFrom, range.dateTo, index));
        }
    }

    /**
     * @description readGoal retrieves the goals for the working year and quarter.
     * If whole year being processed, then user Quarter 4's goals.
     */
    @TestVisible
    private void readGoal() {
        Integer useQuarter = (bQuarter.quarter == 0) ? 4 : bQuarter.quarter;

        activityGoal = BusinessActivityGoal.getGoalFor(
            includeAllRecords,
            reportUsersInfo.keySet(),
            workingBranches.keySet(),
            dQuarterLastDay.year(),
            useQuarter
        );
    }

    /**
     * @description readNewLeads reads Leads for the ownerid in the desired range.
     */
    @TestVisible
    private void readNewLeads() {
        Integer week;

        List<Lead> leads = queryNewLeads();

        for (Lead lead : leads) {
            week = BusinessQuarter.getWeek(lead.CreatedDate.dateGMT(), forWholeYear);

            if (lead.RecordType.Name == 'Client Lead') {
                if (includeAllRecords || reportUsersInfo.containsKey(lead.Business_Development_Manager__c)) {
                    activityData.get(week).newLeads += 1;
                }
            } else if (lead.RecordType.Name == 'Referral Partner Lead') {
                activityData.get(week).newRPs += 1;
            }
        }
    }

    /**
     * @description queryNewLeads.
     * Number of new leads.  The data pulled for this row should fall into the date
     * ranges for weeks 1 through 13, and is based on:
     *     - Client Leads owned by the BDM (Lead_Record_Type__c is Client Lead)
     *     - Using the lead creation date field (CreatedDate)
     * New RPs Contacted: The data pulled for this row should fall into the date ranges
     * for weeks 1 through 13, and is based on
     *     - Referral Partner Leads owned by the BDM (Lead_Record_Type__c is Referral Partner Lead)
     *     - Using the lead creation date field (CreatedDate)
     * @return List of Leads
     */
    @TestVisible
    private List<Lead> queryNewLeads() {
        List<Lead> result = new List<Lead>();
        List<Lead> leads;

        if (includeAllRecords) {
            leads = (List<Lead>) [
                SELECT Id, Name, OwnerId, Business_Development_Manager__c, CreatedDate, RecordType.Name, Branch__c
                FROM Lead
                WHERE
                    CreatedDate >= :dtQuarterFirstDay
                    AND CreatedDate <= :dtQuarterLastDay
                    AND (IsConverted = TRUE
                    OR IsConverted = FALSE)
                    AND LeadSource != 'Televerde'
            ];
        } else {
            leads = (List<Lead>) [
                SELECT Id, Name, OwnerId, Business_Development_Manager__c, CreatedDate, RecordType.Name, Branch__c
                FROM Lead
                WHERE
                    (OwnerId IN :reportUsersInfo.keySet()
                    OR Business_Development_Manager__c IN :reportUsersInfo.keySet())
                    AND CreatedDate >= :dtQuarterFirstDay
                    AND CreatedDate <= :dtQuarterLastDay
                    AND (IsConverted = TRUE
                    OR IsConverted = FALSE)
                    AND LeadSource != 'Televerde'
            ];
        }

        for (Lead lead : leads) {
            if (workingBranches.containsKey(lead.Branch__c)) {
                result.add(lead);
            }
        }

        return result;
    }

    /**
     * @description readMeetings
     */
    @TestVisible
    private void readMeetings() {
        Set<Id> idOpportunities = new Set<Id>();
        Integer week;

        List<Opportunity> opportunities = queryDiscoveryMeetings();

        for (Opportunity opportunity : opportunities) {
            week = BusinessQuarter.getWeek(opportunity.CreatedDate.dateGMT(), forWholeYear);

            activityData.get(week).discoveryMeetings += 1;

            idOpportunities.add(opportunity.Id);
        }

        List<OpportunityFieldHistory> histories = queryDiscoveryMeetingsFieldHistory();

        for (OpportunityFieldHistory history : histories) {
            if (
                workingBranches.containsKey(history.Opportunity.Account.Prospect_Branch__c) &&
                !idOpportunities.contains(history.OpportunityId) &&
                (history.OldValue == 'First Meeting' ||
                history.OldValue == 'Discovery Meeting')
            ) {
                // Opportunity is not already in the list
                week = BusinessQuarter.getWeek(history.CreatedDate.dateGMT(), forWholeYear);

                activityData.get(week).discoveryMeetings += 1;

                idOpportunities.add(history.OpportunityId);
            }
        }
    }

    @TestVisible
    private List<Opportunity> queryDiscoveryMeetings() {
        List<Opportunity> result = new List<Opportunity>();
        List<Opportunity> opportunities;

        if (includeAllRecords) {
            opportunities = (List<Opportunity>) [
                SELECT Id, Name, CreatedDate, Account.Prospect_Branch__c, Account.Business_Development_Manager__c
                FROM Opportunity
                WHERE
                    CreatedDate >= :dtQuarterFirstDay
                    AND CreatedDate <= :dtQuarterLastDay
                    AND (StageName = 'First Meeting'
                    OR StageName = 'Discovery Meeting')
                ORDER BY CreatedDate
            ];
        } else {
            opportunities = (List<Opportunity>) [
                SELECT Id, Name, CreatedDate, Account.Prospect_Branch__c, Account.Business_Development_Manager__c
                FROM Opportunity
                WHERE
                    Account.Business_Development_Manager__c IN :reportUsersInfo.keySet()
                    AND CreatedDate >= :dtQuarterFirstDay
                    AND CreatedDate <= :dtQuarterLastDay
                    AND (StageName = 'First Meeting'
                    OR StageName = 'Discovery Meeting')
                ORDER BY CreatedDate
            ];
        }

        for (Opportunity opp : opportunities) {
            if (workingBranches.containsKey(opp.Account.Prospect_Branch__c)) {
                result.add(opp);
            }
        }

        return result;
    }

    /**
     * @description queryDiscoveryMeetingsFieldHistory
     * Number of Discovery Meetings for opportunities
     *   - Opportunities for which the BDM accessing the report is listed as the BDM on the prospect
     *   - This should include all opportunities that were in the Discovery Meeting stage at any point
     *     during weeks 1 through 13 of the quarter, regardless of their current stage. This is based
     *     on the last modified date of the Stage History.
     * @see // https://developer.salesforce.com/docs/atlas.en-us.api.meta/api/sforce_api_objects_opportunityfieldhistory.htm
     * @return List of OpportunityFieldHistory
     */
    @TestVisible
    @SuppressWarnings('PMD.OperationWithLimitsInLoop')
    private List<OpportunityFieldHistory> queryDiscoveryMeetingsFieldHistory() {
        List<OpportunityFieldHistory> result;

        if (includeAllRecords) {
            result = (List<OpportunityFieldHistory>) [
                SELECT Id, CreatedDate, OpportunityId, OldValue, Opportunity.Account.Prospect_Branch__c
                FROM OpportunityFieldHistory
                WHERE
                    Field = 'StageName'
                    AND CreatedDate >= :dtQuarterFirstDay
                    AND CreatedDate <= :dtQuarterLastDay
                ORDER BY CreatedDate
            ];
        } else {
            result = (List<OpportunityFieldHistory>) [
                SELECT Id, CreatedDate, OpportunityId, OldValue, Opportunity.Account.Prospect_Branch__c
                FROM OpportunityFieldHistory
                WHERE
                    Opportunity.Account.Business_Development_Manager__c IN :reportUsersInfo.keySet()
                    AND Field = 'StageName'
                    AND CreatedDate >= :dtQuarterFirstDay
                    AND CreatedDate <= :dtQuarterLastDay
                ORDER BY CreatedDate
            ];
        }

        return result;
    }

    /**
     * @description readNewClients runs through the Account objects counting
     * new clients for the quarter
     */
    @TestVisible
    private void readNewClients() {
        Integer week;

        List<Account> clients = queryNewClients();

        for (Account client : clients) {
            week = BusinessQuarter.getWeek(client.Start_Date__c, forWholeYear);
            activityData.get(week).newClients += 1;
        }
    }

    /**
     * @description queryNewClients
     * Number of new clients
     *   - The fields for Weeks 1 through 13 for this row will be populated based on the Policy
     *     or Liability Start Date field (Start_Date__c)
     *   - It will only include Accounts with the Account Record Type of Client
     *   - It should include both Active, Pending and Terminated clients (from API name Status__c)
     * @return List of Client Accounts
     */
    private List<Account> queryNewClients() {
        List<Account> clients;

        if (includeAllRecords) {
            clients = (List<Account>) [
                SELECT Id, Name, Start_Date__c, Prospect_Branch__c, Business_Development_Manager__c
                FROM Account
                WHERE
                    (RecordType.Name = 'Client' OR RecordType.Name = 'Terminated')
                    AND Start_Date__c != NULL
                    AND Start_Date__c >= :dQuarterFirstDay
                    AND Start_Date__c <= :dQuarterLastDay
                    AND Prospect_Branch__c IN :workingBranches.keySet()
                ORDER BY Start_Date__c
            ];
        } else {
            clients = (List<Account>) [
                SELECT Id, Name, Start_Date__c, Prospect_Branch__c, Business_Development_Manager__c
                FROM Account
                WHERE
                    (RecordType.Name = 'Client' OR RecordType.Name = 'Terminated')
                    AND Business_Development_Manager__c IN :reportUsersInfo.keySet()
                    AND Start_Date__c != NULL
                    AND Start_Date__c >= :dQuarterFirstDay
                    AND Start_Date__c <= :dQuarterLastDay
                    AND Prospect_Branch__c IN :workingBranches.keySet()
                ORDER BY Start_Date__c
            ];
        }

        return clients;
    }

    /**
     * @description readRpPlans reads and counts the Referal Partner plans (Blueprints)
     * for the time period.
     */
    @TestVisible
    private void readRpPlans() {
        Set<Id> idOwners;

        if (includeAllRecords) {
            idOwners = mapBranchUsers.keySet();
        } else {
            idOwners = reportUsersInfo.keySet();
        }

        List<Business_Blueprint_RP__c> plans = [
            SELECT Id, LastModifiedDate, Client__c, Client__r.OwnerId
            FROM Business_Blueprint_RP__c
            WHERE
                Client__r.OwnerId IN :idOwners
                AND LastModifiedDate >= :dtQuarterFirstDay
                AND LastModifiedDate <= :dtQuarterLastDay
            ORDER BY LastModifiedDate DESC
        ];

        Integer week;
        for (Business_Blueprint_RP__c plan : plans) {
            week = BusinessQuarter.getWeek(plan.LastModifiedDate.dateGMT(), forWholeYear);
                activityData.get(week).rpPlans += 1;
        }
    }

    /**
     * @description readRpTouches runs through the Task and Event objects counting
     * the ones for the quarter
     */
    @TestVisible
    private void readRpTouches() {
        Integer week;

        List<Event> events = queryEventActivities();

        for (Event event : events) {
            week = BusinessQuarter.getWeek(event.ActivityDate, forWholeYear);
            if (event.Virtual_Event__c) {
                activityData.get(week).rpTouchesVirtual += 1;
            } else {
                activityData.get(week).rpTouchesInPerson += 1;
            }
        }

        /** User Story 33596 Cancelled
        for (Task task : queryTaskActivities()) {
            week = BusinessQuarter.getWeek(task.Date_Completed__c, forWholeYear);
            if (task.Virtual_Event__c) {
                activityData.get(week).rpTouchesVirtual += 1;
            } else {
                activityData.get(week).rpTouchesInPerson += 1;
            }
        }
        **/
    }

    /**
     * @description queryEventActivities
     * @return List of Events
     */
    private List<Event> queryEventActivities() {
        Set<Id> idOwners;

        if (includeAllRecords) {
            idOwners = mapBranchUsers.keySet();
        } else {
            idOwners = reportUsersInfo.keySet();
        }

        return [
            SELECT Id, OwnerId, ActivityDate, Type, AccountId, Account.RecordType.Name, Virtual_Event__c, WhatId, What.Name
            FROM Event
            WHERE
                OwnerId IN :idOwners
                AND ActivityDate >= :bQuarter.dateRange.dateFrom
                AND ActivityDate <= :bQuarter.dateRange.dateTo
                AND (Account.RecordType.Name = 'Referral Partner' OR Who.RecordType.Name = 'Referral Partner Lead')
                AND Type IN ('Meeting', 'Core Meeting', 'Other', 'Phone Call', 'Deep Dive', 'First Meeting')
            ORDER BY ActivityDate DESC
        ];
    }

    /**
     * @description queryTaskActivities
     * Number of referral partner touches
     *   - For Tasks (API name task), the report will include all tasks for which the due date
     *    (field name ActivityDate) is during weeks 1 through 13 of the current quarter
     * @return List of Tasks
     */
    private List<Task> queryTaskActivities() {
        List<Task> result = new List<Task>();
        List<Task> tasks;
        Set<Id> idOwners;

        if (includeAllRecords) {
            idOwners = mapBranchUsers.keySet();
        } else {
            idOwners = reportUsersInfo.keySet();
        }

        if (includeAllRecords) {
            tasks = [
                SELECT Id, Type, ActivityDate, Account.Prospect_Branch__c, OwnerId, Virtual_Event__c
                FROM Task
                WHERE
                    OwnerId IN :idOwners
                    AND Date_Completed__c >= :bQuarter.dateRange.dateFrom
                    AND Date_Completed__c <= :bQuarter.dateRange.dateTo
                    AND (Account.RecordType.Name = 'Referral Partner' OR Who.RecordType.Name = 'Referral Partner Lead')
                    AND Type IN ('Call', 'Email', 'Other')
                ORDER BY ActivityDate
            ];
        } else {
            tasks = [
                SELECT Id, Type, ActivityDate, Date_Completed__c , Account.Prospect_Branch__c, OwnerId, Virtual_Event__c
                FROM Task
                WHERE
                    OwnerId IN :idOwners
                    AND Date_Completed__c >= :bQuarter.dateRange.dateFrom
                    AND Date_Completed__c <= :bQuarter.dateRange.dateTo
                    AND (Account.RecordType.Name = 'Referral Partner' OR Who.RecordType.Name = 'Referral Partner Lead')
                    AND Type IN ('Call', 'Email', 'Other')
                ORDER BY ActivityDate
            ];
        }

        for (Task task : tasks) {
            if (workingBranches.containsKey(task.Account.Prospect_Branch__c)) {
                result.add(task);
            }
        }

        return result;
    }

    /**
     * @description queryEvents
     * Number of referral partner touches
     *   - Activities (API name event, standard object in Salesforce) with a Type of Core Meeting,
     *     Meeting, Phone Call, Other, Trade Show, or Deep Dive will be included if their start date
     *    (field name StartDateTime) is within weeks 1 through 13 of the current quarter
     * @return List of Events
     */
    private List<Event> queryEvents() {
        List<Event> events;
        List<String> types = new List<String>{ 'Meeting', 'Core Meeting', 'Other', 'Phone Call', 'Deep Dive', 'First Meeting' };

        if (includeAllRecords) {
            events = [
                SELECT Id, StartDateTime, OwnerId, Virtual_Event__c
                FROM Event
                WHERE
                    StartDateTime >= :dtQuarterFirstDay
                    AND StartDateTime <= :dtQuarterLastDay
                    AND Type IN :types
                ORDER BY StartDateTime
            ];
        } else {
            events = [
                SELECT Id, StartDateTime, OwnerId, Virtual_Event__c
                FROM Event
                WHERE
                    StartDateTime >= :dtQuarterFirstDay
                    AND StartDateTime <= :dtQuarterLastDay
                    AND Type IN :types
                ORDER BY StartDateTime
            ];
        }

        return events;
    }

    /**
     * @description readProducerTracks runs through the Event__c objects counting
     * the ones for the quarter
     */
    @TestVisible
    private void readProducerTracks() {
        Integer week;

        for (Event__c event : queryBBSIEvents()) {
            week = BusinessQuarter.getWeek(event.Event_Start_Date__c, forWholeYear);
            activityData.get(week).producerTracks += 1;
            activityData.get(week).producerTrackAttendees += (Integer) event.RP_Client_Attendence__c;
        }
    }

    /**
     * @description queryBBSIEvents
     * Number of producer tracks/info session
     *   - This is the number of referral partner education events (API name Event__c) for which
     *     the BDM is listed as the Event Manager during the quarter
     *   - The report will include the following event types (Event_Type__c): Producer Track,
     *     Tier 1- 1 Day, Tier 2- 2 Day, Tier 3- 3 Day, and Tier 4- Executive Event event types
     *     with a start date (Event_Start_Date__c) during weeks 1-13 of the quarter.
     *     Added more types.
     *   - Include events in both Pending Approval and Approved status.
     *   - #37307: It should not include events in Rejected status (from Approval_Status__c)
     * @return List of Event__c
     */
    private List<Event__c> queryBBSIEvents() {
        List<String> eventTypes = new List<String>{
            '8', '1', '2', '3', '4',
            'Earn-In Event',
            'Education Event',
            'Lunch & Learn',
            'Relationship Development',
            'Combination RP and Client Event'
        };

        List<Event__c> events;

        if (includeAllRecords) {
            events = [
                SELECT Id, Event_Start_Date__c, Event_Manager__c, RP_Client_Attendence__c
                FROM Event__c
                WHERE
                    Event_Manager__c IN :idUsersToBranch.keySet()
                    AND Event_Start_Date__c >= :bQuarter.dateRange.dateFrom
                    AND Event_Start_Date__c <= :bQuarter.dateRange.dateTo
                    AND Event_Type__c IN :eventTypes
                    AND Event_Status__c <> 'Cancelled'
                    AND Approval_Status__c <> 'Rejected'
                ORDER BY Event_Start_Date__c
            ]; // Added filter Approval_Status__c not in Rejected 
        } else {
            events = [
                SELECT Id, Event_Start_Date__c, Event_Manager__c, RP_Client_Attendence__c
                FROM Event__c
                WHERE
                    Event_Manager__c IN :reportUsersInfo.keySet()
                    AND Event_Start_Date__c >= :bQuarter.dateRange.dateFrom
                    AND Event_Start_Date__c <= :bQuarter.dateRange.dateTo
                    AND Event_Type__c IN :eventTypes
                    AND Event_Status__c <> 'Cancelled'
                    AND Approval_Status__c <> 'Rejected'
                ORDER BY Event_Start_Date__c
            ]; // Added filter Approval_Status__c not in Rejected 
        }

        return events;
    }

    /**
     * @description readLostClients sets number of Lost Clients.
     */
    @TestVisible
    private void readLostClients() {
        Integer week;

        List<Task> tasks = queryLostClient();

        for (Task task : tasks) {
            week = BusinessQuarter.getWeek(task.Date_Completed__c, forWholeYear);
            activityData.get(week).numberLostClients += 1;
        }
    }

    /**
     * @description queryLostClient get Tasks for Lost Clients.
     * @return  List<Task>
     */
    @TestVisible
    private List<Task> queryLostClient() {
        Set<Id> idOwners;

        if (includeAllRecords) {
            idOwners = mapBranchUsers.keySet();
        } else {
            idOwners = reportUsersInfo.keySet();
        }

        return [
            SELECT Id, OwnerId, Date_Completed__c
            FROM Task
            WHERE OwnerId IN :idOwners
                AND Date_Completed__c >= :bQuarter.dateRange.dateFrom
                AND Date_Completed__c <= :bQuarter.dateRange.dateTo
                AND Status = 'Completed'
                AND Subject LIKE 'Client Cancellation Follow-up%'
            ORDER BY Date_Completed__c
        ];
    }

    @TestVisible
    private void readAmBranches() {
        workingBranches = new Map<Id, Account>();

        Map<Id, List<Account>> areaManagerBranches = AccountBranch.getAreaManagersBranches();

        if (areaManagerBranches.containsKey(creatorId)) {
            for (Account branch : areaManagerBranches.get(creatorId)) {
                workingBranches.put(branch.Id, branch);
            }
        }
    }

    @TestVisible
    private void readAllBranches() {
        workingBranches = new Map<Id, Account>();

        for (Account branch : AccountBranch.getBranches(null)) {
            workingBranches.put(branch.Id, branch);
        }
    }

    @TestVisible
    private void setBranches(List<String> idBranches) {
        workingBranches = new Map<Id, Account>();

        if (idBranches == null || idBranches.isEmpty()) {
            for (Account branch : AccountBranch.getBranches(null)) {
                workingBranches.put(branch.Id, branch);
            }
        } else {
            Set<Id> setIdBranches = new Set<Id>();

            for (String idbranch : idBranches) {
                setIdBranches.add(Id.valueOf(idbranch));
            }

            for (Account branch : AccountBranch.getBranches(setIdBranches)) {
                workingBranches.put(branch.Id, branch);
            }
        }
    }

    private void setBranchUsers() {
        Set<String> branchNumbers = new Set<String>();

        for (Account branch : workingBranches.values()) {
            branchNumbers.add(branch.External_Id__c);
        }

        mapBranchUsers = new Map<Id, User>([
            SELECT Id, Name, Branch_Id__c
            FROM User
            WHERE Branch_Id__c IN :branchNumbers
        ]);

        Debug_Service.debug(LoggingLevel.FINEST, 'Found Branch Users', mapBranchUsers.values());
    }

    @TestVisible
    @SuppressWarnings('PMD.AvoidSystemDebugUsage')
    private void dumpData() {
        String dump = 'BusinessActivityReportData Dump';

        dump += '\n Creator: ' + creatorName + '  ' + creatorId;
        dump += '\n Creator Is Report Manager: ' + isCreatorReportManager;
        dump += '\n Creator Is Area Manager: ' + isCreatorAreaManager;
        dump += '\n Year ' + bQuarter.year;
        dump += '\n Quarter ' + bQuarter.quarter;

        dump += '\n Working Branches: ';
        for (Account branch : workingBranches.values()) {
            dump += '\n--- BRANCH: ' + branch.Name;
        }

        dump += '\n BDMs: ';
        for (String name : reportUsersInfo.values()) {
            dump += '\n--- BDM: ' + name;
        }

        dump += '\n Activity Goal: ' + activityGoal;

        System.debug(LoggingLevel.DEBUG, dump);
    }

    private String getBranchId(String branchNum) {
        if (workingBranches != null && !String.isBlank(branchNum)) {
            for (Account branch : workingBranches.values()) {
                if (branch.External_Id__c == branchNum) {
                    return branch.Id;
                }
            }
        }

        return null;
    }
}