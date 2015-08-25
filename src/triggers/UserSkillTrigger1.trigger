trigger UserSkillTrigger1 on User_Skill__c (after insert,after update,after delete) {
if(Trigger.isAfter){
System.debug('Inside History Trigger---->');


 }
}