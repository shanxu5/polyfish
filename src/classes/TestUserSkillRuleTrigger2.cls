/**********************************************************************************************
* @author       Yefim Shuster
* @date         2015-08-14
*
* @version      1.0
*
* @description  This test class tests User Skill Rule trigger and its 
*               exception handler catch block
*
* @revision(s)  
**********************************************************************************************/
@isTest
public class TestUserSkillRuleTrigger2 {

  private class MyException extends Exception {}
  
  /**********************************************************************************************
    * @author       Yefim Shuster
    * @date         08/14/2015
    * @description  This is Test Setup method that will create test data used in this test class
    * @version      1.0
    * @revision(s)  
    **********************************************************************************************/
    @testSetup static void setup() {
       // empty Test Setup method will cause UserSkillRuleTriggerHandler.isDuplicateRecord() to throw QueryException exception
       //because UserSkillRulesAndCaseMap__c Custom Settings will remain empty
    }
  
  static testMethod void validateExceptionHandler() {
      List<User_Skill_Rule__c> newr = new List<User_Skill_Rule__c>();
      
      User_Skill_Rule__c r = new User_Skill_Rule__c(Name = 'DA CCA',
            Work_Item_Type__c = 'BSEG;Delayed Bills;PSSTL;QAS8;Retro Commencing',
            DA_CCA_Indicator__c = 'True');
      newr.clear();
      newr.add(r);
      
      try {
        insert newr;
      
        throw new MyException('If this exception is thrown, then UserSkillRuleTriggerHandler.isDuplicateRecord() did not throw an exception');
      }
      catch(Exception e) {
        Boolean expectedExceptionThrown = (e.getMessage().contains('System.QueryException: unexpected token: \',\'') ? true : false);

        System.AssertEquals(expectedExceptionThrown, true);
      }
  }
}