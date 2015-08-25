/**********************************************************************************************
* @author       Janella Espiritu
* @date         06/22/2015
* @description  This is the trigger for the Shift Times Change object
* @version      1.1
* @revision(s)  
**********************************************************************************************/
trigger ShiftTimesChangeTrigger on Shift_Time_Change__c (after insert,after update,after delete) {
    ShiftTimesChangeTriggerHandler.handle(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap, Trigger.isBefore, Trigger.isUpdate, Trigger.isInsert, Trigger.isDelete);
}