/**
 * @description PricingScenarioCloneDirector
 */
public without sharing class PricingScenarioCloneDirector {
	private PricingScenario__c m_oldPricingScenario;
	private PricingScenario__c m_newPricingScenario;

	private final Boolean PRESERVEID = false;
	private final Boolean ISDEEPCLONE = true;
	private final Boolean PRESERVEREADONLYTIMESTAMPS = false;
	private final Boolean PRESERVEAUTONUMBER = false;

	public PricingScenarioCloneDirector() { }

	public Boolean CloneScenario(String OldPricingScenarioName, String NewPricingScenarioName, Id RenewalId) {
		// New query to ensure we have ALL fields for cloning
		try {
			PricingScenario__c[] pricingScenarioSource = [
				SELECT Id, CreatedDate__c, FEIN__c, LastModifiedDate__c, Renewal__c, ScenarioName__c, Status__c,
				(
					SELECT Id, BDM__c, BDM_Rate__c, BDM_Basis__c, ClientId__c, ClientName__c, Published_Xmod__c,
							ReferralPartner__c, ReferralPartnerRate__c, Xmod__c, commAcronym__c, commCompany__c, commRate__c, commType__c,
							commBasis__c, commBlendedFactor__c, commChksInPeriod__c, commWeeksInPeriod__c
					FROM ClientPricingScenarios__r
				)
				FROM PricingScenario__c
				WHERE Renewal__c = :RenewalId AND ScenarioName__c = :OldPricingScenarioName
			];

			if (pricingScenarioSource.size() > 0) {
				return CloneAll(pricingScenarioSource[0], NewPricingScenarioName);
			}
		} catch (Exception e) {
			System.debug(LoggingLevel.ERROR, 'Pricing Scenario Clone Director - Constructor failed');
			throw new RenewalException('An unexpected error occurred when creating a Pricing Scenario Clone: ' + NewPricingScenarioName, e);
		}

		return false;
	}

	public Boolean CloneScenario(PricingScenario__c OldPricingScenario, String NewPricingScenarioName) {
		// New query to ensure we have ALL fields for cloning
		try {
			PricingScenario__c[] pricingScenarioSource = [
					SELECT Id, CreatedDate__c, LastModifiedDate__c, Renewal__c, ScenarioName__c, Status__c,
					(
							SELECT Id, PricingScenario__c, BDM_Basis__c, BDM_Rate_Renewal__c, BDM_Rate__c, BDM__c,
									ClientId__c, ClientName__c, Published_Xmod__c, ReferralPartnerRate__c, ReferralPartner__c,
									Xmod__c, commAcronym__c, commBasis__c, commBlendedFactor__c, commChksInPeriod__c, commCompany__c,
									commRateRenewal__c, commRate__c, commType__c, commWeeksInPeriod__c, rsumBilling__c, rsumCommsBdm__c,
									rsumComms__c, rsumErTaxes__c, rsumExpenses__c, rsumMargin__c, rsumMaxSI__c, rsumPayroll__c,
									rsumWcPrem__c, ysumBilling__c, ysumCommsBdm__c, ysumComms__c, ysumErTaxes__c, ysumExpenses__c,
									ysumMargin__c, ysumMaxSI__c, ysumPayroll__c, ysumWcPrem__c, projectionFactor__c
							FROM ClientPricingScenarios__r
					)
					FROM PricingScenario__c
					WHERE Id = :OldPricingScenario.Id
			];

			if (pricingScenarioSource.size() > 0) {
				return CloneAll(pricingScenarioSource[0], NewPricingScenarioName);
			}
		} catch (Exception e) {
			System.debug(LoggingLevel.ERROR, 'Pricing Scenario Clone Director - Constructor failed');
			throw new RenewalException('An unexpected error ocurred when creating a Pricing Scenario Clone: ' + NewPricingScenarioName, e);
		}

		return false;
	}

	private Boolean CloneAll(PricingScenario__c oldPricingScenario, String newPricingScenarioName) {
		if (!PricingScenarioCloneDirector.IsNameUnique(newPricingScenarioName, oldPricingScenario.Renewal__c)) {
			Log.info('Clone', 'Clone All', 'Name is not unique ' + newPricingScenarioName);
			return false;
		}

		Boolean result = false;
		try {
			// create Pricing Scenario parent object
			m_oldPricingScenario = oldPricingScenario;
			m_newPricingScenario = m_oldPricingScenario.clone(PRESERVEID, ISDEEPCLONE, PRESERVEREADONLYTIMESTAMPS, PRESERVEAUTONUMBER);

			m_newPricingScenario.ScenarioName__c = newPricingScenarioName;
			m_newPricingScenario.CreatedDate__c = Datetime.now();
			m_newPricingScenario.LastModifiedDate__c = m_newPricingScenario.CreatedDate__c;

			insert m_newPricingScenario;
			if (m_newPricingScenario.Id != null) {
				result = CloneClientScenarios();
			}
		} catch (Exception e) {
			System.debug(LoggingLevel.ERROR, 'Pricing Scenario Clone Director - CloneAll failed');
			throw new RenewalException('An unexpected error ocurred during Clone All: ' + NewPricingScenarioName, e);
		}
		return result;
	}

	private Boolean CloneClientScenarios() {
		Map<Id, ClientPricingScenario__c> cpsOrigToCloneMap = new Map<Id, ClientPricingScenario__c>();
		Boolean result = true;

		Log.info('Clone', 'Clone Client Scenarios', 'ClientPricingScenario Count: ' + m_oldPricingScenario.ClientPricingScenarios__r.size());

		try {
			List<ClientPricingScenario__c> cpsList = [
				SELECT  Id, PricingScenario__c, BDM_Basis__c, BDM_Rate_Renewal__c, BDM_Rate__c, BDM__c,
						ClientId__c, ClientName__c, commAcronym__c, commBasis__c, commBlendedFactor__c, commChksInPeriod__c,
						commCompany__c, commRateRenewal__c, commRate__c, commType__c, commWeeksInPeriod__c,
						HasBdm__c, HasReferralPartner__c,
						IsProspect__c, Opportunity__c, Published_Xmod__c, projectionFactor__c,
						ReferralPartnerRate__c, ReferralPartner__c, rsumBilling__c, rsumCommsBdm__c, rsumComms__c,
						rsumErTaxes__c, rsumExpenses__c, rsumMargin__c, rsumMaxSI__c, rsumPayroll__c, rsumWcPrem__c,
						Xmod__c, ysumBilling__c, ysumCommsBdm__c, ysumComms__c, ysumErTaxes__c, ysumExpenses__c,
						ysumMargin__c, ysumMaxSI__c, ysumPayroll__c, ysumWcPrem__c
				FROM ClientPricingScenario__c
				WHERE PricingScenario__c = :m_oldPricingScenario.Id
			];

			for (ClientPricingScenario__c cpsOrig : cpsList) {
				ClientPricingScenario__c cpsClone = cpsOrig.clone(PRESERVEID, ISDEEPCLONE, PRESERVEREADONLYTIMESTAMPS, PRESERVEAUTONUMBER);
				cpsClone.PricingScenario__c = m_newPricingScenario.Id;
				cpsOrigToCloneMap.put(cpsOrig.Id, cpsClone);
			}

			Database.SaveResult[] srList = Database.insert(cpsOrigToCloneMap.values(), false);
			Log.writeIfError('Pricing', 'Failed ClientPricingScenario__c Clone Items', null, srList);

			// Clone child objects
			for (Id cpsOrigId : cpsOrigToCloneMap.keySet()) {
				Id cpsOrigToCloneMapId = cpsOrigToCloneMap.get(cpsOrigId).Id;
				result = result && CloneErPayrollTaxes(cpsOrigId, cpsOrigToCloneMapId);
				result = result && CloneExpenses(cpsOrigId, cpsOrigToCloneMapId);
				result = result && CloneXmods(cpsOrigId, cpsOrigToCloneMapId);
				result = result && CloneEmployeesAndCodes(cpsOrigId, cpsOrigToCloneMapId);
				result = result && ClonePricingSummaryHistory(cpsOrigId, cpsOrigToCloneMapId);
				result = result && CloneClientInvestment(cpsOrigId, cpsOrigToCloneMapId);
				result &= CloneTemplateWcCodes(cpsOrigId, cpsOrigToCloneMapId);

				if (result == false) {
					break;
				}
			}
		} catch (Exception e) {
			System.debug(LoggingLevel.ERROR, 'CloneClientScenarios failed');
			throw new RenewalException('An unexpected error occurred when creating a Pricing Scenario Clone');
		}

		return result;
	}

	private Boolean CloneErPayrollTaxes(Id origParentId, Id clonedParentId) {
		List<ERPayrollTax__c> clonedItems = new List<ERPayrollTax__c>();
		Boolean result = true;

		try {
			ERPayrollTax__c[] origItems = [
					SELECT Default_Rate__c, Id, LastModifiedDate, Limit__c, Name, Non_Profit__c, Rate__c, State_Code__c, Tax_Type__c
					FROM ERPayrollTax__c
					WHERE ClientPricingScenario__c = :origParentId
			];

			if (origItems.size() == 0) {
				return result;
			}

			for (ERPayrollTax__c origItem : origItems) {
				ERPayrollTax__c clonedItem = origItem.clone(PRESERVEID, ISDEEPCLONE, PRESERVEREADONLYTIMESTAMPS, PRESERVEAUTONUMBER);
				clonedItem.ClientPricingScenario__c = clonedParentId;
				clonedItems.add(clonedItem);
			}

			Database.SaveResult[] srList = Database.Insert(clonedItems, false);
			for (Database.SaveResult sr : srList) {
				for (Database.Error err : sr.getErrors()) {
					System.debug('Clone Payroll Taxes error: ' + err.getStatusCode() + ': ' + err.getMessage());
					System.debug('Account fields that affected this error: ' + err.getFields());
				}
			}
		} catch (Exception e) {
			System.debug(LoggingLevel.ERROR, 'CloneErPayrollTaxes failed');
			throw new RenewalException('An unexpected error ocurred when cloning ER Taxes', e);
		}

		return result;
	}

	private Boolean CloneExpenses(Id origParentId, Id clonedParentId) {
		List<PricingExpense__c> clonedItems = new List<PricingExpense__c>();
		Boolean result = true;
		try {
			PricingExpense__c[] origItems = [
					SELECT Id, Category__c, Cost_Each__c, Description__c, Quantity__c, Total__c, totalcal__c
					FROM PricingExpense__c
					WHERE ClientPricingScenario__c = :origParentId
			];

			if (origItems.size() == 0) {
				return result;
			}

			for (PricingExpense__c origItem : origItems) {
				PricingExpense__c clonedItem = origItem.clone(PRESERVEID, ISDEEPCLONE, PRESERVEREADONLYTIMESTAMPS, PRESERVEAUTONUMBER);
				clonedItem.ClientPricingScenario__c = clonedParentId;
				clonedItems.add(clonedItem);
			}

			Database.SaveResult[] srList = Database.insert(clonedItems, false);
			Log.writeIfError('Pricing', 'Failed PricingExpense__c Cloned Items', null, srList);
		} catch (Exception e) {
			System.debug('CloneExpenses failed');
			throw new RenewalException('An unexpected error occurred when cloning Expenses');
		}

		return result;
	}

	private Boolean CloneXmods(Id origParentId, Id clonedParentId) {
		List<PricingXmod__c> clonedItems = new List<PricingXmod__c>();
		Boolean result = true;

		try {
			PricingXmod__c[] origItems = [
				SELECT  ClientPricingScenario__c, CreatedDate, Id, IsDeleted, IsPricingXmod__c, IsPublishedXmod__c,
						Name, Published_Xmod__c, State_Code__c, Xmod__c, XmodDate__c, XmodStatus__c, Year__c,
						ClientPricingScenario__r.BureauReportUrl__c
				FROM PricingXmod__c
				WHERE ClientPricingScenario__c = :origParentId
			];

			if (origItems.size() == 0) {
				return result;
			}

			for (PricingXmod__c origItem : origItems) {
				PricingXmod__c clonedItem = origItem.clone(PRESERVEID, ISDEEPCLONE, PRESERVEREADONLYTIMESTAMPS, PRESERVEAUTONUMBER);
				clonedItem.ClientPricingScenario__c = clonedParentId;
				clonedItems.add(clonedItem);
			}

			Database.SaveResult[] srList = Database.insert(clonedItems, false);
			Log.writeIfError('Pricing', 'Failed PricingXmod__c Cloned Items', null, srList);
		} catch (Exception e) {
			System.debug(LoggingLevel.ERROR, 'CloneXmods failed');
			throw new RenewalException('An unexpected error occurred when cloning Xmod values', e);
		}

		return result;
	}

	private Boolean ClonePricingSummaryHistory(Id origParentId, Id clonedParentId) {
		List<PricingSummaryHistory__c> clonedItems = new List<PricingSummaryHistory__c>();
		Boolean result = true;

		try {
			PricingSummaryHistory__c[] origItems = [
				SELECT  BUHours3x__c, BUHours5x__c, FTE__c, Headcount__c, HeadcountAnnual__c, Id,
						MarginPercent__c, MarginPercentPayroll__c, MarginPerHead__c, MarkupPercentage__c, Name,
						PeriodEndDate__c, PeriodStartDate__c, PeriodType__c, PremiumBasedPayroll__c, PremiumBasedPayroll_base__c,
						SortingFormula__c, TotalClaims__c, TotalIncurred__c, Turnover__c, UltimateExpected__c, Xmod__c,
						YendBilling__c, YendBilling_base__c, YendBillingAdjustments__c, YendBillingNet__c,
						YendCommissionPercent__c, YendComms__c, YendCommsBdm__c, YendCommsTotal__c,
						YendErTaxes__c, YendErTaxes_base__c, YendErTaxesNoOwner__c, YendExpenses__c, YendExpenses_Percent__c,
						YendMargin__c, YendMaxSI__c, YendPayroll__c, YendPayroll_base__c, YendPayrollTaxable__c,
						YendPayrollTaxable_base__c, YendPayrollTaxableNoOwner__c, YendTaxBurden_Percent__c,
						YendTaxBurden_PercentNo1k__c, YendWcPrem__c, YendWcPrem_base__c
				FROM PricingSummaryHistory__c
				WHERE ClientPricingScenario__c = :origParentId
			];

			if (origItems.size() == 0) {
				return result;
			}

			for (PricingSummaryHistory__c origItem : origItems) {
				PricingSummaryHistory__c clonedItem = origItem.clone(PRESERVEID, ISDEEPCLONE, PRESERVEREADONLYTIMESTAMPS, PRESERVEAUTONUMBER);
				clonedItem.ClientPricingScenario__c = clonedParentId;
				clonedItems.add(clonedItem);
			}

			Database.SaveResult[] srList = Database.insert(clonedItems, false);
			Log.writeIfError('Pricing', 'Failed PricingSummaryHistory__c Cloned Items', null, srList);
		} catch (Exception e) {
			System.debug(LoggingLevel.ERROR, 'Clone Pricing Summary failed');
			throw new RenewalException('An unexpected error occurred when cloning Pricing Summary', e);
		}

		return result;
	}

	private Boolean CloneEmployeesAndCodes(Id origParentId, Id clonedParentId) {
		Map<Id, PricingEmployee__c> eeOrigToCloneMap = new Map<Id, PricingEmployee__c>();
		Map<Id, PricingWcCode__c> wcOrigToCloneMap = new Map<Id, PricingWcCode__c>();
		Map<PricingEEtoWcCodeAssoc__c, PricingEEtoWcCodeAssoc__c> assocOrigToCloneMap = new Map<PricingEEtoWcCodeAssoc__c, PricingEEtoWcCodeAssoc__c>();

		Boolean result = true;

		try {
			// Clone Employees
			PricingEmployee__c[] origEEs = [
				SELECT  AnnualHours__c, AnnualPay__c, AnnualPremPay__c, AnnualTaxablePay__c, ClientPricingScenario__c,
						ClientPricingScenario__r.projectionFactor__c, CreatedDate, Employee_Name__c, EstimatedERTax__c,
						HourlyRate__c, Id, IsActive__c, IsDeleted, IsUpdate__c, IsOwner__c, LastModifiedDate, Margin_Goal__c, Name,
						Pricing_Group__c, Primary_WC_Code__c, PrimaryPricingWcCode__c, Qty__c, State_Code__c,
						WcCodeCount__c, (
						SELECT  Id, AnnualHoursInCode__c, AnnualHoursInCode_base__c,
								AnnualPayInCode__c, AnnualPayInCode_base__c,
								AnnualPremPayInCode__c, AnnualPremPayInCode_base__c,
								AnnualTaxablePayInCode__c, AnnualTaxablePayInCode_base__c,
								EstimatedErTaxInCode__c,
								PricingWcCode__c
						FROM PricingEEtoWcCodeAssocs__r
						)
				FROM PricingEmployee__c
				WHERE ClientPricingScenario__c = :origParentId
			];

			if (origEEs.size() == 0) {
				return result;
			}

			for (PricingEmployee__c origEE : origEEs) {
				PricingEmployee__c clonedEE = origEE.clone(PRESERVEID, ISDEEPCLONE, PRESERVEREADONLYTIMESTAMPS, PRESERVEAUTONUMBER);
				clonedEE.ClientPricingScenario__c = clonedParentId;
				eeOrigToCloneMap.put(origEE.Id, clonedEE);
			}

			Database.SaveResult[] srList = Database.insert(eeOrigToCloneMap.values(), false);
			Log.writeIfError('Pricing', 'Failed PricingEmployee__c Cloned Items', null, srList);

			// Clone Work Comp Codes
			PricingWcCode__c[] origWCs = [
				SELECT  AnnualHoursInCode__c, AnnualPayInCode__c, AnnualPremPayInCode__c, AnnualTaxablePayInCode__c,
						ClientPricingScenario__c, DesiredMargin__c, DesiredMarginDollars__c, EstimatedErTaxInCode__c,
						HrpWcSuffix__c, Id, Markup__c, Markup_OverTime__c, Markup_DoubleTime__c,
						Markup_Blended__c, MarkupNo1k__c, Modified_WC_Rate__c, Name,
						PercentOfPayroll__c, Pricing_Group__c, SI_Max__c, SI_Max_Blended__c, SI_Percent_of_Payroll__c,
						SI_Percent_of_Premium__c, SIEligible__c, State_Code__c, WC_Code__c, WC_Rate__c, WcPremiumEquivalent__c,
						WCPremPercentOfPayroll__c, WcPremiumBlended__c, WcPremiumBlendedPercentOfPayroll__c,
						(
						SELECT Id, AnnualHoursInCode__c, AnnualHoursInCode_base__c,
								AnnualPayInCode__c, AnnualPayInCode_base__c,
								AnnualPremPayInCode__c, AnnualPremPayInCode_base__c,
								AnnualTaxablePayInCode__c, AnnualTaxablePayInCode_base__c,
								EstimatedErTaxInCode__c,
								Pricing_Employee__c
						FROM PricingEEtoWcCodeAssocs__r
						)
				FROM PricingWcCode__c
				WHERE ClientPricingScenario__c = :origParentId
			];

			if (origWCs.size() == 0) {
				return result;
			}

			for (PricingWcCode__c origWC : origWCs) {
				PricingWcCode__c clonedWC = origWC.clone(PRESERVEID, ISDEEPCLONE, PRESERVEREADONLYTIMESTAMPS, PRESERVEAUTONUMBER);
				clonedWC.ClientPricingScenario__c = clonedParentId;
				wcOrigToCloneMap.put(origWC.Id, clonedWC);
			}

			srList = Database.insert(wcOrigToCloneMap.values(), false);
			Log.writeIfError('Pricing', 'Failed PricingWcCode__c Cloned Items', null, srList);

			// Clone Junction objects: EE to WC
			List<PricingEEtoWcCodeAssoc__c> clonedItems = new List<PricingEEtoWcCodeAssoc__c>();
			PricingEEtoWcCodeAssoc__c[] origAssocs = [
					SELECT Id, AnnualPayInCode__c, AnnualPayUnit__c, AnnualHoursInCode__c, AnnualTaxablePayInCode__c,
							AnnualPremPayInCode__c, AnnualPayInCode_base__c, AnnualHoursInCode_base__c,
							AnnualPremPayInCode_base__c, AnnualTaxablePayInCode_base__c, AnnualHoursUnit__c,
							EstimatedErTaxInCode__c, Pricing_Employee__c, PricingWcCode__c
					FROM PricingEEtoWcCodeAssoc__c
					WHERE Pricing_Employee__r.Id IN :eeOrigToCloneMap.keySet()
			];

			if (origAssocs.size() == 0) {
				return result;
			}

			for (PricingEEtoWcCodeAssoc__c origAssoc : origAssocs) {
				PricingEEtoWcCodeAssoc__c clonedAssoc = origAssoc.clone(PRESERVEID, ISDEEPCLONE, PRESERVEREADONLYTIMESTAMPS, PRESERVEAUTONUMBER);
				clonedAssoc.Pricing_Employee__c = eeOrigToCloneMap.get(origAssoc.Pricing_Employee__c).Id;
				clonedAssoc.PricingWcCode__c = wcOrigToCloneMap.get(origAssoc.PricingWcCode__c).Id;
				clonedItems.add(clonedAssoc);
			}

			srList = Database.insert(clonedItems, false);
			Log.writeIfError('Pricing', 'Failed PricingEEtoWcCodeAssoc__c Cloned Items', null, srList);

			// Set the PrimaryPricingWcCode for each employee
			EmployeeAndWcBuilder.SetPrimaryWcCodes(eeOrigToCloneMap.values());
		} catch (Exception e) {
			System.debug(LoggingLevel.ERROR, 'CloneEmployeesAndCodes failed');
			throw new RenewalException('An unexpected error ocurred when cloning employees and WC codes', e);
		}

		return result;
	}

	private Boolean CloneClientInvestment(Id origParentId, Id clonedParentId) {
		List<PricingClientInvestment__c> clonedItems = new List<PricingClientInvestment__c>();
		Boolean result = true;

		try {
			PricingClientInvestment__c[] origItems = [
					SELECT  ClientPricingScenario__c, Description__c, Id, LastModifiedDate, Method__c, Rate__c, Total_Cost__c
					FROM PricingClientInvestment__c
					WHERE ClientPricingScenario__c = :origParentId
			];

			if (origItems.size() == 0) {
				return result;
			}

			for (PricingClientInvestment__c origItem : origItems) {
				PricingClientInvestment__c clonedItem = origItem.clone(PRESERVEID, ISDEEPCLONE, PRESERVEREADONLYTIMESTAMPS, PRESERVEAUTONUMBER);
				clonedItem.ClientPricingScenario__c = clonedParentId;
				clonedItems.add(clonedItem);
			}

			Database.SaveResult[] srList = Database.insert(clonedItems, false);
			Log.writeIfError('Pricing', 'Failed PricingClientInvestment__c Cloned Items', null, srList);
		} catch (Exception e) {
			System.debug(LoggingLevel.ERROR, 'CloneClientInvestment failed');
			throw new RenewalException('An unexpected error ocurred when cloning Expenses', e);
		}

		return result;
	}

	private Boolean CloneTemplateWcCodes(Id origParentId, Id clonedParentId) {
		List<PricingTemplateWcCode__c> clonedItems = new List<PricingTemplateWcCode__c>();
		Boolean result = true;
		try {
			PricingTemplateWcCode__c[] origItems = [
				SELECT ClientPricingScenario__c, Name, State_Code__c, WC_Code__c, WC_Rate__c, WC_Description__c
				FROM PricingTemplateWcCode__c
				WHERE ClientPricingScenario__c = :origParentId
			];

			if (origItems.size() == 0) {
				return result;
			}

			for (PricingTemplateWcCode__c origItem : origItems) {
				PricingTemplateWcCode__c clonedItem = origItem.clone(PRESERVEID, ISDEEPCLONE, PRESERVEREADONLYTIMESTAMPS, PRESERVEAUTONUMBER);
				clonedItem.ClientPricingScenario__c = clonedParentId;
				clonedItems.add(clonedItem);
			}

			Database.SaveResult[] srList = Database.insert(clonedItems, false);
			Log.writeIfError('Pricing', 'Failed PricingTemplateWcCode__c Cloned Items', null, srList);
		} catch (Exception e) {
			System.debug(LoggingLevel.ERROR, 'CloneTemplateWcCodes failed');
			throw new RenewalException('An unexpected error ocurred when cloning Template WC Codes', e);
		}

		return result;
	}

	public static Boolean IsNameUnique(String ScenarioName, Id Renewal_Id) {
		return PricingScenarioBuilder.IsNameUnique(ScenarioName, Renewal_Id);
	}
}