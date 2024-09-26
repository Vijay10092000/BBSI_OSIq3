/**
 * ReferralPartnerChange_Const contains some common values for Referral Partner
 * Change Requests.
 */
public without sharing class ReferralPartnerChange_Const {

    public static final String NAME = 'Referral_Partner_Change_Request__c';

    // Get each of the RecordTypes
    public static Id idrtHoldRP = RecordTypeService.getId(NAME, 'Hold_Request_Referral_Partner');
    public static Id idrtHoldClient = RecordTypeService.getId(NAME, 'Hold_Request_Client');
    public static Id idrtReleaseHoldRP = RecordTypeService.getId(NAME, 'Release_Hold_Referral_Partner');
    public static Id idrtReleaseHoldClient = RecordTypeService.getId(NAME, 'Release_Hold_Client');
    public static Id idrtCommissionChangeRP = RecordTypeService.getId(NAME, 'Override_Request_Referral_Partner');
    public static Id idrtOverrideClient = RecordTypeService.getId(NAME, 'Override_Request_Client');
    public static Id idrtRPOR = RecordTypeService.getId(NAME, 'RPOR_Change_Client');
    public static Id idrtGroupComm = RecordTypeService.getId(NAME, 'Group_Commission_Change');
    public static Id idrtRPGroupChange = RecordTypeService.getId(NAME, 'Referral_Partner_Group_Change');
    public static Id idrtRPReqActiv = RecordTypeService.getId(NAME, 'Request_Activation');

    /*-------------------Product Line Types---------------------------------------------*/
    public static final String PLTYPE_BENEFITS = 'Benefits';	
    public static final String PLTYPE_WORKERSCOMP = 'Workers Comp';	
    public static final String DEFAULTWORKCOMPTYPE = '% of Work Comp';	
    public static final String DEFAULTBENEFITSTYPE = 'Price per medical participant';	
}