/**********************************************************************************************
* @author       Yefim Shuster
* @date         2014
*
* @version      1.1
*
* @description  This test class tests User Skill Rule trigger and its 
*               handler class  UserSkillRuleTriggerHandler
*
* @revision(s)  Yefim Shuster on 2015-06-29 - use UserSkillRulesAndCaseMap__c Custom Settings - new version is 1.1
**********************************************************************************************/
@isTest
public class TestUserSkillRuleTrigger {

  private class MyException extends Exception {}
  
  /**********************************************************************************************
    * @author       Yefim Shuster
    * @date         06/29/2015
    * @description  This is Test Setup method that will create test data used in this test class
    * @version      1.0
    * @revision(s)  
    **********************************************************************************************/
    @testSetup static void setup() {
       List<UserSkillRulesAndCaseMap__c> usrList = new List<UserSkillRulesAndCaseMap__c>();
       
       UserSkillRulesAndCaseMap__c cs = TestUtility.userSkillCustomSetting('SA_Type__c', 'validateStringContains', 'SA_Type__c', 'String', 'String');
       usrList.add(cs);
       
       cs = TestUtility.userSkillCustomSetting('Age_Bucket_Start__c', null, 'Age__c', 'Decimal', 'Decimal');
       usrList.add(cs);
       
       cs = TestUtility.userSkillCustomSetting('Age_Bucket_End__c', null, null, 'Decimal', 'Decimal');
       usrList.add(cs);
       
       cs = TestUtility.userSkillCustomSetting('Commencing_Bill__c', 'validateBoolean', 'Commencing_Bill__c', 'String', 'Boolean');
       usrList.add(cs);
       
       cs = TestUtility.userSkillCustomSetting('Days_Late_Age_Evaluator__c', null, null, 'Decimal', null);
       usrList.add(cs);
       
       cs = TestUtility.userSkillCustomSetting('DA_CCA_Indicator__c', 'validateBoolean', 'DA_CCA_IND__c', 'String', 'Boolean');
       usrList.add(cs);
       
       cs = TestUtility.userSkillCustomSetting('Interval__c', 'validateBoolean', 'Interval__c', 'String', 'Boolean');
       usrList.add(cs);
       
       cs = TestUtility.userSkillCustomSetting('Max_Billing_Threshold_MBT__c', 'validateBoolean', 'Max_Billing_Threshold_MBT__c', 'String', 'Boolean');
       usrList.add(cs);
       
       cs = TestUtility.userSkillCustomSetting('Message_Category__c', 'validateEqualStrings', 'Message_Category__c', 'String', 'String');
       usrList.add(cs);
       
       cs = TestUtility.userSkillCustomSetting('Message_Number__c', 'validateEqualStrings', 'Message_Number__c', 'String', 'String');
       usrList.add(cs);
       
       cs = TestUtility.userSkillCustomSetting('Metered__c', 'validateBoolean', 'Metered__c', 'String', 'Boolean');
       usrList.add(cs);
       
       cs = TestUtility.userSkillCustomSetting('Multi_Family__c', 'validateBoolean', 'Multi_Family__c', 'String', 'Boolean');
       usrList.add(cs);
       
       cs = TestUtility.userSkillCustomSetting('SA_Status__c', 'validateStringContains', 'SA_Status__c', 'String', 'String');
       usrList.add(cs);
       
       cs = TestUtility.userSkillCustomSetting('SMSPST__c', 'validateStringContains', 'SMSPST__c', 'String', 'String');
       usrList.add(cs);
       
       cs = TestUtility.userSkillCustomSetting('Work_Item_Type__c', 'validateStringContains', 'Work_Item_Type__c', 'String', 'String');
       usrList.add(cs);
       
			 insert usrList;
    
    }
  
