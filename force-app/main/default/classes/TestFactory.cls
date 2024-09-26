/*
 * Test Factory for generating test Recods for
 * running test classes.  Each Method returns
 * one test record.  Parameters are the required
 * fields for each sObject.  As well as a boolean value
 * to determine if an insert is required.
 */
@SuppressWarnings('PMD.ExcessiveParameterList, PMD.ExcessivePublicCount')
@isTest
public class TestFactory {
	public static Integer counter = 0;
	public static Integer externalId = 1000000;

	public static final String EMAIL_DOMAIN = '@bbsitest.zzz';

	/**
	 * @description getCounter increaments and gets the counter Integer.
	 * @return Integer
	 */
	public static Integer getCounter() {
		return ++counter;
	}
    /**
	 * @description getRandom gets the Random Integer.
	 * @return Integer
	 */
	public static Integer getRandom() {
		return Integer.valueof((Math.random() * 100000));
	}
	
	/**
	 * @description nextBranchNumber returns a Branch number different than the previous calls.
	 * @return Branch number (B####)
	 */
	public static String nextBranchNumber() {
		Integer counter = getCounter();

		return 'B' + String.valueOf(counter).leftPad(4, '0');
	}

	/**
	 * @description nextFein returns an External Id different than the previous calls.
	 * @return External Id (99-#######)
	 */
	public static String nextFein() {
		Integer counter = getCounter();

		return '99-' + String.valueOf(counter).leftPad(7, '0');
	}

	/**
	 * @description nextExternalId returns an External Id different than the previous calls.
	 * @return External Id (######)
	 */
	public static String nextExternalId() {       
		Integer randomId = getRandom();
		return String.valueOf(randomId).leftPad(6, '0');
	}

	/**
	 * @description nextPhoneNumber receive a new phone number.  The number
	 * will be different than the previous calls.
	 * @return Valid formated phone number (555-###-####)
	 */
	public static String nextPhoneNumber() {
		Integer counter = getCounter();

		String phone = '555-'+ String.valueOf(counter).leftPad(7, '0');

		return phone.left(7) + '-' + phone.right(4);
	}

	// Deprecated: Replaced with TestFactoryUser.
	//  or TestFactoryUser.makeUser
    public static User createUser(String name, String email, String username, String profile, String branch, Boolean ifInsert) {
        User u = new User(
			Alias = 'standt',
			EmailEncodingKey='UTF-8',
			LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
			TimeZoneSidKey='America/Los_Angeles',
			LastName = name,
			Email = email,
			UserName =  userName,
			ProfileId = Profile_Service.getProfileId(profile),
			Branch_ID__c = branch,
			IsActive = true
		);

        if (ifInsert) {
            insert u;
        }
        return u;
    }

    /**
     * createUser creates a user with given profile.
     * @param  lastName  Last name of the User
     * @param  profile   Profile name
     * @param  branchId  Branch number related to
     * @param  ifInsert Should the User be inserted?
     * @return The created User
     */
	// Deprecated: Replaced with TestFactoryUser.createUser or TestFactoryUser.makeUser
    public static User createUser(String lastName, String profile, String branchId, Boolean ifInsert) {
        String simpleName = lastName.trim().replaceAll('(\\s+)', '_').toLowerCase();
        String email = 'test.' + simpleName.toLowerCase() + '@bbsi.zzz';

        User u = new User(
            IsActive = true,
            Alias = 'Z' + simpleName.left(5).toLowerCase(),
            LastName = lastName,
            Email = email,
            UserName =  email,
            Branch_Id__c = branchId,
            Title = profile,
			ProfileId = Profile_Service.getProfileId(profile),
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles'
        );

        if (ifInsert) {
            insert u;
        }

        return u;
    }

    /**
     * createUserBDM creates a "Business Development Manager" User.
     * @param  lastName Last name of the User
     * @param  acronym  Acronym for the user
     * @param  profile  Profile name
     * @param  branch   Branch number related to
     * @param  ifInsert Should the User be inserted?
     * @return The created User
     */
	// Deprecated: Replaced with TestFactoryUser.createBDM or TestFactoryUser.makeBDM
    public static User createUserBDM(String lastName, String acronym, String profile, String branch, Boolean ifInsert) {
        String email = 'Test.' + lastName + '@bbsi.zzz';

        User u = new User(
            IsActive = true,
            Alias = 'Z' + lastName.left(5).toLowerCase(),
            LastName = lastName,
            Email = email,
            UserName =  email,
            Acronym__c = acronym,
            Branch_Id__c = branch,
            Title = 'Business Development Manager',
			ProfileId = Profile_Service.getProfileId(profile),
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            Business_Activity_Report_BDM__c = true
        );

        if (ifInsert) {
            insert u;
        }

        return u;
    }

