/**

 */
@isTest
private class TestTaskTriggerHandler {
	static testMethod void validateTaskTrigger() {
         /************************************************************************
         *  Creating following test data 
         *   - Related Records
         * 	 - Work Items
         *   - Tasks
         ***********************************************************************/
        //Work Items
        Case c = new Case(Task_Due_Date__c = null ) ; Insert c;
        
        //Related Records
        Related_Records__c r = new Related_Records__c(SFDC_Work_Item__c = c.Id, ID__c = '1234567890') ; insert r;             
        system.assertEquals(r.SFDC_Work_Item__c, c.Id);
        //Task
        Task t = new Task(WhatId=r.Id, ActivityDate = date.today() + 1, Status = 'In Progress') ; insert t;
        Task t1 = new Task(WhatId=r.Id, ActivityDate = date.today() + 2, Status = 'In Progress') ; insert t1;
        Task t2 = new Task(WhatId=r.Id, ActivityDate = date.today() + 3, Status = 'In Progress') ; insert t2;
        Task t3 = new Task(WhatId=r.Id, ActivityDate = date.today(), Status = 'In Progress') ; insert t3;
        c = [select Task_Due_Date__c from Case where Id =: c.Id ];
        //Test that the trigger correctly updated the Task Due Date with the Activity Date
        System.assertEquals(c.Task_Due_Date__c, t3.ActivityDate) ;
        
        t3.Status = 'Completed';
        update t3;
        
        c = [select Task_Due_Date__c from Case where Id =: c.Id ];
        //Test that the trigger correctly updated the Task Due Date with the Activity Date
        System.assertEquals(t.ActivityDate, c.Task_Due_Date__c);
		
        t.Status = 'Completed'; update t;
        t1.Status = 'Completed'; update t1;
        t2.Status = 'Completed'; update t2;
        
        c = [select Task_Due_Date__c from Case where Id =: c.Id ];
        //Test that the trigger correctly updated the Task Due Date with the Activity Date
        System.assertEquals(null, c.Task_Due_Date__c);
        
        Task t4 = new Task(WhatId=r.Id, ActivityDate = date.newInstance(2014,100,30), Status = 'In Progress') ; insert t4;
	}
}