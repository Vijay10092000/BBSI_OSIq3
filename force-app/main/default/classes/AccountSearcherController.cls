public without sharing class AccountSearcherController {
    public without sharing class AccountSearchResponse {
        @AuraEnabled
        public List<AccountData> accounts { get; set; }

        @AuraEnabled
        public String footer { get; set; }

        private AccountSearchResponse() {
            accounts = new List<AccountData>();
            footer = '';
        }
    }

    public without sharing class AccountData {
        @AuraEnabled
        public String accountId { get; set; }

        @AuraEnabled
        public String accountName { get; set; }

        @AuraEnabled
        public String nameDBA { get; set; }

        @AuraEnabled
        public String clientId { get; set; }

        @AuraEnabled
        public String branchName { get; set; }

        @AuraEnabled
        public String branchURL { get; set; }

        @AuraEnabled
        public String ownerName { get; set; }

        @AuraEnabled
        public String ownerContactURL { get; set; }

        @AuraEnabled
        public String typeName { get; set; }

        @AuraEnabled
        public String payrollSpecialist { get; set; }

        @AuraEnabled
        public String payrollSpecialistURL { get; set; }
    }
    // #40777: Replaced Payroll Specialist(Contact Lookup) field to Payroll Specialist(User Lookup) field
    @TestVisible
    private static final String FORMAT_QUERY =
        'SELECT Id, Name, External_Id__c, Prospect_Branch__c, Prospect_Branch__r.Name, OwnerId, Owner.Name, ' +
        '       DBA_Name__c, Payroll_Specialist__c, Payroll_Specialist__r.Name, RecordType.Name' +
        ' FROM Account' +
        ' WHERE {1} (Name LIKE \'%{0}%\' OR External_Id__c LIKE \'%{0}%\' OR DBA_Name__c LIKE \'%{0}%\') ' +
        ' ORDER BY Name {2}';
    @TestVisible
    private static final String AND_ALL = '';
    @TestVisible
    private static final String AND_PROSPECT_CLIENT_TERMINATED =
            'RecordType.Name IN (\'Prospect\', \'Client\', \'Terminated\') AND ';
    @TestVisible
    private static final String AND_PROSPECT_CLIENT =
        'RecordType.Name IN (\'Prospect\', \'Client\') AND ';
        @TestVisible
    private static final String AND_PROSPECT_ONLY =
        'RecordType.Name = \'Prospect\' AND ';
        @TestVisible
    private static final String AND_CLIENT_ONLY =
        'RecordType.Name = \'Client\' AND ';
    private static final String FORMAT_LIMIT = ' LIMIT {0}';
    private static final String FORMAT_SEARCH_FOR = 'List is for: "{0}"';

    // #40777: Replaced Payroll Specialist(Contact Lookup) field to Payroll Specialist(User Lookup) field
    @AuraEnabled
    public static AccountSearchResponse queryAccounts(String searchText, Integer countAccounts, String typeSelection) {
        AccountSearchResponse response = new AccountSearchResponse();

        try {
            if (String.isNotBlank(searchText)) {
                String baseUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/';
                //String url = baseUrl + 'lightning/r/Account/';               

                String query = makeQuery(searchText, countAccounts, typeSelection);

                List<Account> accounts = (List<Account>) Database.query(query);

                if (accounts.isEmpty()) {
                    response.footer = 'No accounts found';
                } else {
                    Map<Id, Id> mapAccountIdToOwnerContact = getAccountOwnerContacts(accounts);

                    for (Account a : accounts) {
                        AccountData ad = new AccountData();

                        ad.accountId = a.Id;
                        ad.accountName = a.Name;
                        ad.nameDBA = a.DBA_Name__c;
                        ad.typeName = a.RecordType.Name;
                        ad.clientId = a.External_Id__c;

                        if (String.isNotBlank(a.Prospect_Branch__c)) {
                            ad.branchURL = baseUrl + a.Prospect_Branch__c;
                            ad.branchName = a.Prospect_Branch__r.Name;
                        }

                        if (String.isNotBlank(a.OwnerId)) {
                            Id idContact = null;

                            if (mapAccountIdToOwnerContact.containsKey(a.Id)) {
                                idContact = mapAccountIdToOwnerContact.get(a.Id);
                            }

                            if (idContact == null) {
                                ad.ownerContactURL = '';
                            } else {
                                ad.ownerContactURL = baseUrl + idContact;
                            }
                            ad.ownerName = a.Owner.Name;
                        }

                        if (String.isNotBlank(a.Payroll_Specialist__c)) {
                            ad.payrollSpecialist = a.Payroll_Specialist__r.Name;
                            ad.payrollSpecialistURL = baseUrl + a.Payroll_Specialist__c;
                        }

                        response.accounts.add(ad);
                    }
                }
            } else {
                response.footer = 'No search value given';
            }
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        return response;
    }

    @TestVisible
    private static String makeQuery(String searchText, Integer countAccounts, String typeSelection) {
        String andClause = makeAndClause(typeSelection);

        String theLimit = '';

        if (0 < countAccounts) {
            theLimit = String.format(FORMAT_LIMIT, new List<String>{ String.valueof(countAccounts) });
        }

        String query = String.format(FORMAT_QUERY, new List<String>{ searchText, andClause, theLimit });
        System.debug('QUERY:  ' + query);
        return query;
    }

    @TestVisible
    private static String makeAndClause(String typeSelection) {
        String andClause;

        switch on typeSelection {
            when 'AllTypes' {
                andClause = AND_ALL;
            }
            when 'ProspectsClientsTerminated' {
                andClause = AND_PROSPECT_CLIENT_TERMINATED;
            }
            when 'ProspectsClients' {
                andClause = AND_PROSPECT_CLIENT;
            }
            when 'Prospects' {
                andClause = AND_PROSPECT_ONLY;
            }
            when 'Clients' {
                andClause = AND_CLIENT_ONLY;
            }
            when else {
                andClause = AND_PROSPECT_CLIENT_TERMINATED;
            }
        }

        return andClause;
    }

    @TestVisible
    private static Map<Id, Id> getAccountOwnerContacts(List<Account> accounts) {
        Set<Id> idOwners = new Set<Id>();

        for (Account a : accounts) {
            idOwners.add(a.OwnerId);
        }

        List<Contact> contacts = [SELECT Id, OwnerId, User_Id__c FROM Contact WHERE User_Id__c IN :idOwners];
        Map<Id, Id> mapUserIdToContactId = new Map<Id, Id>();

        for (Contact c : contacts) {
            mapUserIdToContactId.put(c.User_Id__c, c.Id);
        }

        Map<Id, Id> result = new Map<Id, Id>();
        for (Account a : accounts) {
            Id idContact = null;

            if (mapUserIdToContactId.containsKey(a.OwnerId)) {
                idContact = mapUserIdToContactId.get(a.OwnerId);
            }

            result.put(a.Id, idContact);
        }

        return result;
    }
}