    /**
     * createUserAM creates an "Area Manager" User.
     * @param  lastName Last name of the User
     * @param  branch   Branch number related to
     * @param  ifInsert Should the User be inserted?
     * @return The created User
     */
	// Deprecated: Replaced with TestFactoryUser.createAreaManager or TestFactoryUser.makeAreaManager
    public static User createUserAM(String lastName, String branch, Boolean ifInsert) {
        String email = 'Test.' + lastName.replace(' ', '_') + '@bbsi.zzz';

        User u = new User(
            IsActive = true,
            Alias = 'T' + lastName.left(5).toLowerCase(),
            LastName = lastName,
            Email = email,
            UserName =  email,
            Branch_Id__c = branch,
            Title = 'Area Manager',
			ProfileId = Profile_Service.getProfileId('Area Manager'),
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles'
        );

        if (ifInsert) {
            insert u;
        }

        return u;
    }

    //Returns an Account record.  Required parameters: Name, ZipCode
	// DEPRECATED: Replaced with TestFactoryAccount.createAccount or TestFactoryAccount.makeAccount
    public static Account createAccount(String name, String zipCode, String recordType, Boolean ifInsert) {
        Id recordTypeId = RecordTypeService.getId('Account', recordType);

		Integer randomId = Integer.valueof((Math.random() * 100000));
		String externalId = String.valueOf(randomId);

        Account a = new Account(
			Name = name,
			External_ID__c = externalId.leftPad(6, '0'),
			BillingStreet = '',
			BillingCity = 'VANCOUVER',
			BillingState = 'WA',
			BillingCountry = 'US',
			BillingPostalCode = zipCode,
			ShippingStreet = '',
			ShippingCity = 'VANCOUVER',
			ShippingState = 'WA',
			ShippingCountry = 'US',
			ShippingPostalCode = zipCode,
			RecordTypeId = recordTypeId,
			Branch_Manager__c = name,
			Client_Benefits_Renewal_Month__c = 'June',
			// Required fields for an opportunity to close
			Customer_Class__c = '2',
			EEO_Reporting__c = 'Yes',
			FEIN__c = '99-9999999',
			Safety_Incentive__c = 'Yes',
			X_Mod__c = '118',
			Credit_Limit__c = 250000.00,
			NumberOFEmployees = 51,
			Annual_Payroll__c = 500000.00,
			Main_Payroll_Frequency__c = 'Weekly',
			Verified__c = true,
			Price_Info__c = '1-CA.0042--20.47\n2-CA.1000--8.50\n3-CA.8742--12.02\n4-CA.8810--11.49\n5-CA.9008--29.77\n6-CA.9009--20.79\n7-CA.8810-MODDUTY-0.00\n7-CA.8810-MODDAYS-0.00\n8-CA.9009-MODDUTY-0.00\n8-CA.9009-MODDAYS-0.00\n9-CA.1000-ERHSA-0.85\n10-CA.1000-ERMED-0.00',
			Safety_Incentive_Info__c = '1000 - 0.0\n8742 - 0.0\n8810 - 0.0\n9008 - 4.0\n9009 - 2.51'
		);

        if (ifInsert) {
            insert a;
        }

        return a;
    }

    //Returns an Account record.
	// Deprecated: Replaced with TestFactoryAccount.createBranch or TestFactoryAccount.makeBranch
    public static Account createAccountBranch(String name, String zipCode, String branchNo, Boolean ifInsert) {
		Account branch = createAccount(name, zipCode, 'BBSI Branch', false);
		branch.External_Id__c = branchNo;

        if (ifInsert) {
            insert branch;
        }

        return branch;
    }

    /**
     * createAccountReferralPartner creates a Referral Partner Account object.
     * @param  name     Name of the Referral Partner Account to create
     * @param  ifInsert Should the account be inserted into the data?
     * @return          The created Account
     */
	// Deprecated: Replaced with TestFactoryAccount.createReferralPartner or TestFactoryAccount.makeReferralPartner
    public static Account createAccountReferralPartner(String name, String status, String type, Decimal rate, Id idGroup, Boolean ifInsert) {
        Account a = createAccount(name, '99999', 'Referral Partner', false);
        a.Status__c = status;
        a.Referral_Partner_Status__c = status;
        a.Commission_Type__c = type;
        a.Commission_Rate__c = rate;
        a.Referral_Partner_Group__c = idGroup;

        if (ifInsert) {
            insert a;
        }

        return a;
    }

    /**
     * createAccountProspect creates a Prospect Account object.
     * @param  name     Name of the Prospect Account to create
     * @param  ifInsert Should the account be inserted into the data?
     * @return          The created Account
     */
	// Deprecated: Replaced with TestFactoryAccount.createProspect or TestFactoryAccount.makeProspect
    public static Account createAccountProspect(String name, Boolean ifInsert) {
        Account a = createAccount(name, '99999', 'Prospect', false);

        if (ifInsert) {
            insert a;
        }

        return a;
    }

    /**
     * createAccountClient creates a Client Account object.
     * @param  name     Name of the Client Account to create
     * @param  ifInsert Should the account be inserted into the data?
     * @return          The created Account
     */
	// Deprecated: Replaced with TestFactoryAccount.createClient or TestFactoryAccount.makeClient
    public static Account createAccountClient(String name, Boolean ifInsert) {
        Account a = createAccount(name, '99999', 'Client', false);

        if (ifInsert) {
            insert a;
        }

        return a;
    }

