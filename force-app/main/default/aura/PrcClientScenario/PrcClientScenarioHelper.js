/*
 * Copyright (c) 2018. Barrett Business Services, Inc. All Rights Reserved
 */
({
    loadData: function (cmp, event) {
        this.loadDataCPS(cmp, event);
    },

    loadDataCPS: function (cmp, event) {
        cmp.set("v.isLoading", true);
        let action = cmp.get("c.getClientPricingScenario");
        action.setParams({"recordId": cmp.get("v.recordId")});

        action.setCallback(this, function (data) {
            cmp.set("v.isLoading", false);
            if (data.getState() === "SUCCESS") {
                var cps = data.getReturnValue();
                cmp.set("v.clientPricingScenario", cps);
                cmp.set("v.projFactor", cps.projectionFactor__c);
                cmp.set("v.clientId", cps.ClientId__c);
                cmp.set("v.isProspect", cps.IsProspect__c);
                this.sendIsProspectFlag(cmp);
                this.loadDataSummary(cmp, event);
            } else {
                this.showToast(cmp, "Sorry to interrupt you", "An error occurred while loading the Client Pricing Scenario", "error", "sticky");
            }
        });
        $A.enqueueAction(action);
    },

    loadDataSummary: function (cmp, event) {
        cmp.set("v.isLoading", true);
        let action = cmp.get("c.getPricingSummaryRenewalRow");
        action.setParams({"recordId": cmp.get("v.recordId")});
        action.setCallback(this, function (response) {
            cmp.set("v.isLoading", false);
            if (response.getState() === "SUCCESS") {
                cmp.set("v.renewalSummaryObj", response.getReturnValue());
                this.afterLoadData(cmp, event);
            } else {
                this.showToast(cmp, "Sorry to interrupt you", "An error occurred while loading Renewal Summary data", "error", "sticky");
            }
        });
        $A.enqueueAction(action);
    },

    afterLoadData: function (cmp, event) {
        this.initSummaryTotals(cmp, event);
        this.initPricingDatasets(cmp, event);
        this.dataToChildComponents(cmp, event);
    },

    handleCommissions: function (cmp, event, args) {
        // todo: which type - hasReferralPartner - save args.value 
        // type: hasReferralPartner or hasBdm 
        // 
        
        this.doPricingCommissions(cmp, args);
        this.doPricingMarkup(cmp, null);
        this.doPricingBilling(cmp, null);
        this.doPricingSummary(cmp, null);
        this.saveData(cmp, null);
        this.saveDataWcCodes(cmp, null);
        this.saveDataSummary(cmp, null);
    },

    handleEmployees: function (cmp, event, args) {
        this.doPricingEmployees(cmp, null);
        this.doPricingGrossMarginByWorkCompCode(cmp, null);
        this.doPricingGrossMarginByPercentOfPayroll(cmp, null);
        this.doPricingTaxes(cmp, null);
        this.doPricingWorkCompAndSafetyIncentive(cmp, null);
        this.doPricingCommissions(cmp, null);
        this.doPricingExpenses(cmp, null);
        this.doPricingMarkup(cmp, null);
        this.doPricingBilling(cmp, null);
        this.doPricingSummary(cmp, null);
        this.saveDataEEtoWc(cmp, null);
        this.saveDataWorkComps(cmp, null); //this.saveDataWorkComps includes this.saveDataWcCodes(cmp, null);
        this.saveDataEmployees(cmp, null);
        this.saveDataSummary(cmp, null);
    },

    handleExpenses: function (cmp, event, args) {
        this.doPricingExpenses(cmp, args);
        this.doPricingMarkup(cmp, null);
        this.doPricingBilling(cmp, null);
        this.doPricingSummary(cmp, null);
        this.saveDataWcCodes(cmp, null);
        this.saveDataSummary(cmp, null);
    },

    handleMarkup: function (cmp, event, args) {
        switch(args.type) {
            case "editMarkup":
                this.doPricingMarkupEdit(cmp, null);
                this.doPricingBilling(cmp, null);
                this.doPricingSummary(cmp, null);
                this.saveDataWcCodes(cmp, null);
                this.saveDataSummary(cmp, null);
                break;
            case "editMargin":
                this.doPricingMargin(cmp, args);
                this.doPricingExpenses(cmp, null);
                this.doPricingCommissions(cmp, null);
                this.doPricingMarkup(cmp, null);
                this.doPricingBilling(cmp, null);
                this.doPricingSummary(cmp, null);
                this.saveDataWcCodes(cmp, null);
                this.saveDataSummary(cmp, null);
                break;
        }
    },

    handleTaxRates: function (cmp, event, args) {
        this.doPricingTaxes(cmp, null);
        this.doPricingMarkup(cmp, null);
        this.doPricingBilling(cmp, null);
        this.doPricingSummary(cmp, null);
        this.saveDataClientNonProfit(cmp, args);
        this.saveDataEEtoWc(cmp, null);
        this.saveDataEmployees(cmp, null);
        this.saveDataWcCodes(cmp, null);
        this.saveDataSummary(cmp, null);
    },

    handleWorkComp: function (cmp, event, args) {
        switch(args.type) {
            case "saveWc":
                this.doPricingWorkCompAndSafetyIncentive(cmp, null);
                this.doPricingCommissions(cmp, null);
                this.doPricingExpenses(cmp, null);
                this.doPricingMarkup(cmp, null);
                this.doPricingBilling(cmp, null);
                this.doPricingSummary(cmp, null);
                this.saveDataEEtoWc(cmp, null);
                this.saveDataEmployees(cmp, null);
                this.saveDataWorkComps(cmp, null); //this.saveDataWorkComps includes this.saveDataWcCodes(cmp, null);
                this.saveDataSummary(cmp, null);
                break;
            case "transferWc":
                this.handleEmployees(cmp, event, args);
                break;
            case "addWc":
            case "deleteWc":
                this.sendDataChangeAlert(cmp, "employees");
                break;
        }
    },

    handleXmod: function (cmp, event, args) {
        this.doPricingResetSafetyIncentive(cmp, null);
        this.doPricingWorkCompAndSafetyIncentive(cmp, null);
        this.doPricingCommissions(cmp, null);
        this.doPricingExpenses(cmp, null);
        this.doPricingMarkup(cmp, null);
        this.doPricingBilling(cmp, null);
        this.doPricingSummary(cmp, null);
        this.saveDataEEtoWc(cmp, null);
        this.saveDataEmployees(cmp, null);
        this.saveDataWorkComps(cmp, null); //this.saveDataWorkComps includes this.saveDataWcCodes(cmp, null);
        this.saveDataSummary(cmp, null);
    },

    // loadDataBillingHistories: function (cmp, event, newStateData) {
    //     let action = cmp.get("c.getBillingHistories");
    //     let clientId = cmp.get("v.clientId");
    //     action.setParams({"clientId": clientId});
    //     action.setCallback(this, function(response) {
    //         if(response.getState() === "SUCCESS") {
    //             let rc = new Map();
    //             let priceInfo = response.getReturnValue();
    //             for (let i = 0; i < priceInfo.length; ++i) {
    //                 let wcCode = priceInfo[i].WC_Code__c;
    //                 if (wcCode) {
    //                     currentMarkupWcMap.set(wcCode, wcCode);
    //                 }
    //             }
    //             cmp.set("v.currentMarkupWcMap", currentMarkupWcMap);
    //         }
    //         else {
    //             this.showToast(cmp, "Sorry to interrupt you", "An error occurred while retrieving client's current markups", "error", "sticky");
    //         }
    //     });
    //     $A.enqueueAction(action);
    // },

    // loadDataSafetyIncentives: function (cmp, event, args) {
    //     let action = cmp.get("c.getSafetyIncentiveRates");
    //     let clientId = cmp.get("v.clientId");
    //     action.setParams({"clientId": clientId});
    //     action.setCallback(this, function(response) {
    //         if(response.getState() === "SUCCESS") {
    //             let siRateMap = response.getReturnValue();
    //             cmp.set("v.siRateMap", siRateMap);
    //         }
    //         else {
    //             this.showToast(cmp, "Sorry to interrupt you", "An error occurred while retrieving client's current markups", "error", "sticky");
    //         }
    //     });
    //     $A.enqueueAction(action);
    // },

    loadDataEmployeesAndWorkComps: function (cmp, event, args) {
        let action = cmp.get("c.getPricingWcCodes");
        action.setParams({"recordId": cmp.get("v.recordId")});
        action.setCallback(this, function(response) {
            cmp.set("v.isLoading", false);
            if(response.getState() === "SUCCESS") {
                let dataSet = response.getReturnValue();
                cmp.set("v.prcWorkComps", dataSet);
                this.loadDataEEtoWCassocs(cmp, event, args);
            }});
        $A.enqueueAction(action);
    },

    loadDataEEtoWCassocs: function(cmp, event, args){
        let action = cmp.get("c.getEEtoWcCodeAssocs");
        action.setParams({"recordId": cmp.get("v.recordId")});
        action.setCallback(this, function(response) {
            cmp.set("v.isLoading", false);
            if(response.getState() === "SUCCESS") {
                let dataSet = response.getReturnValue();
                cmp.set("v.dataEEtoWCassocs", dataSet);
                this.buildMaps(cmp, event);
                if (args) {
                    switch (args.component) {
                        case "employees":
                            this.handleEmployees(cmp, event, args);
                            break;
                        case "markup":
                            this.handleMarkup(cmp, event, args);
                            break;
                        case "workComp":
                            this.handleWorkComp(cmp, event, args);
                            break;
                        default :
                            break;
                    }
                } else {
                    console.error("Error loading Employee data: ", response.getError());
                }
            }});
        $A.enqueueAction(action);
    },

    loadExpenses: function(cmp, event, args){
        let action = cmp.get("c.getPricingExpenses");
        action.setParams({"recordId": cmp.get("v.recordId")});
        action.setCallback(this, function (data) {
            if (data.getState() === "SUCCESS") {
                cmp.set("v.prcExpenses", data.getReturnValue());
                this.loadClientInvestments(cmp, event, args);
            } else {
                this.showToast(cmp, "Sorry to interrupt you", "An error occurred while loading Expenses data", "error", "sticky");
            }
        });
        $A.enqueueAction(action);
    },

    loadClientInvestments: function(cmp, event, args){
        let action = cmp.get("c.getPricingClientInvestments");
        action.setParams({"recordId": cmp.get("v.recordId")});
        action.setCallback(this, function (data) {
            if (data.getState() === "SUCCESS") {
                cmp.set("v.prcClientInvestments", data.getReturnValue());
                if (args) {
                    this.handleExpenses(cmp, event, args);
                }
            } else {
                this.showToast(cmp, "Sorry to interrupt you", "An error occurred while loading Client Investments data", "error", "sticky");
            }
        });
        $A.enqueueAction(action);
    },

    loadDataTaxRates: function (cmp, event, args) {
        let action = cmp.get("c.getPricingTaxes");
        action.setParams({"recordId": cmp.get("v.recordId")});
        action.setCallback(this, function (data) {
            if (data.getState() === "SUCCESS") {
                cmp.set("v.prcTaxes", data.getReturnValue());
                if (args) {
                    this.handleTaxRates(cmp, event, args);
                }
            } else {
                this.showToast(cmp, "Sorry to interrupt you", "An error occurred while loading Tax Rates data", "error", "sticky");
            }
        });
        $A.enqueueAction(action);
    },

    loadDataXmods: function(cmp, event, args){
        cmp.set("v.isLoading", true);
        let action = cmp.get("c.getRenewalYearXmods");
        action.setParams({"recordId": cmp.get("v.recordId")});
        action.setCallback(this, function(response) {
            cmp.set("v.isLoading", false);
            if(response.getState() === "SUCCESS"){
                let xmods = response.getReturnValue();
                cmp.set("v.xmodsRenewalYear", xmods );
                cmp.set("v.xmod", Number(xmods[0].Xmod__c));
                this.sendRenewalXmods(cmp, xmods);
                if (args) {
                    this.handleXmod(cmp, event, args);
                }
            } else {
                this.showToast(cmp, "Sorry to interrupt you", "An error occurred while loading Xmod data", "error", "sticky");
            }
        });
        $A.enqueueAction(action);
    },

    loadZeroPayrollWorkComps: function (cmp) {
        let action = cmp.get("c.getPricingWcCodes");
        action.setParams({"recordId": cmp.get("v.recordId")});
        action.setCallback(this, function(response) {
            cmp.set("v.isLoading", false);
            if(response.getState() === "SUCCESS") {
                let zeroPayrollWcCodes = [];
                let workComps = response.getReturnValue();
                for (let i = 0; i < workComps.length; ++i) {
                    let wc = workComps[i];
                    if (wc.AnnualTaxablePayInCode__c === 0) {
                        zeroPayrollWcCodes.push(wc);
                    }
                }
                cmp.set("v.prcWorkComps", workComps);
                cmp.set("v.zeroPayrollWcCodes", zeroPayrollWcCodes);
            }});
        $A.enqueueAction(action);
    },

    buildMaps: function (cmp, event){
        let EEtoWC = cmp.get("v.dataEEtoWCassocs");
        let eeMap = new Map();
        let wcMap = new Map();
        for (let i = 0; i < EEtoWC.length; i++) {
            if(!eeMap.has(EEtoWC[i].Pricing_Employee__r.Id)){
                eeMap.set(EEtoWC[i].Pricing_Employee__r.Id, {
                    "Id" : EEtoWC[i].Pricing_Employee__r.Id,
                    "AnnualHours__c" : EEtoWC[i].Pricing_Employee__r.AnnualHours__c,
                    "AnnualPay__c" : EEtoWC[i].Pricing_Employee__r.AnnualPay__c,
                    "AnnualPremPay__c" : EEtoWC[i].Pricing_Employee__r.AnnualPremPay__c,
                    "AnnualTaxablePay__c" : EEtoWC[i].Pricing_Employee__r.AnnualTaxablePay__c,
                    "ClientPricingScenario__c" : EEtoWC[i].Pricing_Employee__r.ClientPricingScenario__c,
                    "Employee_Name__c" : EEtoWC[i].Pricing_Employee__r.Employee_Name__c,
                    "EstimatedERTax__c" : EEtoWC[i].Pricing_Employee__r.EstimatedERTax__c,
                    "HourlyRate__c" : EEtoWC[i].Pricing_Employee__r.HourlyRate__c,
                    "IsActive__c" : EEtoWC[i].Pricing_Employee__r.IsActive__c,
                    "IsOwner__c" :  EEtoWC[i].Pricing_Employee__r.IsOwner__c,
                    "IsUpdate__c" : EEtoWC[i].Pricing_Employee__r.IsUpdate__c,
                    "Margin_Goal__c" :  EEtoWC[i].Pricing_Employee__r.Margin_Goal__c,
                    /*
                    * DO NOT INCLUDE PRIMARY WC CODE - SAVE EMPLOYEE METHOD DOESN"T LIKE IT AND WE DON"T NEED IT HERE
                    "PrimaryPricingWcCode__c" : EEtoWC[i].Pricing_Employee__r.PrimaryPricingWcCode__c,
                    "Primary_WC_Code__c" : EEtoWC[i].Pricing_Employee__r.Primary_WC_Code__c,
                    */
                    "Qty__c" : EEtoWC[i].Pricing_Employee__r.Qty__c,
                    "State__c" : EEtoWC[i].Pricing_Employee__r.State__c,
                    "State_Code__c" : EEtoWC[i].Pricing_Employee__r.State_Code__c
                });
            }
            if(!wcMap.has(EEtoWC[i].PricingWcCode__r.Id)){
                wcMap.set(EEtoWC[i].PricingWcCode__r.Id, {
                    "Id" : EEtoWC[i].PricingWcCode__r.Id,
                    "AnnualHoursInCode__c" : EEtoWC[i].PricingWcCode__r.AnnualHoursInCode__c,
                    "AnnualPayInCode__c" : EEtoWC[i].PricingWcCode__r.AnnualPayInCode__c,
                    "AnnualPremPayInCode__c" : EEtoWC[i].PricingWcCode__r.AnnualPremPayInCode__c,
                    "AnnualTaxablePayInCode__c" : EEtoWC[i].PricingWcCode__r.AnnualTaxablePayInCode__c,
                    "ClientPricingScenario__c" : EEtoWC[i].PricingWcCode__r.ClientPricingScenario__c,
                    "DesiredMargin__c" : EEtoWC[i].PricingWcCode__r.DesiredMargin__c,
                    "DesiredMarginDollars__c" : EEtoWC[i].PricingWcCode__r.DesiredMarginDollars__c,
                    "EstimatedErTaxInCode__c" : EEtoWC[i].PricingWcCode__r.EstimatedErTaxInCode__c,
                    "MarginPerHeadInCode__c" :  EEtoWC[i].PricingWcCode__r.MarginPerHeadInCode__c,
                    "Markup__c" : EEtoWC[i].PricingWcCode__r.Markup__c,
                    "Markup_OverTime__c" : EEtoWC[i].PricingWcCode__r.Markup_OverTime__c,
                    "Markup_DoubleTime__c" : EEtoWC[i].PricingWcCode__r.Markup_DoubleTime__c,
                    "Markup_Blended__c" : EEtoWC[i].PricingWcCode__r.Markup_Blended__c,
                    "MarkupNo1k__c" : EEtoWC[i].PricingWcCode__r.MarkupNo1k__c,
                    "Modified_WC_Rate__c" : EEtoWC[i].PricingWcCode__r.Modified_WC_Rate__c,
                    "PercentOfPayroll__c" : EEtoWC[i].PricingWcCode__r.PercentOfPayroll__c,
                    "Pricing_Group__c" : EEtoWC[i].PricingWcCode__r.Pricing_Group__c,
                    "SI_Max__c" : EEtoWC[i].PricingWcCode__r.SI_Max__c,
                    "SI_Max_Blended__c" : EEtoWC[i].PricingWcCode__r.SI_Max_Blended__c,
                    "SI_Percent_of_Payroll__c" : EEtoWC[i].PricingWcCode__r.SI_Percent_of_Payroll__c,
                    "SI_Percent_of_Premium__c" : EEtoWC[i].PricingWcCode__r.SI_Percent_of_Premium__c,
                    "SIEligible__c" : EEtoWC[i].PricingWcCode__r.SIEligible__c,
                    "State_Code__c" : EEtoWC[i].PricingWcCode__r.State_Code__c,
                    "TaxBurdenPercentInCode__c": EEtoWC[i].PricingWcCode__r.TaxBurdenPercentInCode__c,
                    "WC_Code__c" : EEtoWC[i].PricingWcCode__r.WC_Code__c,
                    "WC_Rate__c" : EEtoWC[i].PricingWcCode__r.WC_Rate__c,
                    "WcPremiumEquivalent__c" : EEtoWC[i].PricingWcCode__r.WcPremiumEquivalent__c,
                    "WcPremiumBlended__c" : EEtoWC[i].PricingWcCode__r.WcPremiumBlended__c,
                    "WCPremPercentOfPayroll__c" : EEtoWC[i].PricingWcCode__r.WCPremPercentOfPayroll__c,
                    "WCPremiumBlendedPercentOfPayroll__c" : EEtoWC[i].PricingWcCode__r.WCPremiumBlendedPercentOfPayroll__c
                });
            }
        }
        cmp.set("v.eeMap", eeMap);
        cmp.set("v.wcMap", wcMap);
    },

    doPricingBilling: function (cmp, args) {
        // Dependent on: v.totPayroll (doPricingEmployees), v.totTaxes (doPricingTaxes),
        // v.totWcPremiums (doPricingWorkCompAndSafetyIncentive), v.totExpenses (doPricingExpenses), v.totGrossMargin (doPricingMarkup)
        // Set: v.totBilling

        let totBilling =
            Number(cmp.get("v.totPayroll")) +
            Number(cmp.get("v.totTaxes")) +
            Number(cmp.get("v.totWcPremiums")) +
            Number(cmp.get("v.totComms")) +
            Number(cmp.get("v.totExpenses")) +
            Number(cmp.get("v.totGrossMargin"));
        cmp.set("v.totBilling", Number(totBilling));
        console.log(new Date().getTime() + " doPricingBilling");
    },

    doPricingSummary: function(cmp, args){
        // Dependent on: v.renewalSummaryObj, v.totBilling (doPricingBilling), v.totPayroll (doPricingEmployees),
        // v.totTaxes (doPricingTaxes), v.totWcPremiums (doPricingWorkCompAndSafetyIncentive), v.totExpenses (doPricingExpenses),
        // v.totGrossMargin, v.totBuMin3x, v.totBuMax5x (doPricingMarkup), v.totMaxSI (doPricingWorkCompSI),
        // v.totClaims, v.totUltmExpected (initSummaryTotals), v.xmod (loadDataXmods), v.FTE (doPricingEmployees),
        // v.activeHeadcount, v.totalHeadcount (doPricingEmployees)
        // Set: v.totMarginPercent, v.totMarginPercentOfPayroll, v.totMarginPerHead, v.taxBurdenPercent, v.taxBurdenPercentNoOwner,
        // v.renewalSummaryObj - MarginPercent__c, MarginPercentPayroll__c, MarginPerHead__c, MarkupPercentage__c,
        // v.renewalSummaryObj - YendTaxBurden_Percent__c, YendTaxBurden_PercentNo1k__c

        let sumObj = cmp.get("v.renewalSummaryObj");
        sumObj.YendBilling__c = cmp.get("v.totBilling");
        sumObj.YendPayroll__c = cmp.get("v.totPayroll");
        sumObj.YendPayrollTaxable__c = cmp.get("v.totTaxablePayroll");
        sumObj.YendPayrollTaxableNoOwner__c = cmp.get("v.totTaxablePayrollNoOwner");
        sumObj.YendErTaxes__c = cmp.get("v.totTaxes");
        sumObj.YendErTaxesNoOwner__c = cmp.get("v.totTaxesNoOwner");
        sumObj.YendWcPrem__c = cmp.get("v.totWcPremiums");
        sumObj.YendExpenses__c = cmp.get("v.totExpenses");
        sumObj.YendMargin__c = Number(cmp.get("v.totGrossMargin"));
        sumObj.BUHours3x__c = cmp.get("v.totBuMin3x");
        sumObj.BUHours5x__c = cmp.get("v.totBuMax5x");
        sumObj.YendMaxSI__c = cmp.get("v.totMaxSI");
        sumObj.TotalClaims__c = cmp.get("v.totClaims");
        sumObj.UltimateExpected__c = cmp.get("v.totUltmExpected");
        sumObj.Xmod__c = cmp.get("v.xmod");
        sumObj.FTE__c = cmp.get("v.FTE");
        // Calculate Turnover is a calculated field using Headcount__c and HeadcountAnnual__c
        sumObj.Headcount__c = cmp.get("v.activeHeadcount");
        sumObj.HeadcountAnnual__c = cmp.get("v.totalHeadcount");

        // Calculate Taxes
        let taxBurdenPercent = 0;
        let taxBurdenPercentNoOwner = 0;
        if(Number(sumObj.YendErTaxes__c) !== 0 && Number(sumObj.YendPayrollTaxable__c) !== 0){
            taxBurdenPercent = 100 * Number(sumObj.YendErTaxes__c) / Number(sumObj.YendPayrollTaxable__c);
        }
        if(Number(sumObj.YendErTaxesNoOwner__c) !== 0 && Number(sumObj.YendPayrollTaxableNoOwner__c) !== 0){
            taxBurdenPercentNoOwner = 100 * Number(sumObj.YendErTaxesNoOwner__c) / Number(sumObj.YendPayrollTaxableNoOwner__c);
        }
        sumObj.YendTaxBurden_Percent__c = Number(taxBurdenPercent);
        sumObj.YendTaxBurden_PercentNo1k__c = Number(taxBurdenPercentNoOwner);

        cmp.set("v.taxBurdenPercent", Number(taxBurdenPercent));
        cmp.set("v.taxBurdenPercentNoOwner", Number(taxBurdenPercentNoOwner));
        cmp.set("v.renewalSummaryObj", sumObj);
        console.log(new Date().getTime() + " doPricingSummary");
    },

    doPricingCommissions: function (cmp, newData) {
        // Dependent on: v.renewalSummaryObj - YendWcPrem__c, YendMargin__c (doPricingMarkup), YendPayroll__c
        // Set: (if applicable) v.clientPricingScenario - commRateRenewal__c, BDM_Rate_Renewal__c
        // Set: totComms, v.renewalSummaryObj - YendComm__c, YendCommBdm__c, YendCommsTotal__c, YendCommissionPercent__c

        let cps = cmp.get("v.clientPricingScenario");
        if (newData != null && newData.type === "commChanged") {
            if (newData.value.refPartRate != null) {
                cps.commRateRenewal__c = newData.value.refPartRate;
            }
            if (newData.value.bdmRate != null) {
                cps.BDM_Rate_Renewal__c = newData.value.bdmRate;
            }
            if (newData.value.hasReferralPartner != null) {
                cps.HasReferralPartner__c = newData.value.hasReferralPartner;
            }
            if (newData.value.hasBdm != null) {
                cps.HasBdm__c = newData.value.hasBdm;
            }
        }

        let sumObj = cmp.get("v.renewalSummaryObj");
        let commissionRate = (cps.HasReferralPartner__c == true) ? Number(cps.commRateRenewal__c) / 100 : Number(0);
        let bdmRate = (cps.HasBdm__c == true) ? Number(cps.BDM_Rate_Renewal__c) / 100 : Number(0);
        let totTaxablePayroll = Number(cmp.get("v.totTaxablePayroll"));
        sumObj.YendComms__c = commissionRate * Number(cmp.get("v.totWcPremiums"));
        sumObj.YendCommsBdm__c = bdmRate * Number(cmp.get("v.totGrossMargin"));
        sumObj.YendCommsTotal__c = 0;
        if(sumObj.YendComms__c){
            sumObj.YendCommsTotal__c += Number(sumObj.YendComms__c);
        }
        if(sumObj.YendCommsBdm__c){
            sumObj.YendCommsTotal__c += Number(sumObj.YendCommsBdm__c);
        }
        if(Number(sumObj.YendCommsTotal__c) !== 0 && totTaxablePayroll !== 0){
            sumObj.YendCommissionPercent__c = 100 * (Number(sumObj.YendCommsTotal__c) / totTaxablePayroll);
        } else {
            sumObj.YendCommissionPercent__c = 0;
        }

        cmp.set("v.clientPricingScenario", cps);
        cmp.set("v.totComms", sumObj.YendCommsTotal__c);
        cmp.set("v.renewalSummaryObj", sumObj);
        console.log(new Date().getTime() + " doPricingCommissions");
    },

    doPricingEmployees: function (cmp, args) {
        // Dependent on: projFactor, update ee-wc junction object
        // Set: totPayroll, totTaxablePayroll, totTaxablePayrollNoOwner, totPremPayroll, (turnover: totalHeadcount, activeHeadcount), totHours, FTE, update ee-wc junction object
        // Summary: Recalculate Payroll (then Employer Taxes),  Max SI is a formula field and will get auto-"recalculated" after records are saved/loaded

        let projFactor = cmp.get("v.projFactor");
        let pFactor = 1;
        let totPay = 0;
        let totTaxablePay = 0;
        let totTaxablePayNoOwner = 0;
        let totPremPay = 0;
        let totHeadcount = 0;
        let totActiveHeadcount = 0;
        let totHours = 0;
        let qty = 1;

        let EEtoWC = cmp.get("v.dataEEtoWCassocs");
        let eeMap = cmp.get("v.eeMap");
        let wcMap = cmp.get("v.wcMap");

        let empId = "";
        let wcId = "";
        let eeProcessed = {};
        let wcProcessed = {};

        for(let i = 0; i < EEtoWC.length; i++) {
            pFactor = Number(1);
            empId = EEtoWC[i].Pricing_Employee__r.Id;
            wcId = EEtoWC[i].PricingWcCode__r.Id;
            qty = Number(eeMap.get(empId).Qty__c);

            if(!eeProcessed.hasOwnProperty(empId)){
                eeProcessed[empId] = "processed";
                // initialize Employee totals
                eeMap.get(empId).AnnualPay__c = Number(0);
                eeMap.get(empId).AnnualTaxablePay__c = Number(0);
                eeMap.get(empId).AnnualPremPay__c = Number(0);
                eeMap.get(empId).AnnualHours__c = Number(0);

                totHeadcount += Number(qty);
                if(eeMap.get(empId).IsActive__c){
                    totActiveHeadcount += Number(qty);
                }
            }
            if(!wcProcessed.hasOwnProperty(wcId)){
                wcProcessed[wcId] = "processed";
                // initialize Work Comp totals
                wcMap.get(wcId).AnnualPayInCode__c = Number(0);
                wcMap.get(wcId).AnnualTaxablePayInCode__c = Number(0);
                wcMap.get(wcId).AnnualPremPayInCode__c = Number(0);
                wcMap.get(wcId).AnnualHoursInCode__c = Number(0);
                wcMap.get(wcId).ActiveEmployeesInCode__c = Number(0);
                wcMap.get(wcId).TotalEmployeesInCode__c = Number(0);
            }
            if(eeMap.get(empId).IsActive__c){
                pFactor = Number(projFactor);
            }
            if (eeMap.get(empId).IsUpdate__c) {
                pFactor = 1;
            }
            if(qty === 0 && eeMap.get(empId).IsUpdate__c) {
                qty = 1;
            }

            EEtoWC[i].ActiveEmployeesInCode__c = eeMap.get(empId).IsActive__c ? eeMap.get(empId).Qty__c : 0;
            EEtoWC[i].TotalEmployeesInCode__c = eeMap.get(empId).Qty__c;

            EEtoWC[i].AnnualPayInCode__c = Math.round(pFactor * qty * Number(EEtoWC[i].AnnualPayInCode_base__c) * 100) / 100;
            EEtoWC[i].AnnualTaxablePayInCode__c = Math.round(pFactor * qty * Number(EEtoWC[i].AnnualTaxablePayInCode_base__c) * 100) / 100;
            EEtoWC[i].AnnualPremPayInCode__c = Math.round(pFactor * qty * Number(EEtoWC[i].AnnualPremPayInCode_base__c) * 100) / 100;
            EEtoWC[i].AnnualHoursInCode__c = Math.round(pFactor * qty * Number(EEtoWC[i].AnnualHoursInCode_base__c) * 100) / 100;

            // sum employee & WC rollup amounts
            eeMap.get(empId).AnnualPay__c += Number(EEtoWC[i].AnnualPayInCode__c);
            eeMap.get(empId).AnnualTaxablePay__c += Number(EEtoWC[i].AnnualTaxablePayInCode__c);
            eeMap.get(empId).AnnualPremPay__c += Number(EEtoWC[i].AnnualPremPayInCode__c);
            eeMap.get(empId).AnnualHours__c += Number(EEtoWC[i].AnnualHoursInCode__c);

            wcMap.get(wcId).AnnualPayInCode__c += Number(EEtoWC[i].AnnualPayInCode__c);
            wcMap.get(wcId).AnnualTaxablePayInCode__c += Number(EEtoWC[i].AnnualTaxablePayInCode__c);
            wcMap.get(wcId).AnnualPremPayInCode__c += Number(EEtoWC[i].AnnualPremPayInCode__c);
            wcMap.get(wcId).AnnualHoursInCode__c += Number(EEtoWC[i].AnnualHoursInCode__c);
            wcMap.get(wcId).ActiveEmployeesInCode__c += Number(EEtoWC[i].ActiveEmployeesInCode__c);
            wcMap.get(wcId).TotalEmployeesInCode__c += Number(EEtoWC[i].TotalEmployeesInCode__c);

            // grand totals for all employees
            totPay += Number(EEtoWC [i].AnnualPayInCode__c);
            totTaxablePay += Number(EEtoWC[i].AnnualTaxablePayInCode__c);
            totPremPay += Number(EEtoWC[i].AnnualPremPayInCode__c);
            if(!Boolean(eeMap.get(empId).IsOwner__c)){
                totTaxablePayNoOwner += Number(EEtoWC[i].AnnualTaxablePayInCode__c);
            }
            totHours += Number(EEtoWC[i].AnnualHoursInCode__c);
        }

        cmp.set("v.totPayroll", totPay);
        cmp.set("v.totTaxablePayroll", totTaxablePay);
        cmp.set("v.totTaxablePayrollNoOwner", totTaxablePayNoOwner);
        cmp.set("v.totPremPayroll", totPremPay);
        cmp.set("v.totalHeadcount", totHeadcount);        // to auto calculate turnover
        cmp.set("v.activeHeadcount", totActiveHeadcount); // to auto calculate turnover
        cmp.set("v.totHours", Number(totHours));
        cmp.set("v.FTE", this.round(Number(totHours) / 2080, 1));
        cmp.set("v.dataEEtoWCassocs", EEtoWC);
        cmp.set("v.eeMap", eeMap);
        cmp.set("v.wcMap", wcMap);
        console.log(new Date().getTime() + " doPricingEmployees");
    },

    doPricingTaxes: function (cmp, args) {
        // Dependent on: v.dataEEtoWCassocs, v.prcTaxes (loadDataTaxRates), v.eeMap
        // Set: totTaxes, totTaxesNoOwner, v.dataEEtoWCassocs, v.eeMap - EstimatedERTax__c

        let EEtoWC = cmp.get("v.dataEEtoWCassocs");
        let taxRates = cmp.get("v.prcTaxes");
        let eeMap = cmp.get("v.eeMap");
        let eeProcessed = {};
        let wcMap = cmp.get("v.wcMap");
        let wcProcessed = {};
        let totTaxes = 0;
        let totTaxesNoOwner = 0;

        for (let i = 0; i < EEtoWC.length; i++) {
            let result = 0;
            let empId = EEtoWC[i].Pricing_Employee__r.Id;
            if(eeProcessed.hasOwnProperty(empId)) { continue; }
            eeProcessed[empId] = "processed";

            let isNegative = Number(eeMap.get(empId).AnnualTaxablePay__c) < 0;
            let payPerEmployee = Math.abs(Number(eeMap.get(empId).AnnualTaxablePay__c));
            let qty = Math.abs(Number(eeMap.get(empId).Qty__c));
            if(qty !== 0){
                payPerEmployee = Number(payPerEmployee / qty);
            }
            payPerEmployee = Math.abs(payPerEmployee);

            for (let j = 0; j < taxRates.length; j++) {
                // If the tax has a non-profit flag, do not calculate taxes
                // if (taxRates[j].Non_Profit__c) {
                //     continue;
                // }

                // The tax state is not applicable, do not calculate taxes
                if (taxRates[j].State_Code__c !== "FED" && taxRates[j].State_Code__c !== eeMap.get(empId).State_Code__c) {
                    continue;
                }

                let taxType = taxRates[j].Tax_Type__c;
                let limit = Number(taxRates[j].Limit__c);
                let rate = Number(this.round(taxRates[j].Rate__c / 100, 5));
                let payrollLimit = 0;
                
                // Tax Calculation on Modify By WC Code employee row: 
                // Note: Qty will always be a whole number (i.e.: 1, 2, 3, 4)
                // 1. Qty = 0, calculate only MEDI and FICA - NO limit
                //    1.a. MEDI and FICA - NO limit
                //    1.b. Other taxes - NO calculation needed - skip
                // 2. Qty != 0:
                //    2.a. MEDI and FICA - NO limit
                //    2.b. Other taxes - calculate normally with limit in place (i.e.: if limit = 7000, qty = 10, calculate taxes on 70,000)
                // if (eeMap.get(empId).IsUpdate__c || qty == 0) {
                if (eeMap.get(empId).IsUpdate__c || qty == 0) {
                    // 1.a. and 2.a.
                    if (taxType === "MEDI" || taxType === "FICA") {
                        result += Math.abs(rate * Number(eeMap.get(empId).AnnualTaxablePay__c));
                        continue;
                    }
                    // 1.b
                    if (qty === 0) { 
                        continue;
                    }
                    // 2.b. With Limit (limit > 0), Rate * Min between (taxable pay per employee and limit) * qty
                    //      Without Limit (limit = 0), Rate * employee total Annual Taxable Pay
                    payrollLimit = (limit === 0) ? Math.abs(Number(eeMap.get(empId).AnnualTaxablePay__c)) : Math.min(payPerEmployee, limit);
                    result += (rate * payrollLimit * qty);
                }
                else {
                    // Calculation when Qty is not always a full number (i.e.: 1, 2, 3) - which will includes Qty with one decimal point (i.e.: 1.3, 4.2, 6.4)
                    for(let q = qty; q > 0; q--) {
                        let payroll = payPerEmployee;
                        if (q < 1) {
                            payroll = payPerEmployee * q;
                        }
                        payrollLimit += (limit === 0) ? payroll : Math.min(limit, payroll);
                    }
                    result += (rate * payrollLimit);
                }
            }

            eeMap.get(empId).EstimatedERTax__c = Number(isNegative ? -1 : 1) * Number(Math.abs(result));
            totTaxes += Number(eeMap.get(empId).EstimatedERTax__c);
            if(!eeMap.get(empId).IsOwner__c) {
                totTaxesNoOwner += Number(eeMap.get(empId).EstimatedERTax__c);
            }
        }

        for (let i = 0; i < EEtoWC.length; i++) {
            let empId = EEtoWC[i].Pricing_Employee__r.Id;
            let wcId = EEtoWC[i].PricingWcCode__r.Id;

            if (!wcProcessed.hasOwnProperty(wcId)) {
                wcProcessed[wcId] = "processed";
                wcMap.get(wcId).EstimatedErTaxInCode__c = Number(0);
            }

            let taxInCode = 0;
            if(Number(eeMap.get(empId).AnnualTaxablePay__c) != 0){
                taxInCode = this.round(
                    Number(eeMap.get(empId).EstimatedERTax__c) * Number(EEtoWC[i].AnnualTaxablePayInCode__c)
                    / Number(eeMap.get(empId).AnnualTaxablePay__c), 2)
            }

            EEtoWC[i].EstimatedErTaxInCode__c = taxInCode;
            wcMap.get(wcId).EstimatedErTaxInCode__c += taxInCode;
        }

        // Do pricing taxes by ee + wc
        cmp.set("v.totTaxes", totTaxes);
        cmp.set("v.totTaxesNoOwner", totTaxesNoOwner);
        cmp.set("v.dataEEtoWCassocs", EEtoWC);
        cmp.set("v.eeMap", eeMap);
        cmp.set("v.wcMap", wcMap);
        console.log(new Date().getTime() + " doPricingTaxes");
    },

    doPricingGrossMarginByWorkCompCode: function(cmp, args) {
        // Dependent on: v.wcMap, v.totTaxablePayroll
        // Set on: v.wcMap - PercentOfPayroll__c
        
        if(cmp.get("v.grossMarginOption") !== "optMargin"){
            return;
        }

        let wcMap = cmp.get("v.wcMap");
        let totTaxablePayroll = Number(cmp.get("v.totTaxablePayroll"));
        let wcArray = Array.from(wcMap.values());

        for (let i = 0; i < wcArray.length; ++i) {
            let wcId = wcArray[i].Id;
            let wc = wcMap.get(wcId);
            let percentOfPayroll = (wc.AnnualTaxablePayInCode__c != 0)
                ? Number((100 * wc.AnnualTaxablePayInCode__c) / totTaxablePayroll)
                : Number(0);
            wc.PercentOfPayroll__c = percentOfPayroll;
        }
        cmp.set("v.wcMap", wcMap);
    },

    doPricingGrossMarginByPercentOfPayroll: function (cmp, args){
        // Dependent on: v.wcMap, v.totGrossMargin (doPricingMarkup), v.totTaxablePayroll
        // Set on: v.wcMap - DesiredMarginDollars__c
        //                 - PercentOfPayroll__c
        if(cmp.get("v.grossMarginOption") === "optMargin"){
            return;
        }

        let wcMap = cmp.get("v.wcMap");
        let totTaxablePayroll = Number(cmp.get("v.totTaxablePayroll"));
        let totGrossMargin = Number(cmp.get("v.totGrossMargin"));
        let sumMargin = Number(0);
        let highestMarginId = 0;
        let highestMarginDollars = -9999999999;
        let wcArray = Array.from(wcMap.values());

        // Assigning margin to each work comp - based off of percent of payroll
        // while keeping track of the highest payroll row - 
        // -- so if there are difference because of % discrepencies,
        // -- make the desired margin total difference with the assigned margin 
        // -- to the highest payroll work comp
        for (let i = 0; i < wcArray.length; ++i) {
            let wcId = wcArray[i].Id;
            let wc = wcMap.get(wcId);

            let percentOfPayroll = (wc.AnnualTaxablePayInCode__c != 0)
                ? Number((100 * wc.AnnualTaxablePayInCode__c) / totTaxablePayroll)
                : Number(0);
            let marginDollars = Math.round(totGrossMargin * Number(percentOfPayroll.toFixed(2))) / 100;
            sumMargin = Number((marginDollars + sumMargin).toFixed(2));
            if(marginDollars > highestMarginDollars){
                highestMarginDollars = marginDollars;
                highestMarginId = wcId;
            }

            wc.PercentOfPayroll__c = percentOfPayroll;
            wc.DesiredMarginDollars__c = marginDollars;
        }

        totGrossMargin = Number(totGrossMargin.toFixed(2));
        // if the total gross margin and assigned sum margin are not equal, 
        //      make them equal by adding in the difference to the highest payroll work comp
        // however, if the sum of assigned margin is zero, do not add total gross margin at all
        if(sumMargin != 0 && totGrossMargin != sumMargin && highestMarginId != 0){
            let diffMargin = Number((totGrossMargin - sumMargin).toFixed(2));
            wcMap.get(highestMarginId).DesiredMarginDollars__c += diffMargin;
        }

        cmp.set("v.wcMap", wcMap);
        console.log(new Date().getTime() + " doPricingGrossMarginByPercentOfPayroll");
    },

    doPricingMargin: function(cmp, newData){
        // Dependent on: v.wcMap
        // Set: v.totGrossMargin, v.toBuMin3x, v.totBuMax5x

        if(newData != null) {
            cmp.set("v.grossMarginOption", newData.value);
        }

        let wcMap = cmp.get("v.wcMap");
        let totGrossMargin = 0;
        let wcArray = Array.from(wcMap.values());

        for (let i = 0; i < wcArray.length; ++i) {
            let wcId = wcArray[i].Id;
            totGrossMargin += Number(wcMap.get(wcId).DesiredMarginDollars__c);
        }

        let totBuMin3x = (Number(totGrossMargin) / 3) / 80;
        let totBuMax5x = (Number(totGrossMargin) / 5) / 80;

        cmp.set("v.totGrossMargin", Number(totGrossMargin));
        cmp.set("v.totBuMin3x", totBuMin3x);
        cmp.set("v.totBuMax5x", totBuMax5x);
        cmp.set("v.wcMap", wcMap);

        console.log(new Date().getTime() + " doPricingMargin");
    },

    doPricingMarkup: function (cmp, args) {
        // Dependent on: v.wcMap, v.totComms (doPricingCommissions),
        // v.totTaxes (doPricingTaxes), v.totExpenses (doPricingExpenses)
        // Set: v.totGrossMargin, v.toBuMin3x, v.totBuMax5x, wcMap - PercentOfPayroll__c,
        // Markup__c, Markup_OverTime__c, Markup_DoubleTime__c, Markup_Blended__c

        let wcMap = cmp.get("v.wcMap");
        let totTaxablePayroll = Number(cmp.get("v.totTaxablePayroll"));
        let totComms = Number(cmp.get("v.totComms"));
        let totExpenses = Number(cmp.get("v.totExpenses"));
        let totGrossMargin = 0;
        let wcArray = Array.from(wcMap.values());

        for (let i = 0; i < wcArray.length; ++i) {
            let wcId = wcArray[i].Id;
            let wc = wcMap.get(wcId);

            let marginOfPayroll = this.round(100 * Number(wc.DesiredMarginDollars__c) / Number(wc.AnnualTaxablePayInCode__c), 2);
            let taxPercentOfPayroll = this.round(100 * Number(wcMap.get(wcId).EstimatedErTaxInCode__c) / Number(wcMap.get(wcId).AnnualTaxablePayInCode__c), 2);
            let expensesPercentOfPayroll = this.round(100 * totExpenses / totTaxablePayroll, 2);
            let commissionPercentOfPayroll = this.round(100 * totComms / totTaxablePayroll, 2);
            let wcPremiumBlendedPercentOfPayroll = this.round(100 * Number(wc.WcPremiumBlended__c) / Number(wc.AnnualTaxablePayInCode__c), 3);

            wc.Markup_Blended__c =  this.round(marginOfPayroll + taxPercentOfPayroll + expensesPercentOfPayroll + commissionPercentOfPayroll + wcPremiumBlendedPercentOfPayroll, 3);
            wc.Markup__c = this.round(marginOfPayroll + taxPercentOfPayroll + expensesPercentOfPayroll + commissionPercentOfPayroll + Number(wc.Modified_WC_Rate__c), 3);
            wc.Markup_OverTime__c = this.round(wc.Markup__c - (Number(wc.Modified_WC_Rate__c) / 3), 3);
            wc.Markup_DoubleTime__c = this.round(wc.Markup__c - (Number(wc.Modified_WC_Rate__c) / 2), 3);
            wc.MarkupNo1k__c = (wc.WC_Code__c == '1000') ? 0 : Number(wc.Markup__c);
            wc.WCPremiumBlendedPercentOfPayroll__c = wcPremiumBlendedPercentOfPayroll;
            totGrossMargin += Number(wc.DesiredMarginDollars__c);
        }

        let totBuMin3x = (Number(totGrossMargin) / 3) / 80;
        let totBuMax5x = (Number(totGrossMargin) / 5) / 80;

        cmp.set("v.totGrossMargin", Number(totGrossMargin));
        cmp.set("v.totBuMin3x", totBuMin3x);
        cmp.set("v.totBuMax5x", totBuMax5x);
        cmp.set("v.wcMap", wcMap);

        console.log(new Date().getTime() + " doPricingMarkup");
    },

    doPricingMarkupEdit: function (cmp, args) {
        // Dependent on: v.wcMap, v.totComms (doPricingCommissions), v.totTaxes (doPricingTaxes), v.totExpenses (doPricingExpenses)
        // Set: v.totGrossMargin, v.toBuMin3x, v.totBuMax5x, wcMap - PercentOfPayroll__c,
        // Markup__c, Markup_Blended__c
        // NOTE: Markup_OverTime__c, Markup_DoubleTime__c DO NOT recalculate when Markup percentage is modified.

        let wcMap = cmp.get("v.wcMap");
        let totTaxablePayroll = Number(cmp.get("v.totTaxablePayroll"));
        let totComms = Number(cmp.get("v.totComms"));
        let totExpenses = Number(cmp.get("v.totExpenses"));
        let totGrossMargin = 0;
        let wcArray = Array.from(wcMap.values());

        for (let i = 0; i < wcArray.length; ++i) {
            let wcId = wcArray[i].Id;
            let wc = wcMap.get(wcId);

            let taxPercentOfPayroll = this.round(100 * Number(wcMap.get(wcId).EstimatedErTaxInCode__c) / Number(wcMap.get(wcId).AnnualTaxablePayInCode__c), 2);
            let expensesPercentOfPayroll = this.round(100 * totExpenses / totTaxablePayroll, 2);
            let commissionPercentOfPayroll = this.round(100 * totComms / totTaxablePayroll, 2);
            let wcPremiumBlendedPercentOfPayroll = this.round(100 * Number(wc.WcPremiumBlended__c) / Number(wc.AnnualTaxablePayInCode__c), 3);
            let markupPercentOfPayroll = this.round(Number(wc.Markup__c), 3);

            if (!taxPercentOfPayroll) { taxPercentOfPayroll = 0; }
            if (!expensesPercentOfPayroll) { expensesPercentOfPayroll = 0; }
            if (!commissionPercentOfPayroll) { commissionPercentOfPayroll = 0; }
            if (!wcPremiumBlendedPercentOfPayroll) { wcPremiumBlendedPercentOfPayroll = 0; }
            if (!markupPercentOfPayroll) { markupPercentOfPayroll = 0; }

            let marginOfPayroll = this.round(markupPercentOfPayroll - taxPercentOfPayroll - expensesPercentOfPayroll - commissionPercentOfPayroll - Number(wc.Modified_WC_Rate__c), 2);
            let desiredMarginDollars = this.round(marginOfPayroll * Number(wc.AnnualTaxablePayInCode__c) / 100, 2);
            wc.DesiredMarginDollars__c = desiredMarginDollars;
            wc.Markup__c = markupPercentOfPayroll;
            wc.Markup_OverTime__c = this.round(wc.Markup__c - (Number(wc.Modified_WC_Rate__c) / 3), 3);
            wc.Markup_DoubleTime__c = this.round(wc.Markup__c - (Number(wc.Modified_WC_Rate__c) / 2), 3);
            wc.Markup_Blended__c =  this.round(marginOfPayroll + taxPercentOfPayroll + expensesPercentOfPayroll + commissionPercentOfPayroll + wcPremiumBlendedPercentOfPayroll, 3);
            wc.MarkupNo1k__c = (wc.WC_Code__c == '1000') ? 0 : Number(wc.Markup__c);
            wc.WCPremiumBlendedPercentOfPayroll__c = wcPremiumBlendedPercentOfPayroll;
            totGrossMargin += Number(wc.DesiredMarginDollars__c);
        }

        let totBuMin3x = (Number(totGrossMargin) / 3) / 80;
        let totBuMax5x = (Number(totGrossMargin) / 5) / 80;

        cmp.set("v.totGrossMargin", Number(totGrossMargin));
        cmp.set("v.totBuMin3x", totBuMin3x);
        cmp.set("v.totBuMax5x", totBuMax5x);
        cmp.set("v.wcMap", wcMap);

        console.log(new Date().getTime() + " doPricingMarkupEdit");
    },

    doPricingResetSafetyIncentive: function (cmp, args) {
        let workComps = cmp.get("v.prcWorkComps");
        let wcMap = cmp.get("v.wcMap");
        for (let j = 0; j < workComps.length; ++j) {
            let workComp = workComps[j];
            let wcId = workComps[j].Id;
            workComp.SI_Percent_of_Payroll__c = Number(0);
            workComp.SI_Percent_of_Premium__c = Number(0);
            if (wcMap.has(wcId)) {
                wcMap.get(wcId).SI_Percent_of_Payroll__c = Number(0);
                wcMap.get(wcId).SI_Percent_of_Premium__c = Number(0);
            }
        }
        cmp.set("v.prcWorkComps", workComps);
        cmp.set("v.wcMap", wcMap);
    },

    doPricingWorkCompAndSafetyIncentive:function (cmp, args) {
        // Dependent on: v.xmodsRenewalYear (loadDataXmods), v.wcMap, v.prcWorkComps
        // Set: v.totMaxSI, v.totWcPremiums, v.dataEEToWCcassocs, v.wcMap - SI_Percent_of_Payroll__c, SI_Percent_of_Premium__c, SI_Max__c
        // Summary: Recalculate WC Premiums, SI Rates and Total SI
        //          Apply default rules: % of Premium Based Payroll >= percentMin (0.75) && <= percentMax (4)
        let workComps = cmp.get("v.prcWorkComps");
        let wcMap = cmp.get("v.wcMap");
        let xmods = cmp.get("v.xmodsRenewalYear");
        let xmodMap = {};

        for (let i = 0; i < xmods.length; i++) {
            if (xmodMap.hasOwnProperty(xmods[i].State_Code__c)) { continue; }
            xmodMap[xmods[i].State_Code__c] = Number(xmods[i].Xmod__c);
        }

        let totSI_Max = 0;
        let totWcPremiums = 0;
        let percentMin = Number(0.75);
        let percentMax = Number(4);
        let defaultPercentOfPayroll = 25;

        for (let j = 0; j < workComps.length; ++j) {
            let workComp = workComps[j];
            let wcId = workComps[j].Id;

            let siPercentOfPayroll = Number(0);
            let siPercentOfPremium = Number(0);
            let modifiedWcRate = Number(workComp.WC_Rate__c) * Number(xmodMap[workComp.State_Code__c]);

            if (workComp.SIEligible__c) {
                siPercentOfPayroll = Number(workComp.SI_Percent_of_Payroll__c);
                siPercentOfPremium = Number(workComp.SI_Percent_of_Premium__c);
                let modifiedWcRatePercentage = modifiedWcRate / 100;

                if(siPercentOfPayroll === 0 && siPercentOfPremium === 0)
                {
                    siPercentOfPayroll = modifiedWcRatePercentage * defaultPercentOfPayroll;
                    if(Number(siPercentOfPayroll) < percentMin){
                        siPercentOfPayroll = Number(0);
                        siPercentOfPremium = Number(0);
                    }
                    else if(siPercentOfPayroll > percentMax){
                        siPercentOfPayroll = Number(percentMax);
                        siPercentOfPremium = siPercentOfPayroll / modifiedWcRatePercentage;
                    }
                    else{
                        siPercentOfPremium = siPercentOfPayroll / modifiedWcRatePercentage;
                    }
                }
                else
                {
                    if(siPercentOfPayroll === 0)
                    {
                        siPercentOfPayroll = Number(siPercentOfPremium *  modifiedWcRatePercentage);
                    }
                    if(siPercentOfPremium === 0)
                    {
                        siPercentOfPremium = Number(siPercentOfPayroll / modifiedWcRatePercentage);
                    }
                }
            }

            workComp.Modified_WC_Rate__c = this.round(modifiedWcRate, 4);
            workComp.SI_Percent_of_Payroll__c = this.round(siPercentOfPayroll, 2);
            workComp.SI_Percent_of_Premium__c = this.round(siPercentOfPremium, 2);
            workComp.SI_Max__c = 0;
            workComp.WcPremiumEquivalent__c = 0;

            // use the latest value in the wcMap.AnnualTaxablePayInCode__c (NOT from v.workComps.AnnualTaxablePayInCode__c - it was original value form Database prior to any changes on this change)
            if (wcMap.has(wcId)) {
                workComp.SI_Max__c = (Number(workComp.SI_Percent_of_Payroll__c) / 100) * Number(wcMap.get(wcId).AnnualTaxablePayInCode__c);
                workComp.WcPremiumEquivalent__c = (Number(workComp.Modified_WC_Rate__c) / 100) * Number(wcMap.get(wcId).AnnualTaxablePayInCode__c);

                // update v.wcMap with v.prcWorkComp values
                wcMap.get(wcId).Modified_WC_Rate__c = workComp.Modified_WC_Rate__c;
                wcMap.get(wcId).SI_Percent_of_Payroll__c = workComp.SI_Percent_of_Payroll__c;
                wcMap.get(wcId).SI_Percent_of_Premium__c = workComp.SI_Percent_of_Premium__c;
                wcMap.get(wcId).SI_Max__c = workComp.SI_Max__c
                wcMap.get(wcId).WcPremiumEquivalent__c = workComp.WcPremiumEquivalent__c;
            }

            totSI_Max += Number(workComp.SI_Max__c);
            totWcPremiums += Number(workComp.WcPremiumEquivalent__c);
        }
        cmp.set("v.prcWorkComps", workComps);
        cmp.set("v.wcMap", wcMap);

        cmp.set("v.totMaxSI", totSI_Max);
        cmp.set("v.totWcPremiums", totWcPremiums);
        console.log(new Date().getTime() + " doPricingWorkCompAndSafetyIncentive");
    },

    doPricingExpenses: function (cmp, newData) {
        // Dependent on: v.totPayroll (doPricingEmployees)
        // Set: v.totExpenses, v.renewalSummaryObj - YendExpenses__c, YendExpenses_Percent__c

        let expenses = cmp.get("v.prcExpenses");
        let investments = cmp.get("v.prcClientInvestments");
        let sumObj = cmp.get("v.renewalSummaryObj");
        let totTaxablePayroll = Number(cmp.get("v.totTaxablePayroll"));
        let totWcPremiums = Number(cmp.get("v.totWcPremiums"));
        let totMargin = Number(cmp.get("v.totGrossMargin"));
        let totExpenses = Number(0);

        if(sumObj){ // on initial data load, the sumObj may be null so we don"t update Expenses
            console.log("doPricingExpenses - sumObj is null")
        }

        if(newData != null){
            sumObj.YendExpenses__c = newData.value;
        }
        else {
            for (let i = 0; i < expenses.length; i++) {
                let exp = expenses[i];
                totExpenses += Number(exp.Quantity__c) * Number(exp.Cost_Each__c);
            }
            for (let i = 0; i < investments.length; i++) {
                let inv = investments[i];
                let methodValue = Number(0);
                switch (inv.Method__c.toLowerCase()) {
                    case "% of payroll":
                        methodValue = totTaxablePayroll; break;
                    case "% of wc premium":
                        methodValue = totWcPremiums; break;
                    case "% of margin":
                        methodValue = totMargin; break;
                    default:
                        methodValue = totTaxablePayroll; break;
                }
                totExpenses += (Number(this.round(inv.Rate__c, 2))) * methodValue / 100;
            }
            sumObj.YendExpenses__c = this.round(totExpenses, 2);
        }

        if(Number(sumObj.YendExpenses__c) !== 0 && totTaxablePayroll !== 0){
            sumObj.YendExpenses_Percent__c = (100 * Number(sumObj.YendExpenses__c) / totTaxablePayroll);
        } else {
            sumObj.YendExpenses_Percent__c = 0;
        }

        cmp.set("v.totExpenses", sumObj.YendExpenses__c);
        cmp.set("v.renewalSummaryObj", sumObj);
    },

    initPricingDatasets: function (cmp, event) {
        // this.loadDataBillingHistories(cmp, event, null);
        // this.loadDataSafetyIncentives(cmp, event, null);
        this.loadDataEmployeesAndWorkComps(cmp, event, null);
        this.loadDataTaxRates(cmp, event, null);
        this.loadDataXmods(cmp, event, null);
        this.loadExpenses(cmp, event, null);
    },

    initSummaryTotals: function(cmp, event){
        let sumObj = cmp.get("v.renewalSummaryObj");
        let cps = cmp.get("v.clientPricingScenario");
        cmp.set("v.refCommAmt", Number(cps.rsumComms__c));
        cmp.set("v.bdmCommAmt", Number(cps.rsumCommsBdm__c));
        cmp.set("v.totBilling", sumObj.YendBilling__c);
        cmp.set("v.totPayroll", sumObj.YendPayroll__c);
        cmp.set("v.totTaxablePayroll", sumObj.YendPayrollTaxable__c);
        cmp.set("v.totTaxablePayrollNoOwner", sumObj.YendPayrollTaxableNoOwner__c);
        cmp.set("v.totTaxes", sumObj.YendErTaxes__c);
        cmp.set("v.totTaxesNoOwner", sumObj.YendErTaxesNoOwner__c);
        cmp.set("v.totWcPremiums", sumObj.YendWcPrem__c);
        cmp.set("v.totComms", sumObj.YendCommsTotal__c);
        cmp.set("v.totExpenses", sumObj.YendExpenses__c);
        cmp.set("v.totGrossMargin", sumObj.YendMargin__c);
        cmp.set("v.totBuMin3x", sumObj.BUHours3x__c);
        cmp.set("v.totBuMax5x", sumObj.BUHours5x__c);
        cmp.set("v.totMaxSI", sumObj.YendMaxSI__c);
        cmp.set("v.totClaims", sumObj.TotalClaims__c);
        cmp.set("v.totUltmExpected", sumObj.UltimateExpected__c);
        cmp.set("v.xmod", sumObj.Xmod__c );
        cmp.set("v.FTE", sumObj.FTE__c );
        cmp.set("v.activeHeadcount", sumObj.Headcount__c);
        cmp.set("v.totalHeadcount", sumObj.HeadcountAnnual__c);
        cmp.set("v.taxBurdenPercent",sumObj.YendTaxBurden_Percent__c);
        cmp.set("v.taxBurdenPercentNoOwner",sumObj.YendTaxBurden_PercentNo1k__c);
    },

    dataToChildComponents: function (cmp, event) {
        this.sendCommissionTotals(cmp, event);
        this.sendSummaryUpdate(cmp, null);
    },

    sendSummaryUpdate: function (cmp, data) {
        if(!data){
            data = cmp.get("v.renewalSummaryObj");
        }
        let changeType = "summaryUpdate";
        this.fireStateChange(cmp, changeType, data);
    },

    sendDataChangeAlert: function (cmp, message) {
        let changeType = "dataChange";
        this.fireStateChange(cmp, changeType, message);
    },

    sendCommissionTotals: function (cmp, event) {
        let sumObj = cmp.get("v.renewalSummaryObj");
        let changeType = "commsTotal";
        let commsData = {
            "comms": sumObj.YendComms__c,
            "commsBdm": sumObj.YendCommsBdm__c
        };
        this.fireStateChange(cmp, changeType, commsData);
    },

    sendRenewalXmods: function (cmp, data) {
        let changeType = "xmodsRenewalYear";
        this.fireStateChange(cmp, changeType, data);
    },

    sendIsProspectFlag: function (cmp) {
        let changeType = "isProspect";
        let isProspect = cmp.get("v.isProspect");
        this.fireStateChange(cmp, changeType, isProspect);
    },

    saveData: function (cmp, event) { // save Client Pricing Scenario
        cmp.set("v.isLoading", true);
        let action = cmp.get("c.SaveClientPricingScenario");
        action.setParams({"clientPricingScenario": cmp.get("v.clientPricingScenario")});
        action.setCallback(this, function (response) {
            cmp.set("v.isLoading", false);
            if (response.getState() === "SUCCESS") {
                this.sendDataChangeAlert(cmp, "clientPricingScenario");
            }
            else {
                this.showToast(cmp, "Sorry to interrupt you", "An error occurred while saving the Client Pricing Scenario", "error", "sticky");
            }
        });
        $A.enqueueAction(action);
    },

    saveDataSummary: function (cmp, event) {
        let summaryData = cmp.get("v.renewalSummaryObj");
        let action = cmp.get("c.savePricingSummaryRenewalRow");

        action.setParams({"pricingSummary": summaryData});
        action.setCallback(this, function (response) {
            if (response.getState() === "SUCCESS") {
                this.sendSummaryUpdate(cmp, summaryData);
            }
            else {
                this.showToast(cmp, "Sorry to interrupt you", "An error occurred while saving Pricing Scenario summary data", "error", "sticky");
            }
        });
        $A.enqueueAction(action);
    },

    saveDataEEtoWc: function (cmp, event){
        let action = cmp.get("c.saveAssocList");
        let assocList = cmp.get("v.dataEEtoWCassocs");

        action.setParams({"assocList": assocList});
        action.setCallback(this, function (response) {
            if (response.getState() === "SUCCESS") {
                this.sendDataChangeAlert(cmp, "EE2WC");
            } 
            else {
                this.showToast(cmp, "Sorry to interrupt you", "An error occurred while saving changes to the Employee data list", "error", "sticky");
            }
        });
        $A.enqueueAction(action);
    },

    saveDataEmployees: function (cmp, event){
        let action = cmp.get("c.saveEmployees");
        let eeMap = cmp.get("v.eeMap");
        let eeList = [];
        let it = eeMap.values();

        for(let i = 0; i < eeMap.size; i++){
            eeList.push(it.next().value);
        }

        action.setParams({"eeList": eeList});
        action.setCallback(this, function (response) {
            if (response.getState() === "SUCCESS") {
                this.sendDataChangeAlert(cmp, "employees");
            } 
            else {
                this.showToast(cmp, "Sorry to interrupt you", "An error occurred while saving changes to the Employee data list", "error", "sticky");
            }
        });
        $A.enqueueAction(action);
    },

    // Save v.wcMap
    saveDataWcCodes: function (cmp, event){
        let action = cmp.get("c.savePricingWcCodes");
        let wcMap = cmp.get("v.wcMap");
        let wcList = [];
        let it = wcMap.values();

        for(let i = 0; i < wcMap.size; i++){
            wcList.push(it.next().value);
        }

        action.setParams({"wcCodes": wcList});
        action.setCallback(this, function (response) {
            if (response.getState() === "SUCCESS") {
                this.sendDataChangeAlert(cmp, "wcCodes");
            }
            else {
                this.showToast(cmp, "Sorry to interrupt you", "An error occurred while saving changes to the Employee data list", "error", "sticky");
            }
        });
        $A.enqueueAction(action);
    },

    // Save v.PrcWorkComp and v.wcMap
    saveDataWorkComps: function (cmp, event) {
        let action = cmp.get("c.savePricingWcCodes");
        let workComps = cmp.get("v.prcWorkComps");

        action.setParams({"wcCodes": workComps});
        action.setCallback(this, function (response) {
            if (response.getState() === "SUCCESS") {
                this.saveDataWcCodes(cmp, event);
            } 
            else {
                this.showToast(cmp, "Sorry to interrupt you", "An error occurred while saving changes to the Employee data list", "error", "sticky");
            }
        });
        $A.enqueueAction(action);
    },

    saveZeroPayrollWcCodes: function (cmp, event, draftValues) {
        if (!draftValues || draftValues.length == 0) {
            return;
        }

        let draftJson = JSON.stringify(draftValues);
        let action = cmp.get("c.savePricingWcCodes");
        action.setParams({"wcCodes": draftJson});
        action.setCallback(this, function (response) {
            if (response.getState() === "SUCCESS") {
                if (cmp.find("zeroPayrollTable")) {
                    // clear the Cancel and Save buttons
                    cmp.find("zeroPayrollTable").set("v.draftValues", null); 
                }
                this.loadZeroPayrollWorkComps(cmp);
            } 
            else {
                this.showToast(cmp, "Sorry to interrupt you", "An error occurred while saving changes to the Zero Payroll data list", "error", "sticky");
            }
        });
        $A.enqueueAction(action);
    },

    saveDataClientNonProfit: function(cmp, nonProfit) {
        if (nonProfit == null || nonProfit.type !== "nonProfit") {
            return;
        }

        cmp.set("v.nonProfit", nonProfit.value);
        let cps = cmp.get("v.clientPricingScenario");
        cps.Non_Profit__c = nonProfit.value;

        let action = cmp.get("c.SaveClientPricingScenario");
        action.setParams({"clientPricingScenario": cps});
        action.setCallback(this, function (response) {
            cmp.set("v.isLoading", false);
            if (response.getState() === "SUCCESS") {
                this.sendDataChangeAlert(cmp, "nonProfit");
            } 
            else {
                this.showToast(cmp, "Sorry to interrupt you", "An error occurred while saving Non-Profit info", "error", "sticky");
            }
        });
        $A.enqueueAction(action);
    },

    sendClientId: function (cmp, event) {
        this.fireStateChange(cmp, "recordId", cmp.get("v.recordId"));
    },

    sendEmpTableHeight: function (cmp, event, value) {
        this.fireStateChange(cmp, "empTableHeight", value);
    },

    fireStateChange: function (cmp, changeType, data) {
        let appEvent = $A.get("e.c:FluxContainer_getState");
        appEvent.setParams({"context": {"type": changeType, "value": data}});
        appEvent.fire();
    },

    showToast: function (cmp, title, message, variant, mode) {
        cmp.find("notifLib").showToast({"title": title, "message": message, "variant": variant, "mode": mode});
    },

    showNotice: function (cmp, title, message, variant, mode){
        cmp.find("notifLib").showNotice({"title": title, "message": message, "variant": variant, "mode": mode});
    },

    getSummaryWorksheet: function(cmp, event){
        cmp.set("v.isLoading", true);
        let action = cmp.get("c.getSummaryWorksheet");
        action.setParams({"recordId": cmp.get("v.recordId")});
        action.setCallback(this, function (data) {
            cmp.set("v.isLoading", false);
            if (data.getState() === "SUCCESS" && data.getReturnValue().length === 2) {
                let link = document.createElement("a");
                document.body.appendChild(link);
                let result = data.getReturnValue();
                let filename = result[0];
                let content = result[1];
                link.href = "data:text/excel;" + content;
                link.download = filename;
                link.click();
                document.body.removeChild(link);
            } 
            else {
                this.showToast(cmp, "Sorry to interrupt you", "An error occurred while loading the Client Pricing Scenario", "error", "sticky");
            }
        });
        $A.enqueueAction(action);
    },

    round: function(value, numberOfDecimalPoints) {
        let dp = 1;
        for(let i = 0; i < numberOfDecimalPoints; ++i) {
            dp *= 10;
        }
        return Math.round(dp * value) / dp;
    },

    saveSettingsAndCreateReport: function(cmp, event) {
        let cps = cmp.get("v.clientPricingScenario");
        cps.Notes__c = cmp.get("v.notes");
        cps.Non_Profit__c = cmp.get("v.nonProfit");
        cps.ZeroPayrollWcCodes__c = "";

        this.cancelPdf(cmp, event);
        this.includeZeroPayrollWcCodes(cmp);
        
        let action = cmp.get("c.saveReportSettings");
        action.setParams({
            "clientPricingScenario": cps,
            "wcCodes": cmp.get("v.zeroPayrollWcCodes")
        });
        action.setCallback(this, function (response) {
            cmp.set("v.isLoading", false);
            if (response.getState() === "SUCCESS") {
                this.createPdfReport(cmp);
            }
            else {
                this.showToast(cmp, "Sorry to interrupt you", "An error occurred while creating Pricing Summary Report", "error", "sticky");
            }
        });
        $A.enqueueAction(action);
    },

    initReportSetting: function (cmp) {
        this.initZeroPayrollWorkComps(cmp);
        cmp.set("v.openReportSettingDialog", true);
    },

    initZeroPayrollWorkComps: function (cmp) {
        let zeroPayrollWcCodes = [];
        let workComps = cmp.get("v.prcWorkComps");

        let sumObj = cmp.get("v.renewalSummaryObj");
        let marginOfPayroll = this.round(sumObj.MarginPercentPayroll__c, 2);
        let taxPercentOfPayroll = this.round(sumObj.YendTaxBurden_Percent__c, 2);
        let expensesPercentOfPayroll = this.round(sumObj.YendExpenses_Percent__c, 2);
        let commissionPercentOfPayroll = this.round(sumObj.YendCommissionPercent__c, 2);

        for (let i = 0; i < workComps.length; ++i) {
            let wc = workComps[i];
            if (wc.AnnualTaxablePayInCode__c === 0) {
                if (wc.Markup__c === 0) {
                    // Set the default values for Markup/OT/DT and SI Rate initialization - when Markup__c is ZERO
                    wc.Markup__c = this.round(marginOfPayroll + taxPercentOfPayroll + expensesPercentOfPayroll + commissionPercentOfPayroll + Number(wc.Modified_WC_Rate__c), 3);
                    wc.Markup_OverTime__c = this.round(wc.Markup__c - (Number(wc.Modified_WC_Rate__c) / 3), 3);
                    wc.Markup_DoubleTime__c = this.round(wc.Markup__c - (Number(wc.Modified_WC_Rate__c) / 2), 3);
                }
                zeroPayrollWcCodes.push(wc);
            }
        }
        cmp.set("v.zeroPayrollWcCodes", zeroPayrollWcCodes);
        cmp.set("v.prcWorkComps", workComps);

        this.saveZeroPayrollWcCodes(cmp, event, zeroPayrollWcCodes);
    },

    // Add the user selected zero payroll work comps to include in the report creation
    includeZeroPayrollWcCodes: function (cmp) {
        let zeroPayrollWcCodes = cmp.get("v.zeroPayrollWcCodes");
        let additionalWcCodes = cmp.find("zeroPayrollTable") ? cmp.find("zeroPayrollTable").getSelectedRows() : [];
        let selectedWcCodeMap = new Map();

        for (let i = 0; i < additionalWcCodes.length; ++i) {
            let wc = additionalWcCodes[i];
            selectedWcCodeMap.set(wc.State_Code__c + "." + wc.WC_Code__c, wc);
        }
        for (let i = 0; i < zeroPayrollWcCodes.length; ++i) {
            let wc = zeroPayrollWcCodes[i];
            wc.Include__c = selectedWcCodeMap.has(wc.State_Code__c + "." + wc.WC_Code__c);
        }

        cmp.set("v.zeroPayrollWcCodes", zeroPayrollWcCodes);
    },

    createPdfReport: function (cmp) {
        let report = cmp.get("v.selectedReport");
        if (report === "Pricing Summary Report") {
            this.createPricingSummaryReport(cmp);
        }
        else if (report.includes("Client Addendum")) {
            this.createClientAddendumReport(cmp);
        }
    },

    createPricingSummaryReport: function (cmp) {
        window.open("/apex/PricingSummaryReport?id=" + cmp.get("v.recordId"));
    },

    createClientAddendumReport: function (cmp) {
        let recordId = cmp.get("v.recordId");
        let includeOtDt = cmp.get("v.includeOtDt");
        let includeSi = cmp.get("v.includeSi");
        window.open("/apex/PricingClientAddendum?id=" + recordId + "&si=" + includeSi + "&includeOtDt=" + includeOtDt);
    },

    cancelPdf: function(cmp, event) {
        cmp.set("v.notes", "");
        cmp.set("v.openReportSettingDialog", false);
    },
    
    isMarkupValidated: function (cmp, draftValues, workComps) {
        for (let i = 0; i < draftValues.length; ++i) {
            let id = draftValues[i].Id;
            let markup = draftValues[i].Markup__c;
            for (let j = 0; j < workComps.length; ++j) {
                let wc = workComps[j];
                if (id === wc.Id && markup < wc.Modified_WC_Rate__c) {
                    this.showNotice(cmp, "Attention", wc.State_Code__c + "." + wc.WC_Code__c + ": Markup of " + markup + "% cannot be lower than Work Comp's Modified WC Rate " + wc.Modified_WC_Rate__c + "%", "warning", "dismissable");
                    return false;
                }
            }
        }
        return true;
    },

});