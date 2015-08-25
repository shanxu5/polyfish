trigger CustomerContactLogTrigger on Customer_Contact_Log__c (before insert, after insert, before update, after update) {
	CustomerContactLogTriggerHandler.handle(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap, Trigger.isBefore, Trigger.isUpdate, Trigger.isInsert);
}