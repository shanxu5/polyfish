/**********************************************************************************************
* @author       Yefim Shuster
* @date         10/19/2014
* 
* @version      1.1
*
* @description  This trigger runs on the User Skill Rule object and calls UserSkillRuleTriggerHandler to run all
*               processes
* @revision     Modified by YXS7 on 2015-06-08 - add exception handling - new version is 1.1
**********************************************************************************************/
trigger UserSkillRuleTrigger on User_Skill_Rule__c (after insert, after update) {
  try {
    if(Trigger.isAfter){
      UserSkillRuleTriggerHandler.isDuplicateRecord(Trigger.new, Trigger.newMap);
      Diags.Save();
    }
  }
  catch(Exception e){
    Diags.SaveException(e);
    Diags.ClearAll();
    throw e;      
  }
}