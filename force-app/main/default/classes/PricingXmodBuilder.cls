public without sharing class PricingXmodBuilder {

	private ClientPricingScenario__c m_clientPricingScenario;
	private List<PricingXmod__c> m_pricingXmods;
	private XmodDataModel m_xmodPublishedData;
	private XmodHistoryData m_xmodHistory;

	/*  April 2018 changed source of Xmod History
		Add a list of xmod history to the ClientPricingScenario
		Set ONE Xmod per State Code to use for Pricing

		July 2018 added published Xmod list for California (from Intellicomp API)
	*/

	public PricingXmodBuilder(ClientPricingScenario__c ClientPricingScenario, PricingSummaryDataModel pSumDataModel) {
		if(ClientPricingScenario != null && pSumDataModel.XmodHistory != null) {
			try {
				m_clientPricingScenario = ClientPricingScenario;
				m_xmodHistory = pSumDataModel.XmodHistory;
				m_xmodPublishedData = pSumDataModel.XmodPublishedData;
				m_pricingXmods = new List<PricingXmod__c>();

			} catch (System.Exception e) {
				System.debug(e.getMessage());
			}
		}
	}

	public List<PricingXmod__c> GetResult()
	{
		Map<String, PricingXmod__c> publishedXmodStateMap = new Map<String, PricingXmod__c>();
		Map<String, PricingXmod__c> historyXmodStateMap = new Map<String, PricingXmod__c>();
		Map<String, XmodRecommended__c> recommendedXmodStateMap = new Map<String, XmodRecommended__c>();
		String [] states = new List<String>();
		PricingXmod__c newXmodItem;
		Date xmodDate;
		Boolean hasPubXmods = false;

		for(XmodHistoryData.XmodDetailItem xmodData : m_xmodHistory.XmodDetails) {
			try {
				String[] stringParts = xmodData.ModifiedDate.split(' ');
				String dateOnly = stringParts[0];
				String[] dateParts = dateOnly.split('-');

				Integer year = Integer.valueOf(dateParts[0]);
				Integer month = Integer.valueOf(dateParts[1]);
				Integer day = Integer.valueOf(dateParts[2]);

				xmodDate = Date.newInstance(year, month, day);

				newXmodItem = new PricingXmod__c();
				newXmodItem.ClientPricingScenario__c = m_clientPricingScenario.Id;
				newXmodItem.XmodDate__c = xmodDate;
				newXmodItem.Published_Xmod__c = xmodData.Xmod;
				newXmodItem.Xmod__c = xmodData.Xmod;
				newXmodItem.State_Code__c = xmodData.StateCode;
				newXmodItem.Year__c = xmodData.Year;
				newXmodItem.IsPricingXmod__c = false;
				newXmodItem.IsPublishedXmod__c = false;

				if(!historyXmodStateMap.containsKey(newXmodItem.State_Code__c)) {
					historyXmodStateMap.put(newXmodItem.State_Code__c, newXmodItem);
					states.add(newXmodItem.State_Code__c);
				}
				else if(historyXmodStateMap.get(newXmodItem.State_Code__c).XmodDate__c < newXmodItem.XmodDate__c) {
					historyXmodStateMap.put(newXmodItem.State_Code__c, newXmodItem);
				}

				m_pricingXmods.add(newXmodItem);
			} catch (Exception e) {
				// without a good date value, move on to the next xmodData item
				Log.error('Renewal', 'GetResult', 'XmodHistoryData: Xmod Builder, Xmod date', e);
				continue;
			}
		}

		// Add Published Xmod history if we have it
		if(m_xmodPublishedData != null && m_xmodPublishedData.StatusCode == 200 &&
				m_xmodPublishedData.ExmodData != null && m_xmodPublishedData.ExmodData.ExMods != null){
			for(ExmodsICdata.ExModItem xmodDataPub : m_xmodPublishedData.ExmodData.ExMods){
				try{
					String[] stringParts = xmodDataPub.calc_date.split(' ');
					String dateOnly = stringParts[0];
					String[] dateParts = dateOnly.split('-');

					Integer year = Integer.valueOf(dateParts[0]);
					Integer month = Integer.valueOf(dateParts[1]);
					Integer day = Integer.valueOf(dateParts[2]);

					xmodDate = Date.newInstance(year, month, day);

					newXmodItem = new PricingXmod__c();
					newXmodItem.ClientPricingScenario__c = m_clientPricingScenario.Id;
					newXmodItem.XmodDate__c = xmodDate;
					newXmodItem.Published_Xmod__c = xmodDataPub.Xmod;
					newXmodItem.Xmod__c = xmodDataPub.Xmod;
					newXmodItem.State_Code__c = xmodDataPub.StateCode;
					newXmodItem.Year__c = xmodDataPub.year.format().replaceAll('[,]', '');
					newXmodItem.XmodStatus__c = xmodDataPub.XmodStatus;
					newXmodItem.IsPricingXmod__c = false;
					newXmodItem.IsPublishedXmod__c = true;

					m_pricingXmods.add(newXmodItem);
					if (newXmodItem.Xmod__c != null){
						hasPubXmods = true;

						if(!publishedXmodStateMap.containsKey(newXmodItem.State_Code__c)) {
							publishedXmodStateMap.put(newXmodItem.State_Code__c, newXmodItem);
						}
						else if(publishedXmodStateMap.get(newXmodItem.State_Code__c).XmodDate__c < newXmodItem.XmodDate__c) {
							publishedXmodStateMap.put(newXmodItem.State_Code__c, newXmodItem);
						}
					}
				} catch (Exception e) {
					// without a good date value, move on to the next xmodData item
					Log.error('Renewals - PricingXmodBuilder.GetResult()', 'ExmodsICdata.ExModItem', 'Xmod Builder, Xmod date', e);
					continue;
				}
			}
			// Write Intellicomp URL to the Client Pricing Scenario
			m_clientPricingScenario.BureauReportUrl__c = m_xmodPublishedData.ExmodData.BureauReportUrl;
		}

		XmodRecommended__c[] recommendedXmods = [
				SELECT Xmod__c, Effective_Date__c, State_Code__c, Client_Info__c, Client__c
				FROM XmodRecommended__c
				WHERE Client_Info__c = :m_clientPricingScenario.ClientId__c
		];

		for(XmodRecommended__c x : recommendedXmods) {
			if(!recommendedXmodStateMap.containsKey(x.State_Code__c)) {
				recommendedXmodStateMap.put(x.State_Code__c, x);
			}
			else if(recommendedXmodStateMap.get(x.State_Code__c).Effective_Date__c < x.Effective_Date__c) {
				recommendedXmodStateMap.put(x.State_Code__c, x);
			}
		}

		for(String state : states) {
			if(!historyXmodStateMap.containsKey(state)) {
				continue;
			}

			PricingXmod__c historyXmod = historyXmodStateMap.get(state);
			Boolean hasPublishedXmod = publishedXmodStateMap.containsKey(state);
			Boolean hasRecommendedXmod = recommendedXmodStateMap.containsKey(state);
			newXmodItem = new PricingXmod__c(
					ClientPricingScenario__c = historyXmod.ClientPricingScenario__c,
					State_Code__c = historyXmod.State_Code__c,
					IsPublishedXmod__c = false,
					IsPricingXmod__c = true,
					XmodStatus__c = historyXmod.XmodStatus__c,
					Year__c = '',
					Xmod__c = 1.0,
					XmodDate__c = Date.today().addYears(-10)
			);
			m_pricingXmods.add(newXmodItem);

			// Assign latest year to be one year from today's date because published XMOD's year is one year ahead
			// For example: Published XMOD Effective Date = 9/26/2019, the Year = 2020
			Integer latestYear = Date.today().year() + 1;
			Integer minYear = latestYear - 10;

			while(newXmodItem.Year__c.length() == 0 && latestYear > minYear)
			{
				AssignDefaultXmod(latestYear, newXmodItem, historyXmod, hasPublishedXmod ? publishedXmodStateMap.get(state) : null, hasRecommendedXmod ? recommendedXmodStateMap.get(state) : null);
				latestYear--;
			}
		}

		Database.SaveResult[] srList = Database.insert(m_pricingXmods, false);
		Log.writeIfError('Renewals - PricingXmodBuilder.CreateRenewals()', 'Database Insert new Renewal Failed', null, srList);

		return m_pricingXmods;
	}

	public void AssignDefaultXmod(Integer year, PricingXmod__c newXmodItem, PricingXmod__c historyXmod, PricingXmod__c publishedXmod, XmodRecommended__c recommendedXmod)
	{
		// For the given year (started from today's date's year + 1 - going back to 10 years)
		Boolean hasPublishedXmod = publishedXmod != null && Integer.valueOf(publishedXmod.Year__c) == year;
		Boolean hasRecommendedXmod = recommendedXmod != null && recommendedXmod.Effective_Date__c.year() == year;
		Boolean hasHistoryXmod = historyXmod.XmodDate__c.year() == year;
		// Case 1: if Published XMOD is present (NOT blank), use Published XMOD
		if (hasPublishedXmod)
		{
			newXmodItem.Xmod__c = publishedXmod.Xmod__c;
			newXmodItem.XmodDate__c = publishedXmod.XmodDate__c;
			newXmodItem.Year__c = publishedXmod.Year__c;
		}
		// Case 2: else if Recommended XMOD is present (NOT blank), use Recommended XMOD
		else if (hasRecommendedXmod)
		{
			newXmodItem.Xmod__c = recommendedXmod.Xmod__c;
			newXmodItem.XmodDate__c = recommendedXmod.Effective_Date__c;
			newXmodItem.Year__c = String.valueOf(recommendedXmod.Effective_Date__c.year());
		}
		// Case 3: else if History XMOD is present, use History XMOD
		else if (hasHistoryXmod)
		{
			newXmodItem.Xmod__c = historyXmod.Xmod__c;
			newXmodItem.XmodDate__c = historyXmod.XmodDate__c;
			newXmodItem.Year__c = historyXmod.Year__c;
		}
		else
		{
			return;
		}
	}
}