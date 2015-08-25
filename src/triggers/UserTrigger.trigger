/**********************************************************************************************
* @author       Joe Kowalsky
* @date         06/17/2015
* @description  This trigger runs on the User object and calls UserTriggerHandler to run all
*               processes
*
* @version      1.0
*
* @revision(s)  
*               
**********************************************************************************************/
trigger UserTrigger on User (before update) {
    
    // All processing is handled in UserTriggerHandler
    UserTriggerHandler.handle(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap, Trigger.isBefore, Trigger.isUpdate, Trigger.isInsert, Trigger.isDelete);
    
}