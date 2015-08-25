@isTest
public class TestYefim {

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

       System.debug('In setup() after insert usrList');

    }
  
  static testMethod void validateCustomSetting() {
      
      Map<String, UserSkillRulesAndCaseMap__c> usrMap = UserSkillRulesAndCaseMap__c.getAll();
      
      System.debug('In validateCustomSetting() after UserSkillRulesAndCaseMap__c.getAll()');
      
      System.debug('usrMap.size() = ' + usrMap.size());
      
  }
}