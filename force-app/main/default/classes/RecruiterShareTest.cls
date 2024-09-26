@isTest
public class RecruiterShareTest {
    
    @isTest static void PositiveShareInsert(){
        Schema.DescribeFieldResult fieldResult = Position__c.Recruiter__c.getDescribe();
   		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
   		String Recuiter;

 		for( Schema.PicklistEntry f : ple){
 			if(f.getLabel() != 'External'){
 				Recuiter = f.getLabel();
 			}
   		}
        
        TestFactory.createUser(Recuiter, 'Recuiter@BBSIhq.com', 'Recuiter@BBSIhq.com', 'BBSI Standard', '910', true);
        
        Account Branch = TestFactory.createAccount('Branch', '98683', 'BBSI Branch', true);

        Contact c = TestFactory.createContact(Branch, Recuiter, 'BBSI Employee',  false);
        c.Email = 'Recuiter@BBSIhq.com';
        insert c;
        
        Position__c p = TestFactory.createPosition(Branch, true);
        
        p.Recruiter__c = Recuiter;
        
        update p;
        
        System.assertEquals(1, [Select ID from Position__Share where parentID =: p.ID and RowCause =: Schema.Position__Share.RowCause.Recruiter_Access__c].size());
    }

    @isTest static void NegativeShareInsert(){
        Schema.DescribeFieldResult fieldResult = Position__c.Recruiter__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        String Recuiter;

        for( Schema.PicklistEntry f : ple){
            if(f.getLabel() != 'External'){
                Recuiter = f.getLabel();
            }
        }
        
        TestFactory.createUser(Recuiter, 'Recuiter@BBSIhq.com', 'Recuiter@BBSIhq.com', 'BBSI Standard', '910', true);
        
        Account Branch = TestFactory.createAccount('Branch', '98683', 'BBSI Branch', true);

        Contact c = TestFactory.createContact(Branch, Recuiter, 'BBSI Employee',  false);
        c.Email = 'Recuiter@BBSIhq.com';
        insert c;
        
        Position__c p = TestFactory.createPosition(Branch, true);
        
        p.Recruiter__c = Recuiter;
        
        update p;
        
        System.assertEquals(1, [Select ID from Position__Share where parentID =: p.ID and RowCause =: Schema.Position__Share.RowCause.Recruiter_Access__c].size());

        p.Recruiter__c = NULL;

        update p;

        System.assertEquals(0, [Select ID from Position__Share where parentID =: p.ID and RowCause =: Schema.Position__Share.RowCause.Recruiter_Access__c].size());

    }
}