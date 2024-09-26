@IsTest
@SuppressWarnings('PMD.ApexAssertionsShouldIncludeMessage')
public with sharing class Csv_Service_Test {
	private static final String TEST_LINE_EMPTY = '';
	private static final String TEST_LINE_SIMPLE = 'a,2,c,4';
	private static final String TEST_LINE_COMPLEX = '"""a""",2,""",""" ,"4 "';

	private static final String TEST_CSV_STRING = '"""a""",2,"abc",4\n"\nabc"';

	private static final String TEST_CSV_MATRIX =
		'A0, B0, C0, D0, E0\n' +
		'A1, B1, C1, D1, E1\n' +
		'A2, B2, C2, D2, E2\n' +
		'A3, B3, C3, D3, E3';

	private static final String TEST_CSV_CREATED_SIMPLE =
		'A0,B0,C0,D0,E0\n' +
		'A1,B1,C1,D1,E1\n' +
		'A2,B2,C2,D2,E2\n' +
		'A3,B3,C3,D3,E3';
	private static final String TEST_CSV_CREATED_COMPLEX =
		'"A""0"""," B""0",C0\n' +
		'"A1  ",",B1"\n' +
		',B2';
	private static final String TEST_REWIND_2 ='"A""0","B,0",,D0\n"A1  ",B1\nA2';

	@IsTest
	public static void test_Rewind_1() {
		List<List<String>> data = new List<List<String>>();
		data.add(new List<String>{ 'A"0', 'B,0', '', 'D0' });
		data.add(new List<String>{ 'A1  ', 'B1', '' });
		data.add(new List<String>{ 'A2' });

		String text = Csv_Service.create(data);
		data = Csv_Service.read(text);

		Assert.areEqual(3, data.size());

		List<String> row;
		row = data.get(0);
		Assert.areEqual(4, row.size());
		Assert.areEqual('A"0', row.get(0));
		Assert.areEqual('B,0', row.get(1));
		Assert.areEqual('', row.get(2));
		Assert.areEqual('D0', row.get(3));
		row = data.get(1);
		Assert.areEqual(2, row.size());
		Assert.areEqual('A1  ', row.get(0));
		Assert.areEqual('B1', row.get(1));
		row = data.get(2);
		Assert.areEqual(1, row.size());
		Assert.areEqual('A2', row.get(0));
	}

	@IsTest
	public static void test_Rewind_2() {
		List<List<String>> data = Csv_Service.read(TEST_REWIND_2);
		String text = Csv_Service.create(data);
		Assert.areEqual(TEST_REWIND_2, text);
	}

	@IsTest
	public static void test_ParserCsv_readLine() {
		Csv_Service.Csv parser = new Csv_Service.Csv();

		List<String> parsed;

		parsed = parser.parseLine(TEST_LINE_EMPTY);
		Assert.areEqual(0, parsed.size());

		parsed = parser.parseLine(TEST_LINE_SIMPLE);
		Assert.areEqual(4, parsed.size());
		Assert.areEqual('a', parsed.get(0));
		Assert.areEqual('2', parsed.get(1));
		Assert.areEqual('c', parsed.get(2));
		Assert.areEqual('4', parsed.get(3));

		parsed = parser.parseLine(TEST_LINE_COMPLEX);
		Assert.areEqual(4, parsed.size());
		Assert.areEqual('"a"', parsed.get(0));
		Assert.areEqual('2', parsed.get(1));
		Assert.areEqual('","', parsed.get(2));
		Assert.areEqual('4 ', parsed.get(3));
	}

	@IsTest
	public static void test_ParserCsv_parse() {
		Csv_Service.Csv parser = new Csv_Service.Csv();

		List<List<String>> parsed;

		parsed = parser.parse(null);
		Assert.areEqual(0, parsed.size());

		parsed = parser.parse(TEST_CSV_STRING);
		Assert.areEqual(2, parsed.size());

		List<String> line;

		line = parsed.get(0);
		Assert.areEqual(4, line.size());
		Assert.areEqual('"a"', line.get(0));
		Assert.areEqual('2', line.get(1));
		Assert.areEqual('abc', line.get(2));
		Assert.areEqual('4', line.get(3));

		line = parsed.get(1);
		Assert.areEqual(1, line.size());
		Assert.areEqual('\nabc', line.get(0));
	}

	@IsTest
	public static void test_create() {
		String textCsv;

		List<List<String>> data;

		data = new List<List<String>>();
		data.add(new List<String>{ 'A0', 'B0', 'C0', 'D0', 'E0' });
		data.add(new List<String>{ 'A1', 'B1', 'C1', 'D1', 'E1' });
		data.add(new List<String>{ 'A2', 'B2', 'C2', 'D2', 'E2' });
		data.add(new List<String>{ 'A3', 'B3', 'C3', 'D3', 'E3' });

		textCsv = Csv_Service.create(data);

		Assert.areEqual(TEST_CSV_CREATED_SIMPLE, textCsv);

		data = new List<List<String>>();
		data.add(new List<String>{ 'A"0"', ' B"0', 'C0' });
		data.add(new List<String>{ 'A1  ', ',B1' });
		data.add(new List<String>{ '', 'B2' });

		textCsv = Csv_Service.create(data);

		Assert.areEqual(TEST_CSV_CREATED_COMPLEX, textCsv);
	}

	@IsTest
	public static void test_readAsMatrix() {
		Map<Integer, Map<Integer, String>> parsed = Csv_Service.readAsMatrix(TEST_CSV_MATRIX);
		Assert.areEqual(4, parsed.size());

		for (Integer row = 0; row < 4; ++row) {
			Map<Integer, String> columns = parsed.get(row);

			Assert.areEqual(5, columns.size());

			Assert.areEqual('A' + row, columns.get(0));
			Assert.areEqual('B' + row, columns.get(1));
			Assert.areEqual('C' + row, columns.get(2));
			Assert.areEqual('D' + row, columns.get(3));
			Assert.areEqual('E' + row, columns.get(4));
		}
	}

	@IsTest
	public static void test_readAsSpreadsheet() {
		Set<String> keys;

		Map<String, Map<String, String>> parsed = Csv_Service.readAsSpreadsheet(TEST_CSV_MATRIX);
		keys = parsed.keySet();
		Assert.areEqual(3, parsed.size());
		Assert.isTrue(keys.contains('A1'));
		Assert.isTrue(keys.contains('A2'));
		Assert.isTrue(keys.contains('A3'));

		Map<String, String> columns = parsed.get('A1');
		keys = columns.keySet();
		Assert.areEqual(4, keys.size());
		Assert.isTrue(keys.contains('B0'));
		Assert.isTrue(keys.contains('C0'));
		Assert.isTrue(keys.contains('D0'));
		Assert.isTrue(keys.contains('E0'));

		Assert.areEqual('C2', parsed.get('A2').get('C0'));
		Assert.areEqual('B1', parsed.get('A1').get('B0'));
	}

	@IsTest
	public static void test_readAsLists() {
		Set<String> keys;

		Map<String, List<String>> parsed = Csv_Service.readAsLists(TEST_CSV_MATRIX);
		keys = parsed.keySet();
		Assert.areEqual(4, parsed.size());
		Assert.isTrue(keys.contains('A0'));
		Assert.isTrue(keys.contains('A1'));
		Assert.isTrue(keys.contains('A2'));
		Assert.isTrue(keys.contains('A3'));

		List<String> row;

		row = parsed.get('A0');
		Assert.areEqual(4, row.size());
		Assert.areEqual('B0', row.get(0));
		Assert.areEqual('C0', row.get(1));
		Assert.areEqual('D0', row.get(2));
		Assert.areEqual('E0', row.get(3));

		row = parsed.get('A1');
		Assert.areEqual(4, row.size());
		Assert.areEqual('B1', row.get(0));
		Assert.areEqual('C1', row.get(1));
		Assert.areEqual('D1', row.get(2));
		Assert.areEqual('E1', row.get(3));

		row = parsed.get('A2');
		Assert.areEqual(4, row.size());
		Assert.areEqual('B2', row.get(0));
		Assert.areEqual('C2', row.get(1));
		Assert.areEqual('D2', row.get(2));
		Assert.areEqual('E2', row.get(3));

		row = parsed.get('A3');
		Assert.areEqual(4, row.size());
		Assert.areEqual('B3', row.get(0));
		Assert.areEqual('C3', row.get(1));
		Assert.areEqual('D3', row.get(2));
		Assert.areEqual('E3', row.get(3));
	}
}