@isTest
public class TestScheduleSendCustomerContact {
	 // CRON expression: midnight on March 15.
   // Because this is a test, job executes
   // immediately after Test.stopTest().
   public static String CRON_EXP = '0 0 0 15 3 ? 2022';

   static testmethod void test() {
      Test.startTest();
       
      User_Skill_Rule__c usr = TestUtility.createUserSkillRule(1, 'PSSTL', null, null, null, null, null, null, null, 'less than or equal', 1, null, null);
      User_Skill_Rule__c usr2 = TestUtility.createUserSkillRule(1, 'PSSTL', null, null, null, null, null, null, null, 'greater than', 1, null, null);
	  Case wi = new Case();
      wi.Work_Item_Type__c = 'PSSTL';
      wi.Event_Date__c = date.today() + 1;
      insert wi;
      // Validate that the User Skill Rule is correct
      system.assertEquals(usr.Id, [select User_Skill_Rule__c from Case where Id =: wi.Id].User_Skill_Rule__c);
       
      wi.Event_Date__c = date.today() - 3;
      update wi;
      // Validate that the User Skill Rule is still the same
      system.assertEquals(usr.Id, [select User_Skill_Rule__c from Case where Id =: wi.Id].User_Skill_Rule__c);
      // Validate that the Age is 2
      system.assertEquals(3, [select Age__c from Case where Id =: wi.Id].Age__c);
      // Schedule the test job
      String jobId = System.schedule('ScheduleApexClassTest',
                        CRON_EXP, 
                        new ScheduleSendCustomerContact());
         
      // Get the information from the CronTrigger API object
      CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
         NextFireTime
         FROM CronTrigger WHERE id = :jobId];

      // Verify the expressions are the same
      System.assertEquals(CRON_EXP, 
         ct.CronExpression);

      // Verify the job has not run
      System.assertEquals(0, ct.TimesTriggered);

      // Verify the next time the job will run
      System.assertEquals('2022-03-15 00:00:00', 
         String.valueOf(ct.NextFireTime));
      // Verify the scheduled job hasn't run yet.
      system.assertEquals(usr.Id, [select User_Skill_Rule__c from Case where Id =: wi.Id].User_Skill_Rule__c);
      Test.stopTest();

      // Now that the scheduled job has executed after Test.stopTest(),
      //   fetch the new merchandise that got added.
     system.assertEquals(usr2.Id, [select User_Skill_Rule__c from Case where Id =: wi.Id].User_Skill_Rule__c);

   }
}