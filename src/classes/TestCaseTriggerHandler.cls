/**

 */
@isTest
private class TestCaseTriggerHandler {
	// This method tests populateUserSkillRule
    static testMethod void populateUserSkillRule() {
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
            Case validateLessThan = TestUtility.CreateWorkItem('40', 'PSSTL', 'Pending Start', null, '24164', '90000', acc.Id, DASA.Id, true, prem.Id, sp.Id, queueId, recordtypeId); 
            validateLessThan.Mtr_Config_Ty_Cd__c='SM 40'; 
            validateLessThan.SMSPST__c = '10';
            validateLessThan.Priority_Adjustment__c = 10; // setting the wi age number
            validateLessThan.Commencing_Bill__c = true;
            Insert validateLessThan; 
            system.debug(Logginglevel.INFO,'*******AFTER update validateLessThan:' + cs);
            
             
 	  }

    }
	/*
    static testMethod void populateUserSkillRule2() {
      // Query Queue
        Id queueId = [select Id, Name from Group where Name = 'Billing Exceptions' and Type = 'Queue'].Id;
        Id recordtypeId = [select Id from RecordType where Name='Billing Exceptions' and sObjectType = 'Case'].Id;
        
        //User Skill records
        User_Skill__c  userSkill1;
        User_Skill__c  userSkill2;
        
        // Create Account
        Account acc = TestUtility.createAccount(date.today() - 60, 'Account 1', '0007652348'); insert acc;
        // Create Service Agreement
        Service_Agreement__c DASA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'E-RES', '1234567890'); insert DASA;
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
        User_Skill_Rule__c TRUEusr = TestUtility.createUserSkillRule(1, 'PSSTL', 'True', 'True', 'E-RES', 'True', null, null, null, null, null, 'True', 'Pending Start'); TRUEusr.Name = 'True'; 
        TRUEusr.SMSPST__c = '10';
        usrList.add(TRUEusr);
        User_Skill_Rule__c LessThanusr = TestUtility.createUserSkillRule(4, null, null, null, null, null, null, null, null, 'less than', 1, null, null); LessThanusr.Name = 'less than'; usrList.add(LessThanusr);
        User_Skill_Rule__c LessOrEqualusr = TestUtility.createUserSkillRule(6, null, null, null, null, null, null, null, null, 'less or equal', 1, null, null); LessOrEqualusr.Name = 'less or equal'; usrList.add(LessOrEqualusr);
        User_Skill_Rule__c Betweenusr = TestUtility.createUserSkillRule(8, null, null, null, null, null, null, null, null, 'between', 60, null, null); Betweenusr.Name = 'between'; Betweenusr.Age_Bucket_End__c = 70; usrList.add(Betweenusr);
        User_Skill_Rule__c NOTusr = TestUtility.createUserSkillRule(8, null, null, null, null, null, null, null, null, 'not', 60, null, null); NOTusr.Name = 'Not'; usrList.add(NOTusr);
        User_Skill_Rule__c NULLusr = TestUtility.createUserSkillRule(9, null, null, null, null, null, null, null, null, null, null, null, null); NULLusr.Name = 'NULL'; usrList.add(NULLusr);
        insert usrList;
        //system.assertEquals(9, usrList.size());
        // Create Work Items
        Case WorkItemTrue = TestUtility.CreateWorkItem('40', 'PSSTL', 'Pending Start', null, '', '', acc.Id, DASA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); 
          WorkItemTrue.Mtr_Config_Ty_Cd__c='SM 40'; 
          WorkItemTrue.SMSPST__c = '10';
          WorkItemTrue.Commencing_Bill__c = true;
          Insert WorkItemTrue;
        Case WorkItemFalse = TestUtility.CreateWorkItem(null, null, null, date.today() - 2, '', '', acc.Id, null, false, prem.Id, sp.Id, queueId, recordtypeId); Insert WorkItemFalse;
        //system.assertEquals(userSkill1.Id, [select User_Skill_Rule__c from Case where Id =: WorkItem1.Id].User_Skill_Rule__c);
    }
    */
	/*
    static testMethod void testGroupWorkItems() {
      Profile p = [select id from profile where name='CSR'];
        UserRole r = [Select id from userrole where name='CSR'];
        Profile padmin = [select id from profile where name='Administrator'];
        UserRole rbillops = [Select id from userrole where name='Billing Operations'];
        Profile pbillOpsHead = [select id from profile where name='Billing Ops Head'];
        UserRole rSupervisor = [Select id from userrole where name='Supervisor'];
        User admin= TestUtility.createUser(padmin.id,rbillops.id,3); admin.LAN_ID__c = 'ADM1'; insert admin;
        User supervisor= TestUtility.createUser(pbillOpsHead.id,rSupervisor.id,4);supervisor.LAN_ID__c = 'SUP1'; insert supervisor;
        User CSR= TestUtility.createUser(p.id,r.id,1);  CSR.Supervisor__c = supervisor.Id; CSR.LAN_ID__c = 'CSR1'; insert CSR;
        User CSR2= TestUtility.createUser(p.id,r.id,2); CSR2.Supervisor__c = supervisor.Id; CSR2.LAN_ID__c = 'CSR2'; insert CSR2;
        User CSR3= TestUtility.createUser(p.id,r.id,5); CSR3.Supervisor__c = supervisor.Id; CSR3.LAN_ID__c = 'CSR3'; insert CSR3;

        System.runAs(admin){
            Id queueId = [select Id, Name from Group where Name = 'Billing Exceptions' and Type = 'Queue'].Id;
          Id recordtypeId = [select Id from RecordType where Name='Billing Exceptions' and sObjectType = 'Case'].Id;  
            // Create Bill Cycle Window
            Bill_Cycle_Window__c bcw = TestUtility.createBillCycleWindow(); insert bcw;
            // Create TurnOnAssignmentandGrouping__c
            List<TurnOnAssignmentandGrouping__c> turnOnOffList = new List<TurnOnAssignmentandGrouping__c>();
            TurnOnAssignmentandGrouping__c turnOnBSEG = TestUtility.createTurnOnAssignmentandGrouping('BSEG', true, true); turnOnOffList.add(turnOnBSEG);
            TurnOnAssignmentandGrouping__c turnOnPSSTL = TestUtility.createTurnOnAssignmentandGrouping('PSSTL', true, true); turnOnOffList.add(turnOnPSSTL);
            TurnOnAssignmentandGrouping__c turnOnRetroCommencing = TestUtility.createTurnOnAssignmentandGrouping('Retro Commencing', false, true); turnOnOffList.add(turnOnRetroCommencing);
            insert turnOnOffList;
            
            List<User_Skill_Rule__c> usrList = new List<User_Skill_Rule__c>();
            User_Skill_Rule__c DAusr = TestUtility.createUserSkillRule(1, 'PSSTL', null, null, null, 'True', null, null, null, null, null, null, null); DAusr.Name = 'DA CCA PSSTL'; usrList.add(DAusr);
            User_Skill_Rule__c NEMusr = TestUtility.createUserSkillRule(2, 'PSSTL', null, null, 'HN-ERES', null, null, null, null, null, null, null, null); NEMusr.Name = 'NEM PSSTL'; usrList.add(NEMusr);
            User_Skill_Rule__c SLusr = TestUtility.createUserSkillRule(3, 'PSSTL', null, null, 'E-LGHT', null, null, null, null, null, null, null, null); SLusr.Name = 'Streetlight'; usrList.add(SLusr);
            User_Skill_Rule__c AGusr = TestUtility.createUserSkillRule(4, 'PSSTL', null, null, 'E-AG', null, null, null, null, null, null, null, null); AGusr.Name = 'Agricultural'; usrList.add(AGusr);
            insert usrList;
            // Create Work Item Assignments and User Skills
            List<Work_Item_Assignment__c> wiaList = new List<Work_Item_Assignment__c>();
            Work_Item_Assignment__c wia = TestUtility.createWorkItemAssignment(CSR.Id, true); wia.Limit__c = 2; wiaList.add(wia); //insert wia;
            Work_Item_Assignment__c wia2 = TestUtility.createWorkItemAssignment(CSR2.Id, true); wia2.Limit__c = 1; wiaList.add(wia2); //insert wia2;
            Work_Item_Assignment__c wia3 = TestUtility.createWorkItemAssignment(CSR3.Id, true); wia3.Limit__c = 1; wiaList.add(wia3);//insert wia3;
            insert wiaList;
            
            List<User_Skill__c> userSkillList = new List<User_Skill__c>();
            User_Skill__c userSkill1 = TestUtility.createUserSkill(NEMusr.id,wia.id,wia);userSkillList.add(userSkill1); //Insert userSkill1;
            User_Skill__c userSkill2 = TestUtility.createUserSkill(NEMusr.id,wia2.id,wia2);userSkillList.add(userSkill2); // Insert userSkill2;
            User_Skill__c userSkill3 = TestUtility.createUserSkill(DAusr.id,wia3.id,wia3);userSkillList.add(userSkill3); // Insert userSkill3;
            insert userSkillList;
            
            // Create Account
            Account acc = TestUtility.createAccount(date.today() - 60, 'Account 1', '0007652348'); insert acc;
            Account acc2 = TestUtility.createAccount(date.today() - 60, 'Account 2', '0007652350'); insert acc2;
            // Create Service Agreement
            Service_Agreement__c DASA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'E-RES', '1234567890'); insert DASA;
            Service_Agreement__c IntSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'HE-RES', '1234567890'); insert IntSA;
            Service_Agreement__c NEMSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'HN-ERES', '1234567890'); insert NEMSA;
            Service_Agreement__c AGSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'E-AG', '1234567890'); insert AGSA;
            Service_Agreement__c OTSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'G-RES', '1234567890'); insert OTSA;
            Service_Agreement__c SLSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'E-LGHT', '234567890'); insert SLSA;
            // Create Premise
            Premise__c prem = TestUtility.createPremise(); insert prem;
            // Create Service Point
            Service_Point__c sp = TestUtility.createServicePoint(prem.Id); insert sp;
      
            system.assertEquals(0, [select Load_Score__c from Work_Item_Assignment__c where Id =: wia.Id].Load_Score__c); // validate that the CSR is available
            
            // Create Work Items
            List<Case> workItems = new List<Case>();
            // Add another set of work items for same account
            //Case WorkItem2 = TestUtility.CreateWorkItem('40', 'PSSTL', '', date.today() - 100, '', '', acc.Id, DASA.Id, true, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem2);
            Case WorkItem3 = TestUtility.CreateWorkItem('40', 'PSSTL', null, null, null, null, acc.Id, NEMSA.Id, false, null, null, queueId, recordtypeId); workItems.add(WorkItem3);
            Case WorkItem4 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 52, '', '', acc.Id, AGSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem4);
            Case WorkItem5 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 52, '', '', acc.Id, OTSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem5);
            Case WorkItem6 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 52, '', '', acc.Id, SLSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem6);
            //Case WorkItem31 = TestUtility.CreateWorkItem('40', 'PSSTL', null, null, null, null, acc.Id, NEMSA.Id, false, null, null, queueId, recordtypeId); workItems.add(WorkItem31);
            //Case WorkItem41 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 52, '', '', acc.Id, AGSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem41);
            //Case WorkItem51 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 52, '', '', acc.Id, OTSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem51);
            //Case WorkItem61 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 52, '', '', acc.Id, SLSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem61);
            insert workItems;
            // Validate that Parent has no Parent Id
            Case wi = [select SMSPST__c , ParentId, OwnerId, Parent.SMSPST__c, User_Skill_Rule__c, Status, SA_Type__c from Case where Id =: WorkItem3.Id];
            system.assertEquals('HN-ERES', wi.SA_Type__c); // Validate that SA Type is correct
            system.assertEquals(NEMusr.Id, wi.User_Skill_Rule__c); // validate that the user skill rule has been populated correctly
            system.assertNotEquals(queueId, wi.OwnerId); // Validate that the owner is not the queue
            system.assertEquals('Assigned', wi.Status); // Validate that status is Assigned
            system.assertEquals(null, wi.ParentId); // Validate that it is the Parent
            // Validate that child records have the correct Parent
            wi = [select SMSPST__c , ParentId, OwnerId, Parent.SMSPST__c from Case where Id =: WorkItem4.Id];
            system.assertEquals(WorkItem3.Id, wi.ParentId);
            
            wi = [select Work_Item_Assignment__c, OwnerId from Case where Id =: WorkItem3.Id];
            system.assertNotEquals(null, wi.Work_Item_Assignment__c);
            system.assertNotEquals(wia.Id, wi.OwnerId);
            
            // Test updateWorkItemAssignment, validate that the Work Item Assignment will be null if Owner is changed to the queue
            for(Case c : workItems){
                c.OwnerId = queueId;
            }
            update workItems;

            wi = [select Work_Item_Assignment__c from Case where Id =: WorkItem3.Id];
            system.assertEquals(null, wi.Work_Item_Assignment__c);
            
            // Validate that the work items are going to be re-grouped
      Case WorkItem1 = TestUtility.CreateWorkItem('40', 'PSSTL', '', date.today() - 200, '', '', acc.Id, DASA.Id, true, prem.Id, sp.Id, queueId, recordtypeId); insert WorkItem1;
            wi = [select ParentId, OwnerId from Case where Id =: WorkItem3.Id];
            system.assertEquals(WorkItem1.Id, wi.ParentId);
            system.assertEquals(CSR3.Id, wi.OwnerId);
            
            Case WorkItemDA = TestUtility.CreateWorkItem('40', 'PSSTL', '', date.today() - 200, '', '', acc.Id, DASA.Id, true, prem.Id, sp.Id, queueId, recordtypeId); insert WorkItemDA;
            
        }
    }
    
    static testMethod void testGroupWorkItems2() {
      Profile p = [select id from profile where name='CSR'];
        UserRole r = [Select id from userrole where name='CSR'];
        Profile padmin = [select id from profile where name='Administrator'];
        UserRole rbillops = [Select id from userrole where name='Billing Operations'];
        Profile pbillOpsHead = [select id from profile where name='Billing Ops Head'];
        UserRole rSupervisor = [Select id from userrole where name='Supervisor'];
        User admin= TestUtility.createUser(padmin.id,rbillops.id,3); admin.LAN_ID__c = 'ADM1'; insert admin;
        User supervisor= TestUtility.createUser(pbillOpsHead.id,rSupervisor.id,4);supervisor.LAN_ID__c = 'SUP1'; insert supervisor;
        User CSR= TestUtility.createUser(p.id,r.id,1);  CSR.Supervisor__c = supervisor.Id; CSR.LAN_ID__c = 'CSR1'; insert CSR;
        User CSR2= TestUtility.createUser(p.id,r.id,2); CSR2.Supervisor__c = supervisor.Id; CSR2.LAN_ID__c = 'CSR2'; insert CSR2;
        User CSR3= TestUtility.createUser(p.id,r.id,5); CSR3.Supervisor__c = supervisor.Id; CSR3.LAN_ID__c = 'CSR3'; insert CSR3;

        System.runAs(admin){
            Id queueId = [select Id, Name from Group where Name = 'Billing Exceptions' and Type = 'Queue'].Id;
          Id recordtypeId = [select Id from RecordType where Name='Billing Exceptions' and sObjectType = 'Case'].Id;  
            // Create Bill Cycle Window
            Bill_Cycle_Window__c bcw = TestUtility.createBillCycleWindow(); insert bcw;
            // Create TurnOnAssignmentandGrouping__c
            List<TurnOnAssignmentandGrouping__c> turnOnOffList = new List<TurnOnAssignmentandGrouping__c>();
            TurnOnAssignmentandGrouping__c turnOnBSEG = TestUtility.createTurnOnAssignmentandGrouping('BSEG', true, true); turnOnOffList.add(turnOnBSEG);
            TurnOnAssignmentandGrouping__c turnOnPSSTL = TestUtility.createTurnOnAssignmentandGrouping('PSSTL', true, true); turnOnOffList.add(turnOnPSSTL);
            TurnOnAssignmentandGrouping__c turnOnRetroCommencing = TestUtility.createTurnOnAssignmentandGrouping('Retro Commencing', false, true); turnOnOffList.add(turnOnRetroCommencing);
            insert turnOnOffList;
            
            List<User_Skill_Rule__c> usrList = new List<User_Skill_Rule__c>();
            User_Skill_Rule__c DAusr = TestUtility.createUserSkillRule(1, 'PSSTL', null, null, null, 'True', null, null, null, null, null, null, null); DAusr.Name = 'DA CCA PSSTL'; usrList.add(DAusr);
            User_Skill_Rule__c NEMusr = TestUtility.createUserSkillRule(2, 'PSSTL', null, null, 'HN-ERES', null, null, null, null, null, null, null, null); NEMusr.Name = 'NEM PSSTL'; usrList.add(NEMusr);
            User_Skill_Rule__c SLusr = TestUtility.createUserSkillRule(3, 'PSSTL', null, null, 'E-LGHT', null, null, null, null, null, null, null, null); SLusr.Name = 'Streetlight'; usrList.add(SLusr);
            User_Skill_Rule__c AGusr = TestUtility.createUserSkillRule(4, 'PSSTL', null, null, 'E-AG', null, null, null, null, null, null, null, null); AGusr.Name = 'Agricultural'; usrList.add(AGusr);
            insert usrList;
            // Create Work Item Assignments and User Skills
            Work_Item_Assignment__c wia = TestUtility.createWorkItemAssignment(CSR.Id, true); wia.Limit__c = 2; insert wia;
            Work_Item_Assignment__c wia2 = TestUtility.createWorkItemAssignment(CSR2.Id, true); wia2.Limit__c = 1; insert wia2;
            Work_Item_Assignment__c wia3 = TestUtility.createWorkItemAssignment(CSR3.Id, true); wia3.Limit__c = 1; insert wia3;
            User_Skill__c userSkill1 = TestUtility.createUserSkill(NEMusr.id,wia.id,wia); Insert userSkill1;
            User_Skill__c userSkill2 = TestUtility.createUserSkill(NEMusr.id,wia2.id,wia2); Insert userSkill2;
            User_Skill__c userSkill3 = TestUtility.createUserSkill(DAusr.id,wia3.id,wia3); Insert userSkill3;
            
            // Create Account
            Account acc = TestUtility.createAccount(date.today() - 60, 'Account 1', '0007652348'); insert acc;
            Account acc2 = TestUtility.createAccount(date.today() - 60, 'Account 2', '0007652350'); insert acc2;
            // Create Service Agreement
            Service_Agreement__c DASA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'E-RES', '1234567890'); insert DASA;
            Service_Agreement__c IntSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'HE-RES', '1234567890'); insert IntSA;
            Service_Agreement__c NEMSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'HN-ERES', '1234567890'); insert NEMSA;
            Service_Agreement__c AGSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'E-AG', '1234567890'); insert AGSA;
            Service_Agreement__c OTSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'G-RES', '1234567890'); insert OTSA;
            Service_Agreement__c SLSA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'E-LGHT', '234567890'); insert SLSA;
            // Create Premise
            Premise__c prem = TestUtility.createPremise(); insert prem;
            // Create Service Point
            Service_Point__c sp = TestUtility.createServicePoint(prem.Id); insert sp;
      
            system.assertEquals(0, [select Load_Score__c from Work_Item_Assignment__c where Id =: wia.Id].Load_Score__c); // validate that the CSR is available
            
            // Create Work Items
            List<Case> workItems = new List<Case>();
            // Add another set of work items for same account
            //Case WorkItem2 = TestUtility.CreateWorkItem('40', 'PSSTL', '', date.today() - 100, '', '', acc.Id, DASA.Id, true, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem2);
            Case WorkItem3 = TestUtility.CreateWorkItem('40', 'PSSTL', null, null, null, null, acc.Id, NEMSA.Id, false, null, null, queueId, recordtypeId); workItems.add(WorkItem3);
            Case WorkItem4 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 52, '', '', acc.Id, AGSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem4);
            Case WorkItem5 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 52, '', '', acc.Id, OTSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem5);
            Case WorkItem6 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 52, '', '', acc.Id, SLSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem6);
            //insert workItems;
            //workItems = new List<Case>();
            Case WorkItem31 = TestUtility.CreateWorkItem('40', 'PSSTL', null, null, null, null, acc2.Id, NEMSA.Id, false, null, null, queueId, recordtypeId); workItems.add(WorkItem31);
            Case WorkItem41 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 52, '', '', acc2.Id, AGSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem41);
            Case WorkItem51 = TestUtility.CreateWorkItem('30', 'Retro Commencing', '', date.today() - 52, '', '', acc2.Id, OTSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem51);
            Case WorkItem61 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 52, '', '', acc2.Id, SLSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); workItems.add(WorkItem61);
            insert workItems;
            
            //TXTR - replace current case statement with new one for defect 154
            //Case WorkItem62 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 52, '', '', acc.Id, SLSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); WorkItem62.ParentId = WorkItem3.Id; insert WorkItem62;
              Case WorkItem62 = TestUtility.CreateWorkItem('30', 'PSSTL', '', date.today() - 52, '', '', acc.Id, SLSA.Id, false, prem.Id, sp.Id, queueId, recordtypeId); WorkItem62.ParentId = WorkItem3.Id; WorkItem62.IsParent__c = false; insert WorkItem62;
            
        }
    }
    */
    /*************************************************************************
    * @author         Yefim Shuster and Janella Espiritu
    * @date           January, 2015
    * @description    This method tests Re-create of WI
    * @parameters     None
    * 
    * Modified by YXS7 on 02/18/2015 - new version is 1.1
    **************************************************************************/
	/*
	static testMethod void testRecreateWorkItems() {
      Test.startTest();
         
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
        Id queueId = [select Id, Name from Group where Name = 'Billing Exceptions' and Type = 'Queue'].Id;
        Id recordtypeId = [select Id from RecordType where Name='Billing Exceptions' and sObjectType = 'Case'].Id;
        
        // Modified by YXS7 on 02/18/2015 - commented out below and replaced - new version is 1.1
        //Id USRrecordtypeId = [select Id from RecordType where DeveloperName=: 'Billing_Operations_Exceptions' and sObjectType = 'User_Skill_Rule__c'].Id;
        Id USRrecordtypeId = [select Id from RecordType where DeveloperName='Billing_Operations_Exceptions' and sObjectType = 'User_Skill_Rule__c'].Id;
        
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
            // Create Work Item Assignment record  
            wia = TestUtility.createWorkItemAssignment(testUser.Id, false); insert wia;  
            // Create User Skill Rule
            usr_BSEG_Interval = TestUtility.createUserSkillRule(1, 'BSEG' , '', 'True', '', '', '', '', '', 'less than', 70, '', ''); usr_BSEG_Interval.RecordtypeId = USRrecordtypeId; Insert usr_BSEG_Interval;
            usr_PSSTL_Interval = TestUtility.createUserSkillRule(2, 'PSSTL' , '', 'True', '', '', '', '', '', 'less than', 60, '', ''); usr_PSSTL_Interval.RecordtypeId = USRrecordtypeId; Insert usr_PSSTL_Interval;
            // Create User Skill
            userSkill1=TestUtility.createUserSkill(usr_BSEG_Interval.id,wia.id, wia); Insert userSkill1;
            userSkill2=TestUtility.createUserSkill(usr_PSSTL_Interval.id,wia.id, wia); Insert userSkill2;
            system.debug('******userSkill1'+userSkill1);
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
            
            // Date in 2 days
            //date d = date.today().addDays(Integer.valueOf(System.Label.SLA_Notification_Days)); // j1eu added for PCR 139854
            date d = date.today();
        
            // Group 1
            Case WorkItem1 = TestUtility.CreateWorkItem('40', 'QAS8', '', d - 60, '', '', acc.Id, sa.Id, true, prem.Id, sp.Id, queueId, recordtypeId);
            workItem1.OwnerId = testuser.Id;
            workItems.add(WorkItem1); //parent
            
            Case WorkItem2 = TestUtility.CreateWorkItem('40', 'Retro Commencing', '', d - 60, '', '', acc.Id, sa.Id, false, prem.Id, sp.Id, queueId, recordtypeId);
            workItem2.OwnerId = testuser.Id;
            workItems.add(WorkItem2);
            
            Case WorkItem3 = TestUtility.CreateWorkItem('40', 'PSSTL', '', d - 60, '', '', acc.Id, sa.Id, false, prem.Id, sp.Id, queueId, recordtypeId);
            workItem3.OwnerId = testuser.Id;
            workItems.add(WorkItem3);
            
            // Group 2
            Case WorkItem4 = TestUtility.CreateWorkItem('40', 'PSSTL', '', d - 60, '', '', acc2.Id, sa.Id, false, prem.Id, sp.Id, queueId, recordtypeId);
            workItem4.OwnerId = testuser.Id;
            workItems.add(WorkItem4); 
            
            Case WorkItem5 = TestUtility.CreateWorkItem('40', 'BSEG', '', d - 60, '', '', acc2.Id, sa.Id, true, prem.Id, sp.Id, queueId, recordtypeId);
            workItem5.OwnerId = testuser.Id;
            workItems.add(WorkItem5); //parent
            
            Case WorkItem6 = TestUtility.CreateWorkItem('40', 'Retro Commencing', '', d - 60, '', '', acc2.Id, sa.Id, false, prem.Id, sp.Id, queueId, recordtypeId);
            workItem6.OwnerId = testuser.Id;
            workItems.add(WorkItem6);
            
            insert workItems;
            
            //WorkItem1 = [select SLA_Date__c, Event_Date__c from Case where Id =: WorkItem1.Id];
            //system.assertEquals(date.today().addDays(Integer.valueOf(System.Label.SLA_Notification_Days)), WorkItem1.SLA_Date__c);
            
            for (Case wi : workItems) {
                wi.Customer_Contact_Class__c = 'Records Dept Note';
                wi.Customer_Contact_Type__c = 'RECORDS';
                wi.As_Billed_Amount__c = 123;
                wi.As_Corrected_Amount__c = 123;
                wi.Billed_To_Amount__c = 123;
                wi.As_Billed_Corrected_From__c = date.today();
                wi.As_Billed_Corrected_To__c = date.today();
                wi.Billed_From_Date__c = date.today();
                wi.Billed_To_Date__c = date.today();
                wi.Root_Cause__c = 'Other';
                wi.Root_Cause_Other__c = 'Root Cause Other';
                wi.Additional_Customer_Contact_Comments__c = 'Additional Comments';
                wi.OwnerId = testuser.Id;
                wi.QAS8_Date__c = date.today();
                wi.Status = 'Completed';
                wi.Sub_Status__c = 'Completed by Assigned User';
                wi.Add_l_pending_start_stops_at_premise__c = true;
                wi.Clear_related_ToDos_for_Acct_Premise__c = true;
                wi.Is_the_account_billed_current__c = true;
                wi.Is_the_other_commodity_active__c = true;
                wi.Root_Cause__c ='CIF';
                wi.Root_Cause_Other__c = null;
                wi.Postpone_Credit_if_applicable__c = 'Yes';
                wi.Postpone_Credit_Date__c = date.today() + 10;
            }
            
            update workItems;
            
            Case c = new Case();
            c.AccountId = workItem1.AccountId;
            c.Bill_After_Dt__c = workItem1.Bill_After_Dt__c;
            c.Bill_Cycle__c = workItem1.Bill_Cycle__c;
            c.Commencing_Bill__c = workItem1.Commencing_Bill__c;
            c.DA_CCA_IND__c = workItem1.DA_CCA_IND__c;
            c.Event_Date__c = d;
            c.Exception_Message_Text__c = workItem1.Exception_Message_Text__c;
            c.Hold__c = workItem1.Hold__c;
            c.Int_WI_Key__c = workItem1.Int_WI_Key__c;
            c.Last_BSEG_End_Dt__c = workItem1.Last_BSEG_End_Dt__c;
            c.Local_Office__c = workItem1.Local_Office__c;
            c.Message_Number__c = workItem1.Message_Number__c;
            c.Message_Category_Number__c = workItem1.Message_Category_Number__c;
            c.Meter_Read_Cycle__c = workItem1.Meter_Read_Cycle__c;
            c.Mtr_Config_Ty_Cd__c = workItem1.Mtr_Config_Ty_Cd__c;
            c.ParentId = workItem1.Id;
            //TXTR - added customer parent field for defect 154
            c.IsParent__c = false;
            
            c.QAS8_Date__c = workItem1.QAS8_Date__c;
            c.Rate_Schedule__c = workItem1.Rate_Schedule__c;
            c.Recreated__c = true;
            //c.Reopened__c = workItem1.Reopen__c;
            c.SA_Relationship_Date__c = workItem1.SA_Relationship_Date__c;
            c.SA_Status__c = workItem1.SA_Status__c;
            c.SFDC_Prem_ID__c = workItem1.SFDC_Prem_ID__c;
            c.SFDC_SA_ID__c = workItem1.SFDC_SA_ID__c;
            c.SFDC_SP_ID__c = workItem1.SFDC_SP_ID__c;
            c.SFDC_WI_Key__c = workItem1.SFDC_WI_Key__c;
            c.SmartMeter_SP_Status_Description__c = workItem1.SmartMeter_SP_Status_Description__c;
            c.SMSPST__c = workItem1.SMSPST__c;
            c.SMSPST_EffDt__c = workItem1.SMSPST_EffDt__c;
            c.SPR_CD__c = workItem1.SPR_CD__c;
            c.SPR_Descr__c = workItem1.SPR_Descr__c;
            c.OwnerId = workItem1.OwnerId;
            c.Work_Item_Type__c = 'PSSTL';
            c.SA_Create_Date__c = workItem1.SA_Create_Date__c;
            
            insert c;
           
            Case ic = [select Id, Status, OwnerId, Work_Item_Assignment__c, Approver_Reviewer__c, Approver_Reviewer_Email__c from Case where Id = :c.Id];
              
            Work_Item_Assignment__c cwia = [select Id, User__c, User__r.Supervisor__c, User__r.Supervisor__r.Email from Work_Item_Assignment__c where User__c = :ic.OwnerId][0];
            
            System.AssertEquals(ic.OwnerId, cwia.User__c);
            System.AssertEquals(ic.Status, 'Assigned');
            System.AssertEquals(ic.Work_Item_Assignment__c, cwia.Id);
            System.AssertEquals(ic.Approver_Reviewer__c, cwia.User__r.Supervisor__c);
            System.AssertEquals(ic.Approver_Reviewer_Email__c, cwia.User__r.Supervisor__r.Email);
            
            Test.stopTest();
        }
    
    }*/
    
    /*************************************************************************
    * @author         Yefim Shuster and Janella Espiritu
    * @date           January, 2015
    * @description    This method tests Re-create of WI
    * @parameters     None
    * 
    * Modified by YXS7 on 02/18/2015 - new version is 1.1
    **************************************************************************/
    
		static testMethod void testReopenWorkItems() {
      Test.startTest();
         
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
        Id queueId = [select Id, Name from Group where Name = 'Billing Exceptions' and Type = 'Queue'].Id;
        Id recordtypeId = [select Id from RecordType where Name='Billing Exceptions' and sObjectType = 'Case'].Id;
        Id closedRecordtypeId = [select Id from RecordType where Name='Closed Work Item - Billing Exceptions' and sObjectType = 'Case'].Id;
        
        // Modified by YXS7 on 02/18/2015 - commented out below and replaced - new version is 1.1
        //Id USRrecordtypeId = [select Id from RecordType where DeveloperName=: 'Billing_Operations_Exceptions' and sObjectType = 'User_Skill_Rule__c'].Id;
        Id USRrecordtypeId = [select Id from RecordType where DeveloperName='Billing_Operations_Exceptions' and sObjectType = 'User_Skill_Rule__c'].Id;
        
        //User to create test data
        Profile padmin = [select id from profile where name='Administrator'];
        UserRole rbillops = [Select id from userrole where name='Billing Operations'];
        User admin= TestUtility.createUser(padmin.id,rbillops.id,1); admin.Lan_ID__c = 'ADM1'; insert admin;
        
        // Query Profile and User Role
        Profile p = [select id from profile where name='CSR'];
        Profile p2 = [select id from profile where name='SSR'];
        UserRole r = [Select id from userrole where name='CSR'];
        // Create Test User
        User testuser2= TestUtility.createUser(p2.id,r.id, 2); 
        testuser2.Lan_ID__c = 'USR2'; 
        insert testuser2;
        
        //create users
        User testuser= TestUtility.createUser(p.id,r.id, 3); 
        testuser.Lan_ID__c = 'USR3'; 
        testuser.Supervisor__c = testuser2.Id; insert testuser;
        
        // Create inactive user
        User testInactiveUser= TestUtility.createUser(p.id,r.id, 4); 
        testInactiveUser.Lan_ID__c = 'USR4'; 
        testInactiveUser.IsActive = false;
        insert testInactiveUser;
        
        System.runAs(admin){  
            // Create Work Item Assignment record  
            wia = TestUtility.createWorkItemAssignment(testUser.Id, false); insert wia;  
            // Create User Skill Rule
            usr_BSEG_Interval = TestUtility.createUserSkillRule(1, 'BSEG' , '', 'True', '', '', '', '', '', 'less than', 70, '', '',null); usr_BSEG_Interval.RecordtypeId = USRrecordtypeId; 
            usr_BSEG_Interval.Name = 'Fast/Slow Meter Adj - Gas';
            Insert usr_BSEG_Interval;
            usr_PSSTL_Interval = TestUtility.createUserSkillRule(2, 'PSSTL' , '', 'True', '', '', '', '', '', 'less than', 60, '', '',null); usr_PSSTL_Interval.RecordtypeId = USRrecordtypeId; Insert usr_PSSTL_Interval;
            // Create User Skill
            userSkill1=TestUtility.createUserSkill(usr_BSEG_Interval.id,wia.id, wia); Insert userSkill1;
            userSkill2=TestUtility.createUserSkill(usr_PSSTL_Interval.id,wia.id, wia); Insert userSkill2;
            system.debug('******userSkill1'+userSkill1);
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
            
            // Date in 2 days
            //date d = date.today().addDays(Integer.valueOf(System.Label.SLA_Notification_Days)); // j1eu added for PCR 139854
            date d = date.today();
        
            // Group 1
            Case WorkItem1 = TestUtility.CreateWorkItem('40', 'QAS8', '', d - 60, '', '', acc.Id, sa.Id, true, prem.Id, sp.Id, queueId, recordtypeId);
            workItem1.OwnerId = testuser.Id;
            workItem1.Approver_Reviewer_Email__c = 'txtr@pge.com';
            workItems.add(WorkItem1); //parent
            
            // Workitem with inactive user and reopened.
            Case WorkItem2 = TestUtility.CreateWorkItem('40', 'Retro Commencing', '', d - 60, '', '', acc.Id, sa.Id, false, prem.Id, sp.Id, queueId, recordtypeId);
            //workItem2.OwnerId = testInactiveUser.Id;
            workItems.add(WorkItem2);
            
            Case WorkItem3 = TestUtility.CreateWorkItem('40', 'PSSTL', '', d - 60, '', '', acc.Id, sa.Id, false, prem.Id, sp.Id, queueId, recordtypeId);
            workItem3.OwnerId = testuser.Id;
            workItems.add(WorkItem3);
            
            // Group 2
            Case WorkItem4 = TestUtility.CreateWorkItem('40', 'PSSTL', '', d - 60, '', '', acc2.Id, sa.Id, false, prem.Id, sp.Id, queueId, recordtypeId);
            workItem4.OwnerId = testuser.Id;
            workItems.add(WorkItem4); 
            
            Case WorkItem5 = TestUtility.CreateWorkItem('40', 'BSEG', '', d - 60, '', '', acc2.Id, sa.Id, true, prem.Id, sp.Id, queueId, recordtypeId);
            workItem5.OwnerId = testuser.Id;
            workItems.add(WorkItem5); //parent
            
            Case WorkItem6 = TestUtility.CreateWorkItem('40', 'Retro Commencing', '', d - 60, '', '', acc2.Id, sa.Id, false, prem.Id, sp.Id, queueId, recordtypeId);
            workItem6.OwnerId = testuser.Id;
            workItems.add(WorkItem6);
            
            insert workItems;
            
            //WorkItem1 = [select SLA_Date__c, Event_Date__c from Case where Id =: WorkItem1.Id];
            //system.assertEquals(date.today().addDays(Integer.valueOf(System.Label.SLA_Notification_Days)), WorkItem1.SLA_Date__c);
            
            for (Case wi : workItems) {
                wi.Customer_Contact_Class__c = 'Records Dept Note';
                wi.Customer_Contact_Type__c = 'RECORDS';
                wi.As_Billed_Amount__c = 123;
                wi.As_Corrected_Amount__c = 123;
                wi.Billed_To_Amount__c = 123;
                wi.As_Billed_Corrected_From__c = date.today();
                wi.As_Billed_Corrected_To__c = date.today();
                wi.Billed_From_Date__c = date.today();
                wi.Billed_To_Date__c = date.today();
                wi.Root_Cause__c = 'Other';
                wi.Root_Cause_Other__c = 'Root Cause Other';
                wi.Additional_Customer_Contact_Comments__c = 'Additional Comments';
                wi.OwnerId = testuser.Id;
                wi.QAS8_Date__c = date.today();
                wi.Status = 'Completed';
                wi.Sub_Status__c = 'Completed by Assigned User';
                wi.Add_l_pending_start_stops_at_premise__c = true;
                wi.Clear_related_ToDos_for_Acct_Premise__c = true;
                wi.Is_the_account_billed_current__c = true;
                wi.Is_the_other_commodity_active__c = true;
                wi.Root_Cause__c ='CIF';
                wi.Root_Cause_Other__c = null;
                wi.Postpone_Credit_if_applicable__c = 'Yes';
                wi.Postpone_Credit_Date__c = date.today() + 10;
                wi.RecordTypeId = closedRecordtypeId;
                wi.SOX_Required_Information__c = '--None--';
				System.debug(Logginglevel.info,'%%%%%%%%%%%%%%%%%%userIds...' + workItems);
            }
            
            update workItems;            
            // reopen workitem 1 and do the trigger
            workItem1.Reopened__c = true;
			//workItem1.OwnerId = testuser.Id;
            //workItem1.Approver_Reviewer_Email__c = 'txtr@pge.com';
            //workItem1.Recordtype.Name = 'Closed Work Item - Billing Exceptions';
            update workItem1;

        }
    
    }
    
    /*************************************************************************
    * @author         Yefim Shuster
    * @date           02/18/2015
    * @description    This method tests Grouping of WI re-assigned form MBT Queue to Billing Exceptions queue
    * @parameters     None
    * @version        1.0
    **************************************************************************/
    /*
	static testMethod void testGroupMBTtoBillingExceptionsWorkItems() {
      Test.startTest();
         
        Work_Item_Assignment__c wia;
        
        //User skill rule records
        User_Skill_Rule__c  usr_BSEG_Interval_30;
        User_Skill_Rule__c  usr_BSEG_Interval_40;
        
        //User Skill records
        User_Skill__c  userSkill1;
        User_Skill__c  userSkill2;

        Group testGroup;
        QueuesObject testQueue;
        // Query Queue
        Id queueId = [select Id, Name from Group where Name = 'Billing Exceptions' and Type = 'Queue'].Id;
        Id recordtypeId = [select Id from RecordType where Name='Billing Exceptions' and sObjectType = 'Case'].Id;
        
        Id closedRecordtypeId = [select Id from RecordType where Name='Closed Work Item - Billing Exceptions' and sObjectType = 'Case'].Id;
        Id USRrecordtypeId = [select Id from RecordType where DeveloperName='Billing_Operations_Exceptions' and sObjectType = 'User_Skill_Rule__c'].Id;
        
        Id mbtQueue = [select Id, Name from Group where Name = 'BSEG MBT Elec SM30 SM40' and Type = 'Queue'].Id;
        
        System.Assert(mbtQueue != null);
        
        Id USRMBTrecordtypeId = [select Id from RecordType where DeveloperName='BSEG_MBT_Elec_SM30_SM40' and sObjectType = 'User_Skill_Rule__c'].Id;
        
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
            // Create Work Item Assignment record  
            wia = TestUtility.createWorkItemAssignment(testUser.Id, false); insert wia;  
            
            // Create User Skill Rule
            usr_BSEG_Interval_30 = TestUtility.createUserSkillRule(1, 'BSEG' , '', 'True', '', '', '', '', '', 'less than', 70, '', '');
            usr_BSEG_Interval_30.RecordtypeId = USRMBTrecordtypeId;
            usr_BSEG_Interval_30.SMSPST__c = '30';
            Insert usr_BSEG_Interval_30;
            
            usr_BSEG_Interval_40 = TestUtility.createUserSkillRule(2, 'BSEG' , '', 'True', '', '', '', '', '', 'less than', 70, '', '');
            usr_BSEG_Interval_40.RecordtypeId = USRMBTrecordtypeId;
            usr_BSEG_Interval_40.SMSPST__c = '40';
            Insert usr_BSEG_Interval_40;
            
            // Create User Skill
            userSkill1=TestUtility.createUserSkill(usr_BSEG_Interval_30.id,wia.id, wia); Insert userSkill1;
            userSkill2=TestUtility.createUserSkill(usr_BSEG_Interval_40.id,wia.id, wia); Insert userSkill2;
            system.debug('******userSkill1'+userSkill1);
          
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
            
            // Create Lookup Rollup Summary
            dlrs__LookupRollupSummary__c dlrs = TestUtility.createLookupRollupSummary(); insert dlrs;
            
            // Create Work Items
            List<Case> workItems = new List<Case>(); 
            
            // Date in 2 days
            //date d = date.today().addDays(Integer.valueOf(System.Label.SLA_Notification_Days)); // j1eu added for PCR 139854
            date d = date.today();
        
            // Group 1
            
            Case WorkItem1_30 = TestUtility.CreateWorkItem('30', 'BSEG', '', d - 60, '', '', acc2.Id, sa.Id, true, prem.Id, sp.Id, mbtQueue, recordtypeId);
            workItems.add(WorkItem1_30); //parent
            
            Case WorkItem2_40 = TestUtility.CreateWorkItem('40', 'BSEG', '', d - 60, '', '', acc2.Id, sa.Id, false, prem.Id, sp.Id, mbtQueue, recordtypeId); 
            workItems.add(WorkItem2_40);
            
            insert workItems;
            
            //WorkItem1 = [select SLA_Date__c, Event_Date__c from Case where Id =: WorkItem1.Id];
            //system.assertEquals(date.today().addDays(Integer.valueOf(System.Label.SLA_Notification_Days)), WorkItem1.SLA_Date__c);
            
            Case wi_30 = [select Id, CaseNumber, User_Skill_Rule__c, User_Skill_Rule__r.Name, OwnerId, Owner.Name, RecordTypeId, RecordType.Name from Case where Id = :WorkItem1_30.Id];
            Case wi_40 = [select Id, CaseNumber, User_Skill_Rule__c, User_Skill_Rule__r.Name, OwnerId, Owner.Name, RecordTypeId, RecordType.Name from Case where Id = :WorkItem2_40.Id];
            
            System.Assert(wi_30.Id != null);
            System.Assert(wi_40.Id != null);
            System.AssertEquals(wi_30.RecordType.Name, 'Billing Exceptions');
            System.AssertEquals(wi_40.RecordType.Name, 'Billing Exceptions');
            //System.AssertEquals(wi_30.Owner.Name, 'BSEG MBT Elec SM30 SM40');
            //System.AssertEquals(wi_40.Owner.Name, 'BSEG MBT Elec SM30 SM40');
            System.Assert(wi_30.OwnerId != null);
            System.Assert(wi_30.Owner.Name == null);
            
            Test.stopTest();
        }
    
    }*/
	/*************************************************************************
    * @author         Janella Espiritu
    * @date           05/14/2015
	* @description    This method will test concatenateAdditionalComments
    * @parameters     None
    * @version        1.0
    **************************************************************************/
	// Test concatenateAdditionalComments
