public class RecruiterHistory {

	Map<ID, Position__c> newCollection = (Map<ID, Position__c>)trigger.newMap;
    List<Position__c> newInsert = (List<Position__c>)trigger.new;
	Map<ID, Position__c> oldCollection = (Map<ID, Position__c>)trigger.oldMap;

	@TestVisible
	Set<ID> positionHistoryID =  new Set<ID>();
	@TestVisible
	Map<ID, Recruiter_History__c> recrutierMap = new Map<ID, Recruiter_History__c>();
    Map<String, Double> daysRecruiter = new Map<String, Double>();

	public void handle(){
		Set<Position__c> oldRecuiters = checkUpdate();

		if(oldRecuiters.size() > 0 && trigger.isAfter){
			createRecruiterHistory(oldRecuiters);
		}
	}

	/*
		Cycle though all updates and check if any of them have an update
		to the Recruiter field.
	*/
	private Set<Position__c> checkUpdate(){
		Set<Position__c> oldRecuiters = new Set<Position__c>();

		if(trigger.isUpdate){
      System.Debug('check update recruiter');
			for(Position__c p : newCollection.values()){
				if(p.Recruiter__c != oldCollection.get(p.ID).Recruiter__c && p.Recruiter__c != NULL){
					oldRecuiters.add(p);
					positionHistoryID.add(p.ID);
          System.Debug('old recruiters ' + oldRecuiters + ' ' + positionHistoryID);
				}
			}
		}else if(trigger.isInsert){
			for(Position__c p : newInsert){
				if(p.Recruiter__c != NULL){
					oldRecuiters.add(p);
					positionHistoryID.add(p.ID);
				}
			}
		}

        if(positionHistoryID.size() > 0 && trigger.isBefore){
            updateChangeDate();
        }

		return oldRecuiters;
	}

	/*
		Go through the updated Positions and determine if the recruiter update was
		the first time or there have been previous updates.  If it is the first time
		assign the recruiter change date to the days active.  Else calculate the
		difference between the latest recruiter date and the recrutier change date.
	*/
	private void createRecruiterHistory(Set<Position__c> oldRecuiters){
		List<Recruiter_History__c> historyList = new List<Recruiter_History__c>();
		List<Recruiter_History__c> removeHistory = new List<Recruiter_History__c>();

		getHistory();

		Recruiter_History__c rh;
    System.Debug('recrutierMap ' + recrutierMap);
		for(Position__c p :oldRecuiters){
			rh = new Recruiter_History__c();
      System.debug('creating history');
			rh.Position__c = p.ID;

            if(p.Days_with_Recruiter__c != NULL){
            	rh.Days_Active__c = oldCollection.get(p.ID).Days_with_Recruiter__c;
            }else{
                rh.Days_Active__c = 0;
            }


            if(trigger.isUpdate){
            	rh.Name = NewCollection.get(p.ID).Recruiter__c;
            }else if(trigger.isInsert){
            	rh.Name = newCollection.get(p.ID).Recruiter__c;
            }


            for(ID i : recrutierMap.keySet()){
            	if(rh.Name == recrutierMap.get(i).Name && rh.Position__c == recrutierMap.get(i).Position__c){
                    removeHistory.add(recrutierMap.get(i));
                }
            }

			historyList.add(rh);
		}
        System.Debug('historyList: ' + historyList + ' removeLIst: ' + removeHistory);
        if(removeHistory.size() > 0){
            removeHistory(removeHistory);
        }

        if(historyList.size() > 0){
            try{
                insert historyList;
            }catch(DmlException e){
                System.debug('Error: ' + e.getMessage());
            }
        }
	}


	/*
		Query Recruiter History and get all the records associtated with the
		Positons that have been updated. Put the records in a Map, Key => PositionID
		and Value => CreatedDate.  If a matching key is found, check the value and see
		if it is newer or older.  If newer replace the older value with the newer one.
	*/
    @TestVisible
	private void getHistory(){
		Map<ID, Recruiter_History__c> recruiterDate = new Map<ID, Recruiter_History__c>();
		for(Recruiter_History__c rh : [Select ID, Name, Position__c, CreatedDate, Days_Active__c from Recruiter_History__c where Position__c IN: positionHistoryID]){
			if(recruiterDate.containsKey(rh.position__c)){
				if(recruiterDate.get(rh.Position__c).CreatedDate < rh.CreatedDate){
					recruiterDate.put(rh.Position__c, rh);
				}
			}else{
				recruiterDate.put(rh.Position__c, rh);
			}
			recrutierMap.put(rh.ID, rh);
		}
	}

    @TestVisible
    private void removeHistory(List<Recruiter_History__c> removeHistory){
        try{
            delete removeHistory;
        }catch(DMLException e){
            System.debug(e);
        }
    }

    private void updateChangeDate(){

        System.Debug('Updateing change date');

        List<Position__c> recruiterDayUpdate = new List<Position__c>();

        if(trigger.isUpdate){
            for(recruiter_history__c rh : [Select Name, Days_Active__c from recruiter_history__c where Position__c IN: positionHistoryID]){
                if(rh.Days_Active__c != NULL){
                   daysRecruiter.put(rh.Name, rh.Days_Active__c);
                }else{
                   daysRecruiter.put(rh.Name, 0);
                }
            }
            System.debug('Days Recruiter: ' + daysRecruiter);
            for(Position__c p : newCollection.values()){
                if(daysRecruiter.containsKey(p.Recruiter__c)){
                    p.Recruiter_History_Count__c = daysRecruiter.get(p.Recruiter__c);
                }else{
                    p.Recruiter_History_Count__c = 0;
                }
                p.Recruiter_Change_Date__c = System.today();
            }
        }
    }
}