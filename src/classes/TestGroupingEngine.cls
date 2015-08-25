@isTest
public class TestGroupingEngine {

    //test GroupingEngine with GroupType: Hierarchy and GroupBy: AccountId
    static testMethod void testHierarchyAccountId(){
        //create test user to create data
        Profile pfAdmin = [select Id from profile where Name = 'Administrator'];
        UserRole rAdmin = [select Id from userrole where Name = 'Billing Operations'];
        User admin      = TestUtility.createUser(pfAdmin.Id, rAdmin.Id, 1); admin.lan_ID__c = 'ADM1';
        insert admin;
        //create billingExceptions queue
        String billingExceptionsQueueId = WorkItemAssignmentUtility.getBillingExceptionQueueId();
        
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
            system.debug('****SAs: '+saList);
            //create Premise
            Premise__c prem = TestUtility.createPremise();
            insert prem;
            //create SP
            Service_Point__c sp = TestUtility.createServicePoint(prem.Id);
            insert sp;
            //create Grouping Class
            List <Grouping_Class__c> gcList = new List<Grouping_Class__c>();
            Grouping_Class__c DaccaGC = TestUtility.populateGroupingClass('DACCA');gcList.add(DaccaGC);
            Grouping_Class__c NemGC = TestUtility.populateGroupingClass('NEM');gcList.add(NemGC);
            Grouping_Class__c IntGC = TestUtility.populateGroupingClass('Interval');gcList.add(IntGC);
            Grouping_Class__c StGC = TestUtility.populateGroupingClass('Streetlight');gcList.add(StGC);
            Grouping_Class__c AgGC = TestUtility.populateGroupingClass('Agricultural');gcList.add(AgGC);
            Grouping_Class__c BillingGC = TestUtility.populateGroupingClass('Billing 101');gcList.add(BillingGC);
            insert gcList;           
           
            //create Grouping Rules
            List <Grouping_Rules__c> grList = new List<Grouping_Rules__c>();
            Grouping_Rules__c DaccaGR = TestUtility.populateGroupingRules(1, 'Specialized DACCA', 'Hierarchy', DaccaGC.Id, 'AccountId'); grList.add(DaccaGR);
            Grouping_Rules__c NemGR = TestUtility.populateGroupingRules(2, 'Specialized NEM', 'Hierarchy', NemGC.Id, 'AccountId'); grList.add(NemGR);
            Grouping_Rules__c IntGR = TestUtility.populateGroupingRules(3, 'Specialized Interval', 'Hierarchy', IntGC.Id, 'AccountId'); grList.add(IntGR);
            Grouping_Rules__c StGR = TestUtility.populateGroupingRules(4, 'Specialized Streetlight', 'Hierarchy', StGC.Id, 'AccountId');grList.add(StGR);
            Grouping_Rules__c AgGR = TestUtility.populateGroupingRules(5, 'Specialized Agricultural', 'Hierarchy', AgGC.Id, 'AccountId');grList.add(AgGR);
            Grouping_Rules__c BillingGR = TestUtility.populateGroupingRules(6, 'Billing 101', 'Priority', null, 'AccountId'); grList.add(BillingGR);
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
            DaccaUSR.Name = 'DACCA USR'; DaccaUSR.GroupingEnabled__c=TRUE;  usrList.add(DaccaUSR);
            User_Skill_Rule__c NemUSR     = TestUtility.createUserSkillRule(2, 'Retro Commencing', null, null, 'HN-ERES', null, null, null, null, null, null, null, null, NemGC.Id);
            NemUSR.Name = 'NEM USR'; NemUSR.GroupingEnabled__c=TRUE;  usrList.add(NemUSR); 
            User_Skill_Rule__c IntUSR     = TestUtility.createUserSkillRule(3, 'BSEG', null, 'TRUE', null, null, null, null, null, null, null, null, null, IntGC.Id); 
            IntUSR.Name = 'Interval USR'; IntUSR.GroupingEnabled__c=TRUE;  usrList.add(IntUSR);
            User_Skill_Rule__c StUSR      = TestUtility.createUserSkillRule(4, 'QAS8', null, null, 'E-LGHT', null, null, null, null, null, null, null, null, StGC.Id); 
            StUSR.Name = 'Streetlight USR'; StUSR.GroupingEnabled__c=TRUE;  usrList.add(StUSR);
            User_Skill_Rule__c AgUSR      = TestUtility.createUserSkillRule(5, 'Delayed Bills', null, null, 'E-AG', null, null, null, null, null, null, null, null, AgGC.Id); 
            AgUSR.Name = 'Ag USR'; AgUSR.GroupingEnabled__c=TRUE; usrList.add(AgUSR);
            User_Skill_Rule__c BillingUSR = TestUtility.createUserSkillRule(6, 'PSSTL', 'TRUE', null, 'E-RES', null, null, null, null, null, null, null, null, BillingGC.Id); 
            BillingUSR.Name = 'Billing101 USR'; BillingUSR.GroupingEnabled__c=TRUE; usrList.add(BillingUSR);
            insert usrList;
            
            //create WIs
            List<Case> wiList = new List<Case>();   
            //required fields: TestUtility.CreateWorkItem(smSpStatus, workItemType, saStatus, eventDate, msgNumber, msgCategoryNumber, accountId, serviceAgreementId, DACCAIndicator, premiseId, servicePointId, ownerId, recordTypeId)
            Case DaccaWI = TestUtility.CreateWorkItem('30', 'DACCA', 'Active', date.today()-300, '', '', acct.Id, DaccaSa.Id, True, prem.Id, sp.Id, billingExceptionsQueueId, recordTypeId);wiList.add(DaccaWI);
            Case NemWI = TestUtility.CreateWorkItem('40', 'Retro Commencing', 'Active', date.today()-365, '', '', acct.Id, NemSa.Id, False, prem.Id, sp.Id, billingExceptionsQueueId, recordTypeId);wiList.add(NemWI);
            Case IntWI = TestUtility.CreateWorkItem('40', 'BSEG', 'Active', date.today()-265, '', '', acct.Id, IntSa.Id, False, prem.Id, sp.Id, billingExceptionsQueueId, recordTypeId);wiList.add(IntWI);
            Case StWI = TestUtility.CreateWorkItem('30', 'QAS8', 'Active', date.today()-350, '', '', acct.Id, StSa.Id, False, prem.Id, sp.Id, billingExceptionsQueueId, recordTypeId);wiList.add(StWI);
            Case AgWI = TestUtility.CreateWorkItem('20', 'Delayed Bills', 'Active', date.today()-250, '', '', acct.Id, AgSa.Id, False, prem.Id, sp.Id, billingExceptionsQueueId, recordTypeId);wiList.add(AgWI);
            Case BillingWI = TestUtility.CreateWorkItem('30', 'PSSTL', 'Active', date.today()-200, '', '', acct.Id, BillingSa1.Id, False, prem.Id, sp.Id, billingExceptionsQueueId, recordTypeId);wiList.add(BillingWI);            
            insert wiList;
            
            //check queryString
            List<Case> workitemsUSR = [select ParentId, User_Skill_Rule__r.Name, User_Skill_Rule__r.GroupingEnabled__c, OwnerId, Owner.Type, Recreated__c, Reopened__c, Status, AccountId from Case];                    
            List<Case> queryTest = [Select Id, Case_ID__c, User_Skill_Rule__r.Class__c, CaseNumber, User_Skill_Rule__r.Name, ParentId, Status, Priority_Score__c, OwnerId, AccountId from Case 
                                    where 
                                    (AccountId =:acct.Id) 
                                    AND  Status IN('Assigned','Unassigned','Being Worked On','Pending') 
                                    AND User_Skill_Rule__r.GroupingEnabled__c = TRUE 
                                    AND Reopened__c = FALSE AND Recreated__c = FALSE 
                                    AND (Owner.Type = 'User' OR 
                                     OwnerId = '00Go0000000im3yEAA')
                                    ORDER BY Priority_Score__c DESC, CaseNumber ];
            system.debug('***queryTest: '+queryTest);
            for (Case wi : workitemsUSR){                
              	system.debug('***wi USR GroupingEnabled: '+ wi.User_Skill_Rule__r.GroupingEnabled__c);
              	system.debug('***wi USR Name: '+ wi.User_Skill_Rule__r.Name);
                system.debug('***wi Status: '+ wi.Status);
                system.debug('***wi Reopened: '+ wi.Reopened__c);
                system.debug('***wi Recreated: '+ wi.Recreated__c);
                system.debug('***wi OwnerType: '+ wi.Owner.Type);
                system.debug('***wi Owner: '+ wi.OwnerId);
                system.debug('***wi Account: '+ wi.AccountId);
                system.debug('***queryTest parentId: '+wi.ParentId);
            }
            system.assertEquals('00Go0000000im3yEAA', billingExceptionsQueueId);
            //check parentId
            Case testParentId = [select ParentId from Case where Id =: BillingWI.Id];
            system.assertEquals(testParentId.ParentId, DaCcaWI.Id);
        }

    } 
    
 
    
	//test GroupingEngine with GroupType: Hierarchy and GroupBy: PremiseId
    static testMethod void testHierarchyPremiseId(){
        //create test user to create data
        Profile pfAdmin = [select Id from profile where Name = 'Administrator'];
        UserRole rAdmin = [select Id from userrole where Name = 'Billing Operations'];
        User admin      = TestUtility.createUser(pfAdmin.Id, rAdmin.Id, 1); admin.lan_ID__c = 'ADM1';
        insert admin;
        //create billingExceptions queue
        String billingExceptionsQueueId = WorkItemAssignmentUtility.getBillingExceptionQueueId();
        
        System.runAs(admin){
            Id recordtypeId = [select Id from RecordType where Name='Billing Exceptions' and sObjectType = 'Case'].Id;	
            //create account
            Account acct = TestUtility.createAccount(date.today()-60, 'Account1', '0123456789');
            insert acct;
            //create SA
            List<Service_Agreement__c> saList = new List<Service_Agreement__c>();
            Service_Agreement__c smoogSA = TestUtility.createServiceAgreementwithSAType(acct.Id, 'E-RES', '0000000001');  saList.add(smoogSA);
            Service_Agreement__c smoosSA = TestUtility.createServiceAgreementwithSAType(acct.Id, 'HN-ERES', '0000000002'); saList.add(smoosSA);           
            insert saList;
            //create Premise
            Premise__c prem = TestUtility.createPremise();
            insert prem;
            //create SP
            Service_Point__c sp = TestUtility.createServicePoint(prem.Id);
            insert sp;
            
            //create Grouping Class
            List <Grouping_Class__c> gcList = new List<Grouping_Class__c>();
            Grouping_Class__c smoogGC = TestUtility.populateGroupingClass('SM Opt Out - General');
            gcList.add(smoogGC);
            Grouping_Class__c smoosGC = TestUtility.populateGroupingClass('SM Opt Out - Specialized');
            gcList.add(smoosGC);
            insert gcList;           
           
            //create Grouping Rules
            List <Grouping_Rules__c> grList = new List<Grouping_Rules__c>();
            Grouping_Rules__c smoogGR = TestUtility.populateGroupingRules(1, 'SM Opt Out - General', 'Priority', null, 'SFDC_Prem_ID__c'); grList.add(smoogGR);
            Grouping_Rules__c smoosGR = TestUtility.populateGroupingRules(2, 'SM Opt Out - Specialized', 'Hierarchy', smoosGC.Id, 'SFDC_Prem_ID__c'); grList.add(smoosGR);
            insert grList;
            
            //create Related Class
            List<Related_Class__c> rcList = new List<Related_Class__c>();
            Related_Class__c smoogRC1 = TestUtility.relatedClass(smoogGC.Id, smoogGR.Id); rcList.add(smoogRC1);
            Related_Class__c smoogRC2 = TestUtility.relatedClass(smoosGC.Id, smoogGR.Id); rcList.add(smoogRC2);
            insert rcList;
            
            //create GroupingType Custom Setting
            List<GroupingTypes__c> gtList = new List<GroupingTypes__c>();
            GroupingTypes__c hierarchy = TestUtility.createGroupingTypes('Hierarchy','HierarchyImpl'); gtList.add(hierarchy);
            GroupingTypes__c priority = TestUtility.createGroupingTypes('Priority','PriorityImpl'); gtList.add(priority);
            insert gtList;
            
             //create USR records
            List<User_Skill_Rule__c> usrList = new List<User_Skill_Rule__c>();
            //fields required: TestUtility.createUserSkillRule(sortOrder, workItemType, metered, interval, saType, daCCA, msgCategory, msgNumber, maxBilling, DaysLateEvaluator, AgeBucket, CommencingBill, SAStatus, Classc)
            User_Skill_Rule__c smoogUSR   = TestUtility.createUserSkillRule(1, 'SM Opt Out - General', null, null, null, 'TRUE', null, null, null, null, null, null, null, smoogGC.Id); 
            smoogUSR.Name = 'SM Opt Out - General USR'; smoogUSR.GroupingEnabled__c=TRUE;  usrList.add(smoogUSR);
            User_Skill_Rule__c smoosUSR     = TestUtility.createUserSkillRule(2, 'SM Opt Out - Specialized', null, null, 'HN-ERES', null, null, null, null, null, null, null, null, smoosGC.Id);
            smoosUSR.Name = 'SM Opt Out - Specialized USR'; smoosUSR.GroupingEnabled__c=TRUE;  usrList.add(smoosUSR);
            insert usrList;

            //create WIs
            List<Case> wiList = new List<Case>();   
            //field required: TestUtility.CreateWorkItem(smSpStatus, workItemType, saStatus, eventDate, msgNumber, msgCategoryNumber, accountId, serviceAgreementId, DACCAIndicator, premiseId, servicePointId, ownerId, recordTypeId)
            Case smoogWI = TestUtility.CreateWorkItem('30', 'SM Opt Out - General', 'Active', date.today()-300, '', '', acct.Id, smoogSa.Id, True, prem.Id, sp.Id, billingExceptionsQueueId, recordTypeId);wiList.add(smoogWI);
            Case smoosWI = TestUtility.CreateWorkItem('40', 'SM Opt Out - Specialized', 'Active', date.today()-365, '', '', acct.Id, smoosSa.Id, False, prem.Id, sp.Id, billingExceptionsQueueId, recordTypeId);wiList.add(smoosWI);            
            insert wiList;
            
            //check parentId
            Case testParentId = [select ParentId from Case where Id =: smoosWI.Id];
            system.assertEquals(testParentId.ParentId, smoogWI.Id);

        }
    } 

    //test GroupingEngine with GroupType: Hierarchy and GroupBy: OpsAreaCd
        static testMethod void testHierarchyOpsArea(){
        //create test user to create data
        Profile pfAdmin = [select Id from profile where Name = 'Administrator'];
        UserRole rAdmin = [select Id from userrole where Name = 'Billing Operations'];
        User admin      = TestUtility.createUser(pfAdmin.Id, rAdmin.Id, 1); admin.lan_ID__c = 'ADM1';
        insert admin;
        //create billingExceptions queue
        String billingExceptionsQueueId = WorkItemAssignmentUtility.getBillingExceptionQueueId();
        
        System.runAs(admin){
            Id recordtypeId = [select Id from RecordType where Name='Billing Exceptions' and sObjectType = 'Case'].Id;	
            //create account
            Account acct = TestUtility.createAccount(date.today()-60, 'Account1', '0123456789');
            insert acct;
            //create SA
            List<Service_Agreement__c> saList = new List<Service_Agreement__c>();
            Service_Agreement__c qas7SA = TestUtility.createServiceAgreementwithSAType(acct.Id, 'E-RES', '0000000001');  saList.add(qas7SA);
            Service_Agreement__c qas9SA = TestUtility.createServiceAgreementwithSAType(acct.Id, 'HN-ERES', '0000000002'); saList.add(qas9SA);           
            insert saList;
            //create Premise
            Premise__c prem = TestUtility.createPremise();
            insert prem;
            
            //create SP
            Service_Point__c sp = TestUtility.createServicePoint(prem.Id);
            insert sp;
            
            //create Grouping Class
            List <Grouping_Class__c> gcList = new List<Grouping_Class__c>();
            Grouping_Class__c qas7GC = TestUtility.populateGroupingClass('Op Area QAS7');
            gcList.add(qas7GC);
            Grouping_Class__c qas9GC = TestUtility.populateGroupingClass('Op Area QAS9');
            gcList.add(qas9GC);
            insert gcList;
                       
            //create Grouping Rules
            List <Grouping_Rules__c> grList = new List<Grouping_Rules__c>();
            Grouping_Rules__c qas7GR = TestUtility.populateGroupingRules(1, 'Op Area QAS7', 'Priority', null, 'City__c');
            grList.add(qas7GR);
            Grouping_Rules__c qas9GR = TestUtility.populateGroupingRules(2, 'Op Area QAS9', 'Hierachy', qas9GC.Id, 'City__c');
                                                                         //SFDC_SP_ID__r.Op_Area_Cd__c');
            grList.add(qas9GR);
            insert grList;
            
            //create Related Class
            List<Related_Class__c> rcList = new List<Related_Class__c>();
            Related_Class__c RC1 = TestUtility.relatedClass(qas7GC.Id, qas7GR.Id); rcList.add(RC1);
            Related_Class__c RC2 = TestUtility.relatedClass(qas9GC.Id, qas7GR.Id); rcList.add(RC2);
            insert rcList;
           
            //create GroupingType Custom Setting
            List<GroupingTypes__c> gtList = new List<GroupingTypes__c>();
            GroupingTypes__c hierarchy = TestUtility.createGroupingTypes('Hierarchy','HierarchyImpl'); gtList.add(hierarchy);
            GroupingTypes__c priority = TestUtility.createGroupingTypes('Priority','PriorityImpl'); gtList.add(priority);
            insert gtList;
            
            //create USR records
            List<User_Skill_Rule__c> usrList = new List<User_Skill_Rule__c>();
            //field required: TestUtility.createUserSkillRule(sortOrder, workItemType, metered, interval, saType, daCCA, msgCategory, msgNumber, maxBilling, DaysLateEvaluator, AgeBucket, CommencingBill, SAStatus, Classc)
            User_Skill_Rule__c qas7USR   = TestUtility.createUserSkillRule(1, 'Op Area QAS7', null, null, 'E-RES', null, null, null, null, null, null, null, null, qas7GC.Id); 
            qas7USR.Name = 'Op Area QAS7 USR'; qas7USR.GroupingEnabled__c=TRUE;  usrList.add(qas7USR);
            User_Skill_Rule__c qas9USR     = TestUtility.createUserSkillRule(2, 'Op Area QAS9', null, null, 'HN-ERES', null, null, null, null, null, null, null, null, qas9GC.Id);
            qas9USR.Name = 'Op Area QAS9 USR'; qas9USR.GroupingEnabled__c=TRUE;  usrList.add(qas9USR);
            insert usrList;

            //create WIs
            List<Case> wiList = new List<Case>();   
            //TestUtility.CreateWorkItem(smSpStatus, workItemType, saStatus, eventDate, msgNumber, msgCategoryNumber, accountId, serviceAgreementId, DACCAIndicator, premiseId, servicePointId, ownerId, recordTypeId)
            Case qas7WI = TestUtility.CreateWorkItem('30', 'Op Area QAS7', 'Active', date.today()-300, '', '', acct.Id, qas7SA.Id, False, prem.Id, sp.Id, billingExceptionsQueueId, recordTypeId);wiList.add(qas7WI);
            Case qas9WI = TestUtility.CreateWorkItem('40', 'Op Area QAS9', 'Active', date.today()-365, '', '', acct.Id, qas9SA.Id, False, prem.Id, sp.Id, billingExceptionsQueueId, recordTypeId);wiList.add(qas9WI);            
            insert wiList;
            
            //check parentId
            Case testParentId = [select ParentId from Case where Id =: qas9WI.Id];
            system.assertEquals(testParentId.ParentId, qas7WI.Id);
            
        }
        }

        //test GroupingEngine with GroupType: Priority
        static testMethod void testPriority(){
        //create test user to create data
        Profile pfAdmin = [select Id from profile where Name = 'Administrator'];
        UserRole rAdmin = [select Id from userrole where Name = 'Billing Operations'];
        User admin      = TestUtility.createUser(pfAdmin.Id, rAdmin.Id, 1); admin.lan_ID__c = 'ADM1';
        insert admin;
        //create billingExceptions queue
        String billingExceptionsQueueId = WorkItemAssignmentUtility.getBillingExceptionQueueId();
        
        System.runAs(admin){
            Id recordtypeId = [select Id from RecordType where Name='Billing Exceptions' and sObjectType = 'Case'].Id;	
            //create account
            Account acct = TestUtility.createAccount(date.today()-60, 'Account1', '0123456789');
            insert acct;
            //create SA
            List<Service_Agreement__c> saList = new List<Service_Agreement__c>();
            Service_Agreement__c billing1Sa = TestUtility.createServiceAgreementwithSAType(acct.Id, 'E-RES', '0000000001');  saList.add(billing1Sa);
            Service_Agreement__c billing2Sa = TestUtility.createServiceAgreementwithSAType(acct.Id, 'HN-ERES', '0000000002'); saList.add(billing2Sa);           
            insert saList;
            //create Premise
            Premise__c prem = TestUtility.createPremise();
            insert prem;
            
            //create SP
            Service_Point__c sp = TestUtility.createServicePoint(prem.Id);
            insert sp;
            
            //create Grouping Class
            List <Grouping_Class__c> gcList = new List<Grouping_Class__c>();
            Grouping_Class__c billing1GC = TestUtility.populateGroupingClass('Billing101 1');
            gcList.add(billing1GC);
            Grouping_Class__c billing2GC = TestUtility.populateGroupingClass('Billing101 2');
            gcList.add(billing2GC);
            insert gcList;
                       
            //create Grouping Rules
            List <Grouping_Rules__c> grList = new List<Grouping_Rules__c>();
            Grouping_Rules__c billing1GR = TestUtility.populateGroupingRules(1, 'Billing101 1', 'Priority', null, 'AccountId');
            grList.add(billing1GR);
            Grouping_Rules__c billing2GR = TestUtility.populateGroupingRules(2, 'Billing101 2', 'Priority', null, 'AccountId');
            grList.add(billing2GR);
            insert grList;
            
            //create Related Class
            List<Related_Class__c> rcList = new List<Related_Class__c>();
            Related_Class__c RC1 = TestUtility.relatedClass(billing1GC.Id, billing1GR.Id); rcList.add(RC1);
            Related_Class__c RC2 = TestUtility.relatedClass(billing2GC.Id, billing1GR.Id); rcList.add(RC2);
            insert rcList;
           
            //create GroupingType Custom Setting
            List<GroupingTypes__c> gtList = new List<GroupingTypes__c>();
            GroupingTypes__c hierarchy = TestUtility.createGroupingTypes('Hierarchy','HierarchyImpl'); gtList.add(hierarchy);
            GroupingTypes__c priority = TestUtility.createGroupingTypes('Priority','PriorityImpl'); gtList.add(priority);
            insert gtList;
            
            //create USR records
            List<User_Skill_Rule__c> usrList = new List<User_Skill_Rule__c>();
            //field required: TestUtility.createUserSkillRule(sortOrder, workItemType, metered, interval, saType, daCCA, msgCategory, msgNumber, maxBilling, DaysLateEvaluator, AgeBucket, CommencingBill, SAStatus, Classc)
            User_Skill_Rule__c billing1USR   = TestUtility.createUserSkillRule(1, 'Billing101 1', null, null, 'E-RES', null, null, null, null, null, null, null, null, billing1GC.Id); 
            billing1USR.Name = 'Billing101 1 USR'; billing1USR.GroupingEnabled__c=TRUE;  usrList.add(billing1USR);
            User_Skill_Rule__c billing2USR     = TestUtility.createUserSkillRule(2, 'Billing101 2', null, null, 'HN-ERES', null, null, null, null, null, null, null, null, billing2GC.Id);
            billing2USR.Name = 'Billing101 2 USR'; billing2USR.GroupingEnabled__c=TRUE;  usrList.add(billing2USR);
            insert usrList;

            //create WIs
            List<Case> wiList = new List<Case>();   
            //TestUtility.CreateWorkItem(smSpStatus, workItemType, saStatus, eventDate, msgNumber, msgCategoryNumber, accountId, serviceAgreementId, DACCAIndicator, premiseId, servicePointId, ownerId, recordTypeId)
            Case billing1WI = TestUtility.CreateWorkItem('30', 'Billing101 1', 'Active', date.today()-300, '', '', acct.Id, billing1SA.Id, False, prem.Id, sp.Id, billingExceptionsQueueId, recordTypeId);wiList.add(billing1WI);
            Case billing2WI = TestUtility.CreateWorkItem('40', 'Billing101 2', 'Active', date.today()-365, '', '', acct.Id, billing2SA.Id, False, prem.Id, sp.Id, billingExceptionsQueueId, recordTypeId);wiList.add(billing2WI);            
            insert wiList;
            
            //check parentId
            Case testParentId = [select ParentId from Case where Id =: billing2WI.Id];
            system.assertEquals(testParentId.ParentId, billing1WI.Id);
            
        }
        } 


}