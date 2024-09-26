/**
 * @description ExcelWorkbook
 *
 * Format of Range example:  R1C1:R2C2
 *
 * FUTURE WORK
 *   Order the sheets
 *   Element: Data - How?
 *   Element: o:SmartTags in ss:Cell
 *   stN:SmartTag in o:SmartTags
 *   x:AutoFilter, x:AutoFilterAnd, x:AutoFilterColumn, x:AutoFilterCondition, x:AutoFilterOr, x:Footer, x:Header, more
 *   Element: ComponentOptions
 *   Element: WorksheetOptions
 *
 * See:
 *   EXCEL FILE FORMAT:
 *     https://docs.microsoft.com/en-us/previous-versions/office/developer/office-xp/aa140066(v=office.10)?redirectedfrom=MSDN
 *     http://m8y.org/Microsoft_Office_2003_XML_Reference_Schemas/Help/
 *   Document Properties
 *     https://docs.microsoft.com/en-us/office/vba/api/excel.workbook.builtindocumentproperties
 *   WorksheetOptions:
 *     http://m8y.org/Microsoft_Office_2003_XML_Reference_Schemas/Help/html/xeleWorksheetOptions_HV01105084.htm
 *     http://m8y.org/Microsoft_Office_2003_XML_Reference_Schemas/Help/
 *     https://www.bennadel.com/blog/467-freezing-row-column-panes-in-excel-xml.htm
 */
