/**
 * @description ApexInformationController handles file information for Apex
 * classes and triggers.
 */
@SuppressWarnings('PMD.FieldDeclarationsShouldBeAtStart, PMD.ApexDoc')
public without sharing class ApexInformationController {
	public without sharing class ApexInformationWrapper {
		@AuraEnabled
		public Integer totalCharactersUsed { get; private set; }

		@AuraEnabled
		public String textPercentCharactersUsed { get; private set; }

		@AuraEnabled
		public Integer totalLines { get; private set; }

		@AuraEnabled
		public Integer totalLinesCovered { get; private set; }

		@AuraEnabled
		public String textTotalPercentCoverage { get; private set; }

		@AuraEnabled
		public Integer totalClasses { get; private set; }

		@AuraEnabled
		public Integer totalTriggers { get; private set; }

		@AuraEnabled
		public List<ApexInformationController.FileInfo> listAllFiles { get; private set; }
	}

	@SuppressWarnings('PDM.ExcessivePublicCount')
	public with sharing class FileInfo implements Comparable {
		@AuraEnabled
		public String id { get; private set; }

		@AuraEnabled
		public String name { get; private set; }

		@AuraEnabled
		public String namespace { get; private set; }

		@AuraEnabled
		public String link { get; private set; }

		@AuraEnabled
		public String type { get; private set; }

		@AuraEnabled
		public String apiVersion { get; private set; }

		@AuraEnabled
		public Integer lengthWithoutComments { get; private set; }

		@AuraEnabled
		public Integer numberCoveredLines { get; private set; }

		@AuraEnabled
		public Integer numberUncoveredLines { get; private set; }

		@AuraEnabled
		public Integer numberLines { get; private set; }

		@AuraEnabled
		public String textPercentLineCoverage { get; private set; }

		public Integer compareTo(Object compareTo) {
			FileInfo compareFI = (FileInfo) compareTo;

			if (this.Name > compareFI.Name) {
				return 1;
			}
			if (this.Name < compareFI.Name) {
				return -1;
			}
			return 0;
		}
	}

	@TestVisible
	private class Coverage {
		public Id apexClassorTriggerId;
		public Integer numLinesCovered;
		public Integer numLinesUncovered;
	}

	private static final String QUERY_CLASSES = 'SELECT Id, Namespaceprefix, Name, ApiVersion, Status, LengthWithoutComments FROM ApexClass';
	private static final String QUERY_TRIGGERS = 'SELECT Id, Namespaceprefix, Name, ApiVersion, Status, LengthWithoutComments FROM ApexTrigger';
	private static final String QUERY_COVERAGE = 'SELECT ApexClassorTriggerId, NumLinesCovered, NumLinesUncovered FROM ApexCodeCoverageAggregate';

	private static final String FILE_LINK = '/lightning/r/Apex{0}/{1}/view';

	@TestVisible
	private List<ApexClass> listClasses;
	@TestVisible
	private List<ApexTrigger> listTriggers;
	@TestVisible
	private Map<Id, Coverage> mapCoverages;
	@TestVisible
	private Set<Id> setTestClassIds;
	@TestVisible
	private List<FileInfo> listFileInfo;

	/**
	 * getData computes the information about Salesforce Classes and Triggers
	 * and places the information into an ApexInfoWraper.
	 * @return An ApexInfoWrapper
	 */
	@AuraEnabled
	public static ApexInformationWrapper getData() {
		ApexInformationController controller = new ApexInformationController();

		controller.loadFileData();
		controller.processFileData();

		return controller.createWrapper();
	}

	private void loadFileData() {
		loadClasses();
		loadTestClassIds();
		loadTriggers();
		loadCoverages();
	}

	@TestVisible
	private void loadClasses() {
		listClasses = (List<ApexClass>) Database.query(QUERY_CLASSES);
	}

	@TestVisible
	private void loadTestClassIds() {
		setTestClassIds = new Set<Id>();

		List<ApexClass> unitTests = [FIND '@IsTest' IN ALL FIELDS RETURNING ApexClass(Id)][0];

		for (ApexClass ac : unitTests) {
			setTestClassIds.add(ac.Id);
		}
	}

	@TestVisible
	private void loadTriggers() {
		listTriggers = (List<ApexTrigger>) Database.query(QUERY_TRIGGERS);
	}

	@TestVisible
	private void loadCoverages() {
		mapCoverages = new Map<Id, Coverage>();

		HttpResponse response = HttpCallout.queryToolingApi(QUERY_COVERAGE);

		if (response != null && !String.isBlank(response.getBody())) {
			JSONParser parser = JSON.createParser(response.getBody());

			while (parser.nextToken() != null) {
				if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
					while (parser.nextToken() != null) {
						if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
							Coverage coverage = (Coverage) parser.readValueAs(Coverage.class);

							mapCoverages.put(coverage.ApexClassorTriggerId, coverage);

							parser.skipChildren();
						}
					}
				}
			}
		}
	}

	@TestVisible
	private void processFileData() {
		listFileInfo = new List<FileInfo>();
		listFileInfo.addAll(processClasses());
		listFileInfo.addAll(processTriggers());
		listFileInfo.sort();
	}

	@TestVisible
	private List<FileInfo> processClasses() {
		List<FileInfo> results = new List<FileInfo>();

		for (ApexClass ac : listClasses) {
			FileInfo fi = processFile(
				'Class',
				ac.Id,
				ac.Name,
				ac.Namespaceprefix,
				ac.ApiVersion,
				ac.LengthWithoutComments
			);
			if (fi != null) {
				results.add(fi);
			} else {
				System.debug(LoggingLevel.ERROR, 'FAILED: ' + ac.Name);
			}
		}

		return results;
	}

	@TestVisible
	private List<FileInfo> processTriggers() {
		List<FileInfo> results = new List<FileInfo>();

		for (ApexTrigger at : listTriggers) {
			FileInfo fi = processFile(
				'Trigger',
				at.Id,
				at.Name,
				at.Namespaceprefix,
				at.ApiVersion,
				at.LengthWithoutComments
			);
			if (fi != null) {
				results.add(fi);
			} else {
				System.debug(LoggingLevel.ERROR, 'FAILED: ' + at.Name);
			}
		}

		return results;
	}

	@SuppressWarnings('PMD.ExcessiveParameterList')
	private FileInfo processFile(
		String type,
		Id id,
		String name,
		String namespace,
		Decimal apiVersion,
		Integer length
	) {
		FileInfo fi = new FileInfo();

		fi.id = id;
		fi.name = name;
		fi.namespace = (String.isBlank(namespace)) ? '' : namespace;
		fi.link = String.format(FILE_LINK, new List<String>{ type, String.valueOf(id) });
		fi.apiVersion = String.valueOf(apiVersion);
		fi.lengthWithoutComments = (length < 0) ? 0 : length;
		fi.numberCoveredLines = 0;
		fi.numberUncoveredLines = 0;
		fi.numberLines = 0;

		if (mapCoverages != null && mapCoverages.containsKey(id)) {
			Coverage coverage = mapCoverages.get(id);

			fi.numberCoveredLines = coverage.numLinesCovered;
			fi.numberUncoveredLines = coverage.numLinesUncovered;
			fi.numberLines = coverage.numLinesCovered + coverage.numLinesUncovered;
		}

		if (setTestClassIds != null && setTestClassIds.contains(id)) {
            fi.type = 'Test Class';
			fi.textPercentLineCoverage = 'N/A';
		} else {
            if (!String.isBlank(namespace)) {
                fi.type = 'App Class';
                fi.textPercentLineCoverage = 'N/A';
            } else if (0 < fi.numberLines) {
                fi.type = type;
				fi.textPercentLineCoverage = String.valueOf(makePercent(fi.numberCoveredLines, fi.numberLines));
			} else {
                fi.type = type;
				fi.textPercentLineCoverage = '0';
			}
		}

		return fi;
	}

	@TestVisible
	private ApexInformationWrapper createWrapper() {
		Integer numClasses = 0;
		Integer numTriggers = 0;
		Integer totalLines = 0;
		Integer totalLinesCovered = 0;
		Integer totalCharactersUsed = 0;
		Integer totalPercentCoverage = 0;

		for (FileInfo fi : listFileInfo) {
			if (fi == null) {
				System.debug(LoggingLevel.ERROR, 'FAILED!!!');
			}

			if (fi.type == 'Class') {
				++numClasses;
                totalLines += fi.numberLines;
                totalLinesCovered += fi.numberCoveredLines;
				totalCharactersUsed += fi.LengthWithoutComments;
			} else if (fi.type == 'Trigger') {
				++numTriggers;
                totalLines += fi.numberLines;
                totalLinesCovered += fi.numberCoveredLines;
				totalCharactersUsed += fi.LengthWithoutComments;
			}
		}

		if (totalLines > 0) {
			totalPercentCoverage = makePercent(totalLinesCovered, totalLines);
		}

		ApexInformationWrapper wrapper = new ApexInformationWrapper();

		wrapper.listAllFiles = listFileInfo;
		wrapper.totalClasses = numClasses;
		wrapper.totalTriggers = numTriggers;
		wrapper.totalLines = totalLines;
		wrapper.totalLinesCovered = totalLinesCovered;
		wrapper.totalCharactersUsed = totalCharactersUsed;
        wrapper.textPercentCharactersUsed = String.valueOf(makePercent(totalCharactersUsed, 6000000));
		wrapper.textTotalPercentCoverage = String.valueOf(totalPercentCoverage);

		return wrapper;
	}

	@TestVisible
	private Integer makePercent(Integer count, Integer total) {
		return (100 * count) / total;
	}
}