/**********************************************************************************************
* @author       Janella Espiritu
* @date         08/26/2014
* @description  This trigger runs on the Case object and calls CaseTriggerHandler to run all
*               processes
*
* @version      1.5
*
* @revision(s)  Janella Espiritu 09102014 R1S2 : Ability to Group Work Items
*               Janella Espiritu 09102014 R1S2 : Ability to Assign DA Cases
*               Janella Espiritu 09102014 R1S2 : Retrieve related work Items on Assignment
*               Yefim Shuster on 2015-02-04 - Defect 134 - call updateWorkItemAssignment Before Insert for Recreated WI
*               Yefim Shuster on 2015-02-04 - Defect 135 - call createStatusTimes After Insert for Recreated WI
*               Yefim Shuster on 2015-02-19 - PCR 140278 - MBT Reassignment - call groupWorkItems() AFTER UPDATE when Owner changed
*                                  from MBT Queue to Billing Exceptions queue or from ANY to Duplicate Exceptions queue
*               Yefim Shuster on 2015-04-20 - R2 - added Diagnostics - new version is 1.3
*               Yefim Shuster on 2015-06-25 - R2 - refactor CaseTrigger - move all processing into CaseTriggerHandler - new version is 1.5
**********************************************************************************************/
trigger CaseTrigger on Case (before insert, after insert, before update, after update, after delete) {
    
    // Modified by YXS7 on 2015-06-25 - R2 - refactor CaseTrigger - move all processing into CaseTriggerHandler - added below - new version is 1.5
    CaseTriggerHandler.handle(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap, Trigger.isBefore, Trigger.isUpdate, Trigger.isInsert, Trigger.isDelete);
}