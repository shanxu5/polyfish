trigger TaskTrigger on Task (before insert, before update, before delete, after insert, after update) {
	TaskTriggerHandler.handle(Trigger.new,
                              Trigger.newMap,
                              Trigger.old,
                              Trigger.oldMap,
                              Trigger.isBefore,
                              Trigger.isUpdate,
                              Trigger.isInsert,
                              Trigger.isDelete);
}