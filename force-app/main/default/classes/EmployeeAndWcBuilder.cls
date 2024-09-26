public without sharing class EmployeeAndWcBuilder
{
	private ClientPricingScenario__c m_clientPricingScenario;
	private PricingSummaryDataModel m_pricingSummaryModel;

	private List<PricingEmployee__c> m_pricingEmployees;
	private List<PricingWcCode__c> m_pricingWcCodes;
	private List<PricingEEtoWcCodeAssoc__c> m_EEtoWcCodeAssocs;
	// Using a Map to ensure a *unique* set of WC Codes
	private Map<String, PricingWcCode__c> m_uniqueWcCodemap;
	private List<PricingTemplateWcCode__c> m_PricingTemplateWcCodes;
	private String m_ContractYearString = '0';
	private Double m_projFactor = 0;

    public Boolean HasData {
		get
		{
    		return m_clientPricingScenario != null && m_pricingSummaryModel != null;
    	}
    }

	public EmployeeAndWcBuilder(ClientPricingScenario__c ClientPricingScenario, PricingSummaryDataModel PricingSummaryModel) {
		if (ClientPricingScenario != null && PricingSummaryModel != null) {
			try
			{
				m_clientPricingScenario = ClientPricingScenario;
				m_pricingSummaryModel = PricingSummaryModel;
				m_pricingEmployees = new List<PricingEmployee__c>() ;
				m_pricingWcCodes = new List<PricingWcCode__c>();
				m_EEtoWcCodeAssocs = new List<PricingEEtoWcCodeAssoc__c>();
				m_uniqueWcCodemap = new Map<String, PricingWcCode__c>();
				m_ContractYearString = String.valueOf(PricingSummaryModel.EndDate.addDays(-1).year());
				m_PricingTemplateWcCodes = new List<PricingTemplateWcCode__c>();
			}
			catch (System.Exception e)
			{
				String description =
					'ClientPricingScenario: (' + ClientPricingScenario.Id + ')  ' + ClientPricingScenario.Name +
					'\nClient: ' + ClientPricingScenario.ClientName__c +
					'\nClientID: ' + ClientPricingScenario.ClientId__c;

				Log.write(
					Log.Severity.ERROR,
					'Pricing',
					'EmployeeAndWcBuilder constructor',
					description,
					e
				);
				throw new RenewalException('Employee list builder encountered an unexpected error');
			}
		}
		else
		{
			throw new RenewalException('Employee list builder encountered an unexpected initialization error');
		}
	}

	public List<PricingEmployee__c> GetResult()
	{
		if(!this.HasData)
		{
			return new List<PricingEmployee__c>();
		}

		try
		{
			// calculate projection factor
			Integer daysDiff = Datetime.now().date().daysBetween(m_pricingSummaryModel.EndDate);
			m_projFactor = daysDiff > 0 ? (1 + ((Double)daysDiff/365.0)).setScale(2) : 1;

			// Add employees
			PricingEmployee__c pricingEE;
			Map<PayrollHistoryData.PayrollItem, PricingEmployee__c> pricingEEmap = new Map<PayrollHistoryData.PayrollItem, PricingEmployee__c>();

			for (PayrollHistoryData.PayrollItem eeItem : m_pricingSummaryModel.PayrollHistory.Payroll) {
				// We only want records from the current contract year -- no history
				if (eeItem.Year == m_ContractYearString) {
					pricingEE = new PricingEmployee__c(
							ClientPricingScenario__c = m_clientPricingScenario.Id,
							State_Code__c = eeItem.StateCode,
							Employee_Name__c = eeItem.LastName + ', ' + eeItem.FirstName,
							EstimatedERTax__c = eeItem.TotalErTaxes,
							IsActive__c = (eeItem.Active).left(1) == 'A',
							Pricing_Group__c = '',
							PrimaryPricingWcCode__c = null,
							Margin_Goal__c = 0,
							Qty__c = 1
					);
					pricingEE.Primary_WC_Code__c = getPrimaryWcCode(eeItem);
					pricingEE.IsOwner__c = pricingEE.Primary_WC_Code__c == '1000';
					if (pricingEE.State_Code__c == '' && pricingEE.Primary_WC_Code__c == '') {
						continue;
					}
					pricingEEmap.put(eeItem, pricingEE);
				}
			}
			EmployeeAndWcBuilder.insertDatabase(pricingEEmap.values());

			// Add WC codes
			PricingWcCode__c pWcCode;
			String wcKey;
			String wcSuffix;

			for(PayrollHistoryData.PayrollItem eeItem : pricingEEmap.keySet()){
				// For each employee, assemble a list of unique WC/State codes
				if(pricingEEmap.get(eeItem).Id  == null) { continue; }

				for(PayrollHistoryData.WcDetail wcItem : eeItem.WcDetails){
					wcKey = String.format('{0} {1}', new String[]{wcItem.WcCode, wcItem.State});
					wcSuffix = (wcItem.WcCode.length() > 4) ? (wcItem.WcCode.right(wcItem.WcCode.length() - 4)).trim() : '';

					if (!m_uniqueWcCodemap.containsKey(wcKey)) {
						pWcCode = new PricingWcCode__c(
								ClientPricingScenario__c = m_clientPricingScenario.Id,
								Name = wcItem.WcCode + ' ' + wcItem.State,
								SIEligible__c = false,
								SI_Percent_of_Payroll__c = GetSIrate(wcItem.State, wcItem.WcCode),
								SI_Percent_of_Premium__c = 0,
								WC_Code__c = wcItem.WcCode,
								WC_Rate__c = getWcRate(wcItem.State, wcItem.WcCode),
								HrpWcSuffix__c = wcSuffix,
								State_Code__c = wcItem.State,
								DesiredMargin__c = 3,
								DesiredMarginDollars__c = Math.max(.03 * wcItem.PayAmt, 0),
								Markup__c = 0,
								Markup_OverTime__c = 0,
								Markup_DoubleTime__c = 0,
								Markup_Blended__c = 0,
								Pricing_Group__c = '');
						m_uniqueWcCodemap.put(wcKey, pWcCode);
					}
				}
			}

			// Finally, add any WC Codes for this client that were not yet added
			Integer debugCounter = 0;
			for(String wcString : m_pricingSummaryModel.WorkCompCodes) {
				String[] wcStringParts = wcString.split(' ');
				String wcCode = '';
				String stCode = '';
				if(wcStringParts.size() > 1)
				{
					wcCode = wcStringParts[0];
					stCode = wcStringParts[1];
				}

				if(!m_uniqueWcCodemap.containsKey(wcString)) {
					pWcCode = new PricingWcCode__c(
							ClientPricingScenario__c = m_clientPricingScenario.Id,
							Name = wcString,
							SIEligible__c = false,
							SI_Percent_of_Payroll__c = 0,
							SI_Percent_of_Premium__c = 0,
							WC_Code__c = wcCode,
							WC_Rate__c = getWcRate(stCode, wcCode),
							HrpWcSuffix__c = wcSuffix,
							State_Code__c = stCode,
							DesiredMargin__c = 3,
							DesiredMarginDollars__c = 0,
							Markup__c = 0,
							Markup_OverTime__c = 0,
							Markup_DoubleTime__c = 0,
							Markup_Blended__c = 0,
							Pricing_Group__c = '');

					m_uniqueWcCodemap.put(wcString, pWcCode);
					debugCounter ++;
				}
			}

			if (debugCounter > 0) {
				Log.info(
					'Pricing',
					'EmployeeAndWcBuilder.GetResult()',
					'EE and WC Builder \nAddl WC Codes: ' + debugCounter
				);
			}

			EmployeeAndWcBuilder.insertDatabase(m_uniqueWcCodemap.values());

			// Add association objects for Employee + WC Code
			PricingEEtoWcCodeAssoc__c eeToWcObj;
			List<PricingEEtoWcCodeAssoc__c> eeToWcObjectList = new List<PricingEEtoWcCodeAssoc__c>();
			for(PayrollHistoryData.PayrollItem eeItem : pricingEEmap.keySet()){
				// For each employee, create an association with their WC codes
				if(pricingEEmap.get(eeItem).Id  == null){continue;}
				for(PayrollHistoryData.WcDetail wcItem : eeItem.WcDetails){
					wcKey = String.format('{0} {1}', new String[] { wcItem.WcCode, wcItem.State });
					if(m_uniqueWcCodemap.get(wcKey).Id == null){ continue; }
					eeToWcObj = new PricingEEtoWcCodeAssoc__c(
							AnnualPayInCode_base__c = wcItem.PayAmt,
							AnnualPremPayInCode_base__c = wcItem.PremPayAmt,
							AnnualTaxablePayInCode_base__c = wcItem.TaxablePayAmt,
							AnnualHoursInCode_base__c = ((Decimal)wcItem.HoursWorked).setScale(1),
							AnnualPayInCode__c = eeItem.Active == 'A' ? (m_projFactor * (Decimal)wcItem.PayAmt).setScale(2) : wcItem.PayAmt,
							AnnualPremPayInCode__c = eeItem.Active == 'A' ? (m_projFactor * (Decimal)wcItem.PremPayAmt).setScale(2) : wcItem.PremPayAmt,
							AnnualTaxablePayInCode__c = eeItem.Active == 'A' ? (m_projFactor * (Decimal)wcItem.TaxablePayAmt).setScale(2) : wcItem.TaxablePayAmt,
							AnnualHoursInCode__c = eeItem.Active == 'A' ? (m_projFactor * (Decimal)wcItem.HoursWorked).setScale(1) : wcItem.HoursWorked,
							AnnualPayUnit__c = wcItem.PayAmt,
							AnnualHoursUnit__c = wcItem.HoursWorked,
							ActiveEmployeesInCode__c = eeItem.Active == 'A' ? 1 : 0,
							EstimatedErTaxInCode__c = 0,
							Pricing_Employee__c = pricingEEmap.get(eeItem).Id,
							PricingWcCode__c = m_uniqueWcCodemap.get(wcKey).Id,
							TotalEmployeesInCode__c = 1
					);
					eeToWcObjectList.add(eeToWcObj);
				}
			}

			EmployeeAndWcBuilder.insertDatabase(eeToWcObjectList);

			for (WorkCompRatesER.DATA templateWcData : m_pricingSummaryModel.TemplateWorkComps) {
				PricingTemplateWcCode__c templateWcCode = new PricingTemplateWcCode__c(
						ClientPricingScenario__c = m_clientPricingScenario.Id,
						Name = templateWcData.STATE + ' ' + templateWcData.WCCODE + ' ' + templateWcData.WCRATE,
						State_Code__c = templateWcData.STATE,
						WC_Code__c = templateWcData.WCCODE,
						WC_Rate__c = templateWcData.WCRATE.setScale(4),
						WC_Description__c = templateWcData.DESCRIPTION
				);
				m_PricingTemplateWcCodes.add(templateWcCode);
			}

			// Records are added in 200 record blocks.
			Database.executeBatch(new DatabaseInsertBatch(m_PricingTemplateWcCodes, false, 'EmployeeAndWcBuilder', 'Pricing Template WC Codes'), 200);
			//EmployeeAndWcBuilder.insertDatabase(m_PricingTemplateWcCodes);

			EmployeeAndWcBuilder.SetPrimaryWcCodes(pricingEEmap.values());

			m_pricingEmployees = pricingEEmap.values();
		}
		catch (Exception e)
		{
			throw new RenewalException('Employee list builder encountered unexpected errors');
			//m_pricingEmployees = new List<PricingEmployee__c>();
		}
		return m_pricingEmployees;
	}

	/**
	 * @description insertDatabase inserts the list of objects
	 * @param  items Sobject to insert in the database
	 * @return true if fully successful
	 */
	public static Boolean insertDatabase(List<SObject> items){
		Database.SaveResult[] srList = Database.insert(items, false);

		return Log.writeIfError(
			'Pricing',
			'EmployeeAndWcBuilder.insertDatabase',
			'Failed update records',
			srList
		);
	}

	/**
	 * @description updateDatabase updates the list of objects
	 * @param  items Sobject to update in the database
	 * @return true if fully successful
	 */
	public static Boolean updateDatabase(List<SObject> items){
		Database.SaveResult[] srList = Database.update(items, false);

		return Log.writeIfError(
			'Pricing',
			'EmployeeAndWcBuilder.updateDatabase',
			'Failed update records',
			srList
		);
	}

	private String getPrimaryWcCode(PayrollHistoryData.PayrollItem ee) {
		String wcCode = '';
		Decimal payAmt = 0;

		if(ee == null || ee.WcDetails == null)
		{
			return wcCode;
		}

		for (PayrollHistoryData.WcDetail item : ee.WcDetails) {
			if(item.PayAmt > payAmt) { payAmt = item.PayAmt; wcCode = item.WcCode; }
		}

		return wcCode;
	}
    public Decimal getWcRate(String stateCode, String wcCode) {
		Decimal wcRate = 0.0;
		if(m_pricingSummaryModel == null || m_pricingSummaryModel.WorkCompRates == null || m_pricingSummaryModel.WorkCompRates.DATALIST == null)
		{
			return wcRate;
		}

		for(WorkCompRatesER.DATA item : m_pricingSummaryModel.WorkCompRates.DATALIST){
			if (item.STATE == stateCode && item.WCCODE == wcCode) { return item.WCRATE; }
        }
		return wcRate;
    }

	public Boolean IsEligibleForSI(String stateCode, String wcCode) {
		Boolean result = false;
		if(m_pricingSummaryModel == null || m_pricingSummaryModel.WcAndSI == null || m_pricingSummaryModel.WcAndSI.WcSiList == null)
		{
			return result;
		}

		for(WcAndSIdata.WcSiItem item : m_pricingSummaryModel.WcAndSI.WcSiList){
			if(item.StateCode == stateCode && item.WcCode == wcCode){
				return item.IsEligible == 1;
			}
		}
		return result;
	}
	public Double GetSIrate(String stateCode, String wcCode) {
		Double result = 0.0;
		if(m_pricingSummaryModel == null || m_pricingSummaryModel.WcAndSI == null || m_pricingSummaryModel.WcAndSI.WcSiList == null)
		{
			return result;
		}

		for(WcAndSIdata.WcSiItem item : m_pricingSummaryModel.WcAndSI.WcSiList) {
			if(item.StateCode == stateCode && item.WcCode == wcCode){ return item.EligibleRateSI; }
		}
		return result;
	}

	/**
	 * @description SetPrimaryWcCodes retrieves the Pricing WC Code for each employee
	 * @param  employees List of Pricing Employees
	 * @return true if successfully pushed chagnes to database
	 */
    public static Boolean SetPrimaryWcCodes(List<PricingEmployee__c> employees) {
    	List<Id> eeIds = new List<Id>();
    	for(PricingEmployee__c ee : employees){
    		eeIds.add(ee.Id);
    	}
    	PricingEmployee__c[] eeList = [SELECT Id, PrimaryPricingWcCode__c,
    								  (SELECT PricingWcCode__c, AnnualPayInCode__c FROM PricingEEtoWcCodeAssocs__r)
    								   FROM PricingEmployee__c WHERE Id IN : eeIds];
		Decimal tempAmt = 0;
		PricingWcCode__c tempWcCode;
		Id tempId;
		for (PricingEmployee__c ee : eeList) {
			tempAmt = 0;
			tempWcCode = null;
			for (PricingEEtoWcCodeAssoc__c eeAssoc : ee.PricingEEtoWcCodeAssocs__r){
				if (tempAmt < eeAssoc.AnnualPayInCode__c) {
					tempAmt = eeAssoc.AnnualPayInCode__c; tempId = eeAssoc.PricingWcCode__c;
				}
			}
			ee.PrimaryPricingWcCode__c = tempId;
		}

		return EmployeeAndWcBuilder.updateDatabase(eeList);
    }
}