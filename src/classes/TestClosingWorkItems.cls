/**********************************************************************************************
* @author       Melody Yang
* @date         August 2015
* @version      1.0
* @description  This test class tests ValidationUtility's ValidateClosedStatus and ValidateBillingExceptionsWI 
* @revision(s)  Original
**********************************************************************************************/
@isTest
public class TestClosingWorkItems {
    @testSetup static void setup() {
        //static testMethod void TestClosingWorkItems() {
    //create test user to create data
        Profile pfAdmin = [select Id from profile where Name = 'Administrator'];
        UserRole rAdmin = [select Id from userrole where Name = 'Billing Operations'];
        User admin = TestUtility.createUser(pfAdmin.Id, rAdmin.Id, 1); 
    	admin.lan_ID__c = 'ADM1';
        insert admin;
        
        Profile p = [select id from profile where name = 'CSR'];
        UserRole r = [Select id from userrole where name = 'CSR'];
        User CSR = TestUtility.createUser(p.id, r.id, 2); CSR.Lan_ID__c = 'USR2';
        insert CSR;
        
        //create billingExceptions queue
        Id billingExceptionsQueueId = WorkItemAssignmentUtility.getBillingExceptionQueueId();
        Id bsegMBTQueueId = WorkItemAssignmentUtility.getMBTQueueId();
        
        System.runAs(admin){
            Id recordtypeId = [select Id from RecordType where Name='Billing Exceptions' and sObjectType = 'Case'].Id;  
            
            //create account
            List<Account> acctList = new List<Account>();
            Account acct1 = TestUtility.createAccount(date.today()-60, 'Account1', '0123456789'); acctList.add(acct1);
            insert acctList;
            
            //create SA
            Service_Agreement__c sa = TestUtility.createServiceAgreementwithSAType(acct1.Id, 'E-RES', '0000000001');
            insert sa;
            
            //create Premise
            Premise__c prem = TestUtility.createPremise();
            insert prem;
            
            //create SP
            Service_Point__c sp = TestUtility.createServicePoint(prem.Id);
            insert sp;
            
            //create Grouping Class
            Grouping_Class__c BillingGC = TestUtility.populateGroupingClass('Billing101');
            insert BillingGC;           
           
            //create Grouping Rules
            Grouping_Rules__c BillingGR = TestUtility.populateGroupingRules(1, 'Billing101', 'Priority', null, 'AccountId');
            insert BillingGR;
            
            //create Related Class
            Related_Class__c BillingRC = TestUtility.relatedClass(BillingGC.Id, BillingGR.Id);
            insert BillingRC;
            
            //create GroupingType Custom Setting
            List<GroupingTypes__c> gtList = new List<GroupingTypes__c>();
            GroupingTypes__c hierarchy = TestUtility.createGroupingTypes('Hierarchy','HierarchyImpl');
            gtList.add(hierarchy);
            GroupingTypes__c priority = TestUtility.createGroupingTypes('Priority','PriorityImpl');
            gtList.add(priority);
            insert gtList;
            
            User_Skill_Rule__c IntUSR     = TestUtility.createUserSkillRule(3, 'BSEG', null, 'TRUE', null, null, null, null, null, null, null, null, null, BillingGC.Id); 
        	IntUSR.Name = 'Fast/Slow Meter Adj - Gas'; IntUSR.GroupingEnabled__c=TRUE;
        	IntUSR.AssignmentEnabled__c = true;
        	insert IntUSR;
        
            Case WorkItemCompleted = TestUtility.CreateWorkItem('40', 'PSSTL', 'Pending Start', null, '24164', '90000', acct1.Id, sa.Id, true, prem.Id, sp.Id, CSR.Id, recordtypeId); 
        	insert WorkItemCompleted;
        	WorkItemCompleted.Create_Customer_Contact_in_CC_B__c = false;
        	WorkItemCompleted.Status = 'Completed';
        	WorkItemCompleted.Sub_Status__c = 'Completed by Assigned User';
        	WorkItemCompleted.Root_Cause_Category__c = 'DA/CCA';
        	WorkItemCompleted.Root_Cause__c = 'Switch Request';
            WorkItemCompleted.SOX_Required_Information__c = 'Service Agreement ID';
            WorkItemCompleted.CC_Service_Agreement_ID__c = '0987654321';
			update WorkItemCompleted;
                        
            Case query1 = [select Status, isClosed from Case where SMSPST__c = '40'];
            system.assertEquals('Completed', query1.Status);
            system.assertEquals(true, query1.isClosed);
            
            Case WorkItemCanceled = TestUtility.CreateWorkItem('30', 'PSSTL', 'Pending Start', null, '24164', '90000', acct1.Id, sa.Id, true, prem.Id, sp.Id, CSR.Id, recordtypeId); 
        	insert WorkItemCanceled;
        	WorkItemCanceled.Create_Customer_Contact_in_CC_B__c = false;
        	WorkItemCanceled.Status = 'Canceled';
        	WorkItemCanceled.Sub_Status__c = 'Manually Created In Error';
			update WorkItemCanceled;
            
            Case query2 = [select Status, isClosed from Case where SMSPST__c = '30'];
            system.assertEquals('Canceled', query2.Status);
            system.assertEquals(true, query2.isClosed);
            
            Case WorkItemBE = TestUtility.CreateWorkItem('20', 'PSSTL', 'Pending Start', null, '24164', '90000', acct1.Id, sa.Id, true, prem.Id, sp.Id, billingExceptionsQueueId, recordtypeId); 
        	insert WorkItemBE;
        	WorkItemBE.Status = 'Being Worked On';
			update WorkItemBE;
            
            Case query3 = [select Status, OwnerId, isClosed from Case where SMSPST__c = '20'];
            system.assertEquals('Being Worked On', query3.Status);
            system.assertEquals(false, query3.isClosed);
            system.assertEquals(billingExceptionsQueueId, query3.OwnerId);
            
        }
    }
    
