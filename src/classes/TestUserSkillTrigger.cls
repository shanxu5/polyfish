/**********************************************************************************************
* @author       Swetha Tonupunuri
* @date         09/04/2014
* @description	This test class tests UserskillTrigger and its 
                handler class  UserSkillTriggerHandler
* @revision(s)  Janella Espiritu - 09302014 - Sprint 2 Updates
**********************************************************************************************/
@isTest
public class TestUserSkillTrigger {

	static testMethod void testassignCases() {

    	User testuser; 
		User testUser2;
		//Work_Item_Assignment__c wia;
        Work_Item_Assignment__c wia2;
        
        //User skill rule records
        //User_Skill_Rule__c  usr_BSEG_Interval;
        //User_Skill_Rule__c  usr_PSSTL_Interval;
  
        //User Skill records
        User_Skill__c  userSkill1;
        User_Skill__c  userSkill2;

        Group testGroup;
        QueuesObject testQueue;
        // Query Queue
        Id queueId = [select Id, Name from Group where Name = 'Billing Exceptions' and Type = 'Queue'].Id;
        Id recordtypeId = [select Id from RecordType where Name='Billing Exceptions' and sObjectType = 'Case'].Id;
        
        //User to create test data
        Profile padmin = [select id from profile where name='System Administrator'];
        UserRole rbillops = [Select id from userrole where name='Billing Operations'];
        User admin= TestUtility.createUser(padmin.id,rbillops.id,2); //insert admin;
        
        // Query Profile and User Role
        Profile p = [select id from profile where name='CSR'];
        Profile p2 = [select id from profile where name='SSR'];
        UserRole r = [Select id from userrole where name='CSR'];
        
        system.runAs(admin){
            // Create Test User
            testuser2= TestUtility.createUser(p2.id,r.id, 3); testuser2.LAN_ID__C = 'USR1'; insert testuser2;
        	testuser= TestUtility.createUser(p.id,r.id, 1); testuser.Supervisor__c = testuser2.Id; testuser.LAN_ID__C = 'USR2'; insert testuser;
            // Create Account
            Account acc = TestUtility.createAccount(date.today() - 60, 'Account 1', '0007652348'); insert acc;
            Account acc2 = TestUtility.createAccount(date.today() - 60, 'Account 2', '0007652387'); insert acc2;
            // Create Service Agreement
            Service_Agreement__c sa = TestUtility.createServiceAgreement(acc.Id); insert sa;
            // Create Premise
            Premise__c prem = TestUtility.createPremise(); insert prem;
            // Create Service Point
            Service_Point__c sp = TestUtility.createServicePoint(prem.Id); insert sp;
            // Create Bill Cycle Window
            Bill_Cycle_Window__c bcw = TestUtility.createBillCycleWindow(); insert bcw;
            
            // Create TurnOnAssignmentandGrouping__c
            List<TurnOnAssignmentandGrouping__c> turnOnOffList = new List<TurnOnAssignmentandGrouping__c>();
            TurnOnAssignmentandGrouping__c turnOnBSEG = TestUtility.createTurnOnAssignmentandGrouping('BSEG', true, true); turnOnOffList.add(turnOnBSEG);
            TurnOnAssignmentandGrouping__c turnOnPSSTL = TestUtility.createTurnOnAssignmentandGrouping('PSSTL', true, true); turnOnOffList.add(turnOnPSSTL);
            TurnOnAssignmentandGrouping__c turnOnRetroCommencing = TestUtility.createTurnOnAssignmentandGrouping('Retro Commencing', false, true); turnOnOffList.add(turnOnRetroCommencing);
            insert turnOnOffList;
            
            // Create Lookup Rollup Summary
            dlrs__LookupRollupSummary__c dlrs = TestUtility.createLookupRollupSummary(); insert dlrs;
           
            // Create Work Item Assignment record  
            Work_Item_Assignment__c wia = TestUtility.createWorkItemAssignment(testUser.Id, true); insert wia;
            wia = [Select WI_Assigned__c, Limit__c, User__r.Supervisor__c from Work_Item_Assignment__c where Id =: wia.Id];
            system.assertEquals(testuser2.Id, wia.User__r.Supervisor__c);
            
            // Create User Skill Rule
            List<User_Skill_Rule__c> usrList = new List<User_Skill_Rule__c>();
            User_Skill_Rule__c usr_BSEG_Interval = TestUtility.createUserSkillRule(1, 'BSEG' , '', 'True', '', '', '', '', '', 'less than', 60, '', ''); usr_BSEG_Interval.Name = System.Label.DELAYED_BILLS_RES; usrList.add(usr_BSEG_Interval);
            User_Skill_Rule__c usr_PSSTL_Interval = TestUtility.createUserSkillRule(2, 'PSSTL' , '', 'True', '', '', '', '', '', 'less than', 60, '', ''); usrList.add(usr_PSSTL_Interval);
            User_Skill_Rule__c usr_Retro_Interval = TestUtility.createUserSkillRule(3, 'Retro Commencing' , '', 'True', '', '', '', '', '', 'less than', 60, '', ''); usrList.add(usr_Retro_Interval);
            insert usrList;

            // Create Work Items
            List<Case> workItems = new List<Case>();
            // Group 1
            Case WorkItem1 = TestUtility.CreateWorkItem('40', 'BSEG', '', date.today() - 50, '', '', acc.Id, sa.Id, true, prem.Id, sp.Id, queueId, recordtypeId); WorkItem1.OwnerId = queueId; workItems.add(WorkItem1); //parent
            Case WorkItem2 = TestUtility.CreateWorkItem('40', 'Retro Commencing', '', date.today() - 50, '', '', acc.Id, sa.Id, false, prem.Id, sp.Id, queueId, recordtypeId); WorkItem2.OwnerId = queueId; workItems.add(WorkItem2);
            Case WorkItem3 = TestUtility.CreateWorkItem('40', 'PSSTL', '', date.today() - 52, '', '', acc.Id, sa.Id, false, prem.Id, sp.Id, queueId, recordtypeId); WorkItem3.OwnerId = queueId; workItems.add(WorkItem3);
            // Group 2
            Case WorkItem4 = TestUtility.CreateWorkItem('40', 'PSSTL', '', date.today() - 50, '', '', acc2.Id, sa.Id, false, prem.Id, sp.Id, queueId, recordtypeId); WorkItem4.OwnerId = queueId; workItems.add(WorkItem4); 
            Case WorkItem5 = TestUtility.CreateWorkItem('40', 'BSEG', '', date.today() - 51, '', '', acc2.Id, sa.Id, true, prem.Id, sp.Id, queueId, recordtypeId); WorkItem5.OwnerId = queueId; workItems.add(WorkItem5); //parent
            Case WorkItem6 = TestUtility.CreateWorkItem('40', 'Retro Commencing', '', date.today() - 50, '', '', acc2.Id, sa.Id, false, prem.Id, sp.Id, queueId, recordtypeId); WorkItem6.OwnerId = queueId; workItems.add(WorkItem6);
            insert workItems;
            
			Case WorkItem3Rec = [select ParentId, Owner.Name, OwnerId from Case where Id =: WorkItem3.Id];
			system.assertEquals(WorkItem1.Id, WorkItem3Rec.ParentId);
            //system.assertEquals('Billing Exceptions', WorkItem3Rec.Owner.Name);
            userSkill1=TestUtility.createUserSkill(usr_BSEG_Interval.id,wia.id,wia); Insert userSkill1;
            
            //userSkill2=TestUtility.createUserSkill(usr_PSSTL_Interval.id,wia.id); Insert userSkill2;
            
            // Validate that cases are Assigned
            Case caseRec = [select Id, User_Skill_Rule__c, Status, OwnerId, Owner.Name, RecordType.Name, Age__c, Interval__c from Case where Id =: WorkItem1.Id];
            system.assertEquals(50, caseRec.Age__c);
            system.assertEquals(true, caseRec.Interval__c);
            system.assertEquals(usr_BSEG_Interval.Id, caseRec.User_Skill_Rule__c);
            system.assertEquals('Assigned', caseRec.Status);
            system.assertEquals(usr_BSEG_Interval.Id , caseRec.User_Skill_Rule__c);
            system.assertEquals(testUser.Id, caseRec.OwnerId);
            // Validate that the cases are assigned to the correct Work Item Assignment
            Work_Item_Assignment__c wiaRec = [Select WI_Assigned__c, Limit__c, User__r.Supervisor__c from Work_Item_Assignment__c where Id =: wia.Id];
            system.assertEquals(testuser2.Id, wiaRec.User__r.Supervisor__c);
            system.assertEquals(1, wiaRec.Limit__c);
            system.assertEquals(2, wiaRec.WI_Assigned__c);
         }
        
        
    }
    
