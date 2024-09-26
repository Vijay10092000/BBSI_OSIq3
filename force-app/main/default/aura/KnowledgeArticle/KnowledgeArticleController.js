({
	doInit : function(component, event, helper) {
        // fetch all Data Categories & Knowledge Articles
        helper.doInitHelper(component, helper);
    },
    
    onFilterChange: function (component, event, helper) {
        //console.log('source = ' + event.getSource().get("v.name"));
        var source = event.getSource().get("v.name"); 
        var allBPKAObjList = component.get("v.allBPKAObjList");
		var bpKAObjList = [];
        
        // remove marking in value using: <mark></mark> 
        for(var i = 0; i < allBPKAObjList.length; i++) {
            if(!$A.util.isEmpty(allBPKAObjList[i].ArticleNumber)) {
                allBPKAObjList[i].ArticleNumber = helper.removeMarking(helper, allBPKAObjList[i].ArticleNumber, '<mark>', '');
                allBPKAObjList[i].ArticleNumber = helper.removeMarking(helper, allBPKAObjList[i].ArticleNumber, '</mark>', '');
            }
            if(!$A.util.isEmpty(allBPKAObjList[i].Title)) {
                allBPKAObjList[i].Title = helper.removeMarking(helper, allBPKAObjList[i].Title, '<mark>', '');
                allBPKAObjList[i].Title = helper.removeMarking(helper, allBPKAObjList[i].Title, '</mark>', '');
            }
            if(!$A.util.isEmpty(allBPKAObjList[i].Summary)) {
                allBPKAObjList[i].Summary = helper.removeMarking(helper, allBPKAObjList[i].Summary, '<mark>', '');
                allBPKAObjList[i].Summary = helper.removeMarking(helper, allBPKAObjList[i].Summary, '</mark>', '');
            }
            if(!$A.util.isEmpty(allBPKAObjList[i].ArticleType)) {
                allBPKAObjList[i].ArticleType = helper.removeMarking(helper, allBPKAObjList[i].ArticleType, '<mark>', '');
                allBPKAObjList[i].ArticleType = helper.removeMarking(helper, allBPKAObjList[i].ArticleType, '</mark>', '');
            }
            if(!$A.util.isEmpty(allBPKAObjList[i].Language)) {
                allBPKAObjList[i].Language = helper.removeMarking(helper, allBPKAObjList[i].Language, '<mark>', '');
                allBPKAObjList[i].Language = helper.removeMarking(helper, allBPKAObjList[i].Language, '</mark>', '');
            }
            if(!$A.util.isEmpty(allBPKAObjList[i].UrlName)) {
                allBPKAObjList[i].UrlName = helper.removeMarking(helper, allBPKAObjList[i].UrlName, '<mark>', '');
                allBPKAObjList[i].UrlName = helper.removeMarking(helper, allBPKAObjList[i].UrlName, '</mark>', '');
            }
            if(!$A.util.isEmpty(allBPKAObjList[i].PublishStatus)) {
                allBPKAObjList[i].PublishStatus = helper.removeMarking(helper, allBPKAObjList[i].PublishStatus, '<mark>', '');
                allBPKAObjList[i].PublishStatus = helper.removeMarking(helper, allBPKAObjList[i].PublishStatus, '</mark>', '');
            }
            if(!$A.util.isEmpty(allBPKAObjList[i].CreatedDate)) {
                allBPKAObjList[i].CreatedDate = helper.removeMarking(helper, allBPKAObjList[i].CreatedDate, '<mark>', '');
                allBPKAObjList[i].CreatedDate = helper.removeMarking(helper, allBPKAObjList[i].CreatedDate, '</mark>', '');
            }
            if(!$A.util.isEmpty(allBPKAObjList[i].FirstPublishedDate)) {
                allBPKAObjList[i].FirstPublishedDate = helper.removeMarking(helper, allBPKAObjList[i].FirstPublishedDate, '<mark>', '');
                allBPKAObjList[i].FirstPublishedDate = helper.removeMarking(helper, allBPKAObjList[i].FirstPublishedDate, '</mark>', '');
            }
            if(!$A.util.isEmpty(allBPKAObjList[i].LastPublishedDate)) {
                allBPKAObjList[i].LastPublishedDate = helper.removeMarking(helper, allBPKAObjList[i].LastPublishedDate, '<mark>', '');
                allBPKAObjList[i].LastPublishedDate = helper.removeMarking(helper, allBPKAObjList[i].LastPublishedDate, '</mark>', '');
            }
            // Custom fields
            if(!$A.util.isEmpty(allBPKAObjList[i].Article_Body__c)) {
                allBPKAObjList[i].Article_Body__c = helper.removeMarking(helper, allBPKAObjList[i].Article_Body__c, '<mark>', '');
                allBPKAObjList[i].Article_Body__c = helper.removeMarking(helper, allBPKAObjList[i].Article_Body__c, '</mark>', '');
            }
            if(!$A.util.isEmpty(allBPKAObjList[i].Business_Case__c)) {
                allBPKAObjList[i].Business_Case__c = helper.removeMarking(helper, allBPKAObjList[i].Business_Case__c, '<mark>', '');
                allBPKAObjList[i].Business_Case__c = helper.removeMarking(helper, allBPKAObjList[i].Business_Case__c, '</mark>', '');
            }
            if(!$A.util.isEmpty(allBPKAObjList[i].Impacted_Roles__c)) {
                allBPKAObjList[i].Impacted_Roles__c = helper.removeMarking(helper, allBPKAObjList[i].Impacted_Roles__c, '<mark>', '');
                allBPKAObjList[i].Impacted_Roles__c = helper.removeMarking(helper, allBPKAObjList[i].Impacted_Roles__c, '</mark>', '');
            }
            if(!$A.util.isEmpty(allBPKAObjList[i].Last_Reviewed_On__c)) {
                allBPKAObjList[i].Last_Reviewed_On__c = helper.removeMarking(helper, allBPKAObjList[i].Last_Reviewed_On__c, '<mark>', '');
                allBPKAObjList[i].Last_Reviewed_On__c = helper.removeMarking(helper, allBPKAObjList[i].Last_Reviewed_On__c, '</mark>', '');
            }
            if(!$A.util.isEmpty(allBPKAObjList[i].Review_By_Date__c)) {
                allBPKAObjList[i].Review_By_Date__c = helper.removeMarking(helper, allBPKAObjList[i].Review_By_Date__c, '<mark>', '');
                allBPKAObjList[i].Review_By_Date__c = helper.removeMarking(helper, allBPKAObjList[i].Review_By_Date__c, '</mark>', '');
            }
            if(!$A.util.isEmpty(allBPKAObjList[i].System_Version__c)) {
                allBPKAObjList[i].System_Version__c = helper.removeMarking(helper, allBPKAObjList[i].System_Version__c, '<mark>', '');
                allBPKAObjList[i].System_Version__c = helper.removeMarking(helper, allBPKAObjList[i].System_Version__c, '</mark>', '');
            }
            if(!$A.util.isEmpty(allBPKAObjList[i].Type__c)) {
                allBPKAObjList[i].Type__c = helper.removeMarking(helper, allBPKAObjList[i].Type__c, '<mark>', '');
                allBPKAObjList[i].Type__c = helper.removeMarking(helper, allBPKAObjList[i].Type__c, '</mark>', '');
            }
            if(!$A.util.isEmpty(allBPKAObjList[i].Body__c)) {
                allBPKAObjList[i].Body__c = helper.removeMarking(helper, allBPKAObjList[i].Body__c, '<mark>', '');
                allBPKAObjList[i].Body__c = helper.removeMarking(helper, allBPKAObjList[i].Body__c, '</mark>', '');
            }
            if(!$A.util.isEmpty(allBPKAObjList[i].Access_Required__c)) {
                allBPKAObjList[i].Access_Required__c = helper.removeMarking(helper, allBPKAObjList[i].Access_Required__c, '<mark>', '');
                allBPKAObjList[i].Access_Required__c = helper.removeMarking(helper, allBPKAObjList[i].Access_Required__c, '</mark>', '');
            }
            // remove marking in Knowledge Article Docs.
            if(!$A.util.isEmpty(allBPKAObjList[i].articleCVList)) {
                var articleCVList = allBPKAObjList[i].articleCVList;
                for(var j = 0; j < articleCVList.length; j++) {
                    if(!$A.util.isUndefinedOrNull(articleCVList[j].Title)) {
                        articleCVList[j].Title = helper.removeMarking(helper, articleCVList[j].Title, '<mark>', '');
                        articleCVList[j].Title = helper.removeMarking(helper, articleCVList[j].Title, '</mark>', '');
                    }
                    if(!$A.util.isUndefinedOrNull(articleCVList[j].Description)) {
                        articleCVList[j].Description = helper.removeMarking(helper, articleCVList[j].Description, '<mark>', '');
                        articleCVList[j].Description = helper.removeMarking(helper, articleCVList[j].Description, '</mark>', '');
                    }
                }
                allBPKAObjList[i].articleCVList = articleCVList;
            }
        }
        
        var selDataCatLocOption = component.find("selDataCatLocOption").get("v.value");
        var selDataCatAppOption = component.find("selDataCatAppOption").get("v.value");
        var selDataCatRoleOption = component.find("selDataCatRoleOption").get("v.value");
        //console.log('selDataCatLocOption = ' + selDataCatLocOption);
        //console.log('selDataCatAppOption = ' + selDataCatAppOption);
        //console.log('selDataCatRoleOption = ' + selDataCatRoleOption);
                        
        // checking data category filter
        if(selDataCatLocOption == "No Filter" 
           && selDataCatAppOption =="No Filter" 
           && selDataCatRoleOption == "No Filter") {
            bpKAObjList = allBPKAObjList;
        }
        else {
            if(!$A.util.isEmpty(allBPKAObjList)) {
                var dataCatAllLocsList = component.get("v.dataCatAllLocsList");
                var dataCatAllAppsList = component.get("v.dataCatAllAppsList");
                var dataCatAllRolesList = component.get("v.dataCatAllRolesList");
                
                var dataCatAllParentLocsMap = component.get("v.dataCatAllParentLocsMap");
                var dataCatAllParentAppsMap = component.get("v.dataCatAllParentAppsMap");
                var dataCatAllParentRolesMap = component.get("v.dataCatAllParentRolesMap");
                
                var dataCatAllLocsMap = component.get("v.dataCatAllLocsMap");
                var dataCatAllAppsMap = component.get("v.dataCatAllAppsMap");
                var dataCatAllRolesMap = component.get("v.dataCatAllRolesMap");
                
                // get all parent and child data categories
                var eligibleDataCatLocList = helper.getEligibleDataCat(component, selDataCatLocOption, dataCatAllLocsList, dataCatAllParentLocsMap);
                var eligibleDataCatAppList = helper.getEligibleDataCat(component, selDataCatAppOption, dataCatAllAppsList, dataCatAllParentAppsMap);
                var eligibleDataCatRoleList = helper.getEligibleDataCat(component, selDataCatRoleOption, dataCatAllRolesList, dataCatAllParentRolesMap);
                //console.log('eligibleDataCatLocList = ' + eligibleDataCatLocList);
                //console.log('eligibleDataCatAppList = ' + eligibleDataCatAppList);
                //console.log('eligibleDataCatRoleList = ' + eligibleDataCatRoleList);
                
                for(var i = 0; i < allBPKAObjList.length; i++) {
                    var isValid = false;
                    var dataCategorySelections = allBPKAObjList[i].DataCategorySelections;
                    if(!$A.util.isUndefinedOrNull(dataCategorySelections) && !$A.util.isEmpty(dataCategorySelections)) {
                        // checking data category Location
                        if(selDataCatLocOption == "No Filter") {
                            isValid = true;
                        } else {
                            for(var j = 0; j < dataCategorySelections.length; j++) {
                                if(dataCategorySelections[j].DataCategoryGroupName == "Location") {
                                    for(var k = 0; k < eligibleDataCatLocList.length; k++) {
                                        if(dataCategorySelections[j].DataCategoryName == dataCatAllLocsMap[eligibleDataCatLocList[k]]) {
                                            isValid = true;
                                            break;
                                        }
                                    }
                                }
                            }
                        }
                        //console.log("isValid = " + isValid);
                        
                        // checking data category Application if isValid
                        if(isValid && selDataCatAppOption == "No Filter") {
                            isValid = true;
                        } else if(isValid) {
                            isValid = false;
                            for(var j = 0; j < dataCategorySelections.length; j++) {
                                if(dataCategorySelections[j].DataCategoryGroupName == "Application") {
                                    for(var k = 0; k < eligibleDataCatAppList.length; k++) {
                                        if(dataCategorySelections[j].DataCategoryName == dataCatAllAppsMap[eligibleDataCatAppList[k]]) {
                                            isValid = true;
                                            break;
                                        }
                                    }
                                }
                            }
                        }
                        //console.log("isValid = " + isValid);
                        
                        // checking data category Role if isValid
                        if(isValid && selDataCatRoleOption == "No Filter") {
                            isValid = true;
                        } else if(isValid) {
                            isValid = false;
                            for(var j = 0; j < dataCategorySelections.length; j++) {
                                if(dataCategorySelections[j].DataCategoryGroupName == "Role") {
                                    for(var k = 0; k < eligibleDataCatRoleList.length; k++) {
                                        if(dataCategorySelections[j].DataCategoryName == dataCatAllRolesMap[eligibleDataCatRoleList[k]]) {
                                            isValid = true;
                                            break;
                                        }
                                    }
                                }
                            }
                        }
                        //console.log("isValid = " + isValid);
                        if(isValid)
                            bpKAObjList.push(allBPKAObjList[i]);  
                    }
                }
            }
        }
                
        if(source != "search-article") {
            component.find('search-article').set('v.value', '');
            component.set("v.bpKAObjList", bpKAObjList);
        }
        else {
            // checking data filter change
            component.set('v.issearching', true);
            var articleName = component.find('search-article').get('v.value');
            //console.log('articleName = ' + articleName);
            var filterBPKAObjList = [];
            if(!$A.util.isEmpty(articleName) && !$A.util.isEmpty(bpKAObjList)) {
                // trim articleName
                articleName = articleName.trim();
                
                // applying marking in value using: <mark></mark> 
                for(var i = 0; i < bpKAObjList.length; i++) {
                    var isValid = false;
                    if(!$A.util.isEmpty(bpKAObjList[i].ArticleNumber)) {
                        var dataObj = helper.addMarking(helper, bpKAObjList[i].ArticleNumber, articleName);
                        if(!isValid)
                            isValid = dataObj.isValid;
                        bpKAObjList[i].ArticleNumber = dataObj.data;
                    }
                    //if(!$A.util.isEmpty(bpKAObjList[i].Title) && bpKAObjList[i].Title.toUpperCase().includes(articleName.toUpperCase())) {
                    if(!$A.util.isEmpty(bpKAObjList[i].Title)) {
                        var dataObj = helper.addMarking(helper, bpKAObjList[i].Title, articleName);
                        if(!isValid)
                            isValid = dataObj.isValid;
                        bpKAObjList[i].Title = dataObj.data;
                        
                        //isValid = true;
                        //bpKAObjList[i].Title = helper.addMarking(helper, bpKAObjList[i].Title, articleName);
                    }
                    if(!$A.util.isEmpty(bpKAObjList[i].Summary)) {
                        var dataObj = helper.addMarking(helper, bpKAObjList[i].Summary, articleName);
                        if(!isValid)
                            isValid = dataObj.isValid;
                        bpKAObjList[i].Summary = dataObj.data;
                    }
                    if(!$A.util.isEmpty(bpKAObjList[i].ArticleType)) {
                        var dataObj = helper.addMarking(helper, bpKAObjList[i].ArticleType, articleName);
                        if(!isValid)
                            isValid = dataObj.isValid;
                        bpKAObjList[i].ArticleType = dataObj.data;
                    }
                    if(!$A.util.isEmpty(bpKAObjList[i].Language)) {
                        var dataObj = helper.addMarking(helper, bpKAObjList[i].Language, articleName);
                        if(!isValid)
                            isValid = dataObj.isValid;
                        bpKAObjList[i].Language = dataObj.data;
                    }
                    if(!$A.util.isEmpty(bpKAObjList[i].UrlName)) {
                        var dataObj = helper.addMarking(helper, bpKAObjList[i].UrlName, articleName);
                        if(!isValid)
                            isValid = dataObj.isValid;
                        bpKAObjList[i].UrlName = dataObj.data;
                    }
                    if(!$A.util.isEmpty(bpKAObjList[i].PublishStatus)) {
                        var dataObj = helper.addMarking(helper, bpKAObjList[i].PublishStatus, articleName);
                        if(!isValid)
                            isValid = dataObj.isValid;
                        bpKAObjList[i].PublishStatus = dataObj.data;
                    }
                    if(!$A.util.isEmpty(bpKAObjList[i].CreatedDate)) {
                        var dataObj = helper.addMarking(helper, bpKAObjList[i].CreatedDate, articleName);
                        if(!isValid)
                            isValid = dataObj.isValid;
                        bpKAObjList[i].CreatedDate = dataObj.data;
                    }
                    if(!$A.util.isEmpty(bpKAObjList[i].FirstPublishedDate)) {
                        var dataObj = helper.addMarking(helper, bpKAObjList[i].FirstPublishedDate, articleName);
                        if(!isValid)
                            isValid = dataObj.isValid;
                        bpKAObjList[i].FirstPublishedDate = dataObj.data;
                    }
                    if(!$A.util.isEmpty(bpKAObjList[i].LastPublishedDate)) {
                        var dataObj = helper.addMarking(helper, bpKAObjList[i].LastPublishedDate, articleName);
                        if(!isValid)
                            isValid = dataObj.isValid;
                        bpKAObjList[i].LastPublishedDate = dataObj.data;
                    }
                    // Custom fields
                    if(!$A.util.isEmpty(bpKAObjList[i].Article_Body__c)) {
                        var dataObj = helper.addMarking(helper, bpKAObjList[i].Article_Body__c, articleName);
                        if(!isValid)
                            isValid = dataObj.isValid;
                        bpKAObjList[i].Article_Body__c = dataObj.data;
                    }
                    if(!$A.util.isEmpty(bpKAObjList[i].Business_Case__c)) {
                        var dataObj = helper.addMarking(helper, bpKAObjList[i].Business_Case__c, articleName);
                        if(!isValid)
                            isValid = dataObj.isValid;
                        bpKAObjList[i].Business_Case__c = dataObj.data;
                    }
                    if(!$A.util.isEmpty(bpKAObjList[i].Impacted_Roles__c)) {
                        var dataObj = helper.addMarking(helper, bpKAObjList[i].Impacted_Roles__c, articleName);
                        if(!isValid)
                            isValid = dataObj.isValid;
                        bpKAObjList[i].Impacted_Roles__c = dataObj.data;
                    }
                    if(!$A.util.isEmpty(bpKAObjList[i].Last_Reviewed_On__c)) {
                        var dataObj = helper.addMarking(helper, bpKAObjList[i].Last_Reviewed_On__c, articleName);
                        if(!isValid)
                            isValid = dataObj.isValid;
                        bpKAObjList[i].Last_Reviewed_On__c = dataObj.data;
                    }
                    if(!$A.util.isEmpty(bpKAObjList[i].Review_By_Date__c)) {
                        var dataObj = helper.addMarking(helper, bpKAObjList[i].Review_By_Date__c, articleName);
                        if(!isValid)
                            isValid = dataObj.isValid;
                        bpKAObjList[i].Review_By_Date__c = dataObj.data;
                    }
                    if(!$A.util.isEmpty(bpKAObjList[i].System_Version__c)) {
                        var dataObj = helper.addMarking(helper, bpKAObjList[i].System_Version__c, articleName);
                        if(!isValid)
                            isValid = dataObj.isValid;
                        bpKAObjList[i].System_Version__c = dataObj.data;
                    }
                    if(!$A.util.isEmpty(bpKAObjList[i].Type__c)) {
                        var dataObj = helper.addMarking(helper, bpKAObjList[i].Type__c, articleName);
                        if(!isValid)
                            isValid = dataObj.isValid;
                        bpKAObjList[i].Type__c = dataObj.data;
                    }
                    if(!$A.util.isEmpty(bpKAObjList[i].Body__c)) {
                        var dataObj = helper.addMarking(helper, bpKAObjList[i].Body__c, articleName);
                        if(!isValid)
                            isValid = dataObj.isValid;
                        bpKAObjList[i].Body__c = dataObj.data;
                    }
                    if(!$A.util.isEmpty(bpKAObjList[i].Access_Required__c)) {
                        var dataObj = helper.addMarking(helper, bpKAObjList[i].Access_Required__c, articleName);
                        if(!isValid)
                            isValid = dataObj.isValid;
                        bpKAObjList[i].Access_Required__c = dataObj.data;
                    }
                    //searching in Knowledge Article Docs.
                    if(!$A.util.isEmpty(bpKAObjList[i].articleCVList)) {
                       var articleCVList = bpKAObjList[i].articleCVList;
                       for(var j = 0; j < articleCVList.length; j++) {
                           if(!$A.util.isUndefinedOrNull(articleCVList[j].Title)) {
                               var dataObj = helper.addMarking(helper, articleCVList[j].Title, articleName);
                               if(!isValid)
                                   isValid = dataObj.isValid;
                               articleCVList[j].Title = dataObj.data;
                           }
                           if(!$A.util.isUndefinedOrNull(articleCVList[j].Description)) {
                               var dataObj = helper.addMarking(helper, articleCVList[j].Description, articleName);
                               if(!isValid)
                                   isValid = dataObj.isValid;
                               articleCVList[j].Description = dataObj.data;
                           }
                       }
                    }
                    // add if found articleName
                    if(isValid)
                        filterBPKAObjList.push(bpKAObjList[i]);
                }
            }
            else {
                filterBPKAObjList = bpKAObjList;
            }
            setTimeout(function() {
                component.set('v.issearching', false);
                component.set("v.bpKAObjList", filterBPKAObjList);
            }, 500);
        }
    },
    
    reset : function(component, event, helper) {
        helper.doInitHelper(component, helper);
        component.find('search-article').set('v.value', '');
        component.find('selDataCatLocOption').set('v.value', '');
        component.find('selDataCatAppOption').set('v.value', '');
        component.find('selDataCatRoleOption').set('v.value', '');
    },
    
    navigateToRecord : function(component, event, helper) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": event.currentTarget.id
        });
        navEvt.fire();
    },
    
    openSelDoc : function(component, event, helper) {
        component.set("v.openDoc", true);
        component.set("v.selDocId", event.currentTarget.id);
    },
    
    closeModel : function(component, event, helper) {
        component.set("v.openDoc", false);
        component.set("v.selDocId", null);
    },
})