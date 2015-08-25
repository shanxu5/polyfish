/**********************************************************************************************
* @author       Janella Espiritu
* @date         
* @description  This is the trigger for the Related Records object
* @version      1.0
* @revision(s)  
**********************************************************************************************/
trigger RelatedRecordTrigger on Related_Records__c (before insert, after insert, before update, after update) {
	RelatedRecordTriggerHandler.handle(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap, Trigger.isBefore, Trigger.isUpdate, Trigger.isInsert);
}