/**
 * @description RunoffForensicReportExtension contains methods to help build the Runoff Forensic Report.
 *
 * https://developer.salesforce.com/docs/atlas.en-us.pages.meta/pages/pages_output_pdf_render_in_apex.htm
 */
public without sharing class RunoffForensicReportExtension {
	@TestVisible
	private static final String FILENAME = 'RunoffForensicReport';
	@TestVisible
	private static final String FILE_TYPE = '.pdf';
	@TestVisible
	private static final String PDF_BODY_DEFAULT = 'Invalid Body';

	/**
	 * @description record holds the Client Cancellation record
	 */
	public Client_Cancellation__c record { get; private set; }

	/**
	 * @description clientAccount holds the related client account
	 */
	@TestVisible
	private Account clientAccount { get; private set; }

	/**
	 * @description isValid holds whether the Client Cancellation is valid
	 * for creating the report.
	 */
	@TestVisible
	private Boolean isValid { get; private set; }

	/**
	 * @description createReport creates an File and assigns it to the Client Cancellation record.
	 * @param idRecords  List of Client Cancellation record identifiers
	 * @return List of results
	 */
	@InvocableMethod(
		label='Runoff Forensic Report: Create'
		description='Create the Runoff Forensic report as file on record.'
		category='Client_Cancellation__c'
	)
	public static List<String> createReport(List<Id> idRecords) {
		List<String> result = new List<String>();

		List<Client_Cancellation__c> records = readRecords(idRecords);

		for (Client_Cancellation__c record : records) {
			String error = RunoffForensicReportExtension.getErrorString(record);
			if (String.isEmpty(error)) {
				try {
					File_Service.deleteFile(record.Id, FILENAME);
					File_Service.createFile(record.Id, FILENAME + FILE_TYPE, FILENAME, createBodyPdf(record));
					result.add('CREATED');
				} catch (Exception e) {
					result.add('Failed to create file');
				}
			} else {
				result.add(error);
			}
		}

		return result;
	}

	/**
	 * @description RunoffForensicReportExtension constructor
	 * @param  stdController The Standard Controller
	 */
	public RunoffForensicReportExtension(ApexPages.StandardController stdController) {
		if (stdController != null) {
			setup((Client_Cancellation__c) stdController.getRecord());
		}
	}

	/**
	 * @description setup initializes this extension.
	 * @param  cancellation Client_Cancellation__c for report
	 */
	public void setup(Client_Cancellation__c cancellation) {
		isValid = false;

		if  (cancellation != null) {
			record = (Client_Cancellation__c) readRecords(new List<Id>{ cancellation.Id }).get(0);

			if (record != null && record.Client__c != null) {
				Id idClient = record.Client__c;
				clientAccount = (Account) [
					SELECT Id, Name, External_Id__c, Annual_Billing__c, Prospect_Branch__r.Branch_Manager__c,
					Prospect_Branch__r.Name, Start_Date__c, Cancellation_Date__c, Assigned_Referral_Partner__r.Name,
					Producer__r.Name
					FROM Account
					WHERE Id = :idClient
					LIMIT 1
				];

				isValid = String.isEmpty(RunoffForensicReportExtension.getErrorString(record));
			}
		}
	}

	/**
	 * @description getErrorString determines the values missing to create a report.
	 * @param  record Client_Cancellation__c to test
	 * @return Empty string if no error, else string of errors
	 */
	@TestVisible
	private static String getErrorString(Client_Cancellation__c record) {
		String error = '';

		if (String.isEmpty(record.Cancellation_Reason__c)) {
			error += 'Missing Cancellation Reason \n';
		}
		if (String.isEmpty(record.Improvement__c)) {
			error += 'Missing Improvment \n';
		}
		if (String.isEmpty(record.Red_Flags__c)) {
			error += 'Missing Red Flags \n';
		}
		if (null == record.RP_Follow_up_Date__c) {
			error += 'Missing Referral Partner Follow-up Date \n';
		}
		if (!record.RP_Follow_up_Completed__c) {
			error += 'Referral Partner Follow-up not completed \n';
		}
		if (String.isEmpty(record.RP_Alignment__c)) {
			error += 'Missing Referral Partner Alignment \n';
		}

		return error.trim();
	}

	@TestVisible
	private static Blob createBodyPdf(Client_Cancellation__c cancellation) {
		PageReference reportPage = new PageReference('/apex/RunoffForensicReport?id=' + cancellation.Id);

		if (Test.isRunningTest()) {
			// getContentAsPDF cannot be called in a test
			return Blob.valueOf(PDF_BODY_DEFAULT);
		}

		return reportPage.getContentAsPDF();
	}

	private static List<Client_Cancellation__c> readRecords(List<Id> idRecords) {
		return [
			SELECT
				Id,
				AM_Approval_Status__c,
				AM_Comments__c,
				Business_Development_Manager__c,
				Cancellation_decision_due_to_COVID_19__c,
				Cancellation_Reason__c,
				Client__c,
				Client_Cancellation_Date__c,
				Consistent_CORE__c,
				Contracts_Comments__c,
				Contracts_Reviewed__c,
				Deep_Dive_Completed__c,
				Employees_Notified__c,
				Explanation__c,
				Had_Blueprint__c,
				Improvement__c,
				Last_Check_Date__c,
				Last_Core_Visit__c,
				Local_ORT_Attendance__c,
				Parent_Account__c,
				Red_Flags__c,
				Regular_Meetings__c,
				Revoke__c,
				Revoked_Reason__c,
				RP_Alignment__c,
				RP_Follow_up_Completed__c,
				RP_Follow_up_Date__c,
				Runoff_Forensic_Report_Attached__c,
				Safety_Incentive_Reason__c,
				Safety_Incentive_Refund_Request__c,
				Security_Deposit_Amount__c,
				Tax_Dept_Archived__c,
				Via__c,
				Where_did_the_business_go__c,
				Where_Framework_Failed__c,
				Who_Requested_Cancellation__c
			FROM Client_Cancellation__c
			WHERE Id IN :idRecords
		];
	}
}