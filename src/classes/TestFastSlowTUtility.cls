@isTest
public class TestFastSlowTUtility {
	static testMethod void testFastSlowUtility() {
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
        User_Skill_Rule__c  usr_FastSlow_Gas;
  
        
        //User Skill records
        User_Skill__c  userSkill1;
        User_Skill__c  userSkill2;

        Group testGroup;
        QueuesObject testQueue;
        // Query Queue
        Id queueId = [select Id, Name from Group where Name = 'Fast Slow To Dos' and Type = 'Queue'].Id;
        Id BEqueueId = [select Id, Name from Group where Name = 'Billing Exceptions' and Type = 'Queue'].Id;
        Id recordtypeId = [select Id from RecordType where Name='Billing Exceptions' and sObjectType = 'Case'].Id;
        Id USRrecordtypeId = [select Id from RecordType where DeveloperName=: 'BSEG_MBT_Elec_SM30_SM40' and sObjectType = 'User_Skill_Rule__c'].Id;
        //User to create test data
        Profile padmin = [select id from profile where name='Administrator'];
        UserRole rbillops = [Select id from userrole where name='Billing Operations'];
        User admin= TestUtility.createUser(padmin.id,rbillops.id,1); admin.Lan_ID__c = 'ADM1'; //insert admin;
        
        // Query Profile and User Role
        Profile p = [select id from profile where name='CSR'];
        Profile p2 = [select id from profile where name='SSR'];
        UserRole r = [Select id from userrole where name='CSR'];
        // Create Test User
        User testuser2= TestUtility.createUser(p2.id,r.id, 2); testuser2.Lan_ID__c = 'USR2'; insert testuser2;
        User testuser= TestUtility.createUser(p.id,r.id, 3); testuser.Lan_ID__c = 'USR3'; testuser.Supervisor__c = testuser2.Id; insert testuser;
        
        System.runAs(admin){  
          	// Create User Skill Rule
            usr_FastSlow_Gas = TestUtility.createUserSkillRule(1, 'Fast Slow Mtr Adj To Do' , '', '', 'G-COM', '', '', '', '', '', null, '', '',null); Insert usr_FastSlow_Gas;
        	// Create Account
        	List<Account> accList = new List<Account>();
            Account acc = TestUtility.createAccount(date.today() - 60, 'Account 1', '0007652348'); accList.add(acc);//insert acc;
            Account acc2 = TestUtility.createAccount(date.today() - 60, 'Account 2', '0007652387'); accList.add(acc2);//insert acc2;
            insert accList;
            // Create Service Agreement
            Service_Agreement__c sa = TestUtility.createServiceAgreement(acc.Id); sa.SA_Type_CD__c = 'G-COM'; insert sa;
            // Create Premise
            Premise__c prem = TestUtility.createPremise(); insert prem;
            // Create Service Point
            Service_Point__c sp = TestUtility.createServicePoint(prem.Id); insert sp;
            // Create Lookup Rollup Summary
            dlrs__LookupRollupSummary__c dlrs = TestUtility.createLookupRollupSummary(); insert dlrs;
            // Create Work Items
            List<Case> workItems = new List<Case>(); 
            for(Integer i = 0; i < 500; i++){
            	Case WorkItem1 = TestUtility.CreateWorkItem('40', 'Fast Slow Mtr Adj To Do', '', date.today() - 60, '', '', acc.Id, sa.Id, true, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem1);
            }
            insert workItems;
            for(Case c : [select OwnerId, Status from Case]){
                system.assertEquals(queueId, c.OwnerId);
                system.assertEquals('Unassigned', c.Status);
            }
            
            FastSlowUtility.updateFastSlowGasWorkItemStatus();
            for(Case c : [select OwnerId, Status from Case]){
                system.assertEquals(queueId, c.OwnerId);
                system.assertEquals('Assigned', c.Status);
            }
            FastSlowUtility.updateFastSlowGasOwnerId();
            for(Case c : [select OwnerId from Case]){
                system.assertEquals(BEqueueId, c.OwnerId);
            }
        }
    }
}