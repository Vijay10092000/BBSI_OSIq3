/**
 * @description BusinessActivityReport
 *
 * Outbound Filename:  [Username] _ActivityReport_[Year][ShortQuarter].xls
 *     For example:  John_Doe__ActivityReport_2021Q3.xls
 *     Format filename:  {0}_ActivityReport__{1}{2}.xls then replace spaces with underscore
 */
@SuppressWarnings('PMD.ApexDoc,PMD.ExcessivePublicCount')
public without sharing class BusinessActivityReport extends ExcelWorkbook {
    private static final String REPORT_TITLE = 'New Business Activity Report';
    private static final String COMPANY = 'BBSI';
    private static final String SHEET_ACTIVITY = 'Activity';
    private static final String SHEET_INFO = 'Info';

    private static final String TYPE_STRING = 'String';
    private static final String TYPE_FORMULA = 'Formula';
    private static final String TYPE_NUMBER = 'Number';

    private static final String FONTNAME_MAIN = 'Calibri';
    private static final Integer FONTSIZE_TITLE = 16;
    private static final Integer FONTSIZE_HEADER = 11;
    private static final Integer FONTSIZE_NORMAL = 11;

    private static final String COLOR_BLACK = '#000000';
    private static final String COLOR_WHITE = '#FFFFFF';
    private static final String COLOR_GREEN = '#92D050';
    private static final String COLOR_GRAY = '#D9D9D9';
    private static final String COLOR_RED = '#FFC7CE';
    private static final String COLOR_BLUE = '#D9E1F2';

    private static final String BORDER_TYPE = 'Continuous';
    private static final Integer BORDER_WIDTH = 1;

    private static final String STYLE_TITLE = 'ReportTitle';
    private static final String STYLE_HEADER = 'ReportHeader';
    private static final String STYLE_HEADER_GRAY = 'ReportHeaderGray';
    private static final String STYLE_HEADER_BLUE = 'BlueHeaderCell';
    private static final String STYLE_HEADER_GREEN = 'GreenHeaderCell';
    private static final String STYLE_GREEN = 'GreenCell';
    private static final String STYLE_RED = 'RedCell';
    private static final String STYLE_BLUE = 'BlueCell';
    private static final String STYLE_GRAY = 'GrayCell';
    private static final String STYLE_DATA = 'DataCell';
    private static final String STYLE_DECIMAL2 = 'Decimal2';
    private static final String STYLE_GOAL = 'GoalCell';
    private static final String STYLE_NORMAL = 'NormalCell';

    private static final Integer ROW_HEADERS = 3;

    private static final Integer ROW_DATA_START = 4;
    private static final Integer ROW_NEW_LEADS = 4;
    private static final Integer ROW_DISCOVERY_MEETINGS = 5;
    private static final Integer ROW_NEW_CLIENTS = 6;
    private static final Integer ROW_RP_TOUCHES_IN_PERSON = 7;
    private static final Integer ROW_RP_TOUCHES_VIRTUAL = 8;
    private static final Integer ROW_PRODUCER_TRACKS = 9;
    private static final Integer ROW_PRODUCER_TRACK_ATTENDEES = 10;
    private static final Integer ROW_NEW_RPS = 11;
    private static final Integer ROW_RP_PLANS = 12;
    private static final Integer ROW_NO_LOST_CLIENTS = 13;
    private static final Integer ROW_NO_LOST_LEADS = 14;
    private static final Integer ROW_NO_ADDED_WSE = 15;
    private static final Integer ROW_DATA_END = 15;

    private static final Integer COLUMN_QUARTER_GOAL = 2;
    private static final Integer COLUMN_WEEK_GOAL = 3;
    private static final Integer COLUMN_DATA_START = 4;

    private static final Integer COLUMN_WIDTH_A = 200;
    private static final Integer COLUMN_WIDTH_DATA = 64;

    private static final String FORMAT_FORMULA_WEEK_GOAL = '=R{0}C{1}/{2}';
    private static final String FORMAT_FORMULA_QUARTER = '=SUM(R{0}C{1}:R{2}C{3})';
    private static final String FORMAT_FORMULA_GOAL = '=IFERROR(R{0}C{1}/R{2}C{3}, &quot;&quot;)';

    private static final String CALCULATION_WEEKS_QUARTER = '13';
    private static final String CALCULATION_WEEKS_YEAR = '52';

    private BusinessActivityReportData reportData;

    private Sheet sheetActivity;
    private Sheet sheetInfo;

    /**
     * @description create builds the report.
     * @return A String containing the EXCEL report file
     */
    @SuppressWarnings('PMD.ExcessiveParameterList')
    public String create(
        List<String> idBDMs, List<String> idBranches, Integer year, Integer quarter,
        Boolean includeAllRecords, Boolean includeAllBDMs, Boolean includeAllBranches
    ) {
        readData(idBDMs, idBranches, year, quarter, includeAllRecords, includeAllBDMs, includeAllBranches);

        fillWorkbook();

        return build();
    }

    @SuppressWarnings('PMD.ExcessiveParameterList')
    private void readData(
        List<String> idBDMs, List<String> idBranches, Integer year, Integer quarter,
        Boolean includeAllRecords, Boolean includeAllBDMs, Boolean includeAllBranches
    ) {
        reportData = new BusinessActivityReportData();
        reportData.readData(idBDMs, idBranches, year, quarter, includeAllRecords, includeAllBDMs, includeAllBranches);
    }

    @TestVisible
    private void fillWorkbook() {
        sheetActivity = addSheet(SHEET_ACTIVITY);

        fillWorkbookProperties();
        fillWorkbookStyles();

        fillActivityTitles();
        fillActivityColumnHeaders();
        fillActivityRowHeaders();
        fillActivityColumnsQNoAndGoal();

        addActivityData();

        sheetInfo = addSheet(SHEET_INFO);
        fillSheetInfo();
    }

    @TestVisible
    private void fillWorkbookProperties() {
        addDocumentProperty('Title', REPORT_TITLE);
        addDocumentProperty('Author', UserInfo.getUserName());
        addDocumentProperty('Company', COMPANY);
        addDocumentProperty('Created', Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''));
    }

    @TestVisible
    private void fillWorkbookStyles() {
        Alignment alignment;

        addStyle(STYLE_NORMAL);

        Style styleTitle = addStyle(STYLE_TITLE);
        styleTitle.addFont(FONTNAME_MAIN, FONTSIZE_TITLE, true);

        Style styleHeader = addStyle(STYLE_HEADER);
        styleHeader.addFont(FONTNAME_MAIN, FONTSIZE_HEADER, true);
        alignment = styleHeader.addAlignment();
        alignment.horizontal = 'Center';
        styleHeader.addAllBorders(BORDER_TYPE, BORDER_WIDTH, COLOR_BLACK);

        Style styleHeaderGray = addStyle(STYLE_HEADER_GRAY);
        styleHeaderGray.addFont(FONTNAME_MAIN, FONTSIZE_HEADER, true);
        styleHeaderGray.interior(COLOR_GRAY);
        alignment = styleHeaderGray.addAlignment();
        alignment.horizontal = 'Center';
        styleHeaderGray.addAllBorders(BORDER_TYPE, BORDER_WIDTH, COLOR_BLACK);

        Style styleHeaderBlue = addStyle(STYLE_HEADER_BLUE);
        styleHeaderBlue.addFont(FONTNAME_MAIN, FONTSIZE_HEADER, true);
        styleHeaderBlue.interior(COLOR_BLUE);
        alignment = styleHeaderBlue.addAlignment();
        alignment.horizontal = 'Center';
        styleHeaderBlue.addAllBorders(BORDER_TYPE, BORDER_WIDTH, COLOR_BLACK);

        Style styleHeaderGreen = addStyle(STYLE_HEADER_GREEN);
        styleHeaderGreen.addFont(FONTNAME_MAIN, FONTSIZE_HEADER, true);
        styleHeaderGreen.interior(COLOR_GREEN);
        alignment = styleHeaderGreen.addAlignment();
        alignment.horizontal = 'Center';
        styleHeaderGreen.addAllBorders(BORDER_TYPE, BORDER_WIDTH, COLOR_BLACK);

        Style styleGreen = addStyle(STYLE_GREEN);
        styleGreen.addFont(FONTNAME_MAIN, FONTSIZE_NORMAL, true);
        styleGreen.interior(COLOR_GREEN);
        styleGreen.addAllBorders(BORDER_TYPE, BORDER_WIDTH, COLOR_BLACK);

        Style styleBlue = addStyle(STYLE_BLUE);
        styleBlue.addFont(FONTNAME_MAIN, FONTSIZE_NORMAL, false);
        styleBlue.interior(COLOR_BLUE);
        styleBlue.addAllBorders(BORDER_TYPE, BORDER_WIDTH, COLOR_BLACK);

        Style styleRed = addStyle(STYLE_RED);
        styleRed.addFont(FONTNAME_MAIN, FONTSIZE_NORMAL);
        styleRed.interior(COLOR_RED);
        styleRed.addAllBorders(BORDER_TYPE, BORDER_WIDTH, COLOR_BLACK);

        Style styleGray = addStyle(STYLE_GRAY);
        styleGray.addFont(FONTNAME_MAIN, FONTSIZE_NORMAL);
        styleGray.interior(COLOR_GRAY);
        styleGray.addAllBorders(BORDER_TYPE, BORDER_WIDTH, COLOR_BLACK);

        Style styleData = addStyle(STYLE_DATA);
        styleData.addFont(FONTNAME_MAIN, FONTSIZE_NORMAL);
        styleData.interior(COLOR_WHITE);
        styleData.addAllBorders(BORDER_TYPE, BORDER_WIDTH, COLOR_BLACK);

        Style styleDecimal2 = addStyle(STYLE_DECIMAL2);
        styleDecimal2.addFont(FONTNAME_MAIN, FONTSIZE_NORMAL);
        styleDecimal2.interior(COLOR_WHITE);
        styleDecimal2.addAllBorders(BORDER_TYPE, BORDER_WIDTH, COLOR_BLACK);
        styleDecimal2.numberFormat('#0.00');

        Style styleGoal = addStyle(STYLE_GOAL);
        styleGoal.addFont(FONTNAME_MAIN, FONTSIZE_NORMAL);
        styleGoal.interior(COLOR_WHITE);
        styleGoal.addAllBorders(BORDER_TYPE, BORDER_WIDTH, COLOR_BLACK);
        styleGoal.numberFormat('Percent');
    }

    @TestVisible
    private void fillActivityTitles() {
        sheetActivity.addCell(1, 1, TYPE_STRING, REPORT_TITLE, STYLE_TITLE);
        sheetActivity.addCell(
            2,
            1,
            TYPE_STRING,
            String.valueOf(reportData.bQuarter.year) + ' ' +
            BusinessQuarter.asString(reportData.bQuarter.quarter)
        );
        sheetActivity.addCell(2, 2, TYPE_STRING, shortListBDMs());
        sheetActivity.addCell(2, 4, TYPE_STRING, shortListBranches());
    }

    @TestVisible
    private void fillActivityColumnHeaders() {
        Column col = sheetActivity.addColumn(1);
        col.width = COLUMN_WIDTH_A;

        String goalHeader = (reportData.forWholeYear) ? 'Y Goal' : 'Q Goal';

        sheetActivity.addCell(ROW_HEADERS, 1, TYPE_STRING, 'Metrics', STYLE_HEADER_GREEN);
        sheetActivity.addCell(ROW_HEADERS, 2, TYPE_STRING, goalHeader, STYLE_HEADER);
        sheetActivity.addCell(ROW_HEADERS, 3, TYPE_STRING, 'W Goal', STYLE_HEADER);

        Integer numberWeeks = reportData.activityData.size();

        for (Integer index = 0; index < numberWeeks; ++index) {
            DateTime weekStart = reportData.dateRanges.get(index).dateFrom;
            DateTime weekEnd = reportData.dateRanges.get(index).dateTo;

            sheetActivity.addCell(
                ROW_HEADERS,
                4 + index,
                TYPE_STRING,
                formatDateHeader(weekStart, weekEnd),
                STYLE_HEADER
            );
        }

        String totalTitle = (reportData.forWholeYear) ? 'Y#' : 'Q#';

        sheetActivity.addCell(ROW_HEADERS, 3 + numberWeeks + 1, TYPE_STRING, totalTitle, STYLE_HEADER_BLUE);

        sheetActivity.addCell(ROW_HEADERS, 3 + numberWeeks + 2, TYPE_STRING, '% of Goal', STYLE_HEADER);
    }

    @TestVisible
    private void fillActivityRowHeaders() {
        sheetActivity.addCell(ROW_NEW_LEADS, 1, TYPE_STRING, '# of New Leads', STYLE_DATA);
        sheetActivity.addCell(ROW_DISCOVERY_MEETINGS, 1, TYPE_STRING, '# of Discovery Meetings - Opps', STYLE_DATA);
        sheetActivity.addCell(ROW_NEW_CLIENTS, 1, TYPE_STRING, '# of New Clients', STYLE_DATA);
        sheetActivity.addCell(ROW_RP_TOUCHES_IN_PERSON, 1, TYPE_STRING, '# of RP Touches - In Person', STYLE_DATA);
        sheetActivity.addCell(ROW_RP_TOUCHES_VIRTUAL, 1, TYPE_STRING, '# of RP Touches - Virtual', STYLE_DATA);
        sheetActivity.addCell(ROW_PRODUCER_TRACKS, 1, TYPE_STRING, '# of Producer Tracks/Info Session', STYLE_DATA);
        sheetActivity.addCell(ROW_PRODUCER_TRACK_ATTENDEES, 1, TYPE_STRING, '# Producer Track Info Session Attendees', STYLE_DATA);
        sheetActivity.addCell(ROW_NEW_RPS, 1, TYPE_STRING, 'New RPs Contacted', STYLE_DATA);
        sheetActivity.addCell(ROW_RP_PLANS, 1, TYPE_STRING, 'RP Plans in Place', STYLE_DATA);
        sheetActivity.addCell(ROW_NO_LOST_CLIENTS, 1, TYPE_STRING, '# of Lost Clients Contacted', STYLE_DATA);
        sheetActivity.addCell(ROW_NO_LOST_LEADS, 1, TYPE_STRING, '# of Lost Leads Contacted', STYLE_DATA);
        sheetActivity.addCell(ROW_NO_ADDED_WSE, 1, TYPE_STRING, '# of WSE Added', STYLE_DATA);
    }

    @TestVisible
    private void fillActivityColumnsQNoAndGoal() {
        Integer numberWeeks = reportData.activityData.size();
        Integer columnQNo = COLUMN_DATA_START + numberWeeks;
        Integer columnGoal = columnQNo + 1;

        String strColStart = String.valueOf(COLUMN_DATA_START);
        String strColEnd = String.valueOf(COLUMN_DATA_START + numberWeeks - 1);

        for (Integer index = COLUMN_DATA_START; index < COLUMN_DATA_START + numberWeeks; ++index) {
            Column col = sheetActivity.addColumn(index);
            col.width = COLUMN_WIDTH_DATA;
        }

        String valueGoal;
        String formulaWeekGoal;
        String formulaQ;
        String formulaGoal;
        String calculationWeeks = (reportData.forWholeYear) ? CALCULATION_WEEKS_YEAR : CALCULATION_WEEKS_QUARTER;

        for (Integer row = ROW_DATA_START; row <= ROW_DATA_END; ++row) {
            String strRow = String.valueOf(row);

            valueGoal = getGoalForRow(row);

            formulaWeekGoal = String.format(
                FORMAT_FORMULA_WEEK_GOAL,
                new List<String>{ strRow, String.valueOf(COLUMN_QUARTER_GOAL), calculationWeeks }
            );
            formulaQ = String.format(
                FORMAT_FORMULA_QUARTER,
                new List<String>{ strRow, strColStart, strRow, strColEnd }
            );
            formulaGoal = String.format(
                FORMAT_FORMULA_GOAL,
                new List<String>{ strRow, String.valueOf(columnQNo), strRow, String.valueOf(COLUMN_QUARTER_GOAL) }
            );

            sheetActivity.addCell(row, 2, TYPE_NUMBER, valueGoal, STYLE_DATA);
            sheetActivity.addFormulaCell(row, COLUMN_WEEK_GOAL, formulaWeekGoal, TYPE_NUMBER, '0', STYLE_DECIMAL2);
            sheetActivity.addFormulaCell(row, columnQNo, formulaQ, TYPE_NUMBER, '0', STYLE_BLUE);
            sheetActivity.addFormulaCell(row, columnGoal, formulaGoal, TYPE_NUMBER, '0', STYLE_GOAL);
        }
    }

    @TestVisible
    private void addActivityData() {
        Integer column = COLUMN_DATA_START - 1;

        for (BusinessActivityReportData.ActivityData data : reportData.activityData.values()) {
            addDataCell(ROW_NEW_LEADS, column + data.week, data.newLeads);
            addDataCell(ROW_DISCOVERY_MEETINGS, column + data.week, data.discoveryMeetings);
            addDataCell(ROW_NEW_CLIENTS, column + data.week, data.newClients);
            addDataCell(ROW_RP_TOUCHES_IN_PERSON, column + data.week, data.rpTouchesInPerson);
            addDataCell(ROW_RP_TOUCHES_VIRTUAL, column + data.week, data.rpTouchesVirtual);
            addDataCell(ROW_PRODUCER_TRACKS, column + data.week, data.producerTracks);
            addDataCell(ROW_PRODUCER_TRACK_ATTENDEES, column + data.week, data.producerTrackAttendees);
            addDataCell(ROW_NEW_RPS, column + data.week, data.newRPs);
            addDataCell(ROW_RP_PLANS, column + data.week, data.rpPlans);
            addDataCell(ROW_NO_LOST_CLIENTS, column + data.week, data.numberLostClients);
            addDataCell(ROW_NO_LOST_LEADS, column + data.week, data.numberLostLeads);
            addDataCell(ROW_NO_ADDED_WSE, column + data.week, data.numberAddedWSE);
        }
    }

    @TestVisible
    private void addDataCell(Integer row, Integer column, Integer value) {
        sheetActivity.addCell(row, column, TYPE_NUMBER, String.valueOf(value), STYLE_RED);
    }

    @TestVisible
    @SuppressWarnings('PMD.CyclomaticComplexity')
    private String getGoalForRow(Integer row) {
        Decimal value = 0;

        Integer mulitplier = (reportData.forWholeYear) ? 4 : 1;

        if (reportData.activityGoal != null) {
            if (row == ROW_NEW_LEADS) {
                value = mulitplier * reportData.activityGoal.New_Leads__c;
            }
            else if (row == ROW_DISCOVERY_MEETINGS) {
                value = mulitplier * reportData.activityGoal.Discovery_Meetings__c;
            }
            else if (row == ROW_NEW_CLIENTS) {
                value = mulitplier * reportData.activityGoal.New_Clients__c;
            }
            else if (row == ROW_RP_TOUCHES_IN_PERSON) {
                value = mulitplier * reportData.activityGoal.RP_Touches_In_Person__c;
            }
            else if (row == ROW_RP_TOUCHES_VIRTUAL) {
                value = mulitplier * reportData.activityGoal.RP_Touches_Virtual__c;
            }
            else if (row == ROW_PRODUCER_TRACKS) {
                value = mulitplier * reportData.activityGoal.Producer_Tracks_Info_Sessions__c;
            }
            else if (row == ROW_PRODUCER_TRACK_ATTENDEES) {
                return ''; // TODO: There will be a goal, but not yet known.
            }
            else if (row == ROW_NEW_RPS) {
                value = mulitplier * reportData.activityGoal.New_Referral_Partners_Contacted__c;
            }
            else if (row == ROW_RP_PLANS) {
                value = mulitplier * reportData.activityGoal.Referral_Partner_Plans_In_Place__c;
            }
            else if (row == ROW_NO_LOST_CLIENTS) {
                value = mulitplier * reportData.activityGoal.Lost_Clients_Contacted__c;
            }
            else if (row == ROW_NO_LOST_LEADS) {
                value = mulitplier * reportData.activityGoal.Lost_Leads_Contacted__c;
            }
            else if (row == ROW_NO_ADDED_WSE) {
                value = mulitplier * reportData.activityGoal.WSE_Added__c;
            }
        }

        return String.valueOf(value.intValue());
    }

    /**
     * @description fillSheetInfo addes the Info sheet to the workbook.
     */
    private void fillSheetInfo() {
        Column col1 = sheetInfo.addColumn(1);
        col1.width = 100;
        Column col2 = sheetInfo.addColumn(2);
        col2.width = 100;
        Column col3 = sheetInfo.addColumn(3);
        col3.width = 100;
        Column col4 = sheetInfo.addColumn(4);
        col4.width = 100;
        Column col5 = sheetInfo.addColumn(5);
        col5.width = 100;
        Column col6 = sheetInfo.addColumn(6);
        col6.width = 100;
        Column col7 = sheetInfo.addColumn(7);
        col7.width = 100;

        sheetInfo.addCell(1, 1, TYPE_STRING, 'Report Information', STYLE_TITLE);
        sheetInfo.addCell(2, 1, TYPE_STRING, 'Created On', STYLE_NORMAL);
        sheetInfo.addCell(2, 2, TYPE_STRING, String.valueOf(DateTime.now()), STYLE_NORMAL);
        sheetInfo.addCell(3, 1, TYPE_STRING, 'Created By', STYLE_NORMAL);
        sheetInfo.addCell(3, 2, TYPE_STRING, reportData.creatorName, STYLE_NORMAL);

        if (reportData.isCreatorReportManager) {
            sheetInfo.addCell(3, 3, TYPE_STRING, 'as Report Manager', STYLE_NORMAL);
        } else if (reportData.isCreatorAreaManager) {
            sheetInfo.addCell(3, 3, TYPE_STRING, 'as Area Manager', STYLE_NORMAL);
        }

        if (reportData.includeAllRecords) {
            sheetInfo.addCell(5, 1, TYPE_STRING, 'All Records', STYLE_NORMAL);
        }

        // Add User Names
        if (!reportData.reportUsersInfo.isEmpty()) {
            sheetInfo.addCell(6, 1, TYPE_STRING, 'BDM(s)', STYLE_NORMAL);

            List<String> names = reportData.reportUsersInfo.values();
            names.sort();

            Integer index = 0;
            for (String name : names) {
                sheetInfo.addCell(6 + index, 2, TYPE_STRING, name, STYLE_NORMAL);
                ++index;
            }
        }

        if (reportData.includeAllBranches) {
            sheetInfo.addCell(5, 3, TYPE_STRING, 'All Branches', STYLE_NORMAL);
        }

        if (!reportData.workingBranches.isEmpty()) {
            // Add Branch Names
            sheetInfo.addCell(6, 3, TYPE_STRING, 'Branches', STYLE_NORMAL);

            List<String> names = new List<String>();
            for (Account branch : reportData.workingBranches.values()) {
                names.add(branch.Name);
            }
            names.sort();

            Integer index = 0;
            for (String name : names) {
                sheetInfo.addCell(6 + index, 4, TYPE_STRING, name, STYLE_NORMAL);
                ++index;
            }
        }

        if (!reportData.mapBranchUsers.isEmpty()) {
            // Branch Users
            sheetInfo.addCell(6, 5, TYPE_STRING, 'Branch Users', STYLE_NORMAL);

            List<String> names = new List<String>();
            for (User user : reportData.mapBranchUsers.values()) {
                names.add(user.Name);
            }
            names.sort();

            Integer index = 0;
            for (String name : names) {
                sheetInfo.addCell(6 + index, 6, TYPE_STRING, name, STYLE_NORMAL);
                ++index;
            }
        }
    }

    private String formatDateHeader(DateTime weekStart, DateTime weekEnd) {
        return weekStart.formatGmt('MM/dd') + ' - ' + weekEnd.formatGmt('MM/dd');
    }

    private String shortListBDMs() {
        String result = '';

        if (!reportData.reportUsersInfo.isEmpty()) {
            List<String> names = reportData.reportUsersInfo.values();

            if (names.size() <= 3) {
                names.sort();

                result = String.join(names, ', ');
            }
        }

        return result;
    }

    private String shortListBranches() {
        String result = '';

        if (!reportData.workingBranches.isEmpty()) {
            List<Account> branches = reportData.workingBranches.values();

            if (branches.size() <= 3) {
                List<String> names = new List<String>();

                for (Account branch : branches) {
                    names.add(branch.Name);
                }

                names.sort();

                result = String.join(names, ', ');
            }
        }

        return result;
    }
}