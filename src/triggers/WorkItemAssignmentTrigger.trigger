/**********************************************************************************************
* @author       Janella Espiritu
* @date         08/26/2014
* @description  This trigger runs on the Work Item Assignment object and calls
*               WorkItemAssignmentTriggerHandler to run all processes
*
* @version      1.1
*
* @revision(s)  Yefim Shuster on 2015-05-05 - R2 - refactor WorkItemAssignmentTrigger - move all processing into WorkItemAssignmentTriggerHandler - new version is 1.1 
**********************************************************************************************/
trigger WorkItemAssignmentTrigger on Work_Item_Assignment__c (after insert, after update) {

    // Modified by YXS7 on 2015-05-05 - R2 - refactor WorkItemAssignmentTrigger - move all processing into WorkItemAssignmentTriggerHandler - added below - new version is 1.1
    WorkItemAssignmentTriggerHandler.handle(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap, Trigger.isBefore, Trigger.isUpdate, Trigger.isInsert);
}