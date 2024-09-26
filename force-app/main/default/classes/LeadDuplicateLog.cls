public class LeadDuplicateLog {
  public void createLeadLog(Lead l, List<possibleMatches> allMatches){
    
    Lead_Duplicate_Log__c dupLog = new Lead_Duplicate_Log__c();
    
    dupLog.Lead__c = l.ID;
    dupLog.Number_of_Duplicates__c = allMatches.size(); 
    dupLog.Type__c = l.RecordType.Name;       
    try{
    	insert dupLog;
	    buildMatches(dupLog, allMatches);   
    }catch(DMLException e){
        system.debug(e);
    }
  }
    
	private void buildMatches(Lead_Duplicate_Log__c duplog, List<possibleMatches> newCollection){
		List<Match__c> newMatches = new List<Match__c>();
		Match__c m;

		for(possibleMatches pm : newCollection){
			m = new Match__c();
			m.Owner__c = pm.Owner.ID;
      
      if(pm.Branch != Null){
				m.Branch__c = pm.Branch.ID;                
      }           
      
      if(pm.Name != Null){
        m.Name = pm.Name;                
      }else{
        if(pm.Company != NULL){
          m.Name = pm.Company;
        }else{
          m.Name = pm.Owner.Name;
        }
      }
      
      if(pm.Company != Null){
				m.Company__c = pm.Company;             
      }
			
      m.Record_ID__c = pm.RecordID;
			m.FEIN__c = pm.FEIN;
			m.Street__c = pm.Street;
			m.Phone__c = pm.Phone;
			m.Created_Date__c = pm.CreatedDate;
			//m.Match_Type__c = pm.matchType;
      m.FEINMatch__c = pm.FEINMatch;
      m.CompanyMatch__c = pm.CompanyMatch;
      m.DBAMatch__c = pm.DBAMatch;
      m.NameMatch__c = pm.NameMatch;
			m.Record_Type__c = pm.RecordType;
			m.Lead_Duplicate_Log__c = dupLog.ID;
      m.DBA_Name__c = pm.DBAName;
			newMatches.add(m);
		}

		try{
			insert newMatches;
		}catch(DmlException e){
			System.debug(e);
		}
	}
}