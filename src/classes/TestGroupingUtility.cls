@isTest
public class TestGroupingUtility {
    /*
	static testMethod void testGroupingEnabled() {
        Profile p = [select id from profile where name='CSR'];
        UserRole r = [Select id from userrole where name='CSR'];
        User CSR= TestUtility.createUser(p.id,r.id,1); CSR.LAN_ID__C = 'CSR1'; insert CSR;
        Profile padmin = [select id from profile where name='Administrator'];
        UserRole rbillops = [Select id from userrole where name='Billing Operations'];
        User admin= TestUtility.createUser(padmin.id,rbillops.id,2); admin.LAN_ID__C = 'ADM1'; //insert admin;
        System.runAs(admin){
            TurnOnAssignmentandGrouping__c turnOnBSEG = TestUtility.createTurnOnAssignmentandGrouping('BSEG', true, true); insert turnOnBSEG;
            Set<String> grpEnabled = GroupingUtility.groupingEnabled();
            System.assert(grpEnabled.contains('BSEG'));
        }
    }
    static testMethod void testSortUserSkills() {
        Profile p = [select id from profile where name='CSR'];
        UserRole r = [Select id from userrole where name='CSR'];
        User CSR= TestUtility.createUser(p.id,r.id,1); CSR.LAN_ID__C = 'CSR1'; insert CSR;
        Profile padmin = [select id from profile where name='Administrator'];
        UserRole rbillops = [Select id from userrole where name='Billing Operations'];
        User admin= TestUtility.createUser(padmin.id,rbillops.id,2); admin.LAN_ID__C = 'ADM1'; //insert admin;
        System.runAs(admin){
            List<Work_Item_Assignment__c> wlist = new List<Work_Item_Assignment__c>();
            Work_Item_Assignment__c wia= new Work_Item_Assignment__c(user__r=CSR,WI_Assigned__c=10,Limit__c=20 ); insert wia; wlist.add(wia);
            List<Work_Item_Assignment__c> wiaList = GroupingUtility.sortUserSkillsList(wlist, 'ASC', 'Load_Score__c');
            system.assertEquals(wia.Id, wiaList[0].Id);   
        }
    }
    static testMethod void testSortCaseList() {
        Profile p = [select id from profile where name='CSR'];
        UserRole r = [Select id from userrole where name='CSR'];
        User CSR= TestUtility.createUser(p.id,r.id,1); CSR.LAN_ID__C = 'CSR1'; insert CSR;
        Profile padmin = [select id from profile where name='Administrator'];
        UserRole rbillops = [Select id from userrole where name='Billing Operations'];
        User admin= TestUtility.createUser(padmin.id,rbillops.id,2); admin.LAN_ID__C = 'ADM1'; //insert admin;
        System.runAs(admin){
            Id queueId = [select Id, Name from Group where Name = 'Billing Exceptions' and Type = 'Queue'].Id;
        	Id recordtypeId = [select Id from RecordType where Name='Billing Exceptions' and sObjectType = 'Case'].Id;	
            
            // Create Account
            Account acc = TestUtility.createAccount(date.today() - 60, 'Account 1', '0007652348'); insert acc;
            Account acc2 = TestUtility.createAccount(date.today() - 60, 'Account 2', '0007652387'); insert acc2;
            // Create Service Agreement
            Service_Agreement__c sa = TestUtility.createServiceAgreement(acc.Id); insert sa;
            // Create Premise
            Premise__c prem = TestUtility.createPremise(); insert prem;
            // Create Service Point
            Service_Point__c sp = TestUtility.createServicePoint(prem.Id); insert sp;
            
            // Create Work Items
            List<Case> workItems = new List<Case>();
            // Group 1
            Case WorkItem1 = TestUtility.CreateWorkItem('40', 'BSEG', '', date.today() - 50, '', '', acc.Id, sa.Id, true, prem.Id, sp.Id, queueId, recordtypeId); 
            workItem1.OwnerId = admin.Id;
            workItems.add(WorkItem1); //parent
            Case WorkItem2 = TestUtility.CreateWorkItem('40', 'Retro Commencing', '', date.today() - 51, '', '', acc.Id, sa.Id, false, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem2);
            Case WorkItem3 = TestUtility.CreateWorkItem('40', 'PSSTL', '', date.today() - 52, '', '', acc.Id, sa.Id, false, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem3);
            insert workItems;
            
            workItems = GroupingUtility.sortCaseList(workItems, 'ASC', 'Priority_Score__c');
            system.assertEquals(WorkItem1.Id, workItems[0].Id);
            
            Case parentCase = GroupingUtility.retrieveParentCase(workItems, queueId);
        }
    }
    static testMethod void testGroupingDA() {
    	Profile p = [select id from profile where name='CSR'];
        UserRole r = [Select id from userrole where name='CSR'];
        User CSR= TestUtility.createUser(p.id,r.id,1); CSR.LAN_ID__C = 'CSR1'; insert CSR;
        Profile padmin = [select id from profile where name='Administrator'];
        UserRole rbillops = [Select id from userrole where name='Billing Operations'];
        User admin= TestUtility.createUser(padmin.id,rbillops.id,2); admin.LAN_ID__C = 'ADM1'; //insert admin;
        System.runAs(admin){
            Id queueId = [select Id, Name from Group where Name = 'Billing Exceptions' and Type = 'Queue'].Id;
        	Id recordtypeId = [select Id from RecordType where Name='Billing Exceptions' and sObjectType = 'Case'].Id;	
            
            List<User_Skill_Rule__c> usrList = new List<User_Skill_Rule__c>();
            User_Skill_Rule__c DAusr = TestUtility.createUserSkillRule(1, 'PSSTL', null, null, null, 'True', null, null, null, null, null, null, null); DAusr.Name = 'DA CCA PSSTL'; usrList.add(DAusr);
            User_Skill_Rule__c NEMusr = TestUtility.createUserSkillRule(2, 'PSSTL', null, null, 'HN-ERES', null, null, null, null, null, null, null, null); NEMusr.Name = 'NEM PSSTL'; usrList.add(NEMusr);
            User_Skill_Rule__c SLusr = TestUtility.createUserSkillRule(2, 'PSSTL', null, null, 'E-LGHT', null, null, null, null, null, null, null, null); SLusr.Name = 'Streetlight'; usrList.add(SLusr);
            User_Skill_Rule__c AGusr = TestUtility.createUserSkillRule(2, 'PSSTL', null, null, 'E-AG', null, null, null, null, null, null, null, null); AGusr.Name = 'Agricultural'; usrList.add(AGusr);

            insert usrList;
            
            // Create Account
            Account acc = TestUtility.createAccount(date.today() - 60, 'Account 1', '0007652348'); insert acc;
            // Create Service Agreement
            Service_Agreement__c DASA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'E-RES', '1234567890'); insert DASA;
            Service_Agreement__c IntSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'HE-RES', '1234567890'); insert IntSA;
            Service_Agreement__c NEMSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'HN-RES', '1234567890'); insert NEMSA;
            Service_Agreement__c AGSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'E-AG', '1234567890'); insert AGSA;
            Service_Agreement__c OTSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'G-RES', '1234567890'); insert OTSA;
            Service_Agreement__c SLSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'E-LGHT', '234567890'); insert SLSA;
            // Create Premise
            Premise__c prem = TestUtility.createPremise(); insert prem;
            // Create Service Point
            Service_Point__c sp = TestUtility.createServicePoint(prem.Id); insert sp;
            
            // Create Work Items
            List<Case> workItems = new List<Case>();
            // Group 1
            Case WorkItem1 = TestUtility.CreateWorkItem('40', 'BSEG', '', date.today() - 50, '', '', acc.Id, DASA.Id, true, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem1); //parent
            Case WorkItem2 = TestUtility.CreateWorkItem('40', 'Retro Commencing', '', date.today() - 51, '', '', acc.Id, IntSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem2);
            Case WorkItem3 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 52, '', '', acc.Id, NEMSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem3);
            Case WorkItem4 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 52, '', '', acc.Id, AGSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem4);
            Case WorkItem5 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 52, '', '', acc.Id, OTSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem5);
            Case WorkItem6 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 52, '', '', acc.Id, SLSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem6);
            insert workItems;
            workitems = [select Id, SA_Type__c, Interval__c, DA_CCA_IND__c, OwnerId, ParentId, AccountId, Status, User_Skill_Rule__r.Name, Priority_Score__c from Case];
            Set<Id> caseIds = new Set<Id>();
            for(Case c : workItems){
                caseIds.add(c.Id);
            }
            GroupingUtility.groupWorkItems(workItems, queueId, new Map<Id, List<User_Skill__c>>(), caseIds);
            update workItems;
            system.assertEquals(WorkItem1.Id, [select ParentId from Case where Id =: WorkItem2.Id].ParentId);
        }
    }
    static testMethod void testGroupingDA2() {
    	Profile p = [select id from profile where name='CSR'];
        UserRole r = [Select id from userrole where name='CSR'];
        User CSR= TestUtility.createUser(p.id,r.id,1); CSR.LAN_ID__C = 'CSR1';insert CSR;
        Profile padmin = [select id from profile where name='Administrator'];
        UserRole rbillops = [Select id from userrole where name='Billing Operations'];
        User admin= TestUtility.createUser(padmin.id,rbillops.id,2); admin.LAN_ID__C = 'ADM1';//insert admin;
        System.runAs(admin){
            Id queueId = [select Id, Name from Group where Name = 'Billing Exceptions' and Type = 'Queue'].Id;
        	Id recordtypeId = [select Id from RecordType where Name='Billing Exceptions' and sObjectType = 'Case'].Id;	
            
            List<User_Skill_Rule__c> usrList = new List<User_Skill_Rule__c>();
            User_Skill_Rule__c DAusr = TestUtility.createUserSkillRule(1, 'PSSTL', null, null, null, 'True', null, null, null, null, null, null, null); DAusr.Name = 'DA CCA PSSTL'; usrList.add(DAusr);
            User_Skill_Rule__c NEMusr = TestUtility.createUserSkillRule(2, 'PSSTL', null, null, 'HN-ERES', null, null, null, null, null, null, null, null); NEMusr.Name = 'NEM PSSTL'; usrList.add(NEMusr);
            User_Skill_Rule__c SLusr = TestUtility.createUserSkillRule(2, 'PSSTL', null, null, 'E-LGHT', null, null, null, null, null, null, null, null); SLusr.Name = 'Streetlight'; usrList.add(SLusr);
            User_Skill_Rule__c AGusr = TestUtility.createUserSkillRule(2, 'PSSTL', null, null, 'E-AG', null, null, null, null, null, null, null, null); AGusr.Name = 'Agricultural'; usrList.add(AGusr);

            insert usrList;
            
            // Create Account
            Account acc = TestUtility.createAccount(date.today() - 60, 'Account 1', '0007652348'); insert acc;
            // Create Service Agreement
            Service_Agreement__c DASA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'E-RES', '1234567890'); insert DASA;
            Service_Agreement__c IntSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'HE-RES', '1234567890'); insert IntSA;
            Service_Agreement__c NEMSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'HN-RES', '1234567890'); insert NEMSA;
            Service_Agreement__c AGSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'E-AG', '1234567890'); insert AGSA;
            Service_Agreement__c OTSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'G-RES', '1234567890'); insert OTSA;
            Service_Agreement__c SLSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'E-LGHT', '234567890'); insert SLSA;
            // Create Premise
            Premise__c prem = TestUtility.createPremise(); insert prem;
            // Create Service Point
            Service_Point__c sp = TestUtility.createServicePoint(prem.Id); insert sp;
            Case WorkItem3 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 52, '', '', acc.Id, NEMSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); WorkItem3.OwnerId = CSR.Id; insert WorkItem3;
            // Create Work Items
            List<Case> workItems = new List<Case>();
            // Group 1
            Case WorkItem1 = TestUtility.CreateWorkItem('40', 'BSEG', '', date.today() - 50, '', '', acc.Id, DASA.Id, true, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem1); //parent
            Case WorkItem2 = TestUtility.CreateWorkItem('40', 'Retro Commencing', '', date.today() - 51, '', '', acc.Id, IntSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem2);
            Case WorkItem4 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 52, '', '', acc.Id, AGSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem4);
            Case WorkItem5 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 52, '', '', acc.Id, OTSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem5);
            Case WorkItem6 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 52, '', '', acc.Id, SLSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem6);
            insert workItems;
            workitems = [select Id, SA_Type__c, Interval__c, DA_CCA_IND__c, OwnerId, ParentId, AccountId, Status, User_Skill_Rule__r.Name, Priority_Score__c from Case];
            Set<Id> caseIds = new Set<Id>();
            for(Case c : workItems){
                if(c.SA_Type__c != DASA.SA_Type_CD__c){
                    caseIds.add(c.Id);
                }
            }
            GroupingUtility.groupWorkItems(workItems, queueId, new Map<Id, List<User_Skill__c>>(), caseIds);
            update workItems;
            system.assertEquals(WorkItem3.Id, [select ParentId from Case where Id =: WorkItem2.Id].ParentId);
        }
    }
    static testMethod void testGroupingDA3() {
    	Profile p = [select id from profile where name='CSR'];
        UserRole r = [Select id from userrole where name='CSR'];
        User CSR= TestUtility.createUser(p.id,r.id,1); CSR.LAN_ID__C = 'CSR1';insert CSR;
        Profile padmin = [select id from profile where name='Administrator'];
        UserRole rbillops = [Select id from userrole where name='Billing Operations'];
        User admin= TestUtility.createUser(padmin.id,rbillops.id,2); admin.LAN_ID__C = 'ADM1';//insert admin;
        System.runAs(admin){
            Id queueId = [select Id, Name from Group where Name = 'Billing Exceptions' and Type = 'Queue'].Id;
        	Id recordtypeId = [select Id from RecordType where Name='Billing Exceptions' and sObjectType = 'Case'].Id;	
            
            List<User_Skill_Rule__c> usrList = new List<User_Skill_Rule__c>();
            User_Skill_Rule__c DAusr = TestUtility.createUserSkillRule(1, 'PSSTL', null, null, null, 'True', null, null, null, null, null, null, null); DAusr.Name = 'DA CCA PSSTL'; usrList.add(DAusr);
            User_Skill_Rule__c NEMusr = TestUtility.createUserSkillRule(2, 'PSSTL', null, null, 'HN-ERES', null, null, null, null, null, null, null, null); NEMusr.Name = 'NEM PSSTL'; usrList.add(NEMusr);
            User_Skill_Rule__c SLusr = TestUtility.createUserSkillRule(2, 'PSSTL', null, null, 'E-LGHT', null, null, null, null, null, null, null, null); SLusr.Name = 'Streetlight'; usrList.add(SLusr);
            User_Skill_Rule__c AGusr = TestUtility.createUserSkillRule(2, 'PSSTL', null, null, 'E-AG', null, null, null, null, null, null, null, null); AGusr.Name = 'Agricultural'; usrList.add(AGusr);

            insert usrList;
            
            // Create Account
            Account acc = TestUtility.createAccount(date.today() - 60, 'Account 1', '0007652348'); insert acc;
            // Create Service Agreement
            Service_Agreement__c DASA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'E-RES', '1234567890'); insert DASA;
            Service_Agreement__c IntSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'HE-RES', '1234567890'); insert IntSA;
            Service_Agreement__c NEMSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'HN-RES', '1234567890'); insert NEMSA;
            Service_Agreement__c AGSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'E-AG', '1234567890'); insert AGSA;
            Service_Agreement__c OTSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'G-RES', '1234567890'); insert OTSA;
            Service_Agreement__c SLSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'E-LGHT', '234567890'); insert SLSA;
            // Create Premise
            Premise__c prem = TestUtility.createPremise(); insert prem;
            // Create Service Point
            Service_Point__c sp = TestUtility.createServicePoint(prem.Id); insert sp;
            Case WorkItem3 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 52, '', '', acc.Id, NEMSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); insert WorkItem3;
            // Create Work Items
            List<Case> workItems = new List<Case>();
            // Group 1
            Case WorkItem1 = TestUtility.CreateWorkItem('40', 'BSEG', '', date.today() - 50, '', '', acc.Id, DASA.Id, true, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem1); //parent
            Case WorkItem2 = TestUtility.CreateWorkItem('40', 'Retro Commencing', '', date.today() - 51, '', '', acc.Id, IntSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem2);
            Case WorkItem4 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 52, '', '', acc.Id, AGSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem4);
            Case WorkItem5 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 52, '', '', acc.Id, OTSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem5);
            Case WorkItem6 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 52, '', '', acc.Id, SLSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem6);
            insert workItems;
            workitems = [select Id, SA_Type__c, Interval__c, DA_CCA_IND__c, OwnerId, ParentId, AccountId, Status, User_Skill_Rule__r.Name, Priority_Score__c from Case];
            Set<Id> caseIds = new Set<Id>();
            for(Case c : workItems){
                //if(c.SA_Type__c != DASA.SA_Type_CD__c){
                    caseIds.add(c.Id);
                //}
            }
            GroupingUtility.groupWorkItems(workItems, queueId, new Map<Id, List<User_Skill__c>>(), caseIds);
            update workItems;
            system.assertEquals(WorkItem1.Id, [select ParentId from Case where Id =: WorkItem2.Id].ParentId);
        }
    }
    static testMethod void testGroupingDA4() {
    	Profile p = [select id from profile where name='CSR'];
        UserRole r = [Select id from userrole where name='CSR'];
        User CSR= TestUtility.createUser(p.id,r.id,1); CSR.LAN_ID__C = 'CSR1'; insert CSR;
        Profile padmin = [select id from profile where name='Administrator'];
        UserRole rbillops = [Select id from userrole where name='Billing Operations'];
        User admin= TestUtility.createUser(padmin.id,rbillops.id,2); admin.LAN_ID__C = 'ADM1'; //insert admin;
        System.runAs(admin){
            Id queueId = [select Id, Name from Group where Name = 'Billing Exceptions' and Type = 'Queue'].Id;
        	Id recordtypeId = [select Id from RecordType where Name='Billing Exceptions' and sObjectType = 'Case'].Id;	
            
            List<User_Skill_Rule__c> usrList = new List<User_Skill_Rule__c>();
            User_Skill_Rule__c DAusr = TestUtility.createUserSkillRule(1, 'PSSTL', null, null, null, 'True', null, null, null, null, null, null, null); DAusr.Name = 'DA CCA PSSTL'; usrList.add(DAusr);
            User_Skill_Rule__c NEMusr = TestUtility.createUserSkillRule(2, 'PSSTL', null, null, 'HN-ERES', null, null, null, null, null, null, null, null); NEMusr.Name = 'NEM PSSTL'; usrList.add(NEMusr);
            User_Skill_Rule__c SLusr = TestUtility.createUserSkillRule(2, 'PSSTL', null, null, 'E-LGHT', null, null, null, null, null, null, null, null); SLusr.Name = 'Streetlight'; usrList.add(SLusr);
            User_Skill_Rule__c AGusr = TestUtility.createUserSkillRule(2, 'PSSTL', null, null, 'E-AG', null, null, null, null, null, null, null, null); AGusr.Name = 'Agricultural'; usrList.add(AGusr);

            insert usrList;
            
            // Create Account
            Account acc = TestUtility.createAccount(date.today() - 60, 'Account 1', '0007652348'); insert acc;
            // Create Service Agreement
            Service_Agreement__c DASA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'E-RES', '1234567890'); insert DASA;
            Service_Agreement__c IntSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'HE-RES', '1234567890'); insert IntSA;
            Service_Agreement__c NEMSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'HN-RES', '1234567890'); insert NEMSA;
            Service_Agreement__c AGSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'E-AG', '1234567890'); insert AGSA;
            Service_Agreement__c OTSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'G-RES', '1234567890'); insert OTSA;
            Service_Agreement__c SLSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'E-LGHT', '234567890'); insert SLSA;
            // Create Premise
            Premise__c prem = TestUtility.createPremise(); insert prem;
            // Create Service Point
            Service_Point__c sp = TestUtility.createServicePoint(prem.Id); insert sp;
            Case WorkItem3 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 52, '', '', acc.Id, IntSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); WorkItem3.OwnerId = CSR.Id; insert WorkItem3;
            // Create Work Items
            List<Case> workItems = new List<Case>();
            // Group 1
            Case WorkItem1 = TestUtility.CreateWorkItem('40', 'BSEG', '', date.today() - 50, '', '', acc.Id, DASA.Id, true, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem1); //parent
            Case WorkItem4 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 52, '', '', acc.Id, AGSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem4);
            Case WorkItem5 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 52, '', '', acc.Id, OTSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem5);
            Case WorkItem6 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 52, '', '', acc.Id, SLSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem6);
            insert workItems;
            workitems = [select Id, SA_Type__c, Interval__c, DA_CCA_IND__c, OwnerId, ParentId, AccountId, Status, User_Skill_Rule__r.Name, Priority_Score__c from Case];
            Set<Id> caseIds = new Set<Id>();
            for(Case c : workItems){
                if(c.SA_Type__c != DASA.SA_Type_CD__c){
                    caseIds.add(c.Id);
                }
            }
            GroupingUtility.groupWorkItems(workItems, queueId, new Map<Id, List<User_Skill__c>>(), caseIds);
            update workItems;
            system.assertEquals(WorkItem3.Id, [select ParentId from Case where Id =: WorkItem4.Id].ParentId);
        }
    }
    static testMethod void testGroupingDA5() {
    	Profile p = [select id from profile where name='CSR'];
        UserRole r = [Select id from userrole where name='CSR'];
        User CSR= TestUtility.createUser(p.id,r.id,1); CSR.LAN_ID__C = 'CSR1'; insert CSR;
        Profile padmin = [select id from profile where name='Administrator'];
        UserRole rbillops = [Select id from userrole where name='Billing Operations'];
        User admin= TestUtility.createUser(padmin.id,rbillops.id,2); admin.LAN_ID__C = 'ADM1'; //insert admin;
        System.runAs(admin){
            Id queueId = [select Id, Name from Group where Name = 'Billing Exceptions' and Type = 'Queue'].Id;
        	Id recordtypeId = [select Id from RecordType where Name='Billing Exceptions' and sObjectType = 'Case'].Id;	
            
            List<User_Skill_Rule__c> usrList = new List<User_Skill_Rule__c>();
            User_Skill_Rule__c DAusr = TestUtility.createUserSkillRule(1, 'PSSTL', null, null, null, 'True', null, null, null, null, null, null, null); DAusr.Name = 'DA CCA PSSTL'; usrList.add(DAusr);
            User_Skill_Rule__c NEMusr = TestUtility.createUserSkillRule(2, 'PSSTL', null, null, 'HN-ERES', null, null, null, null, null, null, null, null); NEMusr.Name = 'NEM PSSTL'; usrList.add(NEMusr);
            User_Skill_Rule__c SLusr = TestUtility.createUserSkillRule(2, 'PSSTL', null, null, 'E-LGHT', null, null, null, null, null, null, null, null); SLusr.Name = 'Streetlight'; usrList.add(SLusr);
            User_Skill_Rule__c AGusr = TestUtility.createUserSkillRule(2, 'PSSTL', null, null, 'E-AG', null, null, null, null, null, null, null, null); AGusr.Name = 'Agricultural'; usrList.add(AGusr);

            insert usrList;
            
            // Create Account
            Account acc = TestUtility.createAccount(date.today() - 60, 'Account 1', '0007652348'); insert acc;
            // Create Service Agreement
            Service_Agreement__c DASA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'E-RES', '1234567890'); insert DASA;
            Service_Agreement__c IntSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'HE-RES', '1234567890'); insert IntSA;
            Service_Agreement__c NEMSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'HN-RES', '1234567890'); insert NEMSA;
            Service_Agreement__c AGSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'E-AG', '1234567890'); insert AGSA;
            Service_Agreement__c OTSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'G-RES', '1234567890'); insert OTSA;
            Service_Agreement__c SLSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'E-LGHT', '234567890'); insert SLSA;
            // Create Premise
            Premise__c prem = TestUtility.createPremise(); insert prem;
            // Create Service Point
            Service_Point__c sp = TestUtility.createServicePoint(prem.Id); insert sp;
            Case WorkItem3 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 52, '', '', acc.Id, IntSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); insert WorkItem3;
            // Create Work Items
            List<Case> workItems = new List<Case>();
            // Group 1
            Case WorkItem1 = TestUtility.CreateWorkItem('40', 'BSEG', '', date.today() - 50, '', '', acc.Id, DASA.Id, true, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem1); //parent
            Case WorkItem4 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 52, '', '', acc.Id, AGSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem4);
            Case WorkItem5 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 52, '', '', acc.Id, OTSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem5);
            Case WorkItem6 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 52, '', '', acc.Id, SLSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem6);
            insert workItems;
            workitems = [select Id, SA_Type__c, Interval__c, DA_CCA_IND__c, OwnerId, ParentId, AccountId, Status, User_Skill_Rule__r.Name, Priority_Score__c from Case];
            Set<Id> caseIds = new Set<Id>();
            for(Case c : workItems){
                if(c.SA_Type__c != DASA.SA_Type_CD__c){
                    caseIds.add(c.Id);
                }
            }
            GroupingUtility.groupWorkItems(workItems, queueId, new Map<Id, List<User_Skill__c>>(), caseIds);
            update workItems;
            system.assertEquals(WorkItem1.Id, [select ParentId from Case where Id =: WorkItem4.Id].ParentId);
        }
    }
    static testMethod void testGroupingDA6() {
    	Profile p = [select id from profile where name='CSR'];
        UserRole r = [Select id from userrole where name='CSR'];
        User CSR= TestUtility.createUser(p.id,r.id,1); CSR.LAN_ID__C = 'CSR1'; insert CSR;
        Profile padmin = [select id from profile where name='Administrator'];
        UserRole rbillops = [Select id from userrole where name='Billing Operations'];
        User admin= TestUtility.createUser(padmin.id,rbillops.id,2); admin.LAN_ID__C = 'ADM1'; //insert admin;
        System.runAs(admin){
            Id queueId = [select Id, Name from Group where Name = 'Billing Exceptions' and Type = 'Queue'].Id;
        	Id recordtypeId = [select Id from RecordType where Name='Billing Exceptions' and sObjectType = 'Case'].Id;	
            
            List<User_Skill_Rule__c> usrList = new List<User_Skill_Rule__c>();
            User_Skill_Rule__c DAusr = TestUtility.createUserSkillRule(1, 'PSSTL', null, null, null, 'True', null, null, null, null, null, null, null); DAusr.Name = 'DA CCA PSSTL'; usrList.add(DAusr);
            User_Skill_Rule__c NEMusr = TestUtility.createUserSkillRule(2, 'PSSTL', null, null, 'HN-ERES', null, null, null, null, null, null, null, null); NEMusr.Name = 'NEM PSSTL'; usrList.add(NEMusr);
            User_Skill_Rule__c SLusr = TestUtility.createUserSkillRule(2, 'PSSTL', null, null, 'E-LGHT', null, null, null, null, null, null, null, null); SLusr.Name = 'Streetlight'; usrList.add(SLusr);
            User_Skill_Rule__c AGusr = TestUtility.createUserSkillRule(2, 'PSSTL', null, null, 'E-AG', null, null, null, null, null, null, null, null); AGusr.Name = 'Agricultural'; usrList.add(AGusr);

            insert usrList;
            
            // Create Account
            Account acc = TestUtility.createAccount(date.today() - 60, 'Account 1', '0007652348'); insert acc;
            // Create Service Agreement
            Service_Agreement__c DASA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'E-RES', '1234567890'); insert DASA;
            Service_Agreement__c IntSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'HE-RES', '1234567890'); insert IntSA;
            Service_Agreement__c NEMSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'HN-RES', '1234567890'); insert NEMSA;
            Service_Agreement__c AGSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'E-AG', '1234567890'); insert AGSA;
            Service_Agreement__c OTSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'G-RES', '1234567890'); insert OTSA;
            Service_Agreement__c SLSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'E-LGHT', '234567890'); insert SLSA;
            // Create Premise
            Premise__c prem = TestUtility.createPremise(); insert prem;
            // Create Service Point
            Service_Point__c sp = TestUtility.createServicePoint(prem.Id); insert sp;
            Case WorkItem3 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 52, '', '', acc.Id, IntSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); insert WorkItem3;
            Case WorkItem4 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 52, '', '', acc.Id, AGSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); WorkItem4.OwnerId = CSR.Id; insert WorkItem4;
            // Create Work Items
            List<Case> workItems = new List<Case>();
            // Group 1
            Case WorkItem1 = TestUtility.CreateWorkItem('40', 'BSEG', '', date.today() - 50, '', '', acc.Id, DASA.Id, true, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem1); //parent
            //Case WorkItem4 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 52, '', '', acc.Id, AGSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem4);
            Case WorkItem5 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 52, '', '', acc.Id, OTSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem5);
            Case WorkItem6 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 52, '', '', acc.Id, SLSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem6);
            insert workItems;
            workitems = [select Id, SA_Type__c, Interval__c, DA_CCA_IND__c, OwnerId, ParentId, AccountId, Status, User_Skill_Rule__r.Name, Priority_Score__c from Case];
            Set<Id> caseIds = new Set<Id>();
            for(Case c : workItems){
                //if(c.SA_Type__c != DASA.SA_Type_CD__c){
                    caseIds.add(c.Id);
                //}
            }
            GroupingUtility.groupWorkItems(workItems, queueId, new Map<Id, List<User_Skill__c>>(), caseIds);
            update workItems;
            system.assertEquals(WorkItem1.Id, [select ParentId from Case where Id =: WorkItem5.Id].ParentId);
        }
    }
    static testMethod void testGroupingDA7() {
    	Profile p = [select id from profile where name='CSR'];
        UserRole r = [Select id from userrole where name='CSR'];
        User CSR= TestUtility.createUser(p.id,r.id,1); CSR.LAN_ID__C = 'CSR1'; insert CSR;
        Profile padmin = [select id from profile where name='Administrator'];
        UserRole rbillops = [Select id from userrole where name='Billing Operations'];
        User admin= TestUtility.createUser(padmin.id,rbillops.id,2); admin.LAN_ID__C = 'ADM1'; //insert admin;
        System.runAs(admin){
            Id queueId = [select Id, Name from Group where Name = 'Billing Exceptions' and Type = 'Queue'].Id;
        	Id recordtypeId = [select Id from RecordType where Name='Billing Exceptions' and sObjectType = 'Case'].Id;	
            
            List<User_Skill_Rule__c> usrList = new List<User_Skill_Rule__c>();
            User_Skill_Rule__c DAusr = TestUtility.createUserSkillRule(1, 'PSSTL', null, null, null, 'True', null, null, null, null, null, null, null); DAusr.Name = 'DA CCA PSSTL'; usrList.add(DAusr);
            User_Skill_Rule__c NEMusr = TestUtility.createUserSkillRule(2, 'PSSTL', null, null, 'HN-ERES', null, null, null, null, null, null, null, null); NEMusr.Name = 'NEM PSSTL'; usrList.add(NEMusr);
            User_Skill_Rule__c SLusr = TestUtility.createUserSkillRule(2, 'PSSTL', null, null, 'E-LGHT', null, null, null, null, null, null, null, null); SLusr.Name = 'Streetlight'; usrList.add(SLusr);
            User_Skill_Rule__c AGusr = TestUtility.createUserSkillRule(2, 'PSSTL', null, null, 'E-AG', null, null, null, null, null, null, null, null); AGusr.Name = 'Agricultural'; usrList.add(AGusr);

            insert usrList;
            
            // Create Account
            Account acc = TestUtility.createAccount(date.today() - 60, 'Account 1', '0007652348'); insert acc;
            // Create Service Agreement
            Service_Agreement__c DASA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'E-RES', '1234567890'); insert DASA;
            Service_Agreement__c IntSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'HE-RES', '1234567890'); insert IntSA;
            Service_Agreement__c NEMSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'HN-RES', '1234567890'); insert NEMSA;
            Service_Agreement__c AGSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'E-AG', '1234567890'); insert AGSA;
            Service_Agreement__c OTSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'G-RES', '1234567890'); insert OTSA;
            Service_Agreement__c SLSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'E-LGHT', '234567890'); insert SLSA;
            // Create Premise
            Premise__c prem = TestUtility.createPremise(); insert prem;
            // Create Service Point
            Service_Point__c sp = TestUtility.createServicePoint(prem.Id); insert sp;
            Case WorkItem3 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 52, '', '', acc.Id, IntSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); insert WorkItem3;
            Case WorkItem4 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 52, '', '', acc.Id, OTSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); WorkItem4.OwnerId = CSR.Id; insert WorkItem4;
            // Create Work Items
            List<Case> workItems = new List<Case>();
            // Group 1
            Case WorkItem1 = TestUtility.CreateWorkItem('40', 'BSEG', '', date.today() - 50, '', '', acc.Id, DASA.Id, true, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem1); //parent
            //Case WorkItem4 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 52, '', '', acc.Id, AGSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem4);
            //Case WorkItem5 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 52, '', '', acc.Id, OTSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem5);
            Case WorkItem6 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 52, '', '', acc.Id, SLSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem6);
            insert workItems;
            workitems = [select Id, SA_Type__c, Interval__c, DA_CCA_IND__c, OwnerId, ParentId, AccountId, Status, User_Skill_Rule__r.Name, Priority_Score__c from Case];
            Set<Id> caseIds = new Set<Id>();
            for(Case c : workItems){
                if(c.SA_Type__c != DASA.SA_Type_CD__c){
                    caseIds.add(c.Id);
                }
            }
            GroupingUtility.groupWorkItems(workItems, queueId, new Map<Id, List<User_Skill__c>>(), caseIds);
            update workItems;
            system.assertEquals(WorkItem1.Id, [select ParentId from Case where Id =: WorkItem6.Id].ParentId);
        }
    }
    static testMethod void testGroupingDA8() {
    	Profile p = [select id from profile where name='CSR'];
        UserRole r = [Select id from userrole where name='CSR'];
        User CSR= TestUtility.createUser(p.id,r.id,1); CSR.LAN_ID__C = 'CSR1'; insert CSR;
        Profile padmin = [select id from profile where name='Administrator'];
        UserRole rbillops = [Select id from userrole where name='Billing Operations'];
        User admin= TestUtility.createUser(padmin.id,rbillops.id,2); admin.LAN_ID__C = 'ADM1'; //insert admin;
        System.runAs(admin){
            Id queueId = [select Id, Name from Group where Name = 'Billing Exceptions' and Type = 'Queue'].Id;
        	Id recordtypeId = [select Id from RecordType where Name='Billing Exceptions' and sObjectType = 'Case'].Id;	
            
            List<User_Skill_Rule__c> usrList = new List<User_Skill_Rule__c>();
            User_Skill_Rule__c DAusr = TestUtility.createUserSkillRule(1, 'PSSTL', null, null, null, 'True', null, null, null, null, null, null, null); DAusr.Name = 'DA CCA PSSTL'; usrList.add(DAusr);
            User_Skill_Rule__c NEMusr = TestUtility.createUserSkillRule(2, 'PSSTL', null, null, 'HN-ERES', null, null, null, null, null, null, null, null); NEMusr.Name = 'NEM PSSTL'; usrList.add(NEMusr);
            User_Skill_Rule__c SLusr = TestUtility.createUserSkillRule(2, 'PSSTL', null, null, 'E-LGHT', null, null, null, null, null, null, null, null); SLusr.Name = 'Streetlight'; usrList.add(SLusr);
            User_Skill_Rule__c AGusr = TestUtility.createUserSkillRule(2, 'PSSTL', null, null, 'E-AG', null, null, null, null, null, null, null, null); AGusr.Name = 'Agricultural'; usrList.add(AGusr);

            insert usrList;
            
            // Create Account
            Account acc = TestUtility.createAccount(date.today() - 60, 'Account 1', '0007652348'); insert acc;
            // Create Service Agreement
            Service_Agreement__c DASA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'E-RES', '1234567890'); insert DASA;
            Service_Agreement__c IntSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'HE-RES', '1234567890'); insert IntSA;
            Service_Agreement__c NEMSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'HN-RES', '1234567890'); insert NEMSA;
            Service_Agreement__c AGSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'E-AG', '1234567890'); insert AGSA;
            Service_Agreement__c OTSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'G-RES', '1234567890'); insert OTSA;
            Service_Agreement__c SLSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'E-LGHT', '234567890'); insert SLSA;
            // Create Premise
            Premise__c prem = TestUtility.createPremise(); insert prem;
            // Create Service Point
            Service_Point__c sp = TestUtility.createServicePoint(prem.Id); insert sp;
            Case WorkItem3 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 52, '', '', acc.Id, IntSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); insert WorkItem3;
            Case WorkItem4 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 52, '', '', acc.Id, OTSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); insert WorkItem4;
            // Create Work Items
            List<Case> workItems = new List<Case>();
            // Group 1
            Case WorkItem1 = TestUtility.CreateWorkItem('40', 'BSEG', '', date.today() - 50, '', '', acc.Id, DASA.Id, true, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem1); //parent
            //Case WorkItem4 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 52, '', '', acc.Id, AGSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem4);
            //Case WorkItem5 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 52, '', '', acc.Id, OTSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem5);
            Case WorkItem6 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 52, '', '', acc.Id, SLSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem6);
            insert workItems;
            workitems = [select Id, SA_Type__c, Interval__c, DA_CCA_IND__c, OwnerId, ParentId, AccountId, Status, User_Skill_Rule__r.Name, Priority_Score__c from Case];
            Set<Id> caseIds = new Set<Id>();
            for(Case c : workItems){
                if(c.SA_Type__c != DASA.SA_Type_CD__c){
                    caseIds.add(c.Id);
                }
            }
            GroupingUtility.groupWorkItems(workItems, queueId, new Map<Id, List<User_Skill__c>>(), caseIds);
            update workItems;
            system.assertEquals(WorkItem1.Id, [select ParentId from Case where Id =: WorkItem6.Id].ParentId);
        }
    }
    static testMethod void testGroupingDA9() {
    	Profile p = [select id from profile where name='CSR'];
        UserRole r = [Select id from userrole where name='CSR'];
        User CSR= TestUtility.createUser(p.id,r.id,1); CSR.LAN_ID__C = 'CSR1'; insert CSR;
        Profile padmin = [select id from profile where name='Administrator'];
        UserRole rbillops = [Select id from userrole where name='Billing Operations'];
        User admin= TestUtility.createUser(padmin.id,rbillops.id,2); admin.LAN_ID__C = 'ADM1'; //insert admin;
        System.runAs(admin){
            Id queueId = [select Id, Name from Group where Name = 'Billing Exceptions' and Type = 'Queue'].Id;
        	Id recordtypeId = [select Id from RecordType where Name='Billing Exceptions' and sObjectType = 'Case'].Id;	
            
            List<User_Skill_Rule__c> usrList = new List<User_Skill_Rule__c>();
            User_Skill_Rule__c DAusr = TestUtility.createUserSkillRule(1, 'PSSTL', null, null, null, 'True', null, null, null, null, null, null, null); DAusr.Name = 'DA CCA PSSTL'; usrList.add(DAusr);
            User_Skill_Rule__c NEMusr = TestUtility.createUserSkillRule(2, 'PSSTL', null, null, 'HN-ERES', null, null, null, null, null, null, null, null); NEMusr.Name = 'NEM PSSTL'; usrList.add(NEMusr);
            User_Skill_Rule__c SLusr = TestUtility.createUserSkillRule(2, 'PSSTL', null, null, 'E-LGHT', null, null, null, null, null, null, null, null); SLusr.Name = 'Streetlight'; usrList.add(SLusr);
            User_Skill_Rule__c AGusr = TestUtility.createUserSkillRule(2, 'PSSTL', null, null, 'E-AG', null, null, null, null, null, null, null, null); AGusr.Name = 'Agricultural'; usrList.add(AGusr);

            insert usrList;
            
            // Create Account
            Account acc = TestUtility.createAccount(date.today() - 60, 'Account 1', '0007652348'); insert acc;
            // Create Service Agreement
            Service_Agreement__c DASA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'E-RES', '1234567890'); insert DASA;
            Service_Agreement__c IntSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'HE-RES', '1234567890'); insert IntSA;
            Service_Agreement__c NEMSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'HN-RES', '1234567890'); insert NEMSA;
            Service_Agreement__c AGSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'E-AG', '1234567890'); insert AGSA;
            Service_Agreement__c OTSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'G-RES', '1234567890'); insert OTSA;
            Service_Agreement__c SLSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'E-LGHT', '234567890'); insert SLSA;
            // Create Premise
            Premise__c prem = TestUtility.createPremise(); insert prem;
            // Create Service Point
            Service_Point__c sp = TestUtility.createServicePoint(prem.Id); insert sp;
            Case WorkItem4 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 52, '', '', acc.Id, SLSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); WorkItem4.OwnerId = CSR.Id; insert WorkItem4;
            // Create Work Items
            List<Case> workItems = new List<Case>();
            // Group 1
            Case WorkItem1 = TestUtility.CreateWorkItem('40', 'BSEG', '', date.today() - 50, '', '', acc.Id, DASA.Id, true, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem1);
            insert workItems;
            workitems = [select Id, SA_Type__c, Interval__c, DA_CCA_IND__c, OwnerId, ParentId, AccountId, Status, User_Skill_Rule__r.Name, Priority_Score__c from Case];
            Set<Id> caseIds = new Set<Id>();
            for(Case c : workItems){
               // if(c.SA_Type__c != DASA.SA_Type_CD__c){
                    caseIds.add(c.Id);
               // }
            }
            GroupingUtility.groupWorkItems(workItems, queueId, new Map<Id, List<User_Skill__c>>(), caseIds);
            update workItems;
            system.assertEquals(null, [select ParentId from Case where Id =: WorkItem4.Id].ParentId);
            system.assertEquals(null, [select ParentId from Case where Id =: WorkItem1.Id].ParentId);
        }
    }
	static testMethod void testGroupingNEM() {
    	Profile p = [select id from profile where name='CSR'];
        UserRole r = [Select id from userrole where name='CSR'];
        User CSR= TestUtility.createUser(p.id,r.id,1); CSR.LAN_ID__C = 'CSR1'; insert CSR;
        Profile padmin = [select id from profile where name='Administrator'];
        UserRole rbillops = [Select id from userrole where name='Billing Operations'];
        User admin= TestUtility.createUser(padmin.id,rbillops.id,2); admin.LAN_ID__C = 'ADM1'; //insert admin;
        System.runAs(admin){
            Id queueId = [select Id, Name from Group where Name = 'Billing Exceptions' and Type = 'Queue'].Id;
        	Id recordtypeId = [select Id from RecordType where Name='Billing Exceptions' and sObjectType = 'Case'].Id;	
            
            List<User_Skill_Rule__c> usrList = new List<User_Skill_Rule__c>();
            User_Skill_Rule__c DAusr = TestUtility.createUserSkillRule(1, 'PSSTL', null, null, null, 'True', null, null, null, null, null, null, null); DAusr.Name = 'DA CCA PSSTL'; usrList.add(DAusr);
            User_Skill_Rule__c NEMusr = TestUtility.createUserSkillRule(2, 'PSSTL', null, null, 'HN-ERES', null, null, null, null, null, null, null, null); NEMusr.Name = 'NEM PSSTL'; usrList.add(NEMusr);
            User_Skill_Rule__c SLusr = TestUtility.createUserSkillRule(2, 'PSSTL', null, null, 'E-LGHT', null, null, null, null, null, null, null, null); SLusr.Name = 'Streetlight'; usrList.add(SLusr);
            User_Skill_Rule__c AGusr = TestUtility.createUserSkillRule(2, 'PSSTL', null, null, 'E-AG', null, null, null, null, null, null, null, null); AGusr.Name = 'Agricultural'; usrList.add(AGusr);

            insert usrList;
            
            // Create Account
            Account acc = TestUtility.createAccount(date.today() - 60, 'Account 1', '0007652348'); insert acc;
            // Create Service Agreement
            Service_Agreement__c DASA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'E-RES', '1234567890'); insert DASA;
            Service_Agreement__c IntSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'HE-RES', '1234567890'); insert IntSA;
            Service_Agreement__c NEMSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'HN-RES', '1234567890'); insert NEMSA;
            Service_Agreement__c AGSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'E-AG', '1234567890'); insert AGSA;
            Service_Agreement__c OTSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'G-RES', '1234567890'); insert OTSA;
            Service_Agreement__c SLSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'E-LGHT', '234567890'); insert SLSA;
            // Create Premise
            Premise__c prem = TestUtility.createPremise(); insert prem;
            // Create Service Point
            Service_Point__c sp = TestUtility.createServicePoint(prem.Id); insert sp;
            
            // Create Work Items
            List<Case> workItems = new List<Case>();
            // Group 1
            Case WorkItem2 = TestUtility.CreateWorkItem('40', 'Retro Commencing', '', date.today() - 51, '', '', acc.Id, IntSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem2);
            Case WorkItem3 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 52, '', '', acc.Id, NEMSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem3);
            Case WorkItem4 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 52, '', '', acc.Id, AGSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem4);
            Case WorkItem5 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 52, '', '', acc.Id, OTSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem5);
            Case WorkItem6 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 52, '', '', acc.Id, SLSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem6);
            insert workItems;
            workitems = [select Id, SA_Type__c, Interval__c, DA_CCA_IND__c, OwnerId, ParentId, AccountId, Status, User_Skill_Rule__r.Name, Priority_Score__c from Case];
            Set<Id> caseIds = new Set<Id>();
            for(Case c : workItems){
                caseIds.add(c.Id);
            }
            GroupingUtility.groupWorkItems(workItems, queueId, new Map<Id, List<User_Skill__c>>(), caseIds);
            update workItems;
            system.assertEquals(WorkItem3.Id, [select ParentId from Case where Id =: WorkItem4.Id].ParentId);
        }
    }
    static testMethod void testGroupingNEM2() {
    	Profile p = [select id from profile where name='CSR'];
        UserRole r = [Select id from userrole where name='CSR'];
        User CSR= TestUtility.createUser(p.id,r.id,1); CSR.LAN_ID__C = 'CSR1'; insert CSR;
        Profile padmin = [select id from profile where name='Administrator'];
        UserRole rbillops = [Select id from userrole where name='Billing Operations'];
        User admin= TestUtility.createUser(padmin.id,rbillops.id,2); admin.LAN_ID__C = 'ADM1'; //insert admin;
        System.runAs(admin){
            Id queueId = [select Id, Name from Group where Name = 'Billing Exceptions' and Type = 'Queue'].Id;
        	Id recordtypeId = [select Id from RecordType where Name='Billing Exceptions' and sObjectType = 'Case'].Id;	
            
            List<User_Skill_Rule__c> usrList = new List<User_Skill_Rule__c>();
            User_Skill_Rule__c DAusr = TestUtility.createUserSkillRule(1, 'PSSTL', null, null, null, 'True', null, null, null, null, null, null, null); DAusr.Name = 'DA CCA PSSTL'; usrList.add(DAusr);
            User_Skill_Rule__c NEMusr = TestUtility.createUserSkillRule(2, 'PSSTL', null, null, 'HN-ERES', null, null, null, null, null, null, null, null); NEMusr.Name = 'NEM PSSTL'; usrList.add(NEMusr);
            User_Skill_Rule__c SLusr = TestUtility.createUserSkillRule(2, 'PSSTL', null, null, 'E-LGHT', null, null, null, null, null, null, null, null); SLusr.Name = 'Streetlight'; usrList.add(SLusr);
            User_Skill_Rule__c AGusr = TestUtility.createUserSkillRule(2, 'PSSTL', null, null, 'E-AG', null, null, null, null, null, null, null, null); AGusr.Name = 'Agricultural'; usrList.add(AGusr);

            insert usrList;
            
            // Create Account
            Account acc = TestUtility.createAccount(date.today() - 60, 'Account 1', '0007652348'); insert acc;
            // Create Service Agreement
            Service_Agreement__c IntSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'HE-RES', '1234567890'); insert IntSA;
            Service_Agreement__c NEMSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'HN-RES', '1234567890'); insert NEMSA;
            Service_Agreement__c AGSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'E-AG', '1234567890'); insert AGSA;
            Service_Agreement__c OTSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'G-RES', '1234567890'); insert OTSA;
            Service_Agreement__c SLSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'E-LGHT', '234567890'); insert SLSA;
            // Create Premise
            Premise__c prem = TestUtility.createPremise(); insert prem;
            // Create Service Point
            Service_Point__c sp = TestUtility.createServicePoint(prem.Id); insert sp;
            
            // Create Work Items
            Case WorkItem2 = TestUtility.CreateWorkItem('40', 'Retro Commencing', '', date.today() - 51, '', '', acc.Id, IntSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId);  WorkItem2.OwnerId = CSR.Id; insert WorkItem2;
            List<Case> workItems = new List<Case>();
            // Group 1
            Case WorkItem3 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 52, '', '', acc.Id, NEMSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem3);
            Case WorkItem4 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 52, '', '', acc.Id, AGSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem4);
            Case WorkItem5 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 52, '', '', acc.Id, OTSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem5);
            Case WorkItem6 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 52, '', '', acc.Id, SLSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem6);
            insert workItems;
            workitems = [select Id, SA_Type__c, SFDC_SA_ID__c, Interval__c, DA_CCA_IND__c, OwnerId, ParentId, AccountId, Status, User_Skill_Rule__r.Name, Priority_Score__c from Case];
            Set<Id> caseIds = new Set<Id>();
            for(Case c : workItems){
                //if(c.SFDC_SA_ID__c != NEMSA.Id){
                	caseIds.add(c.Id);    
                //}
            }
            GroupingUtility.groupWorkItems(workItems, queueId, new Map<Id, List<User_Skill__c>>(), caseIds);
            update workItems;
            system.assertEquals(WorkItem3.Id, [select ParentId from Case where Id =: WorkItem4.Id].ParentId);
        }
    }
    static testMethod void testGroupingNEM3() {
    	Profile p = [select id from profile where name='CSR'];
        UserRole r = [Select id from userrole where name='CSR'];
        User CSR= TestUtility.createUser(p.id,r.id,1); CSR.LAN_ID__C = 'CSR1'; insert CSR;
        Profile padmin = [select id from profile where name='Administrator'];
        UserRole rbillops = [Select id from userrole where name='Billing Operations'];
        User admin= TestUtility.createUser(padmin.id,rbillops.id,2); admin.LAN_ID__C = 'ADM1'; //insert admin;
        System.runAs(admin){
            Id queueId = [select Id, Name from Group where Name = 'Billing Exceptions' and Type = 'Queue'].Id;
        	Id recordtypeId = [select Id from RecordType where Name='Billing Exceptions' and sObjectType = 'Case'].Id;	
            
            List<User_Skill_Rule__c> usrList = new List<User_Skill_Rule__c>();
            User_Skill_Rule__c DAusr = TestUtility.createUserSkillRule(1, 'PSSTL', null, null, null, 'True', null, null, null, null, null, null, null); DAusr.Name = 'DA CCA PSSTL'; usrList.add(DAusr);
            User_Skill_Rule__c NEMusr = TestUtility.createUserSkillRule(2, 'PSSTL', null, null, 'HN-ERES', null, null, null, null, null, null, null, null); NEMusr.Name = 'NEM PSSTL'; usrList.add(NEMusr);
            User_Skill_Rule__c SLusr = TestUtility.createUserSkillRule(2, 'PSSTL', null, null, 'E-LGHT', null, null, null, null, null, null, null, null); SLusr.Name = 'Streetlight'; usrList.add(SLusr);
            User_Skill_Rule__c AGusr = TestUtility.createUserSkillRule(2, 'PSSTL', null, null, 'E-AG', null, null, null, null, null, null, null, null); AGusr.Name = 'Agricultural'; usrList.add(AGusr);

            insert usrList;
            
            // Create Account
            Account acc = TestUtility.createAccount(date.today() - 60, 'Account 1', '0007652348'); insert acc;
            // Create Service Agreement
            Service_Agreement__c IntSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'HE-RES', '1234567890'); insert IntSA;
            Service_Agreement__c NEMSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'HN-RES', '1234567890'); insert NEMSA;
            Service_Agreement__c AGSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'E-AG', '1234567890'); insert AGSA;
            Service_Agreement__c OTSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'G-RES', '1234567890'); insert OTSA;
            Service_Agreement__c SLSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'E-LGHT', '234567890'); insert SLSA;
            // Create Premise
            Premise__c prem = TestUtility.createPremise(); insert prem;
            // Create Service Point
            Service_Point__c sp = TestUtility.createServicePoint(prem.Id); insert sp;
            
            // Create Work Items
            Case WorkItem2 = TestUtility.CreateWorkItem('40', 'Retro Commencing', '', date.today() - 51, '', '', acc.Id, IntSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); insert WorkItem2;
            List<Case> workItems = new List<Case>();
            // Group 1
            Case WorkItem3 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 52, '', '', acc.Id, NEMSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem3);
            Case WorkItem4 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 52, '', '', acc.Id, AGSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem4);
            Case WorkItem5 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 52, '', '', acc.Id, OTSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem5);
            Case WorkItem6 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 52, '', '', acc.Id, SLSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem6);
            insert workItems;
            workitems = [select Id, SA_Type__c, SFDC_SA_ID__c, Interval__c, DA_CCA_IND__c, OwnerId, ParentId, AccountId, Status, User_Skill_Rule__r.Name, Priority_Score__c from Case];
            Set<Id> caseIds = new Set<Id>();
            for(Case c : workItems){
                //if(c.SFDC_SA_ID__c != NEMSA.Id){
                	caseIds.add(c.Id);    
                //}
            }
            GroupingUtility.groupWorkItems(workItems, queueId, new Map<Id, List<User_Skill__c>>(), caseIds);
            update workItems;
            system.assertEquals(WorkItem3.Id, [select ParentId from Case where Id =: WorkItem5.Id].ParentId);
            system.assertEquals(WorkItem3.Id, [select ParentId from Case where Id =: WorkItem2.Id].ParentId);
        }
    }
    static testMethod void testGroupingNEM4() {
    	Profile p = [select id from profile where name='CSR'];
        UserRole r = [Select id from userrole where name='CSR'];
        User CSR= TestUtility.createUser(p.id,r.id,1); CSR.LAN_ID__C = 'CSR1'; insert CSR;
        Profile padmin = [select id from profile where name='Administrator'];
        UserRole rbillops = [Select id from userrole where name='Billing Operations'];
        User admin= TestUtility.createUser(padmin.id,rbillops.id,2); admin.LAN_ID__C = 'ADM1'; //insert admin;
        System.runAs(admin){
            Id queueId = [select Id, Name from Group where Name = 'Billing Exceptions' and Type = 'Queue'].Id;
        	Id recordtypeId = [select Id from RecordType where Name='Billing Exceptions' and sObjectType = 'Case'].Id;	
            
            List<User_Skill_Rule__c> usrList = new List<User_Skill_Rule__c>();
            User_Skill_Rule__c DAusr = TestUtility.createUserSkillRule(1, 'PSSTL', null, null, null, 'True', null, null, null, null, null, null, null); DAusr.Name = 'DA CCA PSSTL'; usrList.add(DAusr);
            User_Skill_Rule__c NEMusr = TestUtility.createUserSkillRule(2, 'PSSTL', null, null, 'HN-ERES', null, null, null, null, null, null, null, null); NEMusr.Name = 'NEM PSSTL'; usrList.add(NEMusr);
            User_Skill_Rule__c SLusr = TestUtility.createUserSkillRule(2, 'PSSTL', null, null, 'E-LGHT', null, null, null, null, null, null, null, null); SLusr.Name = 'Streetlight'; usrList.add(SLusr);
            User_Skill_Rule__c AGusr = TestUtility.createUserSkillRule(2, 'PSSTL', null, null, 'E-AG', null, null, null, null, null, null, null, null); AGusr.Name = 'Agricultural'; usrList.add(AGusr);

            insert usrList;
            
            // Create Account
            Account acc = TestUtility.createAccount(date.today() - 60, 'Account 1', '0007652348'); insert acc;
            // Create Service Agreement
            Service_Agreement__c IntSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'HE-RES', '1234567890'); insert IntSA;
            Service_Agreement__c NEMSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'HN-RES', '1234567890'); insert NEMSA;
            Service_Agreement__c AGSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'E-AG', '1234567890'); insert AGSA;
            Service_Agreement__c OTSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'G-RES', '1234567890'); insert OTSA;
            Service_Agreement__c SLSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'E-LGHT', '234567890'); insert SLSA;
            // Create Premise
            Premise__c prem = TestUtility.createPremise(); insert prem;
            // Create Service Point
            Service_Point__c sp = TestUtility.createServicePoint(prem.Id); insert sp;
            
            // Create Work Items
            Case WorkItem2 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 51, '', '', acc.Id, AGSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId);  WorkItem2.OwnerId = CSR.Id; insert WorkItem2;
            List<Case> workItems = new List<Case>();
            // Group 1
            Case WorkItem3 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 52, '', '', acc.Id, NEMSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem3);
            Case WorkItem5 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 52, '', '', acc.Id, OTSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem5);
            Case WorkItem6 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 52, '', '', acc.Id, SLSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem6);
            insert workItems;
            workitems = [select Id, SA_Type__c, SFDC_SA_ID__c, Interval__c, DA_CCA_IND__c, OwnerId, ParentId, AccountId, Status, User_Skill_Rule__r.Name, Priority_Score__c from Case];
            Set<Id> caseIds = new Set<Id>();
            for(Case c : workItems){
                if(c.SFDC_SA_ID__c != NEMSA.Id){
                	caseIds.add(c.Id);    
                }
            }
            GroupingUtility.groupWorkItems(workItems, queueId, new Map<Id, List<User_Skill__c>>(), caseIds);
            update workItems;
            system.assertEquals(WorkItem2.Id, [select ParentId from Case where Id =: WorkItem5.Id].ParentId);
            system.assertEquals(null, [select ParentId from Case where Id =: WorkItem2.Id].ParentId);
            system.assertEquals(null, [select ParentId from Case where Id =: WorkItem3.Id].ParentId);
            system.assertEquals(null, [select ParentId from Case where Id =: WorkItem6.Id].ParentId);
        }
    }
    static testMethod void testGroupingNEM5() {
    	Profile p = [select id from profile where name='CSR'];
        UserRole r = [Select id from userrole where name='CSR'];
        User CSR= TestUtility.createUser(p.id,r.id,1); CSR.LAN_ID__C = 'CSR1'; insert CSR;
        Profile padmin = [select id from profile where name='Administrator'];
        UserRole rbillops = [Select id from userrole where name='Billing Operations'];
        User admin= TestUtility.createUser(padmin.id,rbillops.id,2); admin.LAN_ID__C = 'ADM1'; //insert admin;
        System.runAs(admin){
            Id queueId = [select Id, Name from Group where Name = 'Billing Exceptions' and Type = 'Queue'].Id;
        	Id recordtypeId = [select Id from RecordType where Name='Billing Exceptions' and sObjectType = 'Case'].Id;	
            
            List<User_Skill_Rule__c> usrList = new List<User_Skill_Rule__c>();
            User_Skill_Rule__c DAusr = TestUtility.createUserSkillRule(1, 'PSSTL', null, null, null, 'True', null, null, null, null, null, null, null); DAusr.Name = 'DA CCA PSSTL'; usrList.add(DAusr);
            User_Skill_Rule__c NEMusr = TestUtility.createUserSkillRule(2, 'PSSTL', null, null, 'HN-ERES', null, null, null, null, null, null, null, null); NEMusr.Name = 'NEM PSSTL'; usrList.add(NEMusr);
            User_Skill_Rule__c SLusr = TestUtility.createUserSkillRule(2, 'PSSTL', null, null, 'E-LGHT', null, null, null, null, null, null, null, null); SLusr.Name = 'Streetlight'; usrList.add(SLusr);
            User_Skill_Rule__c AGusr = TestUtility.createUserSkillRule(2, 'PSSTL', null, null, 'E-AG', null, null, null, null, null, null, null, null); AGusr.Name = 'Agricultural'; usrList.add(AGusr);

            insert usrList;
            
            // Create Account
            Account acc = TestUtility.createAccount(date.today() - 60, 'Account 1', '0007652348'); insert acc;
            // Create Service Agreement
            Service_Agreement__c IntSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'HE-RES', '1234567890'); insert IntSA;
            Service_Agreement__c NEMSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'HN-RES', '1234567890'); insert NEMSA;
            Service_Agreement__c AGSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'E-AG', '1234567890'); insert AGSA;
            Service_Agreement__c OTSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'G-RES', '1234567890'); insert OTSA;
            Service_Agreement__c SLSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'E-LGHT', '234567890'); insert SLSA;
            // Create Premise
            Premise__c prem = TestUtility.createPremise(); insert prem;
            // Create Service Point
            Service_Point__c sp = TestUtility.createServicePoint(prem.Id); insert sp;
            
            // Create Work Items
            Case WorkItem2 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 51, '', '', acc.Id, AGSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); insert WorkItem2;
            List<Case> workItems = new List<Case>();
            // Group 1
            Case WorkItem3 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 52, '', '', acc.Id, NEMSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem3);
            Case WorkItem5 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 52, '', '', acc.Id, OTSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem5);
            Case WorkItem6 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 52, '', '', acc.Id, SLSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem6);
            insert workItems;
            workitems = [select Id, SA_Type__c, SFDC_SA_ID__c, Interval__c, DA_CCA_IND__c, OwnerId, ParentId, AccountId, Status, User_Skill_Rule__r.Name, Priority_Score__c from Case];
            Set<Id> caseIds = new Set<Id>();
            for(Case c : workItems){
                if(c.SFDC_SA_ID__c != NEMSA.Id && !c.Interval__c){
                	caseIds.add(c.Id);    
                }
            }
            GroupingUtility.groupWorkItems(workItems, queueId, new Map<Id, List<User_Skill__c>>(), caseIds);
            update workItems;
            system.assertEquals(null, [select ParentId from Case where Id =: WorkItem5.Id].ParentId);
            system.assertEquals(null, [select ParentId from Case where Id =: WorkItem3.Id].ParentId);
            system.assertEquals(WorkItem3.Id, [select ParentId from Case where Id =: WorkItem2.Id].ParentId);
            system.assertEquals(null, [select ParentId from Case where Id =: WorkItem6.Id].ParentId);
        }
    }
    static testMethod void testGroupingNEM6() {
    	Profile p = [select id from profile where name='CSR'];
        UserRole r = [Select id from userrole where name='CSR'];
        User CSR= TestUtility.createUser(p.id,r.id,1); CSR.LAN_ID__C = 'CSR1'; insert CSR;
        Profile padmin = [select id from profile where name='Administrator'];
        UserRole rbillops = [Select id from userrole where name='Billing Operations'];
        User admin= TestUtility.createUser(padmin.id,rbillops.id,2); admin.LAN_ID__C = 'ADM1'; //insert admin;
        System.runAs(admin){
            Id queueId = [select Id, Name from Group where Name = 'Billing Exceptions' and Type = 'Queue'].Id;
        	Id recordtypeId = [select Id from RecordType where Name='Billing Exceptions' and sObjectType = 'Case'].Id;	
            
            List<User_Skill_Rule__c> usrList = new List<User_Skill_Rule__c>();
            User_Skill_Rule__c DAusr = TestUtility.createUserSkillRule(1, 'PSSTL', null, null, null, 'True', null, null, null, null, null, null, null); DAusr.Name = 'DA CCA PSSTL'; usrList.add(DAusr);
            User_Skill_Rule__c NEMusr = TestUtility.createUserSkillRule(2, 'PSSTL', null, null, 'HN-ERES', null, null, null, null, null, null, null, null); NEMusr.Name = 'NEM PSSTL'; usrList.add(NEMusr);
            User_Skill_Rule__c SLusr = TestUtility.createUserSkillRule(2, 'PSSTL', null, null, 'E-LGHT', null, null, null, null, null, null, null, null); SLusr.Name = 'Streetlight'; usrList.add(SLusr);
            User_Skill_Rule__c AGusr = TestUtility.createUserSkillRule(2, 'PSSTL', null, null, 'E-AG', null, null, null, null, null, null, null, null); AGusr.Name = 'Agricultural'; usrList.add(AGusr);

            insert usrList;
            
            // Create Account
            Account acc = TestUtility.createAccount(date.today() - 60, 'Account 1', '0007652348'); insert acc;
            // Create Service Agreement
            Service_Agreement__c IntSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'HE-RES', '1234567890'); insert IntSA;
            Service_Agreement__c NEMSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'HN-RES', '1234567890'); insert NEMSA;
            Service_Agreement__c AGSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'E-AG', '1234567890'); insert AGSA;
            Service_Agreement__c OTSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'G-RES', '1234567890'); insert OTSA;
            Service_Agreement__c SLSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'E-LGHT', '234567890'); insert SLSA;
            // Create Premise
            Premise__c prem = TestUtility.createPremise(); insert prem;
            // Create Service Point
            Service_Point__c sp = TestUtility.createServicePoint(prem.Id); insert sp;
            
            // Create Work Items
            Case WorkItem2 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 51, '', '', acc.Id, OTSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); WorkItem2.OwnerId = CSR.Id; insert WorkItem2;
            List<Case> workItems = new List<Case>();
            // Group 1
            Case WorkItem3 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 52, '', '', acc.Id, NEMSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem3);
            Case WorkItem6 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 52, '', '', acc.Id, SLSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem6);
            insert workItems;
            workitems = [select Id, SA_Type__c, SFDC_SA_ID__c, Interval__c, DA_CCA_IND__c, OwnerId, ParentId, AccountId, Status, User_Skill_Rule__r.Name, Priority_Score__c from Case];
            Set<Id> caseIds = new Set<Id>();
            for(Case c : workItems){
                if(c.SFDC_SA_ID__c != NEMSA.Id && !c.Interval__c){
                	caseIds.add(c.Id);    
                }
            }
            GroupingUtility.groupWorkItems(workItems, queueId, new Map<Id, List<User_Skill__c>>(), caseIds);
            update workItems;
            system.assertEquals(null, [select ParentId from Case where Id =: WorkItem2.Id].ParentId);
            system.assertEquals(null, [select ParentId from Case where Id =: WorkItem3.Id].ParentId);
            system.assertEquals(null, [select ParentId from Case where Id =: WorkItem6.Id].ParentId);
        }
    }
    static testMethod void testGroupingNEM7() {
    	Profile p = [select id from profile where name='CSR'];
        UserRole r = [Select id from userrole where name='CSR'];
        User CSR= TestUtility.createUser(p.id,r.id,1); CSR.LAN_ID__C = 'CSR1'; insert CSR;
        Profile padmin = [select id from profile where name='Administrator'];
        UserRole rbillops = [Select id from userrole where name='Billing Operations'];
        User admin= TestUtility.createUser(padmin.id,rbillops.id,2); admin.LAN_ID__C = 'ADM1'; //insert admin;
        System.runAs(admin){
            Id queueId = [select Id, Name from Group where Name = 'Billing Exceptions' and Type = 'Queue'].Id;
        	Id recordtypeId = [select Id from RecordType where Name='Billing Exceptions' and sObjectType = 'Case'].Id;	
            
            List<User_Skill_Rule__c> usrList = new List<User_Skill_Rule__c>();
            User_Skill_Rule__c DAusr = TestUtility.createUserSkillRule(1, 'PSSTL', null, null, null, 'True', null, null, null, null, null, null, null); DAusr.Name = 'DA CCA PSSTL'; usrList.add(DAusr);
            User_Skill_Rule__c NEMusr = TestUtility.createUserSkillRule(2, 'PSSTL', null, null, 'HN-ERES', null, null, null, null, null, null, null, null); NEMusr.Name = 'NEM PSSTL'; usrList.add(NEMusr);
            User_Skill_Rule__c SLusr = TestUtility.createUserSkillRule(2, 'PSSTL', null, null, 'E-LGHT', null, null, null, null, null, null, null, null); SLusr.Name = 'Streetlight'; usrList.add(SLusr);
            User_Skill_Rule__c AGusr = TestUtility.createUserSkillRule(2, 'PSSTL', null, null, 'E-AG', null, null, null, null, null, null, null, null); AGusr.Name = 'Agricultural'; usrList.add(AGusr);

            insert usrList;
            
            // Create Account
            Account acc = TestUtility.createAccount(date.today() - 60, 'Account 1', '0007652348'); insert acc;
            // Create Service Agreement
            Service_Agreement__c IntSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'HE-RES', '1234567890'); insert IntSA;
            Service_Agreement__c NEMSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'HN-RES', '1234567890'); insert NEMSA;
            Service_Agreement__c AGSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'E-AG', '1234567890'); insert AGSA;
            Service_Agreement__c OTSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'G-RES', '1234567890'); insert OTSA;
            Service_Agreement__c SLSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'E-LGHT', '234567890'); insert SLSA;
            // Create Premise
            Premise__c prem = TestUtility.createPremise(); insert prem;
            // Create Service Point
            Service_Point__c sp = TestUtility.createServicePoint(prem.Id); insert sp;
            
            // Create Work Items
            Case WorkItem2 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 51, '', '', acc.Id, OTSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); WorkItem2.OwnerId = queueId; insert WorkItem2;
            List<Case> workItems = new List<Case>();
            // Group 1
            Case WorkItem3 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 52, '', '', acc.Id, NEMSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem3);
            Case WorkItem6 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 52, '', '', acc.Id, SLSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem6);
            insert workItems;
            workitems = [select Id, SA_Type__c, SFDC_SA_ID__c, Interval__c, DA_CCA_IND__c, OwnerId, ParentId, AccountId, Status, User_Skill_Rule__r.Name, Priority_Score__c from Case];
            Set<Id> caseIds = new Set<Id>();
            for(Case c : workItems){
                if(c.SFDC_SA_ID__c != NEMSA.Id && !c.Interval__c){
                	caseIds.add(c.Id);    
                }
            }
            GroupingUtility.groupWorkItems(workItems, queueId, new Map<Id, List<User_Skill__c>>(), caseIds);
            update workItems;
            system.assertEquals(WorkItem3.Id, [select ParentId from Case where Id =: WorkItem2.Id].ParentId);
        }
    }
	static testMethod void testGroupingInterval() {
    	Profile p = [select id from profile where name='CSR'];
        UserRole r = [Select id from userrole where name='CSR'];
        User CSR= TestUtility.createUser(p.id,r.id,1); CSR.LAN_ID__C = 'CSR1'; insert CSR;
        Profile padmin = [select id from profile where name='Administrator'];
        UserRole rbillops = [Select id from userrole where name='Billing Operations'];
        User admin= TestUtility.createUser(padmin.id,rbillops.id,2); admin.LAN_ID__C = 'ADM1'; //insert admin;
        System.runAs(admin){
            Id queueId = [select Id, Name from Group where Name = 'Billing Exceptions' and Type = 'Queue'].Id;
        	Id recordtypeId = [select Id from RecordType where Name='Billing Exceptions' and sObjectType = 'Case'].Id;	
            
            List<User_Skill_Rule__c> usrList = new List<User_Skill_Rule__c>();
            User_Skill_Rule__c DAusr = TestUtility.createUserSkillRule(1, 'PSSTL', null, null, null, 'True', null, null, null, null, null, null, null); DAusr.Name = 'DA CCA PSSTL'; usrList.add(DAusr);
            User_Skill_Rule__c NEMusr = TestUtility.createUserSkillRule(2, 'PSSTL', null, null, 'HN-ERES', null, null, null, null, null, null, null, null); NEMusr.Name = 'NEM PSSTL'; usrList.add(NEMusr);
            User_Skill_Rule__c SLusr = TestUtility.createUserSkillRule(2, 'PSSTL', null, null, 'E-LGHT', null, null, null, null, null, null, null, null); SLusr.Name = 'Streetlight'; usrList.add(SLusr);
            User_Skill_Rule__c AGusr = TestUtility.createUserSkillRule(2, 'PSSTL', null, null, 'E-AG', null, null, null, null, null, null, null, null); AGusr.Name = 'Agricultural'; usrList.add(AGusr);

            insert usrList;
            
            // Create Account
            Account acc = TestUtility.createAccount(date.today() - 60, 'Account 1', '0007652348'); insert acc;
            // Create Service Agreement
            Service_Agreement__c DASA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'E-RES', '1234567890'); insert DASA;
            Service_Agreement__c IntSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'HE-RES', '1234567890'); insert IntSA;
            Service_Agreement__c NEMSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'HN-RES', '1234567890'); insert NEMSA;
            Service_Agreement__c AGSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'E-AG', '1234567890'); insert AGSA;
            Service_Agreement__c OTSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'G-RES', '1234567890'); insert OTSA;
            Service_Agreement__c SLSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'E-LGHT', '234567890'); insert SLSA;
            // Create Premise
            Premise__c prem = TestUtility.createPremise(); insert prem;
            // Create Service Point
            Service_Point__c sp = TestUtility.createServicePoint(prem.Id); insert sp;
            
            // Create Work Items
            List<Case> workItems = new List<Case>();
            // Group 1
            //Case WorkItem1 = TestUtility.CreateWorkItem('40', 'BSEG', '', date.today() - 50, '', '', acc.Id, DASA.Id, true, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem1); //parent
            Case WorkItem2 = TestUtility.CreateWorkItem('40', 'Retro Commencing', '', date.today() - 51, '', '', acc.Id, IntSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem2);
            //Case WorkItem3 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 52, '', '', acc.Id, NEMSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem3);
            Case WorkItem4 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 52, '', '', acc.Id, AGSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem4);
            Case WorkItem5 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 52, '', '', acc.Id, OTSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem5);
            Case WorkItem6 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 52, '', '', acc.Id, SLSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem6);
            insert workItems;
            workitems = [select Id, SA_Type__c, Interval__c, DA_CCA_IND__c, OwnerId, ParentId, AccountId, Status, User_Skill_Rule__r.Name, Priority_Score__c from Case];
            Set<Id> caseIds = new Set<Id>();
            for(Case c : workItems){
                caseIds.add(c.Id);
            }
            GroupingUtility.groupWorkItems(workItems, queueId, new Map<Id, List<User_Skill__c>>(), caseIds);
            update workItems;
            system.assertEquals(WorkItem2.Id, [select ParentId from Case where Id =: WorkItem4.Id].ParentId);
        }
    }
    static testMethod void testGroupingInterval2() {
    	Profile p = [select id from profile where name='CSR'];
        UserRole r = [Select id from userrole where name='CSR'];
        User CSR= TestUtility.createUser(p.id,r.id,1); CSR.LAN_ID__C = 'CSR1'; insert CSR;
        Profile padmin = [select id from profile where name='Administrator'];
        UserRole rbillops = [Select id from userrole where name='Billing Operations'];
        User admin= TestUtility.createUser(padmin.id,rbillops.id,2); admin.LAN_ID__C = 'ADM1'; //insert admin;
        System.runAs(admin){
            Id queueId = [select Id, Name from Group where Name = 'Billing Exceptions' and Type = 'Queue'].Id;
        	Id recordtypeId = [select Id from RecordType where Name='Billing Exceptions' and sObjectType = 'Case'].Id;	
            
            List<User_Skill_Rule__c> usrList = new List<User_Skill_Rule__c>();
            User_Skill_Rule__c DAusr = TestUtility.createUserSkillRule(1, 'PSSTL', null, null, null, 'True', null, null, null, null, null, null, null); DAusr.Name = 'DA CCA PSSTL'; usrList.add(DAusr);
            User_Skill_Rule__c NEMusr = TestUtility.createUserSkillRule(2, 'PSSTL', null, null, 'HN-ERES', null, null, null, null, null, null, null, null); NEMusr.Name = 'NEM PSSTL'; usrList.add(NEMusr);
            User_Skill_Rule__c SLusr = TestUtility.createUserSkillRule(2, 'PSSTL', null, null, 'E-LGHT', null, null, null, null, null, null, null, null); SLusr.Name = 'Streetlight'; usrList.add(SLusr);
            User_Skill_Rule__c AGusr = TestUtility.createUserSkillRule(2, 'PSSTL', null, null, 'E-AG', null, null, null, null, null, null, null, null); AGusr.Name = 'Agricultural'; usrList.add(AGusr);

            insert usrList;
            
            // Create Account
            Account acc = TestUtility.createAccount(date.today() - 60, 'Account 1', '0007652348'); insert acc;
            // Create Service Agreement
            Service_Agreement__c DASA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'E-RES', '1234567890'); insert DASA;
            Service_Agreement__c IntSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'HE-RES', '1234567890'); insert IntSA;
            Service_Agreement__c NEMSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'HN-RES', '1234567890'); insert NEMSA;
            Service_Agreement__c AGSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'E-AG', '1234567890'); insert AGSA;
            Service_Agreement__c OTSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'G-RES', '1234567890'); insert OTSA;
            Service_Agreement__c SLSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'E-LGHT', '234567890'); insert SLSA;
            // Create Premise
            Premise__c prem = TestUtility.createPremise(); insert prem;
            // Create Service Point
            Service_Point__c sp = TestUtility.createServicePoint(prem.Id); insert sp;
            
            // Create Work Items
            Case WorkItem4 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 52, '', '', acc.Id, AGSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); WorkItem4.OwnerId = CSR.Id; insert WorkItem4;
            List<Case> workItems = new List<Case>();
            // Group 1
            Case WorkItem2 = TestUtility.CreateWorkItem('40', 'Retro Commencing', '', date.today() - 51, '', '', acc.Id, IntSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem2);
            Case WorkItem5 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 52, '', '', acc.Id, OTSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem5);
            Case WorkItem6 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 52, '', '', acc.Id, SLSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem6);
            insert workItems;
            workitems = [select Id, SA_Type__c, Interval__c, DA_CCA_IND__c, OwnerId, ParentId, AccountId, Status, User_Skill_Rule__r.Name, Priority_Score__c from Case];
            Set<Id> caseIds = new Set<Id>();
            for(Case c : workItems){
                if(!c.Interval__c){
                	caseIds.add(c.Id);    
                }
            }
            GroupingUtility.groupWorkItems(workItems, queueId, new Map<Id, List<User_Skill__c>>(), caseIds);
            update workItems;
            system.assertEquals(WorkItem4.Id, [select ParentId from Case where Id =: WorkItem5.Id].ParentId);
        }
    }
    static testMethod void testGroupingInterval3() {
    	Profile p = [select id from profile where name='CSR'];
        UserRole r = [Select id from userrole where name='CSR'];
        User CSR= TestUtility.createUser(p.id,r.id,1); CSR.LAN_ID__C = 'CSR1'; insert CSR;
        Profile padmin = [select id from profile where name='Administrator'];
        UserRole rbillops = [Select id from userrole where name='Billing Operations'];
        User admin= TestUtility.createUser(padmin.id,rbillops.id,2); admin.LAN_ID__C = 'ADM1'; //insert admin;
        System.runAs(admin){
            Id queueId = [select Id, Name from Group where Name = 'Billing Exceptions' and Type = 'Queue'].Id;
        	Id recordtypeId = [select Id from RecordType where Name='Billing Exceptions' and sObjectType = 'Case'].Id;	
            
            List<User_Skill_Rule__c> usrList = new List<User_Skill_Rule__c>();
            User_Skill_Rule__c DAusr = TestUtility.createUserSkillRule(1, 'PSSTL', null, null, null, 'True', null, null, null, null, null, null, null); DAusr.Name = 'DA CCA PSSTL'; usrList.add(DAusr);
            User_Skill_Rule__c NEMusr = TestUtility.createUserSkillRule(2, 'PSSTL', null, null, 'HN-ERES', null, null, null, null, null, null, null, null); NEMusr.Name = 'NEM PSSTL'; usrList.add(NEMusr);
            User_Skill_Rule__c SLusr = TestUtility.createUserSkillRule(2, 'PSSTL', null, null, 'E-LGHT', null, null, null, null, null, null, null, null); SLusr.Name = 'Streetlight'; usrList.add(SLusr);
            User_Skill_Rule__c AGusr = TestUtility.createUserSkillRule(2, 'PSSTL', null, null, 'E-AG', null, null, null, null, null, null, null, null); AGusr.Name = 'Agricultural'; usrList.add(AGusr);

            insert usrList;
            
            // Create Account
            Account acc = TestUtility.createAccount(date.today() - 60, 'Account 1', '0007652348'); insert acc;
            // Create Service Agreement
            Service_Agreement__c DASA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'E-RES', '1234567890'); insert DASA;
            Service_Agreement__c IntSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'HE-RES', '1234567890'); insert IntSA;
            Service_Agreement__c NEMSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'HN-RES', '1234567890'); insert NEMSA;
            Service_Agreement__c AGSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'E-AG', '1234567890'); insert AGSA;
            Service_Agreement__c OTSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'G-RES', '1234567890'); insert OTSA;
            Service_Agreement__c SLSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'E-LGHT', '234567890'); insert SLSA;
            // Create Premise
            Premise__c prem = TestUtility.createPremise(); insert prem;
            // Create Service Point
            Service_Point__c sp = TestUtility.createServicePoint(prem.Id); insert sp;
            
            // Create Work Items
            Case WorkItem4 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 52, '', '', acc.Id, AGSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); insert WorkItem4;
            List<Case> workItems = new List<Case>();
            // Group 1
            Case WorkItem2 = TestUtility.CreateWorkItem('40', 'Retro Commencing', '', date.today() - 51, '', '', acc.Id, IntSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem2);            
            Case WorkItem5 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 52, '', '', acc.Id, OTSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem5);
            Case WorkItem6 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 52, '', '', acc.Id, SLSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem6);
            insert workItems;
            workitems = [select Id, SA_Type__c, Interval__c, DA_CCA_IND__c, OwnerId, ParentId, AccountId, Status, User_Skill_Rule__r.Name, Priority_Score__c from Case];
            Set<Id> caseIds = new Set<Id>();
            for(Case c : workItems){
                //if(!c.Interval__c){
                	caseIds.add(c.Id);    
                //}
            }
            GroupingUtility.groupWorkItems(workItems, queueId, new Map<Id, List<User_Skill__c>>(), caseIds);
            update workItems;
            system.assertEquals(WorkItem2.Id, [select ParentId from Case where Id =: WorkItem5.Id].ParentId);
        }
    }
    static testMethod void testGroupingInterval4() {
    	Profile p = [select id from profile where name='CSR'];
        UserRole r = [Select id from userrole where name='CSR'];
        User CSR= TestUtility.createUser(p.id,r.id,1); CSR.LAN_ID__C = 'CSR1'; insert CSR;
        Profile padmin = [select id from profile where name='Administrator'];
        UserRole rbillops = [Select id from userrole where name='Billing Operations'];
        User admin= TestUtility.createUser(padmin.id,rbillops.id,2); admin.LAN_ID__C = 'ADM1'; //insert admin;
        System.runAs(admin){
            Id queueId = [select Id, Name from Group where Name = 'Billing Exceptions' and Type = 'Queue'].Id;
        	Id recordtypeId = [select Id from RecordType where Name='Billing Exceptions' and sObjectType = 'Case'].Id;	
            
            List<User_Skill_Rule__c> usrList = new List<User_Skill_Rule__c>();
            User_Skill_Rule__c DAusr = TestUtility.createUserSkillRule(1, 'PSSTL', null, null, null, 'True', null, null, null, null, null, null, null); DAusr.Name = 'DA CCA PSSTL'; usrList.add(DAusr);
            User_Skill_Rule__c NEMusr = TestUtility.createUserSkillRule(2, 'PSSTL', null, null, 'HN-ERES', null, null, null, null, null, null, null, null); NEMusr.Name = 'NEM PSSTL'; usrList.add(NEMusr);
            User_Skill_Rule__c SLusr = TestUtility.createUserSkillRule(2, 'PSSTL', null, null, 'E-LGHT', null, null, null, null, null, null, null, null); SLusr.Name = 'Streetlight'; usrList.add(SLusr);
            User_Skill_Rule__c AGusr = TestUtility.createUserSkillRule(2, 'PSSTL', null, null, 'E-AG', null, null, null, null, null, null, null, null); AGusr.Name = 'Agricultural'; usrList.add(AGusr);

            insert usrList;
            
            // Create Account
            Account acc = TestUtility.createAccount(date.today() - 60, 'Account 1', '0007652348'); insert acc;
            // Create Service Agreement
            Service_Agreement__c DASA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'E-RES', '1234567890'); insert DASA;
            Service_Agreement__c IntSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'HE-RES', '1234567890'); insert IntSA;
            Service_Agreement__c NEMSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'HN-RES', '1234567890'); insert NEMSA;
            Service_Agreement__c AGSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'E-AG', '1234567890'); insert AGSA;
            Service_Agreement__c OTSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'G-RES', '1234567890'); insert OTSA;
            Service_Agreement__c SLSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'E-LGHT', '234567890'); insert SLSA;
            // Create Premise
            Premise__c prem = TestUtility.createPremise(); insert prem;
            // Create Service Point
            Service_Point__c sp = TestUtility.createServicePoint(prem.Id); insert sp;
            
            // Create Work Items
            Case WorkItem5 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 52, '', '', acc.Id, OTSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); WorkItem5.OwnerId = CSR.Id; Insert WorkItem5;
            List<Case> workItems = new List<Case>();
            // Group 1
            Case WorkItem2 = TestUtility.CreateWorkItem('40', 'Retro Commencing', '', date.today() - 51, '', '', acc.Id, IntSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem2);            
            
            Case WorkItem6 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 52, '', '', acc.Id, SLSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem6);
            insert workItems;
            workitems = [select Id, SA_Type__c, Interval__c, DA_CCA_IND__c, OwnerId, ParentId, AccountId, Status, User_Skill_Rule__r.Name, Priority_Score__c from Case];
            Set<Id> caseIds = new Set<Id>();
            for(Case c : workItems){
               // if(!c.Interval__c){
                	caseIds.add(c.Id);    
               // }
            }
            GroupingUtility.groupWorkItems(workItems, queueId, new Map<Id, List<User_Skill__c>>(), caseIds);
            update workItems;
            system.assertEquals(null, [select ParentId from Case where Id =: WorkItem5.Id].ParentId);
            system.assertEquals(null, [select ParentId from Case where Id =: WorkItem2.Id].ParentId);
            system.assertEquals(null, [select ParentId from Case where Id =: WorkItem6.Id].ParentId);
        }
    }
    static testMethod void testGroupingInterval5() {
    	Profile p = [select id from profile where name='CSR'];
        UserRole r = [Select id from userrole where name='CSR'];
        User CSR= TestUtility.createUser(p.id,r.id,1); CSR.LAN_ID__C = 'CSR1'; insert CSR;
        Profile padmin = [select id from profile where name='Administrator'];
        UserRole rbillops = [Select id from userrole where name='Billing Operations'];
        User admin= TestUtility.createUser(padmin.id,rbillops.id,2); admin.LAN_ID__C = 'ADM1'; //insert admin;
        System.runAs(admin){
            Id queueId = [select Id, Name from Group where Name = 'Billing Exceptions' and Type = 'Queue'].Id;
        	Id recordtypeId = [select Id from RecordType where Name='Billing Exceptions' and sObjectType = 'Case'].Id;	
            
            List<User_Skill_Rule__c> usrList = new List<User_Skill_Rule__c>();
            User_Skill_Rule__c DAusr = TestUtility.createUserSkillRule(1, 'PSSTL', null, null, null, 'True', null, null, null, null, null, null, null); DAusr.Name = 'DA CCA PSSTL'; usrList.add(DAusr);
            User_Skill_Rule__c NEMusr = TestUtility.createUserSkillRule(2, 'PSSTL', null, null, 'HN-ERES', null, null, null, null, null, null, null, null); NEMusr.Name = 'NEM PSSTL'; usrList.add(NEMusr);
            User_Skill_Rule__c SLusr = TestUtility.createUserSkillRule(2, 'PSSTL', null, null, 'E-LGHT', null, null, null, null, null, null, null, null); SLusr.Name = 'Streetlight'; usrList.add(SLusr);
            User_Skill_Rule__c AGusr = TestUtility.createUserSkillRule(2, 'PSSTL', null, null, 'E-AG', null, null, null, null, null, null, null, null); AGusr.Name = 'Agricultural'; usrList.add(AGusr);

            insert usrList;
            
            // Create Account
            Account acc = TestUtility.createAccount(date.today() - 60, 'Account 1', '0007652348'); insert acc;
            // Create Service Agreement
            Service_Agreement__c DASA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'E-RES', '1234567890'); insert DASA;
            Service_Agreement__c IntSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'HE-RES', '1234567890'); insert IntSA;
            Service_Agreement__c NEMSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'HN-RES', '1234567890'); insert NEMSA;
            Service_Agreement__c AGSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'E-AG', '1234567890'); insert AGSA;
            Service_Agreement__c OTSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'G-RES', '1234567890'); insert OTSA;
            Service_Agreement__c SLSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'E-LGHT', '234567890'); insert SLSA;
            // Create Premise
            Premise__c prem = TestUtility.createPremise(); insert prem;
            // Create Service Point
            Service_Point__c sp = TestUtility.createServicePoint(prem.Id); insert sp;
            
            // Create Work Items
            Case WorkItem5 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 52, '', '', acc.Id, OTSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); Insert WorkItem5;
            List<Case> workItems = new List<Case>();
            // Group 1
            Case WorkItem2 = TestUtility.CreateWorkItem('40', 'Retro Commencing', '', date.today() - 51, '', '', acc.Id, IntSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem2);            
            
            Case WorkItem6 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 52, '', '', acc.Id, SLSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem6);
            insert workItems;
            workitems = [select Id, SA_Type__c, Interval__c, DA_CCA_IND__c, OwnerId, ParentId, AccountId, Status, User_Skill_Rule__r.Name, Priority_Score__c from Case];
            Set<Id> caseIds = new Set<Id>();
            for(Case c : workItems){
                //if(!c.Interval__c){
                	caseIds.add(c.Id);    
                //}
            }
            GroupingUtility.groupWorkItems(workItems, queueId, new Map<Id, List<User_Skill__c>>(), caseIds);
            update workItems;
            system.assertEquals(WorkItem2.Id, [select ParentId from Case where Id =: WorkItem5.Id].ParentId);
        }
    }
	static testMethod void testGroupingAg() {
    	Profile p = [select id from profile where name='CSR'];
        UserRole r = [Select id from userrole where name='CSR'];
        User CSR= TestUtility.createUser(p.id,r.id,1); CSR.LAN_ID__C = 'CSR1'; insert CSR;
        Profile padmin = [select id from profile where name='Administrator'];
        UserRole rbillops = [Select id from userrole where name='Billing Operations'];
        User admin= TestUtility.createUser(padmin.id,rbillops.id,2); admin.LAN_ID__C = 'ADM1'; //insert admin;
        System.runAs(admin){
            Id queueId = [select Id, Name from Group where Name = 'Billing Exceptions' and Type = 'Queue'].Id;
        	Id recordtypeId = [select Id from RecordType where Name='Billing Exceptions' and sObjectType = 'Case'].Id;	
            
            List<User_Skill_Rule__c> usrList = new List<User_Skill_Rule__c>();
            User_Skill_Rule__c DAusr = TestUtility.createUserSkillRule(1, 'PSSTL', null, null, null, 'True', null, null, null, null, null, null, null); DAusr.Name = 'DA CCA PSSTL'; usrList.add(DAusr);
            User_Skill_Rule__c NEMusr = TestUtility.createUserSkillRule(2, 'PSSTL', null, null, 'HN-ERES', null, null, null, null, null, null, null, null); NEMusr.Name = 'NEM PSSTL'; usrList.add(NEMusr);
            User_Skill_Rule__c SLusr = TestUtility.createUserSkillRule(2, 'PSSTL', null, null, 'E-LGHT', null, null, null, null, null, null, null, null); SLusr.Name = 'Streetlight'; usrList.add(SLusr);
            User_Skill_Rule__c AGusr = TestUtility.createUserSkillRule(2, 'PSSTL', null, null, 'E-AG', null, null, null, null, null, null, null, null); AGusr.Name = 'Agricultural'; usrList.add(AGusr);

            insert usrList;
            
            // Create Account
            Account acc = TestUtility.createAccount(date.today() - 60, 'Account 1', '0007652348'); insert acc;
            // Create Service Agreement
            Service_Agreement__c DASA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'E-RES', '1234567890'); insert DASA;
            Service_Agreement__c IntSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'HE-RES', '1234567890'); insert IntSA;
            Service_Agreement__c NEMSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'HN-RES', '1234567890'); insert NEMSA;
            Service_Agreement__c AGSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'E-AG', '1234567890'); insert AGSA;
            Service_Agreement__c OTSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'G-RES', '1234567890'); insert OTSA;
            Service_Agreement__c SLSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'E-LGHT', '234567890'); insert SLSA;
            // Create Premise
            Premise__c prem = TestUtility.createPremise(); insert prem;
            // Create Service Point
            Service_Point__c sp = TestUtility.createServicePoint(prem.Id); insert sp;
            
            // Create Work Items
            List<Case> workItems = new List<Case>();
            // Group 1
            //Case WorkItem1 = TestUtility.CreateWorkItem('40', 'BSEG', '', date.today() - 50, '', '', acc.Id, DASA.Id, true, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem1); //parent
            //Case WorkItem2 = TestUtility.CreateWorkItem('40', 'Retro Commencing', '', date.today() - 51, '', '', acc.Id, IntSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem2);
            //Case WorkItem3 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 52, '', '', acc.Id, NEMSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem3);
            Case WorkItem4 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 52, '', '', acc.Id, AGSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem4);
            Case WorkItem5 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 52, '', '', acc.Id, OTSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem5);
            Case WorkItem6 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 52, '', '', acc.Id, SLSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem6);
            insert workItems;
            workitems = [select Id, SA_Type__c, Interval__c, DA_CCA_IND__c, OwnerId, ParentId, AccountId, Status, User_Skill_Rule__r.Name, Priority_Score__c from Case];
            Set<Id> caseIds = new Set<Id>();
            for(Case c : workItems){
                caseIds.add(c.Id);
            }
            GroupingUtility.groupWorkItems(workItems, queueId, new Map<Id, List<User_Skill__c>>(), caseIds);
            update workItems;
            system.assertEquals(WorkItem4.Id, [select ParentId from Case where Id =: WorkItem5.Id].ParentId);
        }
    }
    static testMethod void testGroupingAg2() {
    	Profile p = [select id from profile where name='CSR'];
        UserRole r = [Select id from userrole where name='CSR'];
        User CSR= TestUtility.createUser(p.id,r.id,1); CSR.LAN_ID__C = 'CSR1'; insert CSR;
        Profile padmin = [select id from profile where name='Administrator'];
        UserRole rbillops = [Select id from userrole where name='Billing Operations'];
        User admin= TestUtility.createUser(padmin.id,rbillops.id,2); admin.LAN_ID__C = 'ADM1'; //insert admin;
        System.runAs(admin){
            Id queueId = [select Id, Name from Group where Name = 'Billing Exceptions' and Type = 'Queue'].Id;
        	Id recordtypeId = [select Id from RecordType where Name='Billing Exceptions' and sObjectType = 'Case'].Id;	
            
            List<User_Skill_Rule__c> usrList = new List<User_Skill_Rule__c>();
            User_Skill_Rule__c DAusr = TestUtility.createUserSkillRule(1, 'PSSTL', null, null, null, 'True', null, null, null, null, null, null, null); DAusr.Name = 'DA CCA PSSTL'; usrList.add(DAusr);
            User_Skill_Rule__c NEMusr = TestUtility.createUserSkillRule(2, 'PSSTL', null, null, 'HN-ERES', null, null, null, null, null, null, null, null); NEMusr.Name = 'NEM PSSTL'; usrList.add(NEMusr);
            User_Skill_Rule__c SLusr = TestUtility.createUserSkillRule(2, 'PSSTL', null, null, 'E-LGHT', null, null, null, null, null, null, null, null); SLusr.Name = 'Streetlight'; usrList.add(SLusr);
            User_Skill_Rule__c AGusr = TestUtility.createUserSkillRule(2, 'PSSTL', null, null, 'E-AG', null, null, null, null, null, null, null, null); AGusr.Name = 'Agricultural'; usrList.add(AGusr);

            insert usrList;
            
            // Create Account
            Account acc = TestUtility.createAccount(date.today() - 60, 'Account 1', '0007652348'); insert acc;
            // Create Service Agreement
            Service_Agreement__c DASA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'E-RES', '1234567890'); insert DASA;
            Service_Agreement__c IntSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'HE-RES', '1234567890'); insert IntSA;
            Service_Agreement__c NEMSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'HN-RES', '1234567890'); insert NEMSA;
            Service_Agreement__c AGSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'E-AG', '1234567890'); insert AGSA;
            Service_Agreement__c OTSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'G-RES', '1234567890'); insert OTSA;
            Service_Agreement__c SLSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'E-LGHT', '234567890'); insert SLSA;
            // Create Premise
            Premise__c prem = TestUtility.createPremise(); insert prem;
            // Create Service Point
            Service_Point__c sp = TestUtility.createServicePoint(prem.Id); insert sp;
            
            // Create Work Items
            List<Case> workItems = new List<Case>();
            Case WorkItem5 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 52, '', '', acc.Id, OTSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); WorkItem5.OwnerId = CSR.Id; insert WorkItem5;
            // Group 1
            Case WorkItem4 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 52, '', '', acc.Id, AGSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem4);
            Case WorkItem6 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 52, '', '', acc.Id, SLSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem6);
            insert workItems;
            workitems = [select Id, SA_Type__c, Interval__c, DA_CCA_IND__c, OwnerId, ParentId, AccountId, Status, User_Skill_Rule__r.Name, Priority_Score__c from Case];
            Set<Id> caseIds = new Set<Id>();
            for(Case c : workItems){
                if(c.SA_Type__c != 'E-AG'){
                    caseIds.add(c.Id);
                }
            }
            GroupingUtility.groupWorkItems(workItems, queueId, new Map<Id, List<User_Skill__c>>(), caseIds);
            update workItems;
            system.assertEquals(null, [select ParentId from Case where Id =: WorkItem5.Id].ParentId);
            system.assertEquals(null, [select ParentId from Case where Id =: WorkItem4.Id].ParentId);
            system.assertEquals(null, [select ParentId from Case where Id =: WorkItem6.Id].ParentId);
        }
    }
    static testMethod void testGroupingAg3() {
    	Profile p = [select id from profile where name='CSR'];
        UserRole r = [Select id from userrole where name='CSR'];
        User CSR= TestUtility.createUser(p.id,r.id,1); CSR.LAN_ID__C = 'CSR1'; insert CSR;
        Profile padmin = [select id from profile where name='Administrator'];
        UserRole rbillops = [Select id from userrole where name='Billing Operations'];
        User admin= TestUtility.createUser(padmin.id,rbillops.id,2); admin.LAN_ID__C = 'ADM1'; //insert admin;
        System.runAs(admin){
            Id queueId = [select Id, Name from Group where Name = 'Billing Exceptions' and Type = 'Queue'].Id;
        	Id recordtypeId = [select Id from RecordType where Name='Billing Exceptions' and sObjectType = 'Case'].Id;	
            
            List<User_Skill_Rule__c> usrList = new List<User_Skill_Rule__c>();
            User_Skill_Rule__c DAusr = TestUtility.createUserSkillRule(1, 'PSSTL', null, null, null, 'True', null, null, null, null, null, null, null); DAusr.Name = 'DA CCA PSSTL'; usrList.add(DAusr);
            User_Skill_Rule__c NEMusr = TestUtility.createUserSkillRule(2, 'PSSTL', null, null, 'HN-ERES', null, null, null, null, null, null, null, null); NEMusr.Name = 'NEM PSSTL'; usrList.add(NEMusr);
            User_Skill_Rule__c SLusr = TestUtility.createUserSkillRule(2, 'PSSTL', null, null, 'E-LGHT', null, null, null, null, null, null, null, null); SLusr.Name = 'Streetlight'; usrList.add(SLusr);
            User_Skill_Rule__c AGusr = TestUtility.createUserSkillRule(2, 'PSSTL', null, null, 'E-AG', null, null, null, null, null, null, null, null); AGusr.Name = 'Agricultural'; usrList.add(AGusr);

            insert usrList;
            
            // Create Account
            Account acc = TestUtility.createAccount(date.today() - 60, 'Account 1', '0007652348'); insert acc;
            // Create Service Agreement
            Service_Agreement__c DASA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'E-RES', '1234567890'); insert DASA;
            Service_Agreement__c IntSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'HE-RES', '1234567890'); insert IntSA;
            Service_Agreement__c NEMSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'HN-RES', '1234567890'); insert NEMSA;
            Service_Agreement__c AGSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'E-AG', '1234567890'); insert AGSA;
            Service_Agreement__c OTSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'G-RES', '1234567890'); insert OTSA;
            Service_Agreement__c SLSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'E-LGHT', '234567890'); insert SLSA;
            // Create Premise
            Premise__c prem = TestUtility.createPremise(); insert prem;
            // Create Service Point
            Service_Point__c sp = TestUtility.createServicePoint(prem.Id); insert sp;
            
            // Create Work Items
            List<Case> workItems = new List<Case>();
            Case WorkItem5 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 52, '', '', acc.Id, OTSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); insert WorkItem5;
            // Group 1
            Case WorkItem4 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 52, '', '', acc.Id, AGSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem4);
            Case WorkItem6 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 52, '', '', acc.Id, SLSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem6);
            insert workItems;
            workitems = [select Id, SA_Type__c, Interval__c, DA_CCA_IND__c, OwnerId, ParentId, AccountId, Status, User_Skill_Rule__r.Name, Priority_Score__c from Case];
            Set<Id> caseIds = new Set<Id>();
            for(Case c : workItems){
                if(c.SA_Type__c != 'E-AG'){
                    caseIds.add(c.Id);
                }
            }
            GroupingUtility.groupWorkItems(workItems, queueId, new Map<Id, List<User_Skill__c>>(), caseIds);
            update workItems;
            system.assertEquals(WorkItem4.Id, [select ParentId from Case where Id =: WorkItem5.Id].ParentId);
        }
    }
    static testMethod void testGroupingAg4() {
    	Profile p = [select id from profile where name='CSR'];
        UserRole r = [Select id from userrole where name='CSR'];
        User CSR = TestUtility.createUser(p.id,r.id,1); CSR.LAN_ID__C = 'CSR1'; insert CSR;
        User CSR2 = TestUtility.createUser(p.id,r.id,200); CSR2.LAN_ID__C = 'CSR2'; insert CSR2;
        Profile padmin = [select id from profile where name='Administrator'];
        UserRole rbillops = [Select id from userrole where name='Billing Operations'];
        User admin= TestUtility.createUser(padmin.id,rbillops.id,2); admin.LAN_ID__C = 'ADM1'; //insert admin;
        System.runAs(admin){
            Id queueId = [select Id, Name from Group where Name = 'Billing Exceptions' and Type = 'Queue'].Id;
        	Id recordtypeId = [select Id from RecordType where Name='Billing Exceptions' and sObjectType = 'Case'].Id;	
            
            List<User_Skill_Rule__c> usrList = new List<User_Skill_Rule__c>();
            User_Skill_Rule__c DAusr = TestUtility.createUserSkillRule(1, 'PSSTL', null, null, null, 'True', null, null, null, null, null, null, null); DAusr.Name = 'DA CCA PSSTL'; usrList.add(DAusr);
            User_Skill_Rule__c NEMusr = TestUtility.createUserSkillRule(2, 'PSSTL', null, null, 'HN-ERES', null, null, null, null, null, null, null, null); NEMusr.Name = 'NEM PSSTL'; usrList.add(NEMusr);
            User_Skill_Rule__c SLusr = TestUtility.createUserSkillRule(2, 'PSSTL', null, null, 'E-LGHT', null, null, null, null, null, null, null, null); SLusr.Name = 'Streetlight'; usrList.add(SLusr);
            User_Skill_Rule__c AGusr = TestUtility.createUserSkillRule(2, 'PSSTL', null, null, 'E-AG', null, null, null, null, null, null, null, null); AGusr.Name = 'Agricultural'; usrList.add(AGusr);

            insert usrList;
            
            // Create Account
            Account acc = TestUtility.createAccount(date.today() - 60, 'Account 1', '0007652348'); insert acc;
            // Create Service Agreement
            Service_Agreement__c DASA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'E-RES', '1234567890'); insert DASA;
            Service_Agreement__c IntSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'HE-RES', '1234567890'); insert IntSA;
            Service_Agreement__c NEMSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'HN-RES', '1234567890'); insert NEMSA;
            Service_Agreement__c AGSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'E-AG', '1234567890'); insert AGSA;
            Service_Agreement__c OTSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'G-RES', '1234567890'); insert OTSA;
            Service_Agreement__c SLSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'E-LGHT', '234567890'); insert SLSA;
            // Create Premise
            Premise__c prem = TestUtility.createPremise(); insert prem;
            // Create Service Point
            Service_Point__c sp = TestUtility.createServicePoint(prem.Id); insert sp;
            
            // Create Work Items
            List<Case> workItems = new List<Case>();
            Case WorkItem5 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 52, '', '', acc.Id, OTSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); WorkItem5.OwnerId = CSR.Id; insert WorkItem5;
            // Group 1
            Case WorkItem4 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 52, '', '', acc.Id, AGSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); WorkItem4.OwnerId = CSR2.Id; workItems.add(WorkItem4);
            Case WorkItem6 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 52, '', '', acc.Id, SLSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem6);
            insert workItems;
            workitems = [select Id, SA_Type__c, Interval__c, DA_CCA_IND__c, OwnerId, ParentId, AccountId, Status, User_Skill_Rule__r.Name, Priority_Score__c from Case];
            Set<Id> caseIds = new Set<Id>();
            for(Case c : workItems){
                caseIds.add(c.Id);
            }
            GroupingUtility.groupWorkItems(workItems, queueId, new Map<Id, List<User_Skill__c>>(), caseIds);
            update workItems;
            system.assertEquals(WorkItem4.Id, [select ParentId from Case where Id =: WorkItem5.Id].ParentId);
        }
    }
	static testMethod void testGroupingStreetlight() {
    	Profile p = [select id from profile where name='CSR'];
        UserRole r = [Select id from userrole where name='CSR'];
        User CSR= TestUtility.createUser(p.id,r.id,1); CSR.LAN_ID__C = 'CSR1'; insert CSR;
        Profile padmin = [select id from profile where name='Administrator'];
        UserRole rbillops = [Select id from userrole where name='Billing Operations'];
        User admin= TestUtility.createUser(padmin.id,rbillops.id,2); admin.LAN_ID__C = 'ADM1'; //insert admin;
        System.runAs(admin){
            Id queueId = [select Id, Name from Group where Name = 'Billing Exceptions' and Type = 'Queue'].Id;
        	Id recordtypeId = [select Id from RecordType where Name='Billing Exceptions' and sObjectType = 'Case'].Id;	
            
            List<User_Skill_Rule__c> usrList = new List<User_Skill_Rule__c>();
            User_Skill_Rule__c DAusr = TestUtility.createUserSkillRule(1, 'PSSTL', null, null, null, 'True', null, null, null, null, null, null, null); DAusr.Name = 'DA CCA PSSTL'; usrList.add(DAusr);
            User_Skill_Rule__c NEMusr = TestUtility.createUserSkillRule(2, 'PSSTL', null, null, 'HN-ERES', null, null, null, null, null, null, null, null); NEMusr.Name = 'NEM PSSTL'; usrList.add(NEMusr);
            User_Skill_Rule__c SLusr = TestUtility.createUserSkillRule(2, 'PSSTL', null, null, 'E-LGHT', null, null, null, null, null, null, null, null); SLusr.Name = 'Streetlight'; usrList.add(SLusr);
            User_Skill_Rule__c AGusr = TestUtility.createUserSkillRule(2, 'PSSTL', null, null, 'E-AG', null, null, null, null, null, null, null, null); AGusr.Name = 'Agricultural'; usrList.add(AGusr);

            insert usrList;
            
            // Create Account
            Account acc = TestUtility.createAccount(date.today() - 60, 'Account 1', '0007652348'); insert acc;
            // Create Service Agreement
            Service_Agreement__c DASA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'E-RES', '1234567890'); insert DASA;
            Service_Agreement__c IntSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'HE-RES', '1234567890'); insert IntSA;
            Service_Agreement__c NEMSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'HN-RES', '1234567890'); insert NEMSA;
            Service_Agreement__c AGSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'E-AG', '1234567890'); insert AGSA;
            Service_Agreement__c OTSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'G-RES', '1234567890'); insert OTSA;
            Service_Agreement__c SLSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'E-LGHT', '234567890'); insert SLSA;
            // Create Premise
            Premise__c prem = TestUtility.createPremise(); insert prem;
            // Create Service Point
            Service_Point__c sp = TestUtility.createServicePoint(prem.Id); insert sp;
            
            // Create Work Items
            List<Case> workItems = new List<Case>();
            // Group 1
            Case WorkItem5 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 52, '', '', acc.Id, SLSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem5);
            Case WorkItem6 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 52, '', '', acc.Id, SLSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem6);
            insert workItems;
            workitems = [select Id, SA_Type__c, Interval__c, DA_CCA_IND__c, OwnerId, ParentId, AccountId, Status, User_Skill_Rule__r.Name, Priority_Score__c from Case];
            Set<Id> caseIds = new Set<Id>();
            for(Case c : workItems){
                caseIds.add(c.Id);
            }
            GroupingUtility.groupWorkItems(workItems, queueId, new Map<Id, List<User_Skill__c>>(), caseIds);
            update workItems;
            system.assertEquals(WorkItem5.Id, [select ParentId from Case where Id =: WorkItem6.Id].ParentId);
        }
    }    
    static testMethod void testGroupingOther() {
    	Profile p = [select id from profile where name='CSR'];
        UserRole r = [Select id from userrole where name='CSR'];
        User CSR= TestUtility.createUser(p.id,r.id,1); CSR.LAN_ID__C = 'CSR1'; insert CSR;
        Profile padmin = [select id from profile where name='Administrator'];
        UserRole rbillops = [Select id from userrole where name='Billing Operations'];
        User admin= TestUtility.createUser(padmin.id,rbillops.id,2); admin.LAN_ID__C = 'ADM1'; //insert admin;
        System.runAs(admin){
            Id queueId = [select Id, Name from Group where Name = 'Billing Exceptions' and Type = 'Queue'].Id;
        	Id recordtypeId = [select Id from RecordType where Name='Billing Exceptions' and sObjectType = 'Case'].Id;	
            
            List<User_Skill_Rule__c> usrList = new List<User_Skill_Rule__c>();
            User_Skill_Rule__c DAusr = TestUtility.createUserSkillRule(1, 'PSSTL', null, null, null, 'True', null, null, null, null, null, null, null); DAusr.Name = 'DA CCA PSSTL'; usrList.add(DAusr);
            User_Skill_Rule__c NEMusr = TestUtility.createUserSkillRule(2, 'PSSTL', null, null, 'HN-ERES', null, null, null, null, null, null, null, null); NEMusr.Name = 'NEM PSSTL'; usrList.add(NEMusr);
            User_Skill_Rule__c SLusr = TestUtility.createUserSkillRule(2, 'PSSTL', null, null, 'E-LGHT', null, null, null, null, null, null, null, null); SLusr.Name = 'Streetlight'; usrList.add(SLusr);
            User_Skill_Rule__c AGusr = TestUtility.createUserSkillRule(2, 'PSSTL', null, null, 'E-AG', null, null, null, null, null, null, null, null); AGusr.Name = 'Agricultural'; usrList.add(AGusr);

            insert usrList;
            
            // Create Account
            Account acc = TestUtility.createAccount(date.today() - 60, 'Account 1', '0007652348'); insert acc;
            // Create Service Agreement
            Service_Agreement__c DASA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'E-RES', '1234567890'); insert DASA;
            Service_Agreement__c IntSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'HE-RES', '1234567890'); insert IntSA;
            Service_Agreement__c NEMSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'HN-RES', '1234567890'); insert NEMSA;
            Service_Agreement__c AGSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'E-AG', '1234567890'); insert AGSA;
            Service_Agreement__c OTSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'G-RES', '1234567890'); insert OTSA;
            Service_Agreement__c SLSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'E-LGHT', '234567890'); insert SLSA;
            // Create Premise
            Premise__c prem = TestUtility.createPremise(); insert prem;
            // Create Service Point
            Service_Point__c sp = TestUtility.createServicePoint(prem.Id); insert sp;
            
            // Create Work Items
            List<Case> workItems = new List<Case>();
            // Group 1
            Case WorkItem5 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 52, '', '', acc.Id, OTSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem5);
            Case WorkItem6 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 52, '', '', acc.Id, OTSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem6);
            insert workItems;
            workitems = [select Id, SA_Type__c, Interval__c, DA_CCA_IND__c, OwnerId, ParentId, AccountId, Status, User_Skill_Rule__r.Name, Priority_Score__c from Case];
            Set<Id> caseIds = new Set<Id>();
            for(Case c : workItems){
                caseIds.add(c.Id);
            }
            GroupingUtility.groupWorkItems(workItems, queueId, new Map<Id, List<User_Skill__c>>(), caseIds);
            update workItems;
            system.assertEquals(WorkItem5.Id, [select ParentId from Case where Id =: WorkItem6.Id].ParentId);
        }
    }*/
}