public with sharing class ClientPricingScenarioBuilder
{
    private Decimal BDM_RATE = 0;
    private Decimal REF_PART_RATE = 0;
    private Map<String, ClientPricingScenario__c> m_clientPricingScenario_Map;
    private Map<String, PricingScenarioDataModel> m_pricingScenarioDataModel_map;
    private PricingScenario__c m_ps;

    private ClientPricingScenario__c m_cps;
    private String m_clientName;
    private String m_clientId;

    public ClientPricingScenarioBuilder()
    {
        SetDefaultCommissionRateVariables(); // set member variables with commission rates
    }

    public ClientPricingScenario__c BuildClientPricingScenario(PricingScenario__c pricingScenario, PricingScenarioDataModel psDataModel)
    {
        try {
            m_clientId = psDataModel.ClientId;
            m_clientName = GetClientName(m_clientId);

            m_cps = new ClientPricingScenario__c();
            m_cps.PricingScenario__c = pricingScenario.Id;
            m_cps.ClientId__c = m_clientId;
            m_cps.ClientName__c = m_clientName;

            m_cps.YsumBilling__c = psDataModel.BillAmtTotal;
            m_cps.YsumWcPrem__c = psDataModel.WcPremTotal;

            m_cps.YsumPayroll__c = psDataModel.PayrollTotal;
            m_cps.YsumErTaxes__c = psDataModel.TaxesTotal;

            m_cps.YsumMaxSI__c = psDataModel.MaxSITotal;
            m_cps.YsumComms__c = psDataModel.RefPartCommissionTotal;
            m_cps.YsumCommsBdm__c = psDataModel.BdmCommissionTotal;

            // 3/5/18 Issue #682028 the commission expense should be included in the gross margin
            m_cps.YsumMargin__c = psDataModel.MarginTotal - (psDataModel.RefPartCommissionTotal + psDataModel.BdmCommissionTotal);
            m_cps.YsumExpenses__c = 0;

            if (psDataModel.BdmInfo != null) {
                m_cps.BDM__c = psDataModel.BdmInfo.BDMNAME;
            }
            else {
                m_cps.BDM__c = '';
            }

            // User Story #18720: always assign default rate (i.e.: 5%) on the BDM commission
            m_cps.BDM_Rate__c = BDM_RATE;
            m_cps.BDM_Rate_Renewal__c = BDM_RATE;
            m_cps.BDM_Basis__c = psDataModel.MarginTotal;

            Account Client = [
                    SELECT  Assigned_Referral_Partner__c, Assigned_Referral_Partner__r.Name,
                            Assigned_Referral_Partner__r.Commission_Rate__c, Assigned_Referral_Partner__r.Commission_Type__c
                    FROM Account
                    WHERE External_ID__c =: m_clientId
            ];

            Boolean hasReferralPartner = Client != null && Client.Assigned_Referral_Partner__c != null;
            if (hasReferralPartner) {
                Boolean hasRfValidCommission = Client.Assigned_Referral_Partner__r.Commission_Type__c != null &&
                        Client.Assigned_Referral_Partner__r.Commission_Type__c == '% of Work Comp' &&
                        Client.Assigned_Referral_Partner__r.Commission_Rate__c != null;
                m_cps.commRate__c = hasRfValidCommission ? Client.Assigned_Referral_Partner__r.Commission_Rate__c : REF_PART_RATE;
                m_cps.commRateRenewal__c = hasRfValidCommission ? Client.Assigned_Referral_Partner__r.Commission_Rate__c : REF_PART_RATE;
                m_cps.commBasis__c = psDataModel.WcPremTotal;
                m_cps.commAcronym__c = Client.Assigned_Referral_Partner__r.Name;
                m_cps.commCompany__c = Client.Assigned_Referral_Partner__r.Name;
            }
            else {
                m_cps.commRate__c = 0;
                m_cps.commBasis__c = 0;
                m_cps.commRateRenewal__c = 0;
                m_cps.commAcronym__c = '';
                m_cps.commCompany__c = '';
            }

            Database.SaveResult sr = Database.insert(m_cps, false);
			Log.writeIfError('Renewals - ClientPricingScenarioBuilder.BuildClientPricingScenario()', 'Database Insert New Scenarios Failed', null, new List<Database.SaveResult>{ sr });
		} catch(system.Exception e) {
            System.debug(LoggingLevel.ERROR, 'ClientPricingScenarioBuilder Build CPS Exception: ' + e.getMessage() + ' ' + e.getLineNumber());
            throw new RenewalException('An unexpected error occurred while building a Client Pricing Scenario');
        }
        return m_cps;
    }

    public void BuildAssociatedTables(PricingSummaryDataModel pSumDataModel, PricingDataModel prDataModel)
    {
        try
        {
            // Xmod table
            PricingXmodBuilder xmodBuilder = new PricingXmodBuilder(m_cps, pSumDataModel);
            xmodBuilder.GetResult();

            // ER Payroll Taxes
            ErPayrollTaxBuilder taxBuilder = new ErPayrollTaxBuilder(m_cps, prDataModel);
            if(taxBuilder.HasData)
            {
                taxBuilder.GetResult();
            }

            // Pricing Expenses
            PricingExpenseBuilder expenseBuilder = new PricingExpenseBuilder(m_cps);
            expenseBuilder.GetResult();

            // Build Pricing Employees and WC Codes (with Association objects)
            EmployeeAndWcBuilder eeWcBuilder = new EmployeeAndWcBuilder(m_cps, pSumDataModel);
            eeWcBuilder.GetResult();

            // Build Pricing Summary/History Data
            PricingSummaryBuilder pricingSumBuilder = new PricingSummaryBuilder(m_cps, pSumDataModel);
            pricingSumBuilder.GetResult();
        }
        catch(System.Exception e)
        {
            System.debug('ClientPricingScenarioBuilder Assoc Tables Exception: ' + e.getMessage());
            throw new RenewalException('An unexpected error occurred while building Pricing Scenario tables');
        }
    }

    public ClientPricingScenarioBuilder(PricingScenario__c PricingScenario, Id Renewal_Id,
            Map<String, PricingScenarioDataModel> PricingScenarioDataModelMap)
    {
        if (PricingScenario != null && Renewal_Id != null && PricingScenarioDataModelMap != null) {
            try
            {
                this.m_ps = PricingScenario;
                this.m_clientPricingScenario_Map = new Map<String, ClientPricingScenario__c>();
                this.m_pricingScenarioDataModel_map = PricingScenarioDataModelMap;
            }
            catch (System.Exception e)
            {
                System.debug('ClientPricingScenarioBuilder Constructor Exception: ' + e.getMessage());
            }
        }
    }

    public Map<String, ClientPricingScenario__c> GetResult()
    {
        if(m_clientPricingScenario_Map == null) {
            m_clientPricingScenario_Map = new Map<String, ClientPricingScenario__c>();
        }

        if(m_pricingScenarioDataModel_map == null) {
            return m_clientPricingScenario_Map;
        }

        try {
            SetDefaultCommissionRateVariables();

            // Get the client name for each ClientId
            Map<String, String> clientNameMap = new Map<String, String>();

            for (Account client : [SELECT External_ID__c, Name FROM Account WHERE External_ID__c IN :  m_pricingScenarioDataModel_map.keySet()]) {
                clientNameMap.put(client.External_ID__c, client.Name);
            }

            ClientPricingScenario__c myClientScenario;
            PricingScenarioDataModel myPricingScenDataModel;

            m_clientPricingScenario_Map.clear();

            for (String clientId : m_pricingScenarioDataModel_map.keySet()) {
                myClientScenario = new ClientPricingScenario__c();

                myClientScenario.ClientId__c = clientId;
                myClientScenario.ClientName__c = clientNameMap.get(clientId);
                myPricingScenDataModel = m_pricingScenarioDataModel_map.get(clientId);

                // Save contract year-end summary data. Used to compare pricing scenarios with 'last year'

                myClientScenario.ysumBilling__c = myPricingScenDataModel.BillAmtTotal;
                myClientScenario.ysumWcPrem__c = myPricingScenDataModel.WcPremTotal;

                myClientScenario.ysumPayroll__c = myPricingScenDataModel.PayrollTotal;
                myClientScenario.ysumErTaxes__c = myPricingScenDataModel.TaxesTotal;

                myClientScenario.ysumMaxSI__c = myPricingScenDataModel.MaxSITotal;
                myClientScenario.ysumComms__c = myPricingScenDataModel.RefPartCommissionTotal; 	// Ref Partner commissions
                myClientScenario.ysumCommsBdm__c = myPricingScenDataModel.BdmCommissionTotal;	// BDM commissions

                // 3/5/18 Issue #682028 the commission expense should be included in the gross margin
                myClientScenario.ysumMargin__c = myPricingScenDataModel.MarginTotal - (myPricingScenDataModel.RefPartCommissionTotal + myPricingScenDataModel.BdmCommissionTotal);
                myClientScenario.ysumExpenses__c = 0;	// BBSI Service Expenses don't exist yet

                if (myPricingScenDataModel.BdmInfo != null){
                    myClientScenario.BDM__c = myPricingScenDataModel.BdmInfo.BDMNAME;
                } else {
                    myClientScenario.BDM__c = '';
                }

                // User Story #18720: always assign default rate (i.e.: 5%) on the BDM commission
                myClientScenario.BDM_Rate__c = BDM_RATE;
                myClientScenario.BDM_Rate_Renewal__c = BDM_RATE;
                myClientScenario.BDM_Basis__c = myPricingScenDataModel.MarginTotal;

                myClientScenario.PricingScenario__c = m_ps.Id;

                Account Client = [
                        SELECT  External_ID__c,
                                Assigned_Referral_Partner__c,
                                Assigned_Referral_Partner__r.Name,
                                Assigned_Referral_Partner__r.Commission_Rate__c,
                                Assigned_Referral_Partner__r.Commission_Type__c
                        FROM Account
                        WHERE External_ID__c =: clientId
                        LIMIT 1
                ];

                // Referral Partner Rate comes from:
                // if Account's Assigned RP exists and Commission Type is % of Work Comp, use RP commission rate
                // if Account's Asssigned RP exists but Commission Type is not % of Work Comp, use default RP commission rate (i.e.: 11.5%)
                // if Account's Assigned RP does NOT exist, use 0%
                Boolean hasReferralPartner = Client.Assigned_Referral_Partner__c != null;
                if (hasReferralPartner) {
                    Boolean hasRfValidCommission = Client.Assigned_Referral_Partner__r.Commission_Type__c != null &&
                            Client.Assigned_Referral_Partner__r.Commission_Type__c == '% of Work Comp' &&
                            Client.Assigned_Referral_Partner__r.Commission_Rate__c != null;
                    myClientScenario.commRate__c = hasRfValidCommission ? Client.Assigned_Referral_Partner__r.Commission_Rate__c : REF_PART_RATE;
                    myClientScenario.commRateRenewal__c = hasRfValidCommission ? Client.Assigned_Referral_Partner__r.Commission_Rate__c : REF_PART_RATE;
                    myClientScenario.commBasis__c = myPricingScenDataModel.WcPremTotal;
                    myClientScenario.commAcronym__c = Client.Assigned_Referral_Partner__r.Name;
                    myClientScenario.commCompany__c = Client.Assigned_Referral_Partner__r.Name;
                }
                else {
                    myClientScenario.commRate__c = 0;
                    myClientScenario.commBasis__c = 0;
                    myClientScenario.commRateRenewal__c = 0;
                    myClientScenario.commAcronym__c = '';
                    myClientScenario.commCompany__c = '';
                }

                // initialize commission rates for renewal
                myClientScenario.BDM_Rate_Renewal__c = myClientScenario.BDM_Rate__c;
                myClientScenario.commRateRenewal__c = myClientScenario.commRate__c;

                // These four fields are not yet in use
                myClientScenario.commType__c = '';
                myClientScenario.commBlendedFactor__c =  1;
                myClientScenario.commChksInPeriod__c =  0;
                myClientScenario.commWeeksInPeriod__c =  0;

                //AG:TODO remove these two fields
                myClientScenario.ReferralPartnerRate__c = 0;
                myClientScenario.ReferralPartner__c = '';

                myClientScenario.Xmod__c = 0;
                myClientScenario.Published_Xmod__c = 0;			//AG:TODO Get published Xmod

                m_clientPricingScenario_Map.put(clientId, myClientScenario);
            }

            Database.SaveResult[] srList = Database.insert(m_clientPricingScenario_Map.values(), false);
            Log.writeIfError('Renewals - ClientPricingScenarioBuilder.GetResult()', 'Database Insert New Scenarios Failed', null, srList);

        } catch (System.Exception e) {
			Log.error('Renewals - ClientPricingScenarioBuilder.GetResult()', 'Exception: ' + e.getMessage(), null, e);
        }
        return m_clientPricingScenario_Map;
    }

    public String GetClientName(String clientId)
    {
        String clientName = '';

        Account[] clients = [SELECT Name FROM Account WHERE External_ID__c = : clientId];
        if(clients.size() > 0){
            clientName = clients[0].Name;
        }
        return clientName;
    }

    private void SetDefaultCommissionRateVariables()
    {
        try
        {
            CommissionRate__mdt commRates = [SELECT BdmRate__c, RefPartnertRateWC__c FROM CommissionRate__mdt WHERE MasterLabel = 'Default Rates' LIMIT 1];
            if (commRates == null) {
                return;
            }
            BDM_RATE = commRates.BdmRate__c;
            REF_PART_RATE = commRates.RefPartnertRateWC__c;
        }
        catch(System.Exception e)
        {
            System.debug('Default Commission Rate error: (line num ' + e.getLineNumber() + '), ' + e.getMessage());
        }
    }
}