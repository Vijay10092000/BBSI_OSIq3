/**
 * @description AccountClientShell_Extension creates the Client's Prism Shell.
 */
public without sharing class AccountClientShell_Extension {
	@TestVisible
	private static final String QUERY_SHELL_DATA = String.escapeSingleQuotes(
		'SELECT Id, Name, BillingCity, BillingPostalCode, BillingState, BillingStreet, Prospect_Branch__r.Name,' +
		'    Business_Unit__r.Name, User_Acronym__c, DBA_Name__c,FEIN__c, NAICS__c,Fax, Phone, County__c,' +
		'    Business_Entity_Type__c, Business_Entity_Type_Code__c, Business_Development_Manager__r.EmployeeNumber,' +
		'    Assigned_Referral_Partner__r.External_Id__c, Assigned_Referral_Partner__r.RecordTypeId,' +
		'    Prospect_Branch__r.Branch_No__c, ' +
		'    Payroll_Specialist__c, Payroll_Specialist__r.Name, Payroll_Specialist__r.EmployeeNumber, Payroll_Specialist__r.AD_Username__c, ' +
		'    (SELECT Id, Business_Unit_Member__c, Business_Unit_Member__r.Role__c, Business_Unit_Member__r.Active__c,' +
		'         Business_Unit_Member__r.BU_Member__r.User_Id__r.EmployeeNumber,' +
		'         Business_Unit_Member__r.BU_Member__r.User_id__r.FirstName,' +
		'         Business_Unit_Member__r.BU_Member__r.User_id__r.LastName,' +
		'         Business_Unit_Member__r.BU_Member__r.User_id__r.AD_Username__c,' +
		'         Business_Unit_Member__r.Primary__c' +
		'      FROM Branch_Business_Unit__r WHERE Business_Unit_Member__r.Active__c = TRUE' +
		'      ORDER BY Business_Unit_Member__r.Role__c)' +
		' FROM Account' +
		' WHERE Id = :IdAccount');

	@TestVisible
	private static final String SHELL_CREATION_FAILURE =
		'Please open a MyHub ticket.<br/><br/>' +
		'There was a problem creating the client shell in Prism.<br/>' +
		'A case has been created which you can view by <a href="/{0}" >Clicking Here</a><br/>' +
		'Support has been notified and may contact you with questions.<br/>' +
		'<a href="/{1}" >Click Here</a> to return to the opportunity.<br/>' +
		'Please do not attempt to create the client again.';

	@TestVisible
	private static final String OPPORTUNITY_IS_INCOMPLETE = 'Please correct the error(s) before creating a Prism shell:<br/>{0}</br></br></br><a href="/{1}" >Click Here</a> to return to record.';
	@TestVisible
	private static final String FAILED_SHELL_CREATE_TITLE = 'Failed to create Client Shell for Account {0} ({1})';
	@TestVisible
	private static final String FAILED_SHELL_CREATE_BODY = 'Callout to Boomi/Prism failed.  A Log record should exist for this failure.\n\n{0}\n\nAccount: {1}  {2}\nOpportunity: {3}  {4}\n\nResponse:\n{5}';

	// Account related to the Opportunity
	@TestVisible
	private Account workAccount;

	// Opportunity which is causing the shell to be created
	@TestVisible
	private Opportunity workOpp;

	private List<String> errors = new List<String>();

	/**
	 * @description ShellWrapper holds the data which will be sent to Prism to create the shell.
	 */
	@TestVisible
	public class ShellWrapper {
		@TestVisible
		private Account sfdcAccount;

		@TestVisible
		private String riskManager;

		@TestVisible
		private String referralPartner;

		@TestVisible
		private String payrollRep;

		@TestVisible
		private String hrManager;

		@TestVisible
		private String riskManagerUser;

		@TestVisible
		private String payrollRepUser;

		@TestVisible
		private String hrManagerUser;

		@TestVisible
		private String branchNo;

		@TestVisible
		private String billingStreet1;

		@TestVisible
		private String billingStreet2;

		public String toJSON() {
			return JSON.serialize(this);
		}

		/**
		 * @description ShellWrapper constructor.
		 */
		public ShellWrapper(Id idAccount) {
			Account a = queryShellData(idAccount);
	
			Boolean isPrimary = false;
			String employeeNumber;
			String employeeName;
	
			Boolean havePrimaryAdUser = false;
			String adUserName;
	
			Boolean havePrimaryPayrollRep = false;
			String payrollRep;
			String payrollRepName;
	
			Boolean havePrimaryRiskManager = false;
			String riskManager;
			String riskManagerName;
	
			Boolean havePrimaryHrManager = false;
			String hrManager;
			String hrManagerName;
		
			for (Business_Unit_Member__c bum : a.Branch_Business_Unit__r) {
				if (
					bum.Business_Unit_Member__c != null &&
					bum.Business_Unit_Member__r.Role__c != null &&
					bum.Business_Unit_Member__r.BU_Member__r.User_Id__r.EmployeeNumber != null
				) {
					isPrimary = bum.Business_Unit_Member__r.Primary__c;
					employeeNumber = bum.Business_Unit_Member__r.BU_Member__r.User_Id__r.EmployeeNumber;
					employeeName = bum.Business_Unit_Member__r.BU_Member__r.User_Id__r.AD_Username__c;
	
					if (isPrimary || !havePrimaryAdUser) {
						adUserName = bum.Business_Unit_Member__r?.BU_Member__r?.User_id__r?.AD_Username__c;
					}
					havePrimaryAdUser |= isPrimary;
	
					switch on (bum.Business_Unit_Member__r.Role__c) {
						when 'Payroll Specialist' {
							if (isPrimary || !havePrimaryPayrollRep) {
								payrollRep = employeeNumber;
								payrollRepName = employeeName;
							}
	
							havePrimaryPayrollRep |= isPrimary;
						}
						when 'Risk Consultant' {
							if (isPrimary || !havePrimaryRiskManager) {
								riskManager = employeeNumber;
								riskManagerName = employeeName;
							}
	
							havePrimaryRiskManager |= isPrimary;
						}
						when 'HR Consultant' {
							if (isPrimary || !havePrimaryHrManager) {
								hrManager = employeeNumber;
								hrManagerName = employeeName;
							}
	
							havePrimaryHrManager |= isPrimary;
						}
					}
				}
			}
			
			if (a.Payroll_Specialist__c != null) {
				havePrimaryPayrollRep = true;
				payrollRep = a.Payroll_Specialist__r.EmployeeNumber;
				payrollRepName = a.Payroll_Specialist__r.AD_Username__c;
			}
	
			sfdcAccount = a;
			riskManager = riskManager;
			referralPartner = getReferralPartnerId(a);
			payrollRep = payrollRep;
			hrManager = hrManager;
			riskManagerUser = riskManagerName;
			payrollRepUser = payrollRepName;
			hrManagerUser = hrManagerName;

			if (a.Prospect_Branch__r != null) {
				string b = a.Prospect_Branch__r.Name;
				branchNo = fixBranchNumber(a.Prospect_Branch__r.Branch_No__c);
			}
	
			if (!String.isBlank(a.BillingStreet)) {
				String street = a.BillingStreet.replace('\r', '');
	
				if (street.contains('\n')) {
					billingStreet1 = street.substringBefore('\n').trim();
					billingStreet2 = street.substringAfter('\n').replace('\n', ' ').trim();
				} else {
					billingStreet1 = street;
				}
			}
		}

		public Account queryShellData(Id idAccount) {	
			Map<String, Object> binds = new Map<String, Object>{
				'idAccount' => idAccount
			};

			return Database.queryWithBinds(QUERY_SHELL_DATA, binds, AccessLevel.SYSTEM_MODE);
		}
	}

	/**
	 * @description AccountClientShell_Extension constructor.
	 * @param  stdController The standard controller
	 */
	public AccountClientShell_Extension(ApexPages.StandardController stdController) {
		workOpp = [
			SELECT 
				Id, 
				Name, 
				AccountId, 
				Amount, 
				Client_Annual_Payroll__c,
				States_of_Operation__c,
				AM_Approval_Status__c, 
				OK_For_Risk_Approval_Status__c, 
				Credit_Approval_Status__c
			FROM Opportunity
			WHERE Id = :stdController.getId()
		];
		
		workAccount = [
			SELECT
				Id,
				Name,
				External_Id__c,
				Verified__c,
				Safety_Incentive__c,
				NAICS__c,
				FEIN__c,
				EEO_Reporting__c,
				Customer_Class__c,
				Business_Unit__c,
				BU_Assignment_Date__c
			FROM Account
			WHERE Id = :workOpp.AccountId
		];
	}

	/**
	 * @description createClientShell creates a Prism Shell for the Opportunity's related Account.
	 * @return Update Account page or null to remain on Opportunity.
	 */
	public PageReference createClientShell() {
		PageReference pageRef = null;

		if (workAccount.External_Id__c == null) {
			String clientID = makeClientShell();

			if (clientID != null) {		
				updateClientId(clientID);

				workOpp.RecordTypeId = RecordTypeService.getId('Opportunity', 'Client');
				update workOpp;

				AccountProspectOnboard.createOnboardingCase(workOpp);

				pageRef = new PageReference('/' + workAccount.Id);
			}
		} else {
			// Account already has a shell
			pageRef = new PageReference('/' + workAccount.Id);
		}

		if (!errors.isEmpty()) {
			string message = '';

			for (String error : errors) {
				message += '\n' + error;
			}

			String text = String.format(OPPORTUNITY_IS_INCOMPLETE, new List<String>{ message, workOpp.Id });

			ApexPages.addMessage(
				new ApexPages.Message(
					ApexPages.Severity.ERROR, 
					text
				)
			);

			pageRef = null;
		}

		return pageRef;
	}

	/**
	 * @description makeClientShell makes the create callout to Prism.
	 * for the account.
	 * @return The new Client ID or null
	 */
	@TestVisible
	private String makeClientShell() {
		ShellWrapper wrapper = new ShellWrapper(workAccount.Id);

		errors = validate(wrapper);

		if (!errors.isEmpty()) {
			return null;
		}

		String json = wrapper.toJSON();

		if (String.isBlank(json)) {
			errors.add('Failed to create Prism Shell account.  Invalid JSON.');
			return null;
		}

		return getClientId(json);
	}

	/**
	 * @description getClientId call to Boomi to set up the Client Shell and retrieve the Client Id.
	 * If the call errors, a Case is automatically created.
	 * @param  json  Data sent with the call
	 * @return The Client Id or null on error.
	 */
	@TestVisible
	private String getClientId(String json) {
		HttpResponse response = HttpCallout.callBoomi('createClient', json);

		if (response == null || response.getStatusCode() != 200) {			
			String responseBody = response?.getBody().trim();
			String linkAccount = URL.getSalesforceBaseUrl().toExternalForm() + '/' + workAccount.Id;
			String linkOpportunity = URL.getSalesforceBaseUrl().toExternalForm() + '/' + workOpp.Id;
			
			Id caseId = createCase(
				workAccount.Id,
				String.format(FAILED_SHELL_CREATE_TITLE, new List<String>{ workAccount.Name, workAccount.Id }),
				String.format(
					FAILED_SHELL_CREATE_BODY,
					new List<String>{ getError(responseBody), workAccount.Name, linkAccount, linkOpportunity, workOpp.Name, responseBody }
				)
			);

			errors.add(
				String.format(
					SHELL_CREATION_FAILURE,
					new List<String>{ String.valueOf(caseId), String.valueOf(workOpp.Id) }
				)
			);

			return null;
		}
		
		return response.getBodyDocument().getRootElement().getChildElement('clientid', null).getText();
	}

	/**
	 * @description getError tries to retrive the specific error from an HTML response
	 * @param  body The response body
	 * @return The specific error or an empty string if not found
	 */
	@TestVisible
	private String getError(String body) {
		if (!String.isBlank(body)) {
			if (body.startsWith('<html>')) {
				return body.substringAfter('Unable to create new client in Prism: Error 4')
					.substringBefore('</title>')
					.trim();
			}
		}

		return '';
	}

	/**
	 * @description updateClientId sets the Client identifier (External_Id__c) on the account.
	 * @param  clientId The Client identifier
	 */
	@TestVisible
	private void updateClientId(String clientId) {
		workAccount.External_Id__c = clientId;
		update workAccount;
	}

	/**
	 * @description createCase create a new Case for callout failure
	 * @param  accountId Account identifier related to the Opportunity
	 * @param  title     Subject for the Case
	 * @param  body      Error information
	 * @return The new Case identifier
	 */
	@TestVisible
	private Id createCase(Id accountId, String title, String body) {
		return Case_Services.insertSystemGeneratedCase(title, body, accountId);
	}

	/**
	 * @description getReferralPartnerId retrieves the Referral Partner's External Id related
	 * to the given Account.
	 * @param  account  Account looking at
	 * @return The Referral Partner's External Id
	 *         null if the Referral Partner does not have an External Id
	 *         "9999" if the Referral Parnter is not actually a Referral Partner
	 */
	private static String getReferralPartnerId(Account account) {
		Boolean isReferralPartner = RecordTypeService.isType(
			account.Assigned_Referral_Partner__r.RecordTypeId,
			'Account',
			'Referral Partner'
		);
		String result;

		if (account.Assigned_Referral_Partner__c != null) {
			if (isReferralPartner && account.Assigned_Referral_Partner__r.External_Id__c != null) {
				result = account.Assigned_Referral_Partner__r.External_Id__c;
			} else if (!isReferralPartner) {
				result = '9999';
			}
		} else {
			result = '9999';
		}

		return result;
	}

	/**
	 * @description fixBranchNumber pads leading '0's to the branch number to make it 3 characters (or more).
	 * @param  value  Branch Number to fix
	 * @return Fixed Branch Number
	 */
	@TestVisible
	private static String fixBranchNumber(String value) {
		if (!String.isBlank(value)) {
			value = value.leftPad(3, '0');
		}

		return value;
	}
		
	/**
	 * @description validate determines if there is missing data in this wrapper
	 * and given data.
	 * @param wrapper   ShellWrapper
	 * @return Empty List if all is OK
	 */
	@TestVisible
	@SuppressWarnings('PMD.StdCyclomaticComplexity, PMD.CyclomaticComplexity')
	private List<String> validate(ShellWrapper wrapper) {
		List<String> errors = new List<String>();

		if (workOpp.Amount == null || workOpp.Amount == 0) {
			errors.add('Enter an Amount');
		}

		if (workOpp.AM_Approval_Status__c != 'Approved') {
			errors.add('You must get Area Manager approval');
		}

		if (workOpp.OK_For_Risk_Approval_Status__c != 'Approved') {
			errors.add('OK for Risk Approval status is needed');
		}

		if (workOpp.Credit_Approval_Status__c != 'Approved') {
			errors.add('Credit Approval is needed');
		}

		if (workAccount.BU_Assignment_Date__c == null) {
			errors.add('Enter a Business Unit Assingment Date');
		}

		if (workAccount.Business_Unit__c == null) {
			errors.add('Enter a Business Unit');
		}

		if (workAccount.Customer_Class__c == null || workAccount.Customer_Class__c == '') {
			errors.add('Customer Class can not be blank');
		}

		if (workAccount.EEO_Reporting__c == null || workAccount.EEO_Reporting__c == '') {
			errors.add('Enter Yes or No for EEO Reporting');
		}

		if (workAccount.FEIN__c == null || workAccount.FEIN__c == '') {
			errors.add('Enter FEIN');
		}

		if (workAccount.NAICS__c == null || workAccount.NAICS__c == '') {
			errors.add('Enter NACIS Code');
		} else if (!workAccount.NAICS__c.isNumeric()) {
			errors.add('Invalid NACIS Code. NACIS Code can only contain numeric digits');
		}

		if (workAccount.Safety_Incentive__c == null || workAccount.Safety_Incentive__c == '') {
			errors.add('Enter Safety Incentive');
		}

		if (workAccount.Verified__c == false) {
			errors.add('Account address must be verified');
		}

		if (wrapper.payrollRepUser == null) {
			errors.add('A Payroll Specialist must be assigned on the Account, or listed as a Business Unit Member');
		}

		return errors;
	}
}