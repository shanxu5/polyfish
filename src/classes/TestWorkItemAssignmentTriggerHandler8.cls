/**********************************************************************************************
* @author       Yefim Shuster
* @date         06/01/2015
*
* @version      1.0
*
* @description  This test class tests WorkItemAssignmentTrigger and its 
*               handler class  WorkItemAssignmentTriggerHandler including testing with open Bill Cycle windows
*
* @revision(s)  Original
**********************************************************************************************/
@isTest
public class TestWorkItemAssignmentTriggerHandler8 {

    /**********************************************************************************************
    * @author       Yefim Shuster
    * @date         06/01/2015
    * @description  This is Test Setup method that will create test data used in this test class
    * @version      1.0
    * @revision(s)  
    **********************************************************************************************/
    @testSetup static void setup() {
        
        //create test user to create data
        Profile pfAdmin = [select Id from profile where Name = 'Administrator'];
        UserRole rAdmin = [select Id from userrole where Name = 'Billing Operations'];
        User admin      = TestUtility.createUser(pfAdmin.Id, rAdmin.Id, 1); admin.lan_ID__c = 'ADM1';
        insert admin;
        
        Profile p = [select id from profile where name = 'CSR'];
        UserRole r = [Select id from userrole where name = 'CSR'];
        User testuser = TestUtility.createUser(p.id, r.id, 2); testuser.Lan_ID__c = 'USR2';
        insert testuser;
        
        //create billingExceptions queue
        Id billingExceptionsQueueId = WorkItemAssignmentUtility.getBillingExceptionQueueId();
        
        System.runAs(admin){
            Id recordtypeId = [select Id from RecordType where Name='Billing Exceptions' and sObjectType = 'Case'].Id;  
            
            //create account
            Account acct = TestUtility.createAccount(date.today()-60, 'Account1', '0123456789');
            insert acct;
            
            //create SA
            List<Service_Agreement__c> saList = new List<Service_Agreement__c>();
            Service_Agreement__c DaccaSa       = TestUtility.createServiceAgreementwithSAType(acct.Id, 'E-RES', '0000000001');  saList.add(DaccaSa);
            Service_Agreement__c NemSa         = TestUtility.createServiceAgreementwithSAType(acct.Id, 'HN-ERES', '0000000002'); saList.add(NemSa);
            Service_Agreement__c IntSa         = TestUtility.createServiceAgreementwithSAType(acct.Id, 'HE-RES', '0000000003'); saList.add(IntSa);
            Service_Agreement__c StSa          = TestUtility.createServiceAgreementwithSAType(acct.Id, 'E-LGHT', '0000000004'); saList.add(StSa);
            Service_Agreement__c AgSa          = TestUtility.createServiceAgreementwithSAType(acct.Id, 'E-AG', '0000000005');   saList.add(AgSa);
            Service_Agreement__c BillingSa1    = TestUtility.createServiceAgreementwithSAType(acct.Id, 'E-RES', '0000000006');  saList.add(BillingSa1);
            insert saList;
            
            //create Premise
            Premise__c prem = TestUtility.createPremise();
            insert prem;
            
            //create SP
            Service_Point__c sp = TestUtility.createServicePoint(prem.Id);
            insert sp;
            
            //create Grouping Class
            List <Grouping_Class__c> gcList = new List<Grouping_Class__c>();
            Grouping_Class__c DaccaGC = TestUtility.populateGroupingClass('DACCA');
            gcList.add(DaccaGC);
            Grouping_Class__c NemGC = TestUtility.populateGroupingClass('NEM');
            gcList.add(NemGC);
            Grouping_Class__c IntGC = TestUtility.populateGroupingClass('Interval');
            gcList.add(IntGC);
            Grouping_Class__c StGC = TestUtility.populateGroupingClass('Streetlight');
            gcList.add(StGC);
            Grouping_Class__c AgGC = TestUtility.populateGroupingClass('Agricultural');
            gcList.add(AgGC);
            Grouping_Class__c BillingGC = TestUtility.populateGroupingClass('Billing 101');
            gcList.add(BillingGC);
            insert gcList;           
           
            //create Grouping Rules
            List <Grouping_Rules__c> grList = new List<Grouping_Rules__c>();
            Grouping_Rules__c DaccaGR = TestUtility.populateGroupingRules(1, 'Specialized DACCA', 'Hierarchy', DaccaGC.Id, 'AccountId');
            grList.add(DaccaGR);
            Grouping_Rules__c NemGR = TestUtility.populateGroupingRules(2, 'Specialized NEM', 'Hierarchy', NemGC.Id, 'AccountId');
            grList.add(NemGR);
            Grouping_Rules__c IntGR = TestUtility.populateGroupingRules(3, 'Specialized Interval', 'Hierarchy', IntGC.Id, 'AccountId');
            grList.add(IntGR);
            Grouping_Rules__c StGR = TestUtility.populateGroupingRules(4, 'Specialized Streetlight', 'Hierarchy', StGC.Id, 'AccountId');
            grList.add(StGR);
            Grouping_Rules__c AgGR = TestUtility.populateGroupingRules(5, 'Specialized Agricultural', 'Hierarchy', AgGC.Id, 'AccountId');
            grList.add(AgGR);
            Grouping_Rules__c BillingGR = TestUtility.populateGroupingRules(6, 'Billing 101', 'Priority', null, 'AccountId');
            grList.add(BillingGR);
            insert grList;
            
            //create Related Class
            List<Related_Class__c> rcList = new List<Related_Class__c>();
            Related_Class__c DaccaRC1 = TestUtility.relatedClass(DaccaGC.Id, DaccaGR.Id); rcList.add(DaccaRC1);
            Related_Class__c DaccaRC2 = TestUtility.relatedClass(NemGC.Id, DaccaGR.Id); rcList.add(DaccaRC2);
            Related_Class__c DaccaRC3 = TestUtility.relatedClass(IntGC.Id, DaccaGR.Id); rcList.add(DaccaRC3);
            Related_Class__c DaccaRC4 = TestUtility.relatedClass(StGC.Id, DaccaGR.Id); rcList.add(DaccaRC4);
            Related_Class__c DaccaRC5 = TestUtility.relatedClass(AgGC.Id, DaccaGR.Id); rcList.add(DaccaRC5);
            Related_Class__c DaccaRC6 = TestUtility.relatedClass(BillingGC.Id, DaccaGR.Id); rcList.add(DaccaRC6);
            
            Related_Class__c NemRC1 = TestUtility.relatedClass(NemGC.Id, NemGR.Id); rcList.add(NemRC1);
            Related_Class__c NemRC2 = TestUtility.relatedClass(IntGC.Id, NemGR.Id); rcList.add(NemRC2);
            Related_Class__c NemRC3 = TestUtility.relatedClass(AgGC.Id, NemGR.Id); rcList.add(NemRC3);
            Related_Class__c NemRC4 = TestUtility.relatedClass(BillingGC.Id, NemGR.Id); rcList.add(NemRC4);
            
            Related_Class__c IntRC1 = TestUtility.relatedClass(IntGC.Id, IntGR.Id); rcList.add(IntRC1);
            Related_Class__c IntRC2 = TestUtility.relatedClass(AgGC.Id, IntGR.Id); rcList.add(IntRC2);
            Related_Class__c IntRC3 = TestUtility.relatedClass(BillingGC.Id, IntGR.Id); rcList.add(IntRC3);
            
            Related_Class__c StRC1 = TestUtility.relatedClass(StGC.Id, StGR.Id); rcList.add(StRC1);
            Related_Class__c StRC2 = TestUtility.relatedClass(BillingGC.Id, StGR.Id); rcList.add(StRC2);
            
            Related_Class__c AgRC1 = TestUtility.relatedClass(AgGC.Id, AgGR.Id); rcList.add(AgRC1);
            Related_Class__c AgRC2 = TestUtility.relatedClass(BillingGC.Id, AgGR.Id); rcList.add(AgRC2);
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
            User_Skill_Rule__c DaccaUSR   = TestUtility.createUserSkillRule(1, 'DACCA', null, null, null, 'TRUE', null, null, null, null, null, null, null, DaccaGC.Id); 
            DaccaUSR.Name = 'DACCA USR'; DaccaUSR.GroupingEnabled__c=TRUE;
            DaccaUSR.AssignmentEnabled__c = true;
            usrList.add(DaccaUSR);
            
            User_Skill_Rule__c fastSlowUSR = TestUtility.createUserSkillRule(1, 'Fast/Slow Meter Adj - Gas', null, null, null, 'TRUE', null, null, null, null, null, null, null, DaccaGC.Id); 
            fastSlowUSR.Name = 'Fast/Slow Meter Adj - Gas'; fastSlowUSR.GroupingEnabled__c=TRUE;
            fastSlowUSR.AssignmentEnabled__c = true;
            usrList.add(fastSlowUSR);
            User_Skill_Rule__c NemUSR     = TestUtility.createUserSkillRule(2, 'Retro Commencing', null, null, 'HN-ERES', null, null, null, null, null, null, null, null, NemGC.Id);
            NemUSR.Name = 'NEM USR'; NemUSR.GroupingEnabled__c=TRUE;
            NemUSR.AssignmentEnabled__c = true;
            usrList.add(NemUSR);
            User_Skill_Rule__c IntUSR     = TestUtility.createUserSkillRule(3, 'BSEG', null, 'TRUE', null, null, null, null, null, null, null, null, null, IntGC.Id); 
            IntUSR.Name = 'Interval USR'; IntUSR.GroupingEnabled__c=TRUE;
            IntUSR.AssignmentEnabled__c = true;
            usrList.add(IntUSR);
            User_Skill_Rule__c StUSR      = TestUtility.createUserSkillRule(4, 'QAS8', null, null, 'E-LGHT', null, null, null, null, null, null, null, null, StGC.Id); 
            StUSR.Name = 'Streetlight USR'; StUSR.GroupingEnabled__c=TRUE;
            StUSR.AssignmentEnabled__c = true;
            usrList.add(StUSR);
            User_Skill_Rule__c AgUSR      = TestUtility.createUserSkillRule(5, 'Delayed Bills', null, null, 'E-AG', null, null, null, null, null, null, null, null, AgGC.Id); 
            AgUSR.Name = 'Ag USR'; AgUSR.GroupingEnabled__c=TRUE;
            AgUSR.AssignmentEnabled__c = true;
            usrList.add(AgUSR);
            User_Skill_Rule__c BillingUSR = TestUtility.createUserSkillRule(6, 'PSSTL', 'TRUE', null, 'E-RES', null, null, null, null, null, null, null, null, BillingGC.Id); 
            BillingUSR.Name = 'Billing101 USR'; BillingUSR.GroupingEnabled__c=TRUE;
            BillingUSR.AssignmentEnabled__c = true;
            usrList.add(BillingUSR);
            insert usrList;
            
            // Create Bill Cycle windows A to E
            Bill_Cycle_Window__c bcw;
            List<Bill_Cycle_Window__c> bcwList = new List<Bill_Cycle_Window__c>();
            String primary_bill_cycle = 'A';
            Date start_date = Date.today() - 5;
            Date end_date = Date.today() + 5;
            Id notAssignedRecTypeId = WorkItemAssignmentUtility.getBillCycleWindowNotAssignedRecordTypeId();
            Id defaultRecTypeId = WorkItemAssignmentUtility.getBillCycleWindowDefaultRecordTypeId();
            
            for (Integer i = 0; i < 5; i++){
              primary_bill_cycle = String.fromCharArray(new List<Integer>{primary_bill_cycle.charAt(0) + i});
              bcw = TestUtility.createBillCycleWindowForBillCycle(primary_bill_cycle, start_date, end_date, defaultRecTypeId);
              bcwList.add(bcw);
              start_date = end_date + 1;
              end_date = start_date + 5;
            }
            bcwList[0].User_Skill_Rule__c = DaccaUSR.Id;
            bcwList[0].RecordTypeId = notAssignedRecTypeId;
            bcwList[1].User_Skill_Rule__c = IntUSR.Id;
            bcwList[1].RecordTypeId = notAssignedRecTypeId;
            bcwList[2].User_Skill_Rule__c = AgUSR.Id;
            bcwList[2].RecordTypeId = notAssignedRecTypeId;
            bcwList[3].User_Skill_Rule__c = NemUSR.Id;
            bcwList[3].RecordTypeId = notAssignedRecTypeId;
            bcwList[4].User_Skill_Rule__c = StUSR.Id;
            bcwList[4].RecordTypeId = notAssignedRecTypeId;
            
            insert bcwList;
            
            //create WIs
            List<Case> wiList = new List<Case>();   
            //TestUtility.CreateWorkItem(smSpStatus, workItemType, saStatus, eventDate, msgNumber, msgCategoryNumber, accountId, serviceAgreementId, DACCAIndicator, premiseId, servicePointId, ownerId, recordTypeId)
            Case DaccaWI = TestUtility.CreateWorkItem('30', 'DACCA', 'Active', date.today()-300, '', '', acct.Id, DaccaSa.Id, True, prem.Id, sp.Id, billingExceptionsQueueId, recordTypeId);
            DaccaWI.Bill_Cycle__c = bcwList[0].Primary_Bill_Cycle__c;
            wiList.add(DaccaWI);
            Case NemWI = TestUtility.CreateWorkItem('40', 'Retro Commencing', 'Active', date.today()-365, '', '', acct.Id, NemSa.Id, False, prem.Id, sp.Id, billingExceptionsQueueId, recordTypeId);
            NemWI.Bill_Cycle__c = bcwList[3].Primary_Bill_Cycle__c;
            wiList.add(NemWI);
            Case IntWI = TestUtility.CreateWorkItem('40', 'BSEG', 'Active', date.today()-265, '', '', acct.Id, IntSa.Id, False, prem.Id, sp.Id, billingExceptionsQueueId, recordTypeId);
            IntWI.Bill_Cycle__c = bcwList[1].Primary_Bill_Cycle__c;
            wiList.add(IntWI);
            Case StWI = TestUtility.CreateWorkItem('30', 'QAS8', 'Active', date.today()-350, '', '', acct.Id, StSa.Id, False, prem.Id, sp.Id, billingExceptionsQueueId, recordTypeId);
            StWI.Bill_Cycle__c = bcwList[4].Primary_Bill_Cycle__c;
            wiList.add(StWI);
            Case AgWI = TestUtility.CreateWorkItem('20', 'Delayed Bills', 'Active', date.today()-250, '', '', acct.Id, AgSa.Id, False, prem.Id, sp.Id, billingExceptionsQueueId, recordTypeId);
            AgWI.Bill_Cycle__c = bcwList[2].Primary_Bill_Cycle__c;
            wiList.add(AgWI);
            Case BillingWI = TestUtility.CreateWorkItem('30', 'PSSTL', 'Active', date.today()-200, '', '', acct.Id, BillingSa1.Id, False, prem.Id, sp.Id, billingExceptionsQueueId, recordTypeId);
            BillingWI.Bill_Cycle__c = bcwList[0].Primary_Bill_Cycle__c;
            wiList.add(BillingWI);            
            insert wiList;
            
            // Create Work Item Assignment record  
            Work_Item_Assignment__c wia = TestUtility.createWorkItemAssignment(testUser.Id, false);
            insert wia;
            
            // Create User Skill
            List<User_Skill__c> usList = new List<User_Skill__c>();
            User_Skill__c userSkill1 = TestUtility.createUserSkill(IntUSR.id, wia.id, wia);
            usList.add(userSkill1);
            
            User_Skill__c userSkill2 = TestUtility.createUserSkill(BillingUSR.id, wia.id, wia);
            usList.add(userSkill2);
            
            User_Skill__c userSkill3 = TestUtility.createUserSkill(DaccaUSR.id, wia.id, wia);
            usList.add(userSkill3);
            
            insert usList;
       }
    }


