/**
 * @description TestFactoryReferralPartnerGroup contains methods to create test Referral Partner Group.
 */
@SuppressWarnings('PMD.ExcessiveParameterList, PMD.ExcessivePublicCount')
@isTest
public class TestFactoryReferralPartnerGroup {
    /**
	 * @description createReferralPartnerGroup creates a new ReferralPartnerGroup record in the database.
	 * @param  name       Name of the ReferralPartnerGroup
	 * @param  recordType Record Type name for the ReferralPartnerGroup
	 * @return ReferralPartnerGroup
	 */
	public static Referral_Partner_Group__c createReferralPartnerGroup(String name, String description, String commissionType, Decimal commissionRate) {
		Referral_Partner_Group__c ReferralPartnerGroup = makeReferralPartnerGroup(name, description, commissionType, commissionRate);
		insert ReferralPartnerGroup;
		return ReferralPartnerGroup;
	}

	/**
	 * @description makeReferralPartnerGroup makes an ReferralPartnerGroup record.
	 * @param  name       Name of the ReferralPartnerGroup
	 * @param  recordType Record Type name for the ReferralPartnerGroup
	 * @return ReferralPartnerGroup
	 */
	public static Referral_Partner_Group__c makeReferralPartnerGroup(String name, String description, String commissionType, Decimal commissionRate) {
		Referral_Partner_Group__c rpg = new Referral_Partner_Group__c(
            Name = name,
            Description__c = description,
            Group_Commission_Type__c = commissionType,
            Group_Commission_Rate__c = commissionRate
        );
        return rpg;
	}
}