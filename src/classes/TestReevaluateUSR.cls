/**********************************************************************************************
* @author       Melody Yang
* @date         July 2015
* @version      1.0
* @description  This test class tests re-evaluate USR and grouping inside CaseTriggerHandler. 
* @revision(s)  Original
**********************************************************************************************/
@isTest
public class TestReevaluateUSR {
    @testSetup static void setup() {
    //create test user to create data
        Profile pfAdmin = [select Id from profile where Name = 'Administrator'];
        UserRole rAdmin = [select Id from userrole where Name = 'Billing Operations'];
        User admin      = TestUtility.createUser(pfAdmin.Id, rAdmin.Id, 1); admin.lan_ID__c = 'ADM1';
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

            //create USR records
            //TestUtility.createUserSkillRule(sortOrder, workItemType, metered, interval, saType, daCCA, msgCategory, msgNumber, maxBilling, DaysLateEvaluator, AgeBucket, CommencingBill, SAStatus, Classc)
            User_Skill_Rule__c Billing10USR = TestUtility.createUserSkillRule(1, 'BSEG', null, null, 'E-RES', 'FALSE', '', '', null, null, null, null, null, BillingGC.Id); 
            Billing10USR.Name = 'BSEG - Residential 10'; Billing10USR.GroupingEnabled__c=true; Billing10USR.AssignmentEnabled__c = TRUE; 
            Billing10USR.Multi_Family__c = null; Billing10USR.SMSPST__c='10'; Billing10USR.Medical_Allotment__c=null;Billing10USR.Medical_Allotment_Evaluator__c=null;
            insert Billing10USR;
            
            User_Skill_Rule__c Billing30USR = TestUtility.createUserSkillRule(1, 'BSEG', null, null, 'E-RES', 'FALSE', '', '', null, null, null, null, null, BillingGC.Id); 
            Billing30USR.Name = 'BSEG - Residential 30 Category'; Billing30USR.GroupingEnabled__c=true; Billing30USR.AssignmentEnabled__c = TRUE; 
            Billing30USR.Multi_Family__c = null; Billing30USR.SMSPST__c='30'; Billing30USR.Medical_Allotment__c=null;Billing30USR.Medical_Allotment_Evaluator__c=null;
            Billing30USR.Message_Category__c = '00000';
            insert Billing30USR;
            
            User_Skill_Rule__c Billing40USR = TestUtility.createUserSkillRule(1, 'BSEG', null, null, 'E-RES', 'FALSE', '', '', null, null, null, null, null, BillingGC.Id); 
            Billing40USR.Name = 'BSEG - Residential 40 Number'; Billing40USR.GroupingEnabled__c=true; Billing40USR.AssignmentEnabled__c = TRUE; 
            Billing40USR.Multi_Family__c = null; Billing40USR.SMSPST__c='40'; Billing40USR.Medical_Allotment__c=null;Billing40USR.Medical_Allotment_Evaluator__c=null;
            Billing40USR.Message_Number__c = '00000'; 
            insert Billing40USR;
            
            User_Skill_Rule__c mbt30USR = TestUtility.createUserSkillRule(2, 'BSEG', null, null, 'E-RES', 'FALSE', '90000', '24164', null, null, null, null, null, BillingGC.Id); 
            mbt30USR.Name = 'BSEG MBT Elec SM30'; mbt30USR.GroupingEnabled__c=true; mbt30USR.AssignmentEnabled__c = TRUE; 
            mbt30USR.Multi_Family__c = null; mbt30USR.SMSPST__c='30'; mbt30USR.Medical_Allotment__c=null;mbt30USR.Medical_Allotment_Evaluator__c=null;
            insert mbt30USR;
            
            User_Skill_Rule__c mbt40USR = TestUtility.createUserSkillRule(3, 'BSEG', null, null, 'E-RES', 'FALSE', '90000', '24164', null, null, null, null, null, BillingGC.Id); 
            mbt40USR.Name = 'BSEG MBT Elec SM40'; mbt40USR.GroupingEnabled__c=true; mbt40USR.AssignmentEnabled__c = TRUE; 
            mbt40USR.Multi_Family__c = null; mbt40USR.SMSPST__c='40'; mbt40USR.Medical_Allotment__c=null;mbt40USR.Medical_Allotment_Evaluator__c=null;
            insert mbt40USR;
            
            //WIA
            Work_Item_Assignment__c wia = TestUtility.createWorkItemAssignment(CSR.Id, true); insert wia;
            
            //User Skill
           // User_Skill__c us1 = TestUtility.createUserSkill(Billing10USR.Id, wia.Id, wia); insert us1;
            User_Skill__c us2 = TestUtility.createUserSkill(mbt30USR.Id, wia.Id, wia); insert us2;
            
            //create WIs
            //String smSpStatus,String workItemType,String saStatus,Date eventDate,String msgNumber,String msgCategoryNumber,Id accountId,Id serviceAgreementId,Boolean DACCAIndicator,Id premiseId,Id servicePointId,Id ownerId,Id recordTypeId
            List<Case> wiList = new List<Case>();
            Case billing = TestUtility.CreateWorkItem('10', 'BSEG', null, date.today()-300, '', '', acct1.Id, sa.Id, false, prem.Id, sp.Id, billingExceptionsQueueId, recordTypeId);
            wiList.add(billing); 
            Case mbtNum = TestUtility.CreateWorkItem('30', 'BSEG', null, date.today()-300, '24164', '90000', acct1.Id, sa.Id, false, prem.Id, sp.Id, bsegMBTQueueId, recordTypeId);
            wiList.add(mbtNum);
            Case mbtCat = TestUtility.CreateWorkItem('40', 'BSEG', null, date.today()-300, '24164', '90000', acct1.Id, sa.Id, false, prem.Id, sp.Id, bsegMBTQueueId, recordTypeId);
            wiList.add(mbtCat);
            insert wiList;

        }
    }
        
    static testMethod void TestReevaluateUSR() {
     
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
        
        System.runAs(tAdmin){  
            
            //query for USRs
            User_Skill_Rule__c BillingUSR = [select Id from User_Skill_Rule__c where SMSPST__c = '10'];
            User_Skill_Rule__c CatUSR = [select Id from User_Skill_Rule__c where SMSPST__c = '30' and Message_Category__c = '00000'];
            User_Skill_Rule__c NumUSR = [select Id from User_Skill_Rule__c where SMSPST__c = '40' and Message_Number__c = '00000'];
            User_Skill_Rule__c mbt30USR = [select Id from User_Skill_Rule__c where SMSPST__c = '30' and Message_Category__c = '90000'];
            User_Skill_Rule__c mbt40USR = [select Id from User_Skill_Rule__c where SMSPST__c = '40' and Message_Category__c = '90000'];
           
            //query for WIs
            Case tBilling = [select Id, OwnerId, IsParent__c, Message_Category_Number__c, User_Skill_Rule__c from Case where SMSPST__c = '10']; 
            Case tMBT1 = [select Id, OwnerId, IsParent__c, Message_Category_Number__c, User_Skill_Rule__c from Case where SMSPST__c = '30'];
            Case tMBT2 = [select Id, OwnerId, IsParent__c, Message_Category_Number__c, User_Skill_Rule__c from Case where SMSPST__c = '40'];
            
            //check for USR
            system.assertEquals(billingUSR.Id, tBilling.User_Skill_Rule__c);
            system.assertEquals(mbt30USR.Id, tMBT1.User_Skill_Rule__c);
            system.assertEquals(mbt40USR.Id, tMBT2.User_Skill_Rule__c);
            
            Test.startTest();
            //change Error Cat / Number
            List<Case> updateWI = new List<Case>();
            tMBT1.Message_Category_Number__c = '00000'; updateWI.add(tMBT1);  
            tMBT2.Message_Number__c = '00000'; updateWI.add(tMBT2); 
            update updateWI;
            Test.stopTest();
            
            //query for WIs
            Case tMBT1after = [select Id, OwnerId, User_Skill_Rule__c from Case where SMSPST__c = '30' and Message_Category_Number__c = '00000'];
            Case tMBT2after = [select Id, OwnerId, User_Skill_Rule__c from Case where SMSPST__c = '40' and Message_Number__c = '00000'];
            
            //check that USR changed
            system.assertNotEquals(mbt30USR.Id, tMBT1after.User_Skill_Rule__c);
            system.assertNotEquals(mbt40USR.Id, tMBT2after.User_Skill_Rule__c);
            system.assertEquals(CatUSR.Id, tMBT1after.User_Skill_Rule__c);
            system.assertEquals(NumUSR.Id, tMBT2after.User_Skill_Rule__c);
            //check that owner changed
            system.assertNotEquals(bsegMBTQueueId, tMBT1after.OwnerId);
            system.assertNotEquals(bsegMBTQueueId, tMBT2after.OwnerId);
            system.assertEquals(billingExceptionsQueueId, tMBT1after.OwnerId);
            system.assertEquals(billingExceptionsQueueId, tMBT2after.OwnerId);
            
        }
    }
}