    static testMethod void updateWebformRequest() {
        Webform_Master_Request__c wfm = new Webform_Master_Request__c();

        wfm.Requestor_s_Email__c = 'myemail@pge.com';
        wfm.Requestor_s_Name__c = 'myname';
        wfm.Total_Completed_Work_Items__c = 0;
        insert wfm;
        
        RecordType rec = [Select id from RecordType where DeveloperName = 'Mailbox' and sObjecttype = 'Case'];
        // Create Test data for Work Item record
        List < Case > wiList = new List < Case > ();
        for (Integer i = 1; i <= 20; i++)

        {
            Case wi = new Case();
            wi.Webform_Request_Number__c = 'wfr' + i;
            wi.status = 'Unassigned' + i;
            wi.Webform_Request_Number__c = wfm.Name;
            wi.RecordTypeId = rec.id ;
            wi.origin = 'Email' + i;
            wi.CC_Person_ID__c = '1234' + i;
            wi.Customer_Contact_ID__c = '23455' + i;
            wi.Customer_Contact_Class__c = 'Direct Access' + i;
            wi.Customer_Contact_Type__c = 'Direct Access Inquiry/Note' + i;
            wi.SOX_Required_Information__c = 'Service Agreement ID' + i;
            wi.CC_Service_Agreement_ID__c = '123' + i;
            wi.CC_Account_ID__c = '987' + i;
            wi.CC_Service_Point_ID__c = '7898' + i;
            wi.CC_Premise_ID__c = '890' + i;
            wi.CC_Premise_Address__c = 'premise address' + i;
            wiList.add(wi);

        }

        insert wiList;
        

        Test.startTest();

        List < Case > updatedwiList = new List < Case > ();
        for (Case wi: wiList) {
            wi.status = 'Completed';
            wi.CC_Person_ID__c = 'test';
            wi.Customer_Contact_Class__c = 'Billing Inquiry Note';
            wi.Customer_Contact_Type__c = 'Billing Inquiry Note';
            updatedwiList.add(wi);

        }
        update updatedwiList;

        //System.assertEquals(wfm.Total_Completed_Work_Items__c, 20);

        Test.stopTest();



    }

}