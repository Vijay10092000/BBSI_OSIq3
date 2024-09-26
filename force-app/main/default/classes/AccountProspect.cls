/**
 * @description AccountProspect methods for Prospect Accounts.
 */
public with sharing class AccountProspect {
    /**
     * @description sendEmailAssignedBU sends emails to newly assigned Business Units when
     * assigned to a Prospect account.
     * @param  mapOld Previous versions of the accounts
     * @param  mapNew New versions of the accounts
     */
	public static void sendEmailAssignedBU(Map<Id, Account> mapOld, Map<Id, Account> mapNew) {
        Id idAccountProspect = RecordTypeService.getId('Account', 'Prospect');
        Set<Id> idProspects = new Set<Id>();

        for (Account acc : mapNew.values()) {
			if (acc.RecordTypeId == idAccountProspect) {
				if (mapOld == null || acc.Business_Unit__c != mapOld.get(acc.Id).Business_Unit__c) {
                    if (acc.Business_Unit__c != null) {
					    idProspects.add(acc.Id);
                    }
				}
			}
        }

        if (!idProspects.isEmpty()) {
            futureSendBuProspectEmails(idProspects);
        }
    }

    /**
     * @description futureSendBuProspectEmails creates and sends emails for the
     * assigned Prospect Accounts.
     * @param  idProspects  Identifers of Prospects which may need emails
     */
    @future
    public static void futureSendBuProspectEmails(Set<Id> idProspects) {
        List<Account> prospects = new List< Account>([
            SELECT Id, Name, Business_Unit__c, Business_Unit__r.BBSI_Branch__c
            FROM Account
            WHERE Id IN :idProspects
            AND Business_Unit__c != NULL
        ]);

        Set<Id> idBuBranches = new Set<Id>();

        for (Account account : prospects) {
            if (account.Business_Unit__r.BBSI_Branch__c != null) {
                idBuBranches.add(account.Business_Unit__r.BBSI_Branch__c);
            }
        }

        if (!idBuBranches.isEmpty()) {
            Map<Id, Account> mapBranches = new Map<Id, Account>([
                SELECT Id, Name, Email_BU_when_Prospect_Assigned__c
                FROM Account
                WHERE Id IN :idBuBranches
            ]);

            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

            for (Account prospect : prospects) {
                if (mapBranches.containsKey(prospect.Business_Unit__r.BBSI_Branch__c)) {
                    Boolean allowSend = mapBranches.get(prospect.Business_Unit__r.BBSI_Branch__c).Email_BU_when_Prospect_Assigned__c;

                    if (allowSend == true) {
                        List<String> addresses = BusinessUnit_Service.getBusinessUnitEmails(prospect.Business_Unit__c);

                        if (!addresses.isEmpty()) {
                            emails.add(buildEmailAssignedBU(prospect.Id, addresses));
                        }
                    }
                }
            }

            Email_Service.send(emails);
        }
    }

    /**
     * @description buildEmailAssignedBU builds an email to send when a Prospect Account
     * is assigned to a Business Unit.
     * @param  idAccount    The identifier of the Account
     * @param  toAddresses  The email addresses of the Business Unit
     * @return An email
     */
    @TestVisible
    private static Messaging.SingleEmailMessage buildEmailAssignedBU(Id idAccount, List<String> toAddresses) {
        return Email_Service.buildTemplateEmail(
            toAddresses,
            null,
            'BusinessUnit_Assigned_a_Prospect',
            UserInfo.getUserId(),
            idAccount
        );
    }

	/**
	 * @description setPriceApprovalDate sets/clears the Price Approval date for a Prospect account.
	 * @param  oldAccounts  Accounts before changes
	 * @param  newAccounts  Accounts with changes
	 */
	public static void setPriceApprovalDate(Map<Id, Account> oldAccounts, List<Account> newAccounts) {
		for (Account account : newAccounts) {
			if (oldAccounts == null || oldAccounts.get(account.Id).Price_Approval__c != account.Price_Approval__c) {	
				if (account.Price_Approval__c == 'Approved') {
					account.Price_Approval_Date__c = Date.today();
				}
			}
		}
	}
}