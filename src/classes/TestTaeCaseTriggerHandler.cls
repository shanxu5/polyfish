@isTest
private class TestTaeCasetriggerHandler {
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
        Profile csrProfile = [select id from profile where name='CSR'];
        UserRole csrRole = [Select id from userrole where name='CSR'];
        Profile pbillOpsHead = [select id from profile where name='Billing Ops Head'];
        UserRole rSupervisor = [Select id from userrole where name='Supervisor'];
        //User admin= TestUtility.createUser(padmin.id,rbillops.id,3); insert admin;
        User supervisor= TestUtility.createUser(pbillOpsHead.id,rSupervisor.id,10); supervisor.LAN_ID__c = 'SUP2'; insert supervisor;
        User CSR= TestUtility.createUser(csrProfile.id,csrRole.id,11);  CSR.Supervisor__c = supervisor.Id; CSR.Lan_ID__c = 'CSR2'; insert CSR;
        // Query Queue
        Id queueId = WorkItemAssignmentUtility.getBillingExceptionQueueId();
        Id recordtypeId = WorkItemAssignmentUtility.getCaseBillingExceptionsRecordTypeId();
        
        system.runAs(integration){
            // Create Account
            Account acc = TestUtility.createAccount(date.today() - 60, 'Account 1', '0007652348'); 
            acc.Postpone_Credit_Date__c = date.today();
            insert acc;
            Account acc2 = TestUtility.createAccount(date.today() - 60, 'Account 2', '0007652349'); insert acc2;
            // Create Service Agreement
            Service_Agreement__c DASA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'HE-RES', '1234567890'); insert DASA;
            // Create Premise
            Premise__c prem = TestUtility.createPremise(); insert prem;
            // Create Service Point
            Service_Point__c sp = TestUtility.createServicePoint(prem.Id); insert sp;
            
            Grouping_Class__c DaccaGC = TestUtility.populateGroupingClass('DACCA'); insert DaccaGC;
            Grouping_Rules__c DaccaGR = TestUtility.populateGroupingRules(1, 'Specialized DACCA', 'Hierarchy', DaccaGC.Id, 'AccountId'); insert DaccaGR;
            Related_Class__c DaccaRC1 = TestUtility.relatedClass(DaccaGC.Id, DaccaGR.Id); insert DaccaRC1;
            
            //create GroupingType Custom Setting
            List<GroupingTypes__c> gtList = new List<GroupingTypes__c>();
            GroupingTypes__c hierarchy = TestUtility.createGroupingTypes('Hierarchy','HierarchyImpl');
            gtList.add(hierarchy);
            GroupingTypes__c priority = TestUtility.createGroupingTypes('Priority','PriorityImpl');
            gtList.add(priority);
            insert gtList;
            
            High_Bill_Threshold__c hbt = new High_Bill_Threshold__c();
            hbt.Name = 'High Bill Rate';
            hbt.High_Bill_Threshold_Amount__c = 3000;
            insert hbt;
            
            // Create User Skill Rule
            User_Skill_Rule__c IntUSR     = TestUtility.createUserSkillRule(3, 'BSEG', null, 'TRUE', null, null, null, null, null, null, null, null, null, null); 
            IntUSR.Name = 'Fast/Slow Meter Adj - Gas';
            insert IntUSR;
            
            User_Skill_Rule__c DaccaUSR   = TestUtility.createUserSkillRule(1, 'DACCA', null, null, null, 'TRUE', null, null, null, null, null, null, null, DaccaGC.Id); 
            DaccaUSR.Name = 'DACCA USR'; DaccaUSR.GroupingEnabled__c=TRUE; insert DaccaUSR;
            
            List<Case> insertWI = new List<Case>();
            for(Integer i = 0; i < 5; i++){
                Case wi = TestUtility.CreateWorkItem('40', 'DACCA', 'Pending Start', null, '24164', '90000', acc.Id, DASA.Id, true, prem.Id, sp.Id, queueId, recordtypeId); insertWI.add(wi);
                wi = TestUtility.CreateWorkItem('40', 'DACCA', 'Pending Start', null, '24164', '90000', acc2.Id, DASA.Id, true, prem.Id, sp.Id, queueId, recordtypeId); insertWI.add(wi);
            }
        	insert insertWI;   
            Case WorkItem = TestUtility.CreateWorkItem('40', 'Unaged Debt', 'Pending Start', null, '24164', '90000', acc.Id, DASA.Id, true, prem.Id, sp.Id, queueId, recordtypeId); 
            WorkItem.Hold__c = TRUE;
            WorkItem.LAN_ID__c = 'txtr';
        	insert WorkItem;
        }
    }