  static testMethod void validateDuplicateUserSkillRuleHandler() {
      List<User_Skill_Rule__c> newr = new List<User_Skill_Rule__c>();
      
      User_Skill_Rule__c r = new User_Skill_Rule__c(Name = 'DA CCA',
            Work_Item_Type__c = 'BSEG;Delayed Bills;PSSTL;QAS8;Retro Commencing',
            DA_CCA_Indicator__c = 'True');
      newr.clear();
      newr.add(r);
      
      insert newr;
      
      List<User_Skill_Rule__c> inserted = [select Name,
                          Commencing_Bill__c,
                          DA_CCA_Indicator__c,
                          Days_Late_Age_Evaluator__c,
                          Interval__c,
                          Max_Billing_Threshold_MBT__c,
                          Message_Category__c,
                          Message_Number__c,
                          Metered__c,
                          SA_Status__c,
                          SA_Type__c,
                          Work_Item_Type__c
                    from User_Skill_Rule__c
                    where Id = :r.Id
                    ];
      
      System.assertEquals(inserted.size(), 1);
      
      r = new User_Skill_Rule__c(Name = 'Dup DA CCA',
            Work_Item_Type__c = 'BSEG;Delayed Bills;PSSTL;QAS8;Retro Commencing',
            DA_CCA_Indicator__c = 'True');
      newr.clear();
      newr.add(r);
      
      try {
        insert newr;
      
        throw new MyException('If this exception is thrown, then duplicate custom field value validation did not work');
      }
      catch(Exception e) {
        Boolean expectedExceptionThrown = (e.getMessage().contains('Duplicate User Skill Rule records exist') ? true : false);

        System.AssertEquals(expectedExceptionThrown, true);
      }

      inserted.clear();
      inserted = [select Name,
                          Commencing_Bill__c,
                          DA_CCA_Indicator__c,
                          Days_Late_Age_Evaluator__c,
                          Interval__c,
                          Max_Billing_Threshold_MBT__c,
                          Message_Category__c,
                          Message_Number__c,
                          Metered__c,
                          SA_Status__c,
                          SA_Type__c,
                          Work_Item_Type__c
                    from User_Skill_Rule__c
                    where Id = :r.Id
                    ];
      
      System.assertEquals(inserted.size(), 0);
                          
      r = new User_Skill_Rule__c(Name = 'DA CCA',
            Work_Item_Type__c = 'Delayed Bills;PSSTL;QAS8;Retro Commencing',
            DA_CCA_Indicator__c = 'True');
      newr.clear();
      newr.add(r);
      
      try {
        insert newr;
      
        throw new MyException('If this exception is thrown, then duplicate name validation did not work');
      }
      catch(Exception e) {
        Boolean expectedExceptionThrown = (e.getMessage().contains('Duplicate User Skill Rule Name exists. Please enter another name.') ? true : false);

        System.AssertEquals(expectedExceptionThrown, true);
      }
      
      inserted.clear();
      inserted = [select Name,
                          Commencing_Bill__c,
                          DA_CCA_Indicator__c,
                          Days_Late_Age_Evaluator__c,
                          Interval__c,
                          Max_Billing_Threshold_MBT__c,
                          Message_Category__c,
                          Message_Number__c,
                          Metered__c,
                          SA_Status__c,
                          SA_Type__c,
                          Work_Item_Type__c
                    from User_Skill_Rule__c
                    where Id = :r.Id
                    ];
      
      System.assertEquals(inserted.size(), 0);
      
      r = new User_Skill_Rule__c(Name = 'Dup DA CCA',
            Work_Item_Type__c = 'Delayed Bills;PSSTL;QAS8;Retro Commencing',
            DA_CCA_Indicator__c = 'True');
      newr.clear();
      newr.add(r);
      
      insert newr;
      
      inserted.clear();
      inserted = [select Name,
                          Commencing_Bill__c,
                          DA_CCA_Indicator__c,
                          Days_Late_Age_Evaluator__c,
                          Interval__c,
                          Max_Billing_Threshold_MBT__c,
                          Message_Category__c,
                          Message_Number__c,
                          Metered__c,
                          SA_Status__c,
                          SA_Type__c,
                          Work_Item_Type__c
                    from User_Skill_Rule__c
                    where Id = :r.Id
                    ];
      
      System.assertEquals(inserted.size(), 1);
      System.assertEquals(inserted[0].Name, 'Dup DA CCA');
      r.Name = 'DA CCA';
      r.Work_Item_Type__c = 'PSSTL;QAS8;Retro Commencing';
      newr.clear();
      newr.add(r);
      
      try {         
        update newr;
                          
        throw new MyException('If this exception is thrown, then duplicate name validation did not work');
      }
      catch(Exception e) {
        Boolean expectedExceptionThrown = (e.getMessage().contains('Duplicate User Skill Rule Name exists. Please enter another name.') ? true : false);

        System.AssertEquals(expectedExceptionThrown, true);
      }
      
      Grouping_Class__c BillingGC = TestUtility.populateGroupingClass('Billing 101');
            
      insert BillingGC;
            
      r = new User_Skill_Rule__c(Name = 'First Unaged Debt',
            Work_Item_Type__c = 'Unaged Debt',
            Class__c = BillingGC.Id,
            GroupingEnabled__c = true);
      newr.clear();
      newr.add(r);
      
      User_Skill_Rule__c r2 = new User_Skill_Rule__c(Name = 'Second Unaged Debt',
            Work_Item_Type__c = 'Unaged Debt',
            Class__c = BillingGC.Id,
            GroupingEnabled__c = false);
      
      newr.add(r2);
      
      insert newr;
      
      inserted.clear();
      inserted = [select Name,
                          Commencing_Bill__c,
                          DA_CCA_Indicator__c,
                          Days_Late_Age_Evaluator__c,
                          Interval__c,
                          Max_Billing_Threshold_MBT__c,
                          Message_Category__c,
                          Message_Number__c,
                          Metered__c,
                          SA_Status__c,
                          SA_Type__c,
                          Work_Item_Type__c
                    from User_Skill_Rule__c
                    where Id IN (:r.Id, :r2.Id)
                    ];
      
      System.assertEquals(inserted.size(), 2);
      
      r.Name = 'Third Unaged Debt';
      r.GroupingEnabled__c = r2.GroupingEnabled__c;
      newr.clear();
      newr.add(r);
      
      try {         
        update newr;
                          
        throw new MyException('If this exception is thrown, then duplicate name validation did not work');
      }
      catch(Exception e) {
        Boolean expectedExceptionThrown = (e.getMessage().contains('Duplicate User Skill Rule records exist') ? true : false);

        System.AssertEquals(expectedExceptionThrown, true);
      }
      
  }
}