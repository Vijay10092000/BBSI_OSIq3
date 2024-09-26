/**
 * @description String_Services contains methods to extend the String class.
 */
public without sharing class String_Services {
	private static final Integer MAX_REPLACES = 10;

	/**
	 * @description replaceRepeat calls replace() repeatedly until no changes or hit maxReplace.
	 * @param  base        Starting string
	 * @param  find        Value to find
	 * @param  replace     Value used to replace
	 * @param  maxReplace  Number between 1 and 100 which limits the number of replaces allowed
	 * @return String with replaced values
	 */
	public static String replaceRepeat(String base, String find, String replace, Integer maxReplace) {
		if (maxReplace <= 0 || 100 < maxReplace) {
			throw new IllegalArgumentException(
				'Parameter maxReplace is invalid: ' +
				maxReplace +
				'.  Must be in range 1 to 100 inclusive'
			);
		}

		if (!String.isBlank(base)) {
			String before;
			String after = base;
			Integer count = 0;

			do {
				before = after;
				after = before.replace(find, replace);
				count++;
			} while (!String.isBlank(after) && after != before && count < maxReplace);

			return after;
		}

		return base;
	}

	/**
	 * @description replaceRepeat calls replace repeatedly until no changes or performs MAX_REPLACES times.
	 * @param  base    Starting string
	 * @param  find    find description
	 * @param  replace replace description
	 * @return String with replaced values
	 */
	public static String replaceRepeat(String base, String find, String replace) {
		return replaceRepeat(base, find, replace, MAX_REPLACES);
	}

	/**
	 * @description getDefaultValue test defaultString for null and returns
	 * one of the two Strings based on the result.
	 * @param  defaultString String checking for null
	 * @param  otherString   String returned if defaultString is null
	 * @return The defaultString if not null, otherString if is
	 */
	public static String getDefaultValue(String defaultString, String otherString) {
		String defaultValue;

		if (defaultString != null) {
			defaultValue = defaultString;
		} else {
			defaultValue = otherString;
		}

		return defaultValue;
	}

	/**
	 * @description truncateWithDots reduces the given text to the maxLength with and
	 * ends in "...".
	 * @param  text      Text to check for trucataion
	 * @param  maxLength Length result may be
	 * @return A trucated String
	 */
	public static String truncateWithDots(String text, Integer maxLength) {
		if (maxLength <= 0) {
			throw new IllegalArgumentException('Parameter maxLength is invalid: ' + maxLength);
		}

		if (text == null || text.length() <= maxLength) {
			return text;
		}

		if (maxLength >= 4) {
			return text.substring(0, maxLength - 3) + '...';
		}

		return '...'.substring(0, maxLength);
	}

	/**
	 * @description toString converts List of SObjects to a String
	 * @param  sobjects List of SObjects
	 * @return String
	 */
	public static String toString(List<SObject> sobjects) {
		String result = '';

		if (sobjects != null && !sobjects.isEmpty()) {
			Integer index = 0;

			for (SObject obj : sobjects) {
				result += String.valueOf(index) + ': ' + String.valueOf(obj) + '\n';
				index++;
			}
		}

		return result.trim();
	}

	/**
	 * @description toString converts map of SObjects to a String
	 * @param  mapSObjects Map of SObjects with Id key
	 * @return String
	 */
	public static String toString(Map<Id, SObject> mapSObjects) {
		String result = '';

		if (mapSObjects != null && !mapSObjects.isEmpty()) {
			List<Id> keys = new List<Id>(mapSObjects.keySet());
			keys.sort();

			for (Id key : keys) {
				result += String.valueOf(key) + ' => ' + String.valueOf(mapSObjects.get(key)) + '\n';
			}
		}

		return result.trim();
	}

	/**
	 * @description toString converts map of SObjects to a String
	 * @param  mapSObjects Map of SObjects with String key
	 * @return String
	 */
	public static String toString(Map<String, SObject> mapSObjects) {
		String result = '';

		if (mapSObjects != null && !mapSObjects.isEmpty()) {
			List<String> keys = new List<String>(mapSObjects.keySet());
			keys.sort();

			for (String key : keys) {
				result += key + ' => ' + String.valueOf(mapSObjects.get(key)) + '\n';
			}
		}

		return result.trim();
	}

	/**
	 * @description removeWords description
	 * @param  text         text description
	 * @param  blockedWords blockedWords description
	 * @return Set without the blocked words
	 */
	public static Set<String> removeWords(List<String> words, Set<String> blockedWords) {
		Set<String> result = new Set<String>();

		if (words != null && !words.isEmpty()) {
			if (blockedWords != null && 0 < blockedWords.size()) {
				for (String word : words) {
					if (!blockedWords.contains(word)) {
						result.add(word);
					}
				}
			}
		}

		return result;
	}
}