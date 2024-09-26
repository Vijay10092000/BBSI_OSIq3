/**
 * Created by CElim on 2/25/2019.
 */
({
    init: function (cmp, event, helper) {
        cmp.set("v.recommendedXmodColumns", [
            {label: "State", fieldName: "State_Code__c", type: "text"},
            {label: "Effective Date", fieldName: "Effective_Date__c", type: "date-local"},
            {label: "Policy Number", fieldName: "Policy_Number__c", type: "text"},
            {label: "Client ID", fieldName: "Client_Info__c", type: "text"},
            {label: "Notes", fieldName: "Notes__c", type: "text"},
            {label: "Xmod", fieldName: "Xmod__c", type: "number", typeAttributes: {minimumFractionDigits: "4", maximumFractionDigits: "4"}, initialWidth: 100}
        ]);

        cmp.set("v.wcPolicyColumns", [
            {label: "* Include", fieldName: "Include__c", type: "boolean", editable: true, initialWidth: 100, cellAttributes:{alignment:"center"}},
            {label: "HRP W/C Policy", fieldName: "HRP_Work_Comp_Policy__c", type: "text"},
            {label: "* Display Name", fieldName: "Display_Name__c", type: "text", editable: true},
            {label: "", fieldName: "", type: "", initialWidth: 50}
        ]);

        helper.initStateCodes (cmp);
    },

    uploadFile: function (cmp, event, helper) {
        var fileInput = cmp.find("file").getElement();
        if(!fileInput.files || fileInput.files.length === 0){
            helper.showToast(cmp, "Error", "Please specify file to upload.", "error", "sticky");
            cmp.set("v.recommendedXmodFilename", "");
            return;
        }
        var file = fileInput.files[0];
        if(file) {
            var fileExt = file.name.substring(file.name.length - 4);
            if(fileExt !== ".csv" && fileExt !== ".txt"){
                helper.showToast(cmp, "Error", "Please specify CSV file to upload.", "error", "sticky");
                helper.clearFile(cmp);
                return;
            }
            var reader = new FileReader();
            reader.readAsText(file, "UTF-8");
            reader.onload = function (evt) {
                var csv = evt.target.result;
                helper.parseFile(cmp, csv);
            };
            reader.onerror = function (evt) {
                console.log("error reading file: " + evt);
                helper.showToast(cmp, "Error", "An error occurred while reading the file", "error", "sticky");
                helper.clearFile(cmp);
            };
        }
        else{
            helper.showToast(cmp, "Error", "Please specify file to upload", "error", "sticky");
            helper.clearFile(cmp);
        }
    },

    getXmods: function(cmp, event, helper){
        helper.resetDisplayReports(cmp);
        helper.getRecommendedXmods(cmp);
        cmp.set("v.displayRecommendedXmod", true);
    },

    getWcPolicies: function (cmp, event, helper) {
        helper.resetDisplayReports(cmp);
        helper.getWcPolicies(cmp);
        cmp.set("v.displayWcPolicyMapping", true);
    },

    handleWcPolicySaveTable: function (cmp, event, helper) {
        var draftValues = event.getParam("draftValues");
        helper.saveWcPolicy(cmp, draftValues);
    },
    
    onAddNewWcPolicy: function (cmp, event, helper) {
        var policies = cmp.get("v.wcPolicyData");
        if (!policies || policies.length == 0) {
            //todo: show error
            return;
        } 
        else {
        }
        var newWcPolicy = policies[0];
        newWcPolicy.Id = null;
        newWcPolicy.HRP_Work_Comp_Policy__c = "No HRP Policy: ";
        newWcPolicy.Include__c = true;
        newWcPolicy.Display_Name__c = "";
        newWcPolicy.State_Code__c = "";
        newWcPolicy.Order__c = policies.length;
        cmp.set("v.newWcPolicy", newWcPolicy);
        cmp.set("v.showAddNewWcPolicy", true);
    },

    onAddWcPolicy: function (cmp, event, helper) {
        let newPolicy = cmp.get("v.newWcPolicy");
        newPolicy.HRP_Work_Comp_Policy__c += newPolicy.State_Code__c; 
        helper.saveNewWcPolicy(cmp, event, newPolicy);
        cmp.set("v.newWcPolicy", null);
        cmp.set("v.showAddNewWcPolicy", false);
    }, 

    onCancelWcPolicy: function (cmp, event, helper) {
        cmp.set("v.showAddNewWcPolicy", false);
    }
});