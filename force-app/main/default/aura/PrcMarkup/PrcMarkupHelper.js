/*
 * Copyright (c) 2018. Barrett Business Services, Inc. All Rights Reserved
 */
({
    loadData: function(cmp){
        cmp.set("v.isLoading", true);
        let action = cmp.get("c.getPricingWcCodes");
        action.setParams({"recordId":cmp.get("v.clientPricScenId")});
        action.setCallback(this, function(response) {
            cmp.set("v.isLoading", false);
            let state = response.getState();
            if(state === "SUCCESS"){
                let data = response.getReturnValue();
                cmp.set("v.data", data);
                if(data && data.length > 0) {
                    cmp.set("v.clientId", data[0].ClientPricingScenario__r.ClientId__c);
                    cmp.set("v.clientName", data[0].ClientPricingScenario__r.ClientName__c);
                }
                this.sumTotalMargin(cmp);
                this.sumTotalPayroll(cmp);
            }else{
                console.error("Get Pricing Scenario: ", response.getError());
            }
        });
        $A.enqueueAction(action);
    },

    saveNetMargin: function (cmp, markups) {
        let markupData = JSON.stringify(markups);
        cmp.set("v.isLoading", true);
        let action = cmp.get("c.savePricingWcCodes");
        action.setParams({"wcCodes": markupData});
        action.setCallback(this, function (response) {
            cmp.set("v.isLoading", false);
            let state = response.getState();
            if(state === "SUCCESS") {
                let option = cmp.find("applyMarginGroup").get("v.value");
                this.fireComponentEvent(cmp, "editMargin", option);
                cmp.find("markupTable").set("v.draftValues", null); // clear the Cancel & Save buttons
                this.loadData(cmp);
            }else{
                this.showToast(cmp, "Sorry to interrupt you", "An error occurred while attempting to save Markup changes", "error", "sticky");
            }
        });
        $A.enqueueAction(action);
    },

    saveMarginPerHead: function (cmp, markups) {
        this.buildMaps(cmp);
        let map = cmp.get("v.map");
        let displayWarningMessage = false;
        for (let i = 0; i < markups.length; ++i) {
            let fte = map.get(markups[i].Id).FTEInCode__c;
            if (fte < 0.1) { displayWarningMessage = true;}
            let marginPerHead = this.round(Number(markups[i].MarginPerHeadInCode__c), 2);
            let marginInCode = this.round(fte * marginPerHead, 2);
            markups[i].DesiredMarginDollars__c = marginInCode.toString();
        }

        if (displayWarningMessage) {
            this.showToast(cmp, "Attention", "Modifying Margin $ Per Head when FTE is zero will result in Margin $ Per Head and Net Margin equal to zero. Please modify Net Margin.", "warning", "dismissable");
        }

        this.saveNetMargin(cmp, markups);
    },

    saveMarkupPercent: function (cmp, markups, notifyParent) {
        cmp.set("v.isLoading", true);
        let markupData = JSON.stringify(markups);
        for (let i = 0; i < markups.length; ++i) {
            markupData = markupData.replace("DesiredMarginDollars__c", "");
        }

        let action = cmp.get("c.savePricingWcCodes");
        action.setParams({"wcCodes": markupData});
        action.setCallback(this, function (response) {
            cmp.set("v.isLoading", false);
            let state = response.getState();
            if(state === "SUCCESS") {
                cmp.find("markupTable").set("v.draftValues", null); // clear the Cancel & Save buttons
                if (notifyParent) {
                    this.fireComponentEvent(cmp, "editMarkup", "");
                }
                this.loadData(cmp);
            }else{
                this.showToast(cmp, "Sorry to interrupt you", "An error occurred while attempting to save Markup changes", "error", "sticky");
            }
        });
        $A.enqueueAction(action);
    },

    validateEditMarkupPercent: function (cmp, markups) {
        this.buildMaps(cmp);
        let map = cmp.get("v.map");
        for (let i = 0; i < markups.length; ++i) {
            let modifiedWcRate = map.get(markups[i].Id).Modified_WC_Rate__c;
            let markupPercent = markups[i].Markup__c;
            if (markupPercent < modifiedWcRate) {
                return false;
            }
        }
        return true;
    },

    buildMaps: function (cmp) {
        let data = cmp.get("v.data");
        let map = new Map();
        for (let i = 0; i < data.length; i++) {
            if(map.has(data[i].Id)) {
                continue;
            }
            map.set(data[i].Id, {
                "Id" : data[i].Id,
                "State_Code__c" : data[i].State_Code__c,
                "WC_Code__c" : data[i].WC_Code__c,
                "PercentOfPayroll__c" : data[i].PercentOfPayroll__c,
                "FTEInCode__c" : data[i].FTEInCode__c,
                "MarginPerHeadInCode__c" : data[i].MarginPerHeadInCode__c,
                "DesiredMarginDollars__c" : data[i].DesiredMarginDollars__c,
                "TaxBurdenPercentInCode__c" : data[i].TaxBurdenPercentInCode__c,
                "Modified_WC_Rate__c" : data[i].Modified_WC_Rate__c,
                "Markup__c" : data[i].Markup__c,
                "Markup_OverTime__c" : data[i].Markup_OverTime__c,
                "Markup_DoubleTime__c" : data[i].Markup_DoubleTime__c
            });
        }
        cmp.set("v.map", map);
    },

    sumTotalMargin: function (cmp) {
        let sumMargin = 0;
        let totFTE = 0;
        let dataSet = cmp.get("v.data");

        for(let i = 0; i< dataSet.length; i++){
            sumMargin += Number(dataSet[i].DesiredMarginDollars__c);
            totFTE += Number(dataSet[i].FTEInCode__c);
        }
        sumMargin = Number(sumMargin.toFixed(2));
        totFTE = Number(totFTE.toFixed(1));

        cmp.set("v.totFTE", totFTE);
        cmp.set("v.sumGrossMargin", sumMargin);
        cmp.set("v.totalGrossMargin", sumMargin);
    },

    sumTotalPayroll: function (cmp) {
        // sum values for table footer
        let sumPayroll = 0;
        let dataSet = cmp.get("v.data");
        for(let i = 0; i< dataSet.length; i++){
            if(dataSet[i].PricingEEtoWcCodeAssocs__r == null){
                continue;
            }
            for(let j = 0; j < dataSet[i].PricingEEtoWcCodeAssocs__r.length; j++){
                sumPayroll += Number(dataSet[i].PricingEEtoWcCodeAssocs__r[j].AnnualPayInCode__c);
            }
        }
        // set attributes
        cmp.set("v.totPayroll", sumPayroll);
    },

    applyTotalGrossMargin: function (cmp, totalMarginDesired, type){
        totalMarginDesired = Number(totalMarginDesired);
        let totalMargin = Number(cmp.get("v.sumGrossMargin"));
        let dataSet = cmp.get("v.data");
        let sumMargin = Number(0);
        let highestMarginIndex = 0;
        let highestMarginDollars = 0;

        if(type === "optMargin"){
            if(totalMargin == 0){
                this.showToast(cmp, "Attention", "Cannot continue, current margin is 0", "warning", "dismissable" );
                return;
            }
            if(totalMargin == totalMarginDesired){
                this.showToast(cmp, "Attention", "Requested margin already equals current margin", "warning", "dismissable" );
                return;
            }
            let modFactor = totalMarginDesired / totalMargin;
            for(let i = 0; i < dataSet.length; i++){
                let marginDollars =  Number((modFactor * Number(dataSet[i].DesiredMarginDollars__c)).toFixed(2));
                dataSet[i].DesiredMarginDollars__c = marginDollars;
                sumMargin = Number((sumMargin + marginDollars).toFixed(2));
                if(marginDollars> highestMarginDollars){
                    highestMarginDollars = marginDollars;
                    highestMarginIndex = i;
                }
            }
        }
        else if(type === "optPayroll"){
            let totalPayroll = cmp.get("v.totPayroll");
            if(totalPayroll == 0){
                this.showToast(cmp, "Attention", "Cannot continue, total payroll is 0", "warning", "dismissable" );
                return;
            }
            for(let i = 0; i < dataSet.length; i++){
                let marginDollars = Math.round(totalMarginDesired * Number(Number(dataSet[i].PercentOfPayroll__c).toFixed(2))) / 100;
                dataSet[i].DesiredMarginDollars__c = marginDollars;
                sumMargin = Number((sumMargin + marginDollars).toFixed(2));
                if(marginDollars > highestMarginDollars){
                    highestMarginDollars = marginDollars;
                    highestMarginIndex = i;
                }
            }
        }

        if(totalMarginDesired != sumMargin){
            let diffMargin = Number((totalMarginDesired - sumMargin).toFixed(2));
            dataSet[highestMarginIndex].DesiredMarginDollars__c += diffMargin;
            sumMargin = sumMargin + diffMargin;
        }

        cmp.set("v.sumGrossMargin", sumMargin);
        cmp.set("v.totalGrossMargin", sumMargin);
        cmp.set("v.data", dataSet);

        this.saveNetMargin(cmp, dataSet);
    },

    validateMarginInput: function(cmp, event, wcCode){
        let dataSet = cmp.get("v.data");
        for (let i = 0; i < dataSet.length; i++) {
            if(dataSet[i].Id === wcCode.Id){
                if(dataSet[i].AnnualPayInCode__c === 0){
                    cmp.set("v.errors", {
                        "table": {
                            "title": "You can not assign margin to a work comp code with no associated payroll. Fix the errors and try again.",
                            "messages": [
                            ]
                        }
                    });
                    this.showToast(cmp, "Error", "You can not assign margin to a work comp code with no associated payroll. Fix the errors and try again.", "error", "sticky");
                }
            }
        }
    },

    updateFooterTotals: function (cmp, event, sumData) {
        cmp.set("v.taxBurdenPercent", sumData.YendTaxBurden_Percent__c);
        cmp.set("v.taxBurdenPercentNoOwner", sumData.YendTaxBurden_PercentNo1k__c);
        cmp.set("v.commissionPercent", sumData.YendCommissionPercent__c);
        cmp.set("v.expensesPercent", sumData.YendExpenses_Percent__c);
    },

    fireComponentEvent : function(cmp, type, data) {
        let compName = cmp.get("v.containerName");
        let compEvent = cmp.getEvent("setState");

        compEvent.setParams({
            "newState": {
                "component": compName,
                "type": type,
                "value": data
            }
        });
        compEvent.fire();
    },

    changeRecordId: function (cmp, event, recId) {
        cmp.set("v.clientPricScenId", recId);
        this.loadData(cmp, event);
    },

    showToast: function (cmp, title, message, variant, mode){
        cmp.find("notifLib").showToast({
            "title": title,
            "message": message,
            "variant": variant,
            "mode": mode
        });
    },

    getBillingHistory: function(cmp, event) {
        cmp.set("v.isLoading", true);
        let action = cmp.get("c.getBillingHistories");
        action.setParams({"clientId": cmp.get("v.clientId")});
        action.setCallback(this, function(response) {
            let state = response.getState();
            if(state === "SUCCESS"){
                let priceInfo = response.getReturnValue();
                priceInfo.sort( function(a,b) {
                    let t1 = a.WC_Code__c.replace('.','') + a.Pay_Code__c == b.WC_Code__c.replace('.','') + b.Pay_Code__c;
                    let t2 = a.WC_Code__c.replace('.','') + a.Pay_Code__c  > b.WC_Code__c.replace('.','') + b.Pay_Code__c;
                    return t1 ? 0 : t2 ? 1 : -1;
                });
                cmp.set("v.bhData", priceInfo);
                cmp.set("v.isBillingHistoryOpen", true);
            }else{
                this.showToast(cmp, "Sorry to interrupt you", "An error occurred while retrieving client's current markups", "error", "sticky");
            }
            cmp.set("v.isLoading", false);
        });
        $A.enqueueAction(action);
    },

    round: function(value, numberOfDecimalPoints) {
        let dp = 1;
        for(let i = 0; i < numberOfDecimalPoints; ++i) {
            dp *= 10;
        }
        return Math.round(dp * value) / dp;
    }
});