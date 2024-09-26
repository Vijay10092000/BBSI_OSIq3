public without sharing class ReferralPartnerGroup_Service {

    /**
     * getRelatedReferralPartners retrieves a map relating groups to their
     * Referral Partners
     * @param  rpgs Groups looking at
     * @param  includeInactive Should terminated RPs be included?
     * @return A Map relating group ids to a list of Referral Partner Accounts
     */
    public static Map<Id, List<Account>> getRelatedReferralPartners(Set<Id> rpgs, Boolean includeInactive) {
        Map<Id, List<Account>> results = new Map<Id, List<Account>>();
        List<Account> accounts = new List<Account>();

        for (Id id : rpgs) {
            results.put(id, new List<Account>());
        }

        String query = 'SELECT Id, Name, Status__c, Assigned_Referral_Partner__c, Referral_Partner_Status__c, ' +
            'Commission_Type__c, Commission_Rate__c, Hold__c, Hold_Effective_Date__c, Referral_Partner_Group__c ' +
            'FROM Account ' +
            'WHERE RecordType.Name = \'Referral Partner\' ' +
            'AND Referral_Partner_Group__c IN :rpgs ';
        if (!includeInactive) {
            query += 'AND Referral_Partner_Status__c != \'Inactive\' ';
        }

        for (Account a : Database.query(query)) {
            results.get(a.Referral_Partner_Group__c).add(a);
        }

        return results;
    }

    /**
     * getReferralPartnerGroups retrieves the Referral Partner Groups objects
     * from the given Ids.
     * @param  idGroups Referral Partner Group ids
     * @return Map of group ids to the group object
     */
    public static Map<Id, Referral_Partner_Group__c> getReferralPartnerGroups(Set<Id> idGroups) {
        return new Map<Id, Referral_Partner_Group__c>([
            SELECT Id, Name, Description__c, Group_Commission_Type__c, Group_Commission_Rate__c
            FROM Referral_Partner_Group__c
            WHERE Id IN :idGroups
        ]);
    }

    /**
     * confirmNoReferralPartnersBeforeDelete checks for Referral Partners in the group
     * before it may be deleted.
     * @param mapRpGroups
     */
    public static void confirmNoReferralPartnersBeforeDelete(Map<Id, Referral_Partner_Group__c> mapRpGroups) {
        Map<Id, Boolean> hasReferralPartners = new Map<Id, Boolean>();

        for (Account rp : [SELECT Id, Referral_Partner_Group__c FROM Account WHERE RecordType.Name = 'Referral Partner' AND Referral_Partner_Group__c IN :mapRpGroups.keySet()]){
            hasReferralPartners.put(rp.Referral_Partner_Group__c, true);
        }

        for (Referral_Partner_Group__c rpg : mapRpGroups.values()) {
            if (hasReferralPartners.containsKey(rpg.Id)) {
                rpg.addError('Cannot delete a Referral Partner Group with related Referral Partners.');
            }
        }
    }

    /**
     * truncateGroupDescription trucates the Referral Partner Group Description
     * to 255 characters.
     * @param  rpg rpg description
     * @return The truncated string
     */
    public static String truncateGroupDescription(Referral_Partner_Group__c rpg) {
        String description = '';

        if (rpg != null) {
            if (!String.isBlank(rpg.Description__c)) {
                description = rpg.Description__c;

                if (description.length() > 255) {
                    description = description.left(250) + '...';
                }
            }
        }
        return description;
    }

}