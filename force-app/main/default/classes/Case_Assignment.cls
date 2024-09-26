/**
 * Case_Assignment
 */
public without sharing class Case_Assignment {
    public class CaseAssignmentException extends Exception {}
    
    private static String nameTemplate = 'New Queue Assignment Notification';
    private static List<Case_Assignment_Rule__mdt> rules = null;
    private static Map<String, Group> mapQueueNameToGroup = null;
    private static Id idTemplate = null;
    private static Map<Id, String> recordTypes = null;

    private static String EMAIL_TO_CASE = 'Email to Case';

    // Used in UPDATE to block assignment
    private Boolean blockAssignment = false;
    private Boolean checkRecordType = true;
    
    /**
     * Case_Assignment constructor - private
     */
    @testVisible
    private Case_Assignment() {
        if (rules == null) {
            rules = readRules();
        }
        
        if (mapQueueNameToGroup == null) {
            mapQueueNameToGroup = retrieveQueues();
        }
        
        if (idTemplate == null) {
            EmailTemplate template = [SELECT Id FROM EmailTemplate WHERE Name = :nameTemplate LIMIT 1];
            idTemplate = template.Id;
        }
    }
    
    /**
     * assignCases is the access to the Case_Assignment class and performs
     * the assignments of the given cases
     */
    public static void assignCases(List<Case> cases) {       
        if (cases != null && !cases.isEmpty()) {
            try {
                AssignmentRule AR = [SELECT id FROM AssignmentRule WHERE SobjectType = 'Case' AND Active = true LIMIT 1];
                System.debug(LoggingLevel.INFO, 'Case_Assignment is disabled while there is an active Case Assignment Rule.');
            }
            catch (Exception e) {
                // No Active AssignmentRule has been found, so use the Case_Assignment class
                Case_Assignment ca = new Case_Assignment(); 
                ca.blockAssignment = false;       
                ca.performAssignments(cases, true);
            }
        }
    }    
    /**
     * assignCases is the access to the Case_Assignment class and performs
     * the assignments of the given cases
     */
    public static void updateAssignCases(map<ID, Case> mapNewCases, map<ID, Case> mapOldCases) {       
        if (mapNewCases != null && !mapNewCases.isEmpty()) {
            try {
                AssignmentRule AR = [SELECT id FROM AssignmentRule WHERE SobjectType = 'Case' AND Active = true LIMIT 1];
                System.debug(LoggingLevel.INFO, 'Case_Assignment is disabled while there is an active Case Assignment Rule.');
            }
            catch (Exception e) {
                // No Active AssignmentRule has been found, so use the Case_Assignment class
                List<Case> cases = new List<Case>();
                for (Case newCase : mapNewCases.values()) {
                    Case oldCase = mapOldCases.get(newCase.Id);
                    
                    if (oldCase.Type != newCase.Type ||
                        oldCase.Type__c != newCase.Type__c ||
                        oldCase.Sub_Type__c != newCase.Sub_Type__c) {
                        cases.add(newCase);
                    }
                    
                }
                Case_Assignment ca = new Case_Assignment();
                ca.blockAssignment = true;
                ca.performAssignments(cases, false);
            }
        }
    }
    
    /**
     * readRules queries the Metadata for the assignment rules.
     * 
     * @return Asending ordered list of the assignment rules.
     */
    public static List<Case_Assignment_Rule__mdt> readRules() {
        return [ SELECT id, Label, DeveloperName, Order__c, Case_Record_Type__c, Category__c, Type__c,
                        Sub_Type__c, Primary_Application__c, Scope__c, Account_Record_Type__c,
                        Queue__c, Severity__c
                 FROM Case_Assignment_Rule__mdt
                 ORDER BY Order__c ASC ];
    }
    
    /**
     * readRules set the current list of Assignment rules.
     */
    @testVisible
    private static void setRules(List<Case_Assignment_Rule__mdt> newRules) {
        rules = newRules;
        mapQueueNameToGroup = retrieveQueues();
    }

    /**
     * performAssignments runs through the Metadata rules Case_Assignment_Rule__mdt
     * and will assign the case based on the first matching rule.  If needed
     * an email will be sent for the change of ownership.
     */
    @testVisible
    private void performAssignments(List<Case> cases, Boolean isOnCreate) {  
        Map<Id, String> mapRecordType = getRecordTypeNames(cases);

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        Case_Assignment_Rule__mdt ruleToApply;
        Group queue;
        
        for (Case c : cases) {
            if (isOnCreate && 
                (c.Origin == 'Email to Case' || c.Origin == 'Unverified Email')) {
                continue;
            }

            String recordType = mapRecordType.get(c.RecordTypeId);
            
            checkRecordType = (recordType != EMAIL_TO_CASE);

            ruleToApply = findMatchingRule(recordType, c.Type, c.Type__c, c.Sub_Type__c, 
                                           c.Primary_Product__c, c.Scope__c, c.Account.RecordType.Name);

            if (ruleToApply == null) {
                System.debug(LoggingLevel.ERROR, 'Missing "Catch-All" assignment rule');
            }
            else {
                String nameQueue = ruleToApply.Queue__c;
                if (!String.isBlank(nameQueue)) {
                    if (!mapQueueNameToGroup.keySet().contains(nameQueue)) {
                        nameQueue = rules.get(rules.size()-1).Queue__c;
                    }

                    queue = mapQueueNameToGroup.get(nameQueue);
                    if (!blockAssignment && !c.Block_Auto_Assignment__c) {
                        c.OwnerId = queue.Id;
                    }
                }

                if (!String.isBlank(ruleToApply.Severity__c)) {
                    c.Severity__c = ruleToApply.Severity__c;
                }
                
                isOnCreate = false;  // TODO: FOR NOW - DO NOT SENT EMAILS
                if (isOnCreate && ruleToApply.Send_Email_on_Create__c && needEmail(queue)) {
                    emails.add(createEmail(c, queue));
                }
                
                c.Block_Auto_Assignment__c = false;
            }
        }

        if (!emails.isEmpty() && !Test.isRunningTest()) {
            Messaging.sendEmail(emails);
        }       
    }
    
    /**
     * findMatchingRule runs through the given list of rules in list order
     * to find the first which matches the fields from the given case.
     * 
     * @param  caseRecordType - Record Type of the Case
     * @param  caseCategory - Category of the Case (Type)
     * @param  caseType - Type of the Case (Type__c)
     * @param  caseSubType - Sub-Type of the Case (Sub_Type__c) 
     * @param  casePrimaryApplication - Primary Application of the Case (Primary_Product__c)
     * @param  caseScope - Scope of the Case (Scope__c)
     * @param  caseAccountRecordType - Record Type of the Account related to the Case
     * @return The matching rule or null if none found
    */
    @testVisible
    private Case_Assignment_Rule__mdt findMatchingRule(String caseRecordType, 
                                                       String caseCategory,  
                                                       String caseType,
                                                       String caseSubType, 
                                                       String casePrimaryApplication,  
                                                       String caseScope,  
                                                       String caseAccountRecordType) {
        for (Case_Assignment_Rule__mdt rule : rules) {
            if (checkRuleMatch(rule, caseRecordType, caseCategory, caseType, caseSubType, casePrimaryApplication, caseScope, caseAccountRecordType)) {
                return rule;
            }   
        }

        return null;
    }

    /**
     * checkRuleMatch compares the rule to the given values to determine
     * if they match.
     * 
     * @param  caseRecordType - Record Type of the Case
     * @param  caseCategory - Category of the Case (Type)
     * @param  caseType - Type of the Case (Type__c)
     * @param  caseSubType - Sub-Type of the Case (Sub_Type__c) 
     * @param  casePrimaryApplication - Primary Application of the Case (Primary_Product__c)
     * @param  caseScope - Scope of the Case (Scope__c)
     * @param  caseAccountRecordType - Record Type of the Account related to the Case
     * @return true if rule matches, false if not
     */
    @testVisible
    private Boolean checkRuleMatch(Case_Assignment_Rule__mdt rule, 
                                   String caseRecordType, 
                                   String caseCategory,  
                                   String caseType,  
                                   String caseSubType, 
                                   String casePrimaryApplication,  
                                   String caseScope,  
                                   String caseAccountRecordType) {
        if (checkRecordType) {
            if (rule.Case_Record_Type__c != 'Any' && rule.Case_Record_Type__c != caseRecordType) {
                return false;
            }
        }
        if (rule.Category__c != 'Any' && rule.Category__c != caseCategory) {
            return false;
        }                
        if (rule.Type__c != 'Any' && rule.Type__c != caseType) {
            return false;
        }
        if (rule.Sub_Type__c != 'Any' && rule.Sub_Type__c != caseSubType) {
            return false;
        }               
        if (rule.Primary_Application__c != 'Any' && rule.Primary_Application__c != casePrimaryApplication ) {
            return false;
        }
        if (rule.Scope__c != 'Any' && rule.Scope__c != caseScope) { 
            return false;
        }
        if (rule.Account_Record_Type__c != 'Any' && rule.Account_Record_Type__c != caseAccountRecordType) {
            return false;
        }
        return true;
    }
    
    /**
     * retrieveQueues gets a map relating Queue Names to Ids for the
     * given rules.
     */
    @testVisible
    private static Map<String, Group> retrieveQueues() {
        Map<String, Group> result = new Map<String, Group>();

        Set<String> names = new Set<String>();
        for (Case_Assignment_Rule__mdt rule : rules) {
            names.add(rule.Queue__c);
        }

        for (Group g : [SELECT Id, Name, DoesSendEmailToMembers, Email FROM Group WHERE Type = 'QUEUE' AND Name In :names]) {
            result.put(g.Name, g);
        }

        if (result.size() != names.size()) {
            // Not all queues in the rules exist.  Find out which are missing and send email.
            String missingQueues = '';
            for (String name : names) {
                if (!result.keySet().contains(name)) {
                    missingQueues += ' "' + name + '"';
                }
            }

            emailAdministrators(
                'Case Assingment Rule Error', 
                'Case Assignment Rule did not find the following queue(s): ' + missingQueues + '\r\nPlease create the queue(s) or update the rules.'
            );
        }

        return result;
    }

    /**
     * needEmail determines if the given queue desires an email
     * when assigned a case.
     * 
     * @param queue - Queue being assigned to case
     * @return true if an email needs to be created and sent
     */
    @testVisible
    private Boolean needEmail(Group queue) {
        return (!String.isBlank(queue.Email) || queue.DoesSendEmailToMembers);
    }   
    
    /**
     * createEmail creates a simple template email to send
     * to the given queue.
     * 
     * @param c - Case working on
     * @param queue - Queue being assigned to case
     * @return Messaging.SingleEmailMessage
     */
    @testVisible
    private Messaging.SingleEmailMessage createEmail(Case c, Group queue) {
        Set<String> listTo = new Set<String>(); 
        List<String> listCc = new List<String>();
        Id idTarget = queue.Id; 
        Id idWhat = c.Id;
        
        if (String.isBlank(queue.Email)) {
            listTo.add(queue.Email);
        }
        if (queue.DoesSendEmailToMembers){
            // TODO: listTo.addAll( Get the emails of the members );
        }

        return buildEmail(new List<String>(listTo), listCc, idTemplate, idTarget, idWhat);
    }

    /**
     * buildEmail builds a simple template email.
     * 
     * @param listTo - list of To addresses
     * @param template - the email template
     * @param idTarget - the main object for the template
     * @param idWhat - if idTarget is a contact, then this is an additional template object
     * @return Messaging.SingleEmailMessage
     */
    @testVisible
    private Messaging.SingleEmailMessage buildEmail(List<String> listTo, List<String> listCc, Id templateId, Id idTarget, Id idWhat) {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        
        email.setToAddresses(listTo);
        email.setCcAddresses(listCc);
        email.setTemplateId(templateId);
        email.setTargetObjectId(idTarget);
        email.setWhatId(idWhat);
        
        return email;
    } 
    
    /**
     * getRecordTypeNames retrieves the RecordType names related to the given
     * list of cases.
     * @param cases - list of cases to get RecordTypes for
     * @returns A Map relating RecordType Ids to RecordType Names
     */
    private static Map<Id, String> getRecordTypeNames(List<Case> cases) {
        Map<Id, String> result = new Map<Id, String>();
        Map<Id, Schema.RecordTypeInfo> mapCaseRecordTypes = schema.SObjectType.Case.getRecordTypeInfosById();
        
        for (Case c : cases) {
            Schema.RecordTypeInfo rtInfo = mapCaseRecordTypes.get(c.RecordTypeId);
            result.put(rtInfo.getRecordTypeId(), rtInfo.getName());
        }
        
        return result;
    }
    
    /**
     * DEBUG METHOD
     * logMatchOfRules runs through the given list of rules and
     * logs all matched rules.  Use in Debug - Open Execute Anonymous Window
     * on a Case Id to see the rules it would have matched.
     * 
     * @param  logLevel - the logging level to use
     * @param  caseId - Id of a Case
     * @param  onlyMatching - Only log matching rules
     */
    static public void logMatchOfRules(LoggingLevel logLevel, Id caseId, Boolean onlyMatching) {
        Case c = [SELECT Id, RecordType.Name, Type, Type__c, Sub_Type__c, Primary_Product__c, Scope__c, Account.RecordType.Name
                  FROM Case
                  WHERE Id = :caseId];
        logMatchOfRules(logLevel, c.RecordType.Name, c.Type, c.Type__c, c.Sub_Type__c, c.Primary_Product__c, c.Scope__c, c.Account.RecordType.Name, onlyMatching);
    }
    
    /**
     * DEBUG METHOD
     * logMatchOfRules runs through the given list of rules and
     * logs all matched rules.  Use in Debug - Open Execute Anonymous Window
     * on a Case Id to see the rules it would have matched.
     * 
     * @param  logLevel - the logging level to use
     * @param  caseRecordType - Record Type of the Case
     * @param  caseCategory - Category of the Case (Type)
     * @param  caseType - Type of the Case (Type__c)
     * @param  caseSubType - Sub-Type of the Case (Sub_Type__c) 
     * @param  casePrimaryApplication - Primary Application of the Case (Primary_Product__c)
     * @param  caseScope - Scope of the Case (Scope__c)
     * @param  caseAccountRecordType - Record Type of the Account related to the Case
     * @param  onlyMatching - Only log matching rules
     */
     static public void logMatchOfRules(LoggingLevel logLevel, 
                                        String caseRecordType, 
                                        String caseCategory,  
                                        String caseType,  
                                        String caseSubType, 
                                        String casePrimaryApplication,  
                                        String caseScope,  
                                        String caseAccountRecordType, 
                                        Boolean onlyMatching) {
        System.debug(logLevel, 'CaseAssignment_Test.logAllMatchingRules');    
        System.debug(logLevel, '- Looking for:');
        System.debug(logLevel, '|   Account Record Type: ' + caseAccountRecordType);
        System.debug(logLevel, '|   Case Record Type:    ' + caseRecordType);
        System.debug(logLevel, '|   Category:            ' + caseCategory);
        System.debug(logLevel, '|   Type:                ' + caseType);
        System.debug(logLevel, '|   Sub Type:            ' + caseSubType);
        System.debug(logLevel, '|   Primary Application: ' + casePrimaryApplication);
        System.debug(logLevel, '|   Scope:               ' + caseScope);
                                                
        Case_Assignment ca = new Case_Assignment();
                                                
        for (Case_Assignment_Rule__mdt rule : readRules()) {
            if (ca.checkRuleMatch(rule, caseRecordType, caseCategory, caseType, caseSubType, casePrimaryApplication, caseScope, caseAccountRecordType)) {
                System.debug(logLevel, '! MATCH: Rule: Label: ' + rule.Label + '  Order: ' + rule.Order__c + '  Queue: ' + rule.Queue__c + '  Severity: ' + rule.Severity__c);
                System.debug(logLevel, '|   Account Record Type: ' + rule.Account_Record_Type__c);
                System.debug(logLevel, '|   Case Record Type:    ' + rule.Case_Record_Type__c);
                System.debug(logLevel, '|   Category:            ' + rule.Category__c);
                System.debug(logLevel, '|   Type:                ' + rule.Type__c);
                System.debug(logLevel, '|   Sub Type:            ' + rule.Sub_Type__c);
                System.debug(logLevel, '|   Primary Application: ' + rule.Primary_Application__c); 
                System.debug(logLevel, '|   Scope__c:            ' + rule.Scope__c);
            }
            else {
                if (!onlyMatching) {
                    System.debug(logLevel, '! NO MATCH: Rule: Label: ' + rule.Label + '  Order: ' + rule.Order__c + '  Queue: ' + rule.Queue__c + '  Severity: ' + rule.Severity__c);                System.debug(logLevel, '! MATCH: Rule: Label: ' + rule.Label + '  Order: ' + rule.Order__c + '  Queue: ' + rule.Queue__c + '  Severity: ' + rule.Severity__c);
                    System.debug(logLevel, '|   Account Record Type: ' + rule.Account_Record_Type__c);
                    System.debug(logLevel, '|   Case Record Type:    ' + rule.Case_Record_Type__c);
                    System.debug(logLevel, '|   Category:            ' + rule.Category__c);
                    System.debug(logLevel, '|   Type:                ' + rule.Type__c);
                    System.debug(logLevel, '|   Sub Type:            ' + rule.Sub_Type__c);
                    System.debug(logLevel, '|   Primary Application: ' + rule.Primary_Application__c); 
                    System.debug(logLevel, '|   Scope__c:            ' + rule.Scope__c);
                }
            }
        }
    }

    @TestVisible
    private static void emailAdministrators(String subject, String message) {
        System.debug(LoggingLevel.ERROR, subject + ' : ' + message);

        List<String> toAddresses = new List<String>(); 
        for (User u : [SELECT Id, Email FROM User WHERE Profile.Name = 'System Administrator']) {
            toAddresses.add(u.Email);
        }

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
        mail.setToAddresses(toAddresses); 
        mail.setSenderDisplayName('Salesforce'); 
        mail.subject = subject;
        mail.plainTextBody = message;

        if (!Test.isRunningTest()) {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });  
        }
    }

}