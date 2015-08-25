/**********************************************************************************************
* @author       Tae Tran
* @date         07/21/2015
*
* @version      1.0
*
* @description  Test class for emailbatch class
*               
* @revision     
*               
**********************************************************************************************/

@isTest
public class TestEmailBatch {
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
        User CSR= TestUtility.createUser(csrProfile.id,csrRole.id,11);  
        CSR.Supervisor__c = supervisor.Id; CSR.Lan_ID__c = 'CSR2'; 
        insert CSR;
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
            Case WorkItem = TestUtility.CreateWorkItem('40', 'PSSTL', 'Pending Start', null, '24164', '90000', acc.Id, DASA.Id, true, prem.Id, sp.Id, queueId, recordtypeId); 
            WorkItem.Hold__c = TRUE;
            WorkItem.LAN_ID__c = 'txtr';
            WorkItem.Approver_Reviewer_Email__c = 'txtr@pge.com';
            WorkItem.OwnerId = CSR.ID;
        	insert WorkItem;
        }
     }
    
    	static testMethod void test_emailbatch()
    	{      
            Id recordtypeId = [select Id from RecordType where Name='Billing Exceptions' and sObjectType = 'Case'].Id;	   
            Test.startTest();
    	        String query = 'select Id, OwnerID, Work_Item_Type__c, CaseNumber, Approver_Reviewer_Email__c, Root_Cause__c, Root_Cause_Other__c from Case';// where Id IN (' + recordtypeId + ')';                        
				EmailBatch batchApex = new EmailBatch(query); // call the email batch process
				Database.executeBatch(batchApex, 50); // call apex batch
            Test.stopTest();
            
        }  

}