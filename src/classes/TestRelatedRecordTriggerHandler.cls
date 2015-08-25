/**********************************************************************************************
* @author       Janella Espiritu
* @date         05/06/2015
*
* @version      1.0
*
* @description  This test class tests RelatedRecordTrigger and 
						RelatedRecordTriggerHandler
*
* @revision(s)  Original
**********************************************************************************************/
@isTest
private class TestRelatedRecordTriggerHandler {
    /**********************************************************************************************
    * @author       Janella Espiritu
    * @date         07/20/2015
    * @description  This is Test Setup method that will create test data used in this test class
    * @version      1.0
    * @revision(s)  
    **********************************************************************************************/
    @testSetup static void setup() {
        // Query Queue
        Id queueId = WorkItemAssignmentUtility.getBillingExceptionQueueId();
        Id recordtypeId = WorkItemAssignmentUtility.getCaseBillingExceptionsRecordTypeId();
        // Create Account
        Account acc = TestUtility.createAccount(date.today() - 60, 'Account 1', '0007652348'); 
        acc.Postpone_Credit_Date__c = date.today();
        insert acc;
        // Create Service Agreement
        Service_Agreement__c DASA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'HE-RES', '1234567890'); insert DASA;
        // Create Premise
        Premise__c prem = TestUtility.createPremise(); insert prem;
        // Create Service Point
        Service_Point__c sp = TestUtility.createServicePoint(prem.Id); insert sp;
        Case WorkItem = TestUtility.CreateWorkItem('40', 'PSSTL', 'Pending Start', null, '24164', '90000', acc.Id, DASA.Id, true, prem.Id, sp.Id, queueId, recordtypeId); 
        insert WorkItem;
    }
    /**********************************************************************************************
    * @author       Janella Espiritu
    * @date         07/20/2015
    * @description  Validate Required fields on Creation of Customer Contact record
    * @version      1.0
    * @revision(s)  
    **********************************************************************************************/
    static testMethod void validateRelatedRecordFields(){
        
        Case wi = [select Id from Case limit 1];
        String CCRecordTypeId = Schema.SObjectType.Related_Records__c.getRecordTypeInfosByName().get('Customer Contact').getRecordTypeId();
        CustomerContactType__c cct = TestUtility.createCustContTypeCustSetting('Billing Inquiry Code', 'BILLING', true, true, true); insert cct;
        Related_Records__c rr = new Related_Records__c();
        rr.RR_Customer_Contact_Class__c = 'Billing Inquiry Code';
        rr.RR_Customer_Contact_Type__c = 'Billing Inquiry Code';
        rr.RecordTypeId = CCRecordTypeId;
        rr.CC_Person_ID__c = '1234567890';
        rr.SFDC_Work_Item__c = wi.Id;
        Test.startTest();
        try{
            insert rr;
        }
        catch(Exception e){
           Boolean expectedExceptionThrown =  e.getMessage().contains(System.Label.CCType_Validation_Error_Message) ? true : false;
		//System.assertEquals(e.getMessage(), System.Label.CCType_Validation_Error_Message);
           System.AssertEquals(expectedExceptionThrown, true);
        }
        Test.stopTest();
    }
    /**********************************************************************************************
    * @author       Janella Espiritu
    * @date         07/20/2015
    * @description  Test creation of case log upon creation of customer contact
    * @version      1.0
    * @revision(s)  
    **********************************************************************************************/
    static testMethod void testCreateCaseLog(){
        
        Case wi = [select Id from Case limit 1];
        String CCRecordTypeId = Schema.SObjectType.Related_Records__c.getRecordTypeInfosByName().get('Customer Contact').getRecordTypeId();
        Related_Records__c rr = new Related_Records__c();
        rr.RR_Customer_Contact_Class__c = 'Billing Inquiry Code';
        rr.RR_Customer_Contact_Type__c = 'Billing Inquiry Code';
        rr.RecordTypeId = CCRecordTypeId;
        rr.CC_Person_ID__c = '1234567890';
        rr.SFDC_Work_Item__c = wi.Id;
        rr.Additional_Customer_Contact_Log__c = 'Additional Customer Contact Log';
        rr.Comments__c = 'Comments';
        rr.Completion_Comments__c = 'Completion Comments';
        rr.Add_to_CC_B_Case_Log__c = true;
        Test.startTest();
        insert rr;
        Test.stopTest();
        CC_B_Case_Log__c caseLog = [select CC_B_Case_Log_Details__c, Work_Item__c from CC_B_Case_Log__c]; 
        // Validate that it is assigned to the correct Work Item
        system.assertEquals(wi.Id, caseLog.Work_Item__c);
        // Validate that the details contain the Additional Customer Contact Log
        system.assert(caseLog.CC_B_Case_Log_Details__c.contains(rr.Additional_Customer_Contact_Log__c));
        // Validate that the details contain the Comments
        system.assert(caseLog.CC_B_Case_Log_Details__c.contains(rr.Comments__c));
        // Validate that the details contain the Completion Comments
        system.assert(caseLog.CC_B_Case_Log_Details__c.contains(rr.Completion_Comments__c));
    }
}