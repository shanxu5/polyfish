@isTest
public class TestpopulateUserSkillRule {
    
    static testMethod void test_populateUserSkillRule()
    {   
        // Create Test Users
        Profile p = [select id from profile where name='CSR'];
        UserRole r = [Select id from userrole where name='CSR'];
        Profile padmin = [select id from profile where name='Administrator'];
        UserRole rbillops = [Select id from userrole where name='Billing Operations'];
        Profile pbillOpsHead = [select id from profile where name='Billing Ops Head'];
        UserRole rSupervisor = [Select id from userrole where name='Supervisor'];
        User admin= TestUtility.createUser(padmin.id,rbillops.id,3); insert admin;
        User supervisor= TestUtility.createUser(pbillOpsHead.id,rSupervisor.id,4); supervisor.LAN_ID__c = 'SUP1'; insert supervisor;
        User CSR= TestUtility.createUser(p.id,r.id,1);  CSR.Supervisor__c = supervisor.Id; CSR.Lan_ID__c = 'CSR1'; insert CSR;
        User CSR2= TestUtility.createUser(p.id,r.id,2); CSR2.Supervisor__c = supervisor.Id; CSR2.Lan_ID__c = 'CSR2'; insert CSR2;
        User CSR3= TestUtility.createUser(p.id,r.id,5); CSR3.Supervisor__c = supervisor.Id; CSR3.Lan_ID__c = 'CSR3'; insert CSR3;
        
      	// Query Queue
        //Id queueId = [select Id, Name from Group where Name = 'Billing Exceptions' and Type = 'Queue'].Id;
        Id queueId = WorkItemAssignmentUtility.getBillingExceptionQueueId();
        Id recordtypeId = [select Id from RecordType where Name='Billing Exceptions' and sObjectType = 'Case'].Id;
        
        //Id recordtypeIdCase = [select Id from RecordType where Name='CC&B Billing Ops Cases' and sObjectType = 'Case'].Id;

        //User Skill records
        //User_Skill__c  userSkill1;
        //User_Skill__c  userSkill2;
        System.runAs(admin){
  			               
            // Create Account
            Account acc = TestUtility.createAccount(date.today() - 60, 'Account 1', '0007652348'); 
            acc.Postpone_Credit_Date__c = date.today();
            insert acc;
            // Create Service Agreement
            Service_Agreement__c DASA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'HE-RES', '1234567890'); insert DASA;
            // Create Premise
            Premise__c prem = TestUtility.createPremise(); insert prem;
            // Create Service Point
            Service_Point__c sp = TestUtility.createServicePoint(prem.Id); insert sp;
            // Create TurnOnAssignmentandGrouping__c
            TurnOnAssignmentandGrouping__c turnOnBSEG = TestUtility.createTurnOnAssignmentandGrouping('BSEG', true, true); insert turnOnBSEG;
            TurnOnAssignmentandGrouping__c turnOnPSSTL = TestUtility.createTurnOnAssignmentandGrouping('PSSTL', false, true); insert turnOnPSSTL;
            // Create Lookup Rollup Summary
            dlrs__LookupRollupSummary__c dlrs = TestUtility.createLookupRollupSummary(); insert dlrs;
            // Create User Skill Rule
            List<User_Skill_Rule__c> usrList = new List<User_Skill_Rule__c>();
            
			//Tae - manual update to custom settings
            UserSkillRulesAndCaseMap__c cs = TestUtility.userSkillcustomsetting('Priority_Goal__c', 'validateGreaterOrEqual', 'Priority_Adjustment__c', 'Decimal', 'Decimal');
			insert cs;

            // Test days late age evaluator
            User_Skill_Rule__c usr_PSSTL_Interval_eq = TestUtility.createUserSkillRule(20, 'PSSTL' , '', 'False', '', '', '', '', '', 'equals', 1, '', '', null); 
            usr_PSSTL_Interval_eq.Medical_Allotment__c = 1.0;
            usr_PSSTL_Interval_eq.Medical_Allotment_Evaluator__c = 'equals';
            usr_PSSTL_Interval_eq.Priority_Goal__c = 10;
            usr_PSSTL_Interval_eq.Name = 'usr_PSSTL_Interval_eq'; usrList.add(usr_PSSTL_Interval_eq);
                        
            User_Skill_Rule__c usr_PSSTL_Interval_ne = TestUtility.createUserSkillRule(21, 'PSSTL' , '', 'False', '', '', '', '', '', 'not equal to', 2, '', '', null); 
            usr_PSSTL_Interval_ne.Medical_Allotment__c = 1.0;
            usr_PSSTL_Interval_ne.Medical_Allotment_Evaluator__c = 'not equal to';
            usr_PSSTL_Interval_ne.Name = 'usr_PSSTL_Interval_ne'; usrList.add(usr_PSSTL_Interval_ne);
            
            User_Skill_Rule__c usr_PSSTL_Interval_lt = TestUtility.createUserSkillRule(22, 'PSSTL' , '', 'False', '', '', '', '', '', 'less than', 3, '', '', null); 
            usr_PSSTL_Interval_lt.Medical_Allotment__c = 1.0;
            usr_PSSTL_Interval_lt.Medical_Allotment_Evaluator__c = 'less than';
            usr_PSSTL_Interval_lt.Name = 'usr_PSSTL_Interval_lt'; usrList.add(usr_PSSTL_Interval_lt);
            
            User_Skill_Rule__c usr_PSSTL_Interval_gt = TestUtility.createUserSkillRule(23, 'PSSTL' , '', 'False', '', '', '', '', '', 'greater than', 4, '', '', null); 
            usr_PSSTL_Interval_gt.Medical_Allotment__c = 1.0;
            usr_PSSTL_Interval_gt.Medical_Allotment_Evaluator__c = 'greater than';
            usr_PSSTL_Interval_gt.Name = 'usr_PSSTL_Interval_gt'; usrList.add(usr_PSSTL_Interval_gt);
            
            User_Skill_Rule__c usr_PSSTL_Interval_loe = TestUtility.createUserSkillRule(24, 'PSSTL' , '', 'False', '', '', '', '', '', 'less or equal', 5, '', '', null); 
            usr_PSSTL_Interval_loe.Medical_Allotment__c = 1.0;
            usr_PSSTL_Interval_loe.Medical_Allotment_Evaluator__c = 'less or equal';
            usr_PSSTL_Interval_loe.Name = 'usr_PSSTL_Interval_loe'; usrList.add(usr_PSSTL_Interval_loe);
            
            User_Skill_Rule__c usr_PSSTL_Interval_goe = TestUtility.createUserSkillRule(25, 'PSSTL' , '', 'False', '', '', '', '', '', 'greater or equal', 6, '', '', null); 
            usr_PSSTL_Interval_goe.Medical_Allotment__c = 1.0;
            usr_PSSTL_Interval_goe.Medical_Allotment_Evaluator__c = 'greater or equal';
            usr_PSSTL_Interval_goe.Name = 'usr_PSSTL_Interval_goe'; usrList.add(usr_PSSTL_Interval_goe);
			
            User_Skill_Rule__c Betweenusr = TestUtility.createUserSkillRule(26, 'PSSTL', null, null, null, null, null, null, null, 'between', 60, null, null, null);
            Betweenusr.Medical_Allotment__c = 1.0;
            Betweenusr.Medical_Allotment_Evaluator__c = 'between';
            Betweenusr.Name = 'between'; Betweenusr.Age_Bucket_End__c = 70; usrList.add(Betweenusr);


            // Test Medical Allotment evaluators for Medical Exception WIs
            User_Skill_Rule__c usr_Medical_Exception_equals = TestUtility.createUserSkillRule(30, 'Medical Exceptions' , '', 'False', '', '', '', '', '', 'equals', 6, '', '', null); 
            usr_Medical_Exception_equals.Name = 'usr_Medical_Exception_equals'; 
            usr_Medical_Exception_equals.Medical_Allotment__c = 1.0;
            usr_Medical_Exception_equals.Medical_Allotment_Evaluator__c = 'equals';
            usrList.add(usr_Medical_Exception_equals);
            
            User_Skill_Rule__c usr_Medical_Exception_ne     = TestUtility.createUserSkillRule(31, 'Medical Exceptions' , '', 'False', '', '', '', '', '', 'not equal to', 2, '', '', null); 
            usr_Medical_Exception_ne.Name = 'usr_Medical_Exception_ne'; 
            usr_Medical_Exception_ne.Medical_Allotment__c = 1.0;
            usr_Medical_Exception_ne.Medical_Allotment_Evaluator__c = 'not equal to';
            usrList.add(usr_Medical_Exception_ne);
            
            User_Skill_Rule__c usr_Medical_Exception_lt     = TestUtility.createUserSkillRule(32, 'Medical Exceptions' , '', 'False', '', '', '', '', '', 'less than', 6, '', '', null); 
            usr_Medical_Exception_lt.Name = 'usr_Medical_Exception_lt'; 
            usr_Medical_Exception_lt.Medical_Allotment__c = 1.0;
            usr_Medical_Exception_lt.Medical_Allotment_Evaluator__c = 'less than';
            usrList.add(usr_Medical_Exception_lt);
            
            User_Skill_Rule__c usr_Medical_Exception_gt     = TestUtility.createUserSkillRule(33, 'Medical Exceptions' , '', 'False', '', '', '', '', '', 'greater than', 4, '', '', null); 
            usr_Medical_Exception_gt.Name = 'usr_Medical_Exception_gt'; 
            usr_Medical_Exception_gt.Medical_Allotment__c = 1.0;
            usr_Medical_Exception_gt.Medical_Allotment_Evaluator__c = 'greater than';
            usrList.add(usr_Medical_Exception_gt);
            
            User_Skill_Rule__c usr_Medical_Exception_loe    = TestUtility.createUserSkillRule(34, 'Medical Exceptions' , '', 'False', '', '', '', '', '', 'less or equal', 5, '', '', null); 
            usr_Medical_Exception_loe.Name = 'usr_Medical_Exception_loe'; 
            usr_Medical_Exception_loe.Medical_Allotment__c = 1.0;
            usr_Medical_Exception_loe.Medical_Allotment_Evaluator__c = 'less or equal';
            usrList.add(usr_Medical_Exception_loe);
            
            User_Skill_Rule__c usr_Medical_Exception_goe    = TestUtility.createUserSkillRule(35, 'Medical Exceptions' , '', 'False', '', '', '', '', '', 'greater or equal', 6, '', '', null); 
            usr_Medical_Exception_goe.Name = 'usr_Medical_Exception_goe'; 
            usr_Medical_Exception_goe.Medical_Allotment__c = 1.0;
            usr_Medical_Exception_goe.Medical_Allotment_Evaluator__c = 'greater or equal';
            usrList.add(usr_Medical_Exception_goe);
            
            User_Skill_Rule__c usr_Medical_Exception_between    = TestUtility.createUserSkillRule(35, 'Medical Exceptions' , '', 'False', '', '', '', '', '', 'between', 6, '', '', null); 
            usr_Medical_Exception_between.Name = 'usr_Medical_Exception_between'; 
            usr_Medical_Exception_between.Medical_Allotment__c = 1.0;
            usr_Medical_Exception_between.Medical_Allotment_Evaluator__c = 'between';
            usrList.add(usr_Medical_Exception_between);
            
            User_Skill_Rule__c muliple_pstl    = TestUtility.createUserSkillRule(36, 'PSTL; Retro Commencing; QAS8; Delayed Bills; BSEG' , '', 'False', '', '', '', '', '', 'between', 6, '', '', null); 
            usr_Medical_Exception_between.Name = 'usr_muliple_pstl'; 
            //usr_Medical_Exception_between.Medical_Allotment__c = 1.0;
            //usr_Medical_Exception_between.Medical_Allotment_Evaluator__c = 'between';
            usrList.add(muliple_pstl);

			User_Skill_Rule__c QAS8    = TestUtility.createUserSkillRule(37, 'QAS8' , '', 'False', '', '', '', '', '', 'between', 6, '', '', null); 
            usr_Medical_Exception_between.Name = 'QAS8'; 
            //usr_Medical_Exception_between.Medical_Allotment__c = 1.0;
            //usr_Medical_Exception_between.Medical_Allotment_Evaluator__c = 'between';
            usrList.add(QAS8);
            /*
			User_Skill_Rule__c TRUEusr = TestUtility.createUserSkillRule(100, 'PSSTL', 'True', 'True', 'HE-RES', 'True', '90000', '24164', 'True', null, null, 'True', 'Pending Start', null); TRUEusr.Name = 'True'; 
            TRUEusr.SMSPST__c = '10';
            usrList.add(TRUEusr);
            User_Skill_Rule__c LessThanusr = TestUtility.createUserSkillRule(2, null, null, null, null, null, null, null, null, 'less than', 1, null, null, null); LessThanusr.Name = 'less than'; usrList.add(LessThanusr);
            User_Skill_Rule__c LessOrEqualusr = TestUtility.createUserSkillRule(3, null, null, null, null, null, null, null, null, 'less or equal', 1, null, null, null); LessOrEqualusr.Name = 'less or equal'; usrList.add(LessOrEqualusr);
            User_Skill_Rule__c Betweenusr = TestUtility.createUserSkillRule(4, null, null, null, null, null, null, null, null, 'between', 60, null, null, null); Betweenusr.Name = 'between'; Betweenusr.Age_Bucket_End__c = 70; usrList.add(Betweenusr);
            User_Skill_Rule__c GreaterThanusr = TestUtility.createUserSkillRule(5, null, null, null, null, null, null, null, null, 'greater than', 100, null, null, null); GreaterThanusr.Name = 'greater than'; usrList.add(GreaterThanusr);
           	User_Skill_Rule__c GreaterOrEqualusr = TestUtility.createUserSkillRule(6, null, null, null, null, null, null, null, null, 'greater or equal', 100, null, null, null); GreaterOrEqualusr.Name = 'greater or equal'; usrList.add(GreaterOrEqualusr);
            User_Skill_Rule__c Equalsusr = TestUtility.createUserSkillRule(7, null, null, null, null, null, null, null, null, 'equals', 60, null, null, null); Equalsusr.Name = 'Equals'; usrList.add(Equalsusr);
            User_Skill_Rule__c NotEqualsusr = TestUtility.createUserSkillRule(8, 'Retro Commencing', null, null, null, null, null, null, null, 'not equal to', 60, null, null, null); NotEqualsusr.Name = 'not equal to'; usrList.add(NotEqualsusr);
            User_Skill_Rule__c NULLusr = TestUtility.createUserSkillRule(9, null, null, null, null, null, null, null, null, null, null, null, null, null); NULLusr.Name = 'NULL'; usrList.add(NULLusr);
			*/
            
            //test commencing bill  
            User_Skill_Rule__c commen_bill = TestUtility.createUserSkillRule(45, 'PSSTL', 'True', 'True', 'HE-RES', 'True', '90000', '24164', 'True', null, null, 'True', 'Pending Stop', null); 
			commen_bill.Medical_Allotment__c = 1.0;            
            commen_bill.Medical_Allotment_Evaluator__c = 'between';
            commen_bill.Name = 'commen_bill'; 
            usrList.add(commen_bill);
			  
            insert usrList;
            // Create Work Items
            Case WorkItemTrue = TestUtility.CreateWorkItem('40', 'PSSTL', 'Pending Start', null, '24164', '90000', acc.Id, DASA.Id, true, prem.Id, sp.Id, queueId, recordtypeId); 
            WorkItemTrue.Mtr_Config_Ty_Cd__c='SM 40'; 
            WorkItemTrue.SMSPST__c = '10';
			//WorkItemTrue.Age_c = 9; // setting the wi age number
            WorkItemTrue.Priority_Adjustment__c = 9; // setting the wi age number
            WorkItemTrue.Days_Deferred__c = 9; // setting the wi age number
            WorkItemTrue.Commencing_Bill__c = true;

            Case MedicalExceptionWorkItemTrue = TestUtility.CreateWorkItem('40', 'Medical Exceptions', 'Pending Start', null, '24164', '90000', acc.Id, DASA.Id, true, prem.Id, sp.Id, queueId, recordtypeId); 
            MedicalExceptionWorkItemTrue.Medical_Allotment__c = 1.0;
            MedicalExceptionWorkItemTrue.Mtr_Config_Ty_Cd__c='SM 40'; 
            MedicalExceptionWorkItemTrue.SMSPST__c = '10';
            MedicalExceptionWorkItemTrue.Priority_Adjustment__c = 9; // setting the wi age number
            MedicalExceptionWorkItemTrue.Days_Deferred__c = 9; // setting the wi age number
            MedicalExceptionWorkItemTrue.Commencing_Bill__c = true;

            // this will trigger the case trigger handler class
            Insert MedicalExceptionWorkItemTrue;
            
            // Tae - this will trigger the case traigger handler class
            Insert WorkItemTrue; 	
                
            // Validate that the Work Item got created correctly with the correct User Skill Rule
            Case wi = [select Interval__c, Metered__c, SA_Type__c, DA_CCA_Ind__c, User_Skill_Rule__r.Name, Message_Category_Number__c, Message_Number__c from Case where Id =: WorkItemTrue.Id];
system.assert(wi.Interval__c,'The Interval__c value');
system.assert(wi.Metered__c);
system.assert(wi.DA_CCA_Ind__c);
system.assertEquals('HE-RES', wi.SA_Type__c);
system.assertEquals('90000', wi.Message_Category_Number__c);
system.assertEquals('24164', wi.Message_Number__c);
			//system.assertEquals(TRUEusr.Name, wi.User_Skill_Rule__r.Name); // name is null
			//Case WorkItemFalse = TestUtility.CreateWorkItem(null, null, null, null, '', '', acc.Id, null, false, null, null, queueId, recordtypeId); Insert WorkItemFalse; //result null 
            // Validate that the Case have the correct User Skill Rule rule
			//system.assertEquals(NULLusr.Id, [select User_Skill_Rule__c from Case where Id =: WorkItemFalse.Id].User_Skill_Rule__c);

			//Starting the testing for refactoring populdated trigger
            //update custom setting with new validation methodsd
            //trigger populdatin user skills rules by updateing/ inserting the work item 
			system.debug(Logginglevel.INFO,'******Before entering to update validateLessOrEqual:' + cs );
            cs.Validation_Method__c = 'validateLessOrEqual'; //TestUtility.userSkillcustomsetting('Priority_Goal__c', 'validateLessOrEqual', 'Priority_Adjustment__c', 'Decimal', 'Decimal');
			update cs;
            Case validateLessOrEqual = TestUtility.CreateWorkItem('40', 'PSSTL', 'Pending Start', null, '24164', '90000', acc.Id, DASA.Id, true, prem.Id, sp.Id, queueId, recordtypeId); 
            validateLessOrEqual.Mtr_Config_Ty_Cd__c='SM 40'; 
            validateLessOrEqual.SMSPST__c = '10';
			//WorkItemTrue.Age_c = 9; // setting the wi age number
            validateLessOrEqual.Priority_Adjustment__c = 10; // setting the wi age number
            validateLessOrEqual.Commencing_Bill__c = true;
            Insert validateLessOrEqual; 
            system.debug(Logginglevel.INFO,'*******AFTER update validateLessOrEqual:' + cs);
            
            /////
            system.debug(Logginglevel.INFO,'******Before entering to update validateGreaterThan:' + cs );
            cs.Validation_Method__c = 'validateGreaterThan'; //TestUtility.userSkillcustomsetting('Priority_Goal__c', 'validateLessOrEqual', 'Priority_Adjustment__c', 'Decimal', 'Decimal');
			update cs;
            Case validateGreaterThan = TestUtility.CreateWorkItem('40', 'PSSTL', 'Pending Start', null, '24164', '90000', acc.Id, DASA.Id, true, prem.Id, sp.Id, queueId, recordtypeId); 
            validateGreaterThan.Mtr_Config_Ty_Cd__c='SM 40'; 
            validateGreaterThan.SMSPST__c = '10';
            validateGreaterThan.Priority_Adjustment__c = 10; // setting the wi age number
            validateGreaterThan.Commencing_Bill__c = true;
            Insert validateGreaterThan; 
            system.debug(Logginglevel.INFO,'*******AFTER update validateGreaterThan:' + cs);
            //////
            
			system.debug(Logginglevel.INFO,'******Before entering to update validateEquals:' + cs );
            cs.Validation_Method__c = 'validateEquals'; //TestUtility.userSkillcustomsetting('Priority_Goal__c', 'validateLessOrEqual', 'Priority_Adjustment__c', 'Decimal', 'Decimal');
			update cs;
            Case validateEquals = TestUtility.CreateWorkItem('40', 'PSSTL', 'Pending Start', null, '24164', '90000', acc.Id, DASA.Id, true, prem.Id, sp.Id, queueId, recordtypeId); 
            validateEquals.Mtr_Config_Ty_Cd__c='SM 40'; 
            validateEquals.SMSPST__c = '10';
            validateEquals.Priority_Adjustment__c = 10; // setting the wi age number
            validateEquals.Commencing_Bill__c = true;
            Insert validateEquals; 
            system.debug(Logginglevel.INFO,'*******AFTER update validateEquals:' + cs);
                        
			system.debug(Logginglevel.INFO,'******Before entering to update validateNotEqualTo:' + cs );
            cs.Validation_Method__c = 'validateNotEqualTo'; //TestUtility.userSkillcustomsetting('Priority_Goal__c', 'validateLessOrEqual', 'Priority_Adjustment__c', 'Decimal', 'Decimal');
			update cs;
            Case validateNotEqualTo = TestUtility.CreateWorkItem('40', 'PSSTL', 'Pending Start', null, '24164', '90000', acc.Id, DASA.Id, true, prem.Id, sp.Id, queueId, recordtypeId); 
            validateNotEqualTo.Mtr_Config_Ty_Cd__c='SM 40'; 
            validateNotEqualTo.SMSPST__c = '10';
            validateNotEqualTo.Priority_Adjustment__c = 10; // setting the wi age number
            validateNotEqualTo.Commencing_Bill__c = true;
            Insert validateNotEqualTo; 
            system.debug(Logginglevel.INFO,'*******AFTER update validateNotEqualTo:' + cs);
            
            
			system.debug(Logginglevel.INFO,'******Before entering to update validateLessThan:' + cs );
            cs.Validation_Method__c = 'validateLessThan'; //TestUtility.userSkillcustomsetting('Priority_Goal__c', 'validateLessOrEqual', 'Priority_Adjustment__c', 'Decimal', 'Decimal');
			update cs;
            Case validateLessThan = TestUtility.CreateWorkItem('40', 'PSTL; Retro Commencing; QAS8; Delayed Bills; BSEG', 'Pending Start', null, '24164', '90000', acc.Id, DASA.Id, true, prem.Id, sp.Id, queueId, recordtypeId); 
            //Case validateLessThan = TestUtility.CreateWorkItem('40', 'Employee Deceased Pensioners', 'Pending Start', null, '24164', '90000', acc.Id, DASA.Id, true, prem.Id, sp.Id, queueId, recordtypeId); 
            //Case validateLessThan = TestUtility.CreateWorkItem('40', 'QAS8', 'Pending Start', null, '24164', '90000', acc.Id, DASA.Id, true, prem.Id, sp.Id, queueId, recordtypeId); 
            validateLessThan.Mtr_Config_Ty_Cd__c='SM 40'; 
            validateLessThan.SMSPST__c = '10';
            validateLessThan.Priority_Adjustment__c = 10; // setting the wi age number
            validateLessThan.Commencing_Bill__c = true;
            Insert validateLessThan; 
            system.debug(Logginglevel.INFO,'*******AFTER update validateLessThan:' + cs);           
    
			system.debug(Logginglevel.INFO,'******Before entering to update validateLessThan:' + cs );
            cs.Validation_Method__c = 'validateLessThan'; //TestUtility.userSkillcustomsetting('Priority_Goal__c', 'validateLessOrEqual', 'Priority_Adjustment__c', 'Decimal', 'Decimal');
			update cs;
            //Case validateLessThan_tae = TestUtility.CreateWorkItem('40', 'PSTL', 'Pending Start', null, '24164', '90000', acc.Id, DASA.Id, true, prem.Id, sp.Id, queueId, recordtypeId); 
            //Case validateLessThan = TestUtility.CreateWorkItem('40', 'Employee Deceased Pensioners', 'Pending Start', null, '24164', '90000', acc.Id, DASA.Id, true, prem.Id, sp.Id, queueId, recordtypeId); 
            Case validateLessThan_tae = TestUtility.CreateWorkItem('40', 'QAS8', 'Pending Start', null, '24164', '90000', acc.Id, DASA.Id, true, prem.Id, sp.Id, queueId, recordtypeId); 
            validateLessThan_tae.Mtr_Config_Ty_Cd__c='SM 40'; 
            validateLessThan_tae.SMSPST__c = '10';
            validateLessThan_tae.Priority_Adjustment__c = 10; // setting the wi age number
            validateLessThan_tae.Commencing_Bill__c = true;
            Insert validateLessThan_tae; 
            system.debug(Logginglevel.INFO,'*******AFTER update validateLessThan:' + cs);           
            

	    }
    }

}