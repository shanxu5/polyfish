/**********************************************************************************************
* @author       Tae Tran
* @date         07/22/2015
*
* @version      1.0
*
* @description  This batch apex that will run every midnight and will query all CC&B Cases that 
*				are not closed and Case Age Stopped = FALSE. It will check if the current date is 
*				within the business hours. If so, do the following calculations: 
*				Case Age = (business hours diff of Today and Created Date) - Total Days Stopped
*               
* @revision     
*               
**********************************************************************************************/

global class PopulateCaseAgeBatch implements Database.batchable<sObject>
{
	
	global Database.QueryLocator start(Database.BatchableContext BC) //done
    {
		String query = 'SELECT Id, IsClosed, Case_Age__c, CreatedDate, Total_Days_Stopped__c from Case where IsClosed = false and Case_Age_Stopped__c = false';
           
		return Database.getQueryLocator(query);
		
    }
   
    global void execute(Database.BatchableContext BC, List<Case> scope)
    {
       	 BusinessHours bh = [SELECT Id from BusinessHours where name = 'Case Age Business Hours'];
         for(Case c : scope){  
             if (BusinessHours.isWithin(bh.id, System.now())){
                 if(c.CreatedDate != null && c.Total_Days_Stopped__c != null ){
                	Decimal diff_bh = BusinessHours.diff(bh.id, c.CreatedDate, System.now()); 
               	 	Decimal temp = ((((diff_bh / 1000) /60) /60) /24);  
                	c.Case_Age__c = temp.setScale(2) - c.Total_Days_Stopped__c;	
                 }
             }
         }
    }
   
    global void finish(Database.BatchableContext BC)
    {
		// Don't need this part for now
		
    }
   
}