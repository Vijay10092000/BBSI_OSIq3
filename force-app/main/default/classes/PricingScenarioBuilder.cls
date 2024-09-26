public without sharing class PricingScenarioBuilder
{
	private PricingScenario__c m_pricingScenario;
    public Boolean HasData { get { return (m_pricingScenario != null); } }

	public PricingScenarioBuilder()
	{
		// default constructor does nothing
		// Use this constructor with BuildPricingScenario(ScenarioName, Renewal_Id)
	}

	public PricingScenario__c BuildPricingScenario(String ScenarioName, String Renewal_Id)
	{
		PricingScenario__c pricingScenario;
		if (String.isNotBlank(ScenarioName) && String.isNotBlank(Renewal_Id))
		{
			try
			{
				String fein = '';
				Renewal__c[] renewal = [
						SELECT Id, FEIN__c,
						(
								SELECT Id, Client__r.Assigned_Referral_Partner__r.Commission_Rate__c,
										Client__r.Assigned_Referral_Partner_Acronym__c
								FROM RenewalClientAssociations__r
						)
						FROM Renewal__c
						WHERE Id = : Renewal_Id
				];

				if (renewal.size() > 0) {
					fein = renewal[0].FEIN__c;
				}
				Datetime createdDate = Datetime.now();
				pricingScenario = new PricingScenario__c();

				pricingScenario.ScenarioName__c = ScenarioName;
				pricingScenario.CreatedDate__c = createdDate;
				pricingScenario.LastModifiedDate__c = createdDate;
				pricingScenario.Status__c = 'New';
				pricingScenario.FEIN__c = fein;
				pricingScenario.Renewal__c = Renewal_Id;

				// check if scenario name is unique
				if (PricingScenarioBuilder.IsNameUnique(ScenarioName, Renewal_Id)){
					insert pricingScenario;
				} else {
					pricingScenario = null;
				}
			}
			catch (System.Exception e)
			{
				System.debug(e.getMessage());
				throw new RenewalException('An unexpected error ocurred when creating a Pricing Scenario: ' + ScenarioName);
			}
		}
		else
		{
			System.debug('PricingScenarioBuilder not initialized');
			pricingScenario = null;
		}
		return pricingScenario;
	}

	/*
		This constructor has been deprecated - do not use
	*/
	public PricingScenarioBuilder(String ScenarioName, Id Renewal_Id)
	{
		if (String.isNotBlank(ScenarioName) && Renewal_Id != null)
		{
			try
			{
				if (!PricingScenarioBuilder.IsNameUnique(ScenarioName, Renewal_Id)) {
					m_pricingScenario = null;
					return;
				}

				String fein = '';
				Renewal__c[] renewal = [
						SELECT Id, FEIN__c,
						(
								SELECT Id, Client__r.Assigned_Referral_Partner__r.Commission_Rate__c,
										Client__r.Assigned_Referral_Partner_Acronym__c
								FROM RenewalClientAssociations__r
						)
						FROM Renewal__c
						WHERE Id = : Renewal_Id
				];

				if(renewal.size() > 0){
					fein = renewal[0].FEIN__c;
				}

				m_pricingScenario = new PricingScenario__c();
				m_pricingScenario.ScenarioName__c = ScenarioName;
				m_pricingScenario.CreatedDate__c = Datetime.now();
				m_pricingScenario.LastModifiedDate__c = m_pricingScenario.CreatedDate__c;
				m_pricingScenario.Status__c = 'New';
				m_pricingScenario.FEIN__c = fein;
				m_pricingScenario.Renewal__c = Renewal_Id;
				insert m_pricingScenario;
			}
			catch (System.Exception e)
			{
				System.debug(e.getMessage());
			}
		}
		else
		{
			System.debug('PricingScenarioBuilder not initialized');
		}
	}

	/*
		This constructor has been deprecated - do not use
	*/
	public PricingScenario__c GetResult()
	{
		return m_pricingScenario;
	}

	public static Boolean IsNameUnique(String ScenarioName, Id Renewal_Id)
	{
		Integer recCount = [SELECT COUNT() FROM PricingScenario__c
							WHERE ScenarioName__c LIKE :ScenarioName
							AND Renewal__c = :Renewal_Id];

		if(recCount != 0)
		{
			Log.info('Scenario name error', 'Scenario: ' + ScenarioName, null);
		}

		return recCount == 0;
	}

    public static Boolean IsNameUniqueinEdit(String ScenarioName, Id Renewal_Id, Id Scenario_ID)
	{
		Integer recCount = [SELECT COUNT() FROM PricingScenario__c
                            WHERE ScenarioName__c LIKE :ScenarioName
                            AND Renewal__c = :Renewal_Id
                            AND Id != :Scenario_ID];

		if(recCount != 0)
		{
			Log.info('Scenario rename error', 'Scenario: ' + ScenarioName, null);
		}
		else
		{
			Log.info('Scenario Renamed', 'Scenario: ' + ScenarioName, null);
		}
		return recCount == 0;
	}
}