/**
 * @description Naics_Service handles NAICS Codes.
 */
public with sharing class Naics_Service {
    private static final String FORMAT_INVALID_NAICS = '{0} has invalid NAICS {1}.';

    @TestVisible
    private static Map<String, String> mapCodeToTitle = null;

    /**
     * @description is6DigitNaics determines if the given code is a valid 6 digit NAICS.
     * @param  code Code testing
     * @return true if valid
     */
    public static Boolean is6DigitNaics(String code) {
        getNaics();

        return code != null && code.length() == 6 && mapCodeToTitle.containsKey(code);
    }

    /**
     * @description is6DigitNaics determines if the given code is a valid NAICS.
     * @param  code Code testing
     * @return true if valid
     */
    public static Boolean isValidCode(String code) {
        getNaics();

        return mapCodeToTitle.containsKey(code);
    }

    /**
     * @description getTitle retrieves the title from the code.
     * @param  code Code getting title for
     * @return Title if found, null on error
     */
    public static String getTitle(String code) {
        getNaics();

        if (mapCodeToTitle.containsKey(code)) {
            return mapCodeToTitle.get(code);
        }

        return null;
    }

    /**
     * @description getIndustry retrieves the industry from the code.
     * @param  code Code getting industry for
     * @return 3 digit Industry NAICS Code if found, null on error
     */
    public static String getIndustry(String code) {
        getNaics();

        if (code != null && code.length() >= 3) {
            String naics3 = code.substring(0, 3);

            if (mapCodeToTitle.containsKey(naics3)) {
                return mapCodeToTitle.get(naics3);
            }
        }

        return null;
    }

    /**
     * @description populateNaics sets the NAICS Title and Industry for new or
     * modified Accounts.
     * @param  mapOld  Map of how the Accounts looked
     * @param  listNew List of new or changes Accounts
     */
    public static void populateNaics(Map<Id, Account> mapOld, List<Account> listNew) {
        getNaics();

        for (Account account : listNew) {
            if (account.NAICS__c == null) {
                continue;
            }

            // if (account is prospect) {

            if (mapOld == null || account.NAICS__c != mapOld.get(account.ID).NAICS__c) {
                if (is6DigitNaics(account.NAICS__c)) {
                    account.NAICS_Title__c = getTitle(account.NAICS__c);
                    account.Custom_Industry__c = getIndustry(account.NAICS__c);
                } else {
                    account.addError(
                        String.format(
                            FORMAT_INVALID_NAICS,
                            new List<String>{ 'Account', account.NAICS__c }
                        )
                    );
                }
            }

            // }
        }
    }

    /**
     * @description populateNaics sets the NAICS Title and Industry for new or
     * modified Client Leads.
     * @param  mapOld  Map of how the Leads looked
     * @param  listNew List of new or changes Leads
     */
    public static void populateNaics(Map<Id, Lead> mapOld, List<Lead> listNew) {
        getNaics();

        Id idrtClientLead = recordTypeService.getId('Lead', 'Client_Lead');

        for (Lead lead : listNew) {
            if (lead.NAICS__c == null || lead.recordTypeId != idrtClientLead || lead.isConverted == true) {
                continue;
            }

            if (mapOld == null || lead.NAICS__c != mapOld.get(lead.ID).NAICS__c) {
                if (is6DigitNaics(lead.NAICS__c)) {
                    lead.NAICS_Title__c = getTitle(lead.NAICS__c);
                    lead.Custom_Industry__c = getIndustry(lead.NAICS__c);
                } else {
                    lead.addError(
                        String.format(FORMAT_INVALID_NAICS, new List<String>{ 'Lead', lead.NAICS__c })
                    );
                }
            }
        }
    }

    /**
     * @description getNaics loads the NAICS table if not already.
     */
    @TestVisible
    private static void getNaics() {
        if (mapCodeToTitle == null) {
            List<Naics_Code__c> codes = [SELECT Name, Naics_Title__c FROM NAICS_Code__c];

            mapCodeToTitle = new Map<String, String>();

            for (Naics_Code__c code : codes) {
                mapCodeToTitle.put(code.Name, code.Naics_Title__c);
            }
        }
    }
}