    /**
     * createAccountClient override of the TestFactory version
     * to add Referral Parnter.
     * @param  name              Name of the Client account
     * @param  idReferralPartner Id of the ReferralPartner. Should not be null.
     * @param  idProducer        Id of the Producer
     * @param  commType              Commission type
     * @param  commRate          Commission rate
     * @param  status            Status of the Client account
     * @return An account object
     */
	// Deprecated: Replaced with TestFactoryAccount.createClient or TestFactoryAccount.makeClient
    public static Account createAccountClient(String name, Id idReferralPartner, Id idProducer, String commType, Decimal commRate, String status, Boolean ifInsert) {
        Account a = createAccount(name, '99999', 'Client', false);
        a.Assigned_Referral_Partner__c = idReferralPartner;
        a.Producer__c = idProducer;
        a.Commission_Type__c = commType;
        a.Commission_Rate__c = commRate;
        a.Status__c = status;

        if (ifInsert) {
            insert a;
        }

        return a;
    }

    //Returns an Account record.  Required parameters: Name, ZipCode
	// Deprecated: Replaced with TestFactoryAccount.createBranch or TestFactoryAccount.makeBranch
    public static Account createAccountBranch(String name, String branchNumber, String areaManager, String areaManagerEmail, Boolean ifInsert) {
        Account a = createAccount(name, '99999', 'BBSI Branch', false);
        a.External_ID__c = branchNumber;
        a.Branch_Manager__c = areaManager;
        a.Branch_Manager_Email__c = areaManagerEmail;

        if (ifInsert) {
            insert a;
        }

        return a;
    }

    /**
     * createBranchAccount create a BBSI Branch account
     * @param  branch           Name of the branch
     * @param  branchNumber     Branch #
     * @param  areaManager      Name of the Area Manager
     * @param  areaManagerEmail Email for the Area Manager
     * @param  ifInsert         true if account should be inserted
     * @return The Account object
     */
	// Deprecated: Replaced with TestFactoryAccount.createBranch or TestFactoryAccount.makeBranch
    public static Account createBranchAccount(String branch, String branchNumber, String areaManager, String areaManagerEmail, Boolean ifInsert) {
        ID recordTypeId = RecordTypeService.getId('Account', 'BBSI Branch');

        Account acc = new Account(
            Name = branch,
            External_ID__c = branchNumber,
            RecordTypeId = recordTypeId,
            Branch_Manager__c = areaManager,
            Branch_Manager_Email__c = areaManagerEmail,
            BillingStreet = '123 Fake Street',
            BillingCity = 'Noware',
            BillingState = 'WA',
            BillingCountry = 'US',
            BillingPostalCode = '99999'
        );

        if (ifInsert) {
            insert acc;
        }

        return acc;
    }

    /**
     * createReferralSourceLead creates a Referral Source (Referral_Partner__c)
     * for a Lead
     * @param  startDate         startDate description.  If null, set to today
     * @param  endDate           endDate description (may be null)
     * @param  idReferralPartner Referral Partner related to Referral Source
     * @param  idLead            Lead related to Referral Source
     * @param  idProducer        Producer related to Referral Source
     * @param  type              Type of commission
     * @param  rate              Rate of commission
     * @param  comments          Any comments
     * @param  ifInsert          true if account should be inserted
     * @return The created Referral Source
     */
    public static Referral_Partner__c createReferralSourceLead(Date startDate, Date endDate, Id idReferralPartner, Id idLead,
                                                                  Id idProducer, String type, Decimal rate, String comments,
                                                                  Boolean ifInsert) {
        if (startDate == null) {
            startDate = System.Today();
        }

        Referral_Partner__c rs = new Referral_Partner__c(
            Account__c = null,
            Lead__c = idLead,
            Referral_Partner__c = idReferralPartner,
            Producer__c = idProducer,
            Effective_Date__c = startDate,
            Termination_Date__c = endDate,
            Referral_Partner_Commission_Type__c = type,
            Commission_Rate__c = rate,
            Comments__c = comments
        );

        if (ifInsert) {
            insert rs;
        }

        return rs;
    }

    /**
     * createReferralSourceClient create a Referral Source (Referral_Partner__c)
     * for a Client Account.
     * @param  startDate         startDate description
     * @param  endDate           endDate description (may be null)
     * @param  idReferralPartner Referral Partner related to Referral Source
     * @param  type              Type of commission
     * @param  rate              Rate of commission
     * @param  comments          Any comments
     * @param  ifInsert          true if account should be inserted
     * @return The created Referral Source
     */
    public static Referral_Partner__c createReferralSourceClient(Date startDate, Date endDate, Id idClient, Id idReferralPartner,
                                                                    String type, Decimal rate, String comments, Boolean ifInsert) {
        if (startDate == null) {
            startDate = System.Today();
        }

        Referral_Partner__c rs = new Referral_Partner__c(
            Account__c = idClient,
            Lead__c = null,
            Referral_Partner__c = idReferralPartner,
            Producer__c = null,
            Effective_Date__c = startDate,
            Termination_Date__c = endDate,
            Referral_Partner_Commission_Type__c = type,
            Commission_Rate__c = rate,
            Comments__c = comments
        );

        if (ifInsert) {
            insert rs;
        }

        return rs;
    }

