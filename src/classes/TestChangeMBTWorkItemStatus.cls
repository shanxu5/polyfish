@isTest
public class TestChangeMBTWorkItemStatus {
	static testMethod void testChangeMBTWorkItemStatus() {
        /************************************************************************
         *  Creating following test data as current user 
         *   - User
         *   - User skill rules
         *   - user Skill
         *   - Work Item Assignment
         *   - WorkItem
         ***********************************************************************/
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
        Id queueId = [select Id, Name from Group where Name = 'BSEG MBT Elec SM30 SM40' and Type = 'Queue'].Id;
        Id recordtypeId = [select Id from RecordType where Name='Billing Exceptions' and sObjectType = 'Case'].Id;
        Id USRrecordtypeId = [select Id from RecordType where DeveloperName=: 'BSEG_MBT_Elec_SM30_SM40' and sObjectType = 'User_Skill_Rule__c'].Id;
        //User to create test data
        Profile padmin = [select id from profile where name='Administrator'];
        UserRole rbillops = [Select id from userrole where name='Billing Operations'];
        User admin= TestUtility.createUser(padmin.id,rbillops.id,1); admin.Lan_ID__c = 'ADM1'; insert admin;
        
        // Query Profile and User Role
        Profile p = [select id from profile where name='CSR'];
        Profile p2 = [select id from profile where name='SSR'];
        UserRole r = [Select id from userrole where name='CSR'];
        // Create Test User
        User testuser2= TestUtility.createUser(p2.id,r.id, 2); testuser2.Lan_ID__c = 'USR2'; insert testuser2;
        User testuser= TestUtility.createUser(p.id,r.id, 3); testuser.Lan_ID__c = 'USR3'; testuser.Supervisor__c = testuser2.Id; insert testuser;
        
        System.runAs(admin){  
          	// Create User Skill Rule
            usr_BSEG_Interval = TestUtility.createUserSkillRule(1, 'BSEG' , '', 'True', '', '', '', '', '', 'less than', 70, '', '',null); usr_BSEG_Interval.RecordtypeId = USRrecordtypeId; Insert usr_BSEG_Interval;
        	// Create Account
            Account acc = TestUtility.createAccount(date.today() - 60, 'Account 1', '0007652348'); insert acc;
            Account acc2 = TestUtility.createAccount(date.today() - 60, 'Account 2', '0007652387'); insert acc2;
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
            for(Integer i = 0; i < 500; i++){
            	Case WorkItem1 = TestUtility.CreateWorkItem('40', 'BSEG', '', date.today() - 60, '', '', acc.Id, sa.Id, true, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem1);
            }
            insert workItems;
            for(Case c : [select OwnerId, Status from Case]){
                system.assertEquals(queueId, c.OwnerId);
                system.assertEquals('Unassigned', c.Status);
            }
            
            MBTUtility.updateMBTWorkItemStatus();
            for(Case c : [select OwnerId, Status from Case]){
                system.assertEquals(queueId, c.OwnerId);
                system.assertEquals('Assigned', c.Status);
            }
        }
    }
}