public class PriceApproval {

    private static List<Account> unaprroveAccounts = new List<Account>();
    private static final ID recordTypeClient = RecordTypeService.getRecordTypeIdsByName('Account').get('Client');

    public static void processPriceApproval(Map<Id, Account> mapAccounts, Map<Id, Account> mapOldAccounts){

        list<ID> priceApprovals = new list<ID>();
        list<ID> priceApprovalComments = new list<ID>();
        list<Client_Control__c> newClientControls = new list<Client_Control__c>();
        Map<String,Schema.SObjectField> clientControlFields = Schema.SObjectType.Client_Control__c.Fields.GetMap();
        set<String> customFields = new set<string>{'Renewal_Date__c'};
        Map<String,Schema.SObjectField> fieldMap;
        fieldMap = Schema.SObjectType.Account.Fields.getMap();
        Schema.SObjectField fieldVal;
        Schema.SoapType FldType;
        Set<String> fieldsChanged = new set<String>();
       
        if(mapOldAccounts != null){
            for(Account a : mapAccounts.values()){
              
              if(a.RecordTypeID == recordTypeClient){
                if(a.Price_Approval__c == 'Approved' && a.Price_Approval__c != mapOldAccounts.get(a.ID).Price_Approval__c){
                  priceApprovals.add(a.ID);
                }

               if(a.Price_Approval_Comments__c != mapOldAccounts.get(a.ID).Price_Approval_Comments__c){
                  priceApprovalComments.add(a.ID);
                }
                set<String> fieldSet = new set<String>();
                for(Schema.FieldSetMember fields :Schema.SObjectType.Account.fieldSets.getMap().get('Price_Approval_To_Unapproved').getFields()){
                  fieldSet.add(fields.getFieldPath());
                }
                
                boolean fieldChanged = false;
                for(String fieldName: fieldSet){
                  if(a.get(fieldName) != mapOldAccounts.get(a.ID).get(fieldName)){
                    if(customFields.Contains(fieldName)){
                        fieldChanged = CustomFieldsChanged(fieldName,a);
                    }else{
                      if(mapOldAccounts.get(a.ID).get(fieldName) != null && a.get(fieldName) != null){
                        fieldVal = fieldMap.get(fieldName);
                        fldType = fieldVal.GetDescribe().getSoapType();
                        if(fldType == Schema.SoapType.STRING){
                          if(validateTextFields(String.ValueOf(a.get(fieldName)), String.ValueOf(mapOldAccounts.get(a.id).get(fieldName)))){
                            fieldschanged.add(fieldname);
                            fieldChanged = true;
                          }
                        }else{
                          fieldChanged = true;
                          fieldsChanged.add(fieldName);
                        }
                      }else{
                        fieldChanged = true;
                        fieldsChanged.add(fieldName);
                      }
                    }
                  }
                }
                  
                boolean bAllFilled = true;
                if(fieldChanged){
                  for(String fieldName: fieldSet){
                    if(customFields.Contains(fieldName)){
                        continue;
                    }
                    if(a.get(fieldName) == null && mapOldAccounts.get(a.id).get(fieldName) ==null){
                      bAllFilled = false;
                      break; //one is null that's all we care about.
                    }
                  } 
                }
				
                if(fieldChanged && bAllFilled){
                  Client_Control__c control;
                  for(String fieldName: fieldSet){
                    if(fieldsChanged.contains(fieldName) &&
                       mapOldAccounts.get(a.id).get(fieldName) != null){
                        if(clientControlFields.containsKey(fieldName)){
                          if(control == null){
                            control = new Client_Control__c(Account__c = a.ID);
                          }
                          control.put(fieldName,mapOldAccounts.get(a.ID).get(fieldName));
                      }
                    }
                  }
                  if(control != null){
                    newClientControls.add(control);
                  }
                  a.Price_Approval__c = 'Unapproved';
                }

              }
            }
            if(newClientControls != null && newClientControls.size() > 0){
                ID aID = newClientControls[0].Account__c;
                insert newClientControls;
            }       
        }else if(mapOldAccounts == null){
            for(Account a : mapAccounts.values()){
                if(a.RecordTypeID ==  recordTypeClient){
                    if(a.RecordTypeID == recordTypeClient && a.Price_Approval__c == 'Approved'){
                        priceApprovals.add(a.ID);
                    }
                    if(a.Price_Approval_Comments__c != NULL){
                        priceApprovalComments.add(a.ID);
                    }               
                }
            }
        }

        if(priceApprovals.size() > 0 || priceApprovalComments.size() > 0){
            checkApprovals(priceApprovals, priceApprovalComments, mapAccounts);
        }
    }