    /**
     * createReferralSourceReferralPartner create a Referral Source (Referral_Partner__c) for
     * a Referral Partner.
     * @param  startDate         startDate description
     * @param  endDate           endDate description (may be null)
     * @param  idReferralPartner Referral Partner related to Referral Source
     * @param  type              Type of commission
     * @param  rate              Rate of commission
     * @param  comments          Any comments
     * @param  ifInsert          true if account should be inserted
     * @return The created Referral Source
     */
    public static Referral_Partner__c createReferralSourceReferralPartner(Date startDate, Date endDate, Id idReferralPartner,
                                                                            String type, Decimal rate, String comments, Boolean ifInsert) {
        Referral_Partner__c rs = new Referral_Partner__c(
            Account__c = null,
            Lead__c = null,
            Referral_Partner__c = idReferralPartner,
            Producer__c = null,
            Effective_Date__c = startDate,
            Termination_Date__c = endDate,
            Referral_Partner_Commission_Type__c = type,
            Commission_Rate__c = rate,
            Comments__c = comments
        );

        if (ifInsert) {
            insert rs;
        }

        return rs;
    }

    //Returns a Payroll record.  Required parameters: Account Record, Pay Schedule
    public static Payroll__c createPayroll(Account a, String payScheduleId, Boolean ifInsert) {
        Payroll__c p = new Payroll__c();

        p.Name = payscheduleId;
        p.Account__c = a.ID;

        if (ifInsert) {
            insert p;
        }

        return p;
    }


    //list of functions is for selecting which function the contact is for.  Validation rule requires that one be set.
	// Deprecated: Replaced with TestFactoryContact.createContact or TestFactoryContact.makeContact
    public static Contact createContact(Account a, String name, String recordType,  Boolean ifInsert) {
        Contact c = new Contact(
			AccountId = a.ID,
			LastName = name,
			RecordTypeId = RecordTypeService.getId('Contact', recordType),
			Phone = '555-555-5555'
		);

        if (ifInsert) {
            insert c;
        }

        return c;
    }

    /**
	 * @description createClientContact creates a Contact of type Client Contact.
	 * @param  account  Account related to
	 * @param  name     Name for Contact
	 * @param  ifInsert Should Contact be inserted?
	 * @return A Contact
	 */
	// Deprecated: Replaced with TestFactoryContact.createClient or TestFactoryContact.makeClient
    public static Contact createClientContact(Account account, String name, Boolean ifInsert) {
		String email = name + '@fake.zzz';
		email.replace(' ', '_');

        Contact c = new Contact(
			Active__c = true,
			AccountId = account.Id,
			LastName = name,
			RecordTypeId = RecordTypeService.getId('Contact', 'Client Contact'),
			Email = email,
			Phone = '555-555-5555'
		);

        if (ifInsert) {
            insert c;
        }

        return c;
    }

    /**
     * @description createContactEmployee creates an Employee Contact.
     * @param  idUser     Id of User
     * @param  lastname   Last name of User
     * @param  idAccount  Branch Id of User
     * @param  ifInsert   Perform an insert on the contact?
     * @return The created contact
     */
	// Deprecated: Replaced with TestFactoryContact.createEmployee or TestFactoryContact.makeEmployee
    public static Contact createContactEmployee(Id idUser, String lastname, Id idAccount, Boolean ifInsert) {
        Contact c = new Contact(
            User_Id__c = idUser,
            LastName = lastname,
            AccountId = idAccount,
            RecordTypeId = RecordTypeService.getId('Contact', 'BBSI Employee'),
			Phone = '555-555-5555'
        );

        if (ifInsert) {
            insert c;
        }

        return c;
    }

	// Deprecated: Replaced with TestFactoryOpportunity.createClient or TestFactoryOpportunity.makeClient
	public static Opportunity createOpportunity(String name, Account a, Date closeDate, String stage, Boolean ifInsert) {
		return createOpportunityClient(name, a.Id, closeDate, stage, ifInsert);
	}

	// Deprecated: Replaced with TestFactoryOpportunity.createClient or TestFactoryOpportunity.makeClient
	public static Opportunity createOpportunityClient(String name, Id idAccount, Date closeDate, String stage, Boolean ifInsert) {
		Opportunity opp = new Opportunity();

		opp.RecordTypeId = RecordTypeService.getId('Opportunity', 'Client');
		opp.Name = name;
		opp.AccountId = idAccount;
		opp.CloseDate = closeDate;
		opp.StageName = stage;

		if (ifInsert) {
			insert opp;
		}

		return opp;
	}

	// Deprecated: Replaced with TestFactoryOpportunity.createBenefits or TestFactoryOpportunity.makeBenefits
	public static Opportunity createOpportunityBenefits(String name, Id idAccount, Date closeDate, String stage, Boolean ifInsert) {
		Opportunity opp = new Opportunity();

		opp.RecordTypeId = RecordTypeService.getId('Opportunity', 'Benefits');
		opp.Name = name;
		opp.AccountId = idAccount;
		opp.CloseDate = closeDate;
		opp.StageName = stage;

		if (ifInsert) {
			insert opp;
		}

		return opp;
	}
    
