/**********************************************************************************************
* @author       Yefim Shuster
* @date         10/22/2014
* @description  This class is invoked from a schedule and re-assigns aged Work Items to matched User Skill Rules
*               Updated on 2014-11-07 - removed LastModifiedDate <= YESTERDAY query criteria
**********************************************************************************************/
global class UserSkillRulesReassignment implements Database.Batchable<sObject>, Database.Stateful {

    private static Boolean batchRequested = false;
    
    private String emailAddress;
    
    /**********************************************************************************************
    * @author       Yefim Shuster
    * @date         10/22/2014
    * @description  Start is called once per batch to return qualified Work Items
    **********************************************************************************************/
    global Database.QueryLocator Start(Database.BatchableContext bc) {
        
        String query = 'SELECT Id, Work_Item_Type__c, Metered__c, Interval__c, SA_Type__c, SA_Status__c, ' +
            'Commencing_Bill__c, Age__c, Message_Category_Number__c, Message_Number__c, Max_Billing_Threshold_MBT__c, ' +
            'DA_CCA_IND__c, User_Skill_Rule__c, User_Skill_Rule__r.Days_Late_Age_Evaluator__c, ' +
            'User_Skill_Rule__r.Age_Bucket_Start__c, User_Skill_Rule__r.Age_Bucket_End__c ' +
            'FROM Case ' +
            'WHERE User_Skill_Rule__c != null and ' + 
            'isClosed = false and ' +
            'isDeleted = false and ' +
            'User_Skill_Rule__r.Days_Late_Age_Evaluator__c IN (\'less than\', \'less or equal\', \'between\', \'equals\', \'not equal to\')';
        
        /* This query is used for testing only
        String query = 'SELECT Id, Work_Item_Type__c, Metered__c, Interval__c, SA_Type__c, SA_Status__c, ' +
            'Commencing_Bill__c, Age__c, Message_Category_Number__c, Message_Number__c, Max_Billing_Threshold_MBT__c, ' +
            'DA_CCA_IND__c, User_Skill_Rule__c, User_Skill_Rule__r.Days_Late_Age_Evaluator__c, ' +
            'User_Skill_Rule__r.Age_Bucket_Start__c, User_Skill_Rule__r.Age_Bucket_End__c ' +
            'FROM Case ' +
            'WHERE User_Skill_Rule__c != null and ' + 
            'isClosed = false and ' +
            'isDeleted = false and ' +
            'User_Skill_Rule__r.Days_Late_Age_Evaluator__c IN (\'less than\', \'less or equal\', \'between\', \'equals\', \'not equal to\')';
        */
        
        AsyncApexJob a = [SELECT CreatedBy.Email
                          FROM AsyncApexJob WHERE Id = :bc.getJobId()];
        
        emailAddress = a.CreatedBy.Email;
        
        return Database.getQueryLocator(query);
    }
    
    /**********************************************************************************************
    * @author       Yefim Shuster
    * @date         10/22/2014
    * @description  Execute is invoked multiple time in its own context - evaluate if a WI
    *               has aged and needs to be re-assigned to a new User Skill Rule
    **********************************************************************************************/
    global void Execute(Database.BatchableContext bc, List<Case> clist) {
      
      try {
        if (clist == null || clist.size() == 0) return;
        
        List<Case> qcases = new List<Case>();
        
        for (Case c : clist) {
            if ((c.User_Skill_Rule__r.Days_Late_Age_Evaluator__c == 'less than' &&
                c.Age__c >= c.User_Skill_Rule__r.Age_Bucket_Start__c) ||
                (c.User_Skill_Rule__r.Days_Late_Age_Evaluator__c == 'less or equal' &&
                c.Age__c > c.User_Skill_Rule__r.Age_Bucket_Start__c) ||
                (c.User_Skill_Rule__r.Days_Late_Age_Evaluator__c == 'equals' &&
                c.Age__c != c.User_Skill_Rule__r.Age_Bucket_Start__c) ||
                (c.User_Skill_Rule__r.Days_Late_Age_Evaluator__c == 'not equal to' &&
                c.Age__c == c.User_Skill_Rule__r.Age_Bucket_Start__c) ||
                (c.User_Skill_Rule__r.Days_Late_Age_Evaluator__c == 'between' &&
                 !(c.Age__c >= c.User_Skill_Rule__r.Age_Bucket_Start__c && c.Age__c <= c.User_Skill_Rule__r.Age_Bucket_End__c))) {
                qcases.add(c); 
            }
         }
         
         if (qcases.size() == 0) return;
            
         CaseTriggerHandler.populateUserSkillRule(qcases);
            
         List<Case> ucases = new List<Case>();
            
         for (Case q : qcases) {
            ucases.add(new Case(Id = q.Id, User_Skill_Rule__c = q.User_Skill_Rule__c));
         }
            
         if (ucases.size() == 0) return;
            
         Database.SaveResult[] sresults = Database.update(ucases, false); //allOrNothing = false - it is ok if not all are updated successfully
         
         List<DMLError> errs = new List<DMLError>();
         
         for(Database.SaveResult sr : sresults){
            if(!sr.isSuccess()){
              errs.add(new DMLError('UserSkillRulesReassignment', sr.getId(), sr.getErrors()[0].getMessage()));
            }
         }
         
         if (errs.size() > 0) {
           
           // Insert DMLErrors into Error Log Custom Object
           
           // Send an email to Support Team
           Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
           String[] toAddresses = new String[] {emailAddress};
           mail.setToAddresses(toAddresses);
           mail.setSubject('User Skill Rules Reassignment Batch Job Exceptions - Job Id: ' + bc.getJobId());
           mail.setPlainTextBody('User Skill Rules Reassignment Batch job produced exceptions. All exceptions are logged into Error Log.' +
             ' First exception is: ' + errs[0]);
           Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
         }
        
        return;
      }
      catch(Exception e){
        DMLError err = new DMLError('UserSkillRulesReassignment', null, e.getMessage()); 
        
        // Insert DMLErrors into Error Log Custom Object
        
        // Send an email to Support Team
         Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
         String[] toAddresses = new String[] {emailAddress};
         mail.setToAddresses(toAddresses);
         mail.setSubject('User Skill Rules Reassignment Batch Job Exceptions - Job Id: ' + bc.getJobId());
         mail.setPlainTextBody('User Skill Rules Reassignment Batch job produced unexpected exception. All exceptions are logged into Error Log.' +
           ' Exception is: ' + err);
         Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
      }
    }
    
    global void Finish(Database.BatchableContext bc) {
     // Send an email to Support Team
     AsyncApexJob a = [SELECT Status, NumberOfErrors, TotalJobItems
                      FROM AsyncApexJob WHERE Id = :bc.getJobId()];
                      
     Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
     String[] toAddresses = new String[] {emailAddress};
     mail.setToAddresses(toAddresses);
     mail.setSubject('User Skill Rules Reassignment Batch Job Completed - Job Id: ' + bc.getJobId() + ' Status: ' + a.Status);
     String b = 'User Skill Rules Reassignment Batch completed. Any exceptions were logged into Error Log.' + '\r\n\r\n' +
                'The batch Apex job processed ' + a.TotalJobItems +
                ' batches with ' + a.NumberOfErrors + ' failures.';
     mail.setPlainTextBody('User Skill Rules Reassignment Batch completed. Any exceptions were logged into Error Log.');
     Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
    public static void StartBatch() {
        
        if (batchRequested) return;
        
        UserSkillRulesReassignment usrr = new UserSkillRulesReassignment();
        
        Database.executeBatch(usrr, 2000); // 2000 is the max batch size
        
        batchRequested = true;
    }
    
    public class DMLError {
        
        String source;
        String id;
        String errormsg;
        
        public DMLError(String source, String id, String errormsg) {
            this.source = source;
            this.id = id;
            this.errormsg = errormsg;
        }
        
        public override String toString() {
            return 'Error source: ' + this.source + ', Id: ' + this.id + ', Error: ' + this.errormsg;
        }                                          
    }
    
    public class ScheduleHandler implements ScheduleUserSkillRulesReassignment.IScheduleHandler {
        public void execute(SchedulableContext sc) {
            StartBatch();
            //abortJob() removes scheduled job from Schedule - not needed here
            //System.abortJob(sc.getTriggerId());
        }
    }
    
}