    static testMethod void testassignCases2() {

    	User testuser; 
		User testUser2;
		Work_Item_Assignment__c wia;
        Work_Item_Assignment__c wia2;
        
        //User skill rule records
        //User_Skill_Rule__c  usr_BSEG_Interval;
        //User_Skill_Rule__c  usr_PSSTL_Interval;
  
        //User Skill records
        User_Skill__c  userSkill1;
        User_Skill__c  userSkill2;

        Group testGroup;
        QueuesObject testQueue;
        // Query Queue
        Id queueId = [select Id, Name from Group where Name = 'Billing Exceptions' and Type = 'Queue'].Id;
        Id recordtypeId = [select Id from RecordType where Name='Billing Exceptions' and sObjectType = 'Case'].Id;
        //User to create test data
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        
        // Query Profile and User Role
        Profile p = [select id from profile where name='CSR'];
        Profile p2 = [select id from profile where name='SSR'];
        UserRole r = [Select id from userrole where name='CSR'];
        
        system.runAs(thisUser){
            // Create Test User
            testuser2= TestUtility.createUser(p2.id,r.id, 2); testuser2.LAN_ID__C = 'USR1';  insert testuser2;
            testuser= TestUtility.createUser(p.id,r.id, 1); testuser.LAN_ID__C = 'USR2';  testuser.Supervisor__c = testuser2.Id; insert testuser;
            // Create Account
            Account acc = TestUtility.createAccount(date.today() - 60, 'Account 1', '0007652348'); insert acc;
            Account acc2 = TestUtility.createAccount(date.today() - 60, 'Account 2', '0007652387'); insert acc2;
            // Create Service Agreement
            Service_Agreement__c sa = TestUtility.createServiceAgreement(acc.Id); insert sa;
            // Create Premise
            Premise__c prem = TestUtility.createPremise(); insert prem;
            // Create Service Point
            Service_Point__c sp = TestUtility.createServicePoint(prem.Id); insert sp;
            // Create Bill Cycle Window
            Bill_Cycle_Window__c bcw = TestUtility.createBillCycleWindow(); insert bcw;
            
            // Create TurnOnAssignmentandGrouping__c
            List<TurnOnAssignmentandGrouping__c> turnOnOffList = new List<TurnOnAssignmentandGrouping__c>();
            TurnOnAssignmentandGrouping__c turnOnBSEG = TestUtility.createTurnOnAssignmentandGrouping('BSEG', true, true); turnOnOffList.add(turnOnBSEG);
            TurnOnAssignmentandGrouping__c turnOnPSSTL = TestUtility.createTurnOnAssignmentandGrouping('PSSTL', true, true); turnOnOffList.add(turnOnPSSTL);
            TurnOnAssignmentandGrouping__c turnOnRetroCommencing = TestUtility.createTurnOnAssignmentandGrouping('Retro Commencing', false, true); turnOnOffList.add(turnOnRetroCommencing);
            insert turnOnOffList;
            
            // Create Lookup Rollup Summary
            dlrs__LookupRollupSummary__c dlrs = TestUtility.createLookupRollupSummary(); insert dlrs;
           
            // Create Work Item Assignment record  
            wia = TestUtility.createWorkItemAssignment(testUser.Id, true); insert wia;
            // Validate that the Work Item Assignment has a Supervisor and is Available
            wia = [Select WI_Assigned__c, Limit__c, User__r.Supervisor__c, Availability__c from Work_Item_Assignment__c where Id =: wia.Id];
            system.assertEquals(testuser2.Id, wia.User__r.Supervisor__c);
            system.assertEquals(1, wia.Limit__c);
            system.assertEquals(0, wia.WI_Assigned__c);
            system.assertEquals(true, wia.Availability__c);
            // Create User Skill Rules
            List<User_Skill_Rule__c> usrList = new List<User_Skill_Rule__c>();
            User_Skill_Rule__c usr_BSEG_Interval = TestUtility.createUserSkillRule(1, 'BSEG' , '', 'True', '', '', '', '', '', 'less than', 60, '', ''); usr_BSEG_Interval.Name = System.Label.DELAYED_BILLS_RES; usrList.add(usr_BSEG_Interval);
            User_Skill_Rule__c usr_PSSTL_Interval = TestUtility.createUserSkillRule(2, 'PSSTL' , '', 'True', '', '', '', '', '', 'less than', 60, '', ''); usrList.add(usr_PSSTL_Interval);
            User_Skill_Rule__c usr_Retro_Interval = TestUtility.createUserSkillRule(3, 'Retro Commencing' , '', 'True', '', '', '', '', '', 'less than', 60, '', ''); usrList.add(usr_Retro_Interval);
            insert usrList;

            // Create Work Items
            List<Case> workItems = new List<Case>();
            // Group 1
            Case WorkItem1 = TestUtility.CreateWorkItem('40', 'PSSTL', '', date.today() - 50, '', '', acc.Id, sa.Id, true, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem1); //parent
            Case WorkItem2 = TestUtility.CreateWorkItem('40', 'Retro Commencing', '', date.today() - 50, '', '', acc.Id, sa.Id, true, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem2); //parent
            insert workItems;
            
            Case wi1 = [select User_Skill_Rule__c from Case where Id=: WorkItem1.Id];
            system.assertEquals(usr_PSSTL_Interval.Id, wi1.User_Skill_Rule__c);
            // Create User Skill for Work Item Assignment
            userSkill2=TestUtility.createUserSkill(usr_PSSTL_Interval.id,wia.id,wia); Insert userSkill2;
            // Validate that the Work Item Assignment has a User Skill Rule
            userSkill2 = [Select Work_Item_Assignment__r.User__r.Supervisor__c from User_Skill__c where Id =: userSkill2.Id];
            system.assertEquals(testuser2.Id, userSkill2.Work_Item_Assignment__r.User__r.Supervisor__c);
            // Validate that cases are Assigned
            Case caseRec = [select Id, User_Skill_Rule__c, Status, OwnerId, Owner.Name, RecordType.Name, Age__c, Interval__c, Approver_Reviewer__c, ParentId from Case where Id =: WorkItem1.Id];
            system.assertEquals(null, caseRec.ParentId);
            system.assertEquals(50, caseRec.Age__c);
            system.assertEquals(true, caseRec.Interval__c);
            system.assertEquals('Assigned', caseRec.Status);
            system.assertEquals(testUser2.Id, caseRec.Approver_Reviewer__c);
            system.assertEquals(usr_PSSTL_Interval.Id , caseRec.User_Skill_Rule__c);
            system.assertEquals(testUser.Id, caseRec.OwnerId);
            
            // Validate that the cases are assigned to the correct Work Item Assignment
            Work_Item_Assignment__c wiaRec = [Select WI_Assigned__c, Limit__c, User__r.Supervisor__c from Work_Item_Assignment__c where Id =: wia.Id];
            system.assertEquals(testuser2.Id, wiaRec.User__r.Supervisor__c);
            system.assertEquals(1, wiaRec.Limit__c);
            system.assertEquals(1, wiaRec.WI_Assigned__c);
         }
        
        
    }
}