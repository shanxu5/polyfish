/**********************************************************************************************
* @author       Janella Espiritu
* @date         08/29/2014
* @description  This trigger runs on the User Skill object and calls
*               UserSkillTriggerHandler to run all processes
*
* @version      1.1
*
* @revision(s)  Yefim Shuster on 2015-05-05 - R2 - refactor UserSkillTrigger - move all processing into UserSkillTriggerHandler - new version is 1.1
  @revision     Bharghavi Nekkanti 2015-08-10 User skill history, 
**********************************************************************************************/
trigger UserSkillTrigger on User_Skill__c (after insert,after update,after delete) {

    // Modified by YXS7 on 2015-05-05 - R2 - refactor UserSkillTrigger - move all processing into UserSkillTriggerHandler - added below - new version is 1.1
    UserSkillTriggerHandler.handle(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap, Trigger.isBefore, Trigger.isUpdate, Trigger.isInsert,Trigger.isDelete);
}