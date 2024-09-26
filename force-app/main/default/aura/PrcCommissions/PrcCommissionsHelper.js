/*
 * Copyright (c) 2018. Barrett Business Services, Inc. All Rights Reserved
 */

({
    loadData: function (cmp, event) {
        cmp.set("v.isLoading", true);
        var action = cmp.get("c.getClientPricingScenario");
        action.setParams({ "recordId" : cmp.get("v.clientPricScenId") });

        action.setCallback(this, function(response) {
            cmp.set("v.isLoading", false);
            if(response.getState() === "SUCCESS"){
                console.log("SUCCESS client pricing scenario loadData");
                var resultset = response.getReturnValue();
                cmp.set("v.clientPricingScenarioObj", resultset);
                cmp.set("v.noReferralPartner", !resultset.HasReferralPartner__c);
                cmp.set("v.noBdm", !resultset.HasBdm__c);
                this.loadCustomDataset(cmp, event, resultset);
            } else{
                this.showToast(cmp, "Sorry to interrupt you", "An error occurred while loading the Client Pricing Scenario", "error", "sticky");
                console.error("Get Pricing Scenario: ", response.getError());
            }
        });
        $A.enqueueAction(action);
    },
    
    loadCustomDataset: function(cmp, event, cpsData){
        var Commissions = cmp.get("v.commissionData");
        // Referral Partner Row
        Commissions[0].CommissionType = "Referral Partner Commission";
        Commissions[0].Description = cpsData.commCompany__c;
        Commissions[0].ContractYearRate = "N/A";
        Commissions[0].ContractYearAmt = cpsData.ysumComms__c;
        Commissions[0].RenewalYearRate = cpsData.HasReferralPartner__c === true ? cpsData.commRateRenewal__c : "0";
        Commissions[0].RenewalYearAmt = cmp.get("v.renewalYearCommAmt");

        // BDM Row
        Commissions[1].CommissionType = "BDM Commission";
        Commissions[1].Description = cpsData.BDM__c;
        Commissions[1].ContractYearRate = Number(cpsData.BDM_Rate__c).toFixed(2); // toFixed method returns a String
        Commissions[1].ContractYearAmt = cpsData.ysumCommsBdm__c;
        Commissions[1].RenewalYearRate = cpsData.HasBdm__c === true ? cpsData.BDM_Rate_Renewal__c : "0";
        Commissions[1].RenewalYearAmt = cmp.get("v.renewalYearBdmAmt");
        cmp.set("v.commissionData", Commissions);
        this.updateCommissionTotals(cmp, event);
    },

    changeRecordId: function (cmp, event, recId) {
        cmp.set("v.clientPricScenId", recId);
        this.loadData(cmp, event);
    },

    init: function (cmp) {
        cmp.set("v.columns", [
            {label: "Commission Type", fieldName: "CommissionType", type: "text"},
            {label: "Description", fieldName: "Description", type: "text"},
            /*  Rates are type **text** because the value may be "N/A"  */
            {label: "Contract Year Rate", fieldName: "ContractYearRate", type: "text", cellAttributes: {alignment: "right"}},
            {label: "Contract Year Amount", fieldName: "ContractYearAmt", type: "currency"},
            {label: "Renewal Year Rate", fieldName: "RenewalYearRate", type: "number", typeAttributes: {minimumFractionDigits: "2", maximumFractionDigits: "2"}},
            {label: "Renewal Year Amount", fieldName: "RenewalYearAmt", type: "currency"}
        ]);
    },
    
    initProspect: function (cmp) {
        cmp.set("v.columns", [
            {label: "Commission Type", fieldName: "CommissionType", type: "text"},
            {label: "Description", fieldName: "Description", type: "text"},
            {label: "Rate", fieldName: "RenewalYearRate", type: "number", typeAttributes: {minimumFractionDigits: "2", maximumFractionDigits: "2"}},
            {label: "Amount", fieldName: "RenewalYearAmt", type: "currency"},
            {label: "", fieldName: "", type: "text", initialWidth: 5},
            {label: "", fieldName: "", type: "text", initialWidth: 5}
        ]);
    },

    initCustomDataset: function (cmp) {
        var commData = {"Commissions":[{"CommissionType":"","Description":"","ContractYearRate":"","ContractYearAmt":0,"RenewalYearRate":0,"RenewalYearAmt":0},{"CommissionType":"","Description":"","ContractYearRate":"","ContractYearAmt":0,"RenewalYearRate":0,"RenewalYearAmt":0}]};
        cmp.set("v.commissionData", commData.Commissions);
    },

    setCommRateState: function(cmp, dataValues){
        for(var i = 0; i < dataValues.length; i++) {
            if(dataValues[i].Id === "row-0") {
                this.setRefPartComm(cmp, dataValues[i].RenewalYearRate);
            } else if(dataValues[i].Id === "row-1") {
                this.setBdmComm(cmp, dataValues[i].RenewalYearRate);
            }
        }
    },

    setRefPartComm: function (cmp, data){
        var commRate = Number(data);
        var commData = {"refPartRate" : commRate};
        
        var Commissions = cmp.get("v.commissionData");
        Commissions[0].RenewalYearRate = Number(commRate);
        cmp.set("v.commissionData", Commissions);
        cmp.find("commissionTable").set("v.draftValues", null);

        this.fireComponentEvent(cmp, "commChanged", commData);
    },

    setBdmComm: function (cmp, data){
        var commRate = Number(data);
        var commData = {"bdmRate" : commRate};
        
        var Commissions = cmp.get("v.commissionData");
        Commissions[1].RenewalYearRate = Number(commRate);
        cmp.set("v.commissionData", Commissions);
        cmp.find("commissionTable").set("v.draftValues", null);

        this.fireComponentEvent(cmp, "commChanged", commData);
    },

    saveUseReferralPartner: function (cmp, hasReferralPartner) {
        let data = {"hasReferralPartner": hasReferralPartner};
        this.fireComponentEvent(cmp, "commChanged", data);
    },
    
    saveUseBdm: function (cmp, hasBdm) {
        let data = {"hasBdm": hasBdm};
        this.fireComponentEvent(cmp, "commChanged", data);
    },

    updateFooterTotals: function (cmp, event, sumData) {
        cmp.set("v.renewalYearCommAmt", sumData.YendComms__c);
        cmp.set("v.renewalYearBdmAmt", sumData.YendCommsBdm__c);
        cmp.set("v.commissionPercent", sumData.YendCommissionPercent__c);

        var commData = cmp.get("v.commissionData");
        commData[0].RenewalYearAmt = sumData.YendComms__c;
        commData[1].RenewalYearAmt = sumData.YendCommsBdm__c;
        cmp.set("v.commissionData", commData);

        this.updateCommissionTotals(cmp, event);
    },

    // update commision table footer values
    updateCommissionTotals: function (cmp, event) {
        var sumContractYear = 0;
        var sumRenewalYear = 0;
        var dataSet = cmp.get("v.commissionData");

        for(var i = 0; i < dataSet.length; i++){
            sumContractYear += Number(dataSet[i].ContractYearAmt);
            sumRenewalYear += Number(dataSet[i].RenewalYearAmt);
        }

        cmp.set("v.totalCommContractYear", sumContractYear);
        cmp.set("v.totalCommRenewalYear", sumRenewalYear);
    },

    setIsProspect: function (cmp, isProspect) {
        cmp.set("v.isProspect", isProspect);
        if (isProspect) {
            this.initProspect(cmp);
        } else {
            this.init(cmp);
        }
    },
    
    fireComponentEvent : function(cmp, type, data) {
        var compName = cmp.get("v.containerName");
        var compEvent = cmp.getEvent("setState");

        compEvent.setParams({
            "newState": { 
                "component": compName,
                "type": type,
                "value": data
            }
        });

        compEvent.fire();
    },
    
    showToast: function (cmp, title, message, variant, mode){
        cmp.find("notifLib").showToast({"title": title, "message": message, "variant": variant, "mode": mode});
    }
});