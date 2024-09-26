/**
 * @description DupeCatcher contains methods to determine if Lead has duplicates.
 */
public without sharing class DupeCatcher {
	private static final Integer QUERY_LIMIT = 5000;

	@TestVisible
	private static Set<String> blockedWords = new Set<String>{
		'the',
		'company',
		'are',
		'of',
		'and',
		'&',
		'inc.',
		'inc',
		'incorporated',
		'llc',
		'insurance'
	};

	@TestVisible
	private Integer minimumDistance = -1;
	@TestVisible
	private Integer maximumDistance = -1;
	@TestVisible
	private Set<String> accountRecordTypes = new Set<String>();
	@TestVisible
	private Set<String> leadRecordTypes = new Set<String>();

	@TestVisible
	private Lead workingLead;

	@TestVisible
	private Set<String> searchItems;

	/**
	 * @description leadConversion updates the Lead Duplicate Log.
	 * Called from Lead_UpdateTriggers
	 * @param  leads  List of Leads to check
	 */
	public static void leadConversion(List<Lead> leads) {
		Map<Id, Id> convertedLeads = new Map<Id, Id>();

		for (Lead l : leads) {
			if (l.isConverted) {
				convertedLeads.put(l.Id, l.convertedOpportunityId);
			}
		}

		if (!convertedLeads.isEmpty()) {
			List<Lead_Duplicate_Log__c> updatedLogs = new List<Lead_Duplicate_Log__c>();

			for (Lead_Duplicate_Log__c dup : [
				SELECT Opportunity__c, Lead__c
				FROM Lead_Duplicate_Log__c
				WHERE lead__c IN :convertedLeads.keySet()
			]) {
				dup.Opportunity__c = convertedLeads.get(dup.Lead__c);
				updatedLogs.add(dup);
			}

			if (updatedLogs.size() > 0) {
				try {
					update updatedLogs;
				} catch (DmlException e) {
					System.debug(LoggingLevel.ERROR, e);
				}
			}
		}
	}

	/**
	 * @description buildArchive
	 * @param  allMatches  allMatches description
	 * @param  dupeMatches dupeMatches description
	 */
	public static void buildArchive(Map<Id, possibleMatches> allMatches, List<Match__c> dupeMatches) {
		allMatches = new Map<Id, possibleMatches>();
		possibleMatches pm;

		for (Match__c m : dupeMatches) {
			pm = new possibleMatches();

			pm.Branch = m.Branch__r;
			pm.Owner = (User) m.Owner__r;
			pm.Name = m.Name;
			pm.Company = m.Company__c;
			pm.FEIN = m.FEIN__c;
			pm.Street = m.Street__c;
			pm.RecordID = m.Record_ID__c;
			pm.CreatedDate = m.Created_Date__c;
			pm.DBAName = m.DBA_Name__c;
			pm.recordID = m.Record_ID__c;
			pm.FEINMatch = m.FEINMatch__c;
			pm.DBAMatch = m.DBAMatch__c;
			pm.CompanyMatch = m.CompanyMatch__c;
			pm.NameMatch = m.NameMatch__c;

			allMatches.put(pm.RecordId, pm);
		}
	}

	/**
	 * @description DupeCatcher constructor reads initial settings.
	 */
	public DupeCatcher() {
		getSettings();
	}

	/**
	 * @description populateMatches finds possible matches related to the given Lead.
	 * @param  dupeLead  Lead looking for
	 * @return Map of matches.
	 */
	public Map<Id, possibleMatches> populateMatches(Lead dupeLead) {
		workingLead = dupeLead;

		getSearchItems();

		if (!searchItems.isEmpty()) {
			Map<Id, possibleMatches> matches = new Map<Id, possibleMatches>();

			List<Account> accounts = searchAccounts(searchItems, dupeLead);
			matches = reduceMatches(accounts, matches, dupeLead);

			List<Lead> leads = searchLeads(searchItems, dupeLead);
			matches = reduceMatches(leads, matches, dupeLead);

			return matches;
		}

		return null;
	}

	/**
	 * @description removeBlockedWords removes the values that are excluded from searches.
	 * @param text  Text removing blocked words from
	 * @return String with blocked words removed.
	 */
	public String removeBlockedWords(String text) {
		if (String.isNotBlank(text)) {
			String updatedText = text.trim();

			for (String value : (list<String>) text.split(' ')) {
				if (blockedWords.Contains(value.toLowerCase())) {
					updatedText = updatedText.remove(value);
				}
			}

			return updatedText;
		}

		return text;
	}

	private List<Account> searchAccounts(Set<String> searchItems, Lead lead) {
		List<Account> results = new List<Account>();

		if (!searchItems.isEmpty()) {
			results = [
				SELECT
					Id,
					DBA_Name__c,
					Name,
					Owner.FirstName,
					Owner.LastName,
					Owner.Name,
					Owner.Id,
					CreatedDate,
					FEIN__c,
					Phone,
					RecordType.Name,
					Prospect_Branch__r.Id,
					Prospect_Branch__r.Name,
					BillingStreet
				FROM Account
				WHERE
					RecordType.Name IN :accountRecordTypes
					AND (Name LIKE :searchItems
					OR DBA_Name__c LIKE :searchItems
					OR (FEIN__c != NULL
					AND FEIN__c = :lead.FEIN__c))
				LIMIT :QUERY_LIMIT
			];
		}

		return results;
	}

	private List<Lead> searchLeads(Set<String> searchItems, Lead lead) {
		List<Lead> results = new List<Lead>();

		if (!searchItems.isEmpty()) {
			results = [
				SELECT
					Id,
					Name,
					DBA_Name__c,
					Company,
					Street,
					Owner.FirstName,
					Owner.LastName,
					Owner.Name,
					Owner.Id,
					CreatedDate,
					FEIN__c,
					Phone,
					RecordType.Name,
					Branch__r.Name
				FROM Lead
				WHERE
					RecordType.Name IN :leadRecordTypes
					AND IsConverted = FALSE
					AND Id != :lead.Id
					AND (DBA_Name__c LIKE :searchItems
					OR Company LIKE :searchItems
					OR (FEIN__c != NULL
					AND FEIN__c = :lead.FEIN__c))
				LIMIT :QUERY_LIMIT
			];
		}

		return results;
	}

	private Map<Id, possibleMatches> reduceMatches(
		List<sObject> objectMatches,
		Map<Id, possibleMatches> currentMatches,
		Lead dupeLead
	) {
		if (objectMatches == null || objectMatches.isEmpty()) {
			return currentMatches;
		}

		String objectType = objectMatches.get(0).getSobjectType().getdescribe().getname();
		Boolean isAccount = (objectType == 'Account');

		Map<Id, Decimal> lowestDistance = new Map<Id, Decimal>();

		for (sObject obj : objectMatches) {
			Id idRecord = (Id) obj.get('id');

			/* DEBUG
			if (isAccount) {
				System.debug(
					LoggingLevel.DEBUG,
					'ACCOUNT MATCH ' +
					'Name: ' + obj.get('Name') +
					'FEIN: ' + obj.get('FEIN__c')  +
					'DBAName: ' + obj.get('DBA_Name__c')
				);
			} else {
				System.debug(
					LoggingLevel.DEBUG,
					'LEAD MATCH ' +
					'Company: ' + obj.get('Company')  +
					'FEIN: ' + obj.get('FEIN__c')  +
					'DBAName: ' + obj.get('DBA_Name__c')
				);
			}
			*/

			Decimal distance = -1;
			String reducedCompany = removeBlockedWords(DupeLead.Company);

			// Give FEIN exact matches higher weight than other matches
			if (String.isNotBlank(dupelead.FEIN__c) && obj.get('FEIN__c') == dupeLead.FEIN__c) {
				currentMatches.put(idRecord, populateDupes(obj, 'FEIN', 0));
				lowestDistance.put(idRecord, 0);
			}

			if (dupeLead.DBA_Name__c != null) {
				if (obj.get('DBA_Name__c') != null) {
					String dbaName = removeBlockedWords((String) obj.get('DBA_Name__c'));

					distance = getLevenshteinValue(dupeLead.DBA_Name__c, dbaName);

					if (minimumDistance <= distance && distance <= maximumDistance) {
						if (currentMatches.ContainsKey(idRecord)) {
							currentMatches.get(idRecord).DBAMatch = true;
						} else {
							currentMatches.put(idRecord, populateDupes(obj, 'DBA', distance));
							lowestDistance.put(idRecord, distance);
						}
					}
				}

				//dba to name on account / company on lead
				distance = -1;

				if (isAccount) {
					String accountName = removeBlockedWords((String) obj.get('Name'));

					distance = getLevenshteinValue(DupeLead.DBA_Name__c, accountName);
				} else {
					String companyName = removeBlockedWords((String) obj.get('Company'));

					distance = getLevenshteinValue(DupeLead.DBA_Name__c, companyName);
				}

				if (minimumDistance <= distance && distance <= maximumDistance) {
					if (currentMatches.ContainsKey(idRecord)) {
						currentMatches.get(idRecord).CompanyMatch = true;

						if (lowestDistance.get(idRecord) > distance) {
							lowestDistance.put(idRecord, distance);
						}
					} else {
						currentMatches.put(idRecord, populateDupes(obj, 'COMPANY', distance));
						lowestDistance.put(idRecord, distance);
					}
				}
			}

			//company to name on account / company on lead
			if (String.isNotBlank(reducedCompany)) {
				distance = -1;

				if (isAccount) {
					String accountName = removeBlockedWords((String) obj.get('Name'));

					distance = getLevenshteinValue(reducedCompany, accountName);
				} else {
					String companyName = removeBlockedWords((String) obj.get('Company'));

					distance = getLevenshteinValue(reducedCompany, companyName);
				}

				if (minimumDistance <= distance && distance <= maximumDistance) {
					if (currentMatches.ContainsKey(idRecord)) {
						currentMatches.get(idRecord).CompanyMatch = true;

						if (lowestDistance.get(idRecord) > distance) {
							lowestDistance.put(idRecord, distance);
						}
					} else {
						currentMatches.put(idRecord, populateDupes(obj, 'COMPANY', distance));

						lowestDistance.put(idRecord, distance);
					}
				}
			}

			//company to dba on account / dba on lead
			if (String.isNotBlank(reducedCompany)) {
				distance = -1;

				if (isAccount) {
					String accountDBA = removeBlockedWords((String) obj.get('DBA_Name__c'));

					distance = getLevenshteinValue(reducedCompany, accountDBA);
				} else {
					String leadDBA = removeBlockedWords((String) obj.get('DBA_Name__c'));

					distance = getLevenshteinValue(reducedCompany, leadDBA);
				}

				if (minimumDistance <= distance && distance <= maximumDistance) {
					if (currentMatches.ContainsKey(idRecord)) {
						currentMatches.get(idRecord).CompanyMatch = true;
						if (lowestDistance.get(idRecord) > distance) {
							lowestDistance.put(idRecord, distance);
						}
					} else {
						currentMatches.put(idRecord, populateDupes(obj, 'COMPANY', distance));
						lowestDistance.put(idRecord, distance);
					}
				}
			}
		}

		return currentMatches;
	}

	private void getSettings() {
		// Get custom metadata information for checking duplicates
		Duplicate_Checking__mdt[] settings = [
			SELECT
				MasterLabel,
				DeveloperName,
				Maximum_Levenshtein_Distance__c,
				Minimum_Levenshtein_Distance__c,
				Stopwords__c,
				Account_Record_Types__c,
				Lead_Record_Types__c
			FROM Duplicate_Checking__mdt
		];

		if (settings != null && settings.size() == 1) {
			if (settings[0].Minimum_Levenshtein_Distance__c != null) {
				minimumDistance = settings[0].Minimum_Levenshtein_Distance__c.intValue();
			}

			if (settings[0].Maximum_Levenshtein_Distance__c != null) {
				maximumDistance = settings[0].Maximum_Levenshtein_Distance__c.intValue();
			}

			if (minimumDistance < 0) {
				minimumDistance = 0;
			}

			if (10 < maximumDistance) {
				maximumDistance = 10;
			}

			if (maximumDistance < minimumDistance) {
				Integer swap = minimumDistance;
				minimumDistance = maximumDistance;
				maximumDistance = swap;
			}

			if (String.isNotBlank(settings[0].Stopwords__c)) {
				List<String> stopwords = settings[0].Stopwords__c.split(',');
				blockedWords = new Set<String>();

				for (String stopword : stopwords) {
					blockedWords.add(stopword);
				}
			}

			if (String.isNotBlank(settings[0].Account_Record_Types__c)) {
				List<String> recordTypes = settings[0].Account_Record_Types__c.split(',');

				for (String recordType : recordTypes) {
					accountRecordTypes.add(recordType);
				}
			}

			if (String.isNotBlank(settings[0].Lead_Record_Types__c)) {
				List<String> recordTypes = settings[0].Lead_Record_Types__c.split(',');

				for (String recordType : recordTypes) {
					leadRecordTypes.add(recordType);
				}
			}
		}
	}

	/**
	 * @description getLevenshteinValue determines how close two strings are using the Levenshtein value.
	 * @param  first   First string
	 * @param  second  Second string
	 * @return The Levenshtein value
	 */
	public Decimal getLevenshteinValue(String first, String second) {
		if (String.isBlank(first) || String.isBlank(second)) {
			return -1;
		}

		first = first.toLowerCase();
		second = second.toLowerCase();

		if (first.length() < second.length()) {
			return second.getLevenshteinDistance(first);
		}

		return first.getLevenshteinDistance(second);
	}

	/**
	 * @description getSearchItems detemines the words to search.
	 */
	public void getSearchItems() {
		searchItems = new Set<String>();

		for (String company : (list<String>) workingLead.Company.split(' ')) {
			company = company.trim();
			if (String.isNotBlank(company)) {
				if (!blockedWords.contains(company.toLowerCase())) {
					searchItems.add('%' + company + '%');
				}
			}
		}

		for (String name : (list<String>) workingLead.Name.split(' ')) {
			name = name.trim();
			if (String.isNotBlank(name)) {
				if (!blockedWords.contains(name.toLowerCase())) {
					searchItems.add(name);
				}
			}
		}

		if (workingLead.DBA_Name__c != null && workingLead.DBA_Name__c != '') {
			for (String nameDba : (list<String>) workingLead.DBA_Name__c.split(' ')) {
				nameDba = nameDba.trim();
				if (String.isNotBlank(nameDba)) {
					if (!blockedWords.contains(nameDba.toLowerCase())) {
						searchItems.add('%' + nameDba + '%');
					}
				}
			}
		}

		String log = 'DupeCatcher.getSearchItems(): ALL FOUND SEARCH ITEMS:';
		for (String s : searchItems) {
			log += '\n- ' + s;
		}
		System.debug(LoggingLevel.FINE, log);
	}

	/**
	 * @description populateDupes builds a possibleMatches from the given parameters
	 * @param  o         Lead or Account looking at
	 * @param  matchType Field Matching
	 * @param  distance  How different the match is
	 * @return A possibleMatches
	 */
	public possibleMatches populateDupes(sObject o, String matchType, Decimal distance) {
		String objectTypeName = o.getSobjectType().getdescribe().getname();

		possibleMatches m = new possibleMatches();

		m.SmallestDistance = distance;
		m.recordId = (ID) o.get('Id');

		m.OwnerId = (String) o.get('OwnerID');
		m.OwnerName = o.getsObject('Owner') != null ? (String) o.getsObject('Owner').get('Name') : '';
		m.owner.ID = (ID) o.get('OwnerID');
		m.owner.FirstName = o.getsObject('Owner') != null ? (String) o.getsObject('Owner').get('FirstName') : '';
		m.owner.LastName = o.getsObject('Owner') != null ? (String) o.getsObject('Owner').get('LastName') : '';

		m.DBAName = (String) o.get('DBA_Name__c');
		m.phone = (String) o.get('Phone');
		m.matchType = matchType;
		m.RecordType = (String) o.getSObject('RecordType').get('Name');
		m.createdDate = (DateTime) o.get('createdDate');
		m.FEIN = (String) o.get('FEIN__c');

		if (objectTypeName == 'Account') {
			m.Company = (String) o.get('Name');
			m.CompanyId = (String) o.get('Id');
			m.branch = o.getSObject('Prospect_Branch__r') != null ? (Account) o.getSObject('Prospect_Branch__r') : null;
			m.branchName = o.getSObject('Prospect_Branch__r') != null ? (String) o.getSObject('Prospect_Branch__r').get('Name') : null;
			m.branchId = o.getSObject('Prospect_Branch__r') != null ? (String) o.getSObject('Prospect_Branch__r').get('Id') : null;
			m.Street = (String) (o.get('BillingStreet'));
		} else if (objectTypeName == 'Lead') {
			m.Name = (String) o.get('Name');
			m.company = (String) o.get('Company');
			m.branch = o.getSObject('Branch__r') != null ? (Account) o.getSObject('Branch__r') : null;
			m.branchName = o.getSObject('Branch__r') != null ? (String) o.getSObject('Branch__r').get('Name') : null;
			m.branchId = o.getSObject('Branch__r') != null ? (String) o.getSObject('Branch__r').get('Id') : null;
			m.Street = (String) o.get('Street');
		}

		if (matchType == 'FEIN') {
			m.FEINMatch = true;
		}

		if (matchType == 'COMPANY') {
			m.CompanyMatch = true;
		}

		if (matchType == 'DBA') {
			m.DBAMatch = true;
		}

		if (MatchType == 'NAME') {
			m.NameMatch = true;
		}

		return m;
	}
}