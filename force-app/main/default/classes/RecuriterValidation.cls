public class RecuriterValidation {

	Map<ID, Position__c> newCollection = (Map<ID, Position__c>)trigger.newMap;
	Map<ID, Position__c> oldCollection = (Map<ID, Position__c>)trigger.oldMap;

	Map<ID, Position__c> recruiterUpdates = new Map<ID, Position__c>();

	public void handle(){
		if(trigger.isUpdate){
			checkUpdate();
			if(recruiterUpdates.values().size() > 0 && !recruiterUpdates.isEmpty()) {
				if (!Profile_Service.mayConfigure(UserInfo.getProfileId())) {
					// Running user is not a System Adminstrator or Configuration Admin

					Set<ID> groupID = getExecutives();
					//Check if running user is not part of the Executive Group

					if(!groupID.contains(UserInfo.getUserId())){
						throwRecruiterError();
					}
				}
			}
		}
	}

	private void checkUpdate(){
		for(Position__c p : newCollection.values()){
			if(p.Recruiter__c != oldCollection.get(p.ID).Recruiter__c){
				recruiterUpdates.put(p.ID, p);
			}
		}
	}

	private Set<ID> getExecutives(){
		String userType = Schema.SObjectType.User.getKeyPrefix();
		ID groupID = [Select ID from Group where name = 'Executives' limit 1].ID;

		Set<ID> ExecutiveID = new Set<ID>();

		for(GroupMember gm :[Select Id, UserOrGroupId From GroupMember Where GroupId = :groupId]){
			if (((String)gm.UserOrGroupId).startsWith(userType)){
				ExecutiveID.add(gm.UserOrGroupId);
			}
		}
		return ExecutiveID;
	}

    private void throwRecruiterError(){
		for(ID i : recruiterUpdates.keySet()){
			newCollection.get(i).addError('You do not have permission to access this field');
		}
	}
}