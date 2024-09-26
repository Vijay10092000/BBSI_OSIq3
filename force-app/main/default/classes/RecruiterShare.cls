public class RecruiterShare {

    /*
        Class to handle sharing of the Position to the select Recruiter.
        Recruiter will have Edit access for position and for Candidates and
        Interviews as well.
    */

	List<Position__c> newCollection = (List<Position__c>)trigger.new;
	Map<ID, Position__c> oldCollection = (Map<ID, Position__c>)trigger.OldMap;

    Set<String> recruiterName = new Set<String>();
    Map<String,ID> rLookup = new Map<String,ID>();

    Set<Position__c> newRecuiter = new Set<Position__c>();
    Set<ID> oldRecruiter = new Set<ID>();

    /*
        Intial handle method to fitler out any record that isn't an Update.  If
        it is an update check and there is an update to the recruiter field.
        Send the list to build the sharing records.
    */

	public void handle(){
        if(trigger.isUpdate){
			filterUpdates();

			if(newRecuiter.size() > 0  && !newRecuiter.isEmpty()){
                getRecuiter();
                addSharePosition(newRecuiter);
			}
            if(oldRecruiter.size() > 0 && !oldRecruiter.isEmpty()){
                removeSharePosition(oldRecruiter);
            }
		}
	}

    /*
        Go through each updated position and verify that each update has an
        new Recuiter and add it to the map.
    */

	private void filterUpdates(){
		for(Position__c p : newCollection){
			if(p.Recruiter__c != oldCollection.get(p.ID).Recruiter__c){
                if(p.Recruiter__c != NULL){
                    newRecuiter.add(p);
                    rLookup.put(p.Recruiter__c, p.ID);
                }else if(oldCollection.get(p.ID).Recruiter__c != NULL){
                    oldRecruiter.add(oldCollection.get(p.ID).ID);
                }
			}
            if(p.Recruiter__c == NULL && oldCollection.get(p.ID).Recruiter__c != NULL){
                oldRecruiter.add(oldCollection.get(p.ID).ID);
            }
		}
	}

    /*
        Get all the recruiter's user records that have been assigned to
        the positions.
    */

    private void getRecuiter(){
        for(User u : [Select ID, Name from User where name IN :rLookup.keySet()]){
            rLookup.put(u.Name, u.ID);
        }
	}

    /*
        Build out the Position sharing from the set<Position> for Recruiters.
        Each recruiter gets full read/edit access to Position => Candidate =>
        Interview => Offer
    */

    private void addSharePosition(Set<Position__c> newRecuiter){
        list<Position__Share> shareList = new list<Position__Share>();
        Position__Share pShare;

        for(Position__c p : newRecuiter){
            pShare = new Position__Share();

            pShare.AccessLevel = 'Edit';
            pShare.ParentID = p.ID;
            pShare.RowCause = Schema.Position__Share.RowCause.Recruiter_Access__c;
            pShare.UserOrGroupId = rLookup.get(p.Recruiter__c);

            shareList.add(pShare);
        }

        try{
            insert shareList;
        }catch(DMLException e){
            System.debug(e);
        }
    }

    /*
        Go through the list of Positions that have had their Recruiter's removed
        and remove the old recruiter from the sharing table.
    */

    private void removeSharePosition(Set<ID> oldRecruiter){
        try{
            delete [Select ID from Position__Share where ParentID IN: oldRecruiter and RowCause =: Schema.Position__Share.RowCause.Recruiter_Access__c];
        }catch(DMLException e){
            System.debug(e);
        }
    }
}