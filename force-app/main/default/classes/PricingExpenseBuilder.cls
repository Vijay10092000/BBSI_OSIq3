public without sharing class PricingExpenseBuilder
{
	private ClientPricingScenario__c m_clientPricingScenario;
	private List<PricingExpense__c> m_pricingExpenses;
	private List<PricingClientInvestment__c> m_pricingClientInvestments;

	public PricingExpenseBuilder(ClientPricingScenario__c clientPricingScenario)
    {
		if(clientPricingScenario != null)
        {
			try
            {
				m_clientPricingScenario = clientPricingScenario;
				m_pricingExpenses = new List<PricingExpense__c>();
				m_pricingClientInvestments = new List<PricingClientInvestment__c>();
			}
            catch (System.Exception e)
            {
				System.debug(e.getMessage());
			}
        }
	}

	public List<PricingExpense__c> PricingExpenses { get { return m_pricingExpenses; } }
	public List<PricingClientInvestment__c> PricingClientInvestments { get { return m_pricingClientInvestments; } }

	public void GetResult()
	{
		// AG:TODO Replace hard-coded entries (below) with static resource or API call
		m_pricingExpenses.add(CreatePricingExpenseRow('Time Clocks', 'Hardware', 0, 0));
		m_pricingExpenses.add(CreatePricingExpenseRow('Payroll Services/Corporate Support', 'Payroll Processing, W2 and W2Cs', 0, 0));
		m_pricingExpenses.add(CreatePricingExpenseRow('New Employee', 'Drug Testing', 0, 0));
		m_pricingClientInvestments.add(CreatePricingClientInvestmentRow('Client Investment', '% of Payroll', 0.39));

		Database.SaveResult[] srList = Database.insert(m_pricingExpenses, false);
		srList.addAll(Database.insert(m_pricingClientInvestments, false));
		for (Database.SaveResult sr : srList) {
			if (!sr.isSuccess())
			{
				for(Database.Error err : sr.getErrors()) {
					System.debug('The following error has occurred.');
					System.debug(err.getStatusCode() + ': ' + err.getMessage());
					System.debug('Account fields that affected this error: ' + err.getFields());
				}
			}
		}
	}

	private PricingExpense__c CreatePricingExpenseRow(String category, String description, Decimal quantity, Decimal costEach)
    {
		PricingExpense__c item = new PricingExpense__c(
				ClientPricingScenario__c = m_clientPricingScenario.Id,
				Category__c = category,
				Cost_Each__c = costEach,
				Description__c = description,
				Quantity__c = quantity,
				Total__c = costEach * quantity);
		return item;
	}

    private PricingClientInvestment__c CreatePricingClientInvestmentRow(String description, String method, Decimal rate)
    {
        PricingClientInvestment__c item = new PricingClientInvestment__c(
				ClientPricingScenario__c = m_clientPricingScenario.Id,
				Description__c = description,
				Method__c = method,
				Rate__c = rate);
        return item;
    }
}