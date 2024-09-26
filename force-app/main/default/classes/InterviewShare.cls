public without sharing class InterviewShare {

	/*
		Class to handle enabling access to the posiiton to whoever is
		set as the an Interviewer
	*/

	List<Interview__c> newCollection = (List<Interview__c>)trigger.new;
	Map<ID, Interview__c> oldCollection = (Map<ID, Interview__c>)trigger.OldMap;

    Set<String> recruiterName = new Set<String>();
    Map<String,ID> rLookup = new Map<String,ID>();
    Map<ID, ID> userLookup = new Map<ID, ID>();
    Map<ID, ID> positionLookup = new Map<ID, ID>();

    Set<Position__c> newInterviewer= new Set<Position__c>();
    Map<ID, ID> oldInterviewer = new Map<ID, ID>();

    /*
		Intial method to handle to parse out what is an insert and what is
		an Update.
    */

	public void handle() {
        if(trigger.isUpdate){
        	filterUpdates();

			if(rLookup.size() > 0 && !rLookup.isEmpty()){
				findPositons();
			}
			if(oldInterviewer.size() > 0 && !oldInterviewer.isEmpty()){
            	removeSharePosition(oldInterviewer);
        	}
			if(positionLookup.size() > 0 && userLookup.size() > 0){
				addSharePosition();
			}

		}else if(trigger.isInsert){
			filterInserts();
			if(rLookup.size() > 0 && !rLookup.isEmpty()){
				findPositons();
			}
			if(positionLookup.size() > 0 && userLookup.size() > 0){
				addSharePosition();
			}
		}
	}

	/*
		Method to cycle through all updates and determine which ones need to
		be updated, old and new records.
	*/

	private void filterUpdates(){
		for(Interview__c i : newCollection){
			if(i.Interviewer__c != oldCollection.get(i.ID).Interviewer__c){
                if(i.Interviewer__c  != NULL){
                    rLookup.put(i.Candidate__c, i.ID);
                    userLookup.put(i.Candidate__c, i.Interviewer__c);
                }
                if(oldCollection.get(i.ID).Interviewer__c != NULL){
                    oldInterviewer.put(oldCollection.get(i.ID).Candidate__c, oldCollection.get(i.ID).Interviewer__c);
                }
			}
            if(i.Interviewer__c == NULL && oldCollection.get(i.ID).Interviewer__c != NULL){
               oldInterviewer.put(oldCollection.get(i.ID).Candidate__c, oldCollection.get(i.ID).Interviewer__c);
            }
		}
	}

	/*
		Method to cycle through all inserts and determine which ones have a interviewer.
	*/

	private void filterInserts(){
		for(Interview__c i : newCollection){
			if(i.Interviewer__c != NULL){
                if(i.Interviewer__c  != NULL){
                    rLookup.put(i.Candidate__c, i.ID);
                    userLookup.put(i.Candidate__c, i.Interviewer__c);
                }
			}
		}
	}

	/*
		Method to find all the relating Positins to the interivews.
	*/

	private void findPositons(){
		for(Candidate__c c : [Select Position__c from Candidate__c where ID IN: rLookup.keySet()]){
			positionLookup.put(c.ID, c.Position__c);
		}
	}

	/*
		Adds in the sharing record to the corresponding Position
	*/

    private void addSharePosition(){
        list<Position__Share> shareList = new list<Position__Share>();
        Position__Share pShare;
        for(ID i : rLookup.keySet()){
            pShare = new Position__Share();

            pShare.AccessLevel = 'Edit';
            pShare.ParentID = positionLookup.get(i);
            pShare.RowCause = Schema.Position__Share.RowCause.Interviewer_Access__c;
            pShare.UserOrGroupId = userLookup.get(i);

            shareList.add(pShare);
        }

        try{
            insert shareList;
        }catch(DMLException e){
            System.debug(e);
        }
    }

    /*
		Finds all the postions that had their interviewer removed or updated
		and update the position share table.
    */

    private void removeSharePosition(Map<ID, ID> oldInterviewer){
    	Map<ID, ID> oldPositions = new Map<ID, ID>();

    	for(Candidate__c c : [Select Position__c from Candidate__c where ID IN: oldInterviewer.keySet()]){
    		oldPositions.put(c.Position__c, oldInterviewer.get(c.ID));
    	}

        try{
            delete [Select ID from Position__Share
            		where ParentID IN: oldPositions.keySet() and RowCause =: Schema.Position__Share.RowCause.Interviewer_Access__c and UserOrGroupId IN: oldPositions.values()];
        }catch(DMLException e){
            System.debug(e);
        }
    }

}