/*
    	//test methods
      	static testMethod void testreopenworkitem() {
          
		User pAdmin = [Select Id from User where Lan_ID__c = 'ADM1'];
        System.assert(pAdmin != null);
          
		User pTestUser = [Select Id from User where lan_ID__c = 'USR2'];
        System.assert(pTestUser != null);
        System.runAs(pAdmin){  
		Test.startTest();
          	Case workItems = [Select Id, OwnerId, Reopened__c, RecordTypeId from Case where Work_Item_Type__c = 'PSSTL'];
            System.debug(Logginglevel.info,'%%%%%%%%%%%%%%%%%%% What is the workitem...' + workItems);
            
            workItems.Reopened__c = true; // Mark it true
     		update workItems;
            
            Case workItems1 = [Select Id, OwnerId, RecordTypeId, Reopened__c from Case];
            System.debug(Logginglevel.info,'%%%%%%%%%%%%%%%%%%% What is the workitem1...' + workItems1);
            
			Test.stopTest();
		}
      }
    */
      static testMethod void testfreezeID(){
          // Query Queue
        Profile csrProfile = [select id from profile where name='CSR'];
        UserRole csrRole = [Select id from userrole where name='CSR'];
        Profile pbillOpsHead = [select id from profile where name='Billing Ops Head'];
        UserRole rSupervisor = [Select id from userrole where name='Supervisor'];
        //User admin= TestUtility.createUser(padmin.id,rbillops.id,3); insert admin;
        User supervisor= TestUtility.createUser(pbillOpsHead.id,rSupervisor.id,4); supervisor.LAN_ID__c = 'SUP1'; insert supervisor;
        User CSR= TestUtility.createUser(csrProfile.id,csrRole.id,1);  CSR.Supervisor__c = supervisor.Id; CSR.Lan_ID__c = 'CSR1'; insert CSR;
        
        Id queueId = WorkItemAssignmentUtility.getBillingExceptionQueueId();
        Id recordtypeId = WorkItemAssignmentUtility.getCaseBillingExceptionsRecordTypeId();
        Account acc = [select Id from Account limit 1];
        Service_Agreement__c DASA = [Select Id from Service_Agreement__c limit 1];
        Premise__c prem = [Select Id from Premise__c limit 1];
        Service_Point__c sp = [Select Id from Service_Point__c limit 1];
        //TestUtility.CreateWorkItem(smSpStatus, workItemType, saStatus, eventDate, msgNumber, msgCategoryNumber, accountId, serviceAgreementId, DACCAIndicator, premiseId, servicePointId, ownerId, recordTypeId)
        Case WorkItem = [select Id, Status from Case limit 1];
        
        
        system.runAs(CSR){
            Test.startTest();
            
          /*  Case WorkItem2 = TestUtility.CreateWorkItem('40', 'Unaged Debt', 'Pending Start', null, '24164', '90000', acc.Id, DASA.Id, true, prem.Id, sp.Id, queueId, recordtypeId); 
            WorkItem2.Hold__c = TRUE;
            WorkItem2.LAN_ID__c = 'txtr';
        	insert WorkItem2;
  /*          
            List<Status_Times__c> st = [select id, Work_Item__c from Status_Times__c where Work_Item__c =: WorkItem.Id];
            system.assertEquals(0, st.size());
            
            WorkItem.Status = 'Pending';
            WorkItem.Sub_Status__c = 'Floor Support';
            WorkItem.Floor_Support_Request_Completed__c = true;
            WorkItem.Floor_Support_Analyst__c = supervisor.Id;
            update WorkItem;
            
            st = [select id, Work_Item__c, Current_Status__c, Last_Status__c from Status_Times__c where Work_Item__c =: WorkItem.Id order by CreatedDate];
            system.assertEquals(1, st.size());
            system.assertEquals('Unassigned', st[0].Last_Status__c);
            system.assertEquals('Pending', st[0].Current_Status__c);
*/
            Test.stopTest();
            
        }
      }
    
    
}