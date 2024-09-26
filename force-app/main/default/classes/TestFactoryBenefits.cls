/**
 * @description TestFactoryBenefits contains methods to create test Benefits.
 */
@isTest
public class TestFactoryBenefits {
    /**
	 * @description createUser creates a Benefits in the database.
	 * @param  Name    Name For Benefits    
	 * @param  Account      Account Id
	 * @param  Opportunity  Opportunity Id
	 * @param  BenefitsReferralPartner Is Benefits Referral Partner?
	 * @return Benefits__c
	 */
    public static Benefits__c createBenefits( String Name,Id Account,Id Contact,Id Opportunity,String BenefitsReferralPartner){
        Benefits__c ben = makeBenefits(Name,Account,Contact,Opportunity,BenefitsReferralPartner);
        insert ben;
        return ben;
    }

    /**
	 * @description makeBenefits makes a Benefits in the database.
	 * @param  Name    Name For Benefits    
	 * @param  Account      Account Id
	 * @param  Opportunity  Opportunity Id
	 * @param  BenefitsReferralPartner Is Benefits Referral Partner?
	 * @return Benefits__c
	 */
    public static Benefits__c makeBenefits(String Name,Id Account,Id Contact,Id Opportunity,String BenefitsReferralPartner){
        Benefits__c ben = new Benefits__c();
        ben.AccountId__c = Account;
        ben.Name = Name;
        ben.LH_Contact_Name__c = Contact;
        ben.Is_there_a_benefits_referral_partner__c=BenefitsReferralPartner;
        ben.Opportunity__c = Opportunity;
        return ben;
    }
}