    	public static Opportunity opportunityBenefitsRenewal(String name, Id idAccount, Date closeDate, String stage, Boolean ifInsert) {
		Opportunity opp = new Opportunity();

		opp.RecordTypeId=OpportunityBenefits_Service.BenefitsRenewalRT;
		opp.Name = name;
		opp.AccountId = idAccount;
		opp.CloseDate = closeDate;
		opp.StageName = stage;

		if (ifInsert) {
			insert opp;
		}

		return opp;
	}


    //Returns a Enhancement Request.  Required parameters are Name and type
    public static Enhancement_Request__c createEnhancementRequest(String name, String type, Boolean ifInsert) {
        Enhancement_Request__c e = new Enhancement_Request__c();

        e.name = name;
        e.type__c = type;

        if (ifInsert) {
            insert e;
        }

        return e;
    }

    //Returns a User Vote.  Required parameters are an Enhacement Record
    public static User_Votes__c createUserVotes(Enhancement_Request__c e, Boolean ifInsert) {
        User_Votes__c u = new User_Votes__c();

        u.Name = e.Name;
        u.Enhancement_Request__c = e.ID;

        if (ifInsert) {
            insert u;
        }

        return u;

    }

    //Returns a Work Comp Policy Required Paremeters are the Name, TermDate, EffectiveDate
    public static Work_Comp_Policy__c createWorkCompPolicy(String name, Date termDate, Date effectiveDate, Boolean ifInsert) {
        Work_Comp_Policy__c wcp = new Work_Comp_Policy__c();

        wcp.Name = name;
        wcp.Term_Date__c = termDate;
        wcp.Effective_Date__c = effectiveDate;
        wcp.External_ID__c = name;

        if (ifInsert) {
            insert wcp;
        }

        return wcp;
    }

    //Returns a Work Comp Policy Account Required Paremeters are the Name, Account, Work Comp Policy
    public static WorkCompPolicyAccount__c createWorkCompPolicyAccount(String name, Work_Comp_Policy__c wcp, Account a, Boolean ifInsert) {
        WorkCompPolicyAccount__c wcpa = new WorkCompPolicyAccount__c();

        wcpa.Client__c = a.ID;
        wcpa.Work_Comp_Policy__c = wcp.ID;
        wcpa.Name = name;

        if (ifInsert) {
            insert wcpa;
        }

        return wcpa;
    }

    public static CollaborationGroup createCollaborationGroup(String name, String collaborationType, boolean ifInsert) {
        CollaborationGroup cg = new CollaborationGroup();

        cg.name = name;
        cg.CollaborationType = collaborationType;

        if (ifInsert) {
            insert cg;
        }

        return cg;
    }

    public static Business_Blueprint__c createBusinessBlueprint(String name, Account account, String status, boolean ifInsert) {
        Business_Blueprint__c blueprint = new Business_Blueprint__c(
			RecordTypeId = RecordTypeService.getId('Business_Blueprint__c', 'Business_Blueprint'),
			Name = name,
			Client__c = ((account == null) ? null : account.Id),
			Status__c = status
		);

        if (ifInsert) {
            insert blueprint;
        }

        return blueprint;
    }

    public static Producer_Business_Blueprint__c createProducerBusinessBlueprint(String name, Contact contact, Business_Unit__c businessUnit, boolean ifInsert) {
        Producer_Business_Blueprint__c b = new Producer_Business_Blueprint__c();

        b.name = name;
        b.Producer__c = contact.iD;
		b.Business_Unit__c = businessUnit.Id;
        if (ifInsert) {
            insert b;
        }

        return b;
    }

    public static Attachment createAttachment(String name, String body, ID parent, boolean ifInsert) {
        Attachment attach = new Attachment();

        attach.body = Blob.valueOf(body);
        attach.Name = name;
        attach.parentId = parent;

        if (ifInsert) {
            insert attach;
        }

        return attach;
    }

    public static Note createNote(Id idParent, String title, String body, boolean ifInsert) {
        Note note = new Note();

        note.ParentId = idParent;
        note.Title = title;
        note.Body = body;

        if (ifInsert) {
            insert note;
        }

        return note;
    }

    public static Business_Unit__c createBusinessUnit(String name, Account a, boolean ifInsert) {
        Business_Unit__c bu =  new Business_Unit__c();

        bu.name = name;
        bu.BBSI_Branch__c = a.id;

        if (ifInsert) {
            insert bu;
        }

        return bu;
    }

    public static Business_Unit_Member__c createBusinessUnitMember(Business_Unit_Contact__c buc, Account a, Boolean ifInsert) {
        Business_Unit_Member__c bum = new Business_Unit_Member__c();

        bum.Business_Unit_Member__c = buc.ID;
        bum.Client__c = a.ID;

        if (ifInsert) {
            insert bum;
        }

        return bum;
    }

    /**
     * createCase creates a Case object for use in testing.
     */
    public static Case createCase(String subject, Id accountId, Id contactId, String recordType, String category,
                                   String caseType, String subType, String primaryApplication, String scope,
                                   Boolean skipAutomation, Boolean ifInsert) {
        Case c = new Case(
            AccountId = accountId,
            ContactId = contactId,
            Subject = subject,
            RecordTypeId = RecordTypeService.getId('Case', recordType),
            Type = category,
            Type__c = caseType,
            Sub_Type__c = subType,
            Primary_Product__c = primaryApplication,
            Scope__c = scope,
            Skip_Automation__c = skipAutomation
        );

        if (ifInsert) {
            insert c;
        }

        return c;
    }

