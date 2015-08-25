/**********************************************************************************************
* @author       Slalom
* @date         2014
*
* @version      1.1
*
* @description  Called from Task Trigger to handle trigger logic
*
* @revision     Yefim Shuster on 2015-07-30 - added handle() and moved all processing from Trigger into handle() - new version is 1.1
**********************************************************************************************/
public class TaskTriggerHandler {
    public static void updateTaskDueDate(List<Task> taskList){
        Set<Id> relatedRecordIds = new Set<Id>();
        Set<Id> allRelatedRecordIds = new Set<Id>();
        Set<Id> workItemIds = new Set<Id>();
        Map<Id,Id> relatedRecordWorkItemMap = new Map<Id,Id>();
        Map<Id,Case> workItemMap = new Map<Id,Case>();
        Map<Id,List<Task>> workitemTaskMap = new Map<Id,List<Task>>();
        List<Case> workitemsForUpdate = new List<Case>();
        // Collect Related Records
        for(Task t : taskList){
            relatedRecordIds.add(t.WhatId);
        }
        // Query Related Records and get Work Item Ids
        List<Related_Records__c> relatedRecords = [select Id, SFDC_Work_Item__c from Related_Records__c where Id IN: relatedRecordIds];
        // Collect Work Item Ids
        for(Related_Records__c rr : relatedRecords){
            workItemIds.add(rr.SFDC_Work_Item__c);
        }
        // Query All Related Records related to the Work Items
        List<Related_Records__c> allRelatedRecords = [select Id, SFDC_Work_Item__c from Related_Records__c where SFDC_Work_Item__c IN: workItemIds];
        for(Related_Records__c rr : allRelatedRecords){
            relatedRecordWorkItemMap.put(rr.Id, rr.SFDC_Work_Item__c);
            allRelatedRecordIds.add(rr.Id);
        }
        // Query Work Item Records
        List<Case> workItems = [Select Id, Task_Due_Date__c from Case where Id IN: workItemIds];
        for(Case c : workItems){
            workItemMap.put(c.Id, c);
        }
        List<Task> tasks = new List<Task>();
        tasks = [select Id, ActivityDate, WhatId from Task where WhatId IN: allRelatedRecordIds and ActivityDate >= today and Status != 'Completed'];
        for(Task t : tasks){
            if(relatedRecordWorkItemMap.containsKey(t.WhatId)){
                Id workItemId = relatedRecordWorkItemMap.get(t.WhatId);
                if(workitemTaskMap.containsKey(workItemId)){
                    List<Task> temp = workitemTaskMap.get(workItemId);
                    temp.add(t);
                    workitemTaskMap.put(workItemId, temp);
                }
                else{
                    workitemTaskMap.put(workItemId, new List<Task> {t});
                }
            }
        }
        for(Id i : workItemMap.keySet()){
            if(workitemTaskMap.get(i) == null){
                Case tempCase = workItemMap.get(i);
            	tempCase.Task_Due_Date__c = null;
                workitemsForUpdate.add(tempCase);
            }
        }
        for(Id i : workitemTaskMap.keySet()){
        	List<Task> tempTaskList = workitemTaskMap.get(i); 
            system.debug('***tempTaskList : ' + tempTaskList.size());
			Case tempCase = workItemMap.get(i);
            if(tempTaskList.size() > 0){
                Date soonestDate = tempTaskList[0].ActivityDate;
                Integer soonest = date.today().daysBetween(soonestDate);
                for(Task t : tempTaskList){
                    if(date.today().daysBetween(t.ActivityDate) < soonest){
                        soonestDate = t.ActivityDate;
                        soonest = date.today().daysBetween(soonestDate);
                    }
                }
                tempCase.Task_Due_Date__c = soonestDate;
            }
            workitemsForUpdate.add(tempCase);
        }
        if(workitemsForUpdate.size() > 0){
           update workitemsForUpdate;
        }
    }
    
    /*************************************************************************
    * @author         Yefim Shuster
    * @date           07/30/2015
    *
    * @version      1.1
    *
    * @description    This method is called from Task Trigger and handle all trigger processing
    * @parameters    newTaskList - Trigger.new
    *                newTaskMap - Trigger.newMap
    *                oldTaskList - Trigger.old
    *                oldTaskMap - Trigger.oldMap
    *                isBefore - Trigger.isBefore
    *                isUpdate - Trigger.isUpdate
    *                isInsert - Trigger.isInsert
    *                isDelete - Trigger.isDelete
    **************************************************************************/
    public static void handle(List<Task> newTaskList,
                              Map<Id, Task> newTaskMap,
                              List<Task> oldTaskList,
                              Map<Id, Task> oldTaskMap,
                              Boolean isBefore,
                              Boolean isUpdate,
                              Boolean isInsert,
                              Boolean isDelete){

      try {
      	Id SysAdminProfileId = WorkItemAssignmentUtility.getSysAdminProfileId(); // Only sys admin will delete 
        Diags.Enter('TaskTriggerHandler.handle():IsBefore=' + isBefore + ':IsUpdate=' + isUpdate + ':IsInsert=' + IsInsert + 
          ':isDelete=' + isDelete + ' - newTaskList size = ' + (newTaskList == null ? 0 : newTaskList.size()) +
          ' - oldTaskList size = ' + (oldTaskList == null ? 0 : oldTaskList.size()));
        
        if ((isBefore && isUpdate) || (!isBefore && isInsert)){
          WorkItemRollupSummary.recalculateFUREmailsSentCount(newTaskMap, oldTaskMap, isBefore, isInsert, isUpdate, isDelete);
        }
        
        if(!isBefore){
            
            if(isInsert){
                TaskTriggerHandler.updateTaskDueDate(newTaskList);
            }
            
            if(isUpdate){
                List<Task> taskList = new List<Task>();
                
                for(Task t : newTaskList){
                    if((t.Status =='Completed' && oldTaskMap.get(t.Id).Status != 'Completed') || t.ActivityDate != oldTaskMap.get(t.Id).ActivityDate){
                        taskList.add(t);
                    }
                }
                if(taskList.size() > 0){
                    TaskTriggerHandler.updateTaskDueDate(taskList);
                }
            }
        }
         
		if(isBefore && isDelete){
			// On Update of Record
			for(Task t : oldTaskList){
				if(UserInfo.getProfileId() != SysAdminProfileId){
					//t.addError('Tasks are not allow to be deleted!');
                    t.addError('This item cannot be deleted.');
				}
			}
        }
        
        Diags.Save();
        Diags.Clear();
     }
     catch(Exception e){
       System.debug('***Error in TaskTriggerHandler.handle(): ' + e.getMessage());
       Diags.SaveException(e);
       Diags.ClearAll();
       throw e;
     }                       
   }
}