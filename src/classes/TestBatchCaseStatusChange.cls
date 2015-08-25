/**********************************************************************************************
* @author       Melody Yang
* @date         August 2015
* @version      1.0
* @description  This test class tests ValidationUtility's ValidateClosedStatus and ValidateBillingExceptionsWI 
* @revision(s)  Original
**********************************************************************************************/
@isTest
public class TestBatchCaseStatusChange {
    @testSetup static void setup() {
        //static testMethod void TestBatchCaseStatusChange() {
    //create test user to create data
        Profile pfAdmin = [select Id from profile where Name = 'Administrator'];
        UserRole rAdmin = [select Id from userrole where Name = 'Billing Operations'];
        User admin = TestUtility.createUser(pfAdmin.Id, rAdmin.Id, 1); 
    	admin.lan_ID__c = 'ADM1';
        insert admin;
        
        Profile pfCSR1 = [select id from profile where name = 'CSR'];
        UserRole rCSR1 = [Select id from userrole where name = 'CSR'];
        User CSR1 = TestUtility.createUser(pfCSR1.id, rCSR1.id, 2); CSR1.Lan_ID__c = 'USR1';
        insert CSR1;

        List<AuthSession> a =  [select id, UsersId, UserType,SourceIp,SessionType,SessionSecurityLevel,ParentId,LoginType,CreatedDate, NumSecondsValid, LastModifiedDate from AuthSession where ParentId = null and (NOT SessionType LIKE 'Temp%')];
        system.debug('***### authsession seconds valid'+a);
        //system.debug('***### authsession last modified date: '+a.LastModifiedDate);
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
        	
            //work item #1 owned by CSR1 who is not in AuthSession Map
            Case WI1 = TestUtility.CreateWorkItem('20', 'PSSTL', 'Pending Start', null, '24164', '90000', acct1.Id, sa.Id, true, prem.Id, sp.Id, CSR1.Id, recordtypeId); 
        	insert WI1;
        	WI1.Status = 'Being Worked On';
			update WI1;
            
            Case query1 = [select Status, OwnerId, isClosed from Case where SMSPST__c = '20'];
            system.assertEquals('Being Worked On', query1.Status);
            system.assertEquals(false, query1.isClosed);
            system.assertEquals(CSR1.Id, query1.OwnerId);
            
        }
    }
    
 static testMethod void TestBatchCaseStatusChange() {
     
        //users
        User tAdmin = [Select Id from User where lan_ID__c = 'ADM1'];
        System.assert(tAdmin != null);
        User tCSR = [Select Id from User where lan_ID__c = 'USR1'];
        System.assert(tCSR != null);
        
        //account
        Account tAcct1 = [select Id from Account where Name = 'Account1'];
        
        //SA
        Service_Agreement__c tSa  = [select Id from Service_Agreement__c where SA_ID__c = '0000000001'];
        
        //create billingExceptions queue
        String billingExceptionsQueueId   = WorkItemAssignmentUtility.getBillingExceptionQueueId();
        String bsegMBTQueueId = WorkItemAssignmentUtility.getMBTQueueId();
        Id recordtypeId = [select Id from RecordType where Name='Billing Exceptions' and sObjectType = 'Case'].Id;	   
        
        System.runAs(tAdmin){ 
            
            Test.startTest();
            BatchCaseStatusChange csc = new BatchCaseStatusChange(); 
            Database.executeBatch(csc, 200);
            
            ScheduleBatchCaseStatusChange sBatchCaseHalfHr = new ScheduleBatchCaseStatusChange();
			String schHalfHr = '0 30 * * * ?';
			System.schedule('ScheduleBatchCaseStatusChange-testclass', schHalfHr, sBatchCaseHalfHr);

            Test.stopTest();
            
            //query for WIs
            Case tWI1 = [select Id, Status, OwnerId, IsParent__c, Message_Category_Number__c, User_Skill_Rule__c from Case where SMSPST__c = '20'];
            System.assertEquals('Unavailable', tWI1.Status);
        }
 }
    
}