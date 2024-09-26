/**
 * @description BusinessActivityReportSetup holds the data which will be returned
 * to the BusinessActivityReport component.
 */
public without sharing class BusinessActivityReportSetup {
	@TestVisible
	private static final Integer START_YEAR = 2020;
	private static final String ALL_BRANCHES = '0';
	private static final String ALL_BDMS = '0';
	private static final String ALL_RECORDS = '1';


	private User userReportCreator;
	private Boolean isReportManager = false;
	private Boolean isAreaManager = false;
	private Boolean isBdmWork = false;

	/**
	 * @description userName is the name of User running the report
	 */
	@AuraEnabled
	public String userName { get; private set; }

	/**
	 * @description userId is the ID of User running the report
	 */
	@AuraEnabled
	public String userId { get; set; }

	/**
	 * @description year is the current year
	 */
	@AuraEnabled
	public String year { get; private set; }

	/**
	 * @description quarter is the current quarter
	 */
	@AuraEnabled
	public String quarter { get; private set; }

	/**
	 * @description isBDM determines if the working user is a BDM
	 */
	@AuraEnabled
	public Boolean isBDM { get; private set; }

	/**
	 * @description allowSelection determines if the user is allowed to select
	 * from the dropdown.
	 */
	@AuraEnabled
	public Boolean allowSelection { get; private set; }

	/**
	 * @description optionBDMs is the list of users to pick from
	 */
	@AuraEnabled
	public List<Option> optionBDMs { get; private set; }

	/**
	 * @description optionBranches is the list of branches to pick from
	 */
	@AuraEnabled
	public List<Option> optionBranches { get; private set; }

	/**
	 * @description optionAdvBDMs is the list of users to pick from
	 */
	@AuraEnabled
	public List<Option> optionAdvBDMs { get; private set; }

	/**
	 * @description optionBranches is the list of branches to pick from
	 */
	@AuraEnabled
	public List<Option> optionAdvBranches { get; private set; }

	/**
	 * @description allBDMs
	 */
	@AuraEnabled
	public List<String> allBDMs { get; private set; }

	/**
	 * @description allBranches
	 */
	@AuraEnabled
	public List<String> allBranches { get; private set; }

	/**
	 * @description selectedAdvBDMs is the list of users already picked
	 */
	@AuraEnabled
	public List<String> selectedAdvBDMs { get; private set; }

	/**
	 * @description selectedAdvBranches is the list of branches already picked
	 */
	@AuraEnabled
	public List<String> selectedAdvBranches { get; private set; }

	/**
	 * @description optionYears is the list of years to pick from
	 */
	@AuraEnabled
	public List<Option> optionYears { get; private set; }

	/**
	 * @description optionQuarters is the list of quarters to pick from
	 */
	@AuraEnabled
	public List<Option> optionQuarters { get; private set; }

	/**
	 * @description readData reads the setup data.
	 */
	public void readData() {
		try {
			readUserData();
			setDateData();

			if (isReportManager) {
				System.debug(LoggingLevel.INFO, 'IS REPORT MANAGER');
				setReportManagerData();
			} else if (isAreaManager) {
				System.debug(LoggingLevel.INFO, 'IS AREA MANAGER');
				setAreaManagerData();
			} else if (isBdmWork) {
				System.debug(LoggingLevel.INFO, 'IS BMD');
				setBDMData();
			} else {
				System.debug(LoggingLevel.INFO, 'NO ACCESS');
				clearData();
			}
		} catch (Exception e) {			
			System.debug(LoggingLevel.ERROR, 'Exception: ' + e.getMessage() + '\n' + e.getStackTraceString());
		}
	}

	/**
	 * @description setDateData sets the date data for this object
	 */
	private void setDateData() {
		Date today = Date.today();

		this.year = String.valueOf(today.year());
		this.quarter = String.valueOf(1 + ((today.month() - 1) / 3));

		this.optionQuarters = new List<Option>{
			new Option('1', 'Quarter 1', this.quarter == '1'),
			new Option('2', 'Quarter 2', this.quarter == '2'),
			new Option('3', 'Quarter 3', this.quarter == '3'),
			new Option('4', 'Quarter 4', this.quarter == '4'),
			new Option('0', 'All Quarters', false)
		};

		this.optionYears = new List<Option>();
		for (Integer index = START_YEAR; index <= today.year(); ++index) {
			String strYear = String.valueOf(index);
			this.optionYears.add(new Option(strYear, strYear, this.year == strYear));
		}
		System.debug(LoggingLevel.FINE, 'optionYears: ' + optionYears);
	}

	/**
	 * @description setReportManagerData
	 */
	private void setReportManagerData() {
        Option option;
        
		Map<String, String> bdms = getAllBdms();
		Map<String, String> branches = getReportManagerBranches();

		this.userName = userReportCreator.Name;
		this.userId = userReportCreator.Id;
		this.isBDM = false;
		this.allowSelection = true;
		this.allBDMs = new List<String>(bdms.values());
		this.allBDMs.sort();
		this.allBranches = new List<String>(branches.values());
		this.allBranches.sort();
		this.optionBDMs = asBdmOptions(bdms);
		this.optionBranches = asBranchOptions(branches);

        
        option = new Option(ALL_RECORDS, 'All Records', true);
		this.optionAdvBDMs = asBdmOptions(bdms);
		if (this.optionAdvBDMs.isEmpty()) {
			this.optionAdvBDMs.add(option);
		} else {
			this.optionAdvBDMs.add(0, option);
		}

        option = new Option(ALL_BRANCHES, 'All Branches', true);
		this.optionAdvBranches = asBranchOptions(branches);
		if (this.optionAdvBranches.isEmpty()) {
			this.optionAdvBranches.add(option);
		} else {
			this.optionAdvBranches.add(0, option);
		}

		this.selectedAdvBDMs = new List<String>{ ALL_RECORDS };
		this.selectedAdvBranches = new List<String>{ ALL_BRANCHES };
	}

	/**
	 * @description setAreaManagerData
	 */
	private void setAreaManagerData() {
        Option option;
        
		this.userName = userReportCreator.Name;
		this.userId = userReportCreator.Id;

		Map<String, String> bdms = getAmBdms();
		Map<String, String> branches = getAreaManagerBranches();

		this.isBDM = false;
		this.allowSelection = true;
		this.allBDMs = new List<String>(bdms.values());
		this.allBDMs.sort();
		this.allBranches = new List<String>(branches.values());
		this.allBranches.sort();
		this.optionBDMs = asBdmOptions(bdms);
		this.optionBranches = asBranchOptions(branches);

        option = new Option(ALL_RECORDS, 'All Records', true);
		this.optionAdvBDMs = asBdmOptions(bdms);
		if (this.optionAdvBDMs.isEmpty()) {
			this.optionAdvBDMs.add(option);
        } else {
			this.optionAdvBDMs.add(0, option);
        }

        option = new Option(ALL_BRANCHES, 'All Branches', true);
		this.optionAdvBranches = asBranchOptions(branches);
		if (this.optionAdvBranches.isEmpty()) {
			this.optionAdvBranches.add(option);
		} else {
			this.optionAdvBranches.add(0, option);
		}

		this.selectedAdvBDMs = new List<String>{ ALL_RECORDS };
		this.selectedAdvBranches = new List<String>{ ALL_BRANCHES };
	}

	/**
	 * @description setBDMData
	 */
	private void setBDMData() {
		Map<String, String> bdms = new Map<String, Id>{ userReportCreator.Name => userReportCreator.Id };
		Map<String, String> branches = getBDMBranches();

		this.userName = userReportCreator.Name;
		this.userId = userReportCreator.Id;
		this.isBDM = true;
		this.allowSelection = false;
		this.allBDMs = new List<String>(bdms.values());
		this.allBDMs.sort();
		this.allBranches = new List<String>(branches.values());
		this.allBranches.sort();

		this.optionBDMs = asBdmOptions(bdms);
		this.optionBranches = asBranchOptions(branches);
		this.optionAdvBDMs = asBdmOptions(bdms);
		this.optionAdvBranches = asBranchOptions(branches);

		List<String> nameBranches = new List<String>(branches.values());
		nameBranches.sort();

		this.selectedAdvBDMs = new List<String>{ String.valueOf(userReportCreator.Id) };
		this.selectedAdvBranches = nameBranches;
	}

	/**
	 * @description clearData
	 */
	private void clearData() {
		this.userName = '';
		this.userId = '';
		this.isBDM = false;
		this.allowSelection = false;
		this.optionBDMs = new List<Option>();
		this.optionBranches = new List<Option>();
		this.optionAdvBDMs = new List<Option>();
		this.optionAdvBranches = new List<Option>();
	}

	private void readUserData() {
		userReportCreator = [
			SELECT Id, Name, ProfileId, Business_Activity_Report_BDM__c
			FROM User
			WHERE Id = :UserInfo.getUserId()
		];

		Map<Id, Boolean> mapIsReportManager = CustomPermission_Service.checkUserCustomPermission(
			'Business_Activity_Report_Manager',
			new Set<Id>{ userReportCreator.Id }
		);
        
        String textDebug = 'REPORT MANAGERS:';
		for (Id userId : mapIsReportManager.keySet()) {
			textDebug += '  USER ID: ' + userId + '  Manager? ' + mapIsReportManager.get(userId);
		}
        System.debug(LoggingLevel.FINER, textDebug);

		isReportManager = mapIsReportManager.get(userReportCreator.Id);
		isAreaManager = Profile_Service.isAreaManager(userReportCreator.ProfileId);
		isBdmWork = userReportCreator.Business_Activity_Report_BDM__c;
	}

	/**
	 * @description getAllBdms retrieves all the users marked as BDMs.
	 * @return Map of users who are BDMs
	 */
	@TestVisible
	private Map<String, String> getAllBdms() {
		Map<Id, User> relatedBdms = new Map<Id, User>();

		relatedBdms = new Map<Id, User>(
			[
				SELECT Id, Name
				FROM User
				WHERE (Business_Activity_Report_BDM__c = TRUE OR Profile.Name = 'Area Manager') AND IsActive = TRUE
			]
		);

		Map<String, String> result = new Map<String, String>();

		for (User user : relatedBdms.values()) {
			result.put(user.Name, String.valueOf(user.Id));
		}

		return result;
	}

	/**
	 * @description getAmBdms retrieves BDM base on AM or Report Manager and active users only.
	 * @return Map of users who are BDMs
	 */
	private Map<String, String> getAmBdms() {
		Map<String, String> result = new Map<String, String>();

		Map<Id, List<Account>> mapAmToBranches = AccountBranch.getAreaManagerBranches(
			new Set<Id>{ userReportCreator.Id }
		);

		if (mapAmToBranches.containsKey(userReportCreator.Id)) {
			Set<Id> idBranches = new Set<Id>();

			for (Account branch : mapAmToBranches.get(userReportCreator.Id)) {
				idBranches.add(branch.Id);
			}

			Map<Id, User> relatedBdms = AccountBranch.getRelatedBdms(idBranches);
            
			for (User user : relatedBdms.values()) {
				result.put(user.Name, User.Id);
			}
		}

		return result;
	}

	private Map<String, String> getReportManagerBranches() {
		Map<String, String> branches = new Map<String, String>();

		for (Account branch : AccountBranch.getBranches(null)) {
			branches.put(branch.Name, branch.Id);
		}

		return branches;
	}

	private Map<String, String> getAreaManagerBranches() {
		Map<String, String> branches = new Map<String, String>();

		Map<Id, List<Account>> amBranches = AccountBranch.getAreaManagersBranches();

		if (amBranches.containsKey(userId)) {
			for (Account branch : amBranches.get(userId)) {
				branches.put(branch.Name, branch.Id);
			}
		}

		return branches;
	}

	private Map<String, String> getBDMBranches() {
		Map<String, String> branches = new Map<String, Id>();

		List<Account> workBranches = AccountBranch.getBranches(null);

		if (workBranches != null) {
			for (Account branch : workBranches) {
				branches.put(branch.Name, branch.Id);
			}
		}

		return branches;
	}

	private List<Option> asBdmOptions(Map<String, Id> bdms) {
		List<String> names = new List<String>(bdms.keySet());
		names.sort();

		List<Option> listPicks = new List<Option>();

		for (String name : names) {
			listPicks.add(new Option(bdms.get(name), name, false));
		}

		return listPicks;
	}

	private List<Option> asBranchOptions(Map<String, Id> branches) {
		List<String> names = new List<String>(branches.keySet());
		names.sort();

		List<Option> listPicks = new List<Option>();

		for (String name : names) {
			listPicks.add(new Option(branches.get(name), name, false));
		}

		return listPicks;
	}
}