public class ActivityTriggerHandler {
    
    /*************************************************************************
    * @author         Joe Kowalsky
    * @date           08/04/2015
    * @description    This method is called from WebformMasterRequestTrigger and handles all trigger processing
    * @parameters     newUSList - Trigger.new
    *                 newUSMap - Trigger.newMap
    *                 oldUSList - Trigger.old
    *                 oldUSMap - Trigger.oldMap
    *                 isBefore - Trigger.isBefore
    *                 isUpdate - Trigger.isUpdate
    *                 isInsert - Trigger.isInsert
    **************************************************************************/
    public static void handle(List<Task> newTaskList,
                              Map<Id, Task> newTaskMap,
                              List<Task> oldTaskList,
                              Map<Id, Task> oldTaskMap,
                              Boolean isBefore,
                              Boolean isUpdate,
                              Boolean isInsert){
                         
      try 
      {
        Id SysAdminProfileId = WorkItemAssignmentUtility.getSysAdminProfileId(); // Only sys admin will delete 
        Diags.Enter('ActivityTriggerHandler.handle():isInsert=|IsBefore=' + isInsert + '||' + isBefore + ':IsUpdate=' + isUpdate + ' - newUSList size = ' + (newTaskList == null ? 0 : newTaskList.size()));
    	// After DML
        if(isBefore){
            // On Update of Record
            if(!isUpdate && !isInsert){
                // Check if any Webform Requests need to be removed
                for(Task t : oldTaskList){
                  system.debug(logginglevel.info,'%%%%%%%%%%% what is the user profile%%%%%%%%%...'+ UserInfo.getProfileId());
                    if(UserInfo.getProfileId() != SysAdminProfileId){
                        t.addError('Tasks are not allow to be deleted!');
                    }
                }

            }
        }
        Diags.Save();
        Diags.Clear();
      }
      catch(Exception e){
        System.debug('***Error in ActivityTriggerHandler.handle(): ' + e.getMessage());
        Diags.SaveException(e);
        Diags.ClearAll();
        throw e;
      }                    
    }
}