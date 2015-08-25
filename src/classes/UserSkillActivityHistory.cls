/**********************************************************************************************
* @author       Bhargavi
* @date         06/16/2015
* @description  User Skill Trigger handler class for history tracking
**********************************************************************************************/
public class UserSkillActivityHistory{
    public static void createHistoryTracking(List<User_Skill__c> userSkills, String operation){
        System.debug('Inside History Handler----->');
        List<User_Skill_History__c> skillHistories = new List<User_Skill_History__c>();
        User_Skill_History__c skillHistory;
        for(User_Skill__c userSkill:userSkills){
            System.debug('userSkill---->'+userSkill);
            skillHistory = new User_Skill_History__c ();
            skillHistory.Logged_in_User__c = UserInfo.getUserId() ;
            skillHistory.Modified_Date__c = System.Now() ;
            skillHistory.Operation__c = operation ;
            skillHistory.User_Skill_Rule__c = userSkill.User_Skill_Rule__c ;
            skillHistory.Work_Item_Assignment__c = userSkill.Work_Item_Assignment__c ;
            System.debug('skillHistory---->'+skillHistory);
            skillHistories.add(skillHistory);
        }
        insert skillHistories;
    }

}