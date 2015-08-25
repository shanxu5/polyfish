/**********************************************************************************************
* @author       Janella Espiritu
* @date         07/21/2015
*
* @version      1.0
*
* @description  This test class tests CaseTrigger and CaseTriggerHandler
*
* @revision(s)  Original
**********************************************************************************************/
@isTest
private class TestCaseTriggerHandler2 {
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
            Case WorkItem = TestUtility.CreateWorkItem('40', 'PSSTL', 'Pending Start', null, '24164', '90000', acc.Id, DASA.Id, true, prem.Id, sp.Id, queueId, recordtypeId); 
            WorkItem.Hold__c = TRUE;
        	insert WorkItem;
        }
    }
    /**********************************************************************************************
    * @author       Janella Espiritu
    * @date         07/20/2015
    * @description  Validate Required fields on Creation of Customer Contact record
    * @version      1.0
    * @revision(s)  
    **********************************************************************************************/
    static testMethod void testUpdateWorkItemAssignment(){
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
        system.runAs(supervisor){
            Test.startTest();
            system.assertEquals('Unassigned', workItem.Status);
            
            WorkItem.OwnerId = CSR.Id;
            update WorkItem;
            WorkItem = [select Approver_Reviewer__c, LAN_ID__c from Case where id =: WorkItem.Id];
            system.assertEquals('CSR1', WorkItem.LAN_ID__c);
            system.assertEquals(supervisor.Id, WorkItem.Approver_Reviewer__c);
            
            WorkItem.OwnerId = queueId;
            update WorkItem;    
            WorkItem = [select Approver_Reviewer__c, LAN_ID__c, Status from Case where id =: WorkItem.Id];
            system.assertEquals(null, WorkItem.LAN_ID__c);
            system.assertEquals(null, WorkItem.Approver_Reviewer__c);
            system.assertEquals('Unassigned', WorkItem.Status);
            
            Work_Item_Assignment__c wia = TestUtility.createWorkItemAssignment(CSR.Id, true); insert wia;
            WorkItem.OwnerId = CSR.Id;
            update WorkItem;    
            WorkItem = [select Approver_Reviewer__c, LAN_ID__c,Status, Work_Item_Assignment__c from Case where id =: WorkItem.Id];
            system.assertEquals(wia.Id, WorkItem.Work_Item_Assignment__c);
            system.assertEquals('Assigned', WorkItem.Status);
            system.assertEquals('CSR1', WorkItem.LAN_ID__c);
            system.assertEquals(supervisor.Id, WorkItem.Approver_Reviewer__c);
            Test.stopTest();
        }
    }
    
    /**********************************************************************************************
    * @author       Janella Espiritu
    * @date         07/20/2015
    * @description  Validate Required fields on Creation of Customer Contact record
    * @version      1.0
    * @revision(s)  
    **********************************************************************************************/
    static testMethod void testConcatenateCustomerContacts(){
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
            WorkItem.OwnerId = CSR.Id;
            WorkItem.Customer_Contact_Class__c = 'Records Dept Note';
            WorkItem.Customer_Contact_Type__c = 'RECORDS';
            WorkItem.SOX_Required_Information__c = 'Service Agreement ID';
            WorkItem.CC_Service_Agreement_ID__c = '1234567890';
            WorkItem.As_Billed_Amount__c = 1234;
            WorkItem.As_Corrected_Amount__c = 3214;
            WorkItem.As_Billed_Corrected_From__c = date.today();
            WorkItem.As_Billed_Corrected_To__c = date.today();
            WorkItem.Billed_From_Date__c = date.today();
            WorkItem.Billed_To_Date__c = date.today();
            WorkItem.Billed_To_Amount__c = 4545;
            update WorkItem;
            WorkItem = [select Customer_Contact_Comments__c, CC_Service_Agreement_ID__c from Case where id =: WorkItem.Id];
            system.assert(WorkItem.Customer_Contact_Comments__c.contains(WorkItem.CC_Service_Agreement_ID__c));
            
            WorkItem.SOX_Required_Information__c = 'Account ID';
            WorkItem.CC_Account_ID__c = '9876514521';
            update WorkItem;
            WorkItem = [select Customer_Contact_Comments__c, CC_Account_ID__c from Case where id =: WorkItem.Id];
            system.assert(WorkItem.Customer_Contact_Comments__c.contains(WorkItem.CC_Account_ID__c));
            
            WorkItem.SOX_Required_Information__c = 'Service Point ID';
            WorkItem.CC_Service_Point_ID__c = '6857489652';
            update WorkItem;
            WorkItem = [select Customer_Contact_Comments__c, CC_Service_Point_ID__c from Case where id =: WorkItem.Id];
            system.assert(WorkItem.Customer_Contact_Comments__c.contains(WorkItem.CC_Service_Point_ID__c));
            
            WorkItem.SOX_Required_Information__c = 'Premise ID';
            try{
                WorkItem.CC_Premise_ID__c = '8574965412';
                // Update customer contact so it will exceed 254 characters
                WorkItem.As_Billed_Amount__c =  123123546.112638546;
                WorkItem.As_Corrected_Amount__c =  123123546.112638546;
                WorkItem.Billed_To_Amount__c =  123123546.112638546;
                update WorkItem;
                WorkItem = [select Customer_Contact_Comments__c from Case where id =: WorkItem.Id];
                System.assertEquals(254, WorkItem.Customer_Contact_Comments__c.length());
            }
            catch(Exception e){
               Boolean expectedExceptionThrown =  e.getMessage().contains('The maximum number of characters for Customer Contact Comments is 254.') ? true : false;
               System.AssertEquals(true, expectedExceptionThrown);
            }
            WorkItem.As_Billed_Amount__c = 1234;
            WorkItem.As_Corrected_Amount__c = 3214;
            WorkItem.Billed_To_Amount__c = 4545;
            WorkItem.CC_Premise_ID__c = '8574965412';
            
            update WorkItem;
            WorkItem = [select Customer_Contact_Comments__c, CC_Premise_ID__c from Case where id =: WorkItem.Id];
            system.assert(WorkItem.Customer_Contact_Comments__c.contains(WorkItem.CC_Premise_ID__c));
            
            WorkItem.SOX_Required_Information__c = 'Premise Address';
            WorkItem.CC_Premise_Address__c = 'Premise Address';
            update WorkItem;
            WorkItem = [select Customer_Contact_Comments__c, CC_Premise_Address__c from Case where id =: WorkItem.Id];
            system.assert(WorkItem.Customer_Contact_Comments__c.contains(WorkItem.CC_Premise_Address__c));
            
            WorkItem.CC_Premise_Address__c = 'This is a very loooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooong premise address';
            update WorkItem;
            WorkItem = [select Customer_Contact_Comments__c, CC_Premise_Address__c, As_Billed_Amount__c, Additional_Customer_Contact_Log__c from Case where id =: WorkItem.Id];
            system.assert(WorkItem.Customer_Contact_Comments__c.contains(WorkItem.CC_Premise_Address__c));
            system.assert(WorkItem.Additional_Customer_Contact_Log__c.contains(String.valueOf(WorkItem.As_Billed_Amount__c)));
            Test.stopTest();
        }
    }
	/**********************************************************************************************
    * @author       Janella Espiritu
    * @date         07/20/2015
    * @description  Validate Required fields on Creation of Customer Contact record
    * @version      1.0
    * @revision(s)  
    **********************************************************************************************/
    static testMethod void testCreateCustomerContact(){
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
        system.runAs(supervisor){
            WorkItem.OwnerId = CSR.Id;
            update WorkItem;
        }
        
        system.runAs(CSR){
            Test.startTest();
            List<Related_Records__c> rr = [select id, SFDC_Work_Item__c from Related_Records__c];
            system.assertEquals(0, rr.size());
            WorkItem.Customer_Contact_Class__c = 'Records Dept Note';
            WorkItem.Customer_Contact_Type__c = 'RECORDS';
            WorkItem.SOX_Required_Information__c = 'Service Agreement ID';
            WorkItem.CC_Service_Agreement_ID__c = '1234567890';
            WorkItem.As_Billed_Amount__c = 1234;
            WorkItem.As_Corrected_Amount__c = 3214;
            WorkItem.As_Billed_Corrected_From__c = date.today();
            WorkItem.As_Billed_Corrected_To__c = date.today();
            WorkItem.Billed_From_Date__c = date.today();
            WorkItem.Billed_To_Date__c = date.today();
            WorkItem.Billed_To_Amount__c = 4545;
            WorkItem.Status = 'Completed';
            WorkItem.Sub_Status__c = 'Completed by Assigned User';
            WorkItem.Create_Customer_Contact_in_CC_B__c = true;
            WorkItem.Root_Cause_Category__c = 'DA/CCA';
        	WorkItem.Root_Cause__c = 'Customer Requested - Rate Change';
            update WorkItem;
            WorkItem = [select Id, Status, Sub_Status__c, Create_Customer_Contact_in_CC_B__c from Case where Id =: WorkItem.Id limit 1];
            system.assertEquals('Completed', WorkItem.Status);
            system.assertEquals('Completed by Assigned User', WorkItem.Sub_Status__c);
            system.assertEquals(true, WorkItem.Create_Customer_Contact_in_CC_B__c);
            rr = [select id, SFDC_Work_Item__c from Related_Records__c where SFDC_Work_Item__c =: WorkItem.Id];
            system.assertEquals(1, rr.size());
            system.assertEquals(WorkItem.Id, rr[0].SFDC_Work_Item__c);
            Test.stopTest();
        }
    }
    /**********************************************************************************************
    * @author       Janella Espiritu
    * @date         07/20/2015
    * @description  Validate Required fields on Creation of Status Times record
    * @version      1.0
    * @revision(s)  
    **********************************************************************************************/
    static testMethod void testCreateStatusTimes(){
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
        //Case WorkItem = [select Id, Status from Case limit 1];
        Case WorkItem = TestUtility.CreateWorkItem('40', 'PSSTL', 'Pending Start', null, '24164', '90000', acc.Id, DASA.Id, true, prem.Id, sp.Id, queueId, recordtypeId); 
        WorkItem.Recreated__c = true;
        List<Status_Times__c> st = new List<Status_Times__c>();
        system.runAs(supervisor){
            WorkItem.OwnerId = CSR.Id;
            insert WorkItem;
            st = [select id, Work_Item__c from Status_Times__c where Work_Item__c =: WorkItem.Id];
            system.assertEquals(1, st.size());
        }
        system.runAs(csr){
            Test.startTest();
            WorkItem = [select Id, Status from Case where Id=: WorkItem.Id limit 1];
            system.assertEquals('Assigned', WorkItem.Status);
            
            WorkItem.Status = 'Being Worked On';
            update WorkItem;
            
            st = [select id, Work_Item__c, Current_Status__c, Last_Status__c from Status_Times__c where Work_Item__c =: WorkItem.Id order by CreatedDate];
            system.assertEquals(2, st.size());
            system.assertEquals('Assigned', st[1].Last_Status__c);
            system.assertEquals('Being Worked On', st[1].Current_Status__c);
            Test.stopTest();
        }
    }
    
    /**********************************************************************************************
    * @author       Janella Espiritu
    * @date         07/20/2015
    * @description  Validate Required fields on Creation of Status Times record
    * @version      1.0
    * @revision(s)  
    **********************************************************************************************/
    static testMethod void testCreateStatusTimes2(){
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
            Test.stopTest();
        }
    }
    
    /**********************************************************************************************
    * @author       Janella Espiritu
    * @date         07/20/2015
    * @description  Validate Required fields on Creation of Customer Contact record
    * @version      1.0
    * @revision(s)  
    **********************************************************************************************/
    static testMethod void testPopulatePostponeCredit(){
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
        Account acc = [select Id, Postpone_Credit_Date__c from Account limit 1];
        Service_Agreement__c DASA = [Select Id from Service_Agreement__c limit 1];
        Premise__c prem = [Select Id from Premise__c limit 1];
        Service_Point__c sp = [Select Id from Service_Point__c limit 1];
        //TestUtility.CreateWorkItem(smSpStatus, workItemType, saStatus, eventDate, msgNumber, msgCategoryNumber, accountId, serviceAgreementId, DACCAIndicator, premiseId, servicePointId, ownerId, recordTypeId)
        Case WorkItem = [select Id, Status from Case limit 1];
        system.runAs(CSR){
            Test.startTest();
			system.assertEquals(date.today(), acc.Postpone_Credit_Date__c);
            WorkItem.OwnerId = CSR.Id;
            WorkItem.Customer_Contact_Class__c = 'Records Dept Note';
            WorkItem.Customer_Contact_Type__c = 'RECORDS';
            WorkItem.SOX_Required_Information__c = 'Service Agreement ID';
            WorkItem.CC_Service_Agreement_ID__c = '1234567890';
            WorkItem.As_Billed_Amount__c = 1234;
            WorkItem.As_Corrected_Amount__c = 3214;
            WorkItem.As_Billed_Corrected_From__c = date.today();
            WorkItem.As_Billed_Corrected_To__c = date.today();
            WorkItem.Billed_From_Date__c = date.today();
            WorkItem.Billed_To_Date__c = date.today();
            WorkItem.Billed_To_Amount__c = 4545;
            WorkItem.Status = 'Completed';
            WorkItem.Sub_Status__c = 'Completed by Assigned User';
            WorkItem.Create_Customer_Contact_in_CC_B__c = true;
            WorkItem.Root_Cause_Category__c = 'DA/CCA';
        	WorkItem.Root_Cause__c = 'Customer Requested - Rate Change';
            WorkItem.Postpone_Credit_Date__c = date.today() + 60;
            WorkItem.Postpone_Credit_if_applicable__c = 'Yes';
            update WorkItem;
            acc = [select Id, Postpone_Credit_Date__c, Postpone_Credit_Date_Sent__c from Account limit 1];
            system.assertEquals(date.today() + 60, acc.Postpone_Credit_Date__c);
            system.assertEquals(false, acc.Postpone_Credit_Date_Sent__c);
            Test.stopTest();
        }
    }
    /**********************************************************************************************
    * @author       Janella Espiritu
    * @date         07/20/2015
    * @description  Validate Required fields on Creation of Customer Contact record
    * @version      1.0
    * @revision(s)  
    **********************************************************************************************/
    static testMethod void testPopulatePostponeCredit2(){
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
        Account acc = [select Id, Postpone_Credit_Date__c from Account limit 1];
        Service_Agreement__c DASA = [Select Id from Service_Agreement__c limit 1];
        Premise__c prem = [Select Id from Premise__c limit 1];
        Service_Point__c sp = [Select Id from Service_Point__c limit 1];
        //TestUtility.CreateWorkItem(smSpStatus, workItemType, saStatus, eventDate, msgNumber, msgCategoryNumber, accountId, serviceAgreementId, DACCAIndicator, premiseId, servicePointId, ownerId, recordTypeId)
        Case WorkItem = [select Id, Status from Case limit 1];
        system.runAs(supervisor){
            Case WorkItem2 = TestUtility.CreateWorkItem('40', 'PSSTL', 'Pending Start', null, '24164', '90000', acc.Id, DASA.Id, true, prem.Id, sp.Id, queueId, recordtypeId); 
        	insert WorkItem2;
            Test.startTest();
            List<Case> updateWorkItems = new List<Case>();
			system.assertEquals(date.today(), acc.Postpone_Credit_Date__c);
            WorkItem.OwnerId = CSR.Id;
            WorkItem.Customer_Contact_Class__c = 'Records Dept Note';
            WorkItem.Customer_Contact_Type__c = 'RECORDS';
            WorkItem.SOX_Required_Information__c = 'Service Agreement ID';
            WorkItem.CC_Service_Agreement_ID__c = '1234567890';
            WorkItem.As_Billed_Amount__c = 1234;
            WorkItem.As_Corrected_Amount__c = 3214;
            WorkItem.As_Billed_Corrected_From__c = date.today();
            WorkItem.As_Billed_Corrected_To__c = date.today();
            WorkItem.Billed_From_Date__c = date.today();
            WorkItem.Billed_To_Date__c = date.today();
            WorkItem.Billed_To_Amount__c = 4545;
            WorkItem.Status = 'Completed';
            WorkItem.Sub_Status__c = 'Completed by Assigned User';
            WorkItem.Create_Customer_Contact_in_CC_B__c = true;
            WorkItem.Root_Cause_Category__c = 'DA/CCA';
        	WorkItem.Root_Cause__c = 'Customer Requested - Rate Change';
            WorkItem.Postpone_Credit_Date__c = date.today() + 60;
            WorkItem.Postpone_Credit_if_applicable__c = 'Yes';
            updateWorkItems.add(WorkItem);
            WorkItem2.Customer_Contact_Class__c = 'Records Dept Note';
            WorkItem2.Customer_Contact_Type__c = 'RECORDS';
            WorkItem2.SOX_Required_Information__c = 'Service Agreement ID';
            WorkItem2.CC_Service_Agreement_ID__c = '1234567890';
            WorkItem2.As_Billed_Amount__c = 1234;
            WorkItem2.As_Corrected_Amount__c = 3214;
            WorkItem2.As_Billed_Corrected_From__c = date.today();
            WorkItem2.As_Billed_Corrected_To__c = date.today();
            WorkItem2.Billed_From_Date__c = date.today();
            WorkItem2.Billed_To_Date__c = date.today();
            WorkItem2.Billed_To_Amount__c = 4545;
            WorkItem2.Status = 'Completed';
            WorkItem2.Sub_Status__c = 'Completed by Assigned User';
            WorkItem2.Create_Customer_Contact_in_CC_B__c = true;
            WorkItem2.Root_Cause_Category__c = 'DA/CCA';
        	WorkItem2.Root_Cause__c = 'Customer Requested - Rate Change';
            WorkItem2.Postpone_Credit_Date__c = date.today() + 65;
            WorkItem2.Postpone_Credit_if_applicable__c = 'Yes';
            WorkItem2.OwnerId = CSR.Id;
            updateWorkItems.add(WorkItem2);
            update updateWorkItems;
            acc = [select Id, Postpone_Credit_Date__c, Postpone_Credit_Date_Sent__c from Account limit 1];
            system.assertEquals(date.today() + 65, acc.Postpone_Credit_Date__c);
            system.assertEquals(false, acc.Postpone_Credit_Date_Sent__c);
            Test.stopTest();
        }
    }
    /**********************************************************************************************
    * @author       Janella Espiritu
    * @date         07/20/2015
    * @description  Validate Required fields on Creation of Customer Contact record
    * @version      1.0
    * @revision(s)  
    **********************************************************************************************/
    static testMethod void testConcatenateAdditionalCustomerComments(){
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
            WorkItem.OwnerId = CSR.Id;
            WorkItem.CC_B_Case_ID__c = '0935271835';
            WorkItem.Additional_Customer_Contact_Comments__c = 'Additional Customer Contact Comments';
            WorkItem.Revenue_Assurance_Account_Number__c = '12345';
            WorkItem.Revenue_Assurance_SA_ID__c = '12345';
            WorkItem.Billed_Reason__c = 'Billed Reason';
            WorkItem.Root_Cause__c = 'Other';
            WorkItem.Root_Cause_Other__c = 'Root Cause Other';
            update WorkItem;
            WorkItem = [select Additional_Customer_Comments_back_end__c, 
                        		LAN_ID__c, 
                        		Work_Item_Type__c, 
                        		CC_B_Case_ID__c, 
                        		CreatedDate, 
                        		Postpone_Credit_Date__c, 
                        		Additional_Customer_Contact_Comments__c, 
                        		CaseNumber, 
                        		Revenue_Assurance_Account_Number__c, 
                        		Revenue_Assurance_SA_ID__c, 
                        		Billed_Reason__c, 
                        		Root_Cause__c, 
                        		Root_Cause_Other__c 
                        from Case where id =: WorkItem.Id];
            system.assert(WorkItem.Additional_Customer_Comments_back_end__c.contains(WorkItem.LAN_ID__c));
            system.assert(WorkItem.Additional_Customer_Comments_back_end__c.contains(WorkItem.Work_Item_Type__c));
            system.assert(WorkItem.Additional_Customer_Comments_back_end__c.contains(WorkItem.CC_B_Case_ID__c));
            system.assert(WorkItem.Additional_Customer_Comments_back_end__c.contains(WorkItem.Additional_Customer_Contact_Comments__c));
            system.assert(WorkItem.Additional_Customer_Comments_back_end__c.contains(WorkItem.CaseNumber));
            system.assert(WorkItem.Additional_Customer_Comments_back_end__c.contains(WorkItem.Revenue_Assurance_Account_Number__c));
            system.assert(WorkItem.Additional_Customer_Comments_back_end__c.contains(WorkItem.Revenue_Assurance_SA_ID__c));
            system.assert(WorkItem.Additional_Customer_Comments_back_end__c.contains(WorkItem.Billed_Reason__c));
            system.assert(WorkItem.Additional_Customer_Comments_back_end__c.contains(WorkItem.Root_Cause__c));
            system.assert(WorkItem.Additional_Customer_Comments_back_end__c.contains(WorkItem.Root_Cause_Other__c));
            Test.stopTest();
        }
    }
    /**********************************************************************************************
    * @author       Janella Espiritu
    * @date         07/20/2015
    * @description  Validate Required fields on Creation of Customer Contact record
    * @version      1.0
    * @revision(s)  
    **********************************************************************************************/
    static testMethod void testValidateMassReassignmentError(){
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
            Test.setCurrentPageReference(new PageReference('/CaseMassAction'));
        	System.currentPageReference().getParameters().put('CaseMassAction','CaseMassAction');
            WorkItem.OwnerId = CSR.Id;
            try{
                update WorkItem;
            }
            catch(Exception e){
               //System.assertEquals('CaseMassAction',String.valueOf(URL.getCurrentRequestUrl()));
               //System.AssertEquals(Label.CSR_Mass_Action_Error_Message, e.getMessage());
               Boolean expectedExceptionThrown =  e.getMessage().contains(Label.CSR_Mass_Action_Error_Message) ? true : false;
               System.AssertEquals(true, expectedExceptionThrown);
            }
            
            Test.stopTest();
        }
    }
    /**********************************************************************************************
    * @author       Janella Espiritu
    * @date         07/20/2015
    * @description  Validate Required fields on Creation of Customer Contact record
    * @version      1.0
    * @revision(s)  
    **********************************************************************************************/
    static testMethod void testassignTheWholeGroup(){
        // Query Queue
        Profile csrProfile = [select id from profile where name='CSR'];
        UserRole csrRole = [Select id from userrole where name='CSR'];
        Profile pbillOpsHead = [select id from profile where name='Billing Ops Head'];
        UserRole rSupervisor = [Select id from userrole where name='Supervisor'];
        Profile intProfile = [select id from profile where name='Integration'];
        UserRole intSupervisor = [Select id from userrole where name='Supervisor'];
        //User admin= TestUtility.createUser(padmin.id,rbillops.id,3); insert admin;
        //User integration = TestUtility.createUser(intProfile.id,intSupervisor.id,3); integration.LAN_ID__c = 'INT1'; insert integration;
        User supervisor= TestUtility.createUser(pbillOpsHead.id,rSupervisor.id,4); supervisor.LAN_ID__c = 'SUP1'; insert supervisor;
        User CSR= TestUtility.createUser(csrProfile.id,csrRole.id,1);  CSR.Supervisor__c = supervisor.Id; CSR.Lan_ID__c = 'CSR1'; insert CSR;
        
        Id queueId = WorkItemAssignmentUtility.getBillingExceptionQueueId();
        Id recordtypeId = WorkItemAssignmentUtility.getCaseBillingExceptionsRecordTypeId();
        Account acc = [select Id from Account where Name ='Account 1'];
        Account acc2 = [select Id from Account where Name ='Account 2'];
        // Create Account
        
        Service_Agreement__c DASA = [Select Id from Service_Agreement__c limit 1];
        Premise__c prem = [Select Id from Premise__c limit 1];
        Service_Point__c sp = [Select Id from Service_Point__c limit 1];
        User_Skill_Rule__c dacca = [select Id from User_Skill_Rule__c where Name = 'DACCA USR'];
        //TestUtility.CreateWorkItem(smSpStatus, workItemType, saStatus, eventDate, msgNumber, msgCategoryNumber, accountId, serviceAgreementId, DACCAIndicator, premiseId, servicePointId, ownerId, recordTypeId)

        system.runAs(supervisor){
            Test.startTest();
            List<Case> wiList = new List<Case>();
			List<Case> updateList = new List<Case>();
            
            wiList = [Select User_Skill_Rule__r.GroupingEnabled__c, IsParent__c, Local_Office__c, AccountId, SFDC_Prem_ID__c, Id, Case_ID__c, User_Skill_Rule__r.Class__c, CaseNumber, User_Skill_Rule__r.Name, ParentId, Status, Priority_Score__c, OwnerId, User_Skill_Rule__r.AssignmentEnabled__c from Case where AccountId IN(:acc.Id) /*and IsParent__c = FALSE*/ limit 3];
            system.assert(wiList.size() > 0);
            for(Case wi : wiList){
                system.assert(wi.OwnerId != CSR.Id);
                wi.OwnerId = CSR.Id;
                updateList.add(wi);
            }
            wiList = [Select User_Skill_Rule__r.GroupingEnabled__c, IsParent__c, Local_Office__c, AccountId, SFDC_Prem_ID__c, Id, Case_ID__c, User_Skill_Rule__r.Class__c, CaseNumber, User_Skill_Rule__r.Name, ParentId, Status, Priority_Score__c, OwnerId, User_Skill_Rule__r.AssignmentEnabled__c from Case where AccountId IN(:acc2.Id) and IsParent__c = FALSE limit 3];
            system.assert(wiList.size() > 0);
            for(Case wi : wiList){
                system.assert(wi.OwnerId != CSR.Id);
                wi.OwnerId = CSR.Id;
                updateList.add(wi);
            }
            wiList = [Select User_Skill_Rule__r.GroupingEnabled__c, IsParent__c, Local_Office__c, AccountId, SFDC_Prem_ID__c, Id, Case_ID__c, User_Skill_Rule__r.Class__c, CaseNumber, User_Skill_Rule__r.Name, ParentId, Status, Priority_Score__c, OwnerId, User_Skill_Rule__r.AssignmentEnabled__c from Case where AccountId IN(:acc.Id,:acc2.Id) and IsParent__c = TRUE limit 3];
            for(Case wi : wiList){
                system.assert(wi.OwnerId != CSR.Id);
                wi.OwnerId = CSR.Id;
                updateList.add(wi);
            }

            update updateList;
            for(Case wi : [select OwnerId from Case]){
                system.assertEquals(CSR.Id, wi.OwnerId);
            }
            Test.stopTest();
        }
    }
    /**********************************************************************************************
    * @author       Janella Espiritu
    * @date         07/20/2015
    * @description  Validate Required fields on Creation of Customer Contact record
    * @version      1.0
    * @revision(s)  
    **********************************************************************************************/
    static testMethod void testassignHoldWorkItems(){
        // Query Queue
        Profile csrProfile = [select id from profile where name='CSR'];
        UserRole csrRole = [Select id from userrole where name='CSR'];
        Profile pbillOpsHead = [select id from profile where name='Billing Ops Head'];
        UserRole rSupervisor = [Select id from userrole where name='Supervisor'];
        Profile intProfile = [select id from profile where name='Integration'];
        UserRole intSupervisor = [Select id from userrole where name='Supervisor'];
        //User admin= TestUtility.createUser(padmin.id,rbillops.id,3); insert admin;
        //User integration = TestUtility.createUser(intProfile.id,intSupervisor.id,3); integration.LAN_ID__c = 'INT1'; insert integration;
        User supervisor= TestUtility.createUser(pbillOpsHead.id,rSupervisor.id,4); supervisor.LAN_ID__c = 'SUP1'; insert supervisor;
        User CSR= TestUtility.createUser(csrProfile.id,csrRole.id,1);  CSR.Supervisor__c = supervisor.Id; CSR.Lan_ID__c = 'CSR1'; insert CSR;
        
        Id queueId = WorkItemAssignmentUtility.getBillingExceptionQueueId();
        Id recordtypeId = WorkItemAssignmentUtility.getCaseBillingExceptionsRecordTypeId();
        Account acc = [select Id from Account where Name ='Account 1'];
        Account acc2 = [select Id from Account where Name ='Account 2'];
        // Create Account
        
        Service_Agreement__c DASA = [Select Id from Service_Agreement__c limit 1];
        Premise__c prem = [Select Id from Premise__c limit 1];
        Service_Point__c sp = [Select Id from Service_Point__c limit 1];
        User_Skill_Rule__c dacca = [select Id from User_Skill_Rule__c where Name = 'DACCA USR'];
        //TestUtility.CreateWorkItem(smSpStatus, workItemType, saStatus, eventDate, msgNumber, msgCategoryNumber, accountId, serviceAgreementId, DACCAIndicator, premiseId, servicePointId, ownerId, recordTypeId)

        system.runAs(supervisor){
            Test.startTest();
            List<Case> wiList = new List<Case>();
			List<Case> updateList = new List<Case>();
            
            wiList = [Select Id, Hold__c, IsParent__c from Case];
            system.assert(wiList.size() > 0);
            for(Case wi : wiList){
                if(wi.IsParent__c){
                    wi.OwnerId = CSR.Id;
				}
                else{
                    system.assert(!wi.Hold__c);
                    wi.Hold__c = TRUE;
                    updateList.add(wi);
                }
                
            }
            update wiList;
            
            for(Case wi : updateList){
                system.assert(wi.Hold__c);
                wi.Hold__c = FALSE;
            }
            update updateList;
            for(Case wi : [select OwnerId from Case]){
                system.assertEquals(CSR.Id, wi.OwnerId);
            }
            Test.stopTest();
        }
    }
    /**********************************************************************************************
    * @author       Janella Espiritu
    * @date         07/20/2015
    * @description  Validate Required fields on Creation of Customer Contact record
    * @version      1.0
    * @revision(s)  
    **********************************************************************************************/
    static testMethod void testHighBillUtility(){
        // Query Queue
        Profile csrProfile = [select id from profile where name='CSR'];
        UserRole csrRole = [Select id from userrole where name='CSR'];
        Profile pbillOpsHead = [select id from profile where name='Billing Ops Head'];
        UserRole rSupervisor = [Select id from userrole where name='Supervisor'];
        Profile intProfile = [select id from profile where name='Integration'];
        UserRole intSupervisor = [Select id from userrole where name='Supervisor'];
        //User admin= TestUtility.createUser(padmin.id,rbillops.id,3); insert admin;
        //User integration = TestUtility.createUser(intProfile.id,intSupervisor.id,3); integration.LAN_ID__c = 'INT1'; insert integration;
        User supervisor= TestUtility.createUser(pbillOpsHead.id,rSupervisor.id,4); supervisor.LAN_ID__c = 'SUP1'; insert supervisor;
        User CSR= TestUtility.createUser(csrProfile.id,csrRole.id,1);  CSR.Supervisor__c = supervisor.Id; CSR.Lan_ID__c = 'CSR1'; insert CSR;
        
        Id queueId = WorkItemAssignmentUtility.getBillingExceptionQueueId();
        Id recordtypeId = WorkItemAssignmentUtility.getCaseBillingExceptionsRecordTypeId();
        Account acc = [select Id from Account where Name ='Account 1'];
        Account acc2 = [select Id from Account where Name ='Account 2'];
        // Create Account
        
        Service_Agreement__c DASA = [Select Id from Service_Agreement__c limit 1];
        Premise__c prem = [Select Id from Premise__c limit 1];
        Service_Point__c sp = [Select Id from Service_Point__c limit 1];
        User_Skill_Rule__c dacca = [select Id from User_Skill_Rule__c where Name = 'DACCA USR'];
        
        Case WorkItem = TestUtility.CreateWorkItem('40', 'High Bill', 'Pending Start', null, '24164', '90000', acc.Id, DASA.Id, true, prem.Id, sp.Id, queueId, recordtypeId); 
        WorkItem.Cur_amt__c = 1000;
        WorkItem.Hi_Bil_Amt__c = 500;
        
        Case WorkItem2 = TestUtility.CreateWorkItem('40', 'High Bill', 'Pending Start', null, '24164', '90000', acc.Id, DASA.Id, true, prem.Id, sp.Id, queueId, recordtypeId); 
        WorkItem2.Cur_amt__c = 4000;
        WorkItem2.Hi_Bil_Amt__c = 500;
		WorkItem2.LAN_ID__c = 'CSR1';
        system.runAs(supervisor){
            Test.startTest();
            insert WorkItem;
            insert WorkItem2;
            Test.stopTest();
            Case wi = [select Status, Sub_Status__c from Case where Id =: WorkItem.Id];
            system.assertEquals('Canceled', wi.Status);
            system.assertEquals('Completed by System', wi.Sub_Status__c);
            Case wi2 = [select Status, Sub_Status__c, Approver_Reviewer__c, Approver_Reviewer_Email__c from Case where Id =: WorkItem2.Id];
            system.assertEquals('Pending', wi2.Status);
            system.assertEquals('High Bill Review', wi2.Sub_Status__c);
            system.assertEquals(supervisor.Id, wi2.Approver_Reviewer__c);
            system.assertEquals(supervisor.Email, wi2.Approver_Reviewer_Email__c);
        }
    }
    
    /**********************************************************************************************
    * @author       Janella Espiritu
    * @date         07/20/2015
    * @description  Validate Required fields on Creation of Customer Contact record
    * @version      1.0
    * @revision(s)  
    **********************************************************************************************/
    static testMethod void testCreateCaseLog(){
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

        Case WorkItem = TestUtility.CreateWorkItem('40', 'Case', 'Pending Start', null, '24164', '90000', acc.Id, DASA.Id, true, prem.Id, sp.Id, queueId, recordtypeId); 
        system.runAs(supervisor){
            WorkItem.OwnerId = CSR.Id;
        	insert WorkItem;    
        }
        system.runAs(CSR){
            Test.startTest();
            List<CC_B_Case_Log__c> rr = [select id, Work_Item__c from CC_B_Case_Log__c];
            system.assertEquals(0, rr.size());
            WorkItem.SOX_Required_Information__c = null;
            WorkItem.Status = 'Completed';
            WorkItem.Sub_Status__c = 'Completed by Assigned User';
            WorkItem.Create_Customer_Contact_in_CC_B__c = false;
            WorkItem.Add_to_CC_B_Case_Log__c = true;
            WorkItem.Root_Cause_Category__c = 'DA/CCA';
        	WorkItem.Root_Cause__c = 'Customer Requested - Rate Change';
            update WorkItem;
            rr = [select id, Work_Item__c from CC_B_Case_Log__c where Work_Item__c =: WorkItem.Id];
            system.assertEquals(1, rr.size());
            system.assertEquals(WorkItem.Id, rr[0].Work_Item__c);
            Test.stopTest();
        }
    }
}