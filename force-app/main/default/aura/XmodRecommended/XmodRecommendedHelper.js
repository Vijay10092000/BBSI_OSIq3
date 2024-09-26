/**
 * Created by CElim on 2/25/2019.
 */
({
    showToast: function (cmp, title, message, variant, mode){
        cmp.find("notificationLibrary").showToast({ "title": title, "message": message, "variant": variant, "mode": mode });
    },
    
    clearFile: function(cmp){
        cmp.find("file").getElement().value='';
    },

    parseFile: function(cmp, csv){
        var jsonData = this.parseCsvToJson(cmp, csv);
        this.saveRecommendedXmods(cmp, jsonData);
        this.getRecommendedXmods(cmp);
    },

    parseCsvToJson: function (cmp, csv) {
        var arr = csv.split('\n');;
        arr.pop();

        arr[0] = arr[0].replace("EffDate", "Effective_Date__c");
        arr[0] = arr[0].replace("Recommendation", "Xmod__c");
        arr[0] = arr[0].replace("State", "State_Code__c");
        arr[0] = arr[0].replace("PolicyNumber", "Policy_Number__c");
        arr[0] = arr[0].replace("CompanyNumber", "Client_Info__c");
        arr[0] = arr[0].replace("Notes", "Notes__c");
        var headers = arr[0].split(',');

        var jsonObj = [];
        for(var i = 1; i < arr.length; i++) {
            if(arr[i].length === 6){
                continue;
            }
            var quotes = arr[i].match(/".*?"/g);
            if(quotes){
                for(var q = 0; q < quotes.length; ++q) {
                    arr[i] = arr[i].replace(quotes[q], "quote");
                    quotes[q] = quotes[q].replace('"', '').replace('"', '');
                }
            }

            var data = arr[i].split(',');
            if(quotes){
                q = 0;
                for(var d = 0; d < data.length; ++d){
                    if(q >= quotes.length){
                        break;
                    }
                    if(data[d] === "quote"){
                        data[d] = quotes[q++];
                    }
                }
            }

            var obj = {};
            console.log(data);
            for(var j = 0; j < data.length; j++) {
                obj[headers[j].trim()] = data[j].trim();
            }
            jsonObj.push(obj);
        }
        return JSON.stringify(jsonObj);
    },

    getRecommendedXmods: function(cmp){
        cmp.set("v.isLoading", true);
        var action = cmp.get("c.getXmodRecommended");
        action.setCallback(this, function(response) {
            cmp.set("v.isLoading", false);
            var state = response.getState();
            if(state === "SUCCESS"){
                var data = response.getReturnValue();
                if (!data || data.length == 0) {
                    data = null;
                }
                cmp.set("v.recommendedXmodData", data);
            }
            else{
                this.showToast(cmp, "Error", "An error occurred while saving and parsing the Recommended Xmod file", "error", "sticky");
            }
        });
        $A.enqueueAction(action);
    },

    saveRecommendedXmods: function(cmp, jsonData){
        cmp.set("v.isLoading", true);
        var action = cmp.get("c.saveXmodRecommended");
        action.setParams({"records": jsonData});
        action.setCallback(this, function(response) {
            cmp.set("v.isLoading", false);
            var state = response.getState();
            if(state === "SUCCESS"){
                var errorLog = response.getReturnValue();
                if(errorLog.length > 0){
                    this.showToast(cmp, "Error", "The following policy numbers cannot be found: " + errorLog, "error", "sticky");
                }
            }else{
                this.showToast(cmp, "Error", "An error occurred while saving and parsing the Recommended Xmod file", "error", "sticky");
            }
            this.clearFile(cmp);

        });
        $A.enqueueAction(action);
    },
    
    resetDisplayReports: function (cmp) {
        cmp.set("v.displayRecommendedXmod", false);
        cmp.set("v.displayWcPolicyMapping", false);
    },

    getWcPolicies: function (cmp) {
        cmp.set("v.isLoading", true);
        var action = cmp.get("c.getWorkCompPolicyDisplayNameMappings");
        action.setCallback(this, function(response) {
            cmp.set("v.isLoading", false);
            var state = response.getState();
            if(state === "SUCCESS") {
                cmp.set("v.wcPolicyData", response.getReturnValue());
            }
            else {
                this.showToast(cmp, "Error", "An error occurred while saving and parsing the Recommended Xmod file", "error", "sticky");
            }
            this.clearFile(cmp);
        });
        $A.enqueueAction(action);
    },

    saveWcPolicy: function (cmp, wcPolicyData) {
        cmp.set("v.isLoading", true);
        var action = cmp.get("c.saveWorkCompPolicyDisplayNameMappings");
        action.setParams({"policies": JSON.stringify(wcPolicyData)});
        action.setCallback(this, function (response) {
            cmp.set("v.isLoading", false);
            var state = response.getState();
            if (state === "SUCCESS") {
                if (cmp.find("wcPolicyMappingTable")) {
                    cmp.find("wcPolicyMappingTable").set("v.draftValues", null); // clear the Cancel & Save buttons
                }
                this.getWcPolicies(cmp);
            } 
            else {
                this.showToast(cmp, "Sorry to interrupt you", "An error occurred while saving the WC Policy Mapping value", "error", "sticky");
            }
        });
        $A.enqueueAction(action);
    },

    initStateCodes: function (cmp) {
        var stateCodes = [{"stateCode":"AL","label":"Alabama"},{"stateCode":"AK","label":"Alaska"},{"stateCode":"AZ","label":"Arizona"},{"stateCode":"AR","label":"Arkansas"},{"stateCode":"CA","label":"California"},{"stateCode":"CO","label":"Colorado"},{"stateCode":"CT","label":"Connecticut"},{"stateCode":"DE","label":"Delaware"},{"stateCode":"DC","label":"District of Columbia"},{"stateCode":"FL","label":"Florida"},{"stateCode":"GA","label":"Georgia"},{"stateCode":"HI","label":"Hawaii"},{"stateCode":"ID","label":"Idaho"},{"stateCode":"IL","label":"Illinois"},{"stateCode":"IN","label":"Indiana"},{"stateCode":"IA","label":"Iowa"},{"stateCode":"KS","label":"Kansas"},{"stateCode":"KY","label":"Kentucky"},{"stateCode":"LA","label":"Louisiana"},{"stateCode":"ME","label":"Maine"},{"stateCode":"MT","label":"Montana"},{"stateCode":"NE","label":"Nebraska"},{"stateCode":"NV","label":"Nevada"},{"stateCode":"NH","label":"New Hampshire"},{"stateCode":"NJ","label":"New Jersey"},{"stateCode":"NM","label":"New Mexico"},{"stateCode":"NY","label":"New York"},{"stateCode":"NC","label":"North Carolina"},{"stateCode":"ND","label":"North Dakota"},{"stateCode":"OH","label":"Ohio"},{"stateCode":"OK","label":"Oklahoma"},{"stateCode":"OR","label":"Oregon"},{"stateCode":"MD","label":"Maryland"},{"stateCode":"MA","label":"Massachusetts"},{"stateCode":"MI","label":"Michigan"},{"stateCode":"MN","label":"Minnesota"},{"stateCode":"MS","label":"Mississippi"},{"stateCode":"MO","label":"Missouri"},{"stateCode":"PA","label":"Pennsylvania"},{"stateCode":"RI","label":"Rhode Island"},{"stateCode":"SC","label":"South Carolina"},{"stateCode":"SD","label":"South Dakota"},{"stateCode":"TN","label":"Tennessee"},{"stateCode":"TX","label":"Texas"},{"stateCode":"UT","label":"Utah"},{"stateCode":"VT","label":"Vermont"},{"stateCode":"VA","label":"Virginia"},{"stateCode":"WA","label":"Washington"},{"stateCode":"WV","label":"West Virginia"},{"stateCode":"WI","label":"Wisconsin"},{"stateCode":"WY","label":"Wyoming"}];
        cmp.set("v.stateCodes", stateCodes);
    },

    saveNewWcPolicy: function (cmp, event, newWcPolicy) {
        let wcPolicyData = [];
        wcPolicyData.push(newWcPolicy);
        
        let action = cmp.get("c.addWorkCompPolicyDisplayNameMappings");
        action.setParams({ "policies" : wcPolicyData});
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                this.getWcPolicies(cmp);
            }
            else {
                console.error("Save New W/C Policy: " + response.getError());
                this.showToast(cmp, "Sorry to interrupt you", "Unable to save new W/C Policy", "error", "sticky");
            }
        });
        $A.enqueueAction(action);
    }
});