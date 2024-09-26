/*
 * Copyright (c) 2018. Barrett Business Services, Inc. All Rights Reserved
 */

({
    loadData: function (cmp, event) {
        cmp.set("v.isLoading", true);
        let action = cmp.get("c.getPricingScenario");
        let param = cmp.get("v.recordId");
        action.setParams({ "recordId" : param });

        action.setCallback(this, function(result) {
            cmp.set("v.isLoading", false);
            if(result.getState() === "SUCCESS"){
                cmp.set("v.isLoading", false);
                let data = result.getReturnValue();
                cmp.set("v.pricingScenario", data);
                cmp.set("v.scenarioName", data.ScenarioName__c);
                cmp.set("v.renewalDate", data.Renewal__r.Renewal_Date_Add_1__c);
                this.initChildAttributes(cmp, event, data.ClientPricingScenarios__r);
                this.loadRenewal(cmp, event);
            } else{
                console.error("Get Pricing Scenario: ", result.getError());
            }

        });
        $A.enqueueAction(action);
    },
    
    loadRenewal: function (cmp, event) {
        cmp.set("v.isLoading", true);
        let pricingScenario = cmp.get("v.pricingScenario");
        let action = cmp.get("c.getRenewal");
        action.setParams({ "recordId" : pricingScenario.Renewal__c });
        action.setCallback(this, function(result) {
            cmp.set("v.isLoading", false);
            if(result.getState() === "SUCCESS"){
                cmp.set("v.renewal", result.getReturnValue());
                cmp.set("v.isLoading", false);
            } else{
                console.error("Get Pricing Scenario: ", result.getError());
            }
        });
        $A.enqueueAction(action);
    },

    loadClientPricingScenario: function (cmp) {
        cmp.set("v.isLoading", true);
        let cpsId = cmp.get("v.selectedClient_ScenarioId");
        let action = cmp.get("c.getClientPricingScenario");
        action.setParams({ "recordId" : cpsId});
        action.setCallback(this, function(result) {
            cmp.set("v.isLoading", false);
            if(result.getState() === "SUCCESS"){
                cmp.set("v.isLoading", false);
                let cps = result.getReturnValue();
                cmp.set("v.opportunityLink", "/lightning/r/Opportunity/" + cps.Opportunity__c + "/view");
                cmp.set("v.clientPricingScenario", cps);
                this.setIsProspect(cmp, cps.IsProspect__c);
            } else{
                console.error("Get Client Pricing Scenario: ", result.getError());
            }
        });
        $A.enqueueAction(action);        
    },
    
    initChildAttributes: function(cmp, event, clientList){
        if(!clientList || clientList == null || !clientList == undefined)
        {
            return;
        }

        for(let i = 0; i < clientList.length; i++){
            let clientId = (clientList[i].ClientId__c) ? clientList[i].ClientId__c : '';
            let clientName = clientList[i].ClientName__c
            clientList[i].label = clientId + " " + clientName;
        }

        cmp.set("v.clientScenarioList", clientList);
        cmp.set("v.selectedClient_ScenarioId", clientList[0].Id);
        this.loadClientPricingScenario(cmp);

        // notify child components
        this.pushChildClientScenarioRecordId(cmp, event, clientList[0].Id);
    },

    pushChildClientScenarioRecordId: function(cmp, event, scenRecId){
        let clientComponent = cmp.find("clientScenarioComp");
        clientComponent.changeRenewalDate(cmp.get("v.renewalDate"));
        clientComponent.changeRecordId(scenRecId);
    },

    defineColumns: function (cmp, event) {
    },

    createClientWorksheetSummary: function(cmp, event) {
        let clientComponent = cmp.find("clientScenarioComp");
        clientComponent.createWorksheetSummary();
    },

    createPdf: function(cmp, event) {
        cmp.find("clientScenarioComp").createPdf(cmp.get("v.selectedReport"));
    },

    setIsProspect: function (cmp, isProspect) {
        cmp.set("v.isProspect", isProspect);
        if (isProspect) {
            this.initProspect(cmp);
        } else {
            this.init(cmp);
        }
    },

    init: function (cmp) {
        let reportTypes = ["Pricing Summary Report", "Client Addendum with S/I", "Client Addendum without S/I"];
        cmp.set("v.reportOptions", reportTypes);
        cmp.set("v.selectedReport", reportTypes[0]);
    },

    initProspect: function (cmp) {
        let reportTypes = ["Pricing Summary Report"];
        cmp.set("v.reportOptions", reportTypes);
        cmp.set("v.selectedReport", reportTypes[0]);
    },

    showToast: function (cmp, title, message, variant, mode) {
        cmp.find("notifLib").showToast({"title": title, "message": message, "variant": variant, "mode": mode});
    },

});