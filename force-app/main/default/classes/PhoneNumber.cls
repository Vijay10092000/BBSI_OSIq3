/**
 * @description PhoneNumber contains routines to work with phone numbers.
 *
 * Check valid format phone number in Validation Rule:
 *			NOT( REGEX( PHONE-FIELD , "^(\\d{3}[- ]?){2}\\d{4}$") )
 */
public without sharing class PhoneNumber {
	// Format for the Phone Number
	private static final String FORMAT_PHONENUMBER = '{1}{0}{2}{0}{3} {4}';

	// Phone number with optional extesion
	private static final String REGEX_PHONENUMBER_EXTENSION = '^(\\d{3})-(\\d{3})-(\\d{4})(\\s.+)?$';

	// Phone number with no extesion
	private static final String REGEX_PHONENUMBER = '^(\\d{3})-(\\d{3})-(\\d{4})$';

	/**
	 * @description isValid determines if the given phone number has the correct format.
	 * @param  phone  Phone number checking
	 * @param  allowExtension  The phone number is allowed to have an extension.
	 * @return true if valid format
	 */
	public static Boolean isValid(String phone, Boolean allowExtension) {
		if (String.isNotBlank(phone)) {
			String testPhone = fixPhoneNumber(phone, allowExtension, true);

			if (allowExtension) {
				return Pattern.matches(REGEX_PHONENUMBER_EXTENSION, testPhone);
			}

			return Pattern.matches(REGEX_PHONENUMBER, testPhone);
		}

		return false;
	}

	/**
	 * @description fixPhoneNumber formats the given phone number.
	 * @param  phone  Phone number correcting
	 * @return String
	 */
	public static String fixPhoneNumber(String phone) {
		return fixPhoneNumber(phone, true, false);
	}

	/**
	 * @description fixPhoneNumber formats the given phone number.
	 * @param  phone  Phone number correcting
	 * @param  allowExtension  The phone number is allowed to have an extension.
	 * @param  blockException  If exception thrown, return original number.
	 * @return String
	 */
	public static String fixPhoneNumber(String phone, Boolean allowExtension, Boolean blockException) {
		try {
			if (!String.isBlank(phone)) {
				return PhoneNumber.formatUS(phone, '-', allowExtension);
			}
		} catch (Exception e) {
			if (!blockException) {
				throw e;
			}
		}

		return phone;
	}

	/**
	 * @description forcePhoneNumber formats the given phone number. If the number
	 * is invalid a null is returned.
	 * @param  phone  Phone number correcting
	 * @param  allowExtension  The phone number is allowed to have an extension.
	 * @return Formatted Phone Number or null if cannot make one
	 */
	@SuppressWarnings('PMD.EmptyCatchBlock')
	public static String forcePhoneNumber(String phone, Boolean allowExtension) {
		try {
			if (!String.isBlank(phone)) {
				return PhoneNumber.formatUS(phone, '-', allowExtension);
			}
		} catch (Exception e) {
			// Ignore exception
		}

		return null;
	}

	/**
	 * @description formatUS formats a US phone number into the 10 digits
	 * followed by an extension.  Basically it grabs the first 10 digits then
	 * remainder is the extension.
	 * Formats to:   ###[divider]###[divider]#### [extension]
	 * There is a potential error if the number is ###-#### ####.  This code
	 * will change this into: ###-###-#### #
	 * @param currPhone The number before update
	 * @param divider  The character(s) to put between the 10 digits, null
	 *                 for no divider
	 * @param allowExtension  The phone number is allowed to have an extension.
	 * @return The formatted number, or internaltional number if not US/CA.
	 * @throws IllegalArgumentException
	 */
	@SuppressWarnings('PMD.CyclomaticComplexity')
	public static String formatUS(String currPhone, String divider, Boolean allowExtension) {
		if (String.isBlank(currPhone)) {
			System.debug(
				LoggingLevel.FINE,
				'PhoneNumber.formatUS(' +
				currPhone +
				', ' +
				divider +
				', ' +
				allowExtension +
				') => "Exception: Invalid Phone number. It is blank or null."'
			);
			throw new IllegalArgumentException('Invalid Phone number. It is blank or null.');
		}

		currPhone = currPhone.replace('.', ' ').replace('/', ' ');

		String tenDigits = '';
		String extension = ' ';

		for (Integer i = 0; i < currPhone.length(); i++) {
			if (tenDigits.length() < 10) {
				String currChar = currPhone.mid(i, 1);

				if (currChar.isNumeric()) {
					if (tenDigits.length() == 0) {
						// Check first number found
						if (currChar == '0') {
							// Leading zero is international, do not change
							return currPhone.trim();
						} else if (currChar == '1') {
							// Skip a leading one
							continue;
						}
					}

					tenDigits += currChar;
				} else if (currChar.isAlpha()) {
					// Found a letter before all 10 numbers
					System.debug(
						LoggingLevel.FINE,
						'PhoneNumber.formatUS(' +
						currPhone +
						', ' +
						divider +
						', ' +
						allowExtension +
						') => "Exception: Invalid Phone number."'
					);
					throw new IllegalArgumentException('Invalid Phone number.');
				}
			} else if (allowExtension) {
				// Anything remaining becomes the extension
				extension = currPhone.right(currPhone.length() - i).trim();

				if (String.IsBlank(extension)) {
					extension = ' ';
				}
				break;
			}
		}

		if (tenDigits.length() < 10) {
			throw new IllegalArgumentException('Invalid Phone number: Not long enough.');
		}

		String newPhone = String.format(
				FORMAT_PHONENUMBER,
				new List<String>{ divider, tenDigits.left(3), tenDigits.mid(3, 3), tenDigits.right(4), extension }
			)
			.trim();

		System.debug(
			LoggingLevel.FINE,
			'PhoneNumber.formatUS(' +
			currPhone +
			', ' +
			divider +
			', ' +
			allowExtension +
			') => ' +
			newPhone
		);
		return newPhone;
	}
}