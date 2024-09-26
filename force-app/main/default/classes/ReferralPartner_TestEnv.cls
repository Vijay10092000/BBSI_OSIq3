/**
 * ReferralPartner_TestEnv builds an environment for testing
 * code related to Referral Partners, Referral Partner Groups,
 * Referral Partner Change Requests and more!
 *
 * Group1                   Referral Partner 0, Referral Partner 1
 * Group2                   Referral Partner 2, Referral Partner 3
 * Group3                   No Referral Partners
 *
 * Referral Partner 0      Terminated   -
 * Referral Partner 1      Active       client10, client11, client12, client13, clientPrimary
 * Referral Partner 2      Active       client21, client22
 * Referral Partner 3      Pending      -
 *
 * Client 10               Inactive
 * Client 11               Active
 * Client 12               Active
 * Client 13               Pending
 * Client 21               Active
 * Client 22               Pending
 * Client Split            Active  Split Commissions between Referral Partners 1 and 2
 */
@SuppressWarnings('PMD.ExcessivePublicCount, PMD.TooManyFields')
@IsTest
public without sharing class ReferralPartner_TestEnv {

    private static final String RT_CONTACT_PRODUCER = 'Producer';
    private static final String RT_BBSI_EMPLOYEE = 'BBSI Employee';

	private static final String RPAUSER_LASTNAME = 'ReferralSourceUserRpa';
	private static final String BDMUSER_LASTNAME = 'ReferralSourceUserBdm';
	private static final String AMUSER_LASTNAME = 'ReferralSourceUserAm';
    private static final String NAME_GROUP_1 = 'GROUP 1';
    private static final String NAME_GROUP_2 = 'GROUP 2';
    private static final String NAME_GROUP_3 = 'GROUP 3';
	private static final String BRANCH_DUDE_LASTNAME = 'BranchDude';
	private static final String PRODUCER_LASTNAME_1A = 'Producer1A';
	private static final String PRODUCER_LASTNAME_1B = 'Producer1B';
	private static final String PRODUCER_LASTNAME_2 = 'Producer2';
	private static final String PRODUCER_LASTNAME_3 = 'Producer3';
	private static final String BRANCH_NUMBER = '000';
	private static final String BRANCH_NAME	 = 'Branch';
    private static final String NAME_REFERRAL_PARTNER_0 = 'Test RP ZERO TERMINATED';
    private static final String NAME_REFERRAL_PARTNER_1 = 'Test RP ONE';
    private static final String NAME_REFERRAL_PARTNER_2 = 'Test RP TWO';
    private static final String NAME_REFERRAL_PARTNER_3 = 'Test RP THREE PENDING';
    private static final String NAME_CLIENT_10 = 'Client ONE- ZERO TERMINATED';
    private static final String NAME_CLIENT_11 = 'Client ONE-ONE';
    private static final String NAME_CLIENT_12 = 'Client ONE-TWO';
    private static final String NAME_CLIENT_13 = 'Client ONE-THREE';
    private static final String NAME_CLIENT_21 = 'Client TWO-ONE';
    private static final String NAME_CLIENT_22 = 'Client TWO-TWO';
    private static final String NAME_CLIENT_SPLIT = 'Client SPLIT';
    private static final String NAME_CLIENT_Primary = 'Client Primary';

    public User bdm = null;
    public User areaManager = null;
    public User rpAdmin = null;
    public User sysAdmin = null;

    public Referral_Partner_Group__c group1 = null;
    public Referral_Partner_Group__c group2 = null;
    public Referral_Partner_Group__c group3 = null;

	public Account branch;
    public Account partner0 = null;
    public Account partner1 = null;
    public Account partner2 = null;
    public Account partner3 = null;
    public Account client10 = null;
    public Account client11 = null;
    public Account client12 = null;
    public Account client13 = null;
    public Account client21 = null;
    public Account client22 = null;
    public Account clientSplit = null;
    public Account clientPrimary = null;

    public Contact branchDude = null;
    public Contact producer1A = null;
    public Contact producer1B = null;
    public Contact producer2 = null;
    public Contact producer3 = null;

    /**
     * build builds a whole set of data for testing the
     * Referral Partner methods.
     */
    @SuppressWarnings('PMD.ApexUnitTestMethodShouldHaveIsTestAnnotation')
    public void build() {
        String emailRpAdmin = 'Test.' + RPAUSER_LASTNAME + '@bbsi.zzz';

        sysAdmin = TestFactory.createUser('SysAdmin', 'sys.admin@bbsi.zzz', 'sys.admin@bbsi.zzz', 'System Administrator', '910', true);

        System.runAs(sysAdmin) {
            rpAdmin = TestFactory.createUser(RPAUSER_LASTNAME, emailRpAdmin, emailRpAdmin, 'Legal', '910', false);
            areaManager = TestFactory.createUserAM(AMUSER_LASTNAME, BRANCH_NUMBER, false);
            bdm = TestFactory.createUserBDM(BDMUSER_LASTNAME, '44444', Profile_Service.BBSI_STANDARD, BRANCH_NUMBER, false);

            branch = TestFactory.createAccountBranch(BRANCH_NAME, BRANCH_NUMBER, 'Manager Name', 'manager.name@bbsi.zzz', false);
            branch.Branch_Manager__c = 'Test ' + areaManager.LastName;
            branch.Branch_Manager_Email__c = areaManager.Email;
            insert branch;

            insert new List<User>{ rpAdmin, areaManager, bdm };

            PermissionSet psRPAdmin = [SELECT Id FROM PermissionSet WHERE Name = :PermissionSet_Service.REFERRAL_PARTNER_ADMIN];
            System.assertNotEquals(null, psRPAdmin, 'The Permission Set ' + PermissionSet_Service.REFERRAL_PARTNER_ADMIN + ' should exist.');

            PermissionSetAssignment psaRPAdmin = new PermissionSetAssignment(
                PermissionSetId = psRPAdmin.Id,
                AssigneeId = rpAdmin.Id
            );
            PermissionSetAssignment psaSysAdmin = new PermissionSetAssignment(
                PermissionSetId = psRPAdmin.Id,
                AssigneeId = sysAdmin.Id
            );

            insert new List<PermissionSetAssignment>{ psaRPAdmin, psaSysAdmin };

            branchDude = TestFactory.createContact(branch, BRANCH_DUDE_LASTNAME, RT_BBSI_EMPLOYEE, true);
        }

        System.runAs(rpAdmin) {
            group1 = TestFactory.createReferralPartnerGroup(NAME_GROUP_1, NAME_GROUP_1, '% of WC Eligible Payroll', 1.11, false);
            group2 = TestFactory.createReferralPartnerGroup(NAME_GROUP_2, NAME_GROUP_2, '% of Margin', 2.22, false);
            group3 = TestFactory.createReferralPartnerGroup(NAME_GROUP_3, NAME_GROUP_3, 'Amount Per Check', 3.33, false);
            insert new List<Referral_Partner_Group__c>{ group1, group2, group3 };
        }

        System.runAs(sysAdmin) {
            partner0 = TestFactory.createAccountReferralPartner(NAME_REFERRAL_PARTNER_0, 'Inactive', '% of WC Eligible Payroll', 10.00, group1.Id, false);
            partner1 = TestFactory.createAccountReferralPartner(NAME_REFERRAL_PARTNER_1, 'Active', '% of WC Eligible Payroll', 1.11, group1.Id, false);
            partner2 = TestFactory.createAccountReferralPartner(NAME_REFERRAL_PARTNER_2, 'Active', '% of Margin', 2.22, group2.Id, false);
            partner3 = TestFactory.createAccountReferralPartner(NAME_REFERRAL_PARTNER_3, 'Pending', '% of Margin', 2.22, null, false);
            partner0.OwnerId = areaManager.Id;
            partner1.OwnerId = areaManager.Id;
            partner2.OwnerId = areaManager.Id;
            partner3.OwnerId = areaManager.Id;
            insert new List<Account>{ partner0, partner1, partner2, partner3 };
        }

        System.runAs(areaManager) {
            producer1A = TestFactory.createContact(partner1, PRODUCER_LASTNAME_1A, RT_CONTACT_PRODUCER, false);
            producer1A.Primary__c = true;
            producer1B = TestFactory.createContact(partner1, PRODUCER_LASTNAME_1B, RT_CONTACT_PRODUCER, false);
            producer2 = TestFactory.createContact(partner2, PRODUCER_LASTNAME_2, RT_CONTACT_PRODUCER, false);
            producer2.Primary__c = true;
            producer3 = TestFactory.createContact(partner3, PRODUCER_LASTNAME_3, RT_CONTACT_PRODUCER, false);
            producer3.Primary__c = true;
            insert new List<Contact>{ producer1A, producer1B, producer2, producer3 };
        }

        List<Id> accounts = new List<Id>{ partner0.Id, partner1.Id, partner2.Id, partner3.Id };
        delete [SELECT Id FROM Referral_Partner__c WHERE Referral_Partner__c IN :accounts];

        client10 = TestFactory.createAccountClient(NAME_CLIENT_10, partner1.Id, producer1A.Id, '% of CES Payroll', 0.50, 'Terminated', false);
        client11 = TestFactory.createAccountClient(NAME_CLIENT_11, partner1.Id, producer1A.Id, '% of WC Eligible Payroll', 1.11, 'Active', false);
        client12 = TestFactory.createAccountClient(NAME_CLIENT_12, partner1.Id, producer1A.Id, '% of WC Eligible Payroll', 1.11, 'Active', false);
        client13 = TestFactory.createAccountClient(NAME_CLIENT_13, partner1.Id, producer1B.Id, '% of WC Eligible Payroll', 1.11, 'Pending', false);
        client21 = TestFactory.createAccountClient(NAME_CLIENT_21, partner2.Id, producer2.Id, '% of Margin', 2.22, 'Active', false);
        client22 = TestFactory.createAccountClient(NAME_CLIENT_22, partner2.Id, producer2.Id, '% of Margin', 2.22, 'Pending', false);
        clientSplit = TestFactory.createAccountClient(NAME_CLIENT_SPLIT, partner2.Id, producer2.Id, '% of Margin', 2.22, 'Active', false);
        clientPrimary = TestFactory.createAccountClient(NAME_CLIENT_Primary, partner1.Id, producer1A.Id, '% of WC Eligible Payroll', 1.11, 'Active', false);
        clientPrimary.Headquarters_State__c = 'CA';
        clientPrimary.BBSI_Benefits__c = true;
        clientPrimary.Referral_Partner_for_Benefits__c = partner1.Id;
      

        insert new List<Account>{ client10, client11, client12, client13, client21, client22, clientSplit, clientPrimary };

        createReferralSources();       
    }

    /**
     * createReferralSources creates the Referral Sources for the Clients and Referral Partners.
     */
    private void createReferralSources() {
        List<Referral_Partner__c> rss = [SELECT Id, Effective_Date__c, Termination_Date__c FROM Referral_Partner__c WHERE Account__c = :clientSplit.Id];

        for (Referral_Partner__c rs : rss) {
            rs.Effective_Date__c = System.today().addDays(-100);
            rs.Termination_Date__c = System.today().addDays(-31);
                    }

        // Make clientSplit a Split Commission client to Partners 1 and 2
        Referral_Partner__c rs1 = new Referral_Partner__c(
            RecordTypeId = ReferralSource_Service.idrtClientRP,
            Account__c = clientSplit.Id,
            Referral_Partner__c = partner1.Id,
            Producer__c = producer1B.Id,
            Referral_Partner_Commission_Type__c = '% of Margin',
            Commission_Rate__c = 8.11,
            Effective_Date__c = System.today().addDays(-30),
            Termination_Date__c = null,
            Hold__c = false,
            Override__c = true,
            Split_Commission__c = true,
            Comments__c = 'Split Commission to Partner 1'
        );
        rss.add(rs1);

        Referral_Partner__c rs2 = new Referral_Partner__c(
            RecordTypeId = ReferralSource_Service.idrtClientRP,
            Account__c = clientSplit.Id,
            Referral_Partner__c = partner2.Id,
            Producer__c = producer2.Id,
            Referral_Partner_Commission_Type__c = '% of Margin',
            Commission_Rate__c = 8.22,
            Effective_Date__c = System.today().addDays(-30),
            Termination_Date__c = null,
            Hold__c = false,
            Override__c = true,
            Split_Commission__c = true,
            Comments__c = 'Split Commission to Partner 2'
        );
        rss.add(rs2);

        upsert rss;
    }

    /**
     * read reads the created data.  Remember to call build() before reading.
     */
    @SuppressWarnings('PMD.CognitiveComplexity')
    public void read() {
        sysAdmin = [SELECT Id FROM User WHERE IsActive = true AND Profile.Name = :Profile_Service.SYSTEM_ADMIN LIMIT 1];

        for (User u : [
            SELECT Id, LastName
            FROM User
            WHERE LastName LIKE 'ReferralSourceUser%'
        ]) {
            if (u.LastName == AMUSER_LASTNAME) { areaManager = u; }
            else if (u.LastName == BDMUSER_LASTNAME) { bdm = u; }
            else if (u.LastName == RPAUSER_LASTNAME) { rpAdmin = u; }
        }

        for (Referral_Partner_Group__c g : [
            SELECT Id, Name, Group_Commission_Type__c, Group_Commission_Rate__c, Description__c
            FROM Referral_Partner_Group__c
        ]) {
            if ( g.Name == NAME_GROUP_1) { group1 = g; }
            else if ( g.Name == NAME_GROUP_2) { group2 = g; }
            else if ( g.Name == NAME_GROUP_3) { group3 = g; }
        }

        for (Account a : [
            SELECT Id, Name, Status__c, Assigned_Referral_Partner__c, Referral_Partner_Status__c, Referral_Partner_Group__c,
            Commission_Type__c, Commission_Rate__c, Hold__c, Hold_Effective_Date__c, Producer__c
            FROM Account
        ]) {
            if (a.Name == BRANCH_NAME) { branch = a; }
            else if (a.Name == NAME_REFERRAL_PARTNER_0) { partner0 = a; }
            else if (a.Name == NAME_REFERRAL_PARTNER_1) { partner1 = a; }
            else if (a.Name == NAME_REFERRAL_PARTNER_2) { partner2 = a; }
            else if (a.Name == NAME_REFERRAL_PARTNER_3) { partner3 = a; }
            else if (a.Name == NAME_CLIENT_10) { client10 = a; }
            else if (a.Name == NAME_CLIENT_11) { client11 = a; }
            else if (a.Name == NAME_CLIENT_12) { client12 = a; }
            else if (a.Name == NAME_CLIENT_13) { client13 = a; }
            else if (a.Name == NAME_CLIENT_21) { client21 = a; }
            else if (a.Name == NAME_CLIENT_22) { client22 = a; }
            else if (a.Name == NAME_CLIENT_SPLIT) { clientSplit = a; }
            else if (a.Name == NAME_CLIENT_Primary) { clientPrimary = a; }
        }

        for (Contact c : [SELECT Id, LastName, Owner.Name, AccountId FROM Contact]) {
            if (c.LastName == BRANCH_DUDE_LASTNAME) { branchDude = c; }
            else if (c.LastName == PRODUCER_LASTNAME_1A) { producer1A = c; }
            else if (c.LastName == PRODUCER_LASTNAME_1B) { producer1B = c; }
            else if (c.LastName == PRODUCER_LASTNAME_2) { producer2 = c; }
            else if (c.LastName == PRODUCER_LASTNAME_3) { producer3 = c; }
        }
    }

    @IsTest
    static void testEnvironment() {
        ReferralPartner_TestEnv testEnv = new ReferralPartner_TestEnv();
        testEnv.build();

        Test.startTest();
        testEnv.read();
        Test.stopTest();

        System.assertNotEquals(null, testEnv.bdm.Id, 'BDM should have been created');
        System.assertNotEquals(null, testEnv.areaManager.Id, 'Area Manager should have been created');
        System.assertNotEquals(null, testEnv.rpAdmin.Id, 'RP Admin should have been created');

        System.assertNotEquals(null, testEnv.branch, 'Branch account should have been created');
        System.assertNotEquals(null, testEnv.partner0, 'Partner 0 should have been created');
        System.assertEquals('Inactive', testEnv.partner0.Status__c, 'Partner 0 should be Inactive');
        System.assertNotEquals(null, testEnv.partner1, 'Partner 1 should have been created');
        System.assertEquals('Active', testEnv.partner1.Status__c, 'Partner 0 should be Active');
        System.assertNotEquals(null, testEnv.partner2, 'Partner 2 should have been created');
        System.assertEquals('Active', testEnv.partner2.Status__c, 'Partner 0 should be Active');
        System.assertNotEquals(null, testEnv.partner3, 'Partner 3 should have been created');
        System.assertEquals('Pending', testEnv.partner3.Status__c, 'Partner 0 should be Pending');

        System.assertNotEquals(null, testEnv.client10, 'Client 10 should have been created');
        System.assertNotEquals(null, testEnv.client11, 'Client 11 should have been created');
        System.assertNotEquals(null, testEnv.client12, 'Client 12 should have been created');
        System.assertNotEquals(null, testEnv.client13, 'Client 13 should have been created');
        System.assertNotEquals(null, testEnv.client21, 'Client 21 should have been created');
        System.assertNotEquals(null, testEnv.client22, 'Client 22 should have been created');
        System.assertNotEquals(null, testEnv.clientPrimary, 'Client Primary should have been created');

        System.assertEquals('Terminated', testEnv.client10.Status__c, 'Client 10 is Terminated');
        System.assertEquals('% of CES Payroll', testEnv.client10.Commission_Type__c, 'Client 10 has commission type: % of CES Payroll');

        System.assertEquals(testEnv.partner1.Id, testEnv.client10.Assigned_Referral_Partner__c, 'Client 10 is assigned to Partner 1');
        System.assertEquals(testEnv.partner1.Id, testEnv.client11.Assigned_Referral_Partner__c, 'Client 11 is assigned to Partner 1');
        System.assertEquals(testEnv.partner1.Id, testEnv.client12.Assigned_Referral_Partner__c, 'Client 12 is assigned to Partner 1');
        System.assertEquals(testEnv.partner1.Id, testEnv.client13.Assigned_Referral_Partner__c, 'Client 13 is assigned to Partner 1');
        System.assertEquals(testEnv.partner2.Id, testEnv.client21.Assigned_Referral_Partner__c, 'Client 21 is assigned to Partner 2');
        System.assertEquals(testEnv.partner2.Id, testEnv.client22.Assigned_Referral_Partner__c, 'Client 22 is assigned to Partner 2');

        Set<Id> idAccounts = new Set<Id>{
            testEnv.branch.Id, testEnv.partner0.Id, testEnv.partner1.Id, testEnv.partner2.Id, testEnv.partner3.Id,testEnv.clientPrimary.Id,
            testEnv.client10.Id, testEnv.client11.Id, testEnv.client12.Id, testEnv.client13.Id, testEnv.client21.Id, testEnv.client22.Id
        };

        Map<Id, List<Referral_Partner__c>> mapRss = ReferralSource_Service.getActiveAccountReferralSources(idAccounts);

        System.assertEquals(0, mapRss.get(testEnv.branch.Id).size(), 'branch should have no Referral Sources');
        System.assertEquals(0, mapRss.get(testEnv.partner0.Id).size(), 'partner0 should have no Referral Sources');
        System.assertEquals(0, mapRss.get(testEnv.partner1.Id).size(), 'partner1 should have no Referral Source');
        System.assertEquals(0, mapRss.get(testEnv.partner2.Id).size(), 'partner2 should have no Referral Source');
        System.assertEquals(0, mapRss.get(testEnv.partner3.Id).size(), 'partner3 should have no Referral Sources');
        System.assertEquals(0, mapRss.get(testEnv.client10.Id).size(), 'client10 should have no Referral Sources');
        System.assertEquals(0, mapRss.get(testEnv.client12.Id).size(), 'client11 should have no Referral Sources');
        System.assertEquals(0, mapRss.get(testEnv.client12.Id).size(), 'client12 should have no Referral Sources');
        System.assertEquals(0, mapRss.get(testEnv.client13.Id).size(), 'client13 should have no Referral Sources');
        System.assertEquals(0, mapRss.get(testEnv.client21.Id).size(), 'client21 should have no Referral Sources');
        System.assertEquals(0, mapRss.get(testEnv.client22.Id).size(), 'client22 should have no Referral Sources');
        System.assertEquals(2, mapRss.get(testEnv.clientSplit.Id).size(), 'clientSplit should have 2 Referral Sources');
        System.assertEquals(0, mapRss.get(testEnv.clientPrimary.Id).size(), 'clientPrimary should have 2 Referral Sources');
    }

    /**
     * assertReferralSource confirms values on a Referral Source
     */
    @SuppressWarnings('PMD.ExcessiveParameterList, PMD.ApexUnitTestMethodShouldHaveIsTestAnnotation')
    public static void assertReferralSource(
        String text, Referral_Partner__c rs, Id idAccount, Id idRP, Boolean onHold, Boolean onHoldRP, String holdReason,
        Boolean isOverride, String commType, Decimal commRate, Date dateStart, Date dateEnd
    ) {
        System.assertEquals(idAccount, rs.Account__c, 'Wrong Account__c value.');
        System.assertEquals(idRP, rs.Referral_Partner__c, 'Wrong Referral_Partner__c value.');
        System.assertEquals(onHold, rs.Hold__c, 'Wrong Hold__c value.');
        System.assertEquals(onHoldRP, rs.RP_on_Hold__c, 'Wrong RP_on_Hold__c value.');
        System.assertEquals(holdReason, rs.Hold_Reason__c, 'Wrong Hold_Reason__c value.');
        System.assertEquals(isOverride, rs.Override__c, 'Wrong Override__c value.');
        System.assertEquals(commRate, rs.Commission_Rate__c, 'Wrong Commission_Rate__c value.');
        System.assertEquals(commType, rs.Referral_Partner_Commission_Type__c, 'Wrong Commission_Type__c value.');
        System.assertEquals(dateStart, rs.Effective_Date__c, 'Wrong Effective_Date__c value.');
        System.assertEquals(dateEnd, rs.Termination_Date__c, 'Wrong Termination_Date__c value.');
    }

    /**
     * assertReferralPartnerRequest confirms values on a Referral Partner Change Request
     */
    @SuppressWarnings('PMD.ExcessiveParameterList, PMD.ApexUnitTestMethodShouldHaveIsTestAnnotation')
    public static void assertReferralPartnerRequest(
        String text, Referral_Partner_Change_Request__c rpcr, String type, String status, Id idClient, Id idRP, Id idProducer,
        Boolean isOverride, String commType, Decimal commRate, Date dateStart, Date dateApproval
    ) {
        System.assertEquals(type, rpcr.Record_Type__c, 'Wrong Record_Type__c value ' + text);
        System.assertEquals(idClient, rpcr.Client__c, 'Wrong Client__c value ' + text);
        System.assertEquals(idRP, rpcr.Referral_Partner__c, 'Wrong Referral_Partner__c value ' + text);
        System.assertEquals(idProducer, rpcr.Producer__c, 'Wrong Producer__c value ' + text);
        System.assertEquals(isOverride, rpcr.Override__c, 'Wrong Override__c value ' + text);
        System.assertEquals(commType, rpcr.Commission_Type__c, 'Wrong Commission_Type__c value ' + text);
        System.assertEquals(commRate, rpcr.Commission_Rate__c, 'Wrong Commission_Rate__c value ' + text);
        System.assertEquals(dateStart, rpcr.Effective_Date__c, 'Wrong Effective_Date__c value ' + text);
        System.assertEquals(dateApproval, rpcr.Approval_Date__c, 'Wrong Approval_Date__c value ' + text);
    }


    @SuppressWarnings('PMD.AvoidSystemDebugUsage')
    public void dumpAccounts() {
        System.debug(LoggingLevel.DEBUG,'dumpAccounts -------------------------------------------');
        System.debug(LoggingLevel.DEBUG,'. ' + partner0.Id + '  ' + partner0.Name + '  ');
        System.debug(LoggingLevel.DEBUG,'. ' + partner1.Id + '  ' + partner1.Name + '  ');
        System.debug(LoggingLevel.DEBUG,'. ' + partner2.Id + '  ' + partner2.Name + '  ');
        System.debug(LoggingLevel.DEBUG,'. ' + partner3.Id + '  ' + partner3.Name + '  ');
        System.debug(LoggingLevel.DEBUG,'. ' + client10.Id + '  ' + client10.Name + '  ');
        System.debug(LoggingLevel.DEBUG,'. ' + client11.Id + '  ' + client11.Name + '  ');
        System.debug(LoggingLevel.DEBUG,'. ' + client12.Id + '  ' + client12.Name + '  ');
        System.debug(LoggingLevel.DEBUG,'. ' + client13.Id + '  ' + client13.Name + '  ');
        System.debug(LoggingLevel.DEBUG,'. ' + client21.Id + '  ' + client21.Name + '  ');
        System.debug(LoggingLevel.DEBUG,'. ' + client22.Id + '  ' + client22.Name + '  ');
        System.debug(LoggingLevel.DEBUG,'. ' + clientSplit.Id + '  ' + clientSplit.Name + '  ');
        System.debug(LoggingLevel.DEBUG,'. ' + clientPrimary.Id + '  ' + clientPrimary.Name + '  ');
    }

}