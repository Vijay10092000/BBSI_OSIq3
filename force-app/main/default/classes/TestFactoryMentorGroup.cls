@isTest
public class TestFactoryMentorGroup {

    public static Mentor_Group__c makeMentorGroup(String name) {
        List<Mentor_Group__c> mentorGroups = new List<Mentor_Group__c>();
        mentorGroups = makeMentorGroups(name, 1);
        return mentorGroups.get(0);
    }

    public static Mentor_Group__c createMentorGroup(String name) {
        Mentor_Group__c mentorGroup = makeMentorGroup(name);
        insert mentorGroup;
        return mentorGroup;
    }

    public static List<Mentor_Group__c> makeMentorGroups(String name, Integer numGroups) {
        List<Mentor_Group__c> mentorGroups = new List<Mentor_Group__c>();

        for(Integer i = 0; i < numGroups; i++) {
            Mentor_Group__c mg = new Mentor_Group__c();
            mg.Name= name + ' ' + i;
            mentorGroups.add(mg);
        }

        return mentorGroups;
    }

    public static List<Mentor_Group__c> createMentorGroups(String name, Integer numGroups) {
        List<Mentor_Group__c> mentorGroups = makeMentorGroups(name, numGroups);
        insert mentorGroups;
        return mentorGroups;
    }

}