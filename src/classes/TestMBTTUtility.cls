@isTest
public class TestMBTTUtility {
    /**********************************************************************************************
    * @author       Janella Espiritu
    * @date         07/21/2015
    * @description  This is Test Setup method that will create test data used in this test class
    * @version      1.0
    * @revision(s)  
    **********************************************************************************************/
    @testSetup static void setup() {
        
        Profile intProfile = [select id from profile where name='Integration'];
        UserRole intSupervisor = [Select id from userrole where name='Supervisor'];
        User integration = TestUtility.createUser(intProfile.id,intSupervisor.id,3); integration.LAN_ID__c = 'INT1';
        
        // Query Queue
        Id BEqueueId = WorkItemAssignmentUtility.getBillingExceptionQueueId();
        Id recordtypeId = WorkItemAssignmentUtility.getCaseBillingExceptionsRecordTypeId();
        Id USRrecordtypeId = [select Id from RecordType where DeveloperName=: 'BSEG_MBT_Elec_SM30_SM40' and sObjectType = 'User_Skill_Rule__c'].Id;
        system.runAs(integration){
            // Create User Skill Rule
            User_Skill_Rule__c usr_BSEG_Interval = TestUtility.createUserSkillRule(1, 'BSEG' , '', 'True', '', '', '', '', '', 'less than', 70, '', '', null); 
            usr_BSEG_Interval.RecordtypeId = USRrecordtypeId; 
            usr_BSEG_Interval.Name = 'BSEG MBT Elec SM40'; 
            insert usr_BSEG_Interval;
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
            // Create Work Items
            List<Case> workItems = new List<Case>(); 
            for(Integer i = 0; i < 5; i++){
            	Case WorkItem1 = TestUtility.CreateWorkItem('40', 'BSEG', '', date.today() - 60, '', '', acc.Id, sa.Id, true, prem.Id, sp.Id, BEqueueId, recordtypeId); workItems.add(WorkItem1);
            }
            insert workItems;
        }
    }
	static testMethod void testMBTUtility() {
        Profile pbillOpsHead = [select id from profile where name='Billing Ops Head'];
        UserRole rSupervisor = [Select id from userrole where name='Supervisor'];
        User supervisor= TestUtility.createUser(pbillOpsHead.id,rSupervisor.id,10); supervisor.LAN_ID__c = 'SUP2';
        Id BEqueueId = WorkItemAssignmentUtility.getBillingExceptionQueueId();
        Id queueId = WorkItemAssignmentUtility.getMBTQueueId();
        System.runAs(supervisor){  
          	Test.startTest();
            Id usr = [select Id from User_Skill_Rule__c where Sort_Order__c = 1].Id;
            for(Case c : [select OwnerId, Status,User_Skill_Rule__c from Case]){
                system.assertEquals(c.User_Skill_Rule__c, usr);
                system.assertEquals(queueId, c.OwnerId);
                system.assertEquals('Unassigned', c.Status);
            }
            System.assertEquals(0, [select Id from Case where OwnerId =: BEqueueId].size());
            MBTUtility.updateMBTWorkItemStatus();
            System.assertEquals(0, [select Id from Case where OwnerId =: BEqueueId].size());
            for(Case c : [select OwnerId, Status,User_Skill_Rule__c from Case]){
                system.assertEquals(c.User_Skill_Rule__c, usr);
                system.assertEquals('Assigned', c.Status);
                //system.assertEquals(queueId, c.OwnerId);
            }
            MBTUtility.updateMBTOwnerId();
            for(Case c : [select OwnerId from Case]){
                system.assertEquals(BEqueueId, c.OwnerId);
            }
            Test.stopTest();
        }
    }
}