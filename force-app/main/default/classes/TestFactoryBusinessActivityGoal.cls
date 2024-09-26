@isTest
public class TestFactoryBusinessActivityGoal {

	/**
     * @description makeBusinessActivityGoal description
     * @param  year       Year of the goal
     * @param  quarter    Quarter (1-4 or 0 for full year)
     * @param  isOverride ???
     * @param  value      Value to put into all the goal fields
     * @param  idBranch   If set, the branch goals, else for BDMs
     * @return A new Business_Activity_Goal__c
     */
	public static Business_Activity_Goal__c makeBusinessActivityGoal(Integer year, Integer quarter, Boolean isOverride, Integer value, Id idBranch) {
		return makeBusinessActivityGoal(year, quarter, isOverride, value, idBranch, null);
	}

	/**
     * @description createBusinessActivityGoal description
     * @param  year       Year of the goal
     * @param  quarter    Quarter (1-4 or 0 for full year)
     * @param  isOverride ???
     * @param  value      Value to put into all the goal fields
     * @param  idBranch   If set, the branch goals, else for BDMs
     * @return A new inserted Business_Activity_Goal__c
     */
	public static Business_Activity_Goal__c createBusinessActivityGoal(Integer year, Integer quarter, Boolean isOverride, Integer value, Id idBranch) {
		Business_Activity_Goal__c bag = makeBusinessActivityGoal(year, quarter, isOverride, value, idBranch, null);
		insert bag;
		return bag;
	}

	/**
     * @description makeBusinessActivityGoal description
     * @param  year       Year of the goal
     * @param  quarter    Quarter (1-4 or 0 for full year)
     * @param  isOverride ???
     * @param  value      Value to put into all the goal fields
     * @param  idBranch   If set, the branch goals, else for BDMs
     * @param  fldMap     Additional fields to set on Business Activity Goal
     * @return A new Business_Activity_Goal__c
     */
	public static Business_Activity_Goal__c makeBusinessActivityGoal(Integer year, Integer quarter, Boolean isOverride, Integer value, Id idBranch, Map<String,Object> fldMap) {
		Id idGoalBDM = RecordTypeService.getId('Business_Activity_Goal__c', 'BDM Goal');
		Id idGoalBranch = RecordTypeService.getId('Business_Activity_Goal__c', 'Branch Goal');

		Business_Activity_Goal__c bag = new Business_Activity_Goal__c(
			RecordTypeId = (idBranch == null) ? idGoalBDM : idGoalBranch,
			Branch__c = idBranch,
			Start_Year__c = String.valueOf(year),
			Start_Quarter__c = 'Quarter ' + quarter,
			Override__c = isOverride,
			Discovery_Meetings__c = value,
			Events__c = value,
			Lost_Clients_Contacted__c = value,
			Lost_Leads_Contacted__c = value,
			New_Clients__c = value,
			New_Leads__c = value,
			New_Referral_Partners_Contacted__c = value,
			Producer_Tracks_Info_Sessions__c = value,
			Referral_Partner_Plans_In_Place__c = value,
			Referral_Partner_Touches__c = value,
			RP_Touches_In_Person__c = value,
			RP_Touches_Virtual__c = value,
			WSE_Added__c = value
		);

		if (fldMap != null) {
            bag = (Business_Activity_Goal__c) TestFactory.assignFields(fldMap, bag);
        }

        return bag;
	}

	/**
     * @description createBusinessActivityGoal description
     * @param  year       Year of the goal
     * @param  quarter    Quarter (1-4 or 0 for full year)
     * @param  isOverride ???
     * @param  value      Value to put into all the goal fields
     * @param  idBranch   If set, the branch goals, else for BDMs
     * @param  fldMap     Additional fields to set on Business Activity Goal
     * @return A new inserted Business_Activity_Goal__c
     */
	public static Business_Activity_Goal__c createBusinessActivityGoal(Integer year, Integer quarter, Boolean isOverride, Integer value, Id idBranch, Map<String,Object> fldMap) {
		Business_Activity_Goal__c bag = makeBusinessActivityGoal(year, quarter, isOverride, value, idBranch, fldMap);
		insert bag;
		return bag;
	}
}