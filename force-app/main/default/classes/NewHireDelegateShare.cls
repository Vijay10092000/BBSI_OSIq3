public class NewHireDelegateShare {

	List<Position__c> newCollection = (List<Position__c>)trigger.new;
	Map<ID, Position__c> oldCollection = (Map<ID, Position__c>)trigger.oldMap;

	public void handle(){
        Map<ID, String> AdminLookup = new Map<ID, String>();
		if(trigger.isInsert){
			AdminLookup = getDelegate();
		}else if(trigger.IsUpdate){
			findBadShare();
			AdminLookup = getDelegate();
		}

        if(!AdminLookup.isEmpty() && AdminLookup.size() > 0){
            ShareNewHire(AdminLookup);
        }
	}

	private Map<ID, String> getDelegate(){
		Map<ID, ID> BranchID = new Map<ID, ID>();
		Map<String, String> BranchAdminApproval = new Map<String, String>();
		Map<String, ID> UserLookup = new Map<String, ID>();
		Map<ID, String> AdminLookup = new Map<ID, String>();

		//Get all postion and their related branches
		for(Position__c p : newCollection){
			BranchID.put(p.Branch__c, p.ID);
			AdminLookup.put(p.ID, '');
		}

 		//Get all the New Hire delegates
		for(Admin_Branch__c a: [Select ID, Name, New_Hire_Delegate__c from Admin_Branch__c where New_Hire_Delegate__c != NULL]){
            BranchAdminApproval.put(a.name.toUpperCase(), a.New_Hire_Delegate__c);
        }

        //Get all the user records for the New Hire Delegates
        for(User u : [Select ID, Name from User where Name IN :BranchAdminApproval.values()]){
        	UserLookup.put(u.Name, u.ID);
        }

        //All branches with the Position as the key and the Branch Name as the value
		for(Account a: [Select ID, Name, Lead_AM_Approval__c from Account where ID IN : BranchID.keySet()]){
			AdminLookup.put(BranchID.get(a.ID), UserLookup.get(BranchAdminApproval.get(a.Name.toUpperCase())));
		}

		return AdminLookup;
	}

	//Find all of the updated positons with an old Branch
	private void findBadShare(){
		Set<ID> badShare = new Set<ID>();

		for(Position__c p : newCollection){
			if(p.Branch__c != oldCollection.get(p.ID).Branch__c){
				badShare.add(p.ID);
			}
		}

		if(badShare.size() > 0){
			removeBadShare(badShare);
		}
	}

	//Find all the related Sharing records remove them
	private void removeBadShare(Set<ID> badShare){
		List<Position__Share> removeShare = new List<Position__Share>();

		for(Position__Share ps : [Select ID from Position__Share where ParentID IN: badShare and RowCause = 'Delegate__c']){
			removeShare.add(ps);
		}

		try{
			delete removeShare;
		}catch(DmlException e){
			system.debug(e);
		}
	}

	private void ShareNewHire(Map<ID, String> AdminLookup){
		List<Position__Share> pShareList = new List<Position__Share>();
		Position__Share pShare;

		for(ID i : AdminLookup.keySet()){
            if(adminLookup.get(i) != NULL){
                pShare = new Position__Share();

                pShare.ParentID = i;
                pShare.UserOrGroupId = adminLookup.get(i);
                pShare.AccessLevel = 'Edit';
                pShare.RowCause = Schema.Position__Share.RowCause.Delegate__c;

                pShareList.add(pShare);
            }
		}

        if(pShareList.size() > 0){
            try{
                insert pShareList;
            }catch(DmlException e){
                System.debug(e);
            }
        }
	}
}