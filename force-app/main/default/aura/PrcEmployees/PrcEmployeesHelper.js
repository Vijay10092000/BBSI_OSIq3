/*
 * Copyright (c) 2018. Barrett Business Services, Inc. All Rights Reserved
 */
({
    loadData: function(cmp, event){
        cmp.set("v.isLoading", true);
        let action = cmp.get("c.getPricingEmployees");
        action.setParams({"recordId": cmp.get("v.clientPricScenId")});
        action.setCallback(this, function(response) {
            cmp.set("v.isLoading", false);
            let state = response.getState();
            if(state === "SUCCESS"){                                                         
                let data = response.getReturnValue();
                cmp.set("v.data", data);
                if(data && data.length > 0){
                    let projFactor = Number(data[0].ClientPricingScenario__r.projectionFactor__c);
                    cmp.set("v.projFactor", projFactor);
                }
                this.loadWcCodes(cmp, event);
            }else{
                console.error("Error loading Employee data: ", response.getError());
            }
        });
        $A.enqueueAction(action);
    },

    loadWcCodes : function (cmp, event){
        cmp.set("v.isLoading", true);
        let action = cmp.get("c.getPricingWcCodes");
        action.setParams({"recordId":cmp.get("v.clientPricScenId")});
        action.setCallback(this, function(response) {
            cmp.set("v.isLoading", false);
            let state = response.getState();
            if(state === "SUCCESS") {
                let res = response.getReturnValue();
                for(let i = 0; i < res.length; i++){
                    res[i].label = res[i].WC_Code__c + " " + res[i].State_Code__c;
                }
                cmp.set("v.wcCodeList", res);
                cmp.set("v.wcSummaryData", res);
                this.afterLoadData(cmp, event);
            }else{
                console.log("Error loading Employee WC Code list: ", response);
            }
        });
        $A.enqueueAction(action);
    },
    
    afterLoadData: function (cmp, event) {
        // sum values for table footer
        let employeeList = cmp.get("v.data");

        let totalEEs = 0;
        let activeEEs = 0;
        let hours = 0;
        let totPay = 0;
        let erTaxes = 0;
        for(let i = 0; i < employeeList.length; i++){
            totalEEs += Number(employeeList[i].Qty__c);
            if(employeeList[i].IsActive__c){
                activeEEs += Number(employeeList[i].Qty__c);
            }
            // do not multiply by Qty -- amounts below already account for qty
            hours += Number(employeeList[i].AnnualHours__c);
            totPay += Number(employeeList[i].AnnualTaxablePay__c);
            erTaxes += Number(employeeList[i].EstimatedERTax__c);
        }
        // set attributes
        cmp.set("v.totalEmployees", Number(totalEEs));
        cmp.set("v.activeEmployees", Number(activeEEs));
        cmp.set("v.annualHours", Number(hours));
        cmp.set("v.annualPay", Number(totPay));
        cmp.set("v.estTaxes", Number(erTaxes));

        if(employeeList.length >= 10)
        {
            this.setFixedHeight(cmp);
        }
        else
        {
            this.setAutoHeight(cmp);
        }
    },

    setAutoHeight: function(cmp){
        cmp.set("v.eeTableHeight", "height:auto");
    },

    setFixedHeight: function(cmp){
        cmp.set("v.eeTableHeight", "height:440px");
    },

    initNewEmployee: function(cmp, event){
        const newEE = new Object();
        newEE.ClientPricingScenario__c = cmp.get("v.clientPricScenId");
        newEE.Id = null;
        newEE.Employee_Name__c = "";
        newEE.Qty__c = 1;
        newEE.Primary_WC_Code__c = "";
        newEE.PrimaryPricingWcCode__c = "";
        newEE.State_Code__c = "";
        newEE.IsActive__c = true;
        newEE.IsOwner__c = false;
        newEE.IsUpdate__c = false;
        newEE.AnnualHours__c = 0;
        newEE.AnnualPay__c = 0;
        newEE.HourlyRate__c = 0;
        cmp.set("v.newEmployee", newEE);
    },

    initNewWc: function (cmp, event) {
        const newWc = new Object();
        newWc.ClientPricingScenario__c = cmp.get("v.clientPricScenId");
        newWc.Id = null;
        newWc.Employee_Name__c = "";
        newWc.Qty__c = 0;
        newWc.Primary_WC_Code__c = "";
        newWc.PrimaryPricingWcCode__c = "";
        newWc.State_Code__c = "";
        newWc.IsActive__c = true;
        newWc.IsOwner__c = false;
        newWc.IsUpdate__c = true;
        newWc.AnnualHours__c = 0;
        newWc.AnnualPay__c = 0;
        newWc.HourlyRate__c = 0;
        cmp.set("v.newWc", newWc);
    },

    saveNewEmployee : function(cmp, event, newEmployee) {
        if (newEmployee.PrimaryPricingWcCode__c === "") {
            return this.showToast(cmp, "Sorry to interrupt you", "Please specify WC Code (required)", "error", "sticky");
        }

        let hours = Number(newEmployee.AnnualHours__c);
        let pay = Number(newEmployee.AnnualPay__c);

        let action = cmp.get("c.addEmployee");
        action.setParams({
            "newEE": newEmployee,
            "annualPay": pay,
            "annualHours": hours
        });
        action.setCallback(this, function(response) {
            let state = response.getState();
            cmp.set("v.showAddEmployee", false);
            cmp.set("v.showModifyByWcCode", false);
            if(state === "SUCCESS"){
                this.fireComponentEvent(cmp, "dataSaved", "");
            } else{
                console.error("Save New Employee: " + response.getError());
                this.showToast(cmp, "Sorry to interrupt you", "Unable to save new employee", "error", "sticky");
            }
        });
        $A.enqueueAction(action);
    },

    deleteEmployee : function(cmp, event, row) {
        let eeToDel = JSON.stringify(row);
        let action = cmp.get("c.deleteEmployee");
        action.setParams({"eeToDelete":eeToDel});
        action.setCallback(this, function(response) {
            let state = response.getState();
            if(state === "SUCCESS"){
                this.fireComponentEvent(cmp, "dataSaved", "");
            } else{
                this.showToast(cmp,"Sorry to interrupt you", "Unable to delete employee", "error", "sticky");
            }
        });
        $A.enqueueAction(action);
    },

    saveEmployees : function (cmp, event, draftValues){
        let draftJson = JSON.stringify(draftValues);
        let action = cmp.get("c.saveEmployeesAndHours");
        action.setParams({"eeList": draftJson} );
        action.setCallback(this, function(response) {
            let state = response.getState();
            if(state === "SUCCESS"){
                this.fireComponentEvent(cmp, "dataSaved", "");
                cmp.find("employeesTable").set("v.draftValues", null); // clear the Cancel and Save buttons
            } else{
                this.showToast(cmp,"Sorry to interrupt you", "Unable to save employees", "error", "sticky");
            }
        });
        $A.enqueueAction(action);
    },

    changeRecordId: function (cmp, event, recId) {
        cmp.set("v.clientPricScenId", recId);
        this.loadData(cmp, event);
    },

    setEmpTableHeight: function(cmp, tblHeight){
        switch(tblHeight) {
            case "fixed":
                this.setFixedHeight(cmp);
                break;
            default :
                this.setAutoHeight(cmp);
        }
    },
    sortData: function (cmp, fieldName, sortDirection) {
        let data = cmp.get("v.data");
        let reverse = sortDirection !== "asc";

        data = Object.assign([],
            data.sort(this.sortBy(fieldName, reverse ? -1 : 1))
        );
        cmp.set("v.data", data);
    },
    sortBy: function (field, reverse, primer) {
        let key = primer
            ? function(x) { return primer(x[field]) }
            : function(x) { return x[field] };

        return function (a, b) {
            let A = key(a);
            let B = key(b);
            return reverse * ((A > B) - (B > A));
        };
    },

    updateFooterTotals: function (cmp, event, sumData) {
        // set attributes
        cmp.set("v.taxBurdenPercent", sumData.YendTaxBurden_Percent__c);
        cmp.set("v.taxBurdenPercentNoOwner", sumData.YendTaxBurden_PercentNo1k__c);
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

    showToast: function (cmp, title, message, variant, mode){
        cmp.find("notifLib").showToast({"title": title, "message": message, "variant": variant, "mode": mode});
    },

    showNotice: function (cmp, title, message, variant, mode){
        cmp.find("notifLib").showNotice({"title": title, "message": message, "variant": variant, "mode": mode});
    }
});