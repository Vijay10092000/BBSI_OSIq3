public without sharing class PricingScenarioBuildDirector {

	private string m_scenarioName;
	private PricingScenario__c m_pricingScenario;
	private Id m_renewal_Id;
	private Boolean inputsValid = false;

	// Map key is Account.External_Id__c
	private Map<String, PricingDataModel> m_pricingModel_map;

	private Map<String, ClientPricingScenario__c> m_clientPricingScenario_map;
	private Map<String, PricingScenarioDataModel> m_pricingScenarioDataModel_map;
	private Map<String, PricingSummaryDataModel> m_pricingSummaryDataModel_map;

	private Map<String, List<ERPayrollTax__c>> m_erPayrollTaxes_map;
	private Map<String, List<PricingExpense__c>> m_pricingExpenses_map;
	private Map<String, List<PricingClientInvestment__c>> m_pricingClientInvestment_map;
	private Map<String, List<PricingEmployee__c>> m_pricingEmployees_map;
	private Map<String, List<PricingXmod__c>> m_pricingXmods_map;


    public Boolean HasData {
    	get{
    		return (m_pricingScenarioDataModel_map != null && m_pricingModel_map != null);
    	}
    }
	public PricingScenario__c PricingScenario {	get { return m_pricingScenario;} }
	public Map<String, ClientPricingScenario__c> ClientPricingScenarioMap { get { return m_clientPricingScenario_map;} }
	public Map<String, List<ERPayrollTax__c>> ErPayrollTaxesMap { get { return m_erPayrollTaxes_map;} }
	public Map<String, List<PricingExpense__c>> PricingExpensesMap { get { return m_pricingExpenses_map;} }
	public Map<String, List<PricingClientInvestment__c>> PricingClientInvestmentMap { get { return m_pricingClientInvestment_map;} }
	public Map<String, List<PricingEmployee__c>> PricingEmployeesMap { get { return m_pricingEmployees_map;} }
	public Map<String, List<PricingXmod__c>> PricingXmodsMap { get { return m_pricingXmods_map;} }

	public PricingScenarioBuildDirector(String ScenarioName, Id Renewal_Id,
					Map<String, PricingDataModel> PricingModelMap,
					Map<String, PricingScenarioDataModel> PricingScenarioDataModelMap,
					Map<String, PricingSummaryDataModel> PricingSummaryDataModelMap) {

		InitializeAll(ScenarioName, Renewal_Id, PricingModelMap, PricingScenarioDataModelMap, PricingSummaryDataModelMap);
	}

	private void InitializeAll(String ScenarioName, Id Renewal_Id, Map<String, PricingDataModel> PricingModelMap,
								Map<String, PricingScenarioDataModel> PricingScenarioDataModelMap,
								Map<String, PricingSummaryDataModel> PricingSummaryDataModelMap) {

		if(String.isBlank(ScenarioName) || Renewal_Id == null ||
				PricingModelMap == null || PricingScenarioDataModelMap == null ){
			this.inputsValid = false;
		} else {
			try {
				this.m_scenarioName = ScenarioName;
				this.m_renewal_Id = Renewal_Id;
				this.m_pricingModel_map = PricingModelMap;
				this.m_pricingScenarioDataModel_map = PricingScenarioDataModelMap;
				this.m_pricingSummaryDataModel_map = PricingSummaryDataModelMap;

				m_erPayrollTaxes_map = new Map<String, List<ERPayrollTax__c>>();
				m_pricingExpenses_map = new Map<String, List<PricingExpense__c>>();
				m_pricingClientInvestment_map = new Map<String, List<PricingClientInvestment__c>>();
				m_pricingEmployees_map = new Map<String, List<PricingEmployee__c>>();
				m_pricingXmods_map = new Map<String, List<PricingXmod__c>>();

				this.inputsValid = true;
			}
			catch (System.Exception e) {
				this.inputsValid = false;
				System.debug(e.getMessage());
			}
		}
	}

	public void BuildAll(){
		if (this.HasData){
			try {
				// Create Pricing and Client Pricing Scenarios
				PricingScenarioBuilder psBuilder = new PricingScenarioBuilder(m_scenarioName, m_renewal_Id);
				m_pricingScenario = psBuilder.GetResult();

				ClientPricingScenarioBuilder cpsBuilder = new ClientPricingScenarioBuilder(m_pricingScenario, m_renewal_Id, m_pricingScenarioDataModel_map);
				m_clientPricingScenario_map = cpsBuilder.GetResult();

				// Create Data Tables for each Client Pricing Scenario
				For(String clientId : m_clientPricingScenario_map.keySet()) {

					ClientPricingScenario__c clpScenario = m_clientPricingScenario_map.get(clientId);

					// Build Xmod table
					PricingXmodBuilder xmodBuilder = new PricingXmodBuilder(clpScenario, m_pricingSummaryDataModel_map.get(clientId));
					List<PricingXmod__c> pricingXmods = xmodBuilder.GetResult();
					m_pricingXmods_map.put(clientId, pricingXmods);

					// Build ER Payroll Taxes
					ErPayrollTaxBuilder taxBuilder = new ErPayrollTaxBuilder(clpScenario, m_pricingModel_map.get(clientId));
					if(taxBuilder.HasData){
						List<ERPayrollTax__c> ptResult = taxBuilder.GetResult();
						m_erPayrollTaxes_map.put(clientId, ptResult);
					}

					// Build Pricing Expenses
					PricingExpenseBuilder expenseBuilder = new PricingExpenseBuilder(clpScenario);
					expenseBuilder.GetResult();

					List<PricingExpense__c> peResult = expenseBuilder.PricingExpenses;
					m_pricingExpenses_map.put(clientId, peResult);

					List<PricingClientInvestment__c> pciResult = expenseBuilder.PricingClientInvestments;
					m_pricingClientInvestment_map.put(clientId, pciResult);

					// Build Pricing Employees and WC Codes (with Association objects)
					EmployeeAndWcBuilder eeWcBuilder = new EmployeeAndWcBuilder(clpScenario, m_pricingSummaryDataModel_map.get(clientId));
					List<PricingEmployee__c> eeResult = eeWcBuilder.GetResult();
					m_pricingEmployees_map.put(clientId, eeResult);

					// Build Pricing Summary/History Data
					PricingSummaryBuilder pricingSumBuilder = new PricingSummaryBuilder(clpScenario, m_pricingSummaryDataModel_map.get(clientId));
					Boolean ret = pricingSumBuilder.GetResult();

				}

				// transfer client xmod data to pricing scenario (the *parent* level, where xmod values should be)
				XmodsToPricingScenario();

				Log.info('New Pricing Scenario', 'Scenario: ' + m_scenarioName, null);
			}
			catch(System.Exception e) {
				System.debug(LoggingLevel.ERROR, 'Build All Exception (line num ' + e.getLineNumber() + '), ' + e.getMessage() + '  ' + e.getTypeName());
			}
		} else {
			system.debug(LoggingLevel.ERROR, 'Pricing Scenario Build Director - Initialization failed');
		}
	}

	private void XmodsToPricingScenario() {

		Map<Date, Map<String, Decimal>> parentXmodMap = new Map<Date, Map<String, Decimal>>();
		Map<String, Decimal> stateValueMap = new Map<String, Decimal>();

		For(string clientId : m_pricingXmods_map.keySet()){
			For(PricingXmod__c pxmod : m_pricingXmods_map.get(clientId)) {
				If(String.isBlank(pxmod.State_Code__c.trim())){
					continue;
				}
				if(parentXmodMap.containsKey(pxmod.XmodDate__c)) {
					if (!parentXmodMap.get(pxmod.XmodDate__c).containsKey(pxmod.State_Code__c)) {
						parentXmodMap.get(pxmod.XmodDate__c).put(pxmod.State_Code__c, pxmod.Published_Xmod__c);
					}

				} else {
					parentXmodMap.put(pxmod.XmodDate__c, new map<String, Decimal>());
					parentXmodMap.get(pxmod.XmodDate__c).put(pxmod.State_Code__c, pxmod.Published_Xmod__c);
				}
			}
		}
		// create PricingScenXmod objects -- the most recent one for each state
		List<PricingScenXmod__c> pricingScenXmods = new List<PricingScenXmod__c>();
		PricingScenXmod__c tempXmod;

		List<Date> keyDatesSorted = new List<Date>(parentXmodMap.keySet());
		keyDatesSorted.sort();
		Set<String> keyStateSet = new Set<String>();
		Date keyDate;
		// starting with tne NEWEST entries first, only add ONE per state
		For (integer i = keyDatesSorted.size() - 1; i >= 0; i-- ) {
			keyDate = keyDatesSorted[i];
			For(String keyState : parentXmodMap.get(keyDate).keySet()) {
				if(!keyStateSet.contains(keyState)) {
					keyStateSet.add(keyState);
					pricingScenXmods.add(new PricingScenXmod__c(
						PricingScenario__c = m_pricingScenario.Id,
						Published_Xmod__c = parentXmodMap.get(keyDate).get(keyState),
						Xmod__c = parentXmodMap.get(keyDate).get(keyState),
						State_Code__c = keyState,
						XmodDate__c = keyDate));
				}
			}
		}

		Database.SaveResult[] srList = Database.insert(pricingScenXmods, false);
		Log.writeIfError('Renewal', 'CreateRenewals', 'Insert new Renewal objects', srList);
	}

	public static Boolean IsNameUnique(String ScenarioName, Id Renewal_Id){

		return PricingScenarioBuilder.IsNameUnique(ScenarioName, Renewal_Id);
	}

}