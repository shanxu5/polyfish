@isTest
public class TestValidationUtility {
    // Test Validation when Related Record is created
	static testMethod void validateRelatedRecordFields(){
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
        // Create Grouping Class
        Grouping_Class__c IntGC = TestUtility.populateGroupingClass('Interval'); insert IntGC;
        // Create User Skill Rule
        User_Skill_Rule__c IntUSR     = TestUtility.createUserSkillRule(3, 'BSEG', null, 'TRUE', null, null, null, null, null, null, null, null, null, IntGC.Id); 
        IntUSR.Name = 'Fast/Slow Meter Adj - Gas'; IntUSR.GroupingEnabled__c=TRUE;
        IntUSR.AssignmentEnabled__c = true;
        insert IntUSR;
        Case WorkItem = TestUtility.CreateWorkItem('40', 'PSSTL', 'Pending Start', null, '24164', '90000', acc.Id, DASA.Id, true, prem.Id, sp.Id, queueId, recordtypeId); 
        insert WorkItem;
        
        String CCRecordTypeId = Schema.SObjectType.Related_Records__c.getRecordTypeInfosByName().get('Customer Contact').getRecordTypeId();
        CustomerContactType__c cct = TestUtility.createCustContTypeCustSetting('Billing Inquiry Code', 'BILLING', true, true, true); insert cct;
        Related_Records__c rr = new Related_Records__c();
        rr.RR_Customer_Contact_Class__c = 'Billing Inquiry Code';
        rr.RR_Customer_Contact_Type__c = 'Billing Inquiry Code';
        rr.RecordTypeId = CCRecordTypeId;
        rr.CC_Person_ID__c = '1234567890';
        rr.SFDC_Work_Item__c = WorkItem.Id;
        try{
            insert rr;
        }
        catch(Exception e){
           Boolean expectedExceptionThrown =  e.getMessage().contains(System.Label.CCType_Validation_Error_Message) ? true : false;
           System.AssertEquals(true, expectedExceptionThrown);
        }
    }
    // Test Validation for Customer Contact required fields
    static testMethod void validateCCWorkItemFields(){
        // Query Queue
        Id queueId = WorkItemAssignmentUtility.getBillingExceptionQueueId();
        Id recordtypeId = WorkItemAssignmentUtility.getCaseBillingExceptionsRecordTypeId();
        CustomerContactType__c cct = TestUtility.createCustContTypeCustSetting('Billing Inquiry Code', 'BILLING', true, true, true); insert cct;
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
        // Create Grouping Class
        Grouping_Class__c IntGC = TestUtility.populateGroupingClass('Interval'); insert IntGC;
        // Create User Skill Rule
        User_Skill_Rule__c IntUSR     = TestUtility.createUserSkillRule(3, 'BSEG', null, 'TRUE', null, null, null, null, null, null, null, null, null, IntGC.Id); 
        IntUSR.Name = 'Fast/Slow Meter Adj - Gas'; IntUSR.GroupingEnabled__c=TRUE;
        IntUSR.AssignmentEnabled__c = true;
        insert IntUSR;
        
        Case WorkItem = TestUtility.CreateWorkItem('40', 'PSSTL', 'Pending Start', null, '24164', '90000', acc.Id, DASA.Id, true, prem.Id, sp.Id, queueId, recordtypeId); 
        insert WorkItem;
        WorkItem.Customer_Contact_Class__c = 'Billing Inquiry Code';
        WorkItem.Customer_Contact_Type__c = 'Billing Inquiry Code';
        WorkItem.Status = 'Completed';
        WorkItem.Sub_Status__c = 'Completed by Assigned User';
        WorkItem.Root_Cause_Category__c = 'DA/CCA';
        WorkItem.Root_Cause__c = 'Customer Requested - Rate Change';
        WorkItem.SOX_Required_Information__c = null;
        try{
            update WorkItem;
        }
        catch(Exception e){
           Boolean expectedExceptionThrown =  e.getMessage().contains(System.Label.CCType_Validation_Error_Message) ? true : false;
           System.AssertEquals(true, expectedExceptionThrown);
        }
    }
    // Test Validation when Work Item is closed, Customer_Follow_Up_Required__c is Email
    static testMethod void validateRequiredWorkItemFields(){
        // Query Queue
        Id queueId = WorkItemAssignmentUtility.getBillingExceptionQueueId();
        Id recordtypeId = WorkItemAssignmentUtility.getCaseBillingExceptionsRecordTypeId();
		// Create Custom Setting
		Work_Item_Required_Fields__c requiredFields = TestUtility.createWorkItemRequiredFields('PSSTL'); insert requiredFields;
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
        // Create Grouping Class
        Grouping_Class__c IntGC = TestUtility.populateGroupingClass('Interval'); insert IntGC;
        // Create User Skill Rule
        User_Skill_Rule__c IntUSR     = TestUtility.createUserSkillRule(3, 'BSEG', null, 'TRUE', null, null, null, null, null, null, null, null, null, IntGC.Id); 
        IntUSR.Name = 'Fast/Slow Meter Adj - Gas'; IntUSR.GroupingEnabled__c=TRUE;
        IntUSR.AssignmentEnabled__c = true;
        insert IntUSR;
        Case WorkItem = TestUtility.CreateWorkItem('40', 'PSSTL', 'Pending Start', null, '24164', '90000', acc.Id, DASA.Id, true, prem.Id, sp.Id, queueId, recordtypeId); 
        insert WorkItem;
        WorkItem.Create_Customer_Contact_in_CC_B__c = false;
        WorkItem.Status = 'Completed';
        WorkItem.Sub_Status__c = 'Completed by Assigned User';
        WorkItem.Root_Cause_Category__c = 'DA/CCA';
        WorkItem.Root_Cause__c = 'Customer Requested - Rate Change';
        WorkItem.Customer_Follow_Up_Required__c = 'Email';
        WorkItem.SOX_Required_Information__c = null;
        
        try{
            update WorkItem;
        }
        catch(Exception e){
           	Boolean expectedExceptionThrown =  e.getMessage().contains(System.Label.WIType_Validation_Error_Message) ? true : false;
           	System.AssertEquals(true, expectedExceptionThrown);
        }
    }
    // Test Validation when Work Item is closed, Customer_Follow_Up_Required__c is Letter
    static testMethod void validateRequiredWorkItemFields2(){
        // Query Queue
        Id queueId = WorkItemAssignmentUtility.getBillingExceptionQueueId();
        Id recordtypeId = WorkItemAssignmentUtility.getCaseBillingExceptionsRecordTypeId();
		// Create Custom Setting
		Work_Item_Required_Fields__c requiredFields = TestUtility.createWorkItemRequiredFields('PSSTL'); insert requiredFields;
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
        // Create Grouping Class
        Grouping_Class__c IntGC = TestUtility.populateGroupingClass('Interval'); insert IntGC;
        // Create User Skill Rule
        User_Skill_Rule__c IntUSR     = TestUtility.createUserSkillRule(3, 'BSEG', null, 'TRUE', null, null, null, null, null, null, null, null, null, IntGC.Id); 
        IntUSR.Name = 'Fast/Slow Meter Adj - Gas'; IntUSR.GroupingEnabled__c=TRUE;
        IntUSR.AssignmentEnabled__c = true;
        insert IntUSR;
        Case WorkItem = TestUtility.CreateWorkItem('40', 'PSSTL', 'Pending Start', null, '24164', '90000', acc.Id, DASA.Id, true, prem.Id, sp.Id, queueId, recordtypeId); 
        insert WorkItem;
        WorkItem.Create_Customer_Contact_in_CC_B__c = false;
        WorkItem.Status = 'Completed';
        WorkItem.Sub_Status__c = 'Completed by Assigned User';
        WorkItem.Root_Cause_Category__c = 'DA/CCA';
        WorkItem.Root_Cause__c = 'Customer Requested - Rate Change';
        WorkItem.Customer_Follow_Up_Required__c = 'Letter';
        WorkItem.SOX_Required_Information__c = null;
        
        try{
            update WorkItem;
        }
        catch(Exception e){
           Boolean expectedExceptionThrown =  e.getMessage().contains(System.Label.WIType_Validation_Error_Message) ? true : false;
           System.AssertEquals(true, expectedExceptionThrown);
        }
    }
    // Test Validation when Work Item is closed, Customer_Follow_Up_Required__c is Does Not Apply
    static testMethod void validateRequiredWorkItemFields3(){
        // Query Queue
        Id queueId = WorkItemAssignmentUtility.getBillingExceptionQueueId();
        Id recordtypeId = WorkItemAssignmentUtility.getCaseBillingExceptionsRecordTypeId();
		// Create Custom Setting
		Work_Item_Required_Fields__c requiredFields = TestUtility.createWorkItemRequiredFields('PSSTL'); insert requiredFields;
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
        // Create Grouping Class
        Grouping_Class__c IntGC = TestUtility.populateGroupingClass('Interval'); insert IntGC;
        // Create User Skill Rule
        User_Skill_Rule__c IntUSR     = TestUtility.createUserSkillRule(3, 'BSEG', null, 'TRUE', null, null, null, null, null, null, null, null, null, IntGC.Id); 
        IntUSR.Name = 'Fast/Slow Meter Adj - Gas'; IntUSR.GroupingEnabled__c=TRUE;
        IntUSR.AssignmentEnabled__c = true;
        insert IntUSR;
        Case WorkItem = TestUtility.CreateWorkItem('40', 'PSSTL', 'Pending Start', null, '24164', '90000', acc.Id, DASA.Id, true, prem.Id, sp.Id, queueId, recordtypeId); 
        insert WorkItem;
        WorkItem.Create_Customer_Contact_in_CC_B__c = false;
        WorkItem.Status = 'Completed';
        WorkItem.Sub_Status__c = 'Completed by Assigned User';
        WorkItem.Root_Cause_Category__c = 'DA/CCA';
        WorkItem.Root_Cause__c = 'Customer Requested - Rate Change';
        WorkItem.Customer_Follow_Up_Required__c = 'Does Not Apply';
        WorkItem.SOX_Required_Information__c = null;
        
        try{
            update WorkItem;
        }
        catch(Exception e){
           Boolean expectedExceptionThrown =  e.getMessage().contains(System.Label.WIType_Validation_Error_Message) ? true : false;
           System.AssertEquals(true, expectedExceptionThrown);
        }
    }
    // Test Validation when Work Item is closed, Customer_Follow_Up_Required__c is Phone
    static testMethod void validateRequiredWorkItemFields4(){
        // Query Queue
        Id queueId = WorkItemAssignmentUtility.getBillingExceptionQueueId();
        Id recordtypeId = WorkItemAssignmentUtility.getCaseBillingExceptionsRecordTypeId();
		// Create Custom Setting
		Work_Item_Required_Fields__c requiredFields = TestUtility.createWorkItemRequiredFields('PSSTL'); insert requiredFields;
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
        // Create Grouping Class
        Grouping_Class__c IntGC = TestUtility.populateGroupingClass('Interval'); insert IntGC;
        // Create User Skill Rule
        User_Skill_Rule__c IntUSR     = TestUtility.createUserSkillRule(3, 'BSEG', null, 'TRUE', null, null, null, null, null, null, null, null, null, IntGC.Id); 
        IntUSR.Name = 'Fast/Slow Meter Adj - Gas'; IntUSR.GroupingEnabled__c=TRUE;
        IntUSR.AssignmentEnabled__c = true;
        insert IntUSR;
        Case WorkItem = TestUtility.CreateWorkItem('40', 'PSSTL', 'Pending Start', null, '24164', '90000', acc.Id, DASA.Id, true, prem.Id, sp.Id, queueId, recordtypeId); 
        insert WorkItem;
        WorkItem.Create_Customer_Contact_in_CC_B__c = false;
        WorkItem.Status = 'Completed';
        WorkItem.Sub_Status__c = 'Completed by Assigned User';
        WorkItem.Root_Cause_Category__c = 'DA/CCA';
        WorkItem.Root_Cause__c = 'Customer Requested - Rate Change';
        WorkItem.Customer_Follow_Up_Required__c = 'Phone';
        WorkItem.SOX_Required_Information__c = null;
        
        try{
            update WorkItem;
        }
        catch(Exception e){
           Boolean expectedExceptionThrown =  e.getMessage().contains(System.Label.WIType_Validation_Error_Message) ? true : false;
           System.AssertEquals(true, expectedExceptionThrown);
        }
    }
    // Test Validation when Work Item is closed, Customer_Follow_Up_Required__c is None
    static testMethod void validateRequiredWorkItemFields5(){
        // Query Queue
        Id queueId = WorkItemAssignmentUtility.getBillingExceptionQueueId();
        Id recordtypeId = WorkItemAssignmentUtility.getCaseBillingExceptionsRecordTypeId();
		// Create Custom Setting
		Work_Item_Required_Fields__c requiredFields = TestUtility.createWorkItemRequiredFields('PSSTL'); insert requiredFields;
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
        // Create Grouping Class
        Grouping_Class__c IntGC = TestUtility.populateGroupingClass('Interval'); insert IntGC;
        // Create User Skill Rule
        User_Skill_Rule__c IntUSR     = TestUtility.createUserSkillRule(3, 'BSEG', null, 'TRUE', null, null, null, null, null, null, null, null, null, IntGC.Id); 
        IntUSR.Name = 'Fast/Slow Meter Adj - Gas'; IntUSR.GroupingEnabled__c=TRUE;
        IntUSR.AssignmentEnabled__c = true;
        insert IntUSR;
        Case WorkItem = TestUtility.CreateWorkItem('40', 'PSSTL', 'Pending Start', null, '24164', '90000', acc.Id, DASA.Id, true, prem.Id, sp.Id, queueId, recordtypeId); 
        insert WorkItem;
        WorkItem.Create_Customer_Contact_in_CC_B__c = false;
        WorkItem.Status = 'Completed';
        WorkItem.Sub_Status__c = 'Completed by Assigned User';
        WorkItem.Root_Cause_Category__c = 'DA/CCA';
        WorkItem.Root_Cause__c = 'Customer Requested - Rate Change';
        WorkItem.Customer_Follow_Up_Required__c = 'None';
        WorkItem.SOX_Required_Information__c = null;
        
        try{
            update WorkItem;
        }
        catch(Exception e){
           Boolean expectedExceptionThrown =  e.getMessage().contains(System.Label.WIType_Validation_Error_Message) ? true : false;
           System.AssertEquals(true, expectedExceptionThrown);
        }
    }
}