/*
    static testMethod void testconcatenateAdditionalComments(){
        
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
        
        // Query Queue
        Id queueId = WorkItemAssignmentUtility.getBillingExceptionQueueId();
        Id recordtypeId = WorkItemAssignmentUtility.getCaseBillingExceptionsRecordTypeId();
        system.runAs(admin){
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
            // Create User Skill Rule record
            User_Skill_Rule__c IntUSR     = TestUtility.createUserSkillRule(3, 'BSEG', null, 'TRUE', null, null, null, null, null, null, null, null, null, null); 
            IntUSR.Name = 'Fast/Slow Meter Adj - Gas'; IntUSR.GroupingEnabled__c=TRUE;
            IntUSR.AssignmentEnabled__c = true;
            insert INTUSR;
            Case WorkItem = TestUtility.CreateWorkItem('40', 'PSSTL', 'Pending Start', null, '24164', '90000', acc.Id, DASA.Id, true, prem.Id, sp.Id, queueId, recordtypeId); 
            WorkItem.CC_B_Case_ID__c = '1234567890';
           // Insert the WorkItem (should concatenate the Additional Customer Contact)
            insert WorkItem;
    		Test.startTest();
            // Validate that the Additional Customer Contact has been concatenated correctly
            Case wi = new Case();
            wi = [select OwnerId, 
                            CreatedDate, 
                            Root_Cause__c, 
                            Postpone_Credit_Date__c, 
                            Additional_Customer_Contact_Comments__c, 
                            Revenue_Assurance_Account_Number__c, 
                            Revenue_Assurance_SA_ID__c, 
                            Billed_Reason__c, 
                            Root_Cause_Category__c, 
                            Root_Cause_Other__c, 
                            CC_B_Case_ID__c,
                            Additional_Customer_Comments_back_end__c,
                            Work_Item_Type__c
                            from Case 
                            where Id =: WorkItem.Id];
            System.assert(wi.Additional_Customer_Comments_back_end__c.contains(wi.CC_B_Case_ID__c));
            System.assert(wi.Additional_Customer_Comments_back_end__c.contains(String.valueOf(wi.Work_Item_Type__c)));
            // Update the work item and populate  the fields that are included on the Additional Customer Contact
            // (should concatenate the Additional Customer Contact again)
            WorkItem.Customer_Contact_Class__c = 'Records Dept Note';
            WorkItem.Customer_Contact_Type__c = 'RECORDS';
            WorkItem.OwnerId = CSR.Id;
            update WorkItem;
            // Validate that the Additional Customer Comments back end is concatenated correctly
            wi = [select OwnerId, 
                            CreatedDate, 
                            Root_Cause__c, 
                            Postpone_Credit_Date__c, 
                            Additional_Customer_Contact_Comments__c, 
                            Revenue_Assurance_Account_Number__c, 
                            Revenue_Assurance_SA_ID__c, 
                            Billed_Reason__c, 
                            Root_Cause_Category__c, 
                            Root_Cause_Other__c, 
                            CC_B_Case_ID__c,
                            Additional_Customer_Comments_back_end__c,
                            Work_Item_Type__c
                            from Case 
                            where Id =: WorkItem.Id];
            System.assert(wi.Additional_Customer_Comments_back_end__c.contains(wi.CC_B_Case_ID__c));
            System.assert(wi.Additional_Customer_Comments_back_end__c.contains(String.valueOf(wi.Work_Item_Type__c)));
            // Close the work item and populate  the fields that are included on the Additional Customer Contact
            // (should concatenate the Additional Customer Contact again)
            WorkItem.Postpone_Credit_Date__c = date.today() + 60;
            WorkItem.Postpone_Credit_if_applicable__c = 'Yes';
            WorkItem.Status = 'Completed';
            WorkItem.Sub_Status__c = 'Completed by Assigned User';
            WorkItem.Root_Cause__c = 'Other';
            WorkItem.Additional_Customer_Contact_Comments__c = 'This is a test class';
            WorkItem.Revenue_Assurance_Account_Number__c = '7894561230';
            WorkItem.Revenue_Assurance_SA_ID__c = '2486461245';
            WorkItem.Billed_Reason__c = 'This is the billed reason';
            WorkItem.Root_Cause_Category__c = 'Employee Rates';
            WorkItem.Root_Cause_Other__c = 'Other Reason';
            WorkItem.SOX_Required_Information__c = null;
            update WorkItem;
            // Validate that the Additional Customer Comments back end is concatenated correctly
            wi = [select OwnerId, 
                            CreatedDate, 
                            Root_Cause__c, 
                            Postpone_Credit_Date__c, 
                            Additional_Customer_Contact_Comments__c, 
                            Revenue_Assurance_Account_Number__c, 
                            Revenue_Assurance_SA_ID__c, 
                            Billed_Reason__c, 
                            Root_Cause_Category__c, 
                            Root_Cause_Other__c, 
                            CC_B_Case_ID__c,
                            Additional_Customer_Comments_back_end__c,
                            Work_Item_Type__c
                            from Case 
                            where Id =: WorkItem.Id];
            
            System.assert(wi.Additional_Customer_Comments_back_end__c.contains(wi.CC_B_Case_ID__c));
            System.assert(wi.Additional_Customer_Comments_back_end__c.contains(wi.Root_Cause__c));
            System.assert(wi.Additional_Customer_Comments_back_end__c.contains(String.valueOf(wi.Work_Item_Type__c)));
            Test.stopTest();
        }
    }
*/
    // Test concatenateAdditionalComments
    static testMethod void testconcatenateCustomerContactComments(){
        
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
        
        // Query Queue
        Id queueId = WorkItemAssignmentUtility.getBillingExceptionQueueId();
        Id recordtypeId = WorkItemAssignmentUtility.getCaseBillingExceptionsRecordTypeId();
        system.runAs(admin){
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
            Case WorkItem = TestUtility.CreateWorkItem('40', 'PSSTL', 'Pending Start', null, '24164', '90000', acc.Id, DASA.Id, true, prem.Id, sp.Id, queueId, recordtypeId); 
            WorkItem.Customer_Contact_Class__c = 'Records Dept Note';
            WorkItem.Customer_Contact_Type__c = 'RECORDS';
            WorkItem.CC_Service_Agreement_ID__c = '1234567890';
            WorkItem.As_Billed_Amount__c = 1234;
            WorkItem.As_Corrected_Amount__c = 3214;
            WorkItem.As_Billed_Corrected_From__c = date.today();
            WorkItem.As_Billed_Corrected_To__c = date.today();
            WorkItem.Billed_From_Date__c = date.today();
            WorkItem.Billed_To_Date__c = date.today();
            WorkItem.Billed_To_Amount__c = 4545;
           // Insert the WorkItem (should concatenate the Additional Customer Contact)
            insert WorkItem;
    		Test.startTest();
            // Validate that the Additional Customer Contact has been concatenated correctly
            Case wi = new Case();
            wi = [select CC_Service_Agreement_ID__c, 
                            As_Billed_Amount__c, 
                            As_Corrected_Amount__c, 
                            As_Billed_Corrected_Diff_Amt__c, 
                            Billed_From_Date__c, 
                            Billed_To_Date__c, 
                            Billed_To_Amount__c,
                  			Customer_Contact_Comments__c
                            from Case 
                            where Id =: WorkItem.Id];
            System.assert(wi.Customer_Contact_Comments__c.contains(wi.CC_Service_Agreement_ID__c));
            System.assert(wi.Customer_Contact_Comments__c.contains(String.valueOf(wi.As_Billed_Amount__c)));
            // Update the work item and populate  the fields that are included on the Additional Customer Contact
            // (should concatenate the Additional Customer Contact again)
            WorkItem.CC_Service_Agreement_ID__c = '1234567890';
            WorkItem.As_Billed_Amount__c = 8521;
            WorkItem.As_Corrected_Amount__c = 7894;
            WorkItem.Billed_From_Date__c = date.today();
            WorkItem.Billed_To_Date__c = date.today();
            WorkItem.Billed_To_Amount__c = 4545;
            update WorkItem;
            // Validate that the Additional Customer Comments back end is concatenated correctly
             wi = [select CC_Service_Agreement_ID__c, 
                            As_Billed_Amount__c, 
                            As_Corrected_Amount__c, 
                            As_Billed_Corrected_Diff_Amt__c, 
                            Billed_From_Date__c, 
                            Billed_To_Date__c, 
                            Billed_To_Amount__c,
                  			Customer_Contact_Comments__c
                            from Case 
                            where Id =: WorkItem.Id];
            System.assert(wi.Customer_Contact_Comments__c.contains(wi.CC_Service_Agreement_ID__c));
            System.assert(wi.Customer_Contact_Comments__c.contains(String.valueOf(wi.As_Billed_Amount__c)));
            // Close the work item and populate  the fields that are included on the Additional Customer Contact
            // (should concatenate the Customer Contact Comments again)
            WorkItem.CC_Service_Agreement_ID__c = '1234567890';
            WorkItem.As_Billed_Amount__c =  4444;
            WorkItem.As_Corrected_Amount__c =  5555;
            WorkItem.Billed_From_Date__c = date.today();
            WorkItem.Billed_To_Date__c = date.today();
            WorkItem.Billed_To_Amount__c =  7777;
            update WorkItem;
            // Validate that the Customer Contact Comments is concatenated correctly
             wi = [select CC_Service_Agreement_ID__c, 
                            As_Billed_Amount__c, 
                            As_Corrected_Amount__c, 
                            As_Billed_Corrected_Diff_Amt__c, 
                            Billed_From_Date__c, 
                            Billed_To_Date__c, 
                            Billed_To_Amount__c,
                  			Customer_Contact_Comments__c
                            from Case 
                            where Id =: WorkItem.Id];
            System.assert(wi.Customer_Contact_Comments__c.contains(wi.CC_Service_Agreement_ID__c));
            System.assert(wi.Customer_Contact_Comments__c.contains(String.valueOf(wi.As_Billed_Amount__c)));
            
            // Update customer contact so it will exceed 254 characters
            WorkItem.As_Billed_Amount__c =  123123546.112638546;
            WorkItem.As_Corrected_Amount__c =  123123546.112638546;
            WorkItem.Billed_To_Amount__c =  123123546.112638546;
            try{
                update WorkItem;
            }
            catch(Exception e){
                Boolean expectedExceptionThrown =  e.getMessage().contains('The maximum number of characters for Customer Contact Comments is 254.') ? true : false;
               System.AssertEquals(true, expectedExceptionThrown);
            }
            Test.stopTest();
        }
    }
}