    public static Business_Unit_Contact__c createBusinessUnitContact(Business_Unit__c bu, boolean active, String role, Contact contactRec, boolean ifInsert) {
        Business_Unit_Contact__c buc = new Business_Unit_Contact__c();

        buc.Active__c = active;
        buc.Role__c = role;
        buc.Business_Unit__c = bu.ID;
        buc.BU_Member__c = contactRec.ID;
        if (active) {
            buc.Active_Date__c = System.Today();
        }
        else {
            buc.Inactive_Date__c = System.Today();
        }

        if (ifInsert) {
            insert buc;
        }

        return buc;
    }

    public static Business_Unit_Contact__c createBusinessUnitContact(Business_Unit__c bu, boolean active, String role, boolean ifInsert) {
        Business_Unit_Contact__c buc = new Business_Unit_Contact__c();

        buc.Active__c = active;
        buc.Role__c = role;
        buc.Business_Unit__c = bu.ID;
        if (active) {
            buc.Active_Date__c = System.Today();
        }
        else {
            buc.Inactive_Date__c = System.Today();
        }

        if (ifInsert) {
            insert buc;
        }

        return buc;
    }

    public static Position__c createPosition(Account branch, Boolean ifInsert) {
        Position__c p = new Position__c();

        p.Branch__c = branch.ID;

        if (ifInsert) {
            insert p;
        }

        return p;
    }

    public static Candidate__c createCandidate(String name, Position__c p, Boolean ifInsert) {
        Candidate__c c = new Candidate__c();
        c.Position__c = p.ID;

        if (ifInsert) {
            insert c;
        }

        return c;
    }

    public static Interview__c createInterview(String name, Candidate__c c, User interviewer, DateTime whenTime, Boolean ifInsert) {
        Interview__c i = new Interview__c();

        i.Name = name;
        i.Candidate__c = c.ID;
        i.Interviewer__c = interviewer.ID;
        i.When__c = whenTime;

        if (ifInsert) {
            insert i;
        }

        return i;
    }

    public static object getFieldValueBySoapType(Schema.SoapType soapType) {
        Map<Schema.SoapType, Object> objectTypes = new map<Schema.SoapType, Object>();

        objectTypes.put(Schema.SoapType.DOUBLE, 100);
        objectTypes.put(Schema.SoapType.STRING, '101');
        objectTypes.put(Schema.SoapType.BOOLEAN, true);
        objectTypes.put(Schema.SoapType.DATE, System.Today());
        objectTypes.put(Schema.SoapType.DATETIME, System.Now());
        objectTypes.put(Schema.SoapType.INTEGER, 200);

        return objectTypes.get(soapType);
    }

    public static Mentor_Group__c createMentorGroup(String name, Boolean ifInsert) {
        List<Mentor_Group__c> mentorGroups = new List<Mentor_Group__c>();
        mentorGroups = createMentorGroups(name, 1, ifInsert);

        return mentorGroups.get(0);
    }

    public static List<Mentor_Group__c> createMentorGroups(String name, Integer numGroups, Boolean ifInsert) {
        List<Mentor_Group__c> mentorGroups = new List<Mentor_Group__c>();

        for(Integer i = 0; i < numGroups; i++) {
            Mentor_Group__c mg = new Mentor_Group__c();
            mg.Name= name + ' ' + i;
            mentorGroups.add(mg);
        }

        if (ifInsert) {
            insert mentorGroups;
        }

        return mentorGroups;
    }

    public static Employee__c createEmployee(String name, Boolean ifInsert) {
        List<Employee__c> employees = new List<Employee__c>();
        employees = createEmployees(name, 1, ifInsert);

        return employees.get(0);
    }

    public static List<Employee__c> createEmployees(String name, Integer numEmployees, Boolean ifInsert) {
        List<Employee__c> employees = new List<Employee__c>();

        for(Integer i = 0; i < numEmployees; i++) {
            Employee__c ee = new Employee__c();
            ee.Name= name + ' ' + i;
            employees.add(ee);
        }

        if (ifInsert) {
            insert employees;
        }

        return employees;
    }

    public static Mentor_Group_Member__c createMentorGroupMember(Id mentorGroupId, Id employeeId, Decimal groupWeight, String groupRole, Boolean ifInsert) {
        Mentor_Group_Member__c mentorGroupMember = new Mentor_Group_Member__c();
        mentorGroupMember.Mentor_Group__c = mentorGroupId;
        mentorGroupMember.Employee__c = employeeId;
        mentorGroupMember.Group_Weight__c = groupWeight;
        mentorGroupMember.Group_Role__c = groupRole;

        if (ifInsert) {
            insert mentorGroupMember;
        }

        return mentorGroupMember;
    }