@SuppressWarnings('PMD.ExcessiveClassLength,PMD.ApexDoc,PMD.ExcessivePublicCount')
public virtual class ExcelWorkbook {    
	public static final String TYPE_STRING = 'String';
	public static final String TYPE_FORMULA = 'Formula';
	public static final String TYPE_NUMBER = 'Number';

    private static final String TAG_CLOSE = '>';
    private static final String TAG_FINISH = '/>';

    private static final String TAG_ALIGNMENT_START = '\n   <Alignment';

    private static final String TAG_BORDER_START = '\n    <Border';

    private static final String TAG_BORDERS_START = '\n   <Borders>';
    private static final String TAG_BORDERS_END = '\n   </Borders>';

    private static final String TAG_CELL_START = '\n    <Cell';
    private static final String TAG_CELL_END = '</Cell>';

    private static final String TAG_COLUMN_START = '\n   <Column';

    private static final String TAG_COMMENT_START = '<Comment';
    private static final String TAG_COMMENT_END = '</Comment>';

    private static final String TAG_DATA_START = '<Data';
    private static final String TAG_DATA_END = '</Data>';

    private static final String TAG_DOCUMENT_PROPERTIES_START = '\n <DocumentProperties xmlns="urn:schemas-microsoft-com:office:office">';
    private static final String TAG_DOCUMENT_PROPERTIES_END = '\n </DocumentProperties>';

    private static final String TAG_FONT_START = '\n   <ss:Font';

    private static final String TAG_INTERIOR_START = '\n   <Interior';

    private static final String TAG_NAMERANGE_START = '\n   <NamedRange';

    private static final String TAG_NAMES_START = '\n  <Names>';
    private static final String TAG_NAMES_END = '\n  </Names>';

    private static final String TAG_NAMED_TAG_START = '\n  <ss:NamedTag';

    private static final String TAG_NUMBER_FORMAT_START = '\n   <NumberFormat';

    private static final String TAG_PHONIC_TEXT_START = '\n<PhonicText';
    private static final String TAG_PHONIC_TEXT_END = '</PhonicText>';

    private static final String TAG_PROTECTION_START = '\n<Protection';

    private static final String TAG_ROW_START = '\n   <Row';
    private static final String TAG_ROW_END = '\n   </Row>';

    private static final String TAG_STYLE_START = '\n  <Style';
    private static final String TAG_STYLE_END = '\n  </Style>';

    private static final String TAG_STYLES_START = '\n <Styles>';
    private static final String TAG_STYLES_END = '\n </Styles>';

    private static final String TAG_TABLE_START = '\n  <Table';
    private static final String TAG_TABLE = '\n  </Table>';

    private static final String TAG_WORKSHEET_OPTIONS_START = '\n  <WorksheetOptions>';
    private static final String TAG_WORKSHEET_OPTIONS_END = '\n  </WorksheetOptions>';

    private static final String TAG_WORKSHEET_START = '\n <Worksheet';
    private static final String TAG_WORKSHEET_END = '\n </Worksheet>';

    private static final String FORMAT_TAG_SHEET_OPTION = '\n   <{0}>{1}</{0}>';

    @TestVisible
    private static final String WORKBOOK_START =
        '<?xml version="1.0"?>' +
        '\n<?mso-application progid="Excel.Sheet"?>' +
        '\n<Workbook' +
        ' xmlns="urn:schemas-microsoft-com:office:spreadsheet"' +
        ' xmlns:o="urn:schemas-microsoft-com:office:office"' +
        ' xmlns:x="urn:schemas-microsoft-com:office:excel"' +
        ' xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"' +
        ' xmlns:html="http://www.w3.org/TR/REC-html40">';

    @TestVisible
    private static final String WORKBOOK_END = '\n</Workbook>';

    private static final String ATTRIBUTE_ARRAY_RANGE = 'ss:ArrayRange';
    private static final String ATTRIBUTE_AUTHOR = 'ss:Author';
    private static final String ATTRIBUTE_AUTO_FIT_HEIGHT = 'ss:AutoFitHeight';
    private static final String ATTRIBUTE_AUTO_FIT_WIDTH = 'ss:AutoFitWidth';
    private static final String ATTRIBUTE_BOLD = 'ss:Bold';
    private static final String ATTRIBUTE_CAPTION = 'c:Caption';
    private static final String ATTRIBUTE_CHAR_SET = 'x:CharSet';
    private static final String ATTRIBUTE_COLOR = 'ss:Color';
    private static final String ATTRIBUTE_DEFAULT_COLUMN_WIDTH = 'ss:DefaultColumnWidth';
    private static final String ATTRIBUTE_DEFAULT_ROW_HEIGHT = 'ss:DefaultRowHeight';
    private static final String ATTRIBUTE_EXPANDED_COLUMN_COUNT = 'ss:ExpandedColumnCount';
    private static final String ATTRIBUTE_EXPANDED_ROW_COUNT = 'ss:ExpandedRowCount';
    private static final String ATTRIBUTE_FAMILY = 'x:Family';
    private static final String ATTRIBUTE_FONT_NAME = 'ss:FontName';
    private static final String ATTRIBUTE_FORMAT = 'ss:Format';
    private static final String ATTRIBUTE_FORMULA = 'ss:Formula';
    private static final String ATTRIBUTE_FULL_COLUMNS = 'x:FullColumns';
    private static final String ATTRIBUTE_FULL_ROWS = 'x:FullRows';
    private static final String ATTRIBUTE_HEIGHT = 'ss:Height';
    private static final String ATTRIBUTE_HIDDEN = 'ss:Hidden';
    private static final String ATTRIBUTE_HIDE_FORMULA = 'ss:HideFormula';
    private static final String ATTRIBUTE_HORIZONTAL = 'ss:Horizontal';
    private static final String ATTRIBUTE_HREF = 'ss:HRef';
    private static final String ATTRIBUTE_HREF_SCREEN_TIP = 'ss:HRefScreenTip';
    private static final String ATTRIBUTE_ID = 'ss:ID';
    private static final String ATTRIBUTE_INDENT = 'ss:Indent';
    private static final String ATTRIBUTE_INDEX = 'ss:Index';
    private static final String ATTRIBUTE_ITALIC = 'ss:Italic';
    private static final String ATTRIBUTE_LEFT_CELL = 'ss:LeftCell';
    private static final String ATTRIBUTE_LINE_STYLE = 'ss:LineStyle';
    private static final String ATTRIBUTE_MERGE_ACROSS = 'ss:MergeAcross';
    private static final String ATTRIBUTE_MERGE_DOWN = 'ss:MergeDown';
    private static final String ATTRIBUTE_NAME = 'ss:Name';
    private static final String ATTRIBUTE_OUTLINE = 'ss:Outline';
    private static final String ATTRIBUTE_PARENT = 'ss:Parent';
    private static final String ATTRIBUTE_PASTE_FORMULA = 'ss:PasteFormula';
    private static final String ATTRIBUTE_PATTERN = 'ss:Pattern';
    private static final String ATTRIBUTE_PATTERN_COLOR = 'ss:PatternColor';
    private static final String ATTRIBUTE_POSITION = 'ss:Position';
    private static final String ATTRIBUTE_PROTECTED = 'ss:Protected';
    private static final String ATTRIBUTE_READING_ORDER = 'ss:ReadingOrder';
    private static final String ATTRIBUTE_REFERS_TO = 'ss:RefersTo';
    private static final String ATTRIBUTE_RIGHT_TO_LEFT = 'ss:RightToLeft';
    private static final String ATTRIBUTE_ROTATE = 'ss:Rotate';
    private static final String ATTRIBUTE_SHADOW = 'ss:Shadow';
    private static final String ATTRIBUTE_SHOW_ALWAYS = 'ss:ShowAlways';
    private static final String ATTRIBUTE_SHRINK_TO_FIT = 'ss:ShrinkToFit';
    private static final String ATTRIBUTE_SIZE = 'ss:Size';
    private static final String ATTRIBUTE_SPAN = 'ss:Span';
    private static final String ATTRIBUTE_STRIKETHROUGH = 'ss:StrikeThrough';
    private static final String ATTRIBUTE_STYLE_ID = 'ss:StyleID';
    private static final String ATTRIBUTE_TOP_CELL = 'ss:TopCell';
    private static final String ATTRIBUTE_TYPE = 'ss:Type';
    private static final String ATTRIBUTE_UNDERLINE = 'ss:Underline';
    private static final String ATTRIBUTE_VERTICAL = 'ss:Vertical';
    private static final String ATTRIBUTE_VERTICAL_ALIGN = 'ss:VerticalAlign';
    private static final String ATTRIBUTE_VERTICAL_TEXT = 'ss:VerticalText';
    private static final String ATTRIBUTE_VISIBLE = 'ss:Visible';
    private static final String ATTRIBUTE_WEIGHT = 'ss:Weight';
    private static final String ATTRIBUTE_WIDTH = 'ss:Width';
    private static final String ATTRIBUTE_WRAP_TEXT = 'ss:WrapText';

    @TestVisible
    private Map<String, String> properties;
    @TestVisible
    private Map<String, Style> styles;
    @TestVisible
    private Map<String, NamedRange> namedRanges;
    @TestVisible
    private Map<String, Sheet> sheets;

    /**
     * @description Base class contains basic methods for the other Excel object classes.
     */
    @TestVisible
    private abstract class Base {
        @TestVisible
        private String attribute(String name, String value) {
            if (!String.isBlank(name) && value != null) {
                return ' ' + name + '="' + value + '"';
            }
            return '';
        }

        @TestVisible
        private String attribute(String name, Integer value) {
            return attribute(name, String.valueOf(value));
        }

        @TestVisible
        private String attribute(String name, Double value) {
            return attribute(name, String.valueOf(value));
        }

        @TestVisible
        private String attribute(String name, Boolean value) {
            if (value != null) {
                return attribute(name, value ? '1' : '0');
            }
            return '';
        }
    }

    /**
     * @description Alignment class contains data about an Alignment.
     * Alignment is contained intirely in Style.
     */
    @TestVisible
    public class Alignment extends Base {
        public String horizontal { get; set; }
        public Integer indent { get; set; }
        public String readingOrder { get; set; }
        public Double rotate { get; set; }
        public Boolean isShrinkToFit { get; set; }
        public String vertical { get; set; }
        public Boolean isVerticalText { get; set; }
        public Boolean isWrapText { get; set; }

        @TestVisible
        private String toText() {
            String text = '';

            text += TAG_ALIGNMENT_START;
            text += attribute(ATTRIBUTE_HORIZONTAL, horizontal);
            text += attribute(ATTRIBUTE_INDENT, indent);
            text += attribute(ATTRIBUTE_READING_ORDER, readingOrder);
            text += attribute(ATTRIBUTE_ROTATE, rotate);
            text += attribute(ATTRIBUTE_SHRINK_TO_FIT, isShrinkToFit);
            text += attribute(ATTRIBUTE_VERTICAL, vertical);
            text += attribute(ATTRIBUTE_VERTICAL_TEXT, isVerticalText);
            text += attribute(ATTRIBUTE_WRAP_TEXT, isWrapText);
            text += TAG_FINISH;

            return text;
        }
    }

    /**
     * @description Border class contains data about an Excel Border.
     */
    @TestVisible
    private class Border extends Base {
        public String position { get; private set; }
        public String lineStyle { get; set; }
        public Integer weight { get; set; }
        public String color { get; set; }

        @TestVisible
        private Border(String position) {
            this.position = position;
        }

        @TestVisible
        private Border(String position, String lineStyle, Integer weight, String color) {
            this.position = position;
            this.lineStyle = lineStyle;
            this.weight = weight;
            this.color = color;
        }

        @TestVisible
        private String toText() {
            String text = '';

            text += TAG_BORDER_START;
            text += attribute(ATTRIBUTE_POSITION, position);
            text += attribute(ATTRIBUTE_LINE_STYLE, lineStyle);
            text += attribute(ATTRIBUTE_WEIGHT, weight);
            text += attribute(ATTRIBUTE_COLOR, color);
            text += TAG_FINISH;

            return text;
        }
    }

    /**
     * @description Cell class contains data about a Cell.
     */
    public class Cell extends Base {
        private String phonicText;
        private Boolean isVisible;

        public Integer row { private get; private set; }
        public Integer column { private get; private set; }
        public String type { get; set; }
        public String value { get; set; }
        public String styleID { get; set; }
        public String formula { get; set; }
        public String pasteFormula { get; set; }
        public String arrayRange { get; set; }
        public String hRef { get; set; }
        public String toolTip { get; set; }
        public Integer mergeAcross { get; set; }
        public Integer mergeDown { get; set; }
        private Comment comment { get; set; }

        @TestVisible
        private Cell(Integer row, Integer column) {
            this.row = row;
            this.column = column;
        }

        public void phonicText(String text, Boolean isVisible) {
            this.phonicText = text;
            this.isVisible = isVisible;
        }

        public void comment(String text, String author, Boolean isShowAlways) {
            comment = new Comment(text, author, isShowAlways);
        }

        @TestVisible
        private String toText(List<String> namedRanges) {
            String text = '';

            text += TAG_CELL_START;
            text += attribute(ATTRIBUTE_INDEX, column);
            text += attribute(ATTRIBUTE_STYLE_ID, styleID);
            text += attribute(ATTRIBUTE_FORMULA, formula);
            text += attribute(ATTRIBUTE_MERGE_ACROSS, mergeAcross);
            text += attribute(ATTRIBUTE_MERGE_DOWN, mergeDown);
            text += attribute(ATTRIBUTE_PASTE_FORMULA, pasteFormula);
            text += attribute(ATTRIBUTE_ARRAY_RANGE, arrayRange);
            text += attribute(ATTRIBUTE_HREF, hRef);
            text += attribute(ATTRIBUTE_HREF_SCREEN_TIP, toolTip);
            text += TAG_CLOSE;

            if (!String.isBlank(type)) {
                text += TAG_DATA_START;
                text += attribute(ATTRIBUTE_TYPE, type);
                text += TAG_CLOSE;
                if (!String.isBlank(value)) {
                    text += value;
                }
                text += TAG_DATA_END;
            }
            if (comment != null) {
                text += comment.toText();
            }

            if (!String.isBlank(phonicText)) {
                text += TAG_PHONIC_TEXT_START;
                text += attribute(ATTRIBUTE_VISIBLE, isVisible);
                text += TAG_CLOSE;
                text += phonicText;
                text += TAG_PHONIC_TEXT_END;
            }

            for (String namedRange : namedRanges) {
                text += TAG_NAMED_TAG_START;
                text += attribute(ATTRIBUTE_NAME, namedRange);
                text += TAG_FINISH;
            }

            text += TAG_CELL_END;

            return text;
        }
    }

    /**
     * @description Column class contains data about a Column.
     */
    public class Column extends Base {
        public Integer index { get; private set; }
        public Boolean isAutoFitWidth { get; set; }
        public Integer width { get; set; }
        public String caption { get; set; }
        public Boolean isHidden { get; set; }
        public String styleID { get; set; }
        public Integer span { get; set; }

        @TestVisible
        private Column(Integer index) {
            this.index = index;
        }

        @TestVisible
        private Column(Integer index, Boolean autoFitWidth, Integer width) {
            this.index = index;
            this.isAutoFitWidth = autoFitWidth;
            this.width = width;
        }

        @TestVisible
        private String toText() {
            String text = '';

            text += TAG_COLUMN_START;
            text += attribute(ATTRIBUTE_INDEX, index);
            text += attribute(ATTRIBUTE_AUTO_FIT_WIDTH, isAutoFitWidth);
            text += attribute(ATTRIBUTE_WIDTH, width);
            text += attribute(ATTRIBUTE_HIDDEN, isHidden);
            text += attribute(ATTRIBUTE_STYLE_ID, styleID);
            text += attribute(ATTRIBUTE_SPAN, span);
            text += attribute(ATTRIBUTE_CAPTION, caption);
            text += TAG_FINISH;

            return text;
        }
    }

    /**
     * @description Comment class contains data about a Comment.
     * Comment is contained in Cell.
     */
    @TestVisible
    private class Comment extends Base {
        private String data { get; private set; }
        private String author { get; private set; }
        private Boolean isShowAlways { get; private set; }

        public Comment(String data, String author, Boolean isShowAlways) {
            this.data = data;
            this.author = author;
            this.isShowAlways = isShowAlways;
        }

        @TestVisible
        private String toText() {
            String text = '';

            text += TAG_COMMENT_START;
            text += attribute(ATTRIBUTE_AUTHOR, author);
            text += attribute(ATTRIBUTE_SHOW_ALWAYS, isShowAlways);
            text += TAG_CLOSE;

            text += TAG_DATA_START;
            text += TAG_CLOSE;
            if (!String.isBlank(data)) {
                text += data;
            }
            text += TAG_DATA_END;

            text += TAG_COMMENT_END;

            return text;
        }
    }

    /**
     * @description Font class contains data about a Font.
     */
    public class Font extends Base {
        public String name { get; private set; }
        public Double size { get; set; }
        public String color { get; set; }
        public Boolean isBold { get; set; }
        public Boolean isItalic { get; set; }
        public Boolean isOutline { get; set; }
        public Boolean isShadow { get; set; }
        public Boolean isStrikeThrough { get; set; }
        public Boolean isUnderline { get; set; }
        public Boolean isVerticalAlign { get; set; }
        public String charSet { get; set; }
        public String family { get; set; }

        @TestVisible
        private Font(String name, Double size) {
            this.name = name;
            this.size = size;
        }

        @TestVisible
        private String toText() {
            String text = '';

            text += TAG_FONT_START;
            text += attribute(ATTRIBUTE_FAMILY, family);
            text += attribute(ATTRIBUTE_CHAR_SET, charSet);
            text += attribute(ATTRIBUTE_FONT_NAME, name);
            text += attribute(ATTRIBUTE_SIZE, size);
            text += attribute(ATTRIBUTE_BOLD, isBold);
            text += attribute(ATTRIBUTE_COLOR, color);
            text += attribute(ATTRIBUTE_ITALIC, isItalic);
            text += attribute(ATTRIBUTE_OUTLINE, isOutline);
            text += attribute(ATTRIBUTE_SHADOW, isShadow);
            text += attribute(ATTRIBUTE_STRIKETHROUGH, isStrikeThrough);
            text += attribute(ATTRIBUTE_UNDERLINE, isUnderline);
            text += attribute(ATTRIBUTE_VERTICAL_ALIGN, isVerticalAlign);
            text += TAG_FINISH;

            return text;
        }
    }

    /**
     * @description Interior class contains data about an Interior.
     * Interior is entirely contained in Style
     */
    @TestVisible
    private class Interior extends Base {
        public String color { get; set; }
        public String pattern { get; set; }
        public String patternColor { get; set; }

        @TestVisible
        private String toText() {
            String text = '';

            text += TAG_INTERIOR_START;
            text += attribute(ATTRIBUTE_COLOR, color);
            text += attribute(ATTRIBUTE_PATTERN, pattern);
            text += attribute(ATTRIBUTE_PATTERN_COLOR, patternColor);
            text += TAG_FINISH;

            return text;
        }
    }

    /**
     * @description NamedRange class contains data about a NamedRange.
     */
    @TestVisible
    private class NamedRange extends Base {
        public String name { get; private set; }
        public String sheet { get; private set; }
        public Integer rowFrom { get; private set; }
        public Integer columnFrom { get; private set; }
        public Integer rowTo { get; private set; }
        public Integer columnTo { get; private set; }
        public Boolean isHidden { get; set; }

        public NamedRange(String name, Integer rowFrom, Integer columnFrom, Integer rowTo, Integer columnTo) {
            this.name = name;

            setRange(rowFrom, columnFrom, rowTo, columnTo);
        }

        @SuppressWarnings('PMD.ExcessiveParameterList')
        public NamedRange(
            String name,
            String sheet,
            Integer rowFrom,
            Integer columnFrom,
            Integer rowTo,
            Integer columnTo
        ) {
            this.name = name;
            this.sheet = sheet;

            setRange(rowFrom, columnFrom, rowTo, columnTo);
        }

        public void setRange(Integer rowFrom, Integer columnFrom, Integer rowTo, Integer columnTo) {
            if (rowFrom < rowTo) {
                this.rowFrom = rowFrom;
                this.rowTo = rowTo;
            } else {
                this.rowFrom = rowTo;
                this.rowTo = rowFrom;
            }

            if (columnFrom < columnTo) {
                this.columnFrom = columnFrom;
                this.columnTo = columnTo;
            } else {
                this.columnFrom = columnTo;
                this.columnTo = columnFrom;
            }
        }

        @TestVisible
        private Boolean inRange(Integer row, Integer column) {
            return (rowFrom <= row && row <= rowTo) && (columnFrom <= column && column <= columnTo);
        }

        @TestVisible
        private String toText() {
            String textRange = '';

            if (!String.isBlank(sheet)) {
                textRange += sheet + '!';
            }

            textRange += 'R' + rowFrom;
            textRange += 'C' + rowTo;
            textRange += ':';
            textRange += 'R' + columnFrom;
            textRange += 'C' + columnTo;

            String text = '';

            text += TAG_NAMERANGE_START;
            text += attribute(ATTRIBUTE_NAME, name);
            text += attribute(ATTRIBUTE_REFERS_TO, textRange);
            text += attribute(ATTRIBUTE_HIDDEN, isHidden);
            text += TAG_FINISH;

            return text;
        }
    }

    /**
     * @description Row class contains data about a Row.
     */
    public class Row extends Base {
        public Integer index { get; private set; }
        public Boolean isAutoFitHeight { get; set; }
        public Integer height { get; set; }
        public Boolean isHidden { get; set; }
        public String caption { get; set; }
        public String styleID { get; set; }
        public Integer span { get; set; }

        @TestVisible
        private Row(Integer index) {
            this.index = index;
        }

        @TestVisible
        private Row(Integer index, Boolean autoFitWidth, Integer height) {
            this.index = index;
            this.isAutoFitHeight = autoFitWidth;
            this.height = height;
        }

        @TestVisible
        private String toTextStart() {
            String text = '';

            text += TAG_ROW_START;
            text += attribute(ATTRIBUTE_INDEX, index);
            text += attribute(ATTRIBUTE_AUTO_FIT_HEIGHT, isAutoFitHeight);
            text += attribute(ATTRIBUTE_HEIGHT, height);
            text += attribute(ATTRIBUTE_SPAN, span);
            text += attribute(ATTRIBUTE_CAPTION, caption);
            text += TAG_CLOSE;

            return text;
        }

        @TestVisible
        private String toTextEnd() {
            return TAG_ROW_END;
        }
    }

    /**
     * @description Sheet class contains data about an Excel sheet.
     */
    public class Sheet extends Base {
        @TestVisible
        private Map<String, NamedRange> namedRanges;
        @TestVisible
        private Map<Integer, Row> rows;
        @TestVisible
        private Map<Integer, Column> columns;
        @TestVisible
        private Map<Integer, Map<Integer, Cell>> cells;
        @TestVisible
        private List<NamedRange> workbookNamedRanges;
        @TestVisible
        private List<NamedRange> checkNamedRanges;
        @TestVisible
        private Map<String, String> options = new Map<String, String>();

        public String name { get; private set; }
        public Boolean isProtected { get; set; }
        public Boolean isRightToLeft { get; set; }
        public Integer defaultColumnWidth { get; set; }
        public Integer defaultRowHeight { get; set; }
        public Integer expandedColumnCount { get; set; }
        public Integer expandedRowCount { get; set; }
        public Integer leftCell { get; set; }
        public String styleID { get; set; }
        public Integer topCell { get; set; }
        public Boolean isFullColumns { get; set; }
        public Boolean isFullRows { get; set; }

        @TestVisible
        private Sheet(String name) {
            this.name = name;

            namedRanges = new Map<String, NamedRange>();
            columns = new Map<Integer, Column>();
            rows = new Map<Integer, Row>();
            cells = new Map<Integer, Map<Integer, Cell>>();
        }

        public void addOption(String element, String value) {
            options.put(element, value);
        }

        public void addNamedRange(String name, Integer rowFrom, Integer columnFrom, Integer rowTo, Integer columnTo) {
            NamedRange range = new namedRange(name, rowFrom, columnFrom, rowTo, columnTo);
            namedRanges.put(name, range);
        }

        public Row addRow(Integer rowIndex) {
            Row row = new Row(rowIndex);
            rows.put(rowIndex, row);
            return row;
        }

        public Column addColumn(Integer indexColumn) {
            Column column = new Column(indexColumn);
            columns.put(indexColumn, column);
            return column;
        }

        public Cell addCell(Integer indexRow, Integer indexColumn) {
            if (!this.rows.containsKey(indexRow)) {
                addRow(indexRow);
            }

            if (!cells.containsKey(indexRow)) {
                cells.put(indexRow, new Map<Integer, Cell>());
            }

            Map<Integer, Cell> row = cells.get(indexRow);

            Cell cell = new Cell(indexRow, indexColumn);
            row.put(indexColumn, cell);
            return cell;
        }

        public Cell addCell(Integer indexRow, Integer indexColumn, String type, String value) {
            return addCell(indexRow, indexColumn, type, value, null);
        }

        public Cell addCell(Integer indexRow, Integer indexColumn, String type, String value, String styleID) {
            Cell cell = addCell(indexRow, indexColumn);

            cell.type = type;
            cell.value = value;
            cell.styleID = styleID;

            return cell;
        }

        public Cell addFormulaCell(Integer indexRow, Integer indexColumn, String formula, String type, String value) {
            return addFormulaCell(indexRow, indexColumn, formula, type, value, null);
        }

        @SuppressWarnings('PMD.ExcessiveParameterList')
        public Cell addFormulaCell(
            Integer indexRow,
            Integer indexColumn,
            String formula,
            String type,
            String value,
            String styleID
        ) {
            Cell cell = addCell(indexRow, indexColumn);

            cell.formula = formula;
            cell.type = type;
            cell.value = value;
            cell.styleID = styleID;

            return cell;
        }

        @TestVisible
        private void setWorkbookNamedRanges(List<NamedRange> workbookNamedRanges) {
            this.workbookNamedRanges = workbookNamedRanges;
        }

        @TestVisible
        private String toText() {
            checkNamedRanges = getNamedRangesForSheet();

            String text = '';

            text += toTextWorksheetStart();
            text += toTextNamedRanges();
            text += toTextTableStart();
            text += toTextColumns();
            text += toTextRows();
            text += toTextTableEnd();
            text += toTextWorksheetOptions();
            text += toTextWorksheetEnd();

            return text;
        }

        private String toTextWorksheetStart() {
            String text = '';

            text += TAG_WORKSHEET_START;
            text += attribute(ATTRIBUTE_NAME, name);
            text += attribute(ATTRIBUTE_PROTECTED, isProtected);
            text += attribute(ATTRIBUTE_RIGHT_TO_LEFT, isRightToLeft);
            text += TAG_CLOSE;

            return text;
        }

        private String toTextWorksheetOptions() {
            String text = '';

            if (!options.isEmpty()) {
                text += TAG_WORKSHEET_OPTIONS_START;

                List<String> keys = new List<String>(options.keySet());
                keys.sort();

                for (String element : keys) {
                    text += String.format(FORMAT_TAG_SHEET_OPTION, new List<String>{ element, options.get(element) });
                }

                text += TAG_WORKSHEET_OPTIONS_END;
            }

            return text;
        }

        private String toTextWorksheetEnd() {
            return TAG_WORKSHEET_END;
        }

        @TestVisible
        private String toTextNamedRanges() {
            String text = '';

            for (NamedRange range : namedRanges.values()) {
                text += range.toText();
            }

            return text;
        }

        @TestVisible
        private String toTextTableStart() {
            String text = '';

            text += TAG_TABLE_START;
            text += attribute(ATTRIBUTE_DEFAULT_COLUMN_WIDTH, defaultColumnWidth);
            text += attribute(ATTRIBUTE_DEFAULT_ROW_HEIGHT, defaultRowHeight);
            text += attribute(ATTRIBUTE_EXPANDED_COLUMN_COUNT, expandedColumnCount);
            text += attribute(ATTRIBUTE_EXPANDED_ROW_COUNT, expandedRowCount);
            text += attribute(ATTRIBUTE_LEFT_CELL, leftCell);
            text += attribute(ATTRIBUTE_STYLE_ID, styleID);
            text += attribute(ATTRIBUTE_TOP_CELL, topCell);
            text += attribute(ATTRIBUTE_FULL_COLUMNS, isFullColumns);
            text += attribute(ATTRIBUTE_FULL_ROWS, isFullRows);
            text += TAG_CLOSE;

            return text;
        }

        @TestVisible
        private String toTextTableEnd() {
            return TAG_TABLE;
        }

        @TestVisible
        private String toTextColumns() {
            String text = '';

            List<Integer> columnIndices = new List<Integer>(columns.keySet());
            columnIndices.sort();

            for (Integer index : columnIndices) {
                text += columns.get(index).toText();
            }

            return text;
        }

        @TestVisible
        private String toTextRows() {
            String text = '';

            List<Integer> rowIndices = new List<Integer>(rows.keySet());
            rowIndices.sort();

            for (Integer rowIndex : rowIndices) {
                text += rows.get(rowIndex).toTextStart();

                if (cells.containsKey(rowIndex)) {
                    Map<Integer, Cell> rowData = cells.get(rowIndex);
                    List<Integer> cellColumnIndices = new List<Integer>(rowData.keySet());
                    cellColumnIndices.sort();

                    for (Integer columnIndex : cellColumnIndices) {
                        Cell cell = rowData.get(columnIndex);

                        cell.row = rowIndex;
                        cell.column = columnIndex;

                        text += cell.toText(getNamedRangesRelatedToCell(cell.row, cell.column));
                    }
                }

                text += rows.get(rowIndex).toTextEnd();
            }

            return text;
        }

        @TestVisible
        private List<NamedRange> getNamedRangesForSheet() {
            List<NamedRange> result = new List<NamedRange>();

            // Check all the named ranges in the workbook
            if (workbookNamedRanges != null) {
                for (NamedRange namedRange : workbookNamedRanges) {
                    if (namedRange.sheet == this.name) {
                        result.add(namedRange);
                    }
                }
            }

            // Check all the named ranges in the worksheet
            for (NamedRange namedRange : namedRanges.values()) {
                result.add(namedRange);
            }

            return result;
        }

        @TestVisible
        private List<String> getNamedRangesRelatedToCell(Integer row, Integer column) {
            List<String> result = new List<String>();

            for (NamedRange namedRange : checkNamedRanges) {
                if (namedRange.inRange(row, column)) {
                    result.add(namedRange.name);
                }
            }

            result.sort();

            return result;
        }
    }

    /**
     * @description Style class contains data about an Excel style.
     */
    public class Style extends Base {
        private Alignment alignment;
        private Map<String, Border> borders = new Map<String, Border>();
        private Font font;
        private Interior interior;
        private String numberFormat;

        public String styleID { get; private set; }
        public String name { get; set; }
        public String parent { get; set; }
        public Boolean isProtected { get; set; }
        public Boolean isHideFormula { get; set; }

        @TestVisible
        private Style(String styleID) {
            this.styleID = styleID;
        }

        public Alignment addAlignment() {
            this.alignment = new Alignment();
            return this.alignment;
        }

        public void addBorder(String position, String lineStyle, Integer weight, String color) {
            borders.put(position, new Border(position, lineStyle, weight, color));
        }

        public void addAllBorders(String lineStyle, Integer weight, String color) {
            addBorder('Top', lineStyle, weight, color);
            addBorder('Bottom', lineStyle, weight, color);
            addBorder('Left', lineStyle, weight, color);
            addBorder('Right', lineStyle, weight, color);
        }

        public Font addFont(String name, Double size) {
            this.font = new Font(name, size);
            return this.font;
        }

        public Font addFont(String name, Double size, Boolean isBold) {
            this.font = new Font(name, size);
            this.font.isBold = isBold;
            return this.font;
        }

        public void interior(String color) {
            interior(color, 'Solid', null);
        }

        public void interior(String color, String pattern, String patternColor) {
            this.interior = new Interior();
            this.interior.color = color;
            this.interior.pattern = pattern;
            this.interior.patternColor = patternColor;
        }

        public void numberFormat(String numberFormat) {
            this.numberFormat = numberFormat;
        }

        @TestVisible
        private String toText() {
            String text = '';

            text += TAG_STYLE_START;
            text += attribute(ATTRIBUTE_ID, styleID);
            text += attribute(ATTRIBUTE_NAME, name);
            text += attribute(ATTRIBUTE_PARENT, parent);
            text += TAG_CLOSE;

            if (alignment != null) {
                text += alignment.toText();
            }

            if (!borders.isEmpty()) {
                text += TAG_BORDERS_START;
                for (Border border : borders.values()) {
                    text += border.toText();
                }
                text += TAG_BORDERS_END;
            }

            if (font != null) {
                text += font.toText();
            }

            if (interior != null) {
                text += interior.toText();
            }

            if (numberFormat != null) {
                text += TAG_NUMBER_FORMAT_START;
                text += attribute(ATTRIBUTE_FORMAT, numberFormat);
                text += TAG_FINISH;
            }

            if (isProtected != null || isHideFormula != null) {
                text += TAG_PROTECTION_START;
                text += attribute(ATTRIBUTE_PROTECTED, isProtected);
                text += attribute(ATTRIBUTE_HIDE_FORMULA, isHideFormula);
                text += TAG_FINISH;
            }

            text += TAG_STYLE_END;

            return text;
        }
    }

    public ExcelWorkbook() {
        erase();
    }

    public void erase() {
        properties = new Map<String, String>();
        styles = new Map<String, Style>();
        namedRanges = new Map<String, NamedRange>();
        sheets = new Map<String, Sheet>();
    }

    public String build() {
        String text = '';

        text += toTextWorkbookStart();

        text += toText(properties);
        text += toText(styles);
        text += toText(namedRanges);
        text += toText(sheets);

        text += toTextWorkbookEnd();

        return text;
    }

    public void addDocumentProperty(String attribute, String value) {
        properties.put(attribute, value);
    }

    @SuppressWarnings('PMD.ExcessiveParameterList')
    public void addNamedRange(
        String name,
        String sheet,
        Integer rowFrom,
        Integer columnFrom,
        Integer rowTo,
        Integer columnTo
    ) {
        NamedRange range = new namedRange(name, sheet, rowFrom, columnFrom, rowTo, columnTo);
        namedRanges.put(name, range);
    }

    public Sheet addSheet(String name) {
        Sheet sheet = new Sheet(name);
        sheets.put(name, sheet);
        return sheet;
    }

    public Style addStyle(String styleID) {
        Style style = new Style(styleId);
        styles.put(styleID, style);
        return style;
    }

    @TestVisible
    private String toTextWorkbookStart() {
        return WORKBOOK_START;
    }

    @TestVisible
    private String toTextWorkbookEnd() {
        return WORKBOOK_END;
    }

    @TestVisible
    private String toText(Map<String, String> properties) {
        String text = '';

        if (!properties.isEmpty()) {
            text += TAG_DOCUMENT_PROPERTIES_START;

            List<String> keys = new List<String>(properties.keySet());
            keys.sort();

            for (String key : keys) {
                text += String.format(FORMAT_TAG_SHEET_OPTION, new List<String>{ key, properties.get(key) });
            }

            text += TAG_DOCUMENT_PROPERTIES_END;
        }

        return text;
    }

    @TestVisible
    private String toText(Map<String, NamedRange> ranges) {
        String text = '';

        if (!ranges.isEmpty()) {
            text += TAG_NAMES_START;

            for (NamedRange range : ranges.values()) {
                text += range.toText();
            }

            text += TAG_NAMES_END;
        }

        return text;
    }

    @TestVisible
    private String toText(Map<String, Sheet> sheets) {
        String text = '';

        if (!sheets.isEmpty()) {
            for (Sheet sheet : sheets.values()) {
                sheet.setWorkbookNamedRanges(namedRanges.values());
                text += sheet.toText();
            }
        }

        return text;
    }

    @TestVisible
    private String toText(Map<String, Style> styles) {
        String text = '';

        if (!styles.isEmpty()) {
            text += TAG_STYLES_START;

            for (Style style : styles.values()) {
                text += style.toText();
            }

            text += TAG_STYLES_END;
        }

        return text;
    }
}