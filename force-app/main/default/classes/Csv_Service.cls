/**
 * @description Csv_Service contains utility routines to convert data to and from
 * CSV files.
 *
 * FUTURE METHODS:
 *    createCsvFromMatrix:  Map<Integer, Map<Integer, String>>
 *    createCsvFromSpreadsheet: Map<String, Map<String, String>>
 *    createCsvFromLists: Map<String, List<String>>
 */
public without sharing class Csv_Service {
	/**
	 * @description create creates a single string with the full CSV file
	 * data in it.  Rows are separated by a carriage return (ENTER).
	 * @param  data  The information to process
	 * @return A String with the Csv data in it
	 */
	public static String create(List<List<String>> data) {
		return (new Csv()).create(data);
	}

	/**
	 * @description readreads the given text as a CSV file and returns
	 * the data in a List of Lists.
	 * @param  text Text to parse as CSV data
	 * @return List of Lists
	 */
	public static List<List<String>> read(String text) {
		return (new Csv()).parse(text);
	}

	/**
	 * @description readAsMatrix reads the data as CSV and returns the data
	 * in a Map of Maps.  Indices into the matrix are zero based.
	 * @param  text  Text to parse as CSV data
	 * @return Map<Integer, Map<Integer, String>>
	 */
	public static Map<Integer, Map<Integer, String>> readAsMatrix(String text) {
		Map<Integer, Map<Integer, String>> result = new Map<Integer, Map<Integer, String>>();

		List<List<String>> values = read(text);

		Integer row = 0;
		Integer column = 0;
		Map<Integer, String> rowResult;

		for (List<String> rowValues : values) {
			rowResult = new Map<Integer, String>();
			column = 0;

			for (String value : rowValues) {
				rowResult.put(column, value);
				++column;
			}

			result.put(row, rowResult);
			++row;
		}

		return result;
	}

	/**
	 * @description readAsSpreadsheet reads the data as CSV and returns the data
	 * in a Map of Maps.  First row of the data is expected to be the names of
	 * the column's values and first column is the identifer for the row.
	 * Notes:
	 *     The value in the first column and row is not read.
	 *     Column headers need to be unique
	 *     Trailing values may be lost if column header is missing
	 * @param  text Text to parse as CSV data
	 * @return Row/Column Map of Maps
	 */
	public static Map<String, Map<String, String>> readAsSpreadsheet(String text) {
		Map<String, Map<String, String>> result = new Map<String, Map<String, String>>();

		List<List<String>> values = read(text);

		List<String> columns = values.remove(0);
		Integer numColumns = columns.size();

		String key;
		Integer column;

		for (List<String> row : values) {
			if (row.size() != 0) {
				Map<String, String> rowValues = new Map<String, String>();

				key = row.remove(0);
				column = 1;

				for (String value : row) {
					if (column < numColumns) {
						rowValues.put(columns.get(column), value);
					}

					++column;
				}

				result.put(key, rowValues);
			}
		}

		return result;
	}

	/**
	 * @description readAsLists reads the given text as a CSV file
	 * and returns the data in a Map of Lists.  First column of the CSV
	 * file is the name used as the key of the Map.  The other values
	 * are in order in the List.
	 * @param  text Text to parse as CSV data
	 * @return Map of Lists
	 */
	public static Map<String, List<String>> readAsLists(String text) {
		Map<String, List<String>> result = new Map<String, List<String>>();

		List<List<String>> values = read(text);
		String key;

		for (List<String> row : values) {
			if (row.size() != 0) {
				key = row.remove(0);

				result.put(key, row);
			}
		}

		return result;
	}

	/**
	 * @description Csv implements a CSV parser and creator.
	 */
	@TestVisible
	@SuppressWarnings('PMD.FieldNamingConventions')
	private class Csv {
		private String BLANK = '';
		private String COMMA = ',';
		private String ENTER = '\n';
		private String DOUBLE_QUOTE = '"';
		private String TWO_DOUBLE_QUOTES = '""';

		private Integer intDoubleQuote = DOUBLE_QUOTE.charAt(0);

		// The whole text
		private String text;
		// Current character reading from
		private Integer currTextChar = 0;
		// Current character reading from
		private Integer lengthText = 0;

		// Line of text
		private String textLine;
		// Current character reading from
		private Integer currLineChar = 0;
		// Current character reading from
		private Integer lengthLine = 0;

		/**
		 * @description Csv constructor.
		 */
		@SuppressWarnings('PMD.EmptyStatementBlock')
		public Csv() {
		}

		/**
		 * @description create creates a CSV string from the given data
		 * @param  data Data to use
		 * @return CSV string
		 */
		public String create(List<List<String>> data) {

			String result = BLANK;
			Boolean first;

			for (List<String> row : data) {

				first = true;

				for (String value : row) {
					if (String.isBlank(value)) {
						value = BLANK;
					} else if (value.contains(DOUBLE_QUOTE)) {
						value = DOUBLE_QUOTE + value.Replace(DOUBLE_QUOTE, TWO_DOUBLE_QUOTES) + DOUBLE_QUOTE;
					} else if (value.containsWhitespace() || value.contains(COMMA)) {
						value = DOUBLE_QUOTE + value + DOUBLE_QUOTE;
					}

					if (!first) {
						result += COMMA;
					}

					result += value;
					first = false;
				}

				result += ENTER;
			}

			return result.trim();
		}

		/**
		 * @description parse parses the given CSV text.
		 * @param  text CSV Text to parse
		 * @return List<List<String>>
		 */
		public List<List<String>> parse(String text) {

			List<List<String>> result = new List<List<String>>();

			if (text != null && text.length() > 0) {
				this.text = text;
				this.currTextChar = 0;
				this.lengthText = text.length();

				while (currTextChar < lengthText) {
					result.add(parseLine(readLine()));
				}
			}

			return result;
		}

		/**
		 * @description readLine reads a single line from the text
		 * @return String
		 */
		private String readLine() {
			String line = '';

			String c;
			Integer depthDoubleQuoted = 0;

			while (currTextChar < lengthText) {
				c = getChar(text, currTextChar);
				++currTextChar;

				if (c == DOUBLE_QUOTE) {
					++depthDoubleQuoted;
				} else if (c == ENTER) {
					if (Math.mod(depthDoubleQuoted, 2) == 0) {
						break;
					}
				}

				line = line + c;
			}

			return line.trim();
		}

		/**
		 * @description parseLine separates the line into its values
		 * @param  line  Line of text to separate
		 * @return List<String>
		 */
		public List<String> parseLine(String line) {
			List<String> result = new List<String>();

			this.textLine = line;
			this.currLineChar = 0;
			this.lengthLine = line.length();

			while (this.currLineChar < this.lengthLine) {
				result.add(readValue());
			}

			return result;
		}

		/**
		 * @description readValue reads a single value from the line.
		 * @return String
		 */
		public String readValue() {
			String value = '';

			Integer startsDoubleQuote = 0;
			Integer depthDoubleQuoted = 0;
			String c;

			while (this.currLineChar < this.lengthLine) {
				c = getChar(textLine, currLineChar);
				++currLineChar;

				if (c == DOUBLE_QUOTE) {
					++depthDoubleQuoted;

					if (value.length() == 0) {
						startsDoubleQuote = 1;
					}
				} else if (c == COMMA) {
					if (Math.mod(depthDoubleQuoted, 2) == 0) {
						break;
					}
				}

				value = value + c;
			}

			value = value.trim();

			if (startsDoubleQuote == 1) {
				// Remove outer double quotes
				value = value.substring(1, value.length() - 1);
			}

			return value.Replace(TWO_DOUBLE_QUOTES, DOUBLE_QUOTE);
		}

		private String getChar(String text, Integer pos) {
			if (pos == text.length() - 1) {
				return text.right(1);
			}

			return text.substring(pos, pos + 1);
		}
	}
}