    private static boolean validateTextFields(String newVal, String OldVal){

      boolean returnVal = false;
      list<String> NewValues;
      list<String> OldValues;

      if(newVal != null && newVal.Length() > 0){
        NewValues = NewVal.split('\n');
      }

      if(OldVal != null && oldVal.Length() > 0){
        OldValues = OldVal.split('\n');
      }
      

      if(NewValues != null && oldValues != null){  
        Integer cnt = 0;
        if(NewValues.Size() != OldValues.Size()){
          returnval = true;
        }else{
          for(String SingleNew: NewValues){
            if(SingleNew.trim() != oldValues[cnt].trim()){
              returnVal = true;
              break;      
            }
            cnt ++;
          }
        }
      }else{
        if(NewValues != null && oldValues == null){
          returnVal = true;
        }else{
          if(NewValues == null && oldValues != null){
            returnVal = true;
          }
        }
      }
      
      return returnVal;
    }

    private static boolean CustomFieldsChanged(String field,Account acct){
        boolean returnval = false;
        OrgWide__c orgWide = OrgWide__c.getInstance();
        Integer renewaldays = Integer.ValueOf(orgWide.Days_Account_Renewal_Date__c);
               
        if(field == 'Renewal_Date__c' && acct.Price_Approval__c == 'Approved' && acct.Price_Approval_Date__c != null){
            Date dtoday = System.Today();
            System.Debug('renewaldays ' + renewaldays);
            System.Debug(acct.Price_Approval_Date__c.DaysBetween(dToday));
            if(acct.Price_Approval_Date__c.DaysBetween(dToday) > renewaldays){
                returnval = true;
            }
        }else{
            if(acct.Price_Approval__c == 'Unapproved'){
                returnval = true; //assume if it's unapproved we want to create the tracking records.
            }
        }
        System.Debug('Field changed: ' + field + ' ' + returnval);
        return returnval;
    }

    private static map<ID, string> getBranch(List<ID> acctID){
        Map<ID, string> branchLookup = new Map<ID,string>();

        for(Account a : [Select ID, Prospect_Branch__r.Name From Account where ID IN :acctID]){
            System.debug('Branches: ' + a.Prospect_Branch__c);
            BranchLookup.put(a.ID, a.Prospect_Branch__r.Name);
        }

        return BranchLookup;
    }

    private static Map<String, String> getBranchAdmin(){
        Map<String, String> BranchAdmin = new Map<String,String>();
        
        list<Admin_Branch__c> adminBranch = Admin_Branch__c.getall().values();
        
        for(Admin_Branch__c a : adminBranch){
            BranchAdmin.put(a.name, a.Admin_User__c);
        }
                
        return BranchAdmin;
    }

    private static void checkApprovals(List<ID> priceApprovals, List<ID> priceApprovalComments, Map<Id, Account> mapAccounts){
        User loggedUser = [Select ProfileID, Name, Title from User where ID = :UserInfo.getUserID() limit 1];

        Map<ID, String> branchLookup = getBranch(priceApprovals);
        Map<String, String> BranchAdmin = getBranchAdmin();

        if (!Profile_Service.mayConfigure(loggedUser.ProfileId)) {
            Boolean isAreaManager = User_Services.actsAsAreaManager(UserInfo.getUserId());

					  // Running user is not a System Adminstrator or Configuration Admin
            
            for(ID i : priceApprovals){
                if(!isAreaManager && branchAdmin.get(BranchLookup.get(i)) != loggedUser.name){
                        mapAccounts.get(i).addError('You must be an Area Manager or Delegated Admin to approve records.'); 
                }
            }                  
            for(ID i:priceApprovalComments){
                if(!isAreaManager && branchAdmin.get(BranchLookup.get(i)) != loggedUser.name){
                        mapAccounts.get(i).addError('You must be an Area Manager or Delegated Admin to edit Comments.'); 
                }
            }
        }           
    }
}