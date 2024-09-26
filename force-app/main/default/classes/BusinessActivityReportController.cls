/**
 * @description BusinessActivityReportController handles the server side
 * calls from the BusinessActivityReport component.
 */
@SuppressWarnings('PMD.ApexDoc, PMD.ExcessiveParameterList')
public without sharing class BusinessActivityReportController {
	/**
	 * @description setup determines the data needed for the component
	 * @return BusinessActivityReportSetup containing the needed data
	 */
	@AuraEnabled
	public static BusinessActivityReportSetup setup() {
		BusinessActivityReportSetup setup = new BusinessActivityReportSetup();
		setup.readData();
		return setup;
	}

	/**
	 * @description buildReport creates the text for the report
	 * @param  idBDMs             List of BDM User Ids
	 * @param  idBranches         List of Branch Account Ids
	 * @param  year               Year looking at
	 * @param  quarter            Quarter looking at
	 * @param  includeAllRecords  Include all records
	 * @param  includeAllBDMs      Include All BDMs
	 * @param  includeAllBranches  Include All Branches
	 * @return Text containing the report as .XLS XML file
	 */
	@AuraEnabled
	public static String buildReport(
		List<String> idBDMs, List<String> idBranches, Integer year, Integer quarter,
		Boolean includeAllRecords, Boolean includeAllBDMs, Boolean includeAllBranches
	) {
		try {
			idBDMs.sort();

			return (new BusinessActivityReport()).create(idBDMs, idBranches, year, quarter, includeAllRecords, includeAllBDMs, includeAllBranches);
		} catch (Exception e) {
			String description = 'BusinessActivityReportController.buildReport';

			description += '\n  BDMS Ids: ' + String.join(idBDMs, ', ');
			description += '\n  Branch Ids: ' + String.join(idBDMs, ', ');
			description += '\n  Year: ' + year;
			description += '\n  Quarter: ' + quarter;
			description += '\n  Include All Records: ' + includeAllRecords;
			description += '\n  Include All BDMs: ' + includeAllBDMs;
			description += '\n  Include All Branches: ' + includeAllBranches;

			Log.error('BusinessActivityReport', 'Exception Creating Business Activity Report', description, e);

			throw new AuraHandledException('Exception while creating report.');
		}
	}
}