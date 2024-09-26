/**
 * @description ClientRelationSummaryController
 */   
public class ClientRelationSummaryController {
    public String BUid {get; set;}   
    public Integer clientRelationSummaryRan {get; set;}
    public String accountID {get;set;}   
    public List<Business_Unit_Contact__c> BUteams;

    public ClientRelationSummaryController() {
        clientRelationSummaryRan = 0;
    }

    public list<Business_Unit_Contact__c> getBUteams(){
        return [
            SELECT Id, Role__c, Active_Date__c, BU_Member__r.User_Id__r.Name, BU_Member__r.User_Id__r.Email
            FROM Business_Unit_Contact__c 
            WHERE Business_Unit__c = :BUid
            AND Active__c = true
        ];  
    }
}