/**********************************************************************************************
* @author       Janella Espiritu
* @date         06/22/2015
* @description  This class holds all the trigger methods for the Shift Times object
* @version      1.0
* @revision(s)  
**********************************************************************************************/
public class ShiftTimesChangeTriggerHandler {
	 /*************************************************************************
    * @author         Janella Espiritu
    * @date           06/22/2015
    * @description    This method is called from WorkItemAssignment Trigger and handles all trigger processing
    * @parameters    newWIAList - Trigger.new
    *                newWIAMap - Trigger.newMap
    *                oldWIAList - Trigger.old
    *                oldWIAMap - Trigger.oldMap
    *                isBefore - Trigger.isBefore
    *                isUpdate - Trigger.isUpdate
    *                isInsert - Trigger.isInsert
    **************************************************************************/
    public static void handle(List<Shift_Time_Change__c> newSTList,
                              Map<Id, Shift_Time_Change__c> newSTMap,
                              List<Shift_Time_Change__c> oldSTList,
                              Map<Id, Shift_Time_Change__c> oldSTMap,
                              Boolean isBefore,
                              Boolean isUpdate,
                              Boolean isInsert,
                              Boolean isDelete){
           
      try {
      
        //Diags.Enter('ShiftTimesChangeTriggerHandler.handle():IsBefore=' + isBefore + ':IsUpdate=' + isUpdate + ' - newWIAList size = ' + newSTList.size());

        // After DML
        if(!isBefore){
            // If trigger is Insert, pass created list to the trigger handler
            if(isInsert){
				// Call method to update all work items affected 
				// by the created shift times
                ShiftTimesUtility.updateBusinessHoursOnCreateOfShiftTimes(newSTList);
            }
            // If trigger is Insert, pass created list to the trigger handler
            if(isUpdate){
                ShiftTimesUtility.updateBusinessHoursOnUpdateOfShiftTimes(newSTList,oldSTMap);
            }
            // If trigger is Insert, pass created list to the trigger handler
            if(isDelete){
               ShiftTimesUtility.updateBusinessHoursOnDeleteOfShiftTimes(oldSTList);
            }
        }
        
        Diags.Save();
        Diags.Clear();
      }
      catch(Exception e){
        System.debug('***Error in ShiftTimesChangeTriggerHandler.handle(): ' + e.getMessage());
        Diags.SaveException(e);
        Diags.ClearAll();
        throw e;
      }                      
    }
}