@IsTest
public class RecruiterHistory_Test {

    @IsTest
    public static void testRemoveHistory() {
        Account Branch = TestFactory.createAccount('Branch', '99999', 'BBSI Branch', true);

        Position__c position = TestFactory.createPosition(Branch, false);
        position.Status__c = 'open';
        position.Filled_Date__c = Date.today();
        insert position;

        Recruiter_History__c newRH = new Recruiter_History__c(
            Name = '--Test Recuriter History--',
            Days_Active__c = 72, 
            Position__c = position.Id
        );

        insert newRH;
        
		position.Recruiter__c = 'Internal Recruiter';
        update position;

        List<Recruiter_History__c> histories;

        histories = [
            SELECT Id, Name FROM Recruiter_History__c 
            WHERE Name = '--Test Recuriter History--' AND Days_Active__c = 72 AND Position__c = :position.id
        ];

        System.assertEquals(1, histories.size());

        Test.startTest();

        RecruiterHistory rh = new RecruiterHistory();
        rh.removeHistory(histories);

        Test.stopTest();

        histories = [
            SELECT Id, Name FROM Recruiter_History__c 
            WHERE Name = '--Test Recuriter History--' AND Days_Active__c = 72 AND Position__c = :position.id
        ];

        System.assertEquals(0, histories.size());
    }

    @IsTest
    public static void testGetHistory() {
        Account Branch = TestFactory.createAccount('Branch', '99999', 'BBSI Branch', true);

        Position__c position1 = TestFactory.createPosition(Branch, false);
        position1.Status__c = 'open';
        position1.Filled_Date__c = Date.today();
        insert position1;

        Recruiter_History__c newRH1 = new Recruiter_History__c(
            Name = '--Test Recuriter History--',
            Days_Active__c = 72, 
            Position__c = position1.Id
        );
        Recruiter_History__c newRH2 = new Recruiter_History__c(
            Name = '--Test Recuriter History--',
            Days_Active__c = 52, 
            Position__c = position1.Id
        );

        insert new List<Recruiter_History__c>{ newRH1, newRH2 };

		position1.Recruiter__c = 'Internal Recruiter';
        update position1;

        RecruiterHistory rh = new RecruiterHistory();
        rh.positionHistoryID.add(position1.Id);

        Test.startTest();

        rh.getHistory();

        Test.stopTest();

        System.assertEquals(3, rh.recrutierMap.keySet().size());
    }

    @IsTest
    public static void testRecruterHistory() {
        Account Branch = TestFactory.createAccount('Branch', '98683', 'BBSI Branch', true);

        Position__c position = TestFactory.createPosition(Branch, false);
        position.Status__c = 'open';
        position.Filled_Date__c = Date.today();
        insert position;

        position = [SELECT Id, Recruiter__c, Days_With_Recruiter__c FROM Position__c WHERE Id = :position.Id];

        position.Recruiter__c = 'Internal Recruiter';
        update position;

        Recruiter_History__c rh = [SELECT Id, Days_Active__c FROM Recruiter_History__c WHERE Position__c = :position.Id];
        System.assertEquals(0, rh.Days_Active__c);
    }

}