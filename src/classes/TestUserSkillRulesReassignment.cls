@isTest
public class TestUserSkillRulesReassignment {
	static testmethod void test() {
        
        User_Skill_Rule__c usr = TestUtility.createUserSkillRule(1, 'PSSTL', null, null, null, null, null, null, null, 'less than or equal', 1, null, null);
        User_Skill_Rule__c usr2 = TestUtility.createUserSkillRule(1, 'PSSTL', null, null, null, null, null, null, null, 'greater than', 1, null, null);
        
        String CRON_EXP = '0 0 0 15 3 ? 2022';

       List<Case> wiList = new List<Case>();
       for (Integer i=0;i<10;i++) {
           Case wi = new Case();
           wi.Work_Item_Type__c = 'PSSTL';
           wi.Event_Date__c = date.today() + 1;
       	   wiList.add(wi);
       }
       insert wiList;
        for(Case c : wiList){
            c.Event_Date__c = date.today() - 3;
        }
        update wiList;
       Test.startTest();
       UserSKillRulesReassignment usrr = new UserSKillRulesReassignment();
       Database.executeBatch(usrr);
       Test.stopTest();
    }
}