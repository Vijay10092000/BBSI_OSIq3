/**
 * @description ExcelWorkbook_Test
 */
@IsTest
@SuppressWarnings('PMD.ApexAssertionsShouldIncludeMessage,PMD.ApexUnitTestClassShouldHaveAsserts')
public without sharing class ExcelWorkbook_Test {
    private static final String RESULT_ALIGNMENT_ALL =
        '<Alignment' +
        ' ss:Horizontal="horizontal"' +
        ' ss:Indent="10"' +
        ' ss:ReadingOrder="readingOrder"' +
        ' ss:Rotate="5.43"' +
        ' ss:ShrinkToFit="0"' +
        ' ss:Vertical="vertical"' +
        ' ss:VerticalText="0"' +
        ' ss:WrapText="0"' +
        '/>';

    private static final String RESULT_ALIGNMENT_SOME =
        '<Alignment' +
        ' ss:Horizontal="horizontal"' +
        ' ss:Vertical="vertical"' +
        ' ss:VerticalText="1"' +
        '/>';

    private static final String RESULT_BORDER_ALL =
        '<Border' +
        ' ss:Position="position"' +
        ' ss:LineStyle="lineStyle"' +
        ' ss:Weight="10"' +
        ' ss:Color="#000000"' +
        '/>';

    private static final String RESULT_BORDER_SOME =
        '<Border' +
        ' ss:Position="position"' +
        ' ss:LineStyle="lineStyle"' +
        ' ss:Weight="20"' +
        ' ss:Color="#FFFFFF"' +
        '/>';

    private static final String RESULT_CELL_ALL =
        '<Cell' +
        ' ss:Index="1"' +
        ' ss:StyleID="styleID"' +
        ' ss:Formula="formula"' +
        ' ss:MergeAcross="1"' +
        ' ss:MergeDown="2"' +
        ' ss:PasteFormula="pasteFormula"' +
        ' ss:ArrayRange="arrayRange"' +
        ' ss:HRef="hRef"' +
        ' ss:HRefScreenTip="toolTip"' +
        '>' +
        '<Data ss:Type="type">value</Data>' +
        '<Comment ss:Author="author" ss:ShowAlways="0"><Data>comment</Data></Comment>' +
        '<PhonicText ss:Visible="1">phonicText</PhonicText>' +
        '</Cell>';

    private static final String RESULT_COLUMN_ALL =
        '<Column' +
        ' ss:Index="2"' +
        ' ss:AutoFitWidth="1"' +
        ' ss:Width="20"' +
        ' ss:Hidden="0"' +
        ' ss:Span="2"' +
        ' c:Caption="caption"' +
        '/>';

    private static final String RESULT_COLUMN_SOME =
        '<Column' +
        ' ss:Index="3"' +
        ' ss:AutoFitWidth="0"' +
        ' ss:Width="30"' +
        '/>';

    private static final String RESULT_COMMENT_ALL =
        '<Comment' +
        ' ss:Author="author"' +
        ' ss:ShowAlways="1">' +
        '<Data>comment</Data>' +
        '</Comment>';

    private static final String RESULT_FONT_ALL =
        '<ss:Font' +
        ' x:Family="family"' +
        ' x:CharSet="charSet"' +
        ' ss:FontName="name"' +
        ' ss:Size="15.0"' +
        ' ss:Bold="0"' +
        ' ss:Color="#000000"' +
        ' ss:Italic="0"' +
        ' ss:Outline="0"' +
        ' ss:Shadow="0"' +
        ' ss:StrikeThrough="0"' +
        ' ss:Underline="0"' +
        ' ss:VerticalAlign="0"' +
        '/>';

    private static final String RESULT_INTERIOR_ALL =
        '<Interior' +
        ' ss:Color="#000000"' +
        ' ss:Pattern="pattern"' +
        ' ss:PatternColor="#FFFFFF"' +
        '/>';

    private static final String RESULT_NAMEDRANGE_ALL =
        '<NamedRange' +
        ' ss:Name="name"' +
        ' ss:RefersTo="sheet!R1C2:R1C2"' +
        ' ss:Hidden="1"' +
        '/>';

    private static final String RESULT_NAMEDRANGE_SOME =
        '<NamedRange' +
        ' ss:Name="name"' +
        ' ss:RefersTo="R1C2:R1C2"' +
        '/>';

    private static final String RESULT_ROW_START_ALL =
        '<Row' +
        ' ss:Index="7"' +
        ' ss:AutoFitHeight="1"' +
        ' ss:Height="20"' +
        ' ss:Span="6"' +
        ' c:Caption="caption"' +
        '>';

    private static final String RESULT_ROW_START_SOME1 = '<Row ss:Index="8">';

    private static final String RESULT_ROW_START_SOME2 =
        '<Row' +
        ' ss:Index="9"' +
        ' ss:AutoFitHeight="0"' +
        ' ss:Height="20"' +
        '>';

    private static final String RESULT_ROW_END = '</Row>';

    private static final String RESULT_SHEET_EMPTY = '<Worksheet ss:Name="sheet"><Table></Table></Worksheet>';

    private static final String RESULT_SHEET_OPTIONS =
    '<Worksheet ss:Name="sheet">' +
    '<Table></Table>' +
    '<WorksheetOptions>' +
    '<SplitHorizontal>2</SplitHorizontal>' +
    '<SplitVertical>1</SplitVertical>' +
    '</WorksheetOptions>' +
    '</Worksheet>';

    private static final String RESULT_SHEET_NAMEDRANGES =
        '<Worksheet ss:Name="sheet">' +
        '<NamedRange ss:Name="name1" ss:RefersTo="R1C2:R1C4"/>' +
        '<NamedRange ss:Name="name2" ss:RefersTo="R5C8:R1C4"/>' +
        '<Table></Table>' +
        '</Worksheet>';

    private static final String RESULT_SHEET_TABLE =
        '<Worksheet ss:Name="sheet">' +
        '<Table' +
        ' ss:DefaultColumnWidth="30"' +
        ' ss:DefaultRowHeight="20"' +
        ' ss:ExpandedColumnCount="1000"' +
        ' ss:ExpandedRowCount="1000"' +
        ' ss:LeftCell="1"' +
        ' ss:StyleID="styleID"' +
        ' ss:TopCell="1"' +
        ' x:FullColumns="1"' +
        ' x:FullRows="1"' +
        '>' +
        '</Table>' +
        '</Worksheet>';

    private static final String RESULT_SHEET_COLUMNS =
        '<Worksheet ss:Name="sheet">' +
        '<Table>' +
        '<Column ss:Index="1" ss:AutoFitWidth="1" ss:Width="25"/>' +
        '<Column ss:Index="2" ss:AutoFitWidth="0" ss:Width="30"/>' +
        '</Table>' +
        '</Worksheet>';

    private static final String RESULT_SHEET_ROWS =
        '<Worksheet ss:Name="sheet">' +
        '<Table>' +
        '<Row ss:Index="1" ss:AutoFitHeight="1" ss:Height="25"></Row>' +
        '<Row ss:Index="2"></Row>' +
        '</Table>' +
        '</Worksheet>';

    private static final String RESULT_SHEET_CELLS =
        '<Worksheet ss:Name="sheet">' +
        '<Table>' +
        '<Row ss:Index="1">' +
        '<Cell ss:Index="2"></Cell>' +
        '<Cell ss:Index="5"></Cell>' +
        '</Row>' +
        '<Row ss:Index="2" ss:AutoFitHeight="1" ss:Height="25">' +
        '<Cell ss:Index="1"></Cell><Cell ss:Index="7">' +
        '<Data ss:Type="String">TEXT</Data></Cell></Row>' +
        '<Row ss:Index="4">' +
        '<Cell ss:Index="2"><Data ss:Type="Number">34.5</Data></Cell>' +
        '</Row>' +
        '</Table>' +
        '</Worksheet>';

        private static final String RESULT_STYLE_ALL =
            '<Style' +
            ' ss:ID="styleAll"' +
            ' ss:Name="name"' +
            ' ss:Parent="parent"' +
            '>' +
            '<Alignment/>' +
            '<Borders>' +
            '<Border ss:Position="Left" ss:LineStyle="Solid" ss:Weight="2" ss:Color="#0F0F0F"/>' +
            '</Borders>' +
            '<ss:Font ss:FontName="name" ss:Size="12.5"/>' +
            '<Interior ss:Color="#F0F0F0" ss:Pattern="Solid"/>' +
            '<NumberFormat ss:Format="numberFormat"/>' +
            '<Protection ss:Protected="1" ss:HideFormula="1"/>' +
            '</Style>';

        private static final String RESULT_STYLE_2 =
            '<Style' +
            ' ss:ID="style2"' +
            '>' +
            '<ss:Font ss:FontName="font" ss:Size="11.0" ss:Bold="1"/>' +
            '</Style>';

    private static final String RESULT_PROPERTIES =
        '<DocumentProperties xmlns="urn:schemas-microsoft-com:office:office">' +
        '<Property1>Value1</Property1>' +
        '<Property2>Value2</Property2>' +
        '<Property3>Value3</Property3>' +
        '</DocumentProperties>';

    private static final String RESULT_STYLES =
        '<Styles>' +
        '<Style ss:ID="Style1"></Style>' +
        '<Style ss:ID="Style2"></Style>' +
        '</Styles>';

    private static final String RESULT_SHEETS =
        '<Worksheet ss:Name="sheet1"><Table></Table></Worksheet>' +
        '<Worksheet ss:Name="sheet2"><Table></Table></Worksheet>';

    private static final String RESULT_NAMEDRANGES =
        '<Names>' +
        '<NamedRange ss:Name="Range1" ss:RefersTo="Sheet1!R1C2:R1C2"/>' +
        '<NamedRange ss:Name="Range2" ss:RefersTo="Sheet2!R1C2:R4C5"/>' +
        '</Names>';

    private static final String RESULT_WORKBOOK_BASIC =
        '<?xml version="1.0"?><?mso-applicationprogid="Excel.Sheet"?>' +
        '<Workbook' +
        ' xmlns="urn:schemas-microsoft-com:office:spreadsheet"' +
        ' xmlns:o="urn:schemas-microsoft-com:office:office"' +
        ' xmlns:x="urn:schemas-microsoft-com:office:excel"' +
        ' xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"' +
        ' xmlns:html="http://www.w3.org/TR/REC-html40">' +
        '</Workbook>';

    private static final String RESULT_WORKBOOK_FULL =
    '<?xml version="1.0"?><?mso-applicationprogid="Excel.Sheet"?>' +
    '<Workbook' +
        ' xmlns="urn:schemas-microsoft-com:office:spreadsheet"' +
        ' xmlns:o="urn:schemas-microsoft-com:office:office"' +
        ' xmlns:x="urn:schemas-microsoft-com:office:excel"' +
        ' xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"' +
        ' xmlns:html="http://www.w3.org/TR/REC-html40">' +
        '<DocumentProperties xmlns="urn:schemas-microsoft-com:office:office">' +
        '<Property>Value</Property>' +
        '</DocumentProperties>' +
        '<Styles>' +
        '<Style ss:ID="Style"></Style>' +
        '</Styles>' +
        '<Names>' +
        '<NamedRange ss:Name="Range" ss:RefersTo="sheet!R1C2:R1C2"/>' +
        '</Names>' +
        '<Worksheet ss:Name="sheet">' +
        '<NamedRange ss:Name="name" ss:RefersTo="R1C2:R1C2"/>' +
        '<Table>' +
        '<Column ss:Index="1" ss:AutoFitWidth="1" ss:Width="25"/>' +
        '<Row ss:Index="1">' +
        '<Cell ss:Index="1">' +
        '<ss:NamedTag ss:Name="Range"/>' +
        '<ss:NamedTag ss:Name="name"/>' +
        '</Cell>' +
        '</Row>' +
        '</Table>' +
        '</Worksheet>' +
        '</Workbook>';

    private static void assertEqualsNoWhite(String expected, String actual) {
     Assert.areEqual(
            expected.deleteWhitespace(),
            actual.deleteWhitespace()
        );
    }

    @IsTest
    static void test_ClassBase() {
        ExcelWorkbook.Alignment base = new ExcelWorkbook.Alignment();

        Assert.areEqual(' Name="Value"', base.attribute('Name', 'Value'));
        Assert.areEqual(' Name="3"', base.attribute('Name', (Integer) 3));
        Assert.areEqual(' Name="3.14"', base.attribute('Name', (Double) 3.14));
        Assert.areEqual(' Name="1"', base.attribute('Name', true));
        Assert.areEqual(' Name="0"', base.attribute('Name', false));

        Assert.areEqual('', base.attribute(null, 'Value'));
        Assert.areEqual('', base.attribute('Name', (String) null));
        Assert.areEqual('', base.attribute('Name', (Boolean) null));
    }

    @IsTest
    static void test_ClassAlignment() {
        ExcelWorkbook.Alignment alignmentAll = new ExcelWorkbook.Alignment();
        alignmentAll.horizontal = 'horizontal';
        alignmentAll.indent = 10;
        alignmentAll.readingOrder = 'readingOrder';
        alignmentAll.rotate = (Double) 5.43;
        alignmentAll.isShrinkToFit = false;
        alignmentAll.vertical = 'vertical';
        alignmentAll.isVerticalText = false;
        alignmentAll.isWrapText = false;

        assertEqualsNoWhite(RESULT_ALIGNMENT_ALL, alignmentAll.toText());

        ExcelWorkbook.Alignment alignmentSome = new ExcelWorkbook.Alignment();
        alignmentSome.horizontal = 'horizontal';
        alignmentSome.vertical = 'vertical';
        alignmentSome.isVerticalText = true;

        assertEqualsNoWhite(RESULT_ALIGNMENT_SOME, alignmentSome.toText());
    }

    @IsTest
    static void test_ClassBorder() {
        ExcelWorkbook.Border borderAll = new ExcelWorkbook.Border('position');
        borderAll.lineStyle = 'lineStyle';
        borderAll.weight = 10;
        borderAll.color = '#000000';

        assertEqualsNoWhite(RESULT_BORDER_ALL, borderAll.toText());

        ExcelWorkbook.Border borderSome = new ExcelWorkbook.Border('position', 'lineStyle', 20, '#FFFFFF');

        assertEqualsNoWhite(RESULT_BORDER_SOME, borderSome.toText());
    }

    @IsTest
    static void test_ClassCell() {
        ExcelWorkbook.Cell cellAll = new ExcelWorkbook.Cell(1, 1);

        cellAll.type = 'type';
        cellAll.value = 'value';
        cellAll.styleID = 'styleID';
        cellAll.formula = 'formula';
        cellAll.pasteFormula = 'pasteFormula';
        cellAll.arrayRange = 'arrayRange';
        cellAll.hRef = 'hRef';
        cellAll.toolTip = 'toolTip';
        cellAll.mergeAcross = 1;
        cellAll.mergeDown = 2;
        cellAll.phonicText('phonicText', true);
        cellAll.comment('comment', 'author', false);

        assertEqualsNoWhite(RESULT_CELL_ALL, cellAll.toText(new List<String>()));
    }

    @IsTest
    static void test_ClassColumn() {
        ExcelWorkbook.Column columnAll = new ExcelWorkbook.Column(2);

        columnAll.isAutoFitWidth = true;
        columnAll.width = 20;
        columnAll.isHidden = false;
        columnAll.span = 2;
        columnAll.caption = 'caption';

        assertEqualsNoWhite(RESULT_COLUMN_ALL, columnAll.toText());

        ExcelWorkbook.Column columnSome = new ExcelWorkbook.Column(3, false, 30);

        assertEqualsNoWhite(RESULT_COLUMN_SOME, columnSome.toText());
    }

    @IsTest
    static void test_ClassComment() {
        ExcelWorkbook.Comment commentAll = new ExcelWorkbook.Comment('comment', 'author', true);

        assertEqualsNoWhite(RESULT_COMMENT_ALL, commentAll.toText());
    }

    @IsTest
    static void test_ClassFont() {
        ExcelWorkbook.Font fontAll = new ExcelWorkbook.Font('name', 15);

        fontAll.color = '#000000';
        fontAll.isBold = false;
        fontAll.isItalic = false;
        fontAll.isOutline = false;
        fontAll.isShadow = false;
        fontAll.isStrikeThrough = false;
        fontAll.isUnderline = false;
        fontAll.isVerticalAlign = false;
        fontAll.charSet = 'charSet';
        fontAll.family = 'family';

        assertEqualsNoWhite(RESULT_FONT_ALL, fontAll.toText());
    }

    @IsTest
    static void test_ClassInterior() {
        ExcelWorkbook.Interior interiorAll = new ExcelWorkbook.Interior();

        interiorAll.color = '#000000';
        interiorAll.pattern = 'pattern';
        interiorAll.patternColor = '#FFFFFF';

        assertEqualsNoWhite(RESULT_INTERIOR_ALL, interiorAll.toText());
    }

    @IsTest
    static void test_ClassNamedRange() {
        ExcelWorkbook.NamedRange namedRangeAll = new ExcelWorkbook.NamedRange('name', 'sheet', 2, 2, 1, 1);

        namedRangeAll.isHidden = true;

        assertEqualsNoWhite(RESULT_NAMEDRANGE_ALL, namedRangeAll.toText());

        ExcelWorkbook.NamedRange namedRangeSome = new ExcelWorkbook.NamedRange('name', 1, 1, 2, 2);

        assertEqualsNoWhite(RESULT_NAMEDRANGE_SOME, namedRangeSome.toText());
    }

    @IsTest
    static void test_ClassRow() {
        ExcelWorkbook.Row rowAll = new ExcelWorkbook.Row(7);

        rowAll.isAutoFitHeight = true;
        rowAll.height = 20;
        rowAll.isHidden = false;
        rowAll.caption = 'caption';
        rowAll.styleID = 'styleID';
        rowAll.span = 6;

        assertEqualsNoWhite(RESULT_ROW_START_ALL, rowAll.toTextStart());

        ExcelWorkbook.Row namedRowSome1 = new ExcelWorkbook.Row(8);
        assertEqualsNoWhite(RESULT_ROW_START_SOME1, namedRowSome1.toTextStart());

        ExcelWorkbook.Row namedRowSome2 = new ExcelWorkbook.Row(9, false, 20);
        assertEqualsNoWhite(RESULT_ROW_START_SOME2, namedRowSome2.toTextStart());

        ExcelWorkbook.Row namedRowEnd = new ExcelWorkbook.Row(20);
        assertEqualsNoWhite(RESULT_ROW_END, namedRowEnd.toTextEnd());
    }

    @IsTest
    static void test_ClassSheet_Empty() {
        ExcelWorkbook.Sheet sheet = new ExcelWorkbook.Sheet('sheet');

        Assert.areEqual('sheet', sheet.name);
        Assert.areEqual(true, sheet.namedRanges.isEmpty());
        Assert.areEqual(true, sheet.rows.isEmpty());
        Assert.areEqual(true, sheet.columns.isEmpty());
        Assert.areEqual(true, sheet.cells.isEmpty());
        assertEqualsNoWhite(RESULT_SHEET_EMPTY, sheet.toText());
    }

    @IsTest
    static void test_ClassSheet_Options() {
        ExcelWorkbook.Sheet sheet = new ExcelWorkbook.Sheet('sheet');

        sheet.addOption('SplitVertical', '1');
        sheet.addOption('SplitHorizontal', '2');

        Assert.areEqual(false, sheet.options.isEmpty());
        Assert.areEqual(2, sheet.options.size());
        
        assertEqualsNoWhite(RESULT_SHEET_OPTIONS, sheet.toText());
    }

    @IsTest
    static void test_ClassSheet_NamedRanges() {
        ExcelWorkbook.Sheet sheet = new ExcelWorkbook.Sheet('sheet');

        sheet.addNamedRange('name1', 1, 1, 2, 4);
        sheet.addNamedRange('name2', 5, 1, 8, 4);

         Assert.areEqual(false, sheet.namedRanges.isEmpty());
         Assert.areEqual(2, sheet.namedRanges.size());
        assertEqualsNoWhite(RESULT_SHEET_NAMEDRANGES, sheet.toText());
    }

    @IsTest
    static void test_ClassSheet_Table() {
        ExcelWorkbook.Sheet sheet = new ExcelWorkbook.Sheet('sheet');

        sheet.defaultColumnWidth = 30;
        sheet.defaultRowHeight = 20;
        sheet.expandedColumnCount = 1000;
        sheet.expandedRowCount = 1000;
        sheet.leftCell = 1;
        sheet.styleID = 'styleID';
        sheet.topCell = 1;
        sheet.isFullColumns = true;
        sheet.isFullRows = true;

        assertEqualsNoWhite(RESULT_SHEET_TABLE, sheet.toText());
    }

    @IsTest
    static void test_ClassSheet_Columns() {
        ExcelWorkbook.Sheet sheet = new ExcelWorkbook.Sheet('sheet');

        ExcelWorkbook.Column column2 = sheet.addColumn(2);
        column2.isAutoFitWidth = false;
        column2.width = 30;
        ExcelWorkbook.Column column1 = sheet.addColumn(1);
        column1.isAutoFitWidth = true;
        column1.width = 25;

       Assert.areEqual(false, sheet.columns.isEmpty());
        Assert.areEqual(2, sheet.columns.size());
        assertEqualsNoWhite(RESULT_SHEET_COLUMNS, sheet.toText());
    }

    @IsTest
    static void test_ClassSheet_Rows() {
        ExcelWorkbook.Sheet sheet = new ExcelWorkbook.Sheet('sheet');

        sheet.addRow(2);
        ExcelWorkbook.Row row1 = sheet.addRow(1);
        row1.isAutoFitHeight = true;
        row1.height = 25;

        Assert.areEqual(false, sheet.rows.isEmpty());
        Assert.areEqual(2, sheet.rows.size());
        assertEqualsNoWhite(RESULT_SHEET_ROWS, sheet.toText());
    }

    @IsTest
    static void test_ClassSheet_Cells() {
        ExcelWorkbook.Sheet sheet = new ExcelWorkbook.Sheet('sheet');

        ExcelWorkbook.Row row = sheet.addRow(2);
        row.isAutoFitHeight = true;
        row.height = 25;

        ExcelWorkbook.Cell cell;

        cell = sheet.addCell(1, 2);
        cell = sheet.addCell(1, 5);
        cell = sheet.addCell(2, 1);
        cell = sheet.addCell(2, 7, 'String', 'TEXT');
        cell = sheet.addCell(4, 2, 'Number', '34.5');

        Assert.areEqual(false, sheet.rows.isEmpty());
        Assert.areEqual(3, sheet.rows.size(), 'Number of Rows');
        Assert.areEqual(3, sheet.cells.size(), 'Number of rows in cells');
       Assert.areEqual(2, sheet.cells.get(1).size(), 'Number of row 1 Cells');
        Assert.areEqual(2, sheet.cells.get(2).size(), 'Number of row 2 Cells');
        Assert.areEqual(1, sheet.cells.get(4).size(), 'Number of row 4 Cells');
        assertEqualsNoWhite(RESULT_SHEET_CELLS, sheet.toText());
    }

    @IsTest
    static void test_ClassSheet_AddCellWithStyle() {
        ExcelWorkbook.Sheet sheet = new ExcelWorkbook.Sheet('sheet');

        ExcelWorkbook.Cell cell1 = sheet.addCell(2, 7, 'String', 'TEXT', 'styleID');

        Assert.areEqual('String', cell1.type);
        Assert.areEqual('TEXT', cell1.value);
        Assert.areEqual('styleID', cell1.styleID);
    }

    @IsTest
    static void test_ClassStyle() {
        ExcelWorkbook.Style styleAll = new ExcelWorkbook.Style('styleAll');
        styleAll.name = 'name';
        styleAll.parent = 'parent';
        styleAll.addAlignment();
        styleAll.addBorder('Left', 'Solid', 2, '#0F0F0F');
        styleAll.addFont('name', (Double) 12.5);
        styleAll.interior('#F0F0F0');
        styleAll.numberFormat('numberFormat');
        styleAll.isProtected = true;
        styleAll.isHideFormula = true;
        assertEqualsNoWhite(RESULT_STYLE_ALL, styleAll.toText());

        ExcelWorkbook.Style style2 = new ExcelWorkbook.Style('style2');
        style2.addFont('font', (Double) 11, true);
        assertEqualsNoWhite(RESULT_STYLE_2, style2.toText());
    }

    @IsTest
    static void test_ExcelWorkbook_constructor() {
        ExcelWorkbook workbook = new ExcelWorkbook();

        Assert.isTrue(workbook.properties.isEmpty());
        Assert.isTrue(workbook.styles.isEmpty());
        Assert.isTrue(workbook.namedRanges.isEmpty());
        Assert.isTrue(workbook.sheets.isEmpty());
    }

    @IsTest
    static void test_ExcelWorkbook_build() {
        ExcelWorkbook workbook = new ExcelWorkbook();

        assertEqualsNoWhite(RESULT_WORKBOOK_BASIC, workbook.build());

        workbook.addDocumentProperty('Property', 'Value');
        workbook.addNamedRange('Range', 'sheet', 1, 1, 2, 2);
        workbook.addStyle('Style');

        ExcelWorkbook.Sheet sheet = workbook.addSheet('sheet');
        sheet.addNamedRange('name', 1, 1, 2, 2);
        ExcelWorkbook.Column column = sheet.addColumn(1);
        column.isAutoFitWidth = true;
        column.width = 25;

        sheet.addCell(1, 1);

        assertEqualsNoWhite(RESULT_WORKBOOK_FULL, workbook.build());
    }

    @IsTest
    static void test_ExcelWorkbook_toTextWorkbook() {
        ExcelWorkbook workbook = new ExcelWorkbook();

       Assert.areEqual(ExcelWorkbook.WORKBOOK_START, workbook.toTextWorkbookStart());
       Assert.areEqual(ExcelWorkbook.WORKBOOK_END, workbook.toTextWorkbookEnd());
    }

    @IsTest
    static void test_ExcelWorkbook_DocumentProperty() {
        ExcelWorkbook workbook = new ExcelWorkbook();

        workbook.addDocumentProperty('Property1', 'Value1');
        workbook.addDocumentProperty('Property2', 'Value2');
        workbook.addDocumentProperty('Property3', 'Value3');

        Assert.areEqual(3, workbook.properties.size());
        assertEqualsNoWhite(RESULT_PROPERTIES, workbook.toText(workbook.properties));
    }

    @IsTest
    static void test_ExcelWorkbook_NamedRanges() {
        ExcelWorkbook workbook = new ExcelWorkbook();

        workbook.addNamedRange('Range1', 'Sheet1', 1, 1, 2, 2);
        workbook.addNamedRange('Range2', 'Sheet2', 1, 5, 2, 4);

        Assert.areEqual(2, workbook.namedRanges.size());
        assertEqualsNoWhite(RESULT_NAMEDRANGES, workbook.toText(workbook.namedRanges));
    }

    @IsTest
    static void test_ExcelWorkbook_Sytles() {
        ExcelWorkbook workbook = new ExcelWorkbook();

        workbook.addStyle('Style1');
        workbook.addStyle('Style2');

        Assert.areEqual(2, workbook.styles.size());
        assertEqualsNoWhite(RESULT_STYLES, workbook.toText(workbook.styles));
    }

    @IsTest
    static void test_ExcelWorkbook_Sheets() {
        ExcelWorkbook workbook = new ExcelWorkbook();

        workbook.addSheet('sheet1');
        workbook.addSheet('sheet2');

        Assert.areEqual(2, workbook.sheets.size());
        assertEqualsNoWhite(RESULT_SHEETS, workbook.toText(workbook.sheets));
    }
}