 static testMethod void TestClosingWorkItems() {
     
        //users
        User tAdmin = [Select Id from User where lan_ID__c = 'ADM1'];
        System.assert(tAdmin != null);
        User tCSR = [Select Id from User where lan_ID__c = 'USR2'];
        System.assert(tCSR != null);
        
        //account
        Account tAcct1 = [select Id from Account where Name = 'Account1'];
        
        //SA
        Service_Agreement__c tSa  = [select Id from Service_Agreement__c where SA_ID__c = '0000000001'];
        
        //create billingExceptions queue
        String billingExceptionsQueueId   = WorkItemAssignmentUtility.getBillingExceptionQueueId();
        String bsegMBTQueueId = WorkItemAssignmentUtility.getMBTQueueId();
        Id recordtypeId = [select Id from RecordType where Name='Billing Exceptions' and sObjectType = 'Case'].Id;	   
        
        System.runAs(tCSR){ 
            //query for WIs
            Case tWI1 = [select Id, OwnerId, IsParent__c, Message_Category_Number__c, User_Skill_Rule__c from Case where SMSPST__c = '40']; 
            Case tWI2 = [select Id, OwnerId, IsParent__c, Message_Category_Number__c, User_Skill_Rule__c from Case where SMSPST__c = '30'];
            Case tWI3 = [select Id, OwnerId, IsParent__c, Message_Category_Number__c, User_Skill_Rule__c from Case where SMSPST__c = '20'];
                        
            Test.startTest();
            tWI1.Status = 'Completed';
            tWI2.Status = 'Canceled';
            tWI3.Status = 'Completed';
           
            try{
            update tWI1;
            }
            catch(Exception e){
                Boolean expectedExceptionThrown =  e.getMessage().contains(System.Label.Closing_WI_Again) ? true : false;
           		System.AssertEquals(true, expectedExceptionThrown);
            }
            
            try{
            update tWI2;
            }
            catch(Exception e){
                Boolean expectedExceptionThrown =  e.getMessage().contains(System.Label.Closing_WI_Again) ? true : false;
           		System.AssertEquals(true, expectedExceptionThrown);
            }
            
            try{
            update tWI3;
            }
            catch(Exception e){
                Boolean expectedExceptionThrown =  e.getMessage().contains(System.Label.Closing_WI_As_Billing_Exceptions) ? true : false;
           		System.AssertEquals(true, expectedExceptionThrown);
            }
            
            
            Test.stopTest();
        }
 }
    
}