    /**
     * createDocument creates a ContentDocument for testing
     * @param  title Title of file
     * @param  body  Simple test text
     * @return       The created ContentDocument
     */
    public static ContentDocument createDocument(String title, String body) {
        ContentVersion cv = new ContentVersion(
            Title = title,
            VersionData = Blob.valueOf(body),
            PathOnClient = title + '.txt',
            IsMajorVersion = true
        );

        insert cv;

        return [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument WHERE LatestPublishedVersionId = :cv.Id LIMIT 1];
    }

    /**
     * createReferralPartnerGroup creates a new Referral Partner Group
     * @param  name           Name of the group
     * @param  description    A brief description
     * @param  commissionType commission Type
     * @param  commissionRate Commission Rate
     * @param  ifInsert       Insert the group?
     * @return AReferral_Partner_Group__c
     */
    public static Referral_Partner_Group__c createReferralPartnerGroup(String name, String description, String commissionType, Decimal commissionRate, Boolean ifInsert) {
        Referral_Partner_Group__c rpg = new Referral_Partner_Group__c(
            Name = name,
            Description__c = description,
            Group_Commission_Type__c = commissionType,
            Group_Commission_Rate__c = commissionRate
        );

        if (ifInsert) {
            insert rpg;
        }

        return rpg;
    }

    /**
     * createRPChangeRequest description
     * @param  recordType Type of request to create
     * @param  status     Status of the request
     * @param  idClient   Related Client Account Id
     * @param  idRP       Relate Referral Partner Account Id
     * @param  isOverride Is this an override request?
     * @param  dateStart  Effective date
     * @param  comments   Additional information
     * @param  ifInsert   Insert the group?
     * @return The Referral_Partner_Change_Request__c
     */
    public static Referral_Partner_Change_Request__c createRPChangeRequest(
        String recordType, String status, Id idClient, Id idRP, Boolean isOverride,
        Date dateStart, String comments, Boolean ifInsert
    ) {
        Referral_Partner_Change_Request__c rpcr = new Referral_Partner_Change_Request__c(
            RecordTypeId = RecordTypeService.getId('Referral_Partner_Change_Request__c', recordType),
            Client__c = idClient,
            Referral_Partner__c = idRP,
            Override__c = isOverride,
            Effective_Date__c = dateStart,
            Comments__c = comments,
            Status__c = status
        );

        if (ifInsert) {
            insert rpcr;
        }

        return rpcr;
    }

	public static PermissionSetAssignment createPermissionSetAssignment(Id idUser, String namePS, Boolean ifInsert) {
		Map<String, PermissionSet> mapPSs = PermissionSet_Service.getPermissionSetInfo(new Set<String>{ namePS });

		PermissionSetAssignment psa = new PermissionSetAssignment(
			AssigneeId = idUser,
			PermissionSetId = mapPSs.get(namePS).Id
		);

		if (ifInsert) {
			insert psa;
		}
		return psa;
	}

	public static Group createGroup(String name, Boolean ifInsert) {
		Group g = new Group(
			DeveloperName = name,
			Name = name,
			Type = 'Regular',
			DoesIncludeBosses = false
		);

		if (ifInsert) {
			insert g;
		}
		return g;
	}

	public static GroupMember createGroupMember(Id idUser, Id idGroup, Boolean ifInsert) {
		GroupMember gm= new GroupMember(
			GroupId = idGroup,
			UserOrGroupId = idUser
		);

		if (ifInsert) {
			insert gm;
		}
		return gm;
	}
    /**
     * @description makeBusinessActivityGoal description
     * @param  year       Year of the goal
     * @param  quarter    Quarter (1-4 or 0 for full year)
     * @param  isOverride ???
     * @param  value      Value to put into all the goal fields
     * @param  idBranch   If set, the branch goals, else for BDMs
     * @return A new Business_Activity_Goal__c
     */
	public static Business_Activity_Goal__c makeBusinessActivityGoal(Integer year, Integer quarter, Boolean isOverride, Integer value, Id idBranch) {
		Id idGoalBDM = RecordTypeService.getId('Business_Activity_Goal__c', 'BDM Goal');
		Id idGoalBranch = RecordTypeService.getId('Business_Activity_Goal__c', 'Branch Goal');

		return new Business_Activity_Goal__c(
			RecordTypeId = (idBranch == null) ? idGoalBDM : idGoalBranch,
			Branch__c = idBranch,
			Start_Year__c = String.valueOf(year),
			Start_Quarter__c = 'Quarter ' + quarter,
			Override__c = isOverride,
			Discovery_Meetings__c = value,
			Events__c = value,
			Lost_Clients_Contacted__c = value,
			Lost_Leads_Contacted__c = value,
			New_Clients__c = value,
			New_Leads__c = value,
			New_Referral_Partners_Contacted__c = value,
			Producer_Tracks_Info_Sessions__c = value,
			Referral_Partner_Plans_In_Place__c = value,
			Referral_Partner_Touches__c = value,
			WSE_Added__c = value
		);
	}

