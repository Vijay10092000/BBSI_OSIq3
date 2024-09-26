({
    doInitHelper: function(component, helper) {
        try {
            component.set("v.spinnervisible",true);
            // calling apex controller
            var action = component.get("c.getArticles");
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    //console.log('response = '  + response.getReturnValue());
					var responseObj = response.getReturnValue();
                    helper.populateDataCategory(component, helper, responseObj.dataCatLabelMap, responseObj.dataCatValueMap);
                    helper.populateData(component, helper, responseObj.bpKAObjList, responseObj.bpDataCatSelMap, responseObj.articleCVMap);
                }
                else {
                    let message = 'Error: ';
                    let errors = response.getError();
                    // Retrieve the error message sent by the server
                    if (errors && errors.length > 0)
                        message = message + errors[0].message;
                    console.log("Error in loading Lightning Component: KnowledgeArticle. " + message);
                    component.set("v.error", "Error in loading Lightning Component: KnowledgeArticle. " + message);
                }
                component.set("v.spinnervisible",false);
            });
            $A.enqueueAction(action);
        }catch (ex) {
            console.log("Error in loading Lightning Component: KnowledgeArticle. " + ex);
            component.set("v.error", "Error in loading Lightning Component: KnowledgeArticle. " + ex);
            component.set("v.spinnervisible",false);
        }
    },
    
    populateDataCategory: function(component, helper, dataCatLabelMap, dataCatValueMap) {
        // Initialize input select options
        // setting data category list
        //var dataCatAllLocsList = ['All', 'VOC','VOC > Accounting and Finance','VOC > Contract','VOC > HR','VOC > Insurance','VOC > Internal Audi','VOC > IT','VOC > Organizational Development','VOC > Payroll and Garnishments','VOC > Tax','Eastern','Eastern > Delaware','Eastern > Maryland','Eastern > North Carolina','Eastern > Pennsylvania','Eastern > Virginia','Mountain','Mountain > Arizona','Mountain > Colorado','Mountain > Idaho','Mountain > Nevada','Mountain > Utah','NoCal','Northwest','Northwest > Oregon','Northwest > Washington','SoCal'];
        //var dataCatAllAppsList = ['All', '360','Baseware','BBSI.com','BSO','Bullhorn','CareMC','Citrix','Corvel','File Server (Mapped Drive)','HRP','HRP Web','Intellicomp','MyBBSI','Outlook','Salesforce','Sharefile','Sharepoint','SpringCM','Time Clock Plus','TimeNet','Windows','Salesforce1'];
        //var dataCatAllRolesList = ['All', 'AM', 'BDM', 'BP','HR','PR','Risk'];
        var dataCatAllLocsList = dataCatLabelMap['Location'];
        var dataCatAllAppsList = dataCatLabelMap['Application'];
        var dataCatAllRolesList = dataCatLabelMap['Role'];
        
        component.set("v.dataCatAllLocsList", dataCatAllLocsList);
        component.set("v.dataCatAllAppsList", dataCatAllAppsList);
        component.set("v.dataCatAllRolesList", dataCatAllRolesList);
        
        // setting data category parent list
        // Locations
        var dataCatAllParentLocsMap = {};
        //var dataCatParentLocsMap = VOC<Eastern<Mountain<NoCal<Northwest<SoCal>All,Accounting & Finance<Contracts<HR<Insurance<Internal Audi<IT<Organizational Development<Payroll & Garnishments<Tax>All:VOC,Delaware<Maryland<North Carolina<Pennsylvania<Virginia>All:Eastern,Arizona<Colorado<Idaho<Nevada<Utah>All:Mountain,Oregon<Washington>All:Northwest
        var dataCatParentLocsMap = $A.get("$Label.c.KA_DataCatAllParentLocsMap");
        if(!$A.util.isUndefinedOrNull(dataCatParentLocsMap)) {
            var dataCatParentLocsList = dataCatParentLocsMap.split(',');
            for(var i = 0; i < dataCatParentLocsList.length; i++) {
                var dataCatParentList = dataCatParentLocsList[i].split('>');
                var keys = dataCatParentList[0].split('<');
                for(var j = 0; j < keys.length; j++) {
                    dataCatAllParentLocsMap[keys[j]] = dataCatParentList[1];
                }
            }
        }
        
        /*for(var key in dataCatAllParentLocsMap) {
            console.log('Key: '+ key + ', Value = ' + dataCatAllParentLocsMap[key]);
        }*/
        
        // Apllications
        var dataCatAllParentAppsMap = {};
        //var dataCatParentAppsMap = 360<Baseware<BBSI.com<BSO<Bullhorn<CareMC<Citrix<Corvel<File Server (Mapped Drive)<HRP<HRP Web<Intellicomp<MyBBSI<Outlook<Salesforce<Sharefile<Sharepoint<SpringCM<Time Clock Plus<TimeNet<Windows<Salesforce1>All
        var dataCatParentAppsMap = $A.get("$Label.c.KA_DataCatAllParentAppsMap");
        if(!$A.util.isUndefinedOrNull(dataCatParentAppsMap)) {
            var dataCatParentAppsList = dataCatParentAppsMap.split(',');
            for(var i = 0; i < dataCatParentAppsList.length; i++) {
                var dataCatParentList = dataCatParentAppsList[i].split('>');
                var keys = dataCatParentList[0].split('<');
                for(var j = 0; j < keys.length; j++) {
                    dataCatAllParentAppsMap[keys[j]] = dataCatParentList[1];
                }
            }
        }
        
        // Roles
        var dataCatAllParentRolesMap = {};
		//var dataCatParentRolesMap = AM<BDM<BP<HR<PR<Risk>All
        var dataCatParentRolesMap = $A.get("$Label.c.KA_DataCatAllParentRolesMap");
        if(!$A.util.isUndefinedOrNull(dataCatParentRolesMap)) {
            var dataCatParentRolesList = dataCatParentRolesMap.split(',');
            for(var i = 0; i < dataCatParentRolesList.length; i++) {
                var dataCatParentList = dataCatParentRolesList[i].split('>');
                var keys = dataCatParentList[0].split('<');
                for(var j = 0; j < keys.length; j++) {
                    dataCatAllParentRolesMap[keys[j]] = dataCatParentList[1];
                }
            }
        }
        
        component.set("v.dataCatAllParentLocsMap", dataCatAllParentLocsMap);
        component.set("v.dataCatAllParentAppsMap", dataCatAllParentAppsMap);
        component.set("v.dataCatAllParentRolesMap", dataCatAllParentRolesMap);
        
        // setting data category Map
        // Locations
        var dataCatAllLocsMap = {};
        var dataCatAllLocsValueList = dataCatValueMap['Location'];
        for(var i = 0; i < dataCatAllLocsValueList.length; i++) {
            var dataCatLabelValueObj = dataCatAllLocsValueList[i].split('>');
            dataCatAllLocsMap[dataCatLabelValueObj[0]] = dataCatLabelValueObj[1];
        }
        // again populating Locs Map with all data categories if not present
        //var dataCatLocsMap = All>All,VOC>VOC,Accounting & Finance>Accounting_Finance,Contracts>Contracts,HR>HR,Insurance>Insurance,Internal Audi>Internal_Audi,IT>IT,Organizational Development>Organizational_Development,Payroll & Garnishments>Payroll_Garnishments,Tax>Tax,Eastern>Eastern,Delaware>Delaware,Maryland>Maryland,North Carolina>North_Carolina,Pennsylvania>Pennsylvania,Virginia>Virginia,Mountain>Mountain,Arizona>Arizona,Colorado>Colorado,Idaho>Idaho,Nevada>Nevada,Utah>Utah,NoCal>NoCal,Northwest>Northwest,Oregon>Oregon,Washington>Washington,SoCal>SoCal
        var dataCatLocsMap = $A.get("$Label.c.KA_DataCatAllLocsMap");
        if(!$A.util.isUndefinedOrNull(dataCatLocsMap)) {
            var dataCatLocsList = dataCatLocsMap.split(',');
            for(var i = 0; i < dataCatLocsList.length; i++) {
                var keyValuePairObj = dataCatLocsList[i].split('>');
                if($A.util.isUndefinedOrNull(dataCatAllLocsMap[keyValuePairObj[0]])) {
                    dataCatAllLocsMap[keyValuePairObj[0]] = keyValuePairObj[1];
                }
            }
        }
        
        // Applications
        var dataCatAllAppsMap = {};
        var dataCatAllAppsValueList = dataCatValueMap['Application'];
        for(var i = 0; i < dataCatAllAppsValueList.length; i++) {
            var dataCatLabelValueObj = dataCatAllAppsValueList[i].split('>');
            dataCatAllAppsMap[dataCatLabelValueObj[0]] = dataCatLabelValueObj[1];
        }
        
        // again populating Apps Map with all data categories if not present
        //var dataCatAppsMap = All>All,360>X360,Baseware>Baseware,BBSI.com>BBSI_com,BSO>BSO,Bullhorn>Bullhorn,CareMC>CareMC,Citrix>Citrix,Corvel>Corvel,File Server (Mapped Drive)>File_Server,HRP>HRP,HRP Web>HRP_Web,Intellicomp>Intellicomp,MyBBSI>MyBBSI,Outlook>Outlook,Salesforce>Salesforce,Sharefile>Sharefile,Sharepoint>Sharepoint,SpringCM>SpringCM,Time Clock Plus>Time_Clock_Plus,TimeNet>TimeNet,Windows>Windows,Salesforce1>Salesforce1
        var dataCatAppsMap = $A.get("$Label.c.KA_DataCatAllAppsMap");
        if(!$A.util.isUndefinedOrNull(dataCatAppsMap)) {
            var dataCatLocsList = dataCatAppsMap.split(',');
            for(var i = 0; i < dataCatLocsList.length; i++) {
                var keyValuePairObj = dataCatLocsList[i].split('>');
                if($A.util.isUndefinedOrNull(dataCatAllAppsMap[keyValuePairObj[0]])) {
                    dataCatAllAppsMap[keyValuePairObj[0]] = keyValuePairObj[1];
                }
            }
        }
        
        // Roles
        var dataCatAllRolesMap = {};
        var dataCatAllRolesValueList = dataCatValueMap['Role'];
        for(var i = 0; i < dataCatAllRolesValueList.length; i++) {
            var dataCatLabelValueObj = dataCatAllRolesValueList[i].split('>');
            dataCatAllRolesMap[dataCatLabelValueObj[0]] = dataCatLabelValueObj[1];
        }

        // again populating Roles Map with all data categories if not present
        //var dataCatRolesMap = All>All,AM>AM,BDM>BDM,BP>BP,HR>HR,PR>PR,Risk>Risk
        var dataCatRolesMap = $A.get("$Label.c.KA_DataCatAllRolesMap");
        if(!$A.util.isUndefinedOrNull(dataCatRolesMap)) {
            var dataCatRolesList = dataCatRolesMap.split(',');
            for(var i = 0; i < dataCatRolesList.length; i++) {
                var keyValuePairObj = dataCatRolesList[i].split('>');
                if($A.util.isUndefinedOrNull(dataCatAllRolesMap[keyValuePairObj[0]])) {
                    dataCatAllRolesMap[keyValuePairObj[0]] = keyValuePairObj[1];
                }
            }
        }
        
        component.set("v.dataCatAllLocsMap", dataCatAllLocsMap);
        component.set("v.dataCatAllAppsMap", dataCatAllAppsMap);
        component.set("v.dataCatAllRolesMap", dataCatAllRolesMap);
        
        // setting Location Options
        var dataCatLocOptions = [];
        dataCatLocOptions.push({ "class": "optionClass", label: 'No Filter', value: 'No Filter'});
        for(var i = 0; i < dataCatAllLocsList.length; i++) {
            dataCatLocOptions.push({ "class": "optionClass", label: dataCatAllLocsList[i], value: dataCatAllLocsList[i]});
        }
        // setting Application Options
        var dataCatAppOptions = [];
        dataCatAppOptions.push({ "class": "optionClass", label: 'No Filter', value: 'No Filter'});
        for(var i = 0; i < dataCatAllAppsList.length; i++) {
            dataCatAppOptions.push({ "class": "optionClass", label: dataCatAllAppsList[i], value: dataCatAllAppsList[i]});
        }
        // setting Role Options    
        var dataCatRoleOptions = [];
        dataCatRoleOptions.push({ "class": "optionClass", label: 'No Filter', value: 'No Filter'});
        for(var i = 0; i < dataCatAllRolesList.length; i++) {
            dataCatRoleOptions.push({ "class": "optionClass", label: dataCatAllRolesList[i], value: dataCatAllRolesList[i]});
        }
        
        //component.set("v.publishOptions", publishOptions);
        component.set("v.dataCatLocOptions", dataCatLocOptions);
        component.set("v.dataCatAppOptions", dataCatAppOptions);
        component.set("v.dataCatRoleOptions", dataCatRoleOptions);
        
        // setting default values of data category filters
        component.find("selDataCatLocOption").set("v.value" , "No Filter");
        component.find("selDataCatAppOption").set("v.value" , "No Filter");
        component.find("selDataCatRoleOption").set("v.value" , "No Filter");
    
    },
    
    populateData: function(component, helper, bpKAObjList, bpDataCatSelMap, articleCVMap) {
        var allBPKAObjList = [];
        for(var i = 0; i < bpKAObjList.length; i++) {
            // change ArticleType format if more than one Article Type present in Salesforce org else no field ArticleType will be present on Knowledge Article object.
            //var articleType = (bpKAObjList[i].ArticleType == 'Best_Practice__kav') ? 'Best Practice' : bpKAObjList[i].ArticleType;
            /*
            if(!$A.util.isEmpty(bpKAObjList[i].ArticleNumber))
                bpKAObjList[i].ArticleNumber = bpKAObjList[i].ArticleNumber.toUpperCase();
            
            if(!$A.util.isEmpty(bpKAObjList[i].Title))
                bpKAObjList[i].Title = bpKAObjList[i].Title.toUpperCase();
            
            if(!$A.util.isEmpty(bpKAObjList[i].Summary))
                bpKAObjList[i].Summary = bpKAObjList[i].Summary.toUpperCase();
            */
            bpKAObjList[i].ArticleType = 'Best Practice';
            /*
            if(!$A.util.isEmpty(bpKAObjList[i].Language))
                bpKAObjList[i].Language = bpKAObjList[i].Language.toUpperCase();
            
            if(!$A.util.isEmpty(bpKAObjList[i].UrlName))
                bpKAObjList[i].UrlName = bpKAObjList[i].UrlName.toUpperCase();
            
            if(!$A.util.isEmpty(bpKAObjList[i].PublishStatus))
                bpKAObjList[i].PublishStatus = bpKAObjList[i].PublishStatus.toUpperCase();
            
            if(!$A.util.isEmpty(bpKAObjList[i].CreatedDate))
                bpKAObjList[i].CreatedDate = bpKAObjList[i].CreatedDate.toUpperCase();
            */
            // change date format
            if(!$A.util.isEmpty(bpKAObjList[i].FirstPublishedDate)) {
                var firstPubDate = new Date(bpKAObjList[i].FirstPublishedDate);
                bpKAObjList[i].FirstPublishedDate = (firstPubDate.getMonth() + 1) + "/" + firstPubDate.getDate() + "/" + firstPubDate.getFullYear();   
            }
            
            if(!$A.util.isEmpty(bpKAObjList[i].LastPublishedDate)) {
                var lastPubDate = new Date(bpKAObjList[i].LastPublishedDate);
                bpKAObjList[i].LastPublishedDate = (lastPubDate.getMonth() + 1) + "/" + lastPubDate.getDate() + "/" + lastPubDate.getFullYear();
            }
            /*
            if(!$A.util.isEmpty(bpKAObjList[i].Article_Body__c))
                bpKAObjList[i].Article_Body__c = bpKAObjList[i].Article_Body__c.toUpperCase();
            
            if(!$A.util.isEmpty(bpKAObjList[i].Business_Case__c))
                bpKAObjList[i].Business_Case__c = bpKAObjList[i].Business_Case__c.toUpperCase();
            
            if(!$A.util.isEmpty(bpKAObjList[i].Impacted_Roles__c))
                bpKAObjList[i].Impacted_Roles__c = bpKAObjList[i].Impacted_Roles__c.toUpperCase();
            
            if(!$A.util.isEmpty(bpKAObjList[i].Last_Reviewed_On__c))
                bpKAObjList[i].Last_Reviewed_On__c = bpKAObjList[i].Last_Reviewed_On__c.toUpperCase();
            
            if(!$A.util.isEmpty(bpKAObjList[i].Review_By_Date__c))
                bpKAObjList[i].Review_By_Date__c = bpKAObjList[i].Review_By_Date__c.toUpperCase();
            
            if(!$A.util.isEmpty(bpKAObjList[i].System_Version__c))
                bpKAObjList[i].System_Version__c = bpKAObjList[i].System_Version__c.toUpperCase();
            
            if(!$A.util.isEmpty(bpKAObjList[i].Type__c))
                bpKAObjList[i].Type__c = bpKAObjList[i].Type__c.toUpperCase();
            
            if(!$A.util.isEmpty(bpKAObjList[i].Body__c))
                bpKAObjList[i].Body__c = bpKAObjList[i].Body__c.toUpperCase();
            
            if(!$A.util.isEmpty(bpKAObjList[i].Access_Required__c))
                bpKAObjList[i].Access_Required__c = bpKAObjList[i].Access_Required__c.toUpperCase();
            */
            // fetching DataCategorySelections
            var dataCategorySelections = [];
            if(!$A.util.isUndefinedOrNull(bpDataCatSelMap[bpKAObjList[i].Id])) {
                dataCategorySelections = bpDataCatSelMap[bpKAObjList[i].Id];
            }
            bpKAObjList[i].DataCategorySelections = dataCategorySelections;
            
            // fetching files
            var articleCVList = [];
            if(!$A.util.isUndefinedOrNull(articleCVMap[bpKAObjList[i].KnowledgeArticleId])) {
                articleCVList = articleCVMap[bpKAObjList[i].KnowledgeArticleId];
                for(var j = 0; j < articleCVList.length; j++) {
                    /*if(!$A.util.isEmpty(articleCVList[j].Title))
                        articleCVList[j].Title = articleCVList[j].Title.toUpperCase();
                    if(!$A.util.isEmpty(articleCVList[j].Description))
                        articleCVList[j].Description = articleCVList[j].Description.toUpperCase();
                    */
                    var iconMap = {'CSV': 'doctype:csv',
                                   'TEXT': 'doctype:txt',
                                   'EXCEL_X': 'doctype:excel',
                                   'PDF': 'doctype:pdf',
                                   'WORD_X': 'doctype:word',
                                   'JPG': 'doctype:image',
                                   'PNG': 'doctype:image',
                                   'GIF': 'doctype:image',
                                  };
                    if(!$A.util.isUndefinedOrNull(iconMap[articleCVList[j].FileType]))
                        articleCVList[j].iconName = iconMap[articleCVList[j].FileType];
                    else
                        articleCVList[j].iconName = 'doctype:attachment';
                }
            }
            bpKAObjList[i].articleCVList = articleCVList;
            
            allBPKAObjList.push(bpKAObjList[i]);
        }
        
        component.set("v.allBPKAObjList", allBPKAObjList);
        //var bpKAObjList = allBPKAObjList;
        component.set("v.bpKAObjList", allBPKAObjList);
    },
    
    getEligibleDataCat: function(component, selDataCatOption, dataCatAllList, dataCatAllParentMap) {
        var eligibleDataCatList = [];
        
        //get all parent data categories
        var dataCatList = selDataCatOption.split(' > ');
        for(var i = 0; i < dataCatList.length; i++) {
            if(!eligibleDataCatList.includes(dataCatList[i]))
                eligibleDataCatList.push(dataCatList[i]);
        }
        
        //get all parent data categories if not visible
        if(!$A.util.isUndefinedOrNull(dataCatAllParentMap[dataCatList[dataCatList.length - 1]])) {
            var dataCatAllParentList = dataCatAllParentMap[dataCatList[dataCatList.length - 1]];
            var dataCatParentList = dataCatAllParentList.split(':');
            for(var i = 0; i < dataCatParentList.length; i++) {
                if(!eligibleDataCatList.includes(dataCatParentList[i]))
                    eligibleDataCatList.push(dataCatParentList[i]);
            }
        }
        
        //get all child data categories
        for(var i = 0; i < dataCatAllList.length; i++) {
            if(dataCatAllList[i].includes(selDataCatOption + ' > ')) {
                var childDataCat = dataCatAllList[i].replace(new RegExp(selDataCatOption + ' > ', 'gi'), '');
                var childDataCatList = childDataCat.split(' > ');
                for(var j = 0; j < childDataCatList.length; j++) {
                    if(!eligibleDataCatList.includes(childDataCatList[j]))
                        eligibleDataCatList.push(childDataCatList[j]);
                }
            }
        }
        
        return eligibleDataCatList;
    },
    
    addMarking: function(helper, data, articleName) {
        var isValid = false;
        var articleNameList = articleName.split(' ');
        //checking all words in articleName
        for(var i = 0; i < articleNameList.length; i++) {
            if(!$A.util.isUndefinedOrNull(articleNameList[i]) && !$A.util.isEmpty(articleNameList[i])
               && data.toUpperCase().includes(articleNameList[i].toUpperCase())) {
                // checking if data contains </mark> && <mark>
                if(data.includes("</mark>")) {
                    var dataList = data.split("</mark>");
                    var dataListValue = "";
                    // iterate dataList
                    for(var j = 0; j < dataList.length; j++) {
                        var dataObjList = dataList[j].split("<mark>");
                        var dataObjListValue = "";
                        // iterate dataObjList
                        for(var k = 0; k < dataObjList.length; k++) {
                            dataObjList[k] = dataObjList[k].replace(new RegExp(articleNameList[i], 'gi'), function (x) {
                                return "<mark>" + x + "</mark>";
                            });
                            dataObjListValue = dataObjListValue + dataObjList[k];
                            if(k != dataObjList.length-1)
                                dataObjListValue = dataObjListValue + "<mark>";
                        }
                        dataListValue = dataListValue + dataObjListValue;
                        if(j != dataList.length-1)
                            dataListValue = dataListValue + "</mark>";
                    }
                    data = dataListValue;
                }
                else {
                    data = data.replace(new RegExp(articleNameList[i], 'gi'), function (x) {
                        return "<mark>" + x + "</mark>";
                    });
                }
                
                isValid = true;
            }
        }
        // create dataObj
        var dataObj = {
            isValid: isValid,
            data: data
        };
        
        return dataObj;
    },
    
    /*addMarking: function(helper, data, articleName) {
        var data = data.replace(new RegExp(articleName, 'gi'), function (x) {
            return '<mark>' + x + '</mark>';
        });
        return data;
    },*/
    
    removeMarking: function(helper, data, repText, repTextWith) {
        data = data.replace(new RegExp(repText, 'gi'), repTextWith);
        return data; 
    }
})