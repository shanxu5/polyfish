/**********************************************************************************************
* @author       Yefim Shuster
* @date         01/28/2015
* @description  This test class tests SendSLANotification Batch Class
* @revision(s)
**********************************************************************************************/

@isTest
public class TestSendSLANotification {
    static testMethod void testSendNotification() {
        /************************************************************************
         *  Creating following test data as current user 
         *   - User
         *   - User skill rules
         *   - user Skill
         *   - Work Item Assignment
         *   - WorkItem
         ***********************************************************************/
         Test.startTest();
         
         Work_Item_Assignment__c wia;
        Work_Item_Assignment__c wia2;
        
        //User skill rule records
        User_Skill_Rule__c  usr_BSEG_Interval;
        User_Skill_Rule__c  usr_PSSTL_Interval;
  
        
        //User Skill records
        User_Skill__c  userSkill1;
        User_Skill__c  userSkill2;

        Group testGroup;
        QueuesObject testQueue;
        // Query Queue
        Id queueId = [select Id, Name from Group where Name = 'Billing Exceptions' and Type = 'Queue'].Id;
        Id recordtypeId = [select Id from RecordType where Name='Billing Exceptions' and sObjectType = 'Case'].Id;
        Id USRrecordtypeId = [select Id from RecordType where DeveloperName=: 'Billing_Operations_Exceptions' and sObjectType = 'User_Skill_Rule__c'].Id;
        //User to create test data
        Profile padmin = [select id from profile where name='Administrator'];
        UserRole rbillops = [Select id from userrole where name='Billing Operations'];
        User admin= TestUtility.createUser(padmin.id,rbillops.id,1); admin.Lan_ID__c = 'ADM1'; //insert admin;
        
        // Query Profile and User Role
        Profile p = [select id from profile where name='CSR'];
        Profile p2 = [select id from profile where name='SSR'];
        UserRole r = [Select id from userrole where name='CSR'];
        // Create Test User
        List<User> userList = new List<User>();
        User testuser2= TestUtility.createUser(p2.id,r.id, 2); testuser2.Lan_ID__c = 'USR2'; userList.add(testuser2);//insert testuser2;
        User testuser= TestUtility.createUser(p.id,r.id, 3); testuser.Lan_ID__c = 'USR3'; testuser.Supervisor__c = testuser2.Id; userList.add(testuser);//insert testuser;
        insert userList;
        System.runAs(admin){  
            // Create Work Item Assignment record  
            wia = TestUtility.createWorkItemAssignment(testUser.Id, false); insert wia;  
            // Create User Skill Rule
            usr_BSEG_Interval = TestUtility.createUserSkillRule(1, 'BSEG' , '', 'True', '', '', '', '', '', 'less than', 70, '', ''); usr_BSEG_Interval.RecordtypeId = USRrecordtypeId; Insert usr_BSEG_Interval;
            usr_PSSTL_Interval = TestUtility.createUserSkillRule(2, 'PSSTL' , '', 'True', '', '', '', '', '', 'less than', 60, '', ''); usr_PSSTL_Interval.RecordtypeId = USRrecordtypeId; Insert usr_PSSTL_Interval;
            // Create User Skill
            userSkill1=TestUtility.createUserSkill(usr_BSEG_Interval.id,wia.id, wia); Insert userSkill1;
            userSkill2=TestUtility.createUserSkill(usr_PSSTL_Interval.id,wia.id, wia); Insert userSkill2;
            system.debug('******userSkill1'+userSkill1);
          	// Create Account
          	List<Account> accList = new List<Account>();
            Account acc = TestUtility.createAccount(date.today() - 60, 'Account 1', '0007652348'); accList.add(acc);//insert acc;
            Account acc2 = TestUtility.createAccount(date.today() - 60, 'Account 2', '0007652387'); accList.add(acc2);//insert acc2;
            insert accList;
            // Create Service Agreement
            Service_Agreement__c sa = TestUtility.createServiceAgreement(acc.Id); insert sa;
            // Create Premise
            Premise__c prem = TestUtility.createPremise(); insert prem;
            // Create Service Point
            Service_Point__c sp = TestUtility.createServicePoint(prem.Id); insert sp;
            // Create TurnOnAssignmentandGrouping__c
            TurnOnAssignmentandGrouping__c turnOnBSEG = TestUtility.createTurnOnAssignmentandGrouping('BSEG', true, true); insert turnOnBSEG;
            TurnOnAssignmentandGrouping__c turnOnPSSTL = TestUtility.createTurnOnAssignmentandGrouping('PSSTL', true, true); insert turnOnPSSTL;
            TurnOnAssignmentandGrouping__c turnOnRetroCommencing = TestUtility.createTurnOnAssignmentandGrouping('Retro Commencing', false, true); insert turnOnRetroCommencing;
            // Create Lookup Rollup Summary
            dlrs__LookupRollupSummary__c dlrs = TestUtility.createLookupRollupSummary(); insert dlrs;
            // Create Work Items
            List<Case> workItems = new List<Case>(); 
            
            // Date in 2 days
            date d = date.today().addDays(Integer.valueOf(System.Label.SLA_Notification_Days)); // j1eu added for PCR 139854
        
            // Group 1
            Case WorkItem1 = TestUtility.CreateWorkItem('40', 'QAS8', '', d - 60, '', '', acc.Id, sa.Id, true, prem.Id, sp.Id, queueId, recordtypeId);
            workItem1.OwnerId = testuser.Id;
            workItems.add(WorkItem1); //parent
            
            Case WorkItem2 = TestUtility.CreateWorkItem('40', 'Retro Commencing', '', d - 60, '', '', acc.Id, sa.Id, false, prem.Id, sp.Id, queueId, recordtypeId);
            workItem2.OwnerId = testuser.Id;
            workItems.add(WorkItem2);
            
            Case WorkItem3 = TestUtility.CreateWorkItem('40', 'PSSTL', '', d - 60, '', '', acc.Id, sa.Id, false, prem.Id, sp.Id, queueId, recordtypeId);
            workItem3.OwnerId = testuser.Id;
            workItems.add(WorkItem3);
            
            // Group 2
            Case WorkItem4 = TestUtility.CreateWorkItem('40', 'PSSTL', '', d - 60, '', '', acc2.Id, sa.Id, false, prem.Id, sp.Id, queueId, recordtypeId);
            workItem4.OwnerId = testuser.Id;
            workItems.add(WorkItem4); 
            
            Case WorkItem5 = TestUtility.CreateWorkItem('40', 'BSEG', '', d - 60, '', '', acc2.Id, sa.Id, true, prem.Id, sp.Id, queueId, recordtypeId);
            workItem5.OwnerId = testuser.Id;
            workItems.add(WorkItem5); //parent
            
            Case WorkItem6 = TestUtility.CreateWorkItem('40', 'Retro Commencing', '', d - 60, '', '', acc2.Id, sa.Id, false, prem.Id, sp.Id, queueId, recordtypeId);
            workItem6.OwnerId = testuser.Id;
            workItems.add(WorkItem6);
            
            insert workItems;
            
            WorkItem1 = [select SLA_Date__c, Event_Date__c from Case where Id =: WorkItem1.Id];
            system.assertEquals(date.today().addDays(Integer.valueOf(System.Label.SLA_Notification_Days)), WorkItem1.SLA_Date__c);
            
            SendSLANotification sla = new SendSLANotification();
            
            Database.executeBatch(sla, 2000); // 2000 is the max batch size
            
            Test.stopTest();
        }
    }
}