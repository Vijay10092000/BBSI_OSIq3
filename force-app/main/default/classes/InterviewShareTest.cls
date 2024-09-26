@isTest
public class InterviewShareTest {

    @isTest static void positiveIntervewerShareInsert(){
        User interviewer = TestFactoryUser.createUser(null,'interviewer', 'BBSI Standard', '910','Recuiter@BBSIhq.com', 'Recuiter@BBSIhq.com');
		Account branch = TestFactoryAccount.createBranch('Branch');
        Position__c p = TestFactoryPosition.createPosition(branch.id, null, null);

        Candidate__c c = TestFactoryCandidate.createCandidate('Donald Trump', p.Id, null);
        Interview__c i = TestFactoryInterview.createInterview('Corporate Interview', c.Id, interviewer.Id, null);
        Assert.areEqual(1, [Select ID from Position__Share where parentID =: p.ID and RowCause =: Schema.Position__Share.RowCause.Interviewer_Access__c].size());   	
    }

    @isTest static void positiveIntervewerShareUpdate(){
        User interviewer = TestFactoryUser.createUser(null,'interviewer', 'BBSI Standard', '910','Recuiter@BBSIhq.com', 'Recuiter@BBSIhq.com');
		Account branch = TestFactoryAccount.createBranch('Branch');
        Position__c p = TestFactoryPosition.createPosition(branch.id, null, null);
        Candidate__c c = TestFactoryCandidate.createCandidate('Donald Trump', p.Id, null);
        Interview__c i = TestFactoryInterview.createInterview('Corporate Interview', c.Id, interviewer.Id, null);

        Assert.areEqual(1, [Select ID from Position__Share where parentID =: p.ID and RowCause =: Schema.Position__Share.RowCause.Interviewer_Access__c].size()); 

        i.Interviewer__c = NULL;
        update i;

        Assert.areEqual(0, [Select ID from Position__Share where parentID =: p.ID and RowCause =: Schema.Position__Share.RowCause.Interviewer_Access__c].size()); 

        i.Interviewer__c = interviewer.ID;
        update i;

        Assert.areEqual(1, [Select ID from Position__Share where parentID =: p.ID and RowCause =: Schema.Position__Share.RowCause.Interviewer_Access__c].size());   	
    }    
}