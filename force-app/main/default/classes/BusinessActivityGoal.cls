/**
 * @description BusinessActivityGoal has methods to handle the Business Activity Goal object.
 *
 */
public without sharing class BusinessActivityGoal {
	/**
	 * @description checkValues confirms all computational fields of a goal have a value.
	 * @param  oldGoals  Map of the current goals
	 * @param  newGoals  List of the new goals
	 */
	public static void checkValues(
		Map<Id, Business_Activity_Goal__c> oldGoals,
		List<Business_Activity_Goal__c> newGoals
	) {
		for (Business_Activity_Goal__c goal : newGoals) {
			fixGoal(goal);
		}
	}
	/**
	 * @description checkDuplicates compare the new goals with the old goals and
	 * block adding duplicates.
	 * @param  oldGoals  Map of the current goals
	 * @param  newGoals  List of the new goals
	 */
	public static void fixBranch(
		Map<Id, Business_Activity_Goal__c> oldGoals,
		List<Business_Activity_Goal__c> newGoals
	) {
		Id idrtGoalBDM = RecordTypeService.getId('Business_Activity_Goal__c', 'BDM Goal');

		for (Business_Activity_Goal__c goal : newGoals) {
			if (goal.RecordTypeId == idrtGoalBDM) {
				goal.Branch__c = null;
			}
		}
	}

	/**
	 * @description checkDuplicates compare the new goals with the old goals and
	 * block adding duplicates.
	 * @param  oldGoals  Map of the current goals
	 * @param  newGoals  List of the new goals
	 */
	public static void checkDuplicates(
			Map<Id, Business_Activity_Goal__c> oldGoals,
			List<Business_Activity_Goal__c> newGoals
		) {
		List<String> years = new List<String>();

		for (Business_Activity_Goal__c newGoal : newGoals) {
			years.add(String.valueOf(newGoal.Start_Year__c));
		}

		List<Business_Activity_Goal__c> compareGoals = [
			SELECT Id, RecordTypeId, Branch__c, Start_Year__c, Start_Quarter__c, Override__c
			FROM Business_Activity_Goal__c
			WHERE Start_Year__c IN :years
			ORDER BY Start_Year__c DESC, Start_Quarter__c DESC
		];

		for (Business_Activity_Goal__c newGoal : newGoals) {
			for (Business_Activity_Goal__c compareGoal : compareGoals) {
				if (
					compareGoal.Id != newGoal.Id &&
					compareGoal.RecordTypeId == newGoal.RecordTypeId &&
					compareGoal.Start_Year__c == newGoal.Start_Year__c &&
					compareGoal.Start_Quarter__c == newGoal.Start_Quarter__c &&
					compareGoal.Branch__c == newGoal.Branch__c &&
					compareGoal.Override__c == newGoal.Override__c
				) {
					newGoal.addError('Adding duplicate goal for ' + newGoal.Start_Year_Quarter__c);
				}

				if (Integer.valueOf(compareGoal.Start_Year__c) < Integer.valueOf(newGoal.Start_Year__c)) {
					break;
				}
			}
		}
	}

	/**
	 * @description getBaseYearGoals retrieves BDM goals for the year
	 * @param  year year description
	 * @return List of goals
	 */
	private static List<Business_Activity_Goal__c> getBaseYearGoals(Integer year) {
		String checkYear = String.valueOf(year);

		List<Business_Activity_Goal__c> goals = [
			SELECT
				Id,
				Name,
				Discovery_Meetings__c,
				Events__c,
				Lost_Clients_Contacted__c,
				Lost_Leads_Contacted__c,
				New_Clients__c,
				New_Leads__c,
				New_Referral_Partners_Contacted__c,
				Producer_Tracks_Info_Sessions__c,
				Referral_Partner_Plans_In_Place__c,
				Referral_Partner_Touches__c,
				RP_Touches_In_Person__c,
				RP_Touches_Virtual__c,
				Start_Quarter__c,
				Start_Year__c,
				Start_Year_Quarter__c,
				WSE_Added__c
			FROM Business_Activity_Goal__c
			WHERE RecordType.Name = 'BDM Goal' AND Start_Year__c <= :checkYear AND Override__c = FALSE
			ORDER BY Start_Year__c DESC, Start_Quarter__c DESC
			LIMIT 5
		];

		for (Business_Activity_Goal__c goal : goals) {
			fixGoal(goal);
		}

		return goals;
	}

	/**
	 * @description getGoalFor description
	 * @param  allRecords   All Records selected
	 * @param  idBDMs      idBDMs description
	 * @param  idBranches  idBranches description
	 * @param  year        year description
	 * @param  quarter     quarter description
	 * @return Summary Business_Activity_Goal__c
	 */
	@SuppressWarnings('PMD.ExcessiveParameterList, PMD.AvoidSystemDebugUsage')
	public static Business_Activity_Goal__c getGoalFor(
		Boolean allRecords,
		Set<Id> idBDMs,
		Set<Id> idBranches,
		Integer year,
		Integer quarter
	) {
		System.debug(
			LoggingLevel.DEBUG,
			'BusinessActivityGoal.getGoalFor' +
			'\n year: ' + year +
			'\n quarter: ' + quarter +
			'\n allRecords: ' + allRecords +
			'\n Number BDMS: ' + idBDMs.size() +
			'\n Number Branches: ' + idBranches.size()
		);

		Business_Activity_Goal__c result = createEmptyGoal();

		if (allRecords) {
			// For All Records + All Branches: The latest default goals for each branch should be added together
			// All Records + Branch:  For All BDMs/One Branch: The defaults for that branch should be used
			// All Records + Branches:  For All BDMs/One Branch: sum default for all given branches

			Map<Id, List<Business_Activity_Goal__c>> goals = getAllBranchGoals(year);

			for (Id idBranch : goals.keySet()) {
				Business_Activity_Goal__c goalToAdd = createEmptyGoal();

				if (idBranches.contains(idBranch)) {
					List<Business_Activity_Goal__c> branchGoals = goals.get(idBranch);

					if (quarter == 0) {
						goalToAdd = branchGoals.get(0);
					} else {
						for (Business_Activity_Goal__c goal : branchGoals) {
							if (Integer.valueOf(goal.Start_Year__c) == year) {
								if (Integer.valueOf(goal.Start_Quarter__c.right(1)) <= quarter) {
									goalToAdd = goal;
									break;
								}
							} else {
								goalToAdd = goal;
								break;
							}
						}
					}
				}
				result = addGoals(result, goalToAdd);
			}
		} else {
			// Single BDM: For the first three scenarios (any with one BDM selected), The BDM default rates should pull
			// Multiple BDMs: For the second set of three (any with two BDMs), it would be 2x the BDM defaults
			result = multiplyGoal(getBDMGoalFor(year, quarter), idBDMs.size());
		}

		if (quarter == 0) {
			result = multiplyGoal(result, 4);
		}

		return result;
	}

	/**
	 * @description getBDMGoalFor retrieves the related Business_Activity_Goal__c
	 * for the given year and quarter.
	 * @param  year    Year checking
	 * @param  quarter Quarter checking
	 * @return A Business_Activity_Goal__c or null if not found
	 */
	@TestVisible
	private static Business_Activity_Goal__c getBDMGoalFor(Integer year, Integer quarter) {
		if (quarter == 0) {
			quarter = 4;
		}

		List<Business_Activity_Goal__c> goals = getBaseYearGoals(year);

		for (Business_Activity_Goal__c goal : goals) {
			if (Integer.valueOf(goal.Start_Year__c) == year) {
				if (Integer.valueOf(goal.Start_Quarter__c.right(1)) <= quarter) {
					return goal;
				}
			} else {
				return goal;
			}
		}

		return createEmptyGoal();
	}

	/**
	 * @description getAllBranchGoals retrieves all goals related to branches
	 * @param  year  Maximum year
	 * @return
	 */
	@TestVisible
	private static Map<Id, List<Business_Activity_Goal__c>> getAllBranchGoals(Integer year) {
		Map<Id, List<Business_Activity_Goal__c>> result = new Map<Id, List<Business_Activity_Goal__c>>();
		String checkYear = String.valueOf(year);

		List<Business_Activity_Goal__c> goals = [
			SELECT
				Id,
				RecordTypeId,
				Branch__c,
				Branch__r.Name,
				Name,
				Discovery_Meetings__c,
				Events__c,
				Lost_Clients_Contacted__c,
				Lost_Leads_Contacted__c,
				New_Clients__c,
				New_Leads__c,
				New_Referral_Partners_Contacted__c,
				Producer_Tracks_Info_Sessions__c,
				Referral_Partner_Plans_In_Place__c,
				Referral_Partner_Touches__c,
				RP_Touches_In_Person__c,
				RP_Touches_Virtual__c,
				Start_Quarter__c,
				Start_Year__c,
				Start_Year_Quarter__c,
				WSE_Added__c
			FROM Business_Activity_Goal__c
			WHERE RecordType.Name = 'Branch Goal' AND Start_Year__c <= :checkYear
			ORDER BY Start_Year__c DESC, Start_Quarter__c DESC
		];

		for (Business_Activity_Goal__c goal : goals) {
			fixGoal(goal);

			if (!result.containsKey(goal.Branch__c)) {
				result.put(goal.Branch__c, new List<Business_Activity_Goal__c>());
			}

			result.get(goal.Branch__c).add(goal);
		}

		return result;
	}

	@TestVisible
	private static Business_Activity_Goal__c addGoals(
		Business_Activity_Goal__c goal1,
		Business_Activity_Goal__c goal2
	) {
		return new Business_Activity_Goal__c(
			Discovery_Meetings__c = goal1.Discovery_Meetings__c + goal2.Discovery_Meetings__c,
			Events__c = goal1.Events__c + goal2.Events__c,
			Lost_Clients_Contacted__c = goal1.Lost_Clients_Contacted__c + goal2.Lost_Clients_Contacted__c,
			Lost_Leads_Contacted__c = goal1.Lost_Leads_Contacted__c + goal2.Lost_Leads_Contacted__c,
			New_Clients__c = goal1.New_Clients__c + goal2.New_Clients__c,
			New_Leads__c = goal1.New_Leads__c + goal2.New_Leads__c,
			New_Referral_Partners_Contacted__c = goal1.New_Referral_Partners_Contacted__c +
				goal2.New_Referral_Partners_Contacted__c,
			Producer_Tracks_Info_Sessions__c = goal1.Producer_Tracks_Info_Sessions__c +
				goal2.Producer_Tracks_Info_Sessions__c,
			Referral_Partner_Plans_In_Place__c = goal1.Referral_Partner_Plans_In_Place__c +
					goal2.Referral_Partner_Plans_In_Place__c,
			Referral_Partner_Touches__c = goal1.Referral_Partner_Touches__c +
						goal2.Referral_Partner_Touches__c,
			RP_Touches_In_Person__c = goal1.RP_Touches_In_Person__c + goal2.RP_Touches_In_Person__c,
			RP_Touches_Virtual__c = goal1.RP_Touches_Virtual__c + goal2.RP_Touches_Virtual__c,
			WSE_Added__c = goal1.WSE_Added__c + goal2.WSE_Added__c
		);
	}

	@TestVisible
	private static Business_Activity_Goal__c multiplyGoal(Business_Activity_Goal__c goal1, Integer multiplier) {
		return new Business_Activity_Goal__c(
			Discovery_Meetings__c = goal1.Discovery_Meetings__c * multiplier,
			Events__c = goal1.Events__c * multiplier,
			Lost_Clients_Contacted__c = goal1.Lost_Clients_Contacted__c * multiplier,
			Lost_Leads_Contacted__c = goal1.Lost_Leads_Contacted__c * multiplier,
			New_Clients__c = goal1.New_Clients__c * multiplier,
			New_Leads__c = goal1.New_Leads__c * multiplier,
			New_Referral_Partners_Contacted__c = goal1.New_Referral_Partners_Contacted__c * multiplier,
			Producer_Tracks_Info_Sessions__c = goal1.Producer_Tracks_Info_Sessions__c * multiplier,
			Referral_Partner_Plans_In_Place__c = goal1.Referral_Partner_Plans_In_Place__c * multiplier,
			Referral_Partner_Touches__c = goal1.Referral_Partner_Touches__c * multiplier,
			RP_Touches_In_Person__c = goal1.RP_Touches_In_Person__c * multiplier,
			RP_Touches_Virtual__c = goal1.RP_Touches_Virtual__c * multiplier,
			WSE_Added__c = goal1.WSE_Added__c * multiplier
		);
	}

	@TestVisible
	private static Business_Activity_Goal__c sumGoals(List<Business_Activity_Goal__c> goals) {
		Business_Activity_Goal__c result = createEmptyGoal();

		for (Business_Activity_Goal__c goal : goals) {
			result = addGoals(result, goal);
		}

		return result;
	}

	@TestVisible
	private static Business_Activity_Goal__c createEmptyGoal() {
		return new Business_Activity_Goal__c(
			Discovery_Meetings__c = 0,
			Events__c = 0,
			Lost_Clients_Contacted__c = 0,
			Lost_Leads_Contacted__c = 0,
			New_Clients__c = 0,
			New_Leads__c = 0,
			New_Referral_Partners_Contacted__c = 0,
			Producer_Tracks_Info_Sessions__c = 0,
			Referral_Partner_Plans_In_Place__c = 0,
			Referral_Partner_Touches__c = 0,
			RP_Touches_In_Person__c = 0,
			RP_Touches_Virtual__c = 0,
			WSE_Added__c = 0
		);
	}

	/**
	 * @description fixGoal set null values to zero.
	 * @param  goal Business_Activity_Goal__c to update
	 */
	private static void fixGoal(Business_Activity_Goal__c goal) {
		goal.Discovery_Meetings__c = DataType_Utility.onNull(goal.Discovery_Meetings__c, 0);
		goal.Events__c = DataType_Utility.onNull(goal.Events__c, 0);
		goal.Lost_Clients_Contacted__c = DataType_Utility.onNull(goal.Lost_Clients_Contacted__c, 0);
		goal.Lost_Leads_Contacted__c = DataType_Utility.onNull(goal.Lost_Leads_Contacted__c, 0);
		goal.New_Clients__c = DataType_Utility.onNull(goal.New_Clients__c, 0);
		goal.New_Leads__c = DataType_Utility.onNull(goal.New_Leads__c, 0);
		goal.New_Referral_Partners_Contacted__c = DataType_Utility.onNull(goal.New_Referral_Partners_Contacted__c, 0);
		goal.Producer_Tracks_Info_Sessions__c = DataType_Utility.onNull(goal.Producer_Tracks_Info_Sessions__c, 0);
		goal.Referral_Partner_Plans_In_Place__c = DataType_Utility.onNull(goal.Referral_Partner_Plans_In_Place__c, 0);
		goal.Referral_Partner_Touches__c = DataType_Utility.onNull(goal.Referral_Partner_Touches__c, 0);
		goal.RP_Touches_In_Person__c = DataType_Utility.onNull(goal.RP_Touches_In_Person__c, 0);
		goal.RP_Touches_Virtual__c = DataType_Utility.onNull(goal.RP_Touches_Virtual__c, 0);
		goal.WSE_Added__c = DataType_Utility.onNull(goal.WSE_Added__c, 0);
	}

}