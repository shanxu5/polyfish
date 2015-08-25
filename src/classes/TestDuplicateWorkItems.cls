/**********************************************************************************************
* @author       Melody Yang
* @date         June 2015
* @version      1.0
* @description  This test class tests DuplicateWorkItems
* @revision(s)  Original
**********************************************************************************************/
@isTest
public class TestDuplicateWorkItems {
    
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
        
        //create queues needed
        String billingExceptionsQueueId   = WorkItemAssignmentUtility.getBillingExceptionQueueId();
        String duplicateExceptionsQueueId = workItemAssignmentUtility.getDuplicateExceptionQueueId();
        String bsegMBTQueueId = WorkItemAssignmentUtility.getMBTQueueId();
        
        System.runAs(admin){
            Id recordtypeId = [select Id from RecordType where Name='Billing Exceptions' and sObjectType = 'Case'].Id;	
            //create account
            Account acct = TestUtility.createAccount(date.today()-60, 'Account1', '0123456789');
            insert acct;
            //create SA
            List<Service_Agreement__c> saList = new List<Service_Agreement__c>();
            Service_Agreement__c Sa1  = TestUtility.createServiceAgreementwithSAType(acct.Id, 'E-RES', '0000000001');  saList.add(Sa1);
            Service_Agreement__c Sa2  = TestUtility.createServiceAgreementwithSAType(acct.Id, 'E-RES', '0000000002');  saList.add(Sa2);
            Service_Agreement__c Sa3  = TestUtility.createServiceAgreementwithSAType(acct.Id, 'E-RES', '0000000003');  saList.add(Sa3);
            Service_Agreement__c Sa4  = TestUtility.createServiceAgreementwithSAType(acct.Id, 'E-RES', '0000000004');  saList.add(Sa4);
            Service_Agreement__c Sa5  = TestUtility.createServiceAgreementwithSAType(acct.Id, 'E-RES', '0000000005');  saList.add(Sa5);
            Service_Agreement__c Sa6  = TestUtility.createServiceAgreementwithSAType(acct.Id, 'E-RES', '0000000006');  saList.add(Sa6);
            Service_Agreement__c Sa7  = TestUtility.createServiceAgreementwithSAType(acct.Id, 'E-RES', '0000000007');  saList.add(Sa7);
            Service_Agreement__c Sa8  = TestUtility.createServiceAgreementwithSAType(acct.Id, 'E-RES', '0000000008');  saList.add(Sa8);
            Service_Agreement__c Sa9  = TestUtility.createServiceAgreementwithSAType(acct.Id, 'E-RES', '0000000009');  saList.add(Sa9);
            Service_Agreement__c Sa10  = TestUtility.createServiceAgreementwithSAType(acct.Id, 'E-RES', '0000000010');  saList.add(Sa10);
            Service_Agreement__c Sa11  = TestUtility.createServiceAgreementwithSAType(acct.Id, 'E-RES', '0000000011');  saList.add(Sa11);
            Service_Agreement__c Sa12  = TestUtility.createServiceAgreementwithSAType(acct.Id, 'E-RES', '0000000012');  saList.add(Sa12);
            Service_Agreement__c Sa13  = TestUtility.createServiceAgreementwithSAType(acct.Id, 'E-RES', '0000000013');  saList.add(Sa13);
            insert saList;
            //create Premise
            Premise__c prem = TestUtility.createPremise();
            insert prem;
            //create SP
            Service_Point__c sp = TestUtility.createServicePoint(prem.Id);
            insert sp;
                        
            //create Grouping Class
            List <Grouping_Class__c> gcList = new List<Grouping_Class__c>();
            Grouping_Class__c VeeGC = TestUtility.populateGroupingClass('Interval');gcList.add(VeeGC);
            Grouping_Class__c BsegGC = TestUtility.populateGroupingClass('Billing 101');gcList.add(BsegGC);
            Grouping_Class__c DbGC = TestUtility.populateGroupingClass('Billing 101');gcList.add(DbGC);
            insert gcList;           
            
            //create Grouping Rules
            List <Grouping_Rules__c> grList = new List<Grouping_Rules__c>();
            Grouping_Rules__c IntGR = TestUtility.populateGroupingRules(3, 'Specialized Interval', 'Hierarchy', VeeGC.Id, 'AccountId');
            grList.add(IntGR);
            Grouping_Rules__c BillingGR = TestUtility.populateGroupingRules(6, 'Billing 101', 'Priority', null, 'AccountId');
            grList.add(BillingGR);
            insert grList;
            
            //create Related Class
            List<Related_Class__c> rcList = new List<Related_Class__c>();
            Related_Class__c IntRC1 = TestUtility.relatedClass(veeGC.Id, IntGR.Id); rcList.add(IntRC1);
            Related_Class__c IntRC2 = TestUtility.relatedClass(bsegGC.Id, IntGR.Id); rcList.add(IntRC2);
            Related_Class__c IntRC3 = TestUtility.relatedClass(dbGC.Id, IntGR.Id); rcList.add(IntRC3);
            insert rcList;
            
            //create GroupingType Custom Setting
            List<GroupingTypes__c> gtList = new List<GroupingTypes__c>();
            GroupingTypes__c hierarchy = TestUtility.createGroupingTypes('Hierarchy','HierarchyImpl');
            gtList.add(hierarchy);
            GroupingTypes__c priority = TestUtility.createGroupingTypes('Priority','PriorityImpl');
            gtList.add(priority);
            insert gtList;
            
            //create USR records
            List<User_Skill_Rule__c> usrList = new List<User_Skill_Rule__c>();
            //TestUtility.createUserSkillRule(sortOrder, workItemType, metered, interval, saType, daCCA, msgCategory, msgNumber, maxBilling, DaysLateEvaluator, AgeBucket, CommencingBill, SAStatus, Classc)
            User_Skill_Rule__c VeeUSR   = TestUtility.createUserSkillRule(1, 'VEE', null, null, null, null, null, null, null, null, null, null, null, VeeGC.Id); 
            VeeUSR.Name = 'Vee USR'; VeeUSR.GroupingEnabled__c=TRUE;  usrList.add(VeeUSR);
            User_Skill_Rule__c BsegUSR     = TestUtility.createUserSkillRule(2, 'BSEG', null, null, 'E-RES', null, null, null, null, null, null, null, null, BsegGC.Id);
            BsegUSR.Name = 'BSEG USR'; BsegUSR.GroupingEnabled__c=TRUE;  usrList.add(BsegUSR); 
            User_Skill_Rule__c DbUSR     = TestUtility.createUserSkillRule(3, 'Delayed Bills', null, null, 'E-RES', null, '00003', '24164', null, null, null, null, null, DbGC.Id); 
            DbUSR.Name = 'Db USR'; DbUSR.GroupingEnabled__c=TRUE;  usrList.add(DbUSR);
            insert usrList;
            
            //override default query b/c owner.type = null in test class
            DuplicateWorkItems.QueryString = 'Select Id, AccountId, Work_Item_Type__c, SFDC_SA_ID__c, Duplicate_Vee_Indicator__c, OwnerId, Status from Case where SFDC_SA_ID__c IN: saIds and Work_Item_Type__c IN (\'VEE\', \'BSEG\', \'Delayed Bills\') and Status IN (\'Unassigned\',\'Assigned\', \'Being Worked On\', \'Pending\', \'Unavailable\') and OwnerId !=:duplicateExceptionsQueueId';
            
            //CreateWorkItem(String smSpStatus,String workItemType,String saStatus,Date eventDate,String msgNumber, String msgCategoryNumber, Id accountId, Id serviceAgreementId, Boolean DACCAIndicator, Id premiseId, Id servicePointId, Id ownerId, Id recordTypeId)
            List <Case> existingWI = new List<Case>();
            //Sa1 - any BSEG
            Case bseg1 = TestUtility.CreateWorkItem('30', 'BSEG', 'Active', date.today()-60, '', '', acct.Id, Sa1.Id, False, prem.Id, sp.Id, billingExceptionsQueueId, recordTypeId); existingWI.add(bseg1);
            //Sa2 - any DB
            Case db2= TestUtility.CreateWorkItem('30', 'Delayed Bills', 'Active', date.today()-200, '', '', acct.Id, Sa2.Id, False, prem.Id, sp.Id, billingExceptionsQueueId, recordTypeId); existingWI.add(db2);
            //Sa3 - VEE BWO - CSR
            Case vee3 = TestUtility.CreateWorkItem('30', 'VEE', 'Active', date.today()-30, '', '', acct.Id, Sa3.Id, False, prem.Id, sp.Id, CSR.Id, recordTypeId); existingWI.add(vee3);
            //Sa4 - VEE assigned - CSR
            Case vee4 = TestUtility.CreateWorkItem('30', 'VEE', 'Active', date.today()-30, '', '', acct.Id, Sa4.Id, False, prem.Id, sp.Id, CSR.Id, recordTypeId); existingWI.add(vee4);
            //Sa5 - VEE unassigned
            Case vee5 = TestUtility.CreateWorkItem('30', 'VEE', 'Active', date.today()-30, '', '', acct.Id, Sa5.Id, False, prem.Id, sp.Id, billingExceptionsQueueId, recordTypeId); existingWI.add(vee5);
            //Sa6 - VEE pending - CSR
            Case vee6 = TestUtility.CreateWorkItem('30', 'VEE', 'Active', date.today()-30, '', '', acct.Id, Sa6.Id, False, prem.Id, sp.Id, CSR.Id, recordTypeId); existingWI.add(vee6);
            //Sa7 - VEE assigned - CSR
            Case vee7 = TestUtility.CreateWorkItem('30', 'VEE', 'Active', date.today()-30, '', '', acct.Id, Sa7.Id, False, prem.Id, sp.Id, CSR.Id, recordTypeId); existingWI.add(vee7);
            //SA8 - VEE Unassigned
            Case vee8 = TestUtility.CreateWorkItem('30', 'VEE', 'Active', date.today()-30, '', '', acct.Id, Sa8.Id, False, prem.Id, sp.Id, billingExceptionsQueueId, recordTypeId); existingWI.add(vee8);
            //SA9 - BSEG iMacro
            Case bseg9 = TestUtility.CreateWorkItem('30', 'BSEG', 'Active', date.today()-60, '', '', acct.Id, Sa9.Id, False, prem.Id, sp.Id, bsegMBTQueueId, recordTypeId); existingWI.add(bseg9);
            //SA10 - BSEG Pending - CSR
            Case bseg10 = TestUtility.CreateWorkItem('30', 'BSEG', 'Active', date.today()-60, '', '', acct.Id, Sa10.Id, False, prem.Id, sp.Id, CSR.id, recordTypeId); existingWI.add(bseg10);
            //SA11 - BSEG unassigned
            Case bseg11 = TestUtility.CreateWorkItem('30', 'BSEG', 'Active', date.today()-60, '', '', acct.Id, Sa11.Id, False, prem.Id, sp.Id, billingExceptionsQueueId, recordTypeId); existingWI.add(bseg11);
            //SA12 - BSEG assigned - CSR
            Case bseg12 = TestUtility.CreateWorkItem('30', 'BSEG', 'Active', date.today()-60, '', '', acct.Id, Sa12.Id, False, prem.Id, sp.Id, billingExceptionsQueueId, recordTypeId); existingWI.add(bseg12);
            //SA13 - DB any 
         	Case db13= TestUtility.CreateWorkItem('30', 'Delayed Bills', 'Active', date.today()-200, '', '', acct.Id, Sa13.Id, False, prem.Id, sp.Id, billingExceptionsQueueId, recordTypeId); existingWI.add(db13);
            insert existingWI;
            
			List<Case> updateStatus = new List<Case>();
            vee3.Status = 'Being Worked On'; updateStatus.add(vee3);
            vee4.Status = 'Assigned'; updateStatus.add(vee4);
            vee6.Status = 'Unavailable'; updateStatus.add(vee6);
            vee7.Status = 'Assigned'; updateStatus.add(vee7);
            bseg10.Status = 'Pending'; updateStatus.add(bseg10);
            bseg12.Status = 'Assigned';updateStatus.add(bseg12);
            update updateStatus;
        }
    }
        
    static testMethod void TestDuplicateWorkItems() {
        //users
        User tAdmin = [Select Id from User where lan_ID__c = 'ADM1'];
        System.assert(tAdmin != null);
        User tCSR = [Select Id from User where lan_ID__c = 'USR2'];
        System.assert(tCSR != null);
        
        //account
        Account tAcct = [select Id from Account where Name = 'Account1' ];
        
        //SA
        Service_Agreement__c tSa1  = [select Id from Service_Agreement__c where SA_ID__c = '0000000001'];
        Service_Agreement__c tSa2  = [select Id from Service_Agreement__c where SA_ID__c = '0000000002'];
        Service_Agreement__c tSa3  = [select Id from Service_Agreement__c where SA_ID__c = '0000000003'];
        Service_Agreement__c tSa4  = [select Id from Service_Agreement__c where SA_ID__c = '0000000004'];
        Service_Agreement__c tSa5  = [select Id from Service_Agreement__c where SA_ID__c = '0000000005'];
        Service_Agreement__c tSa6  = [select Id from Service_Agreement__c where SA_ID__c = '0000000006'];
        Service_Agreement__c tSa7  = [select Id from Service_Agreement__c where SA_ID__c = '0000000007'];
        Service_Agreement__c tSa8  = [select Id from Service_Agreement__c where SA_ID__c = '0000000008'];
        Service_Agreement__c tSa9  = [select Id from Service_Agreement__c where SA_ID__c = '0000000009'];
        Service_Agreement__c tSa10  = [select Id from Service_Agreement__c where SA_ID__c = '0000000010'];
        Service_Agreement__c tSa11  = [select Id from Service_Agreement__c where SA_ID__c = '0000000011'];
        Service_Agreement__c tSa12  = [select Id from Service_Agreement__c where SA_ID__c = '0000000012'];
        Service_Agreement__c tSa13  = [select Id from Service_Agreement__c where SA_ID__c = '0000000013'];
        //prem
        Premise__c tPrem = [select Id from Premise__c where Prem_Id__c = '0013026269'];
        //SP
        Service_Point__c tSP = [select Id from Service_Point__c where Service_Point__c.Name = '7705725181'];
        //create billingExceptions queue
        String billingExceptionsQueueId   = WorkItemAssignmentUtility.getBillingExceptionQueueId();
        String duplicateExceptionsQueueId = workItemAssignmentUtility.getDuplicateExceptionQueueId();
        String bsegMBTQueueId = WorkItemAssignmentUtility.getMBTQueueId();
        Id recordtypeId = [select Id from RecordType where Name='Billing Exceptions' and sObjectType = 'Case'].Id;	
            	
        //insert new work items to trigger CaseTriggerHandler - duplicateWorkItems
            List<Case> wiList = new List<Case>();
            //SA1 - VEE
            Case vee1 = TestUtility.CreateWorkItem('10', 'VEE', 'Active', date.today()-30, '', '', tAcct.Id, tSa1.Id, False, tPrem.Id, tSP.Id, billingExceptionsQueueId, recordTypeId); wiList.add(vee1);
            //SA2 - VEE
            Case vee2 = TestUtility.CreateWorkItem('10', 'VEE', 'Active', date.today()-30, '', '', tAcct.Id, tSa2.Id, False, tPrem.Id, tSP.Id, billingExceptionsQueueId, recordTypeId); wiList.add(vee2); 
            //SA3 - BSEG
            Case bseg3 = TestUtility.CreateWorkItem('30', 'BSEG', 'Active', date.today()-60, '', '', tAcct.Id, tSa3.Id, False, tPrem.Id, tSP.Id, billingExceptionsQueueId, recordTypeId); wiList.add(bseg3);
            //SA4 - BSEG
            Case bseg4 = TestUtility.CreateWorkItem('30', 'BSEG', 'Active', date.today()-60, '', '', tAcct.Id, tSa4.Id, False, tPrem.Id, tSP.Id, billingExceptionsQueueId, recordTypeId); wiList.add(bseg4);
            //SA5 - BSEG
            Case bseg5 = TestUtility.CreateWorkItem('30', 'BSEG', 'Active', date.today()-60, '', '', tAcct.Id, tSa5.Id, False, tPrem.Id, tSP.Id, billingExceptionsQueueId, recordTypeId); wiList.add(bseg5);
            //SA6 - DB
            Case Db6 = TestUtility.CreateWorkItem('30', 'Delayed Bills', 'Active', date.today()-90, '', '', tAcct.Id, tSa6.Id, False, tPrem.Id, tSP.Id, billingExceptionsQueueId, recordTypeId); wiList.add(Db6);
            //SA7 - DB
            Case Db7 = TestUtility.CreateWorkItem('30', 'Delayed Bills', 'Active', date.today()-90, '', '', tAcct.Id, tSa7.Id, False, tPrem.Id, tSP.Id, billingExceptionsQueueId, recordTypeId); wiList.add(Db7);
            //SA8 - DB
            Case Db8 = TestUtility.CreateWorkItem('30', 'Delayed Bills', 'Active', date.today()-90, '', '', tAcct.Id, tSa8.Id, False, tPrem.Id, tSP.Id, billingExceptionsQueueId, recordTypeId); wiList.add(Db8);
            //SA9 - DB
            Case Db9 = TestUtility.CreateWorkItem('30', 'Delayed Bills', 'Active', date.today()-90, '', '', tAcct.Id, tSa9.Id, False, tPrem.Id, tSP.Id, billingExceptionsQueueId, recordTypeId); wiList.add(Db9);
            //SA10 - DB
            Case Db10 = TestUtility.CreateWorkItem('30', 'Delayed Bills', 'Active', date.today()-90, '', '', tAcct.Id, tSa10.Id, False, tPrem.Id, tSP.Id, billingExceptionsQueueId, recordTypeId); wiList.add(Db10);
            //SA11 - DB
            Case Db11 = TestUtility.CreateWorkItem('30', 'Delayed Bills', 'Active', date.today()-90, '', '', tAcct.Id, tSa11.Id, False, tPrem.Id, tSP.Id, billingExceptionsQueueId, recordTypeId); wiList.add(Db11);
            //SA12 - DB
            Case Db12 = TestUtility.CreateWorkItem('30', 'Delayed Bills', 'Active', date.today()-90, '', '', tAcct.Id, tSa12.Id, False, tPrem.Id, tSP.Id, billingExceptionsQueueId, recordTypeId); wiList.add(Db12);
            //SA13 - BSEG
            Case bseg13 = TestUtility.CreateWorkItem('30', 'BSEG', 'Active', date.today()-60, '', '', tAcct.Id, tSa13.Id, False, tPrem.Id, tSP.Id, billingExceptionsQueueId, recordTypeId); wiList.add(bseg13);
        
        System.runAs(tAdmin){  
            Test.startTest();
            //override default query b/c owner.type = null in test class
            DuplicateWorkItems.QueryString = 'Select Id, AccountId, Work_Item_Type__c, SFDC_SA_ID__c, Duplicate_Vee_Indicator__c, OwnerId, Status from Case where SFDC_SA_ID__c IN: saIds and Work_Item_Type__c IN (\'VEE\', \'BSEG\', \'Delayed Bills\') and Status IN (\'Unassigned\',\'Assigned\', \'Being Worked On\', \'Pending\', \'Unavailable\') and OwnerId !=:duplicateExceptionsQueueId';
            insert wilist;
            Test.stopTest();
            
            //check that OwnerIds are assigned correctly
            Case vee4 = [select Id, OwnerId from Case where SFDC_SA_ID__c =: tSa4.Id and Work_Item_Type__c = 'VEE'];
            Case vee5 = [select Id, OwnerId from Case where SFDC_SA_ID__c =: tSa5.Id and Work_Item_Type__c = 'VEE'];
            Case vee7 = [select Id, OwnerId from Case where SFDC_SA_ID__c =: tSa7.Id and Work_Item_Type__c = 'VEE'];
            Case vee8 = [select Id, OwnerId from Case where SFDC_SA_ID__c =: tSa8.Id and Work_Item_Type__c = 'VEE'];
            Case bseg11 = [select Id, OwnerId from Case where SFDC_SA_ID__c =: tSa11.Id and Work_Item_Type__c = 'BSEG'];
            Case bseg12 = [select Id, OwnerId from Case where SFDC_SA_ID__c =: tSa12.Id and Work_Item_Type__c = 'BSEG'];
            Case db13 = [select Id, Exception_Message_Text__c, Message_Category_Number__c, Message_Number__c from Case where SFDC_SA_ID__c =: tSa13.Id and Work_Item_Type__c = 'Delayed Bills'];
            
            for (Case c : [select Id, OwnerId, Duplicate_Vee_Indicator__c from Case]){
                if (c.Id == vee1.Id || c.Id == vee2.Id | c.Id == vee4.Id || c.Id == vee5.Id || c.Id == vee7.Id || c.Id == vee8.Id 
                    || c.Id == bseg11.Id || c.Id == bseg12.Id ||c.Id == bseg13.Id){
                    System.assertEquals(duplicateExceptionsQueueId, c.OwnerId);
                }
                if (c.Id == bseg3.Id || c.Id == db6.Id || c.Id == db10.Id){
                    System.assertEquals(tCSR.Id, c.OwnerId);
                }
                if (c.Id == bseg3.Id || c.Id == bseg4.Id || c.Id == bseg5.Id || c.Id == db6.Id || c.Id == db7.Id || c.Id == db8.Id){
                    System.assertEquals(TRUE, c.Duplicate_Vee_Indicator__c);
                }
                if (c.Id == bseg4.Id || c.Id == db8.Id || c.Id == db9.Id || c.Id == db11.Id){
                    System.assertNotEquals(duplicateExceptionsQueueId, c.OwnerId);
                }
            }
        }
    }
}