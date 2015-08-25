/**********************************************************************************************
* @author       Joe Kowalsky
* @date         08/04/2015
* @description  This trigger runs on the Webform_Master_Request__c object and calls
*               WebformMasterRequestTriggerHandler to run all processes
* @version      1.0
* @revision(s)  
**********************************************************************************************/
trigger WebformMasterRequestTrigger on Webform_Master_Request__c (after update) {

        WebformMasterRequestTriggerHandler.handle(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap, Trigger.isBefore, Trigger.isUpdate, Trigger.isInsert);
}