	/**
	 * @description createEmailTemplate creates an EmailTemplate with test information.
	 * @param  name     Label of the template
	 * @param  ifInsert insert template?
	 * @return EmailTemplate
	 */
	public static EmailTemplate createEmailTemplate(String name, Boolean ifInsert){
		EmailTemplate template;

		template = new EmailTemplate(
			isActive = true,
			Name = name,
			DeveloperName = 'TestTemplate_' + name,
			TemplateType = 'custom',
			FolderId = UserInfo.getUserId(),
			Subject = 'TEST EMAIL',
			HtmlValue =
				'<!DOCTYPE html><html>' +
				' <head><meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />' +
				'  <meta name="viewport" content="width=device-width, initialscale=1.0" />' +
				'  <meta http-equiv="X-UA-Compatible" content="IE=edge" />' +
				'  <style type="text/css">@media screen and (max-width: 480px) {slot[style] {margin-right: 0 !important;}.columnDiv {margin-right: 0 !important;}}@media screen and (min-width: 480px) {slot[style] {margin-bottom: 0 !important;}.columnDiv {margin-bottom: 0 !important;}}</style>  <style type="text/css">@media screen and (max-width: 480px) {.contentbuilderBaseColumnRow .columnCell {display:inline-block;width:100%}}</style>  <style type="text/css">.contentpageDefaultEmailTemplatePageTemplate .contentRoot {width: 600px;}@media only screen and (max-width: 480px) {.contentpageDefaultEmailTemplatePageTemplate .contentRoot {width: 320px;}}</style>' +
				'  </head> ' +
				' <body>Email To: {{{Recipient.Name}}}</body>' +
				'</html>'
		);

		if (ifInsert) {
			insert template;
		}

		return template;
	}

	/**
	 * @description createOpportunityContactRole description
	 * @param  idContact     Related Contact
	 * @param  IdOpportunity Related Opportunity
	 * @param  isPrimary     Is Contact the primay
	 * @param  role          What role does Contact have
	 * @param  ifInsert      Insert into database?
	 * @return OpportunityContactRole
	 */
	// Deprecated: Replaced with TestFactoryOpportunity.createContactRole or TestFactoryOpportunity.makeContactRole
	public static OpportunityContactRole createOpportunityContactRole(Id idContact, Id idOpportunity, Boolean isPrimary, String role, Boolean ifInsert) {
		OpportunityContactRole template = new OpportunityContactRole(
			ContactId = idContact,
			IsPrimary = isPrimary,
			OpportunityId = IdOpportunity,
			Role = role
		);

		if (ifInsert) {
			insert template;
		}

		return template;
	}

	/**
	 * @description createClientCancellation creates a Client_Cancellation__c object
	 * with default data.
	 * @param  idAccount   Related Account
	 * @param  dateCancel  Date to cancel
	 * @param  status      Status of Approval
	 * @param  ifInsert    Insert into database?
	 * @return Client_Cancellation__c
	 */
	public static Client_Cancellation__c createClientCancellation(Id idAccount, Date dateCancel, String status, Boolean ifInsert) {
        Client_Cancellation__c cancellation =  new Client_Cancellation__c(
			AM_Approval_Status__c = status,
			AM_Comments__c = 'AM_Comments__c',
			Cancellation_decision_due_to_COVID_19__c = 'No',
			Cancellation_Reason__c = 'Cancellation_Reason__c',
			Client__c = idAccount,
			Client_Cancellation_Date__c = dateCancel,
			Consistent_CORE__c = true,
			Contracts_Comments__c = 'Contracts_Comments__c',
			Contracts_Reviewed__c = true,
			Deep_Dive_Completed__c = true,
			Employees_Notified__c = Date.newInstance(2022, 1, 1),
			Explanation__c = 'Explanation__c',
			Had_Blueprint__c = true,
			Improvement__c = 'Improvement__c',
			Last_Check_Date__c = Date.newInstance(2022, 1, 1),
			Last_Core_Visit__c = Date.newInstance(2021, 10, 15),
			Local_ORT_Attendance__c = true,
			Red_Flags__c = 'Red_Flags__c',
			Regular_Meetings__c = true,
			Revoke__c = false,
			Revoked_Reason__c = 'Revoked_Reason__c',
			RP_Alignment__c = 'Excellent',
			RP_Follow_up_Completed__c = true,
			RP_Follow_up_Date__c = Date.newInstance(2021, 1, 1),
			Runoff_Forensic_Report_Attached__c = false,
			Safety_Incentive_Reason__c = 'Safety_Incentive_Reason__c',
			Safety_Incentive_Refund_Request__c = false,
			Security_Deposit_Amount__c = 10000.00,
			Tax_Dept_Archived__c = false,
			Via__c = 'Via__c',
			Where_did_the_business_go__c = 'Payroll Competitor',
			Where_Framework_Failed__c = 'Market',
			Who_Requested_Cancellation__c = 'BBSI'
		);

		 if (ifInsert) {
			 insert cancellation;
		 }

		 return cancellation;
    }

    /**
     * @author: Harpreet Singh
     * @description: This method is for assigning Field values to objects
     * @param  fieldNameValueMapping: contains Test Data
     * @param  obj: test record on which field data should be set
     */
    public static SObject assignFields(Map<String, Object> fieldNameValueMapping, SObject obj) {
        if(fieldNameValueMapping != null && !fieldNameValueMapping.IsEmpty()) {
            for (String key : fieldNameValueMapping.keyset()) {
                obj.put(key, fieldNameValueMapping.get(key));
            }
        }
        return obj;
    }
}