/**********************************************************************************************
* @author       Yefim Shuster
* @date         12/22/2014
* @description  This Apex Web Service will serve as a Integration Batch Job Dispatcher
**********************************************************************************************/
global class IntegrationJointJobsDispatcher {
   /**********************************************************************************************
   * @author       Yefim Shuster
   * @date         12/30/2014
   * @description  startIntegrationBatchJob will be called from command-line Java client; it will
   *                  determine if a Batch Job jobName can be started and then start the job
   * @return       The list of return codes:
   *                 0 - There are no records found in Integration_Joint__c, and thus no work to do
   *                 1 - There are records found in Integration_Joint__c, and there are Batch Jobs
   *                       already in progress - jobName was not started
   *                 2 - There are records found in Integration_Joint__c, and jobName was started
   *                 3 - jobName is not defined as Apex Batchable class
   **********************************************************************************************/
   webService static Integer startIntegrationBatchJob(String jobName, Integer batchSize){
       Integer iRet = 0;
       
       Integration_Joint__c ij = null;
       try {
         ij = [select Id from Integration_Joint__c where isDeleted = false limit 1];
       }
       catch (System.QueryException e){}
       
       if (ij == null || ij.Id == null) {
          return iRet;
       }  
       
       // Are there any Apex jobs in progress?
       Set<String> activejobstates = new Set<String>{'Queued','Processing','Preparing'};
       Set<String> scheduledjobs = new Set<String>{'ScheduleUserSkillRulesReassignment', 'ScheduleSendSLANotification', 'ScheduleSendCustomerContact'};
       AsyncApexJob aaj = null;
       try {
          aaj = [Select Id from AsyncApexJob where Status in :activejobstates and ApexClass.Name not in :scheduledjobs limit 1];
       }
       catch (System.QueryException e){}
       
       if (aaj != null && aaj.Id != null) {
          iRet = 1;
          return iRet;
       }
       
       // Ready to start jobName
       Type t = Type.forName(jobName);
       if (t != null){
          Database.Batchable<sObject> job = (Database.Batchable<sObject>)t.newInstance();
          if (job != null){
              Database.executeBatch(job, batchSize);
              iRet = 2;
          }
           else {
               iRet = 3;
           }
       }
       else {
          iRet = 3;
       }
       
       return iRet;
   }
}